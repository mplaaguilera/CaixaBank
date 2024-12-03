/**********************************************************************************************************************
Name:      AV_HeaderCustomTriggerHelper_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase AV_HeaderCustomActivityTriggerHelper
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY		AUTHOR              DATE                Description
    1.0            Temas    		Jashanpreet         02/06/2021          Init version

***********************************************************************************************************************/
@isTest
public with sharing class AV_HeaderCustomTriggerHelper_Test {

    @TestSetup
	static void setup(){
		AV_TestHelper.activateLogger();
        User us= AV_TestHelper.createUser('AV_Usuario_CaixaBank');
        Contact empleado  = AV_TestHelper.createEmployee(null, us);
        empleado.CC_Matricula__c= '64735647654752343';
        update empleado;
        Account acc=AV_TestHelper.createCustomer();
        DateTime activityTime= DateTime.now();
        Event ev=AV_TestHelper.createEventVideocCall(us, activityTime, acc);
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_MOCNT', 'OK'));
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
	}

    /**
	* Validate Sync videoCall
	*/
    @isTest
    private static void validateSyncVideoCall() {
        Test.startTest();
        Event ev = [SELECT Id, AV_Task__C FROM Event LIMIT 1];
        AV_HeaderCustomActivity__c cabeceraTarea = [SELECT Id,AV_UrlTeams__c FROM AV_HeaderCustomActivity__c WHERE Id = :ev.AV_Task__C LIMIT 1];
        cabeceraTarea.AV_UrlTeams__c='https://www.google.com/';
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_MOCNT', 'OK'));
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        update cabeceraTarea;
        Test.stopTest();
        System.assertNotEquals(null, cabeceraTarea);
    }

}