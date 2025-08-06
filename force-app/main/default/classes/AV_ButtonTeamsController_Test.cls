/**********************************************************************************************************************
 Name:	  AV_ButtonTeamsController_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de AV_ButtonTeamsController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US202459 		    Sandra Gómez    	12/05/2021			Init version
    1.1		    AV_Query IT	        Daniel Rodríguez	01/03/2022	        Change AV_Query to SOQL for User, Account, Contact

***********************************************************************************************************************/
@isTest
public with sharing class AV_ButtonTeamsController_Test {
    @TestSetup
	static void setup(){
		AV_TestHelper.activateLogger();
        User us= AV_TestHelper.createUser('AV_Usuario_CaixaBank');
        Account acc=AV_TestHelper.createCustomer();
        DateTime activityTime= DateTime.now();
        Event ev=AV_TestHelper.createEvent(us, activityTime, acc);
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
	}

    /**
	* Validate getUrlTeams of Apex class AV_ButtonTeamsController
	*/
    @isTest
    private static void validateGetUrlTeams() {
        Test.startTest();
        Event ev = [Select Id, AV_Task__c From Event limit 1];
        //Event ev =(Event) new AV_Query('Event').selectFields('Id, AV_Task__c').setLimit(1).fetch();
        AV_HeaderCustomActivity__c cabeceraTarea  = [Select Id, AV_UrlTeams__c From AV_HeaderCustomActivity__c Where Id = :ev.AV_Task__c limit 1];
        /*AV_HeaderCustomActivity__c cabeceraTarea = (AV_HeaderCustomActivity__c)new AV_Query('AV_HeaderCustomActivity__c')
                    .selectFields('Id, AV_UrlTeams__c')
                    .addConditionEq('Id', ev.AV_Task__c)
                    .fetch();*/
        cabeceraTarea.AV_UrlTeams__c='https://www.google.com/';
        update cabeceraTarea;
        String resul=AV_ButtonTeamsController.getUrlTeams(ev.Id);
        Test.stopTest();
        System.assertNotEquals(null, resul);
    }
}