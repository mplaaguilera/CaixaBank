/**********************************************************************************************************************
 Name:	  AV_FichaProductosCController_Test
 Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Clase Test para AV_FichaProductosComponentController
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			Test				Carolina Alonso	   	09/03/2020		  	Init version
	1.1			Test				Carolina Alonso	   	12/05/2020		  	Update coverage
	1.2			Test				Carolina Alonso	   	20/05/2020		  	Update coverage; getOpportunityNumber and 
																			getClientName methods.
	1.3			Test				Esperanza Conde		29/07/2020			Modified test method about target and Preconcedido
	1.4			Test				Esperanza Conde		30/09/2020			Update coverage
	1.5			Fix					Sandra Gómez		26/08/2021			Fix product opportunity
	1.6			US276250			Víctor Santiago		15/10/2021			Added second call to getInitData because of
																			asynchronous update (future)
***********************************************************************************************************************/
@isTest
public with sharing class AV_FichaProductosCController_Test {
   
	@isTest
	public static void testAccountWithoutExperienceBusiness() {
		AV_TestHelper.activateLogger();
		Account acc = AV_TestHelper.createCustomer();

		Test.startTest();

		List<AV_FichaProductosComponentController.Response> responseList = new List<AV_FichaProductosComponentController.Response>();
		AV_FichaProductosComponentController.getInitData(acc.Id);
		Test.stopTest();

		//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
		responseList = AV_FichaProductosComponentController.getInitData(acc.Id);
		System.assertEquals(null, responseList);
	}
	
	@isTest
	public static void testAccountWithoutPFExperience() {
		AV_TestHelper.activateLogger();
		Account acc = AV_TestHelper.createCustomer();
		AV_ExperienceBusiness__c exp = AV_TestHelper.createExperienciaNegocio();

		Test.startTest();

		List<AV_FichaProductosComponentController.Response> responseList = new List<AV_FichaProductosComponentController.Response>();
		AV_FichaProductosComponentController.getInitData(acc.Id);
		Test.stopTest();

		//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
		responseList = AV_FichaProductosComponentController.getInitData(acc.Id);
		System.assertEquals(null, responseList);
	}

	@isTest
	public static void testAccountWithTenenciaPotencialidadAndOpp() {
		AV_TestHelper.activateLogger();
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
        prodCliente.AV_TenenciaProducto__c = '1';
        prodCliente.AV_Potencialidad__c = 'S';
		update prodCliente;
        
        String userId = '13550';
		String commercialProductId = producto.Id;


		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_CUSTOMMERPRODDATA','OK'));
		AV_FichaCliente_Integration.CommercialProductsResponse commercialProductResponse = AV_FichaCliente_Integration.getCommercialProducts(userId);		
		List<AV_FichaProductosComponentController.Response> responseList = new List<AV_FichaProductosComponentController.Response>();
        AV_FichaProductosComponentController.getInitData(acc.Id);
		Test.stopTest();
		
		//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
		responseList = AV_FichaProductosComponentController.getInitData(acc.Id);
		System.assertEquals(1, responseList.size());
	}
	
	@isTest
	public static void testAccountWithTargetAndpreconcedido() {
		AV_TestHelper.activateLogger();
		Account acc = AV_TestHelper.createCustomer();
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
		List<AV_FichaProductosComponentController.Response> responseList = new List<AV_FichaProductosComponentController.Response>();
        AV_FichaProductosComponentController.getInitData(acc.Id);
		Test.stopTest();

		//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
		responseList = AV_FichaProductosComponentController.getInitData(acc.Id);
		System.assertEquals(1, responseList.size());
	}
	
	@isTest
	public static void testGetOpportunityNumber() {
		AV_TestHelper.activateLogger();
		
		Account acc = AV_TestHelper.createCustomer();
		
        Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;
        
		Opportunity opp = AV_TestHelper.createOpportunity(acc);

		Test.startTest();
		Product2 prodPF= [SELECT Id FROM Product2 LIMIT 1];
		List<Opportunity> listOpp = new List<Opportunity>();
		listOpp = AV_FichaProductosComponentController.getOpportunityNumber((String)acc.Id, (String)prodPF.Id);
		System.assertEquals(1, listOpp.size());
		
		Test.stopTest();
	}

	@isTest
	public static void testGetClientName() {
		AV_TestHelper.activateLogger();
		
		Account acc = AV_TestHelper.createCustomer();
		
		String nameAcc = [SELECT Name FROM Account where ID =: acc.Id LIMIT 1].Name;
		
        Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;
        
		Opportunity opp = AV_TestHelper.createOpportunity(acc);

		Test.startTest();

		String clientName = '';
		clientName = AV_FichaProductosComponentController.getClientName((String)acc.Id);
		System.assertEquals(nameAcc, clientName);
		
		Test.stopTest();
	} 
    
    @isTest
	public static void testproducts() {
		AV_TestHelper.activateLogger();
		Account acc = AV_TestHelper.createCustomer();
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
        prodExp.AV_ExternalId__c = 'BPA001_50046';
		update prodExp;
		
		AV_ProductClient__c prodCliente = AV_TestHelper.createPFCliente();
        prodCliente.AV_ProductoFicha__c = prodExp.Id;
        prodCliente.AV_Cliente__c = acc.Id;
        prodCliente.AV_ImportePreconcedido__c = 123123.12;
        prodCliente.AV_Target__c = true;
        prodCliente.AV_ExternalId__c = '50046';
		update prodCliente;
		AV_FichaCliente_Integration.Products product = new AV_FichaCliente_Integration.Products();
        AV_FichaCliente_Integration.DataKeyValue proCode= new  AV_FichaCliente_Integration.DataKeyValue('50046','');
        product.productCode = proCode;
        AV_FichaCliente_Integration.DataKeyValue sta= new  AV_FichaCliente_Integration.DataKeyValue('BPA001','');
        product.state = sta;
        product.order = 2;
        product.preconceived = 2;
        product.isTarget = true;
        product.isPotential = true;
        AV_FichaCliente_Integration.DataKeyValue oppData= new  AV_FichaCliente_Integration.DataKeyValue(prodCliente.AV_ExternalId__c,'');
        product.oportunity = oppData;

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_CUSTOMMERPRODDATA','OK'));
		AV_FichaCliente_Integration.CommercialProductsResponse commercialProductResponse = AV_FichaCliente_Integration.getCommercialProducts(userId);		
		List<AV_FichaProductosComponentController.Response> responseList = new List<AV_FichaProductosComponentController.Response>();
        AV_FichaProductosComponentController.getInitData(acc.Id);
        List<AV_FichaCliente_Integration.Products> listproduct = new List<AV_FichaCliente_Integration.Products>();
        listproduct.add(product);
        Map<String, AV_FichaCliente_Integration.Products> mapExpPFCustomer = new Map<String, AV_FichaCliente_Integration.Products>();
        mapExpPFCustomer.put(prodCliente.AV_ExternalId__c, product);
        List<AV_ProductClient__c> listPFCustomerViaIntegration = new List<AV_ProductClient__c>();
		listPFCustomerViaIntegration.add(prodCliente);
		Map<String, AV_ProductExperience__c> mapExternalIdExperience = new Map<String, AV_ProductExperience__c>();
		mapExternalIdExperience = AV_FichaProductosComponentController.createMapExperience(acc.AV_NumPerso__c, mapExpPFCustomer.keySet());
        AV_FichaProductosComponentController.updatePF(acc.Id, acc.AV_NumPerso__c, mapExpPFCustomer, listPFCustomerViaIntegration, mapExternalIdExperience);
		Test.stopTest();

		//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
		responseList = AV_FichaProductosComponentController.getInitData(acc.Id);
		System.assertEquals(1, responseList.size());
	}

}