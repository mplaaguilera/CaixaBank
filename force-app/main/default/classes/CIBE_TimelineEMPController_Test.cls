/**********************************************************************************************************************
Name:	  CIBE_TimelineEMPController_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para dar cobertura a la clase CIBE_TimelineEMPController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			US732988		Ali				04/12/2023		Init version
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_TimelineEMPController_Test {
	@TestSetup
	static void setup() {
        
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP, CIBE_AppConstants.USER_AV_AVOIDBULKAPI};
        
        CIBE_TestInitialSetup.setupInitialData(null, null, null, null, null, ps);

        User usuarioSA = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        User usuarioG = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        RecordType rtOppStage = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT);
        RecordType rtTask = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_EMP_RT);

        System.runAs(usuarioSA){

            DateTime activityDate = Date.today();
            Account acc = CIBE_TestHelper.createCustomer();

            Task tarea  = new Task();
            tarea.Subject = 'Llamada Saliente Test Tarea 1';
            tarea.OwnerId = usuarioG.Id; 
            tarea.Status = CIBE_AppConstants.GESTIONADO_POSITIVO_ESTADO;
            tarea.Priority = 'Normal';
            tarea.AV_ExternalID__c = 'U0000000';		
            tarea.RecordTypeId = rtTask.Id;
            tarea.WhatId = acc.Id;
            tarea.Description = 'test';
            tarea.ActivityDate = Date.today();

            Task tarea2  = new Task();
            tarea2.Subject = 'Llamada Saliente Test Tarea 2';
            tarea2.OwnerId = usuarioG.Id; 
            tarea2.Status = CIBE_AppConstants.TASK_STATUS_PENDIENTE;
            tarea2.Priority = 'Normal';
            tarea2.AV_ExternalID__c = 'U0000012';		
            tarea2.RecordTypeId = rtTask.Id;
            tarea2.WhatId = acc.Id;
            tarea2.Description = 'test01';
            tarea2.ActivityDate = System.today().addDays(5);

            List<Task> listTsk = new List<Task>{tarea2,tarea};
            insert listTsk;

            Test.startTest();

            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
            Event event = new Event();
            event.Subject = 'Call prueba test 11';
            event.WhatId = acc.Id;
            event.AV_Tipo__c = 'VLD';
            event.OwnerId = usuarioG.Id;
            
            
            String externalId = String.valueof((Math.random() * 10000000));
            AV_HeaderCustomActivity__c acthead = new AV_HeaderCustomActivity__c(
                AV_ExternalID__c = externalId,
                AV_ToDelete__c = true,
                OwnerId = usuarioG.Id
            );
            insert acthead;
            
            String randomExternalId = String.valueof((Math.random() * 10000000));
            event.AV_ExternalID__c = randomExternalId;
            event.RecordTypeId = rt.Id;
            event.DurationInMinutes= 60;
            event.AV_Task__c=acthead.id;
            event.ActivityDateTime = activityDate;
            event.StartDateTime = activityDate;
            event.EndDateTime = activityDate.addMinutes(60);
            event.CSBD_Evento_Estado__c = CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
            event.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
            event.Description = 'Prueba';
            insert event;
                    
            Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
            Opportunity opp = new Opportunity();
            opp.OwnerId = usuarioG.Id;
            opp.AccountId = acc.Id;
            opp.Name = 'Alerta test opp';
            opp.StageName = CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA;
            opp.RecordTypeId = rtOppStage.Id;
            opp.CloseDate = Date.today();
            opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
            opp.AV_PF__c = prodPF.Id;

            Opportunity opp1 = new Opportunity();
            opp1.OwnerId = usuarioG.Id;
            opp1.AccountId = acc.Id;
            opp1.Name = 'Alerta test opp1';
            opp1.StageName = CIBE_AppConstants.OPPORTUNITY_STATUS_CERRPOSI;
            opp1.RecordTypeId = rtOppStage.Id;
            opp1.CloseDate = Date.today();
            opp1.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial1';

            Opportunity opp2 = new Opportunity();
            opp2.OwnerId = usuarioG.Id;
            opp2.AccountId = acc.Id;
            opp2.Name = 'Alerta test opp2';
            opp2.StageName = CIBE_AppConstants.OPPORTUNITY_STATUS_CERRNEGA;
            opp2.RecordTypeId = rtOppStage.Id;
            opp2.CloseDate = Date.today();
            opp2.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial2';

            Opportunity opp3 = new Opportunity();
            opp3.OwnerId = usuarioG.Id;
            opp3.AccountId = acc.Id;
            opp3.Name = 'Alerta test opp3';
            opp3.StageName = CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL;
            opp3.RecordTypeId = rtOppStage.Id;
            opp3.CloseDate = Date.today();
            opp3.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial3';

            List<Opportunity> oppL = new List<Opportunity>{opp, opp1, opp2, opp3};
            insert oppL;

            Test.stopTest();
        }

		
	}
	@isTest
	public static void validateGetClientComments() {
        
        // User usuarioSA = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        User usuarioG = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
       
		List<Account> acc = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
		System.runAs(usuarioG){ 
            Test.startTest();
            List<Event> evnto = [SELECT Id, AV_Task__c, Subject FROM Event WHERE Subject = 'Call prueba test 11'];
            List<Opportunity> opp = [SELECT Id, AV_Gestor__c FROM Opportunity WHERE Name = 'Alerta test opp'];
            List<Task> tarea = [SELECT Id, AV_Task__c  FROM Task WHERE Subject = 'Llamada Saliente Test Tarea 1'];
            List<Task> tarea2 = [SELECT Id, AV_Task__c  FROM Task WHERE Subject = 'Llamada Saliente Test Tarea 2'];

            AV_CommentsHistory__c commHist = new AV_CommentsHistory__c();
			commHist.OwnerId = usuarioG.Id;
			commHist.AV_ModificationDate__c = Date.today();
			commHist.AV_AssignedEmployee__c = opp[0].AV_Gestor__c;
            commHist.AV_Opportunity__c = opp[0].Id;
			commHist.AV_NewComment__c = 'Nuevo comentario test a1';
            commHist.AV_Task__c = (String) tarea[0].AV_Task__c;
            commHist.AV_Event__c =  (String)evnto[0].AV_Task__c;
			insert commHist;

            AV_CommentsHistory__c commHist2 = new AV_CommentsHistory__c();
			commHist2.OwnerId = usuarioG.Id;
			commHist2.AV_ModificationDate__c = Date.today();
			commHist2.AV_AssignedEmployee__c = opp[0].AV_Gestor__c;
            commHist2.AV_Opportunity__c = opp[0].Id;
			commHist2.AV_NewComment__c = 'Nuevo comentario test a1';
            commHist2.AV_Task__c = (String) tarea2[0].AV_Task__c;
			insert commHist2;
            
            Map<String,List<CIBE_TimelineEMPController.CommentItem>> lista0 = CIBE_TimelineEMPController.getClientComments(acc[0].id, null, false, false, false, false, true);
            Map<String,List<CIBE_TimelineEMPController.CommentItem>> lista1 = CIBE_TimelineEMPController.getClientComments(acc[0].id, null, false, false, false, false, false);
            Map<String,List<CIBE_TimelineEMPController.CommentItem>> lista2 = CIBE_TimelineEMPController.getClientComments(acc[0].id, null, true, false, false, false, false);
            Map<String,List<CIBE_TimelineEMPController.CommentItem>> lista3 = CIBE_TimelineEMPController.getClientComments(acc[0].id, null, false, true, false, false, false);
            Map<String,List<CIBE_TimelineEMPController.CommentItem>> lista4 = CIBE_TimelineEMPController.getClientComments(acc[0].id, null, false, false, true, false, false);
            Map<String,List<CIBE_TimelineEMPController.CommentItem>> lista5 = CIBE_TimelineEMPController.getClientComments(acc[0].id, null, false, false, false, true, false);
            Map<String,List<CIBE_TimelineEMPController.CommentItem>> listaF1= CIBE_TimelineEMPController.getClientComments(acc[0].id, 'Prueba', false, false, false, false, true);
            Map<String,List<CIBE_TimelineEMPController.CommentItem>> listaF2 = CIBE_TimelineEMPController.getClientComments(acc[0].id, 'Prueba', true, false, false, false, false);
            Map<String,List<CIBE_TimelineEMPController.CommentItem>> listaF3 = CIBE_TimelineEMPController.getClientComments(acc[0].id, 'Prueba', false, true, false, false, false);
            Map<String,List<CIBE_TimelineEMPController.CommentItem>> listaF4 = CIBE_TimelineEMPController.getClientComments(acc[0].id, 'Prueba', false, false, true, false, false);
            Map<String,List<CIBE_TimelineEMPController.CommentItem>> listaF5 = CIBE_TimelineEMPController.getClientComments(acc[0].id, 'Prueba', false, false, false, true, false);
            
            Map<String,List<CIBE_TimelineEMPController.CommentItem>> lista6 = CIBE_TimelineEMPController.getClientComments(acc[0].id, null, true, true, false, false, true);
            Test.stopTest();
            System.assertNotEquals(lista1,null);
            System.assertNotEquals(lista6,null);
        }
	}
}