/**********************************************************************************************************************
Name:	  AV_MetricChart_Controller_Test
Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Clase de test de "AV_MetricChart_Controller"
=======================================================================================================================
Historial
---------------------
VERSION     USER_STORY              AUTHOR              DATE            Description
1.0         Home Custom             Álvaro López        21/10/2020      Init version
1.1		    AV_Query IT	            Daniel Rodríguez	04/03/2022	    Change AV_Query to SOQL for User, Account, Contact
1.7			US719862				Gonzalo Ávila		04/10/2023		Delete methods related to AV_ShowHomeV4 permission (Prio 2.0)
***********************************************************************************************************************/
@isTest
public with sharing class AV_MetricChart_Controller_Test {
     
     @testSetup
	 static void testSetup() {
        
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

		Account caixaCenter = new Account(
			Name = '00615 STORE DOS DE MAIG-ROSSELLO' , CC_Numero_Oficina_Empresa__c = '00615'
		);       
        insert caixaCenter;
         
        AV_TestHelper.createEmployee( caixaCenter , managerUser);
    }

    /**
	 * Retrieve custom metadata type data
	 */
	@isTest
	public static void getDataTest() {
        
        User managerUser = [SELECT Id from User WHERE Email = 'test2@test.dev' LIMIT 1];
        
        AV_ConfiguracionGrafico__mdt chartConfig = [Select Label, DeveloperName From AV_ConfiguracionGrafico__mdt where AV_ReportName__c != null limit 1];
        /*AV_ConfiguracionGrafico__mdt chartConfig = (AV_ConfiguracionGrafico__mdt) new AV_Query('AV_ConfiguracionGrafico__mdt')
                                        .selectField('DeveloperName')
                                        .selectField('Label')
                                        .addConditionNotEq('AV_ReportName__c', null)
                                        .setLimit(1)
                                        .fetch();*/
        system.RunAs(managerUser){
          
        Test.startTest();
        AV_MetricChart_Controller.ChartData chart = AV_MetricChart_Controller.getData(chartConfig.DeveloperName);
        Test.stopTest();
        System.assertEquals(chartConfig.Label, chart.title, 'Los títulos del informe no coinciden.');
    }
    }
    
    @isTest
	public static void getDataDonutChartTest() {
        
        User managerUser = [SELECT Id from User WHERE Email = 'test2@test.dev' LIMIT 1];
        
        List<Task> taskToInsertList = new List<Task>();
        RecordType initiativeRt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
		Task initiativeTask  = new Task();
		initiativeTask.OwnerId = managerUser.Id;
		initiativeTask.Status = 'Open';
		initiativeTask.Priority = 'A';
        initiativeTask.ActivityDate = system.today();
		initiativeTask.AV_OrigenApp__c = 'AV_SalesforceTaskOpp'; 
		initiativeTask.RecordTypeId = initiativeRt.Id; 
        taskToInsertList.add(initiativeTask);
        
        RecordType prioritiserRt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKPRIORIZADOR_RT);
		Task prioritaserTask  = new Task();
		prioritaserTask.OwnerId = managerUser.Id;
		prioritaserTask.Status = 'Open';
		prioritaserTask.Priority = 'A';
        prioritaserTask.ActivityDate = system.today();
		prioritaserTask.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';
		prioritaserTask.RecordTypeId = prioritiserRt.Id;
        taskToInsertList.add(prioritaserTask);
        
        RecordType clientExpRt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKEXPCLIENT_RT);
		Task clientExpTask  = new Task();
		clientExpTask.OwnerId = managerUser.Id;
		clientExpTask.Status = 'Open';
		clientExpTask.Priority = 'A';
        clientExpTask.ActivityDate = system.today();
		clientExpTask.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';
		clientExpTask.RecordTypeId = clientExpRt.Id;
        taskToInsertList.add(clientExpTask);
        
        RecordType commercialAlertRt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKALERTACOM_RT);
        Task commercialAlertTask  = new Task();
		commercialAlertTask.OwnerId = managerUser.Id;
		commercialAlertTask.Status = 'Open';
		commercialAlertTask.Priority = 'A';
        commercialAlertTask.ActivityDate = system.today();
		commercialAlertTask.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';
		commercialAlertTask.RecordTypeId = commercialAlertRt.Id;
        taskToInsertList.add(commercialAlertTask);
        
		insert taskToInsertList;
                
        List<AV_NotifyMe__c> notifymeToInsertList = new List<AV_NotifyMe__c>();
        AV_NotifyMe__c muroNotify  = new AV_NotifyMe__c();
        muroNotify.AV_OrigenAct__c  = 'AV_Muro';
        muroNotify.AV_Status__c  = 'AV_Pendiente';
        muroNotify.OwnerId  = managerUser.Id;
        muroNotify.AV_OperationActivityDate__c = Date.TODAY();
        notifymeToInsertList.add(muroNotify);
        
        AV_NotifyMe__c stopGoNotify  = new AV_NotifyMe__c();
        stopGoNotify.AV_OrigenAct__c  = 'AV_R2B';
        stopGoNotify.AV_Status__c  = 'AV_Pendiente';
        stopGoNotify.OwnerId  = managerUser.Id;
        stopGoNotify.AV_OperationActivityDate__c = Date.TODAY();
        notifymeToInsertList.add(stopGoNotify);

        AV_NotifyMe__c callNotify  = new AV_NotifyMe__c();
        callNotify.AV_OrigenAct__c  = 'AV_Llamadas';
        callNotify.AV_Status__c  = 'AV_Pendiente';
        callNotify.OwnerId  = managerUser.Id;
        callNotify.AV_OperationActivityDate__c = Date.TODAY();
        notifymeToInsertList.add(callNotify);
        
        insert notifymeToInsertList;
        
		AV_ConfiguracionGrafico__mdt priorManageClients = [Select Label, DeveloperName, AV_Data__c From AV_ConfiguracionGrafico__mdt where DeveloperName = 'AV_PriorManageClients' limit 1];
        AV_ConfiguracionGrafico__mdt pendingConversations = [Select Label, DeveloperName, AV_Data__c From AV_ConfiguracionGrafico__mdt where DeveloperName = 'AV_PendingConversation' limit 1];
		AV_ConfiguracionGrafico__mdt todaysAppointments = [Select Label, DeveloperName, AV_Data__c From AV_ConfiguracionGrafico__mdt where DeveloperName = 'AV_TodaysAppointments' limit 1];

        Test.startTest();
        
        System.runAs(managerUser){
            AV_MetricChart_Controller.ChartData chartClients = AV_MetricChart_Controller.getData(priorManageClients.DeveloperName);
            AV_MetricChart_Controller.ChartData chartConversations = AV_MetricChart_Controller.getData(pendingConversations.DeveloperName);
            AV_MetricChart_Controller.ChartData chartAppointments = AV_MetricChart_Controller.getData(todaysAppointments.DeveloperName);
                
            System.assertEquals(chartClients.numRecords, 4);
            System.assertEquals(chartConversations.numRecords, 3);
        }

        Test.stopTest();
    }

}