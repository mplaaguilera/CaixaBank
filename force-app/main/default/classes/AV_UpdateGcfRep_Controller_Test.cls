/**********************************************************************************************************************
Name:	  AV_UpdateGcfRep_Controller_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para dar cobertura a la clase AV_UpdateGcfRepresentative_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY	   AUTHOR		   		DATE			Description
    1.0		    US435107       Patricia Solano      29/08/2022		Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_UpdateGcfRep_Controller_Test {
    
    @TestSetup
    static void setup(){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_ENT_RT);
		Account acc = new Account(
				Name = 'Name',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '61334682',
                CC_NumPerso__c = '88888888',
				AV_Negocio__c = 'BPA',
            	CC_Numero_Documento__c = '9446386T'
			);
		insert acc;
    }

    @isTest
    public static void getRepresentativeDataTestRepresentanteJur() {
        Account acc = [SELECT AV_NumPerso__c, AV_FechaRefrescoApoderado__c, Id FROM Account];
        Test.startTest();
        Test.setMock(WebServiceMock.class, new AV_WS_Mock_Representantes_WSDL());
        String response = AV_UpdateGcfRepresentative_Controller.getRepresentativeData(acc.Id);
        Test.stopTest();
        System.assertEquals(response, 'OK');
    }

    @isTest
    public static void getRepresentativeDataTestTraza() {
        Account acc = [SELECT AV_NumPerso__c, AV_FechaRefrescoApoderado__c, Id FROM Account];
        Test.startTest();
        String response = AV_UpdateGcfRepresentative_Controller.getRepresentativeData(acc.Id);
        Test.stopTest();
        System.assertEquals(response, 'OK');
    }
  
    @isTest
    public static void getRepresentativeDataTestIdNull() {
        Account acc = [SELECT AV_NumPerso__c, AV_FechaRefrescoApoderado__c, Id FROM Account];
        acc.AV_NumPerso__c = '';
        Database.update(acc);
        Test.startTest();
        Test.setMock(WebServiceMock.class, new AV_WS_Mock_Representantes_WSDL());
        String response = AV_UpdateGcfRepresentative_Controller.getRepresentativeData(null);
        Test.stopTest();
        System.assertEquals(response, null);
    }

    @isTest
    public static void retrieveRepresentativeDataNumPersoNull() {
        Account acc = [SELECT AV_NumPerso__c, AV_FechaRefrescoApoderado__c, Id FROM Account];
        Test.startTest();
        Test.setMock(WebServiceMock.class, new AV_WS_Mock_Representantes_WSDL());
        String response = AV_UpdateGcfRepresentative_Controller.retrieveRepresentativeData(null, acc.AV_FechaRefrescoApoderado__c, acc.Id);
        Test.stopTest();
        System.assertEquals(response, null);
    }

}