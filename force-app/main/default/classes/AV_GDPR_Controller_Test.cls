/**********************************************************************************************************************
Name:     AV_GDPR_Controller_Test
Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Test para el controlador de GDPR
=======================================================================================================================
Historial
---------------------
VERSION     USER_STORY     AUTHOR               DATE            Description
1.0         Test Class     Esperanza Conde      17/09/2020      Init version
1.1         Test Class     Carolina Alonso      01/10/2020      Add test to cover new logic
1.2         Test Class     Eric Vazquez         14/10/2020      Add test to cover update logic
1.3         AV_Query IT    Daniel Rodríguez     07/02/2022      Change AV_Query to SOQL for User and Account
1.4         US568949       Ángel Medina.         19/04/2023     Added custom setting record
1.5         US649249       Óscar Moreno         27/11/2023      Include system.asserts in all methods
1.6         US866754       Oscar Moreno        25/04/2024       Add  testgetJsonGDPR  method          

***********************************************************************************************************************/
@isTest
public with sharing class AV_GDPR_Controller_Test {
   
    private static final String AV_USUARIO_CAIXABANK = 'AV_Usuario_CaixaBank';
   
    @TestSetup
    static void setup(){
        CBK_IntegrationSetting__c gdpr = new CBK_IntegrationSetting__c();
        gdpr.Name = 'AV_GDPR';
        gdpr.NamedCredential__c = 'callout:GDPRControllerTest';
        Database.insert(gdpr);
        AV_TestHelper.activateLogger();
 
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User userGestor;
 
        System.runAs(userGcf){
 
            userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
            userGestor.Email = 'gestor-test@test.com';
            User usrTest = AV_TestHelper.createUserSinInsert('Standard User','U01543678');
            List<User> listUserInsert = new List<User>();
            listUserInsert.add(userGestor);
            listUserInsert.add(usrTest);
            insert listUserInsert;
            List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
            List<PermissionSet> perSet = [SELECT Id FROM PermissionSet WHERE Name IN :new List<String>{ 'AV_GestorOperativa', 'AV_CustomMetadata' }];
            for(PermissionSet ps : perSet) {
                permissionSetList.add(
                    new PermissionSetAssignment(
                        AssigneeId = userGestor.Id,
                        PermissionSetId = ps.Id
                ));
            }
            if(!permissionSetList.isEmpty()) {
                insert permissionSetList;
            }
 
 
            PermissionSetGroup psg = [SELECT Id, Status FROM PermissionSetGroup WHERE DeveloperName = 'AV_Gestor' LIMIT 1];
            Map<String, PermissionSetAssignment> mapPs = new Map<String, PermissionSetAssignment>();
            List<PermissionSetAssignment> listAssignment = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetGroupId =:psg.Id AND AssigneeId=:userGestor.Id];
            for (PermissionSetAssignment ass: listAssignment) {
                mapPs.put(ass.AssigneeId, ass);
            }
            if(psg.Status != 'Updated'){
                Test.calculatePermissionSetGroup(psg.Id);
            }
            if(!mapPs.containsKey(userGestor.id)) {
                insert new PermissionSetAssignment(PermissionSetGroupId = psg.Id, AssigneeId = userGestor.Id);    
            }
             
            Account cliente = AV_TestHelper.createCustomerSinInsert();
            cliente.AV_Numperso__c = '102302498';
            cliente.AV_JSONGDPR__c = '';
            //cliente.AV_JSONGDPR__c ='[{"value":"No admite publicidad del gestor","key":"21"}]';
            cliente.AV_JSONAlertas__c ='[{"value":"No admite publicidad del gestor","key":"21"}]';
            cliente.OwnerId = userGestor.id;
        
        
            Account cliente2 = AV_TestHelper.createCustomerSinInsert();
            cliente2.AV_Numperso__c = '';
            cliente2.AV_FechaRefrescoGDPR__c = DateTime.now()-2;
            cliente2.OwnerId = userGestor.id;
            insert new List<Account> {cliente,cliente2};
       
           
        }
    }
   
    

    @isTest
    public static void testgetJsonGDPR() {
                   
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454'];
        AV_GDPR_Controller.response response;
        Account cliente =[SELECT Id,AV_JSONGDPR__c FROM Account WHERE AV_Numperso__c = '102302498' ];
        Account cliente2 =[SELECT Id FROM Account WHERE AV_Numperso__c = '' ];    
       
        
        
        Test.startTest();
        System.runAs(userGestor){
            userGestor.AV_ExternalId__c='';
            update userGestor;

            
            try{
                AV_GDPR_Controller.getJsonGDPR(cliente.id);

                
             
            }catch(Exception e){
                System.assertEquals(cliente.AV_JSONGDPR__c,'No admite publicidad del gestor');
            }
           
           
        }
        Test.stopTest();
        
    }
 
    
 
    @isTest
    public static void testcheckgetGDPRForCampaigns() {
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454'];
       
        List<List<String>> fields;
        List<List<String>> fields2;
       
        Account cliente =[SELECT Id FROM Account WHERE AV_Numperso__c = '102302498' ];
        Account cliente2 =[SELECT Id FROM Account WHERE AV_Numperso__c = '' ];
       
        
 
        System.runAs(userGestor){  
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GDPR','OK'));
            fields = new List<List<String>>();
            List<String> field = new List<String>();
            field.add(cliente.Id);
            fields.add(field);
           
            fields2 = new List<List<String>>();
            List<String> field2 = new List<String>();
            field2.add(cliente2.Id);
            fields2.add(field2);
        }
 
       
   
        Test.startTest();
        System.runAs(userGestor){  
            try{
                List<Boolean> res = AV_GDPR_Controller.getGDPRForCampaigns(fields);
                List<Boolean> res2 = AV_GDPR_Controller.getGDPRForCampaigns(fields2);
            }catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Error') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }  
        }
       
        Test.stopTest();
       
       
       
       
    }
   
    @isTest
    public static void checkGDPRResponseTest(){
       
        User userGestor = [SELECT Id,AV_ExternalID__c FROM User WHERE AV_ExternalID__c = 'U01545454'];
        AV_GDPR_Controller.response response;
        Account cliente =[SELECT Id,AV_JSONGDPR__c,AV_Numperso__c FROM Account WHERE AV_Numperso__c = '102302498' ];
                 
        System.runAs(userGestor){                      
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GDPR','OK'));
        }
 
        Test.startTest();
        System.runAs(userGestor){
           
            try{
                AV_GDPR_Integration.GDPRResponse dataGDPR1 = AV_GDPR_Integration.checkTreatments('0040-A','EVA', cliente.AV_NumPerso__c, userGestor.AV_ExternalID__c);
                 response = new AV_GDPR_Controller.response();
                //response = AV_GDPR_Controller.getTreatments(cliente.Id);
                AV_GDPR_Controller.checkGDPRResponse(response, dataGDPR1, true);
             
            }catch(Exception e){
                System.assertEquals(e.getMessage(),'error in response');
            }
        }
        Test.stopTest();
       
     
    }
   
   @isTest
    public static void testcheckgetGDPRForCampaigns2() {
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454'];
        userGestor.AV_ExternalId__c = '';
        update userGestor;
        List<List<String>> fields;
       
       
        Account cliente =[SELECT Id FROM Account WHERE AV_Numperso__c = '102302498' ];
       
       
        System.runAs(userGestor){  
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GDPR','OK'));
            fields = new List<List<String>>();
            List<String> field = new List<String>();
            field.add(cliente.Id);
            fields.add(field);
           
        }
 
        Test.startTest();
        System.runAs(userGestor){  
            try{
                List<Boolean> res = AV_GDPR_Controller.getGDPRForCampaigns(fields);
            }catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Error') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }  
        }
       
        Test.stopTest();
    }
   
   
    @isTest
    public static void testcheckgetGDPRForCampaigns3Error() {
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454'];
        List<List<String>> fields;
       
       
       
 
        Test.startTest();
        System.runAs(userGestor){  
            try{
                List<Boolean> res = AV_GDPR_Controller.getGDPRForCampaigns(fields);
            }catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Error') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }  
        }
       
        Test.stopTest();
    }
   
}