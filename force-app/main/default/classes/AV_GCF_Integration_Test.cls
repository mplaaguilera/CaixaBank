/**********************************************************************************************************************
Name:	  AV_GCF_Integration_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para dar cobertura a la clase AV_GCF_Integration
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY	   AUTHOR		   		DATE			Description
    1.0		    US435107       Patricia Solano      29/08/2022		Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_GCF_Integration_Test {

    @TestSetup
    static void setup(){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_ENT_RT);
		Account acc = new Account(
				Name = 'Name',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '123',
				AV_Negocio__c = 'BPA',
            	CC_Numero_Documento__c = '9446386T'
			);
		insert acc;
    }

    @isTest
    public static void getDataALFWS_RepresentantesJuridicosApoderados(){
        Account acc = [SELECT AV_NumPerso__c, AV_FechaRefrescoApoderado__c, Id FROM Account LIMIT 1];
        Test.startTest();
        Test.setMock(WebServiceMock.class, new AV_WS_Mock_Representantes_WSDL());
        Map<String,Object> result = AV_GCF_Integration.getDataALFWS_RepresentantesJuridicos(acc.AV_NumPerso__c,''); 
        Test.stopTest();
        System.assertNotEquals(result, null);
    }   

    @isTest
    public static void getDataALFWS_RepresentantesJuridicosTraza(){
        Account acc = [SELECT AV_NumPerso__c, AV_FechaRefrescoApoderado__c, Id FROM Account LIMIT 1];
        Test.startTest();
        Map<String,Object> result = AV_GCF_Integration.getDataALFWS_RepresentantesJuridicos(acc.AV_NumPerso__c,''); 
        Test.stopTest();
        System.assertNotEquals(result, null);
    }   

}