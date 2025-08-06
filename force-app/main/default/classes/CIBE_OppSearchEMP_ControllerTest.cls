/**********************************************************************************************************************
@description
Name:	  CIBE_OppSearchEMP_ControllerTest
Copyright © 2024  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Test class to LWC CIBE_OppSearchEMP
------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	        AUTHOR		   		DATE				Description
1.0			US807175		    Lucia       	    07/03/2024		    Init version
***********************************************************************************************************************/



@IsTest
public with sharing class CIBE_OppSearchEMP_ControllerTest {

    @TestSetup
    static void makeData(){
        Test.startTest();

        CIBE_TestInitialSetup.setupInitialDataEMP();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        RecordType rtOpp = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT);
        RecordType rt = CIBE_AppUtilities.getRecordType('AV_ProductClient__c', 'AV_ProductoFichaCliente');

        List<Profile> result = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema'  LIMIT 1];
        User u1 = new User(
            Alias = 'u1',
            Email = 'test@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '00615',
            ProfileId = result[0].Id,
            UserName = 'testu2@test.dev',
            AV_ExternalID__c = 'U0009102',
            IsActive = true,
            AV_Funcion__c = 'DAN'
        );
        insert u1;
        Test.stopTest();

        System.runAs(usuario) {
            Account acc = CIBE_TestHelper.createCustomerSinInsert();
            Account acc2 = CIBE_TestHelper.createCustomerSinInsert();
            Account acc3 = CIBE_TestHelper.createAccountGC();
            acc2.Name = 'Name2';
            acc2.AV_NumPerso__c = '345';
            acc2.AV_AttentionModel__c = 'Cliente de alto valor';
            List<Account> listAccountInsert = new List<Account>();
            listAccountInsert.add(acc);
            listAccountInsert.add(acc2);
            listAccountInsert.add(acc3);
            insert listAccountInsert;
            List<Product2> prodsToInsert = new List<Product2>();
            Product2 prodPF = CIBE_TestHelper.createProductSinInsert(null,null, '00112');
            Product2 prodPF2 = CIBE_TestHelper.createProductSinInsert(null,null, '00113');
            Product2 prodPF3 = CIBE_TestHelper.createProductSinInsert(null,null, '00114');
            Product2 prodPF4 = CIBE_TestHelper.createProductSinInsert(null,null, '00115');
            prodsToInsert.add(prodPF);
            prodsToInsert.add(prodPF2);
            prodsToInsert.add(prodPF3);
            prodsToInsert.add(prodPF4);
            insert prodsToInsert;
            Opportunity opp = CIBE_TestHelper.createOpportunityWithEmpleadoSinInsert(acc, prodPF, rtOpp, '00000002', usuario.Id);
            opp.CIBE_GrupoComercial__c = acc3.Id;
            Opportunity opp1 = CIBE_TestHelper.createOpportunityWithEmpleadoSinInsert(acc2, prodPF, rtOpp, '00000001', usuario.Id);
            opp1.CIBE_GrupoComercial__c = acc3.Id;
            Opportunity opp2 = CIBE_TestHelper.createOpportunityWithEmpleadoSinInsert(acc2, prodPF3,rtOpp, '00000003', usuario.Id);
            Opportunity opp3 = CIBE_TestHelper.createOpportunityWithEmpleadoSinInsert(acc2, prodPF3,rtOpp, '00000004', usuario.Id);
            Opportunity opp4 = CIBE_TestHelper.createOpportunityWithEmpleadoSinInsert(acc2, prodPF3,rtOpp, '00000005', usuario.Id);
            opp4.CIBE_ProbabilidadExito__c = 'Baja';
            opp4.AV_FechaProximoRecordatorio__c = System.today().addDays(5);
            opp4.StageName = 'CIBE_Pendiente_Firma';
            opp4.CIBE_NextMeetingDate__c = System.today();
            Opportunity opp5 = CIBE_TestHelper.createOpportunityWithEmpleadoSinInsert(acc2, prodPF3,rtOpp, '00000006', usuario.Id);
            opp5.CIBE_ESG__c = true;
            opp5.AV_FechaProximoRecordatorio__c = System.today().addDays(5);
            opp5.CIBE_Pais__c = 'Alemania';
            opp5.CIBE_TipoOperacion__c = 'Nueva';
            opp5.CIBE_ProbabilidadExito__c = 'Baja';
            Opportunity opp6 = CIBE_TestHelper.createOpportunityWithEmpleadoSinInsert(acc2, prodPF3,rtOpp, '00000007', usuario.Id);
            opp6.AV_Center__c = '00615';
            List<Opportunity> listOpportunityInsert = new List<Opportunity>();
            listOpportunityInsert.add(opp);
            listOpportunityInsert.add(opp1);
            listOpportunityInsert.add(opp2);
            listOpportunityInsert.add(opp3);
            listOpportunityInsert.add(opp4);
            listOpportunityInsert.add(opp5);
            listOpportunityInsert.add(opp6);
            insert listOpportunityInsert;
            AV_ExperienceBusiness__c expNeg = new AV_ExperienceBusiness__c();
            expNeg.AV_DescTipoExperiencia__c = 'Dia a dia';
            expNeg.AV_ExternalID__c = 'EMP002';
            expNeg.AV_Negocio__c = 'EMP';
            expNeg.ownerId = usuario.Id;
            insert expNeg;
            AV_ProductExperience__c prodExp = new AV_ProductExperience__c();
            prodExp.AV_ExternalID__c = 'EMP_00112';
            prodExp.AV_ExperienciaNegocio__c = expNeg.Id;
            prodExp.AV_ProductoFicha__c = prodPF.Id;
            prodExp.ownerId = usuario.Id;
            insert prodExp;
            AV_ProductClient__c prodCliente = new AV_ProductClient__c();
            prodCliente.RecordTypeId = rt.Id;
            prodCliente.AV_Activo__c = true;
            prodCliente.AV_TenenciaProducto__c = '1';
            prodCliente.AV_Potencialidad__c = 'S';
            prodCliente.AV_ProductoFicha__c = prodExp.Id;
            prodCliente.AV_Cliente__c = acc.Id;
            prodCliente.ownerId = usuario.Id;
            insert prodCliente;
        }


    }


    @isTest
	public static void searchParticipeTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        Test.startTest();
        System.runAs(usuario){
            List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
            List<String> lista = new List<String>();
            User usuarioTest  = [SELECT Id, name,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_NumeroOficinaEmpresa__c != NULL AND Alias = 'u1' LIMIT 1];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = usuarioTest.Id;
            // SOSL queries need fixed results in order to retrieve data
            Test.setFixedSearchResults(fixedSearchResults);
            results = CIBE_OppSearchEMP_Controller.searchParticipe(usuarioTest.name,lista,usuarioTest.AV_NumeroOficinaEmpresa__c);
            Test.stopTest();
            System.assert(results != null);
        }
       
	}

    @isTest
	public static void getTipoOperacionPicklistTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usuario) {
            Test.startTest();
            List<CIBE_OppSearchEMP_Controller.OptionsField> listValues = CIBE_OppSearchEMP_Controller.getTipoOperacion();
            System.assert(!listValues.isEmpty());
            Test.stopTest(); 
        }
    }

    @isTest
	public static void getPaisesPicklistTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usuario) {
            Test.startTest();
            List<CIBE_OppSearchEMP_Controller.OptionsField> listValues = CIBE_OppSearchEMP_Controller.getPaises();
            System.assert(!listValues.isEmpty());
            Test.stopTest(); 
        }
    }

    @isTest
	private static void validateGetDataToChart() {
		Test.startTest();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		List<Opportunity> listOpp = [SELECT Id, CIBE_GrupoComercial__c,  AV_Potencial__c, LastModifiedDate, Account.AV_IndicadoresClientes__c, AV_PotencialityOpportunity__c, Account.AV_ClientPotencialityFormula__c, AccountId, AV_PF__c, RecordType.DeveloperName, Account.Name, AV_Type__c, Account.AV_FormulaNegocio__c, RecordType.Name, Name, AV_PF__r.Name, Account.AV_Priority__c, StageName, AV_FechaProximoRecordatorio__c, CloseDate, Account.AV_Negocio__c, Account.AV_Age__c, Account.AV_AhorroEInversion__c, Account.AV_Financiacion__c, Account.AV_Ingresos__c, Account.AV_Preconceived__c, TOLABEL(Account.AV_MyBox__c), TOLABEL(Account.AV_TargetAuto__c), Account.AV_IsPreconceived__c, AV_Propensity__c, AV_PF__r.AV_ExternalId__c, AV_FechaAlta__c FROM Opportunity];
		List<Map<String,String>> listOppSave = new List<Map<String,String>>();
		for (Opportunity opp : listOpp) {
			Map<String,String> oppSearch = constructOppSearch(opp);
			listOppSave.add(oppSearch);
		}
		List<CIBE_OppSearchEMP_Controller.DataCharts> returns;
		System.runAs(usuario){
			returns = CIBE_OppSearchEMP_Controller.getDataToChart(listOppSave, listOppSave, false);
		}
		Test.stopTest();
		System.assert(!returns.isEmpty());
	}

    @isTest
	private static void validateGetDataToChart2() {
		Test.startTest();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		List<Opportunity> listOpp = [SELECT Id, AV_Potencial__c, LastModifiedDate, Account.AV_IndicadoresClientes__c, AV_PotencialityOpportunity__c, Account.AV_ClientPotencialityFormula__c, AccountId, AV_PF__c, RecordType.DeveloperName, Account.Name, AV_Type__c, Account.AV_FormulaNegocio__c, RecordType.Name, Name, AV_PF__r.Name, Account.AV_Priority__c, StageName, AV_FechaProximoRecordatorio__c, CloseDate, Account.AV_Negocio__c, Account.AV_Age__c, Account.AV_AhorroEInversion__c, Account.AV_Financiacion__c, Account.AV_Ingresos__c, Account.AV_Preconceived__c, TOLABEL(Account.AV_MyBox__c), TOLABEL(Account.AV_TargetAuto__c), Account.AV_IsPreconceived__c, AV_Propensity__c, AV_PF__r.AV_ExternalId__c, AV_FechaAlta__c FROM Opportunity];
		List<Map<String,String>> listOppSave = new List<Map<String,String>>();
		for (Opportunity opp : listOpp) {
			Map<String,String> oppSearch = constructOppSearch2(opp);
			listOppSave.add(oppSearch);
		}
		List<CIBE_OppSearchEMP_Controller.DataCharts> returns;
		System.runAs(usuario){
			returns = CIBE_OppSearchEMP_Controller.getDataToChart(listOppSave, listOppSave, false);
		}
		Test.stopTest();
		System.assertEquals(1,returns.size(),'sin experiencia');
        System.assertEquals('Sin experiencia',returns[0].label);
	}



    private static Map<String,String> constructOppSearch(Opportunity opp) {
		Map<String,String> oppSearch = new Map<String,String>();
		oppSearch.put('cliente',opp.Account.Name);
		oppSearch.put('origen',opp.RecordType.Name);
		oppSearch.put('nombre',opp.Name);
		oppSearch.put('producto',opp.AV_PF__r.Name);
		oppSearch.put('productoId',opp.AV_PF__r.AV_ExternalId__c);
		oppSearch.put('estado',opp.StageName);
		oppSearch.put('fechaProxG',getValorDate(opp.AV_FechaProximoRecordatorio__c));
		oppSearch.put('fechaCie',getValorDate(opp.CloseDate));
        oppSearch.put('productoIdSales',opp.AV_PF__c);
        oppSearch.put('grupoComercial',opp.CIBE_GrupoComercial__c);
		return oppSearch;
	}

    private static Map<String,String> constructOppSearch2(Opportunity opp) {
		Map<String,String> oppSearch = new Map<String,String>();
		oppSearch.put('cliente',opp.Account.Name);
        oppSearch.put('oppId',opp.Id);
		oppSearch.put('origen',opp.RecordType.Name);
		oppSearch.put('nombre',opp.Name);
		oppSearch.put('producto',null);
		oppSearch.put('productoId',null);
		oppSearch.put('estado',opp.StageName);
		oppSearch.put('fechaProxG',getValorDate(opp.AV_FechaProximoRecordatorio__c));
		oppSearch.put('fechaCie',getValorDate(opp.CloseDate));
        oppSearch.put('productoIdSales',null);
		return oppSearch;
	}


	private static String getValorDate(Date field) {
		String result;
		if(field != null) {
			result = field.format();
		} else {
			result = '';
		}
		return result;
	}

    @isTest
	private static void validateGetOpportunities() {
		Test.startTest();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		List<Opportunity> listOpp = [SELECT Id, Name, CIBE_GrupoComercial__c, AV_PF__c, AV_PF__r.Name, AV_ExternalID__c FROM Opportunity WHERE OwnerId = :usuario.Id];
		CIBE_OppSearchEMP_Controller.DataFilter df = new CIBE_OppSearchEMP_Controller.DataFilter();
        CIBE_OppSearchEMP_Controller.DataMoreFilters dmf = new CIBE_OppSearchEMP_Controller.DataMoreFilters();
        CIBE_OppSearchEMP_Controller.MultiData md = new CIBE_OppSearchEMP_Controller.MultiData();
        md.id = usuario.id;
        md.label = 'usuario';
        md.bucleId = '1';
		df.isDestacada = false;
		df.isPendienteFirma = true;
		df.isPrio = false;
		df.orderBy = 'RecordType.Name';
		df.orderingCriterion = 'DESC';
		String datosString = Json.serialize(df);
		Boolean destacadas = false;
		String productName;
        List<CIBE_OppSearchEMP_Controller.MultiData> employee = new List<CIBE_OppSearchEMP_Controller.MultiData>();
        employee.add(md);

        dmf.probabilidad = 'Baja';
        dmf.employee = employee;
        String moreFilters = Json.serialize(dmf);
		List<CIBE_OppSearchEMP_Controller.ProductNegocio> listPN = new List<CIBE_OppSearchEMP_Controller.ProductNegocio>();
		CIBE_OppSearchEMP_Controller.ProductNegocio pn = new CIBE_OppSearchEMP_Controller.ProductNegocio();
		List<String> filterName = new List<String>();
		for (Opportunity opp : listOpp) {
			if (opp.AV_ExternalID__c == '00000005') {
				pn.product = opp.AV_PF__c;
				pn.negocio = 'BPA';
				productName = opp.AV_PF__r.Name;
			}
			filterName.add(opp.Name);
		}
		listPN.add(pn);
		String filterExpeString = Json.serialize(listPN);
		CIBE_OppSearchEMP_Controller.DataReturn dr;
		List<String> listProducts = new List<String>();
		System.runAs(usuario){
			dr = CIBE_OppSearchEMP_Controller.getOpportunities(datosString, destacadas, filterExpeString, productName, listProducts, filterName, '1', moreFilters);
		}
		Test.stopTest();
		System.assertEquals(1,dr.totalSize,'una oportunidad cumple los requisitos');
	}



    @isTest
	private static void validateGetOpportunities2() {
		Test.startTest();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        List<CIBE_OppSearchEMP_Controller.MultiData> multiData = new List<CIBE_OppSearchEMP_Controller.MultiData>();
        CIBE_OppSearchEMP_Controller.MultiData md = new  CIBE_OppSearchEMP_Controller.MultiData();
        CIBE_OppSearchEMP_Controller.MultiData md2 = new  CIBE_OppSearchEMP_Controller.MultiData();
        CIBE_OppSearchEMP_Controller.MultiData md3 = new  CIBE_OppSearchEMP_Controller.MultiData();
		List<Opportunity> listOpp = [SELECT Id, Name, AV_PF__c, AV_PF__r.Name, AV_ExternalID__c FROM Opportunity];
        CIBE_OppSearchEMP_Controller.DataMoreFilters dmf = new CIBE_OppSearchEMP_Controller.DataMoreFilters();
        CIBE_OppSearchEMP_Controller.DataFilter df = new CIBE_OppSearchEMP_Controller.DataFilter();
        Product2 prod = [SELECT Id FROM Product2 WHERE AV_ExternalID__c = '00112'];
		Boolean destacadas = false;
		String productName;
        md2.id = usuario.id;
        md2.label = 'usuario';
        md2.bucleId = '1';
        md3.id = 'Activas';
        md3.label = 'Activas';
        md3.bucleId = '1';
        List<CIBE_OppSearchEMP_Controller.MultiData> employee = new List<CIBE_OppSearchEMP_Controller.MultiData>();
        employee.add(md2);
        List<CIBE_OppSearchEMP_Controller.MultiData> stage = new List<CIBE_OppSearchEMP_Controller.MultiData>();
        stage.add(md3);
        dmf.esg = true;
        dmf.probabilidad = 'Baja';
        dmf.origen = CIBE_AppConstants.OPP_INICIATIVAEMP_RT;
        dmf.dateVenFrom = System.today();
        dmf.dateVenUntil = System.today().addDays(10);
        dmf.pais = 'Alemania';
        dmf.operacion = 'Nueva';
        dmf.modeloAtencion = 'Cliente de alto valor';
        dmf.employee = employee;
        dmf.stage = stage;
        for (Opportunity opp : listOpp) {
			if (opp.AV_ExternalID__c == '00000006') {
				md.label = opp.AV_PF__r.Name;
				md.id = opp.AV_PF__c;
			}
			multiData.add(md);
		}
        dmf.producto = multiData;

        String moreFilters = Json.serialize(dmf);
		List<CIBE_OppSearchEMP_Controller.ProductNegocio> listPN = new List<CIBE_OppSearchEMP_Controller.ProductNegocio>();
		CIBE_OppSearchEMP_Controller.ProductNegocio pn = new CIBE_OppSearchEMP_Controller.ProductNegocio();
		List<String> filterName = new List<String>();
		for (Opportunity opp : listOpp) {
			if (opp.AV_ExternalID__c == '00000005') {
				pn.product = opp.AV_PF__c;
				pn.negocio = 'BPA';
				productName = opp.AV_PF__r.Name;
			}
			filterName.add(opp.Name);
		}
		listPN.add(pn);
		String filterExpeString = Json.serialize(listPN);
        String datosString = Json.serialize(df);
		CIBE_OppSearchEMP_Controller.DataReturn dr;
		List<String> listProducts = new List<String>();
		System.runAs(usuario){
			dr = CIBE_OppSearchEMP_Controller.getOpportunities(datosString, destacadas, filterExpeString, productName, listProducts, filterName, '1', moreFilters);
		}
		Test.stopTest();
		System.assertEquals(1,dr.totalSize,'una oportunidad cumple los requisitos');
	}

    @isTest
	private static void validateGetOpportunities3() {
		Test.startTest();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		List<Opportunity> listOpp = [SELECT Id, Name, CIBE_GrupoComercial__c, AV_PF__c, AV_PF__r.Name, AV_ExternalID__c FROM Opportunity WHERE OwnerId = :usuario.Id];
		CIBE_OppSearchEMP_Controller.DataFilter df = new CIBE_OppSearchEMP_Controller.DataFilter();
        CIBE_OppSearchEMP_Controller.DataMoreFilters dmf = new CIBE_OppSearchEMP_Controller.DataMoreFilters();
        CIBE_OppSearchEMP_Controller.MultiData md = new CIBE_OppSearchEMP_Controller.MultiData();
        md.id = usuario.id;
        md.label = 'usuario';
        md.bucleId = '1';
        List<CIBE_OppSearchEMP_Controller.MultiData> employee = new List<CIBE_OppSearchEMP_Controller.MultiData>();
        employee.add(md);
		df.isDestacada = false;
		df.isPendienteFirma = false;
		df.isPrio = false;
		df.orderBy = 'RecordType.Name';
		df.orderingCriterion = 'DESC';
        dmf.employee = employee;
		String datosString = Json.serialize(df);
		Boolean destacadas = false;
		String productName;
        String moreFilters = Json.serialize(dmf);
		List<CIBE_OppSearchEMP_Controller.ProductNegocio> listPN = new List<CIBE_OppSearchEMP_Controller.ProductNegocio>();
		CIBE_OppSearchEMP_Controller.ProductNegocio pn = new CIBE_OppSearchEMP_Controller.ProductNegocio();
		List<String> filterName = new List<String>();
		for (Opportunity opp : listOpp) {
			if (opp.AV_ExternalID__c == '00000002') {
				pn.product = opp.AV_PF__c;
				pn.negocio = 'BPA';
				productName = opp.AV_PF__r.Name;
			}
			filterName.add(opp.Name);
		}
		listPN.add(pn);
		String filterExpeString = Json.serialize(listPN);
		CIBE_OppSearchEMP_Controller.DataReturn dr;
		List<String> listProducts = new List<String>();
		System.runAs(usuario){
			dr = CIBE_OppSearchEMP_Controller.getOpportunities(datosString, destacadas, filterExpeString, productName, listProducts, filterName, '1', moreFilters);
		}
		Test.stopTest();
		System.assertEquals(2,dr.totalSize,'dos oportunidad cumple los requisitos');
	}



    @IsTest
    static void searchProduct_Test(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Product2 product = [SELECT Id, Name FROM Product2 WHERE AV_ExternalID__c = '00112'];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = product.Id;
            Test.setFixedSearchResults(fixedSearchResults);
            List<AV_LookupSearchResult> productos = CIBE_OppSearchEMP_Controller.searchProduct(product.Name);
            System.assert(!productos.isEmpty());
            
        }
        Test.stopTest();
    }
        

   
}