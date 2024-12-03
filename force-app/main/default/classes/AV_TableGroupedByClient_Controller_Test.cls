/**********************************************************************************************************************
 Name:	  AV_TableGroupedByClient_Controller_Test
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test AV_TableGroupedByClient_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Ainhoa				01/04/2023			Init version
	1.0			Fix Ejec Lentas	Sandra				14/02/2024			Fix Ejec Lentas
***********************************************************************************************************************/
@isTest
public with sharing class AV_TableGroupedByClient_Controller_Test {
    
    @TestSetup
    static void setup(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User managerUser;
        System.runAs(userGcf) {
            Profile caixaBankProfile = [SELECT Id FROM Profile WHERE Name = 'AV_Usuario_CaixaBank'];
            managerUser = new User(
                Alias = 'u',
                Email = 'test2@test.dev',
                EmailEncodingKey = 'UTF-8',
                LastName = 'testLastName',
                LanguageLocaleKey = 'es',
                LocaleSidKey = 'es',
                TimeZoneSidKey = 'Europe/Berlin',
                AV_NumeroOficinaEmpresa__c = '001-15243',
                ProfileId = caixaBankProfile.Id,
                UserName = 'testu3@test.dev',
                AV_ExternalID__c = 'U0009103',
                IsActive = true,
                AV_Funcion__c = 'Gestor'
            );
            insert managerUser;
            AV_TestHelper.insertPermissionSet(managerUser.Id,AV_AppConstants.PS_PRIVATEBANKING);
        }
        User us1 = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U0009103'];
        Account cenTest = AV_TestHelper.createCaixaCenterSinInsert();
        cenTest.CC_Numero_Oficina__c = '15243';
        cenTest.CC_Numero_Oficina_Empresa__c = '001-15243';
        insert cenTest;
        Contact conTest = AV_TestHelper.createEmployee(cenTest, managerUser, 'U0009103');
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        Account customer;
        customer = AV_TestHelper.createCustomer();
        customer.AV_Priority__c = 2000;
        customer.AV_AhorroEInversion__c = 200;
        customer.AV_Financiacion__c = 100;
        customer.AV_Preconceived__c = 1000;
        update(customer);
        RecordType giRecordType = AV_AppUtilities.getRecordType('AV_GrupoInterlocucion__c', AV_AppConstants.INTERLOC_GROUP_RT);
        AV_GrupoInterlocucion__c gi = new AV_GrupoInterlocucion__c();
        gi.Name = 'GRUPO 1';
        gi.AV_Numper__c = customer.Id;
        gi.AV_IsInterlocutor__c = false;
        gi.RecordTypeId = giRecordType.Id;
        insert gi;
        List<Task> taskToInsertList = new List<Task>();
        Test.startTest();
        RecordType initiativeRt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKEXPCLIENT_RT);
		Task initiativeTask  = new Task();
		initiativeTask.OwnerId = managerUser.Id;
		initiativeTask.Status = 'Open';
        initiativeTask.Subject = 'Test';
		initiativeTask.Priority = 'A';
        initiativeTask.ActivityDate = system.today();
		initiativeTask.AV_OrigenApp__c = 'AV_SalesforceTaskOpp'; 
		initiativeTask.RecordTypeId = initiativeRt.Id;
        initiativeTask.ActivityDate = system.today();
		initiativeTask.AV_ToDelete__c = FALSE;
        initiativeTask.WhatId = customer.Id;
        initiativeTask.AV_Valor1__c = null;
        initiativeTask.AV_Valor2__c = null;
        initiativeTask.WhatId = customer.Id;
        initiativeTask.AV_Center__c = '15243';
        taskToInsertList.add(initiativeTask);
        RecordType prioritiserRt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKONBOARDING_RT);
		Task prioritaserTask  = new Task();
		prioritaserTask.OwnerId = managerUser.Id;
		prioritaserTask.Status = 'Open';
        prioritaserTask.Subject = 'Test';
		prioritaserTask.Priority = 'A';
        prioritaserTask.ActivityDate = system.today();
		prioritaserTask.RecordTypeId = prioritiserRt.Id;
        prioritaserTask.AV_ToDelete__c = FALSE;
        prioritaserTask.WhatId = customer.Id;
        prioritaserTask.AV_Center__c = '15243';
        taskToInsertList.add(prioritaserTask);
        RecordType iniciativaRt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
		Task iniciativaTask  = new Task();
		iniciativaTask.OwnerId = managerUser.Id;
		iniciativaTask.Status = 'Open';
        iniciativaTask.Subject = 'Test';
		iniciativaTask.Priority = 'A';
        iniciativaTask.ActivityDate = system.today();
		iniciativaTask.RecordTypeId = iniciativaRt.Id;
        iniciativaTask.AV_ToDelete__c = FALSE;
        iniciativaTask.WhatId = customer.Id;
        iniciativaTask.AV_Center__c = '15243';
        taskToInsertList.add(iniciativaTask);
        insert taskToInsertList;
		Account testAcc1 = [SELECT FirstName FROM Account WHERE FirstName = 'FirstName'];
        testAcc1.OwnerId = managerUser.Id;
        update testAcc1;
        Test.stopTest();
        AV_Score__c score2 = new AV_Score__c();
        score2.AV_Object__c = 'Task';
        score2.AV_RecordType__c = AV_AppConstants.TASKALERTACOM_RT;
        insert score2;
    }

    @IsTest
    public static void getDataTest(){
        User us1 = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U0009103'];
        AV_TableGroupedByClient_Controller.Filters filters = new AV_TableGroupedByClient_Controller.Filters();
        filters.subjectFilterValue = null;
        filters.preconcedidoFilterValue = null;
        filters.myBoxFilterValue = null;
        filters.targetAutoFilterValue = null;
        filters.origenFilterValue = null;
        filters.employeesFilter = new List<String>{us1.Id};
        filters.officeFilter = us1.AV_NumeroOficinaEmpresa__c.split(AV_AppConstants.DASH)[1];
        String[]arrayOrigen1 = new String[]{AV_AppConstants.TASKEXPCLIENT_RT};
        String[]arrayOrigen2 = new String[]{'AV_Otros'};
        String[]arrayOrigen3 = new String[]{AV_AppConstants.TASKONBOARDING_RT};  
        Test.startTest();
        System.runAs(us1){
            List<Task> debuging = [SELECT Subject,Status,RecordType.DeveloperName, AV_OrigenApp__c,Owner.Name,AV_Center__c FROM Task];
            List<AV_TableGroupedByClient_Controller.TableGroupedByClientWrapper> result = AV_TableGroupedByClient_Controller.getData(filters, arrayOrigen1);
            System.assertEquals(1, result.size());
            List<AV_TableGroupedByClient_Controller.TableGroupedByClientWrapper> result3 = AV_TableGroupedByClient_Controller.getData(filters, new List<String>{AV_AppConstants.TASKINICIATIVA_RT,AV_AppConstants.TASKONBOARDING_RT});
            List<AV_TableGroupedByClient_Controller.TableGroupedByClientWrapper> result5 = AV_TableGroupedByClient_Controller.getData(filters, new List<String>{AV_AppConstants.TASKINICIATIVA_RT});
            List<AV_TableGroupedByClient_Controller.TableGroupedByClientWrapper> result6 = AV_TableGroupedByClient_Controller.getData(filters, new List<String>());
            List<AV_TableGroupedByClient_Controller.TableGroupedByClientWrapper> result4 = AV_TableGroupedByClient_Controller.getData(filters, arrayOrigen3 );
            System.assertEquals(1, result4.size());
        }
        Test.stopTest();
    }
    
    @isTest
    public static void orderTaskByOrigenTest(){
        List<Task> listTask = [SELECT Id,Account.AV_Priority__c,RecordType.DeveloperName from Task];
        User us1 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009103'];
        List<Task> results = new List<Task>();
        Test.startTest();
        System.runAs(us1){
             results= AV_TableGroupedByClient_Controller.orderTaskByOrigen(listTask);    
        }
        System.assertNotEquals(results, null);
        Test.stopTest();
    }
    
    @isTest
    public static void getScoreTest(){
        User us1 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009103'];
        AV_Score__c score = new AV_Score__c();
        score.AV_Object__c = 'Task';
        score.AV_RecordType__c = AV_AppConstants.TASKALERTACOM_RT;
        insert score;
        Test.startTest();
        System.runAs(us1){
            AV_TableGroupedByClient_Controller.getScore();
        }
        System.assertEquals(AV_TableGroupedByClient_Controller.getScore(), null);
        Test.stopTest();
    }

    @isTest
    public static void poolTest(){
        
        Test.startTest();
        User us1 = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U0009103'];
        us1.Alias = 'multige';
        us1.AV_Pool__c = TRUE;
        update us1;
        Account center = [SELECT Id FROM Account WHERE CC_Numero_Oficina_Empresa__c = '001-15243'];
        center.AV_TipoEstructura__c = '02';
        center.AV_TipoCentroSuperior__c = 'TT';
        update center;
        System.runAs(us1){
            AV_TableGroupedByClient_Controller.Filters filters = new AV_TableGroupedByClient_Controller.Filters();
            filters.subjectFilterValue = null;
            filters.preconcedidoFilterValue = null;
            filters.myBoxFilterValue = null;
            filters.targetAutoFilterValue = null;
            filters.origenFilterValue = null;
            filters.employeesFilter = new List<String>{us1.Id};
            filters.officeFilter = us1.AV_NumeroOficinaEmpresa__c.split(AV_AppConstants.DASH)[1];
            List<AV_TableGroupedByClient_Controller.TableGroupedByClientWrapper> result6 = AV_TableGroupedByClient_Controller.getData(filters, new List<String>());
            System.assert(result6 != null);
        }
        Test.stopTest();


    }

    @isTest

    public static void getEmployeesTest(){
        User us1 = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U0009103'];
        
        
        System.runAs(us1){
            Test.startTest();
            String data = us1.AV_NumeroOficinaEmpresa__c.split('-')[1]+'{|}'+'all';
            String data2 = us1.AV_NumeroOficinaEmpresa__c.split('-')[1]+'{|}'+AV_AppConstants.TASKINICIATIVA_RT;
            List<AV_TableGroupedByClient_Controller.OptionsEmployee> res1 = AV_TableGroupedByClient_Controller.getEmployees(data);
            List<AV_TableGroupedByClient_Controller.OptionsEmployee> res2 = AV_TableGroupedByClient_Controller.getEmployees(data2);
            List<AV_TableGroupedByClient_Controller.OptionsEmployee> res3 = AV_TableGroupedByClient_Controller.getEmployees(us1.AV_NumeroOficinaEmpresa__c);
            Test.stopTest();

            System.assert(res1 != null && res2 != null);
        }

    }   
}