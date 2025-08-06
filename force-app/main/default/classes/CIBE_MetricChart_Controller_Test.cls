/**********************************************************************************************************************************************************************************************
Name:	  CIBE_MetricChart_Controller_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de "CIBE_MetricChart_Controller"
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Historial
------------------------
VERSION     USER_STORY              AUTHOR              DATE            Description
1.0         US486064                Ali y Bea           14/09/2023      Init version
1.1         US746418                Bea                 14/11/2023      Se añaden las pruebas para los metadataChart de "Citas en los próximos 7 días" y "Oportunidades en lo próximos 7 días"

**********************************************************************************************************************************************************************************************/
@isTest
public with sharing class CIBE_MetricChart_Controller_Test {
    
    @testSetup
	static void testSetup() {
        
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP, CIBE_AppConstants.USER_AV_AVOIDBULKAPI};
        
        
        CIBE_TestInitialSetup.setupInitialData(null, null, null, null, null, ps);
        User usrSetup = [SELECT Id, AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        User managerUser = [SELECT Id, AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        managerUser.AV_NumeroOficinaEmpresa__c = '001-00001';
        update managerUser;

        String centroUser = [SELECT AV_Funcion__c, AV_NumeroOficinaEmpresa__c
        FROM User WHERE Id = :usrSetup.Id].AV_NumeroOficinaEmpresa__c;
        String centroU = centroUser.split('-')[1];
        
        System.runAs(managerUser) {

            // Account centro = CIBE_TestHelper.createCaixaCenter('00615 STORE DOS DE MAIG-ROSSELLO','00615');
            // Contact employee = CIBE_TestHelper.createEmployee(centro, usrGestor);
            List<Task> taskToInsertList = new List<Task>();

        //TASK EMP 
        RecordType initiativeRtEMP = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);
		Task initiativeTaskEMP  = new Task();
		initiativeTaskEMP.OwnerId = managerUser.Id;
		initiativeTaskEMP.Status = 'Open';
		initiativeTaskEMP.Priority = 'A';
        initiativeTaskEMP.ActivityDate = System.today(); 
		initiativeTaskEMP.RecordTypeId = initiativeRtEMP.Id; 
        taskToInsertList.add(initiativeTaskEMP);
        
        RecordType prioritiserRtEMP = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_PRIORIZADOS_EMP_RT);
		Task prioritaserTaskEMP  = new Task();
		prioritaserTaskEMP.OwnerId = managerUser.Id;
		prioritaserTaskEMP.Status = 'Open';
		prioritaserTaskEMP.Priority = 'A';
        prioritaserTaskEMP.ActivityDate = System.today();
		prioritaserTaskEMP.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';
		prioritaserTaskEMP.RecordTypeId = prioritiserRtEMP.Id;
        taskToInsertList.add(prioritaserTaskEMP);
        
        RecordType clientExpRtEMP = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_EMP_RT);
		Task clientExpTaskEMP  = new Task();
		clientExpTaskEMP.OwnerId = managerUser.Id;
		clientExpTaskEMP.Status = 'Open';
		clientExpTaskEMP.Priority = 'A';
        clientExpTaskEMP.ActivityDate = System.today();
		clientExpTaskEMP.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';
		clientExpTaskEMP.RecordTypeId = clientExpRtEMP.Id;
        taskToInsertList.add(clientExpTaskEMP);
        
        RecordType commercialAlertRtEMP = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_EMP_RT);
        Task commercialAlertTaskEMP  = new Task();
		commercialAlertTaskEMP.OwnerId = managerUser.Id;
		commercialAlertTaskEMP.Status = 'Open';
		commercialAlertTaskEMP.Priority = 'A';
        commercialAlertTaskEMP.ActivityDate = System.today();
		commercialAlertTaskEMP.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';
		commercialAlertTaskEMP.RecordTypeId = commercialAlertRtEMP.Id;
        taskToInsertList.add(commercialAlertTaskEMP);
        

        RecordType onboardingCIBRtEMP = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ONBOARDING_EMP_RT);
        Task onboardingCIBTaskEMP  = new Task();
		onboardingCIBTaskEMP.OwnerId = managerUser.Id;
		onboardingCIBTaskEMP.Status = 'Open';
		onboardingCIBTaskEMP.Priority = 'A';
        onboardingCIBTaskEMP.ActivityDate = System.today();
		onboardingCIBTaskEMP.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';
		onboardingCIBTaskEMP.RecordTypeId = onboardingCIBRtEMP.Id;
        taskToInsertList.add(onboardingCIBTaskEMP);

        // TASK AVISOS EMP
        RecordType avisosEMP = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_AVISOS_EMP_RT);
        Task avisosEMPTask  = new Task();
		avisosEMPTask.OwnerId = managerUser.Id;
		avisosEMPTask.Status = 'Open';
		avisosEMPTask.Priority = 'A';
        avisosEMPTask.ActivityDate = System.today();
		avisosEMPTask.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';
		avisosEMPTask.RecordTypeId = avisosEMP.Id;
        avisosEMPTask.AV_PriorityTask__c = true;
        taskToInsertList.add(avisosEMPTask);
		insert taskToInsertList;

        // NOTIFYME - CONVERSACIONES PENDIENTES
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

        AV_NotifyMe__c pendientesdeFirmaNotify  = new AV_NotifyMe__c();
        pendientesdeFirmaNotify.AV_OrigenAct__c  = 'CIBE_OperacionesPendientesFirma';
        pendientesdeFirmaNotify.AV_Status__c  = 'AV_Pendiente';
        pendientesdeFirmaNotify.OwnerId  = managerUser.Id;
        pendientesdeFirmaNotify.AV_OperationActivityDate__c = Date.TODAY();
        notifymeToInsertList.add(pendientesdeFirmaNotify);
        
        insert notifymeToInsertList;
        Test.startTest();

        //EVENTOS DE HOY
        List<Event> eventToInsertList = new List<Event>();
        RecordType eventosCliente = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
        Event eventToday1  = new Event();
        eventToday1.ActivityDate = System.today();
        eventToday1.OwnerId = managerUser.Id;
        eventToday1.RecordTypeId = eventosCliente.Id;
        eventToday1.AV_InOutbound__c = '002';
        eventToday1.DurationInMinutes = 60;
        eventToday1.ActivityDateTime = System.today();
        eventToInsertList.add(eventToday1);
        
        //EVENTOS PROXIMOS 7 DIAS + HOY
        Event eventToday2  = new Event();
        eventToday2.ActivityDate = System.today();
        eventToday2.OwnerId = managerUser.Id;
        eventToday2.RecordTypeId = eventosCliente.Id;
        eventToday2.AV_InOutbound__c = '001';
        eventToday2.DurationInMinutes = 60;
        eventToday2.ActivityDateTime = System.today();
        eventToInsertList.add(eventToday2);

        insert eventToInsertList;

		// OPORTUNIDADES EN LOS PROXIMOS 7 DIAS + HOY
        List<Opportunity> oppToInsertList = new List<Opportunity>();
        RecordType rtIniEmp = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT);
        Opportunity oppIniEmp1 = new Opportunity();
        oppIniEmp1.Name = 'PruebaOpp1';
        oppIniEmp1.RecordTypeId = rtIniEmp.Id;
        oppIniEmp1.CloseDate = System.today();
        oppIniEmp1.OwnerId = managerUser.Id;
        oppIniEmp1.StageName = CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA;
        oppIniEmp1.AV_Center__c = centroU;
        oppToInsertList.add(oppIniEmp1);

        RecordType rtalerCom = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ALERTAEMP_RT);
        Opportunity oppIniEmp2 = new Opportunity();
        oppIniEmp2.Name = 'PruebaOpp2';
        oppIniEmp2.RecordTypeId = rtalerCom.Id;
        oppIniEmp2.CloseDate = System.today();
        oppIniEmp2.OwnerId = managerUser.Id;
        oppIniEmp2.StageName = CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO;
        oppIniEmp2.AV_Center__c = centroU;
        oppToInsertList.add(oppIniEmp2);

        RecordType rtAccCom = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ACCIONEMP_RT);
        Opportunity oppIniEmp3 = new Opportunity();
        oppIniEmp3.Name = 'PruebaOpp3';
        oppIniEmp3.RecordTypeId = rtAccCom.Id;
        oppIniEmp3.CloseDate = System.today();
        oppIniEmp3.OwnerId = managerUser.Id;
        oppIniEmp3.StageName = CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA;
        oppIniEmp3.AV_Center__c = centroU;
        oppToInsertList.add(oppIniEmp3);

        RecordType rtSugEMP = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_SUGERENCIAEMP_RT);
        Opportunity oppIniEmp4 = new Opportunity();
        oppIniEmp4.Name = 'PruebaOpp4';
        oppIniEmp4.RecordTypeId = rtSugEMP.Id;
        oppIniEmp4.CloseDate = System.today();
        oppIniEmp4.OwnerId = managerUser.Id;
        oppIniEmp4.StageName = CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO;
        oppIniEmp4.AV_Center__c = centroU;
        oppToInsertList.add(oppIniEmp4);

        insert oppToInsertList;     
        Test.stopTest();  
        
        }
    }
    
    @isTest
	public static void getDataDonutChartTest() {
        
        User managerUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Test.startTest();
        AV_ConfiguracionGrafico__mdt priorManageClientsEMP = [SELECT Label, DeveloperName, AV_Data__c FROM AV_ConfiguracionGrafico__mdt WHERE DeveloperName = 'CIBE_PriorManageClientsEMP' LIMIT 1];
        AV_ConfiguracionGrafico__mdt pendingConversations = [SELECT Label, DeveloperName, AV_Data__c FROM AV_ConfiguracionGrafico__mdt WHERE DeveloperName = 'CIBE_PendingConversation' LIMIT 1];
        AV_ConfiguracionGrafico__mdt tasksNext7DaysEMP = [SELECT Label, DeveloperName, AV_Data__c FROM AV_ConfiguracionGrafico__mdt WHERE DeveloperName = 'CIBE_TareasProximos7Dias_EMP' LIMIT 1];
        AV_ConfiguracionGrafico__mdt taskAvisosEMP = [SELECT Label, DeveloperName, AV_Data__c FROM AV_ConfiguracionGrafico__mdt WHERE DeveloperName = 'CIBE_WarningsToManageEMP' LIMIT 1];
        AV_ConfiguracionGrafico__mdt eventosHoy = [SELECT Label, DeveloperName, AV_Data__c FROM AV_ConfiguracionGrafico__mdt WHERE DeveloperName = 'CIBE_TodaysAppointments' LIMIT 1];
        AV_ConfiguracionGrafico__mdt eventosProximos7Dias = [SELECT Label, DeveloperName, AV_Data__c FROM AV_ConfiguracionGrafico__mdt WHERE DeveloperName = 'CIBE_CitasProximos7Dias' LIMIT 1];
        AV_ConfiguracionGrafico__mdt oppProximos7Dias = [SELECT Label, DeveloperName, AV_Data__c FROM AV_ConfiguracionGrafico__mdt WHERE DeveloperName = 'CIBE_OpportunitiesNext7Days_EMP' LIMIT 1];
        
        
        System.runAs(managerUser){
            List<Opportunity> listOpp = [SELECT Id FROM Opportunity WHERE Owner.Id = :managerUser.Id];
            CIBE_MetricChart_Controller.ChartData chartClientsEMP = CIBE_MetricChart_Controller.getData(priorManageClientsEMP.DeveloperName);
            CIBE_MetricChart_Controller.ChartData chartConversations = CIBE_MetricChart_Controller.getData(pendingConversations.DeveloperName);
            CIBE_MetricChart_Controller.ChartData chartAppointmentsEMP = CIBE_MetricChart_Controller.getData(tasksNext7DaysEMP.DeveloperName);
            CIBE_MetricChart_Controller.ChartData chartAvisosEMP = CIBE_MetricChart_Controller.getData(taskAvisosEMP.DeveloperName);
            CIBE_MetricChart_Controller.ChartData chartEventosHoy = CIBE_MetricChart_Controller.getData(eventosHoy.DeveloperName);
            CIBE_MetricChart_Controller.ChartData chartEventosProximos7Dias = CIBE_MetricChart_Controller.getData(eventosProximos7Dias.DeveloperName);
            CIBE_MetricChart_Controller.ChartData chartOppProximos7Dias = CIBE_MetricChart_Controller.getData(oppProximos7Dias.DeveloperName);

            System.assertEquals(chartConversations.numRecords, 4);
            System.assertEquals(chartClientsEMP.numRecords, 4);
            System.assertEquals(chartAppointmentsEMP.numRecords, 1);
            System.assertEquals(chartAvisosEMP.numRecords, 1);
            //System.assertEquals(chartEventosProximos7Dias.numRecords, 2);
            System.assertEquals(chartOppProximos7Dias.numRecords, 4);
        }

        Test.stopTest();
    }
    
    // @isTest
	// public static void hasPermissionSetTest() {
        
    //     User managerUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
    //     CIBE_TestHelper.insertPermissionSet(managerUser.id, 'CIBE_ShowHomeV4');

    //     Test.startTest();
    //     Boolean haspermissionSet;
    //     System.RunAs(managerUser){
    //         haspermissionSet = CIBE_MetricChart_Controller.userHasPermissionSet();
    //     }

    //     System.assertEquals(haspermissionSet, true);
    //     Test.stopTest();

    // }

}