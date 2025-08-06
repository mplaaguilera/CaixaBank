/**********************************************************************************************************************
@description
Name:	  AV_OppSearch_Controller_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_OppSearch_Controller"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US767515		Sandra Gómez		21/12/2023		Init version
	1.1			US866737		Sandra Gómez		19/04/2024		Add method validateGetTypesOptions and add new filter tipo in all methods
	1.2			PPM100408652    Luis Fernández		19/07/2024		enhancedGetUserInfo cover method
***********************************************************************************************************************/
@isTest
public with sharing class AV_OppSearch_Controller_Test {
	@TestSetup
	static void setup(){
		Test.startTest();
		AV_TestHelper.activateLogger();
		AV_TestHelper.createPricebook2();
		Set<String> setRTs = new Set<String>{AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPINICIATIVA_RT,AV_AppConstants.OPPLLAMADA_RT,AV_AppConstants.EMPLOYEE_RT,'AV_ProductoFichaCliente'};
		Map<String,RecordType> rtMap = AV_AppUtilities.getRecordTypeInMap(setRTs);
		User userGcf = [SELECT Id,AV_ExternalId__c FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		User userCli = [SELECT Id,AV_ExternalId__c FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];
		System.runAs(userGcf){
			User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
			userGestor.Email = 'gestor-test@test.com';
			User usrTest = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01543678');
			List<User> listUserInsert = new List<User>();
			listUserInsert.add(userGestor);
			listUserInsert.add(usrTest);
			insert listUserInsert;

			AV_TestHelper.insertNeededPermissions2(listUserInsert[0]);
			AV_TestHelper.insertNeededPermissions2(listUserInsert[1]);

		}
		System.runAs(userCli) {
			Account accTest = AV_TestHelper.createConfidencialCustomerSinInsert();
			Account accTest2 = AV_TestHelper.createCustomerWithNumpersonSinInsert('12345678');
			accTest2.AV_Negocio__c = 'BPA;BPR';
			Account cenTest = AV_TestHelper.createCaixaCenterSinInsert();
			List<Account> listAccountInsert = new List<Account>();
			listAccountInsert.add(accTest);
			listAccountInsert.add(accTest2);
			listAccountInsert.add(cenTest);
			insert listAccountInsert;
            RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_CTO_RT);
        	Account center2 = new Account(Name = '00804 TEST CENTER',CC_Numero_Oficina_Empresa__c = '00804',CC_Numero_Oficina__c = '00804',RecordTypeId = rt.Id,AV_CentroSuperior__c = accTest.Id);
            insert center2;
		}

        Test.stopTest();
		System.runAs(userGcf){
			Account accTest2 = [SELECT Id FROM Account WHERE AV_NumPerso__c = '12345678' LIMIT 1];
			Account accTest = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
			Account cenTest = [SELECT Id FROM Account WHERE CC_Numero_Oficina_Empresa__c = '00615' LIMIT 1];
			User userGestor = [SELECT Id,AV_ExternalId__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com' AND AV_ExternalID__c = 'U01545454'];
			User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01543678' AND IsActive = true];
			Contact conTest = AV_TestHelper.createEmployeeSinInsert2(cenTest, userGestor, rtMap.get('Empleado'),userGestor.AV_ExternalId__c,userGestor);
			Contact conTest2 = AV_TestHelper.createEmployeeSinInsert2(cenTest, userGcf, rtMap.get('Empleado'),userGcf.AV_ExternalId__c,userGcf);
			Contact conTest3 = AV_TestHelper.createEmployeeSinInsert2(cenTest, usrTest, rtMap.get('Empleado'),'U01543678',userGestor);
			conTest2.FirstName = 'Empleado2';
			conTest3.FirstName = 'Empleado3';
			List<Contact> listContactInsert = new List<Contact>();
			listContactInsert.add(conTest);
			listContactInsert.add(conTest2);
			listContactInsert.add(conTest3);
			insert listContactInsert;
			List<Product2> prodsToInsert = new List<Product2>();
			Product2 prodPF = AV_TestHelper.createProductSinInsert(null,null,'50112');
			Product2 prodPF2 = AV_TestHelper.createProductSinInsert(null,null,'50113');
			Product2 prodPF3 = AV_TestHelper.createProductSinInsert(null,null,'50114');
			Product2 prodPF4 = AV_TestHelper.createProductSinInsert(null,null,'50115');
			prodsToInsert.add(prodPF);
			prodsToInsert.add(prodPF2);
			prodsToInsert.add(prodPF3);
			prodsToInsert.add(prodPF4);
			insert prodsToInsert;
			Opportunity opp = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(accTest, conTest, prodPF4, rtMap.get('Iniciativa'), '00000002', userGestor.Id);
			Opportunity opp1 = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(accTest, conTest, prodPF, rtMap.get('Alerta Comercial'), '00000001', userGestor.Id);
			Opportunity opp2 = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(accTest2, conTest, prodPF3, rtMap.get('Alerta Comercial'), '00000003', userGestor.Id);
			Opportunity opp3 = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(accTest2, conTest, prodPF3, rtMap.get('Alerta Comercial'), '00000004', userGestor.Id);
            Opportunity opp4 = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(accTest2, conTest, prodPF3, rtMap.get('Alerta Comercial'), '00000005', userGestor.Id);
            opp4.AV_Center__c = '00615';
            opp4.AV_FechaProximoRecordatorio__c = System.today().addDays(2);
            opp4.AV_Potencial__c = 'B';
			opp4.AV_Type__c ='Hola';
            Opportunity opp5 = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(accTest2, conTest, prodPF3, rtMap.get('Iniciativa'), '00000006', userGestor.Id);
            opp5.AV_Center__c = '00615';
			opp5.AV_Type__c ='Hola2';
            opp5.AV_FechaProximoRecordatorio__c = System.today().addDays(-2);
            Opportunity opp6 = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(accTest2, conTest, prodPF3, rtMap.get('Iniciativa'), '00000007', userGestor.Id);
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
			expNeg.AV_ExternalID__c = 'BPA002';
			expNeg.AV_Negocio__c = 'BPA';
			expNeg.ownerId = userGestor.Id;
			insert expNeg;
			AV_ProductExperience__c prodExp = new AV_ProductExperience__c();
			prodExp.AV_ExternalID__c = 'BPA_50112';
			prodExp.AV_ExperienciaNegocio__c = expNeg.Id;
			prodExp.AV_ProductoFicha__c = prodPF.Id;
			prodExp.ownerId = userGestor.Id;
			insert prodExp;
			AV_ProductClient__c prodCliente = new AV_ProductClient__c();
			prodCliente.RecordTypeId = rtMap.get('ProductoFicha Cliente').Id;
			prodCliente.AV_Activo__c = true;
			prodCliente.AV_TenenciaProducto__c = '1';
			prodCliente.AV_Potencialidad__c = 'S';
			prodCliente.AV_ProductoFicha__c = prodExp.Id;
			prodCliente.AV_Cliente__c = accTest.Id;
			prodCliente.ownerId = userGestor.Id;
			insert prodCliente;
		}
	}

	@isTest
	private static void validateGetOpportunities() {
		Test.startTest();
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com' AND AV_ExternalID__c = 'U01545454'];
		List<Opportunity> listOpp = [SELECT Id, Name, AV_PF__c, AV_PF__r.Name, AV_ExternalID__c FROM Opportunity];
		AV_OppSearch_Controller.DataFilter df = new AV_OppSearch_Controller.DataFilter();
		df.preconcedido = true;
		df.myBox = true;
		df.targetAuto = true;
		df.orderBy = 'RecordType.Name';
		df.orderingCriterion = 'DESC';
		df.limite = '100';
		df.type = 'Hola';
		String datosString = Json.serialize(df);
		Boolean destacadas = true;
		String productName;
		List<AV_OppSearch_Controller.ProductNegocio> listPN = new List<AV_OppSearch_Controller.ProductNegocio>();
		AV_OppSearch_Controller.ProductNegocio pn = new AV_OppSearch_Controller.ProductNegocio();
		List<String> filterName = new List<String>();
		for (Opportunity opp : listOpp) {
			if (opp.AV_ExternalID__c == '00000001') {
				pn.product = opp.AV_PF__c;
				pn.negocio = 'BPA';
				productName = opp.AV_PF__r.Name;
			}
			filterName.add(opp.Name);
		}
		listPN.add(pn);
		String filterExpeString = Json.serialize(listPN);
		AV_OppSearch_Controller.DataReturn dr;
		List<String> listProducts = new List<String>();
		System.runAs(userGestor){
			dr = AV_OppSearch_Controller.getOpportunities(datosString, destacadas, filterExpeString, productName, listProducts, filterName, '1', null);
		}
		Test.stopTest();
		System.assertEquals(0,dr.totalSize,'No tiene ninguna oportunidad que culpa las condiciones');
	}

	@isTest
	private static void validateGetOpportunities2() {
		Test.startTest();
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com' AND AV_ExternalID__c = 'U01545454'];
		List<Opportunity> listOpp = [SELECT Id, Name, AV_PF__c, AV_PF__r.Name, AV_ExternalID__c FROM Opportunity];
		AV_OppSearch_Controller.DataFilter df = new AV_OppSearch_Controller.DataFilter();
		df.preconcedido = false;
		df.myBox = false;
		df.targetAuto = false;
		df.orderBy = 'RecordType.Name';
		df.orderingCriterion = 'DESC';
		df.limite = '100';
		df.type = '';
		String datosString = Json.serialize(df);
		Boolean destacadas = false;
		String productName;
		List<AV_OppSearch_Controller.ProductNegocio> listPN = new List<AV_OppSearch_Controller.ProductNegocio>();
		AV_OppSearch_Controller.ProductNegocio pn = new AV_OppSearch_Controller.ProductNegocio();
		List<String> filterName = new List<String>();
		for (Opportunity opp : listOpp) {
			if (opp.AV_ExternalID__c == '00000001') {
				pn.product = opp.AV_PF__c;
				pn.negocio = 'BPA';
				productName = opp.AV_PF__r.Name;
			}
			filterName.add(opp.Name);
		}
		listPN.add(pn);
		String filterExpeString = Json.serialize(listPN);
		AV_OppSearch_Controller.DataReturn dr;
		List<String> listProducts = new List<String>();
		System.runAs(userGestor){
			dr = AV_OppSearch_Controller.getOpportunities(datosString, destacadas, filterExpeString, productName, listProducts, filterName, '1', null);
		}
		Test.stopTest();
		System.assertEquals(1,dr.totalSize,'una oportunidad cumple los requisitos');
	}

	@isTest
	private static void validateGetDataToChart() {
		Test.startTest();
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com' AND AV_ExternalID__c = 'U01545454'];
		List<Opportunity> listOpp = [SELECT Id, AV_Potencial__c, LastModifiedDate, Account.AV_IndicadoresClientes__c, AV_PotencialityOpportunity__c, Account.AV_ClientPotencialityFormula__c, AccountId, AV_PF__c, RecordType.DeveloperName, Account.Name, AV_Type__c, Account.AV_FormulaNegocio__c, RecordType.Name, Name, AV_PF__r.Name, Account.AV_Priority__c, StageName, AV_FechaProximoRecordatorio__c, CloseDate, Account.AV_Negocio__c, Account.AV_Age__c, Account.AV_AhorroEInversion__c, Account.AV_Financiacion__c, Account.AV_Ingresos__c, Account.AV_Preconceived__c, TOLABEL(Account.AV_MyBox__c), TOLABEL(Account.AV_TargetAuto__c), Account.AV_IsPreconceived__c, AV_Propensity__c, AV_PF__r.AV_ExternalId__c, AV_FechaAlta__c FROM Opportunity];
		List<Map<String,String>> listOppSave = new List<Map<String,String>>();
		for (Opportunity opp : listOpp) {
			Map<String,String> oppSearch = constructOppSearch(opp);
			listOppSave.add(oppSearch);
		}
		List<AV_OppSearch_Controller.DataCharts> returns;
		System.runAs(userGestor){
			returns = AV_OppSearch_Controller.getDataToChart(listOppSave, listOppSave, false);
		}
		Test.stopTest();
		System.assertEquals(2,returns.size(),'Solo dos experiencias');
	}

	@isTest
	private static void validateGetDataToChart2() {
		Test.startTest();
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com' AND AV_ExternalID__c = 'U01545454'];
		List<Opportunity> listOpp = [SELECT Id, AV_Potencial__c, LastModifiedDate, Account.AV_IndicadoresClientes__c, AV_PotencialityOpportunity__c, Account.AV_ClientPotencialityFormula__c, AccountId, AV_PF__c, RecordType.DeveloperName, Account.Name, AV_Type__c, Account.AV_FormulaNegocio__c, RecordType.Name, Name, AV_PF__r.Name, Account.AV_Priority__c, StageName, AV_FechaProximoRecordatorio__c, CloseDate, Account.AV_Negocio__c, Account.AV_Age__c, Account.AV_AhorroEInversion__c, Account.AV_Financiacion__c, Account.AV_Ingresos__c, Account.AV_Preconceived__c, TOLABEL(Account.AV_MyBox__c), TOLABEL(Account.AV_TargetAuto__c), Account.AV_IsPreconceived__c, AV_Propensity__c, AV_PF__r.AV_ExternalId__c, AV_FechaAlta__c FROM Opportunity];
		List<Map<String,String>> listOppSave = new List<Map<String,String>>();
		for (Opportunity opp : listOpp) {
			Map<String,String> oppSearch = constructOppSearch2(opp);
			listOppSave.add(oppSearch);
		}
		List<AV_OppSearch_Controller.DataCharts> returns;
		System.runAs(userGestor){
			returns = AV_OppSearch_Controller.getDataToChart(listOppSave, listOppSave, false);
		}
		Test.stopTest();
		System.assertEquals(0,returns.size(),'ninguna experiencia');
	}

	private static Map<String,String> constructOppSearch(Opportunity opp) {
		Map<String,String> oppSearch = new Map<String,String>();
		oppSearch.put('destacada','');
		if ((System.today().addDays(7) > opp.AV_FechaProximoRecordatorio__c && opp.StageName == AV_AppConstants.OPP_STATUS_ENGESTION) || (System.today().addDays(7) > opp.AV_FechaAlta__c && opp.StageName == AV_AppConstants.OPP_STATUS_POTENCIAL)) {
			oppSearch.put('destacadaIcon','action:priority');
			oppSearch.put('iconClass','slds-icon-custom-custom16 slds-icon_container slds-var-p-top_xx-small slds-var-p-bottom_xx-small');
		} else {
			oppSearch.put('iconClass','');
			oppSearch.put('destacadaIcon','');
		}
		oppSearch.put('cliente',opp.Account.Name);
		oppSearch.put('origen',opp.RecordType.Name);
		oppSearch.put('nombre',opp.Name);
		oppSearch.put('producto',opp.AV_PF__r.Name);
		oppSearch.put('productoId',opp.AV_PF__r.AV_ExternalId__c);
		oppSearch.put('estado',opp.StageName);
		oppSearch.put('fechaPro',getValorDate(opp.AV_FechaProximoRecordatorio__c));
		oppSearch.put('fechaCie',getValorDate(opp.CloseDate));
		oppSearch.put('negocio',opp.Account.AV_Negocio__c);
		if(opp.Account.AV_FormulaNegocio__c != null && opp.Account.AV_FormulaNegocio__c.contains('<br>')) {
			if(opp.Account.AV_FormulaNegocio__c.replaceAll('<br>', ';').contains(';')) {
				String nego = opp.Account.AV_FormulaNegocio__c.replaceAll('<br>', ';');
				oppSearch.put('negocioView',nego.substring(0,nego.length()-1));
			} else {
				oppSearch.put('negocioView',opp.Account.AV_FormulaNegocio__c.replaceAll('<br>', ';'));
			}
		} else {
			oppSearch.put('negocioView',opp.Account.AV_FormulaNegocio__c);
		}
		oppSearch.put('edad','22');
		oppSearch.put('ahorroEInversion',getValorDecimal(opp.Account.AV_AhorroEInversion__c));
		oppSearch.put('financiacion',getValorDecimal(opp.Account.AV_Financiacion__c));
		oppSearch.put('ingresos',getValorDecimal(opp.Account.AV_Ingresos__c));
		oppSearch.put('preconcedido',getValorDecimal(opp.Account.AV_Preconceived__c));
		oppSearch.put('mybox',opp.Account.AV_MyBox__c);
		oppSearch.put('targetAuto',opp.Account.AV_TargetAuto__c);
		oppSearch.put('tipo',opp.AV_Type__c);
		return oppSearch;
	}

	private static Map<String,String> constructOppSearch2(Opportunity opp) {
		Map<String,String> oppSearch = new Map<String,String>();
		oppSearch.put('destacada','');
		if ((System.today().addDays(7) > opp.AV_FechaProximoRecordatorio__c && opp.StageName == AV_AppConstants.OPP_STATUS_ENGESTION) || (System.today().addDays(7) > opp.AV_FechaAlta__c && opp.StageName == AV_AppConstants.OPP_STATUS_POTENCIAL)) {
			oppSearch.put('destacadaIcon','action:priority');
			oppSearch.put('iconClass','slds-icon-custom-custom16 slds-icon_container slds-var-p-top_xx-small slds-var-p-bottom_xx-small');
		} else {
			oppSearch.put('iconClass','');
			oppSearch.put('destacadaIcon','');
		}
		oppSearch.put('cliente',opp.Account.Name);
		oppSearch.put('origen',opp.RecordType.Name);
		oppSearch.put('nombre',opp.Name);
		oppSearch.put('producto',opp.AV_PF__r.Name);
		oppSearch.put('productoId',opp.AV_PF__r.AV_ExternalId__c);
		oppSearch.put('estado',opp.StageName);
		oppSearch.put('fechaPro',getValorDate(opp.AV_FechaProximoRecordatorio__c));
		oppSearch.put('fechaCie',getValorDate(opp.CloseDate));
		oppSearch.put('oppId','/'+opp.Id);
		oppSearch.put('negocio',null);
		if(opp.Account.AV_FormulaNegocio__c != null && opp.Account.AV_FormulaNegocio__c.contains('<br>')) {
			if(opp.Account.AV_FormulaNegocio__c.replaceAll('<br>', ';').contains(';')) {
				String nego = opp.Account.AV_FormulaNegocio__c.replaceAll('<br>', ';');
				oppSearch.put('negocioView',nego.substring(0,nego.length()-1));
			} else {
				oppSearch.put('negocioView',opp.Account.AV_FormulaNegocio__c.replaceAll('<br>', ';'));
			}
		} else {
			oppSearch.put('negocioView',opp.Account.AV_FormulaNegocio__c);
		}
		oppSearch.put('edad','19');
		oppSearch.put('ahorroEInversion',getValorDecimal(opp.Account.AV_AhorroEInversion__c));
		oppSearch.put('financiacion',getValorDecimal(opp.Account.AV_Financiacion__c));
		oppSearch.put('ingresos',getValorDecimal(opp.Account.AV_Ingresos__c));
		oppSearch.put('preconcedido',getValorDecimal(opp.Account.AV_Preconceived__c));
		oppSearch.put('mybox',opp.Account.AV_MyBox__c);
		oppSearch.put('targetAuto',opp.Account.AV_TargetAuto__c);
		oppSearch.put('tipo',opp.AV_Type__c);
		return oppSearch;
	}

	private static String getValorDecimal(Decimal field) {
		String result;
		if(field != null) {
			result = field.setScale(0).format()+' €';
		} else {
			result = '0 €';
		}
		return result;
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
	private static void validateSearchOffice() {
		AV_OppSearch_Controller.SearchOffices res = new AV_OppSearch_Controller.SearchOffices();
        List<String> lista = new List<String>();
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];


        Test.startTest();
        List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'System Administrator\' LIMIT 1');
		Profile p = (Profile) result.get(0);
		User u1 = new User(
            Alias = 'u1',
            Email = 'test@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '00615',
            ProfileId = p.Id,
            UserName = 'testu2@test.dev',
            AV_ExternalID__c = 'U0009102',
            IsActive = true,
            AV_Funcion__c = 'DAN'
        );
		
			
        User u2 = new User(
            Alias = 'u2',
            Email = 'test2@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '00615',
            ProfileId = p.Id,
            UserName = 'testu3@test.dev',
            AV_ExternalID__c = 'U0009103',
            IsActive = true,
            AV_Funcion__c = 'Gestor'
        );
        User u3 = new User(
            Alias = 'u3',
            Email = 'test3@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '00615',
            ProfileId = p.Id,
            UserName = 'testu4@test.dev',
            AV_ExternalID__c = 'U0009104',
            IsActive = true,
            AV_Funcion__c = 'SSCC'
        );
        insert new List<User>{u1,u2,u3};
	
        AV_TestHelper.insertNeededPermissions2(u1);
        AV_TestHelper.insertNeededPermissions2(u2);
        AV_TestHelper.insertNeededPermissions2(u3);
		Account center2 = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '00804' LIMIT 1];
		System.runAs(userGcf){
			Contact cn2 = AV_TestHelper.createEmployeeSinInsert(center2,u2,'U0009103');
			cn2.CC_Matricula__c = u2.AV_ExternalId__c;
			cn2.LastName = 'gestorContact'; 
			cn2.AV_CodFuncion__c = '50001967';
			cn2.OwnerId = u2.Id;
			insert cn2;
			
			Opportunity opp = [SELECT ID FROM Opportunity WHERE AV_ExternalId__c = '00000003'];
			opp.OwnerId = u2.Id;
			opp.AV_Center__C = '00615';
			update opp;

		}
        Account a = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '00615' LIMIT 1];
        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = center2.Id;
        // SOSL queries need fixed results in order to retrieve data
        Test.setFixedSearchResults(fixedSearchResults);
        // Director
        System.runAs(u1) {            
            res = AV_OppSearch_Controller.searchOffice('00804', lista);
            res = AV_OppSearch_Controller.searchOffice('00804', new List<String>{a.Id});
        }
        // Gestor
        System.runAs(u2) {
            res = AV_OppSearch_Controller.searchOffice('00804', lista);
            res = AV_OppSearch_Controller.searchOffice('00804', new List<String>{a.Id});
        }
        // SSCC
        System.runAs(u3) {
            res = AV_OppSearch_Controller.searchOffice('00804', lista);
            res = AV_OppSearch_Controller.searchOffice('00804', new List<String>{a.Id});
        }
        Test.stopTest();
        System.assert(!res.listOfi.isEmpty());
    }
    
    @isTest
	private static void validateSearchOffice2() {
		AV_OppSearch_Controller.SearchOffices res = new AV_OppSearch_Controller.SearchOffices();
        List<String> lista = new List<String>();
        Test.startTest();
        List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'System Administrator\' LIMIT 1');
		Profile p = (Profile) result.get(0);
		User u1 = new User(
            Alias = 'u1',
            Email = 'test@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '00615',
            ProfileId = p.Id,
            UserName = 'testu2@test.dev',
            AV_ExternalID__c = 'U0009102',
            IsActive = true,
            AV_Funcion__c = 'DAN',
            AV_OriginalOfficeNumber__c = '00615'
        );
        User u2 = new User(
            Alias = 'u2',
            Email = 'test2@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '00615',
            ProfileId = p.Id,
            UserName = 'testu3@test.dev',
            AV_ExternalID__c = 'U0009103',
            IsActive = true,
            AV_Funcion__c = 'Gestor',
            AV_OriginalOfficeNumber__c = '00615'
        );
        User u3 = new User(
            Alias = 'u3',
            Email = 'test3@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '00615',
            ProfileId = p.Id,
            UserName = 'testu4@test.dev',
            AV_ExternalID__c = 'U0009104',
            IsActive = true,
            AV_Funcion__c = 'SSCC',
            AV_OriginalOfficeNumber__c = '00615'
        );
        insert new List<User>{u1,u2,u3};
        AV_TestHelper.insertNeededPermissions2(u1);
        AV_TestHelper.insertNeededPermissions2(u2);
        AV_TestHelper.insertNeededPermissions2(u3);
        Account a = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '00615' LIMIT 1];
        Account center2 = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '00804' LIMIT 1];
        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = center2.Id;
        // SOSL queries need fixed results in order to retrieve data
        Test.setFixedSearchResults(fixedSearchResults);
        // Director
        System.runAs(u1) {            
            res = AV_OppSearch_Controller.searchOffice('00804', lista);
            res = AV_OppSearch_Controller.searchOffice('00804', new List<String>{a.Id});
        }
        // Gestor
        System.runAs(u2) {
            res = AV_OppSearch_Controller.searchOffice('00804', lista);
            res = AV_OppSearch_Controller.searchOffice('00804', new List<String>{a.Id});
        }
        // SSCC
        System.runAs(u3) {
            res = AV_OppSearch_Controller.searchOffice('00804', lista);
            res = AV_OppSearch_Controller.searchOffice('00804', new List<String>{a.Id});
        }
        Test.stopTest();
        System.assert(res.listOfi.isEmpty());
    }
    
    @isTest
	private static void getEmployeesTest() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		User u = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND Email = 'gestor-test@test.com' AND AV_ExternalID__c = 'U01545454' LIMIT 1];

        System.runAs(u){
        	List<AV_OppSearch_Controller.OptionsEmployee> employees = new List<AV_OppSearch_Controller.OptionsEmployee>();
        	Test.startTest();
            Id[] fixedSearchResults = new Id[2];
            fixedSearchResults[0] = u.Id;
            fixedSearchResults[1] = userGcf.Id;
            Test.setFixedSearchResults(fixedSearchResults);
            String ofi = '00615';
            employees= AV_OppSearch_Controller.getEmployees(ofi);
            Opportunity opp = [SELECT Id, StageName, AV_Center__c, RecordTypeId,RecordType.DeveloperName FROM Opportunity WHERE OwnerId = :u.Id LIMIT 1];
            String oficinaData = opp.AV_Center__c+'{|}' + opp.StageName+'{|}'+ opp.RecordType.DeveloperName;
            employees= AV_OppSearch_Controller.getEmployees(oficinaData);
            String oficinaData2 = '00615{|}' + opp.StageName+'{|}all';
            List<AV_OppSearch_Controller.OptionsEmployee> employees2= AV_OppSearch_Controller.getEmployees(oficinaData2);
        	System.assertEquals(true,!employees.isEmpty(), 'getEmployeesTest');
		}
	}
    
    @isTest
	private static void validateGetOpportunities3() {
		Test.startTest();
		User userGestor = [SELECT Id,Name FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com' AND AV_ExternalID__c = 'U01545454'];
		List<Opportunity> listOpp = [SELECT Id, Name, AV_PF__c, AV_PF__r.Name, AV_ExternalID__c FROM Opportunity];
		AV_OppSearch_Controller.DataFilter df = new AV_OppSearch_Controller.DataFilter();
		df.preconcedido = false;
		df.myBox = false;
		df.targetAuto = false;
		df.orderBy = 'O';
		df.orderingCriterion = 'DESC';
		df.limite = '100';
		df.type = 'Hola';
		String datosString = Json.serialize(df);
		Boolean destacadas = false;
		String productName;
        AV_OppSearch_Controller.DataMoreFilters dmf = new AV_OppSearch_Controller.DataMoreFilters();
        dmf.oficina = '00615';
        AV_OppSearch_Controller.MultiData mdEmployee = new AV_OppSearch_Controller.MultiData();
        mdEmployee.label = userGestor.Name;
        mdEmployee.id = userGestor.Id;
        mdEmployee.bucleId = '0';
        List<AV_OppSearch_Controller.MultiData> listMdEmployee = new List<AV_OppSearch_Controller.MultiData>();
        listMdEmployee.add(mdEmployee);
        dmf.employee = listMdEmployee;
        dmf.origen = 'AV_Iniciativa';
        AV_OppSearch_Controller.MultiData mdStage = new AV_OppSearch_Controller.MultiData();
        mdStage.label = 'En gestión/insistir';
        mdStage.id = 'En gestión/insistir';
        mdStage.bucleId = '0';
        List<AV_OppSearch_Controller.MultiData> listMdStage = new List<AV_OppSearch_Controller.MultiData>();
        listMdStage.add(mdStage);
        dmf.stage = listMdStage;
        dmf.expSale = 'S';
        dmf.dateProFrom = System.today();
        dmf.dateProUntil = System.today().addDays(1);
        dmf.dateVenFrom = System.today();
        dmf.dateVenUntil = System.today().addDays(1);
        dmf.dateModFrom = System.today();
        dmf.dateModUntil = System.today().addDays(1);
		AV_OppSearch_Controller.MultiData seg1 = new AV_OppSearch_Controller.MultiData();
		seg1.label = 'ImaginTeen';
		seg1.id = '1' ;
		seg1.bucleId = '0';
		AV_OppSearch_Controller.MultiData seg2 = new AV_OppSearch_Controller.MultiData();
		seg2.label = 'AgroBank';
		seg2.id = '2' ;
		seg2.bucleId = '1' ;
		dmf.segmento = new List<AV_OppSearch_Controller.MultiData>{seg1,seg2};
        AV_OppSearch_Controller.MultiData mdSegmento = new AV_OppSearch_Controller.MultiData();
        mdSegmento.label = 'ImaginBank';
        mdSegmento.id = '11';
        mdSegmento.bucleId = '0';
        List<AV_OppSearch_Controller.MultiData> listMdSegmento = new List<AV_OppSearch_Controller.MultiData>();
        listMdSegmento.add(mdSegmento);
        dmf.segmento = listMdSegmento;
        String moreFiltersString = Json.serialize(dmf);
		List<AV_OppSearch_Controller.ProductNegocio> listPN = new List<AV_OppSearch_Controller.ProductNegocio>();
		AV_OppSearch_Controller.ProductNegocio pn = new AV_OppSearch_Controller.ProductNegocio();
		List<String> filterName = new List<String>();
		for (Opportunity opp : listOpp) {
			if (opp.AV_ExternalID__c == '00000001') {
				pn.product = opp.AV_PF__c;
				pn.negocio = 'BPA';
				productName = opp.AV_PF__r.Name;
			}
			filterName.add(opp.Name);
		}
		listPN.add(pn);
		String filterExpeString = Json.serialize(listPN);
		AV_OppSearch_Controller.DataReturn dr;
		List<String> listProducts = new List<String>();
		System.runAs(userGestor){
			dr = AV_OppSearch_Controller.getOpportunities(datosString, destacadas, filterExpeString, null, listProducts, filterName, '1', moreFiltersString);
		}
		Test.stopTest();
		System.assertEquals(0,dr.totalSize,'no hay oportuniades que cumplan los requisitos');
	}
    
    @isTest
	private static void validateGetOpportunities5() {
		Test.startTest();
		User userGestor = [SELECT Id,Name FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com' AND AV_ExternalID__c = 'U01545454'];
		User userGcf = [SELECT Id,Name FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		AV_OppSearch_Controller.DataFilter df = new AV_OppSearch_Controller.DataFilter();
		df.preconcedido = false;
		df.myBox = false;
		df.targetAuto = false;
		df.orderBy = 'O';
		df.orderingCriterion = 'DESC';
		df.limite = '100';
		df.type = 'Hola';
		String datosString = Json.serialize(df);
        AV_OppSearch_Controller.DataMoreFilters dmf = new AV_OppSearch_Controller.DataMoreFilters();
        dmf.oficina = '00615';
        AV_OppSearch_Controller.MultiData mdEmployee = new AV_OppSearch_Controller.MultiData();
        mdEmployee.label = userGcf.Name;
        mdEmployee.id = userGcf.Id;
        mdEmployee.bucleId = '0';
        List<AV_OppSearch_Controller.MultiData> listMdEmployee = new List<AV_OppSearch_Controller.MultiData>();
        listMdEmployee.add(mdEmployee);
        dmf.employee = listMdEmployee;
        dmf.origen = 'AV_Iniciativa';
        AV_OppSearch_Controller.MultiData mdStage = new AV_OppSearch_Controller.MultiData();
        mdStage.label = 'Potencial';
        mdStage.id = 'Potencial';
        mdStage.bucleId = '0';
        List<AV_OppSearch_Controller.MultiData> listMdStage = new List<AV_OppSearch_Controller.MultiData>();
        listMdStage.add(mdStage);
        dmf.stage = listMdStage;
        dmf.expSale = 'S';
        dmf.dateProFrom = System.today();
        dmf.dateProUntil = System.today().addDays(1);
        dmf.dateVenFrom = System.today();
        dmf.dateVenUntil = System.today().addDays(1);
        dmf.dateModFrom = System.today();
        dmf.dateModUntil = System.today().addDays(1);
        dmf.segmento = null;
        String moreFiltersString = Json.serialize(dmf);
		AV_OppSearch_Controller.DataReturn dr;
		System.runAs(userGestor){
			dr = AV_OppSearch_Controller.getOpportunities(datosString, null, null, null, null, null, '1', moreFiltersString);
		}
		Test.stopTest();
		System.assertEquals(0,dr.totalSize,'no hay oportuniades que cumplan los requisitos');
	}
    @isTest
	private static void validateGetOpportunities4() {
		Test.startTest();
		User userGestor = [SELECT Id,Name FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com' AND AV_ExternalID__c = 'U01545454'];
		AV_OppSearch_Controller.DataFilter df = new AV_OppSearch_Controller.DataFilter();
		df.preconcedido = false;
		df.myBox = false;
		df.targetAuto = false;
		df.orderBy = 'O';
		df.orderingCriterion = 'DESC';
		df.limite = '100';
		df.type = 'Hola';
		String datosString = Json.serialize(df);
        AV_OppSearch_Controller.DataMoreFilters dmf = new AV_OppSearch_Controller.DataMoreFilters();
        dmf.oficina = '00615';
        AV_OppSearch_Controller.MultiData mdEmployee = new AV_OppSearch_Controller.MultiData();
        mdEmployee.label = userGestor.Name;
        mdEmployee.id = userGestor.Id;
        mdEmployee.bucleId = '0';
        List<AV_OppSearch_Controller.MultiData> listMdEmployee = new List<AV_OppSearch_Controller.MultiData>();
        listMdEmployee.add(mdEmployee);
        dmf.employee = listMdEmployee;
        dmf.origen = 'AV_Iniciativa';
        AV_OppSearch_Controller.MultiData mdStage = new AV_OppSearch_Controller.MultiData();
        mdStage.label = 'Potencial';
        mdStage.id = 'Potencial';
        mdStage.bucleId = '0';
        List<AV_OppSearch_Controller.MultiData> listMdStage = new List<AV_OppSearch_Controller.MultiData>();
        listMdStage.add(mdStage);
        dmf.stage = listMdStage;
        dmf.expSale = 'S';
        dmf.dateProFrom = System.today();
        dmf.dateProUntil = System.today().addDays(1);
        dmf.dateVenFrom = System.today();
        dmf.dateVenUntil = System.today().addDays(1);
        dmf.dateModFrom = System.today();
        dmf.dateModUntil = System.today().addDays(1);
        dmf.segmento = null;
        String moreFiltersString = Json.serialize(dmf);
		AV_OppSearch_Controller.DataReturn dr;
		System.runAs(userGestor){
			dr = AV_OppSearch_Controller.getOpportunities(datosString, null, null, null, null, null, '1', moreFiltersString);
		}
		Test.stopTest();
		System.assertEquals(0,dr.totalSize,'no hay oportuniades que cumplan los requisitos');
	}

	@isTest
	private static void validateGetTypesOptions() {
		Test.startTest();
		User userGestor = [SELECT Id,Name FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com' AND AV_ExternalID__c = 'U01545454'];
		List<AV_OppSearch_Controller.OptionsEmployee> listOpp = new List<AV_OppSearch_Controller.OptionsEmployee>();
		System.runAs(userGestor) {
			listOpp = AV_OppSearch_Controller.getTypesOptions('00615', userGestor.Id, new List<String> {'50114'});
		}
		Test.stopTest();
		System.assertEquals(2,listOpp.size(),'Hay dos opciones que es la nula y una oportunidad');
	}

	@isTest
	public static void enhancedGetUserInfoTest(){
		User userGestor = [SELECT Id,Name FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com' AND AV_ExternalID__c = 'U01545454'];
		Map<String,User> self;
		Test.startTest();
			System.runAs(userGestor){
				self = AV_OppSearch_Controller.enanchedGetUserInfo(userGestor.Id);
			}
		Test.stopTest();
		System.assert(self != null);
		
	}
}