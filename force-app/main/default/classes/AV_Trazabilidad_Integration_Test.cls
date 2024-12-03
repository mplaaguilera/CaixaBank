/**********************************************************************************************************************
Name:	  AV_Trazabilidad_Integration_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la integración de la API de Trazabilidad
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY                                          AUTHOR              DATE			Description
    1.0         US414208                                            Patricia Solano     20/09/2022		Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_Trazabilidad_Integration_Test {

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
    public static void validateGetCustomerTrackings(){
        Account account = [SELECT Id, AV_NumPerso__c FROM Account LIMIT 1];
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('TRACEABILITY','OK')); 
        AV_Trazabilidad_Integration.CustomerResponse response = AV_Trazabilidad_Integration.getCustomerTrackings('A', Integer.valueOf(account.AV_NumPerso__c), '3'); 
        Test.stopTest();
        system.assertEquals('200', response.statusCode);
    }   
}