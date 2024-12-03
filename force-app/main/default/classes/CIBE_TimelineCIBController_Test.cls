/**********************************************************************************************************************
Name:	  CIBE_TimelineCIBController_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para dar cobertura a la clase CIBE_TimelineCIBController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			US740191		Ali, Bea			20/02/2024		Init version
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_TimelineCIBController_Test {
	@TestSetup
	static void setup() {
        
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP, CIBE_AppConstants.USER_AV_AVOIDBULKAPI};
        
        CIBE_TestInitialSetup.setupInitialData(null, null, null, null, null, ps);

        User usuarioSA = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        User usuarioG = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        RecordType rtOppStage = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);

        System.runAs(usuarioSA){
            Date activityDate = Date.today();
            Account acc = CIBE_TestHelper.createCustomer();
            
            RecordType rtTask = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT);
            Task task  = new Task();
            task.Subject = 'PruebaTest';
            task.OwnerId = usuarioG.Id;
            task.Status = CIBE_AppConstants.GESTIONADO_POSITIVO_ESTADO;
            task.Priority = 'Normal';
            task.AV_ExternalID__c = 'U0000000';
            task.RecordTypeId = rtTask.Id;
            task.WhatId = acc.Id;
            task.Description = 'test';
            task.ActivityDate = activityDate;
            insert task;

            RecordType rtEvent = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
            Event evento = new Event();
            evento.Subject = 'PruebaTest';
            evento.WhatId = acc.Id;
            evento.AV_Tipo__c = 'VLD';
            evento.OwnerId = usuarioG.Id;
            
            String externalId = String.valueof((Math.random() * 10000000));
            AV_HeaderCustomActivity__c acthead = new AV_HeaderCustomActivity__c(
                AV_ExternalID__c = externalId,
                AV_ToDelete__c = true,
                OwnerId = usuarioG.Id
            );
            insert acthead;
            Datetime ahora = Datetime.now();
            String randomExternalId = String.valueof((Math.random() * 10000000));
            evento.AV_ExternalID__c = randomExternalId;
            evento.RecordTypeId = rtEvent.Id;
            evento.AV_Task__c=acthead.id;
            evento.ActivityDateTime = ahora;
            evento.StartDateTime = ahora;
            evento.DurationInMinutes= 60;
            DateTime endDateTime = ahora.addMinutes(60);
            evento.EndDateTime = endDateTime;
            evento.CSBD_Evento_Estado__c = CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
            evento.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
            evento.Description = 'Prueba';
            insert evento;

            Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
            Opportunity opp = new Opportunity();
            opp.OwnerId = usuarioG.Id;
            opp.AccountId = acc.Id;
            opp.Name = 'PruebaTest';
            opp.StageName = CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA;
            opp.RecordTypeId = rtOppStage.Id;
            opp.CloseDate = System.today();
            opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
            opp.AV_PF__c = prodPF.Id;
            insert opp;

            AV_CommentsHistory__c commHist = new AV_CommentsHistory__c();
			commHist.OwnerId = usuarioG.Id;
			commHist.AV_ModificationDate__c = Date.today();
			commHist.AV_NewComment__c = opp.AV_Comentarios__c;
			commHist.AV_AssignedEmployee__c = opp.AV_Gestor__c;
            commHist.AV_Opportunity__c = opp.Id;
			commHist.AV_NewComment__c = 'Nuevo comentario';
			insert commHist;
        }

		
	}
	@isTest
	public static void getClientComments_Test() {

        User usuarioG = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        String filterDate = '1970-02-20';
		List<Account> acc = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
		System.runAs(usuarioG){ 
            Test.startTest();
            Map<String,List<CIBE_TimelineCIBController.CommentItem>> lista0 = CIBE_TimelineCIBController.getClientComments(acc[0].id, null, false, false, false, true, filterDate);
            Map<String,List<CIBE_TimelineCIBController.CommentItem>> lista1 = CIBE_TimelineCIBController.getClientComments(acc[0].id, null, false, false, false, false, filterDate);
            Map<String,List<CIBE_TimelineCIBController.CommentItem>> lista2 = CIBE_TimelineCIBController.getClientComments(acc[0].id, null, true, false, false, false, filterDate);
            Map<String,List<CIBE_TimelineCIBController.CommentItem>> lista3 = CIBE_TimelineCIBController.getClientComments(acc[0].id, null, false, true, false, false, filterDate);
            Map<String,List<CIBE_TimelineCIBController.CommentItem>> lista4 = CIBE_TimelineCIBController.getClientComments(acc[0].id, null, false, false, true, false, filterDate);
            Map<String,List<CIBE_TimelineCIBController.CommentItem>> lista5 = CIBE_TimelineCIBController.getClientComments(acc[0].id, null, false, false, false, false, filterDate);
            Map<String,List<CIBE_TimelineCIBController.CommentItem>> listaF1= CIBE_TimelineCIBController.getClientComments(acc[0].id, 'PruebaTest', false, false, false, true, filterDate);
            Map<String,List<CIBE_TimelineCIBController.CommentItem>> listaF2 = CIBE_TimelineCIBController.getClientComments(acc[0].id, 'PruebaTest', true, false, false, false, filterDate);
            Map<String,List<CIBE_TimelineCIBController.CommentItem>> listaF3 = CIBE_TimelineCIBController.getClientComments(acc[0].id, 'PruebaTest', false, true, false, false, filterDate);
            Map<String,List<CIBE_TimelineCIBController.CommentItem>> listaF4 = CIBE_TimelineCIBController.getClientComments(acc[0].id, 'PruebaTest', false, false, true, false, filterDate);
            Map<String,List<CIBE_TimelineCIBController.CommentItem>> listaF5 = CIBE_TimelineCIBController.getClientComments(acc[0].id, 'PruebaTest', false, false, false, false, filterDate);
            
            System.assertNotEquals(lista1,null);
            System.assertNotEquals(listaF1,null);
            Test.stopTest();
        }
	}
}