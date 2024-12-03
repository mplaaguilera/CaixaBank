/**********************************************************************************************************************
Name:	  AV_InterlocutionGroup_Controller
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Tareas y eventos asociados a la oportunidad
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	  AUTHOR		   	DATE				Description
	1.0			US352009	  Luis Fernández  	16/01/2023		  	Init version
                US517372
    1.1         Fix Avoid Bulk Luis Fernández   18/06/2023          Added RunAs and amplified Start Stop Test Ranges
***********************************************************************************************************************/
@isTest
public with sharing class AV_InterlocutionGroup_Controller_Test {
    @TestSetup
    static void setup(){
        User usrGFC = [SELECT Id,Name FROM User WHERE Alias = 'AV-TF9' LIMIT 1];
        User usrCli =[Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User usrTest = AV_TestHelper.createUser(null,'99999990','AV_SistematicaComercial');
        AV_TestHelper.insertNeededPermissions(usrTest);

        Account memberGroup = new Account();
       
        System.runAs(usrCli){
            memberGroup = AV_TestHelper.createCustomerSinInsert();
            memberGroup.OwnerId = usrTest.Id;
            insert memberGroup;
        }
        System.runAs(usrGFC){
       
            Account center = AV_TestHelper.createCaixaCenter();
            Contact cnt = AV_TestHelper.createEmployee(center,usrTest);
            AV_GrupoInterlocucion__C grp = new AV_GrupoInterlocucion__c();
            grp.Name = 'GrupoTest';
            grp.AV_Numper__c = memberGroup.id;
            grp.AV_IsInterlocutor__c = true;
            grp.OwnerId = usrTest.Id;
            insert grp;
        
            
        }

     

       
    }

    @isTest 
    public static void retrieveGroupsTest(){
        User gest = [SELECT Id FROM User WHERE AV_ExternalID__c = '99999990'];
        Account noGrpClient = AV_TestHelper.createCustomerSinInsert();
        noGrpClient.FirstName = 'accountSinGrupo';
        noGrpClient.LastName = 'accountSinGrupo';
        noGrpClient.CC_Numero_Documento__c = '9446376R';
        noGrpClient.AV_Numperso__c = '1234';
        noGrpClient.OwnerId = gest.Id;
        Account grpClient = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = '9446386T' LIMIT 1];
        Test.startTest();
        List<AV_GrupoInterlocucion__c> noEmptyList = new List<AV_GrupoInterlocucion__c>();
        List<AV_GrupoInterlocucion__c> emptyList = new List<AV_GrupoInterlocucion__c>();
        System.runAs(gest){
             noEmptyList = AV_InterlocutionGroup_Controller.retrieveGroupsList(grpClient.Id);
             emptyList = AV_InterlocutionGroup_Controller.retrieveGroupsList(noGrpClient.Id);
             
             Test.stopTest();
             
             System.assert(!noEmptyList.isEmpty());
             System.assert(emptyList.isEmpty());
            }
        }

    @isTest 
    public static void countRecordsTest(){
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        User usrTst = [SELECT Id FROM User WHERE AV_ExternalID__c = '99999990' LIMIT 1];
        Account grpClient = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = '9446386T' LIMIT 1];
        Account center = [SELECT Id FROM Account WHERE CC_Numero_Oficina_Empresa__c = '00615' ];
        Contact cnt = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :usrTst.Id];
        Test.startTest();
        
        // AV_TestHelper.createOpportunityWithEmpleadoSinInsert(grpClient);
        Opportunity opp = AV_TestHelper.createOpportunityWithEmpleadoSinInsert(grpClient,cnt);
        opp.OwnerId = usrTst.Id;
        insert opp;
        System.runAs(usrTst){
        Task t = AV_TestHelper.createTareaExternalIdWithCustomerSinInsert(usrTst,null,grpClient);
            t.ActivityDate = System.today();
            insert t;
            AV_TestHelper.createEvent(usrTst,System.today().addDays(1),grpClient);
            Map<String,Integer> resultTest = AV_InterlocutionGroup_Controller.countRecords('GrupoTest');
            Test.stopTest();
            for(String obj : resultTest.keySet()){
                System.assert(resultTest.get(obj) != null);
            }
        }





    }

    @isTest 
    public static void getRecordsAllTest(){
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        User usrTst = [SELECT Id FROM User WHERE AV_ExternalID__c = '99999990' LIMIT 1];
        Account grpClient = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = '9446386T' LIMIT 1];
        Contact cnt = AV_TestHelper.createEmployee(null,usrTst);
        AV_TestHelper.createOpportunityExternalId(grpClient,cnt,null);
        Task t = AV_TestHelper.createTareaExternalIdWithCustomerSinInsert(usrTst,null,grpClient);
        t.ActivityDate = System.today();
        insert t;
        AV_TestHelper.createEvent(usrTst,System.today().addDays(1),grpClient);
        Test.startTest();
            List<Object> testTasks = new List<Object>();
            List<Object> testEvents = new List<Object>();
            List<Object> testOppos = new List<Object>();
            List<Object> testOpposNoVigentes = new List<Object>();
            List<Object> coverNullLine = new List<Object>();
        System.runAs(usrTst){

             testTasks = AV_InterlocutionGroup_Controller.getRecordsCurrentObject('GrupoTest', AV_AppConstants.OBJECT_NAME_TASK, null);
             testEvents = AV_InterlocutionGroup_Controller.getRecordsCurrentObject('GrupoTest', AV_AppConstants.OBJECT_NAME_EVENT, null);
             testOppos = AV_InterlocutionGroup_Controller.getRecordsCurrentObject('GrupoTest', AV_AppConstants.OBJECT_NAME_OPPORTUNITY, 'V');
             testOpposNoVigentes = AV_InterlocutionGroup_Controller.getRecordsCurrentObject('GrupoTest', AV_AppConstants.OBJECT_NAME_OPPORTUNITY, 'NV');
             coverNullLine = AV_InterlocutionGroup_Controller.getRecordsCurrentObject('GrupoTest', 'NonExistingObject', null);
             
             
             Test.stopTest();
             System.assert(!testTasks.isEmpty());
             System.assert(!testEvents.isEmpty());
             System.assert(!testOppos.isEmpty());
             System.assert(testOpposNoVigentes.isEmpty());
            }
        }

}