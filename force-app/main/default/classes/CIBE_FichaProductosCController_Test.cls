/**********************************************************************************************************************
 Name:      CIBE_FichaProductosCController_Test
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test class for CIBE_FichaProductosComponentController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION     USER_STORY				AUTHOR				DATE            Description
	1.0         US556905       		    Lucía Muñoz		    22/03/2023      Init version

***********************************************************************************************************************/
@IsTest
public with sharing class CIBE_FichaProductosCController_Test {

    @isTest
	public static void testAccountWithoutExperienceBusiness() {
		CIBE_TestHelper.activateLogger();
		
		Account acc = CIBE_TestHelper.createCustomer();

		System.runAs(new User(Id = UserInfo.getUserId())) {
		Test.startTest();		
		List<CIBE_FichaProductosComponentController.Response> responseList = new List<CIBE_FichaProductosComponentController.Response>();
		CIBE_FichaProductosComponentController.getInitData(acc.Id);
		Test.stopTest();

		//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
		responseList = CIBE_FichaProductosComponentController.getInitData(acc.Id);
		System.assertEquals(null, responseList);
		}
	}
	
	@isTest
	public static void testAccountWithoutPFExperience() {
		CIBE_TestHelper.activateLogger();
		Account acc = CIBE_TestHelper.createCustomer();
		AV_ExperienceBusiness__c exp = CIBE_TestHelper.createExperienciaNegocio();

		System.runAs(new User(Id = UserInfo.getUserId())) {
		Test.startTest();
		List<CIBE_FichaProductosComponentController.Response> responseList = new List<CIBE_FichaProductosComponentController.Response>();
		CIBE_FichaProductosComponentController.getInitData(acc.Id);
		Test.stopTest();

		//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
		responseList = CIBE_FichaProductosComponentController.getInitData(acc.Id);
		System.assertEquals(null, responseList);
		}

	}

	@isTest
	public static void testAccountWithTenenciaPotencialidadAndOpp() {

		CIBE_TestHelper.activateLogger();
		Account acc = CIBE_TestHelper.createCustomer2();
		
		AV_ExperienceBusiness__c exp = CIBE_TestHelper.createExperienciaNegocio();

		Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
		Product2 producto = CIBE_TestHelper.createProduct(prodPF,'20');
		producto.AV_Profesional__c = false;
		producto.AV_Activo__c = true;
		update producto;

		AV_ProductExperience__c prodExp = CIBE_TestHelper.createPFExperience();
		prodExp.AV_Activo__c = true;
		prodExp.AV_ProductoFicha__c = producto.Id; 
		prodExp.AV_ExperienciaNegocio__c = exp.Id;
        prodExp.AV_ExternalId__c = 'BPA001_50077';
		update prodExp;
		
		AV_ProductClient__c prodCliente = CIBE_TestHelper.createPFCliente();
        prodCliente.AV_ProductoFicha__c = prodExp.Id;
        prodCliente.AV_Cliente__c = acc.Id;
        prodCliente.AV_TieneOportunidad__c = 'OPORT';
        prodCliente.AV_TenenciaProducto__c = '1';
        prodCliente.AV_Potencialidad__c = 'S';
		update prodCliente;
        
        String userId = '13550';
		String commercialProductId = producto.Id;

		System.runAs(new User(Id = UserInfo.getUserId())) {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_CUSTOMMERPRODDATA','OK'));
		AV_FichaCliente_Integration.CommercialProductsResponse commercialProductResponse = AV_FichaCliente_Integration.getCommercialProducts(userId);		
		List<CIBE_FichaProductosComponentController.Response> responseList = new List<CIBE_FichaProductosComponentController.Response>();
        CIBE_FichaProductosComponentController.getInitData(acc.Id);
		Test.stopTest();
		
		//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
		responseList = CIBE_FichaProductosComponentController.getInitData(acc.Id);
		System.assertEquals(1, responseList.size());
		}
	}
	
	@isTest
	public static void testAccountWithTargetAndpreconcedido() {
		CIBE_TestHelper.activateLogger();

		
		Account acc = CIBE_TestHelper.createCustomer2();
		String userId = '13550';
		AV_ExperienceBusiness__c exp = CIBE_TestHelper.createExperienciaNegocio();

		Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
		Product2 producto = CIBE_TestHelper.createProduct(prodPF,'20');
		producto.AV_Profesional__c = false;
		producto.AV_Activo__c = true;
		update producto;

		AV_ProductExperience__c prodExp = CIBE_TestHelper.createPFExperience();
		prodExp.AV_Activo__c = true;
		prodExp.AV_ProductoFicha__c = producto.Id; 
		prodExp.AV_ExperienciaNegocio__c = exp.Id;
        prodExp.AV_ExternalId__c = 'BPA001_50077';
		
		update prodExp;
		
		AV_ProductClient__c prodCliente = CIBE_TestHelper.createPFCliente();
        prodCliente.AV_ProductoFicha__c = prodExp.Id;
        prodCliente.AV_Cliente__c = acc.Id;
        prodCliente.AV_ImportePreconcedido__c = 123123.12;
        prodCliente.AV_Target__c = true;
		prodCliente.AV_TieneOportunidad__c = 'OFERT';
		prodCliente.AV_TenenciaProducto__c = '1';
        prodCliente.AV_Potencialidad__c = 'S';
		update prodCliente;



		System.runAs(new User(Id = UserInfo.getUserId())){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_CUSTOMMERPRODDATA','OK'));
		AV_FichaCliente_Integration.CommercialProductsResponse commercialProductResponse = AV_FichaCliente_Integration.getCommercialProducts(userId);		
		List<CIBE_FichaProductosComponentController.Response> responseList = new List<CIBE_FichaProductosComponentController.Response>();
        CIBE_FichaProductosComponentController.getInitData(acc.Id);
		Test.stopTest();

		//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
		responseList = CIBE_FichaProductosComponentController.getInitData(acc.Id);
		System.assertEquals(1, responseList.size());
		}
	}
	
	@isTest
	public static void testGetOpportunityNumber() {

		CIBE_TestHelper.activateLogger();
		
		Account acc = CIBE_TestHelper.createCustomer();
		
        Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;
        
		Opportunity opp = CIBE_TestHelper.createOpportunity(acc);

		System.runAs(new User(Id = UserInfo.getUserId())) {
		Test.startTest();
		Product2 prodPF= [SELECT Id FROM Product2 LIMIT 1];
		List<Opportunity> listOpp = new List<Opportunity>();
		listOpp = CIBE_FichaProductosComponentController.getOpportunityNumber((String)acc.Id, (String)prodPF.Id);
		System.assertEquals(1, listOpp.size());
		
		Test.stopTest();
		}
	}

	@isTest
	public static void testGetClientName() {

		CIBE_TestHelper.activateLogger();
		
		Account acc = CIBE_TestHelper.createCustomer2();
		
		String nameAcc = [SELECT Name FROM Account where ID =: acc.Id LIMIT 1].Name;
		
        Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;
        
		Opportunity opp = CIBE_TestHelper.createOpportunity(acc);


		System.runAs(new User(Id = UserInfo.getUserId())) {
		Test.startTest();

		String clientName = '';
		clientName = CIBE_FichaProductosComponentController.getClientName((String)acc.Id);
		System.assertEquals(nameAcc, clientName);
		
		Test.stopTest();
		}
	} 
    
    @isTest
	public static void testproducts() {

		CIBE_TestHelper.activateLogger();
		Account acc = CIBE_TestHelper.createCustomer2();
		String userId = '13550';
		AV_ExperienceBusiness__c exp = CIBE_TestHelper.createExperienciaNegocio();

		Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
		Product2 producto = CIBE_TestHelper.createProduct(prodPF,'20');
		producto.AV_Profesional__c = false;
		producto.AV_Activo__c = true;
		update producto;

		AV_ProductExperience__c prodExp = CIBE_TestHelper.createPFExperience();
		prodExp.AV_Activo__c = true;
		prodExp.AV_ProductoFicha__c = producto.Id; 
		prodExp.AV_ExperienciaNegocio__c = exp.Id;
        prodExp.AV_ExternalId__c = 'BPA001_50046';
		update prodExp;
		
		AV_ProductClient__c prodCliente = CIBE_TestHelper.createPFCliente();
        prodCliente.AV_ProductoFicha__c = prodExp.Id;
        prodCliente.AV_Cliente__c = acc.Id;
        prodCliente.AV_ImportePreconcedido__c = 123123.12;
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


		System.runAs(new User(Id = UserInfo.getUserId())) {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_CUSTOMMERPRODDATA','OK'));
		AV_FichaCliente_Integration.CommercialProductsResponse commercialProductResponse = AV_FichaCliente_Integration.getCommercialProducts(userId);		
		List<CIBE_FichaProductosComponentController.Response> responseList = new List<CIBE_FichaProductosComponentController.Response>();
        CIBE_FichaProductosComponentController.getInitData(acc.Id);
        List<AV_FichaCliente_Integration.Products> listproduct = new List<AV_FichaCliente_Integration.Products>();
        listproduct.add(product);
        Map<String, AV_FichaCliente_Integration.Products> mapExpPFCustomer = new Map<String, AV_FichaCliente_Integration.Products>();
        mapExpPFCustomer.put(prodCliente.AV_ExternalId__c, product);
        List<AV_ProductClient__c> listPFCustomerViaIntegration = new List<AV_ProductClient__c>();
		listPFCustomerViaIntegration.add(prodCliente);
		Map<String, AV_ProductExperience__c> mapExternalIdExperience = new Map<String, AV_ProductExperience__c>();
		mapExternalIdExperience = CIBE_FichaProductosComponentController.createMapExperience(acc.AV_NumPerso__c, mapExpPFCustomer.keySet());
        CIBE_FichaProductosComponentController.updatePF(acc.Id, acc.AV_NumPerso__c, mapExpPFCustomer, listPFCustomerViaIntegration, mapExternalIdExperience);
		Test.stopTest();

		//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
		responseList = CIBE_FichaProductosComponentController.getInitData(acc.Id);
		System.assertEquals(1, responseList.size());
		}
	}



	@isTest
	public static void testInsertPF() {

		CIBE_TestHelper.activateLogger();
		Account acc = CIBE_TestHelper.createCustomer2();
		String userId = '13550';
		AV_ExperienceBusiness__c exp = CIBE_TestHelper.createExperienciaNegocio();

		Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
		Product2 producto = CIBE_TestHelper.createProduct(prodPF,'20');
		producto.AV_Profesional__c = false;
		producto.AV_Activo__c = true;
		update producto;

		AV_ProductExperience__c prodExp = CIBE_TestHelper.createPFExperience();
		prodExp.AV_Activo__c = true;
		prodExp.AV_ProductoFicha__c = producto.Id; 
		prodExp.AV_ExperienciaNegocio__c = exp.Id;
        prodExp.AV_ExternalId__c = 'BPA001_50046';
		update prodExp;
		
		AV_ProductClient__c prodCliente = CIBE_TestHelper.createPFCliente();
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


		System.runAs(new User(Id = UserInfo.getUserId())) {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_CUSTOMMERPRODDATA','OK'));
		AV_FichaCliente_Integration.CommercialProductsResponse commercialProductResponse = AV_FichaCliente_Integration.getCommercialProducts(userId);		
		List<CIBE_FichaProductosComponentController.Response> responseList = new List<CIBE_FichaProductosComponentController.Response>();
        CIBE_FichaProductosComponentController.getInitData(acc.Id);
        List<AV_FichaCliente_Integration.Products> listproduct = new List<AV_FichaCliente_Integration.Products>();
        listproduct.add(product);
        Map<String, AV_FichaCliente_Integration.Products> mapExpPFCustomer = new Map<String, AV_FichaCliente_Integration.Products>();
        mapExpPFCustomer.put(prodCliente.AV_ExternalId__c, product);
		Map<String, AV_ProductExperience__c> mapExternalIdExperience = new Map<String, AV_ProductExperience__c>();
		mapExternalIdExperience = CIBE_FichaProductosComponentController.createMapExperience(acc.AV_NumPerso__c, mapExpPFCustomer.keySet());
        CIBE_FichaProductosComponentController.insertPF(acc.Id, acc.AV_NumPerso__c, mapExpPFCustomer, mapExternalIdExperience);
		Test.stopTest();

		//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
		responseList = CIBE_FichaProductosComponentController.getInitData(acc.Id);
		System.assertEquals(1, responseList.size());
		}

	}


	@isTest
	public static void testInsertOrUpdatePFCustomer() {

		CIBE_TestHelper.activateLogger();
		Account acc = CIBE_TestHelper.createCustomer2();
		String userId = '13550';
		AV_ExperienceBusiness__c exp = CIBE_TestHelper.createExperienciaNegocio();

		Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
		Product2 producto = CIBE_TestHelper.createProduct(prodPF,'20');
		producto.AV_Profesional__c = false;
		producto.AV_Activo__c = true;
		update producto;

		AV_ProductExperience__c prodExp = CIBE_TestHelper.createPFExperience();
		prodExp.AV_Activo__c = true;
		prodExp.AV_ProductoFicha__c = producto.Id; 
		prodExp.AV_ExperienciaNegocio__c = exp.Id;
        prodExp.AV_ExternalId__c = 'BPA001_50046';
		update prodExp;
		
		AV_ProductClient__c prodCliente = CIBE_TestHelper.createPFCliente();
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


		System.runAs(new User(Id = UserInfo.getUserId())) {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_CUSTOMMERPRODDATA','OK'));
		AV_FichaCliente_Integration.CommercialProductsResponse commercialProductResponse = AV_FichaCliente_Integration.getCommercialProducts(userId);		
		List<CIBE_FichaProductosComponentController.Response> responseList = new List<CIBE_FichaProductosComponentController.Response>();
        CIBE_FichaProductosComponentController.getInitData(acc.Id);
        List<AV_FichaCliente_Integration.Products> listproduct = new List<AV_FichaCliente_Integration.Products>();
        listproduct.add(product);
        Map<String, List<AV_FichaCliente_Integration.Products>> mapExpPFCustomer = new Map<String, List<AV_FichaCliente_Integration.Products>>();
        mapExpPFCustomer.put(prodCliente.AV_ExternalId__c, listproduct);
        List<AV_ProductClient__c> listPFCustomerViaIntegration = new List<AV_ProductClient__c>();
		listPFCustomerViaIntegration.add(prodCliente);
		Map<String, AV_ProductExperience__c> mapExternalIdExperience = new Map<String, AV_ProductExperience__c>();
		mapExternalIdExperience = CIBE_FichaProductosComponentController.createMapExperience(acc.AV_NumPerso__c, mapExpPFCustomer.keySet());
        CIBE_FichaProductosComponentController.insertOrUpdatePFCustomer(acc.Id, acc.AV_NumPerso__c, mapExpPFCustomer);
		Test.stopTest();

		//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
		responseList = CIBE_FichaProductosComponentController.getInitData(acc.Id);
		System.assertEquals(1, responseList.size());
		}

	 }
	
    
}