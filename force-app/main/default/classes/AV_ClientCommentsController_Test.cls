/**********************************************************************************************************************
Name:	  AV_ClientCommentsController_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para dar cobertura a la clase AV_ClientCommentsController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Sandra Gómez	   	    18/01/2021		Init version
1.1			US147315	   Sandra Gómez			15/03/2021		change Account location
1.2		    AV_Query IT	   Daniel Rodríguez	    04/02/2022	    Change AV_Query to SOQL for User and Account
1.3         US673516       Elisabeth R.         02/10/2023      Changed setup method to add comment history record

***********************************************************************************************************************/
@isTest
public with sharing class AV_ClientCommentsController_Test {
	@TestSetup
	static void setup() {
        
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        
        System.runAs(userGcf){
            Date activityDate = Date.today();
            Account acc = AV_TestHelper.createCustomer();
            Event evento = AV_TestHelper.createEvent(userGcf, activityDate,acc);
            evento.description ='Prueba comentario 1';
            update evento;
            Task tarea = AV_TestHelper.createTarea(userGcf);
            tarea.description ='Prueba comentario 2';
            tarea.ActivityDate = Date.today();
            tarea.WhatId = acc.id;
            tarea.Status = 'Gestionada positiva';
            update tarea;
            
            Opportunity opp = AV_TestHelper.createOpportunity(acc);
            AV_CommentsHistory__c commHist = new AV_CommentsHistory__c();
			commHist.OwnerId = userGcf.Id;
			commHist.AV_ModificationDate__c = Date.today();
			commHist.AV_NewComment__c = opp.AV_Comentarios__c;
			commHist.AV_OpportunityStatus__c = opp.StageName;
			commHist.AV_AssignedEmployee__c = opp.AV_Gestor__c;
			commHist.AV_Opportunity__c = opp.Id;
			insert commHist;

            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        }

		
	}
	@isTest
	public static void validateGetClientComments() {
        
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		List<Account> acc = [Select Id From Account limit 1];
		System.runAs(userGcf){ 
            	Test.startTest();
                Map<String,List<AV_ClientCommentsController.CommentItem>> lista = AV_ClientCommentsController.getClientComments(acc[0].id, null);
                Test.stopTest();
            	System.assertNotEquals(lista,null);
        }
	}
}