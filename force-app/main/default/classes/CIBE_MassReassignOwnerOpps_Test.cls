/**********************************************************************************************************************
Name:	  CIBE_MassReassignOwnerOpps_Test
Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de "CIBE_MassReassignOwnerOpps_Controller"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION     USER_STORY              AUTHOR              DATE            Description
    1.0			US380297   		        Luis Martinez      24/11/2022		Init version
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_MassReassignOwnerOpps_Test {
    
    @TestSetup
	static void setup(){
		Pricebook2 pb =  CIBE_TestHelper.createPricebook2();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'CIBE_Gestor' limit 1];
        User usrOtraOficina = new User(
            AV_ExternalID__c = 'U0009826',
            Alias = 'tsAlias',
            Email = 'test@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '12345',
            ProfileId = p.Id,
            UserName = 'test@test.dev.devsfc01',
            IsActive = true
        );
        insert usrOtraOficina;
        User usrMiOficina = CIBE_TestHelper.createUser('CIBE_Gestor');
        usrMiOficina.AV_NumeroOficinaEmpresa__c = '13297'; //used in searchTestMiOficina
        update usrMiOficina;
		Account accTest = CIBE_TestHelper.createCustomer();
		Account cenTest = CIBE_TestHelper.createCaixaCenter();
		Contact conTest = CIBE_TestHelper.createEmployee(cenTest, usrOtraOficina);
		User usrTestApiOnly = CIBE_TestHelper.createUser('API Only');
	} 
    
	@isTest
	public static void getBaseDataOppsNullTest() {

        CIBE_MassReassignOwnerOpps_Controller.ObjectList ol = new CIBE_MassReassignOwnerOpps_Controller.ObjectList();
        String clientFilter = null;
        String subjectFilter = null;
        String origenFilter = null;
        String statusFilter = null;
        List<String> employeeFilter = new List<String>();
        String[] filterList = null;
        Date fechaCierreD = null;
        Date fechaCierreH = null;
        String[] participesFilter = null;
        Double importeFilter = null;
        String targetProbabilidad = null;
        String office = null;
        String page = '1'; //needed for pagination
        User usuario  = [Select Id From User Where Email = 'test@test.dev' limit 1];
        employeeFilter.add(usuario.Id);
        Test.startTest();   
            ol = CIBE_MassReassignOwnerOpps_Controller.getBaseData(clientFilter, subjectFilter, origenFilter, statusFilter, employeeFilter, filterList, fechaCierreD, fechaCierreH, page, office, targetProbabilidad, importeFilter, participesFilter);        
        System.assertEquals(true,ol.recordList.isEmpty(), 'getBaseDataOppsNullTest');
        Test.stopTest();
    }

    /**
     * Made to improve coverage
     */
    @isTest
	public static void getBaseDataOppsDatosTest() {
        Account a = [SELECT Id FROM Account LIMIT 1];
        CIBE_MassReassignOwnerOpps_Controller.ObjectList ol = new CIBE_MassReassignOwnerOpps_Controller.ObjectList();
        String objectName='Opportunity';
        String clientFilter = a.Id;
        String subjectFilter = 'Alerta Comercial';
        String origenFilter = CIBE_AppConstants.OPP_INICIATIVACIB_RT;
        String statusFilter = 'Potencial';
        List<String> employeeFilter = new List<String>();
        String targetProbabilidad = 'Media';
        String office = null;
        String[] filterList = new List<String>();
        Date fechaCierreD = System.today()-1;
        Date fechaCierreH = System.today()+6;
        String[] participesFilter = new List<String>();
        Double importeFilter = 100;
        String page = '1'; //needed for pagination
        User usuario  = [Select Id, name From User Where Email = 'test@test.dev' limit 1];
        Contact c = [SELECT Id FROM Contact WHERE FirstName = 'Empleado' LIMIT 1];
        Opportunity o2 =CIBE_TestHelper.createOpportunityWithEmpleado(a, c);
        o2.CIBE_ProbabilidadExito__c = targetProbabilidad;
        o2.CIBE_ImporteOtraEntidad__c = importeFilter+1;

        if(o2!=null && o2?.AV_PF__c !=null){
            filterList.add(o2.AV_PF__c);
        }
        if(o2!=null){
            employeeFilter.add(usuario.Id);
            o2.OwnerId = usuario.id;
        }
        if(o2!=null){
            o2.AV_ToDelete__c = false;
        }
        participesFilter.add(usuario.name);
        Test.startTest();
        system.debug('employeeFilter::: '+employeeFilter);
        system.debug('targetProbabilidad::: '+targetProbabilidad);
        system.debug('02::: '+o2);

            ol = CIBE_MassReassignOwnerOpps_Controller.getBaseData(clientFilter, subjectFilter, origenFilter, statusFilter, employeeFilter, filterList, fechaCierreD, fechaCierreH, page, office, targetProbabilidad, importeFilter, participesFilter);        
            System.assertEquals(true, ol!=null, 'getBaseDataOppsDatosTest');
        Test.stopTest();
    } 

  	@isTest
	private static void getEmployeesTest() {
	
        List<CIBE_MassReassignOwnerOpps_Controller.optionsEmployee> employees = new List<CIBE_MassReassignOwnerOpps_Controller.optionsEmployee>();       
        Test.startTest();
            employees= CIBE_MassReassignOwnerOpps_Controller.getEmployees('00615');
            System.assertEquals(true,!employees.isEmpty(), 'getEmployeesTest');
        Test.stopTest();
	}
    
    @isTest
	public static void searchTestMiOficina() {
		String searchTerm = 'test';
		List<AV_LookupSearchResult> listSearch = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();
        User userPass = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '13297' LIMIT 1];
        System.runAs(userPass) {
            User empMiOficina = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '13297' LIMIT 1];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = empMiOficina.Id;
            // SOSL queries need fixed results in order to retrieve data
            Test.setFixedSearchResults(fixedSearchResults);
            Test.startTest();
                listSearch = CIBE_MassReassignOwnerOpps_Controller.search(searchTerm, lista, true);
                System.assertEquals(true, !listSearch.isEmpty(), 'searchTest');
            Test.stopTest();
        }
	}

    @isTest
	public static void searchTestOtraOficina() {
		String searchTerm = 'test';
		List<AV_LookupSearchResult> listSearch = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();
        User userPass = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '13297' LIMIT 1];
        System.runAs(userPass) {
            User empOtraOficina = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c != '13297' LIMIT 1];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = null;
            // SOSL queries need fixed results in order to retrieve data
            Test.setFixedSearchResults(fixedSearchResults);
            Test.startTest();
                listSearch = CIBE_MassReassignOwnerOpps_Controller.search(searchTerm, lista, false);
                System.assertEquals(true, listSearch.isEmpty(), 'searchTest');
            Test.stopTest();
        }
	}
    
    @isTest
	public static void searchUserTest () {
	
		String searchTerm = '*';
		List<AV_LookupSearchResult> listSearch = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();

        Test.startTest();
            listSearch = CIBE_MassReassignOwnerOpps_Controller.searchUser(searchTerm, lista);
            System.assertEquals(true,listSearch.isEmpty(), 'searchTest');
        Test.stopTest();
	}

    @isTest
	public static void assignOppTest () {
		List<List<SObject>> searchResults = new List<List<SObject>>();
        Account setupAccount = [SELECT ID FROM ACCOUNT LIMIT 1];
        Opportunity opp = CIBE_TestHelper.createOpportunity(setupAccount);
        List<Opportunity> listOpp = new List<Opportunity>{opp};
        String objectName='Opportunity';	
        String result = null;

        Test.startTest();
        User usuario  = [Select Id From User Where Email = 'test@test.dev' limit 1];
        result = CIBE_MassReassignOwnerOpps_Controller.assign(objectName, usuario.Id, listOpp);
        Test.stopTest();
        Opportunity rtrvOpp = [SELECT OwnerId FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertEquals(rtrvOpp.OwnerId,rtrvOpp.OwnerId,'Actualizacion de owner fallida');
    }	
    
	@isTest
	public static void searchProductTest(){

        List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();
        Test.startTest();
        Product2 p2 = CIBE_TestHelper.createProduct(null, '1'); //TO DO
        Product2 p22 = CIBE_TestHelper.createProduct(null, '10');
        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = p2.Id;
        // SOSL queries need fixed results in order to retrieve data
        Test.setFixedSearchResults(fixedSearchResults);
        results = CIBE_MassReassignOwnerOpps_Controller.searchProduct(p2.Name,lista);
        results = CIBE_MassReassignOwnerOpps_Controller.searchProduct('*',new List<String>{p22.Id});
        Test.stopTest();
        System.assert(results!= null);
	}
    
    @isTest
	public static void searchAccountTest(){
        Test.startTest();
        List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();
        List<Account> acc = [Select Id, Name From Account];
        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = acc.get(0).Id;
        // SOSL queries need fixed results in order to retrieve data
        Test.setFixedSearchResults(fixedSearchResults);
        results = CIBE_MassReassignOwnerOpps_Controller.searchAccount(acc.get(0).Name,lista);
        results = CIBE_MassReassignOwnerOpps_Controller.searchAccount(acc.get(0).Name,new List<String>{acc.get(1).Id});
        Test.stopTest();
        System.assert(results != null);
	}
    @isTest
	public static void searchParticipeTest(){
        Test.startTest();
        List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();
        User usuario  = [Select Id, name,AV_NumeroOficinaEmpresa__c From User Where AV_NumeroOficinaEmpresa__c != NULL limit 1];
        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = usuario.Id;
        // SOSL queries need fixed results in order to retrieve data
        Test.setFixedSearchResults(fixedSearchResults);
        results = CIBE_MassReassignOwnerOpps_Controller.searchParticipe(usuario.name,lista,usuario.AV_NumeroOficinaEmpresa__c);
        Test.stopTest();
        System.assert(results != null);
	}
    
    @isTest
    public static void nameContactAssignTest() {
        Test.startTest();
        User usuario  = [Select Id From User Where Email = 'test@test.dev' limit 1];
        String resul= CIBE_MassReassignOwnerOpps_Controller.nameContactAssign(usuario.Id);
        Test.stopTest();
        System.assertNotEquals(null,resul);
    }

    @isTest
    public static void getInferiorCenterIdsTest() {
        Set<Id> res = new Set<Id>();
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
            UserName = 'testu1@test.dev',
            AV_ExternalID__c = 'U0009101',
            IsActive = true,
            AV_Funcion__c = 'DAN'
        );
        insert u1;
        Account a = [
            SELECT Id
            FROM Account
            WHERE CC_Numero_Oficina__c = '00615'
            LIMIT 1
        ];
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CENTROCAIXABANK_RT);
        Account center2 = new Account(
            Name = '00803 TEST CENTER',
            CC_Numero_Oficina_Empresa__c = '00803',
            CC_Numero_Oficina__c = '00803',
            RecordTypeId = rt.Id,
            AV_CentroSuperior__c = a.Id
        );
        insert center2;
        System.runAs(u1) {
            res = CIBE_MassReassignOwnerOpps_Controller.getInferiorCenterIds();
        }
        
        Test.stopTest();
        System.assertEquals(false, res.isEmpty(), 'No ids retrieved');
    }

    @isTest
    public static void searchOfficeTest() {
        List<AV_LookupSearchResult> res = new List<AV_LookupSearchResult>();
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
            AV_Funcion__c = 'DAN'
        );
        insert u1;
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
        insert u2;
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
        insert u3;
        Account a = [
            SELECT Id
            FROM Account
            WHERE CC_Numero_Oficina__c = '00615'
            LIMIT 1
        ];
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CENTROCAIXABANK_RT);
        Account center2 = new Account(
            Name = '00804 TEST CENTER',
            CC_Numero_Oficina_Empresa__c = '00804',
            CC_Numero_Oficina__c = '00804',
            RecordTypeId = rt.Id,
            AV_CentroSuperior__c = a.Id
        );
        insert center2;
        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = center2.Id;
        // SOSL queries need fixed results in order to retrieve data
        Test.setFixedSearchResults(fixedSearchResults);
        // Director
        System.runAs(u1) {
            res = CIBE_MassReassignOwnerOpps_Controller.searchOffice('00804', lista);
            res = CIBE_MassReassignOwnerOpps_Controller.searchOffice('00804', new List<String>{a.Id});
        }
        // Gestor
        System.runAs(u2) {
            res = CIBE_MassReassignOwnerOpps_Controller.searchOffice('00804', lista);
            res = CIBE_MassReassignOwnerOpps_Controller.searchOffice('00804', new List<String>{a.Id});
        }
        // SSCC
        System.runAs(u3) {
            res = CIBE_MassReassignOwnerOpps_Controller.searchOffice('00804', lista);
            res = CIBE_MassReassignOwnerOpps_Controller.searchOffice('00804', new List<String>{a.Id});
        }
        Test.stopTest();
        System.assert(!res.isEmpty());
    }

    @isTest
    public static void getCenterIdsTest() {
        List<Id> res = new List<Id>();
        List<Account> accs = [
            SELECT Id
            FROM Account
        ];
        Test.startTest();
            res = CIBE_MassReassignOwnerOpps_Controller.getCenterIds(accs);
        Test.stopTest();
        System.assertEquals(false, res.isEmpty(), 'No ids returned');
    }
}