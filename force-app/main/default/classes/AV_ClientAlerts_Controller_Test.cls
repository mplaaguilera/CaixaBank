/**********************************************************************************************************************
Name:	  AV_ClientAlerts_Controller_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para dar cobertura a la clase AV_ClientAlerts_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Álvaro López	   	   29/09/2020		Init version
1.1			Fix			   Sandra Gómez		   20/04/2022		Fix Date Refresh
***********************************************************************************************************************/
@isTest
public with sharing class AV_ClientAlerts_Controller_Test {

    @isTest
    private static void retrieveAlertsTest(){
        String userId = '13550';

		Test.startTest();		
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_WARNINGDATA','OK'));
        String expectedJson = '[{"value":"Contrato marco","key":"17"},{"value":"Cliente con reclamaciones históricas","key":"25"},{"value":"Información de seguimiento","key":"11"},{"value":"Cobros pendientes","key":"4"},{"value":"Cliente con alertas de seguimiento","key":"10"}]';
		String jsonResponse = AV_ClientAlerts_Controller.retrieveAlerts(userId, null, null);		
		Test.stopTest();
		System.assertEquals(expectedJson, jsonResponse);
    }

    @isTest
    private static void retrieveAlertsUpdatedTest(){
        String userId = '13550';

        Test.startTest();	
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_WARNINGDATA','OK'));	
        String currentJson = '[{"value":"Contrato marco","key":"17"},{"value":"Cliente con reclamaciones históricas","key":"25"},{"value":"Información de seguimiento","key":"11"},{"value":"Cobros pendientes","key":"4"},{"value":"Cliente con alertas de seguimiento","key":"10"}]';
        String response = AV_ClientAlerts_Controller.retrieveAlerts(userId, System.now(), currentJson);
        Test.stopTest();
		System.assertEquals('UPDATED', response);
    }

    @isTest
    private static void retrieveAlertsNullUserIDTest(){
        String userId = '13550';

        Test.startTest();	
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_WARNINGDATA','OK'));
        String response = AV_ClientAlerts_Controller.retrieveAlerts(null, null, null);
        Test.stopTest();
		System.assertEquals('ERROR', response);
    }
}