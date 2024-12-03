/**********************************************************************************************************************
 Name:	  AV_FichaProductosControllerPS_Test
 Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Clase Test para AV_FichaProductosComponentController_PS
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			Test				Elisabeth R	   	    15/12/2023		  	Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_FichaProductosControllerPS_Test {

	@TestSetup
    static void setup(){
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        User userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
        AV_TestHelper.insertNeededPermissions(userGestor);
        	System.runAs(usuCli) {
				Account acc = AV_TestHelper.createCustomer();
           }
    }

   
	@isTest
	public static void testAccountWithoutExperienceBusiness() {
		AV_TestHelper.activateLogger();
		Account acc = [select id from account limit 1]; 
		User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];	
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];

		List<AV_FichaProductosComponentController_PS.Response> responseList = new List<AV_FichaProductosComponentController_PS.Response>();
        System.runAs(userGcf){
			Test.startTest();
			AV_ExperienceBusiness__c exp = AV_TestHelper.createExperienciaNegocio();
			AV_FichaProductosComponentController_PS.getInitData(acc.Id);
			Test.stopTest();

			//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
			responseList = AV_FichaProductosComponentController_PS.getInitData(acc.Id);
		}
		System.assertEquals(null, responseList, 'KO');
	}
	
	@isTest
	public static void testAccountWithoutPFExperience() {
		AV_TestHelper.activateLogger();
		Account acc = [select id from account limit 1]; 
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];

		User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];	
		List<AV_FichaProductosComponentController_PS.Response> responseList = new List<AV_FichaProductosComponentController_PS.Response>();
        System.runAs(userGcf){

			Test.startTest();
			AV_FichaProductosComponentController_PS.getInitData(acc.Id);
			Test.stopTest();

			//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
			responseList = AV_FichaProductosComponentController_PS.getInitData(acc.Id);
		}
		System.assertEquals(null, responseList, 'KO');
	}

	@isTest
	public static void testAccountWithTenenciaPotencialidadAndOpp() {
		AV_TestHelper.activateLogger();
		Account acc = [select id from account limit 1]; 
		User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];	
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];

		List<AV_FichaProductosComponentController_PS.Response> responseList = new List<AV_FichaProductosComponentController_PS.Response>();
        System.runAs(userGcf){
			AV_ExperienceBusiness__c exp = AV_TestHelper.createExperienciaNegocio();

			Product2 prodPF = AV_TestHelper.createProduct(null,null);
			Product2 producto = AV_TestHelper.createProduct(prodPF,'20');
			producto.AV_Profesional__c = false;
			producto.AV_Activo__c = true;
			update producto;

			AV_ProductExperience__c prodExp = AV_TestHelper.createPFExperience();
			prodExp.AV_Activo__c = true;
			prodExp.AV_ProductoFicha__c = producto.Id; 
			prodExp.AV_ExperienciaNegocio__c = exp.Id;
			prodExp.AV_ExternalId__c = 'BPA001_50077';
			update prodExp;
			
			AV_ProductClient__c prodCliente = AV_TestHelper.createPFCliente();
			prodCliente.AV_ProductoFicha__c = prodExp.Id;
			prodCliente.AV_Cliente__c = acc.Id;
			prodCliente.AV_TieneOportunidad__c = 'OPORT';
			prodCliente.AV_TenenciaProducto__c = '1';
			prodCliente.AV_Potencialidad__c = 'S';
			update prodCliente;
			
			String userId = '13550';
			String commercialProductId = producto.Id;
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_CUSTOMMERPRODDATA','OK'));
			AV_FichaCliente_Integration.CommercialProductsResponse commercialProductResponse = AV_FichaCliente_Integration.getCommercialProducts(userId);		
			AV_FichaProductosComponentController_PS.getInitData(acc.Id);
			Test.stopTest();
			
			//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
			responseList = AV_FichaProductosComponentController_PS.getInitData(acc.Id);
		}
		System.assertEquals(1, responseList.size(), 'KO');
	}
	
	@isTest
	public static void testAccountWithTargetAndpreconcedido() {
		AV_TestHelper.activateLogger();
		Account acc = [select id from account limit 1]; 
		User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];

		List<AV_FichaProductosComponentController_PS.Response> responseList = new List<AV_FichaProductosComponentController_PS.Response>();
		System.runAs(userGcf){
			String userId = '13550';
			AV_ExperienceBusiness__c exp = AV_TestHelper.createExperienciaNegocio();

			Product2 prodPF = AV_TestHelper.createProduct(null,null);
			Product2 producto = AV_TestHelper.createProduct(prodPF,'20');
			producto.AV_Profesional__c = false;
			producto.AV_Activo__c = true;
			update producto;

			AV_ProductExperience__c prodExp = AV_TestHelper.createPFExperience();
			prodExp.AV_Activo__c = true;
			prodExp.AV_ProductoFicha__c = producto.Id; 
			prodExp.AV_ExperienciaNegocio__c = exp.Id;
			prodExp.AV_ExternalId__c = 'BPA001_50077';
			update prodExp;
			
			AV_ProductClient__c prodCliente = AV_TestHelper.createPFCliente();
			prodCliente.AV_ProductoFicha__c = prodExp.Id;
			prodCliente.AV_Cliente__c = acc.Id;
			prodCliente.AV_ImportePreconcedido__c = 123123.12;
			prodCliente.AV_Target__c = true;
			update prodCliente;


			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_CUSTOMMERPRODDATA','OK'));
			AV_FichaCliente_Integration.CommercialProductsResponse commercialProductResponse = AV_FichaCliente_Integration.getCommercialProducts(userId);		
			AV_FichaProductosComponentController_PS.getInitData(acc.Id);
			Test.stopTest();

			//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
			responseList = AV_FichaProductosComponentController_PS.getInitData(acc.Id);
		}
		System.assertEquals(1, responseList.size(), 'KO');
	}

}