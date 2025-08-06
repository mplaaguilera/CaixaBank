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
	1.7			Fix PMD Errors		Daniel Rodriguez	27/10/2023	    	Add runAss, improve coverage, add methods  testInsertPF, testInsertOrUpdatePFCustomer
***********************************************************************************************************************/
@isTest
public with sharing class AV_FichaProductosCController_Test {

	@TestSetup
    static void setup(){
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        User userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
        

        AV_TestHelper.insertNeededPermissions(userGestor);
		Account acc;
		Contact cnt;
        	System.runAs(usuCli) {
                cnt = AV_TestHelper.createEmployee(AV_TestHelper.createCaixaCenter(),userGestor,userGestor.AV_ExternalID__c);
				acc = AV_TestHelper.createCustomer();
                
           }
        System.runAs(userGcf){
            		AppDefinition appDefinition = [SELECT Id,DurableId, Label FROM AppDefinition WHERE DeveloperName = 'AV_CRM_Intouch' LIMIT 1];        
					UserAppInfo app = new UserAppInfo(AppDefinitionId = appDefinition.DurableId, UserId = userGcf.Id, FormFactor = 'Small');
					insert app;	
					AV_ExperienceBusiness__c exp = AV_TestHelper.createExperienciaNegocioSinInsert();
					exp.AV_ExternalID__c = 'BPA004';
					exp.AV_Negocio__c = 'BPA';
					insert exp;
					Product2 prodPF = AV_TestHelper.createProduct(null,null);
					Product2 producto = AV_TestHelper.createProductSinInsert(prodPF,'20',null);
					producto.AV_Profesional__c = false;
					producto.AV_Activo__c = true;
					insert producto;
		
					AV_ProductExperience__c prodExp = AV_TestHelper.createPFExperienceSinInsert();
					prodExp.AV_Activo__c = true;
					prodExp.AV_ProductoFicha__c = producto.Id; 
					prodExp.AV_ExperienciaNegocio__c = exp.Id;
					prodExp.AV_ExternalId__c = 'BPA004_50077';
					// prodExp.AV_Negocio__c = 'BPA';
					insert prodExp;
					
					AV_ProductClient__c prodCliente = AV_TestHelper.createPFClienteSinInsert();
					prodCliente.AV_ProductoFicha__c = prodExp.Id;
					prodCliente.AV_Cliente__c = acc.Id;
					prodCliente.AV_ImportePreconcedido__c = 123123.12;
					prodCliente.AV_Target__c = true;
					prodCliente.AV_ExternalID__c = '50046';
					prodCliente.AV_Activo__c = true;
					insert prodCliente;
					Opportunity opp = AV_TestHelper.createOpportunityWithProduct(acc,cnt,prodPF,null,null,null);


        }
        AV_FichaProductosComponentController.MyBox a = new AV_FichaProductosComponentController.MyBox('','','');
        
	
    }



   
	@isTest
	public static void testAccountWithoutExperienceBusiness() {
		AV_TestHelper.activateLogger();
        

		Account acc = [select id from account where AV_NumPerso__c = '123' limit 1]; 
		User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];	
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];

		List<AV_FichaProductosComponentController.Response> responseList = new List<AV_FichaProductosComponentController.Response>();
        System.runAs(userGcf){
			Test.startTest();
			// AV_ExperienceBusiness__c exp = AV_TestHelper.createExperienciaNegocio();
			AV_FichaProductosComponentController.getInitData(acc.Id);
			Test.stopTest();

			//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
			responseList = AV_FichaProductosComponentController.getInitData(acc.Id);
		}
		System.assert(!responseList.isEmpty());
	}
	
	@isTest
	public static void testAccountWithoutPFExperience() {
		AV_TestHelper.activateLogger();
		Account acc = [select id from account where AV_NumPerso__c = '123' limit 1]; 
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_MOCNT','OK'));
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];

		User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];	
		List<AV_FichaProductosComponentController.Response> responseList = new List<AV_FichaProductosComponentController.Response>();
        System.runAs(userGcf){
            Test.startTest();


			AV_FichaProductosComponentController.getInitData(acc.Id);
			Test.stopTest();

			//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
			responseList = AV_FichaProductosComponentController.getInitData(acc.Id);
		}
		System.assert(!responseList.isEmpty());
	}

	@isTest
	public static void testAccountWithTenenciaPotencialidadAndOpp() {
		AV_TestHelper.activateLogger();
		Account acc = [select id from account where AV_NumPerso__c = '123' limit 1]; 
		User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];	
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];

		List<AV_FichaProductosComponentController.Response> responseList = new List<AV_FichaProductosComponentController.Response>();
        System.runAs(userGcf){
	
			Product2 producto = [select Id FROM Product2 where AV_NombrePF__r.AV_NombrePF__c = null and AV_NombrePF__r.AV_ExternalID__c = null ];

			
			String userId = '13550';
			String commercialProductId = producto.Id;
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_CUSTOMMERPRODDATA','OK'));
			AV_FichaCliente_Integration.CommercialProductsResponse commercialProductResponse = AV_FichaCliente_Integration.getCommercialProducts(userId);	
			responseList = AV_FichaProductosComponentController.getInitData(acc.Id);
			Test.stopTest();
			
			//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
			// responseList = AV_FichaProductosComponentController.getInitData(acc.Id);
		}
		System.assert(responseList != null);
	}
	
	@isTest
	public static void testAccountWithTargetAndpreconcedido() {
		AV_TestHelper.activateLogger();
		Account acc = [select id from account where AV_NumPerso__c = '123' limit 1]; 
		User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];

		List<AV_FichaProductosComponentController.Response> responseList = new List<AV_FichaProductosComponentController.Response>();
		System.runAs(userGcf){
			String userId = '13550';
		


			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_CUSTOMMERPRODDATA','OK'));
			AV_FichaCliente_Integration.CommercialProductsResponse commercialProductResponse = AV_FichaCliente_Integration.getCommercialProducts(userId);		
			AV_FichaProductosComponentController.getInitData(acc.Id);
			responseList = AV_FichaProductosComponentController.getInitData(acc.Id);
			Test.stopTest();

			//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
			// responseList = AV_FichaProductosComponentController.getInitData(acc.Id);
			System.assert(responseList != null);
			// System.assert(responseList != null);
		}
	}
	
	@isTest
	public static void testGetOpportunityNumber() {
		AV_TestHelper.activateLogger();
		Account acc = [select id from account where AV_NumPerso__c = '123' limit 1]; 
		User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];	
		List<Opportunity> listOpp = new List<Opportunity>();
		System.runAs(usuCli){
			Test.startTest();
			Opportunity opp = [SELECT AccountId,AV_PF__C From opportunity where accountId = :acc.id];
			Pricebook2 pb = new Pricebook2();
			pb.Name = 'Standard Price Book';
			insert pb;
			Product2 prodPF= [SELECT Id FROM Product2 LIMIT 1];
			Opportunity opp2 = [Select id from Opportunity where accountId = : opp.accountId and av_pf__c = : opp.av_pf__c];
			listOpp = AV_FichaProductosComponentController.getOpportunityNumber(opp.accountId, opp.av_pf__c);
			Test.stopTest();
		}
		System.assertEquals(1, listOpp.size(),'KO');
	}

	@isTest
	public static void testGetClientName() {
		AV_TestHelper.activateLogger();
		
		Account acc = [select id from account where AV_NumPerso__c = '123' limit 1]; 
		User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];

		String nameAcc = '';
		String clientName = '';
		System.runAs(userGcf){
			nameAcc = [SELECT Name FROM Account where ID =: acc.Id LIMIT 1].Name;
			
			Pricebook2 pb = new Pricebook2();
			pb.Name = 'Standard Price Book';
			insert pb;
			
			Opportunity opp = [SELECT AccountId,AV_PF__C From opportunity where accountId = :acc.Id];
			Test.startTest();
			clientName = AV_FichaProductosComponentController.getClientName((String)acc.Id);
			Test.stopTest();
		}
			System.assertEquals(nameAcc, clientName, 'KO');
	} 
    
    @isTest
	public static void testproducts() {
		AV_TestHelper.activateLogger();
		Account acc = [select id,AV_NumPerso__c from account where AV_NumPerso__c = '123' limit 1]; 
		User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];	
                User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];

		List<AV_FichaProductosComponentController.Response> responseList = new List<AV_FichaProductosComponentController.Response>();
		System.runAs(userGcf){

			String userId = '13550';
	
			AV_ProductClient__c prodCliente = [SELECT AV_ExternalID__c from AV_ProductClient__c where AV_ExternalID__c = '50046'];
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
		}
		System.assert(responseList != null);
	}

	

	 @isTest
	public static void testInsertPF() {

		AV_TestHelper.activateLogger();
		Account acc = [select id,AV_NumPerso__c from account where AV_NumPerso__c = '123' limit 1]; 
		User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];	
		List<AV_FichaProductosComponentController.Response> responseList = new List<AV_FichaProductosComponentController.Response>();
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];

		System.runAs(userGcf) {
			String userId = '13550';

			AV_ProductClient__c prodCliente = [SELECT AV_ExternalID__c FROM AV_ProductClient__c WHERE AV_ExternalID__c = '50046'];
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
			AV_FichaProductosComponentController.getInitData(acc.Id);
			List<AV_FichaCliente_Integration.Products> listproduct = new List<AV_FichaCliente_Integration.Products>();
			listproduct.add(product);
			Map<String, AV_FichaCliente_Integration.Products> mapExpPFCustomer = new Map<String, AV_FichaCliente_Integration.Products>();
			mapExpPFCustomer.put(prodCliente.AV_ExternalId__c, product);
			Map<String, AV_ProductExperience__c> mapExternalIdExperience = new Map<String, AV_ProductExperience__c>();
			mapExternalIdExperience = AV_FichaProductosComponentController.createMapExperience(acc.AV_NumPerso__c, mapExpPFCustomer.keySet());
			AV_FichaProductosComponentController.insertPF(acc.Id, acc.AV_NumPerso__c, mapExpPFCustomer, mapExternalIdExperience);
			Test.stopTest();

			//Second call to getInitData is mandatory for retrieving the data that a future method updated to the database in the first call.
			responseList = AV_FichaProductosComponentController.getInitData(acc.Id);
			
		}
		System.assert(responseList != null);

	}

}