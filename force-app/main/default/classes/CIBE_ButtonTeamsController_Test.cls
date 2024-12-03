/**********************************************************************************************************************
 Name:	  CIBE_ButtonTeamsController_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de CIBE_ButtonTeamsController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US202459 		    Jose Maria	    	07/02/2023			Init version (Copy test from retail)

***********************************************************************************************************************/
@isTest
public with sharing class CIBE_ButtonTeamsController_Test {
    
    @TestSetup
	static void setup(){
		CIBE_TestHelper.activateLogger();
        User us= CIBE_TestHelper.createUser('CIBE_Gestor');
        Account acc=CIBE_TestHelper.createCustomer();
        DateTime activityTime= DateTime.now();
        Event ev=CIBE_TestHelper.createEvent(us, activityTime, acc);
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
	}
    
    /**
	* Validate getUrlTeams of Apex class AV_ButtonTeamsController
	*/
    @isTest
    private static void validateGetUrlTeams() {
        Test.startTest();
       
        Event ev = [SELECT  Id, AV_Task__c FROM Event LIMIT 1];
	    AV_HeaderCustomActivity__c cabeceraTarea  = [SELECT Id, AV_UrlTeams__c FROM AV_HeaderCustomActivity__c WHERE Id = :ev.AV_Task__c LIMIT 1];

        cabeceraTarea.AV_UrlTeams__c='https://www.google.com/';
        update cabeceraTarea;
        String resul=CIBE_ButtonTeamsController.getUrlTeams(ev.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, resul);
        
    }
}