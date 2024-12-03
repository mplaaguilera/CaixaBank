@isTest
public with sharing class AV_TableGroupedByClient_Controller_Test {
    
    @TestSetup
    static void setup(){
        
        Profile caixaBankProfile = [SELECT Id FROM Profile WHERE Name = 'AV_Usuario_CaixaBank'];

        User managerUser = new User(
            Alias = 'u',
            Email = 'test2@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '00615',
            ProfileId = caixaBankProfile.Id,
            UserName = 'testu3@test.dev',
            AV_ExternalID__c = 'U0009103',
            IsActive = true,
            AV_Funcion__c = 'Gestor'
        );
        insert managerUser;
        
        
        Account cenTest = AV_TestHelper.createCaixaCenter();
        Contact conTest = AV_TestHelper.createEmployee(cenTest, managerUser);
        
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        Account customer;
        customer = AV_TestHelper.createCustomer();
        customer.AV_Priority__c = 2000;
        update(customer);
        

        
        List<Task> taskToInsertList = new List<Task>();

        RecordType initiativeRt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
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
        taskToInsertList.add(initiativeTask);

        RecordType prioritiserRt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKPRIORIZADOR_RT);
		Task prioritaserTask  = new Task();
		prioritaserTask.OwnerId = managerUser.Id;
		prioritaserTask.Status = 'Open';
        prioritaserTask.Subject = 'Test';
		prioritaserTask.Priority = 'A';
        prioritaserTask.ActivityDate = system.today();
		prioritaserTask.RecordTypeId = prioritiserRt.Id;
        prioritaserTask.AV_ToDelete__c = FALSE;
        prioritaserTask.WhatId = customer.Id;

        taskToInsertList.add(prioritaserTask);
        insert taskToInsertList;

		Account testAcc1 = [SELECT FirstName FROM Account WHERE FirstName = 'FirstName'];
        testAcc1.OwnerId = managerUser.Id;
        update testAcc1;
        
        AV_Score__c score2 = new AV_Score__c();
        score2.AV_Object__c = 'Task';
        score2.AV_RecordType__c = AV_AppConstants.TASKALERTACOM_RT;
        insert score2;
    }


    
    
    @IsTest
    public static void getDataTest(){
        User us1 = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '00615'];
        AV_TableGroupedByClient_Controller.Filters filters = new AV_TableGroupedByClient_Controller.Filters();
        filters.subjectFilterValue = null;
        filters.preconcedidoFilterValue = null;
        filters.myBoxFilterValue = null;
        filters.targetAutoFilterValue = null;
        filters.origenFilterValue = null;
        
        
        String[]arrayOrigen1 = new String[]{AV_AppConstants.TASKINICIATIVA_RT};
        String[]arrayOrigen2 = new String[]{'AV_Otros'};
            
        Test.startTest();
        System.runAs(us1){
            List<AV_TableGroupedByClient_Controller.TableGroupedByClientWrapper> result = AV_TableGroupedByClient_Controller.getData(filters, arrayOrigen1);
            System.assertEquals(1, result.size());
            List<AV_TableGroupedByClient_Controller.TableGroupedByClientWrapper> result2 = AV_TableGroupedByClient_Controller.getData(filters, arrayOrigen2);
            System.assertEquals(1, result2.size());
            List<AV_TableGroupedByClient_Controller.TableGroupedByClientWrapper> result3 = AV_TableGroupedByClient_Controller.getData(filters, null);
            System.assertEquals(2, result3.size());
        }
        Test.stopTest();
    }
    
    @isTest
    public static void orderTaskByOrigenTest(){
        List<Task> listTask = [SELECT Id,Account.AV_Priority__c,RecordType.DeveloperName from Task];
        User us1 = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '00615'];
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
        User us1 = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '00615'];
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
        
 
}