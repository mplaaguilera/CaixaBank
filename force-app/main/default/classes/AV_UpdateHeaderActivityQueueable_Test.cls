/**********************************************************************************************************************
Name:      AV_UpdateHeaderActivityQueueable_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase AV_UpdateHeaderActivityQueueable_Test
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION        USER_STORY                   AUTHOR              DATE            Description
1.0            Temas    					Jashanpreet         02/06/2021      Init version
1.1 		   US592987	                    Patricia Villacañas 31/05/2023	    Changed AV_Query to SOQL queries and modified to set run as
1.2            US592987		                Ángel Medina		30/05/2023		Changed AV_Query to SOQL queries

***********************************************************************************************************************/
@isTest
public with sharing class AV_UpdateHeaderActivityQueueable_Test {

    @TestSetup
	static void setup(){
        
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

        System.runAs(userGcf){
		AV_TestHelper.activateLogger();
        User us= AV_TestHelper.createUser('AV_Usuario_CaixaBank');
        Account acc=AV_TestHelper.createCustomer();
        DateTime activityTime= DateTime.now();
        Event ev=AV_TestHelper.createEvent(us, activityTime, acc);
        }
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
	}

    /**
	* Validate execute Queueable
	*/
    @isTest
    private static void validateExecuteQueueable() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

        Test.startTest();
        System.runAs(userGcf){
        Event ev = [SELECT Id, AV_Task__c FROM Event LIMIT 1];
        AV_HeaderCustomActivity__c cabeceraTarea = [SELECT Id, AV_UrlTeams__c FROM AV_HeaderCustomActivity__c WHERE Id = :ev.AV_Task__c LIMIT 1];
        AV_UpdateHeaderCustomActivityQueueable apc = new AV_UpdateHeaderCustomActivityQueueable(cabeceraTarea);
        System.enqueueJob(apc);
        Test.stopTest();
        System.assertNotEquals(null, cabeceraTarea);
        }
    }


}