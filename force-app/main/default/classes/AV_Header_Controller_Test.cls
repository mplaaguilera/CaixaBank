/**********************************************************************************************************************
Name:	  AV_Header_Controller_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_Header_Controller"
-----------------------------------------------------------------------------------------------------------------------
Historial
    VERSION		USER_STORY		AUTHOR				DATE			Description
    1.0			Test Class		Ángel Medina		28/06/2023		Init version. Copy the CIBE_Header_Controller_Test class from CIBE 
-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/

@isTest
public with sharing class AV_Header_Controller_Test {
    
    private static final String FILTER_SOBJECT	= 'Account';
    private static final String FIELDSET_NAME	= 'AV_FlexiHeader';
 
    
    

     /***********************************************************************************************************/
    @TestSetup
    static void setup(){
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        User userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
        AV_TestHelper.insertNeededPermissions(userGestor);
        List<Account> listAccounts = new List<Account>();
              System.runAs(usuCli) {
                   Account centro = AV_TestHelper.createCaixaCenterSinInsert();
                   centro.OwnerId = userGestor.Id;
                   Account acc = AV_TestHelper.createCustomerSinInsert();
                   acc.OwnerId = userGestor.Id;
                   listAccounts.add(centro);
                   listAccounts.add(acc);
                   Database.insert(listAccounts,false);
           }
        
        System.runAs(userGcf){
             Contact contact = AV_TestHelper.createEmployee(listAccounts[0], userGestor);     
             Event eventoCliente = AV_TestHelper.createEvent(userGestor, DateTime.now(), listAccounts[1]);
        }
               
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK')); 
    }

    /***********************************************************************************************************/
    @isTest
    private static void getNameTest() {
        User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        
        Test.startTest();
        System.runAs(us){
           Account acc = [select id from account limit 1]; 
           String valorCampo = AV_Header_Controller.getName(acc.id,'name');
           System.assert(valorCampo != Null);  
        }
		Test.stopTest();  
    }
    /***********************************************************************************************************/
	@isTest
    private static void getDateLoadTest() {
        User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        
        Account acc = [select id from account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT limit 1];
        Test.startTest();
        System.runAs(us){
            String valorFecha = AV_Header_Controller.getDateLoad(acc.id);
            System.assert(valorFecha == Null); 
        }
        Test.stopTest();  
        
    }
    /***********************************************************************************************************/
    @isTest
    private static void getActionsTest() {
         User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        
        Map<String,AV_FlowActions__mdt> flowM = AV_FlowActions__mdt.getAll();
        List<AV_Header_Controller.Action> actionf = new List<AV_Header_Controller.Action>();
        
        Test.startTest();
        System.runAs(us){
            actionf = AV_Header_Controller.getActions('AV_Account');
            System.assertEquals(actionf.size()>0,true);
        }
        Test.stopTest();
         
        
        
    }
    /***********************************************************************************************************/
     @isTest
    private static void getFieldsTest() {
        User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        
        Test.startTest();
        System.runAs(us){
        Account acc = [select id from account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT limit 1]; 
        Event evt = [select id from Event limit 1];
        List<Object> listField= AV_Header_Controller.getFields(acc.id, 'AV_FlexiHeader');
        List<Object> listField2= AV_Header_Controller.getFields(evt.id, 'AV_HeaderFields');
        System.assert(!listField2.isEmpty()); 
        }
 		Test.stopTest();  
    }
    /***********************************************************************************************************/

    @isTest
    private static void getAccountInfoTest(){
        User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        Account accCliente = [SELECT Id, Name, RecordType.DeveloperName FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT LIMIT 1];

        Test.startTest();
        System.runAS(us){
            List<String> accountInfo = AV_Header_Controller.getAccountInfo(accCliente.Id);
            System.assertNotEquals(null, accountInfo);
        }
        Test.stopTest();
        
    }
    
    /**************************************************************************************************************/
    
    
    
   
}