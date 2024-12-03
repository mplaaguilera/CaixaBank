/**********************************************************************************************************************
Name:	  AV_Trazabilidad_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase AV_Trazabilidad_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY                                          AUTHOR              DATE			Description
    1.0         US384281                                            Patricia Solano     21/09/2022		Init version
    1.1         US481744                                            Patricia Solano     14/11/2022		Added test method 
                                                                                                        retrieveCustomerTrackingsNull                                                                                                      
***********************************************************************************************************************/
@isTest
public with sharing class AV_Trazabilidad_Controller_Test {

    @TestSetup
    static void setup(){
        AV_TestHelper.activateLogger();
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
		Account account = new Account(
				FirstName = 'FirstName',
				LastName = 'LastName',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '123',
				AV_Negocio__c = 'BPA',
            	CC_Numero_Documento__c = '9446386T'
			);
		insert account;
    }

    @isTest
    public static void retrieveCustomerTrackingsOk() {
        Account account = [SELECT Id, AV_NumPerso__c FROM Account];
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('TRACEABILITY', 'OK'));       
        AV_Trazabilidad_Controller.ResponseResult response = AV_Trazabilidad_Controller.retrieveCustomerTrackings('A', account.Id, '1');
        Test.stopTest();
        system.assertNotEquals(null, response);
    }

    @isTest
    public static void retrieveCustomerTrackingsNull() {
        Account account = [SELECT Id, AV_NumPerso__c FROM Account];
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('TRACEABILITY', 'OK'));       
        AV_Trazabilidad_Controller.ResponseResult response = AV_Trazabilidad_Controller.retrieveCustomerTrackings('A', account.Id, null);
        Test.stopTest();
        system.assertNotEquals(null, response);
    }
}