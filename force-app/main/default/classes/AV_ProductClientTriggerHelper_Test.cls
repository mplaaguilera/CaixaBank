/**********************************************************************************************************************
Name:	  AV_ProductClientTriggerHelper_Test
Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_ProductClientTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			US161442		Álvaro Lóepz		17/02/2021		Init version
1.1			FIX				Sandra Gómez		27/08/2021		Fix product opportunity
1.2		    AV_Query IT	    Daniel Rodríguez	07/02/2022	    Change AV_Query to SOQL for User and Account
1.3 		US592987	   	Laura Marrero		30/05/2023		Changed AV_Query to SOQL queries and Add runAs

***********************************************************************************************************************/
@isTest
public with sharing class AV_ProductClientTriggerHelper_Test {

	@TestSetup
	static void setup(){
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;
		List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
		CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
		listDummyWords.add(word);
		CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
		listDummyWords.add(word2);
		Database.insert(listDummyWords, false);
		User usrTest = AV_TestHelper.createUser('Standard User');
		Account accTest = AV_TestHelper.createCustomer();
		Account cenTest = AV_TestHelper.createCaixaCenter();
		Contact conTest = AV_TestHelper.createEmployee(cenTest, usrTest);
		Opportunity opp = AV_TestHelper.createOpportunityWithEmpleado(accTest, conTest);

		User usrTestApiOnly = AV_TestHelper.createUser('API Only');
		Contact conTest2 = AV_TestHelper.createEmployee(cenTest, usrTestApiOnly);
		conTest2.FirstName = 'Empleado2';
		Database.update(conTest2);
	}

	@isTest
	public static void fillClientProductTest() {
		User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		
		Test.startTest();
		System.runAs(userGcf){
			Account accTest = [Select Id From Account limit 1];
			Product2 prod = [Select Id From Product2 limit 1];
			AV_ProductExperience__c pe = AV_TestHelper.createPFExperience();
			pe.AV_ProductoFicha__c = prod.Id;
			
			Database.update(pe);
			AV_ProductClient__c pfc = new AV_ProductClient__c();
			RecordType rt = AV_AppUtilities.getRecordType('AV_ProductClient__c', 'AV_ProductoFichaCliente');
			pfc.RecordTypeId = rt.Id;
			pfc.AV_Activo__c = true;
			pfc.AV_TenenciaProducto__c = '1';
			pfc.AV_Potencialidad__c = 'S';
			pfc.AV_ProductoFicha__c = pe.Id;
			pfc.AV_Cliente__c = accTest.Id;
			Database.insert(pfc);
			}		
		Test.stopTest();

		Set<String> setOppFields = new Set<String>{'Id','Name', 'AV_PF__c', 'AV_ClientProduct__c'};
		Opportunity oppAfter = [SELECT Id, Name, AV_PF__c, AV_ClientProduct__c FROM Opportunity limit 1];
		AV_ProductClient__c pfcAfter = [SELECT Id FROM AV_ProductClient__c limit 1];
	
		System.assertEquals(pfcAfter.Id, oppAfter.AV_ClientProduct__c, 'El producto ficha cliente no se ha podido actualizar.');
	}
}