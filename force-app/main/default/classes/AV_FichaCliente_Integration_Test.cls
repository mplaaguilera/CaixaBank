/**********************************************************************************************************************
Name:	  AV_FichaCliente_Integration_Test
Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Integración para información de PF
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Esperanza Conde	   	30/07/2020		Init version
2.0			Test Class	   Esperanza Conde		19/08/2020		Init version
3.0			Test Class	   Carolina Alonso		21/09/2020		Add test classes for new logic
4.0          QC            Oscar Moreno        12/06/2024       Delete UserInfo.geetUserId()

***********************************************************************************************************************/
@isTest
public with sharing class AV_FichaCliente_Integration_Test {
	
	@TestSetup
	static void setup(){
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true]; 

		AV_TestHelper.activateLogger();

		AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition WHERE DeveloperName = 'AV_CRM_Intouch' LIMIT 1];        
		UserAppInfo app = new UserAppInfo(AppDefinitionId = appDefinition.DurableId, UserId = usuarioGcf.Id, FormFactor = 'Small');
		insert app;
	}
	
	@isTest
	public static void testGetProducts() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true]; 

		String userId = '13550';
		String ownerType = 'N';
		String productType = 'S';
		String ticket = 'N0000000000000000070100281';
		String key = '1';
		String pageSize = '10';
		String customerType = Null;

		Test.startTest();		
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_PRODUCTS','OK'));
		AV_FichaCliente_Integration.ProductsResponse prodResponse;
		System.runAs(usuarioGcf){
			prodResponse = AV_FichaCliente_Integration.getProducts(userId,ownerType,productType,ticket,key,pageSize,customerType);		
		}
		Test.stopTest();
		System.assertEquals('200', prodResponse.statusCode);
	}

	@isTest
	public static void testGetProductsFail() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true]; 
		
		String userId = '13550';
		String ownerType = 'N';
		String productType = 'S';
		String ticket = 'N0000000000000000070100281';
		String key = '1';
		String pageSize = '10';
		String customerType = Null;

		Test.startTest();
		// Set mock callout class 
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_PRODUCTS','KO')); 
		// This causes a fake response to be sent
		// from the class that implements HttpCalloutMock. 
		AV_FichaCliente_Integration.ProductsResponse prodResponse;
		System.runAs(usuarioGcf){
			prodResponse = AV_FichaCliente_Integration.getProducts(userId,ownerType,productType,ticket,key,pageSize,customerType);
		}
		Test.stopTest();
		System.assertEquals('500', prodResponse.statusCode);
		
	}

	@isTest
	public static void testGetCommercialProductResponse() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true]; 
		
		Account acc = AV_TestHelper.createCustomer();
		
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
        prodCliente.AV_TenenciaProducto__c = '2';
        prodCliente.AV_Potencialidad__c = 'S';
		update prodCliente;

		Test.startTest();		
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_COMMERCIALPRODUCTS','OK'));
		AV_FichaCliente_Integration.CommercialProductsDataResponse prodResponse;
		System.runAs(usuarioGcf){
			prodResponse = AV_FichaCliente_Integration.getCommercialProductResponse(prodCliente.Id);		
		}
		Test.stopTest();
		System.assertEquals('200', prodResponse.data.statusCode);
	}

	@isTest
	public static void testGetDataCustomer() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true]; 
		
		String userId = '13550';

		Test.startTest();		
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_CUSTOMMERDATA','OK'));
		AV_FichaCliente_Integration.CustomerResponse customerResponse;
		System.runAs(usuarioGcf){
			customerResponse = AV_FichaCliente_Integration.getDataCustomer(userId);		
		}
		Test.stopTest();
		System.assertEquals('200', customerResponse.statusCode);
	}

	@isTest
	public static void testGetSignals() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true]; 
		
		String userId = '13550';

		Test.startTest();		
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_SIGNALDATA','OK'));
		AV_FichaCliente_Integration.SignalsResponse signalsResponse;
		System.runAs(usuarioGcf){
			signalsResponse = AV_FichaCliente_Integration.getSignals(userId);		
		}
		Test.stopTest();
		System.assertEquals('200', signalsResponse.statusCode);
	}

	@isTest
	public static void testGetWarnings() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true]; 
		
		String userId = '13550';

		Test.startTest();		
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_WARNINGDATA','OK'));
		AV_FichaCliente_Integration.WarningsResponse warningResponse;
		System.runAs(usuarioGcf){
			warningResponse = AV_FichaCliente_Integration.getWarnings(userId);		
		}
		Test.stopTest();
		System.assertEquals('200', warningResponse.statusCode);
	}

	@isTest
	public static void testGetCommercialProducts() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true]; 
		
		String userId = '13550';

		Test.startTest();		
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_CUSTOMMERPRODDATA','OK'));
		AV_FichaCliente_Integration.CommercialProductsResponse commercialProductResponse;
		System.runAs(usuarioGcf){
			commercialProductResponse = AV_FichaCliente_Integration.getCommercialProducts(userId);		
		}
		Test.stopTest();
		System.assertEquals('200', commercialProductResponse.statusCode);
	}
}