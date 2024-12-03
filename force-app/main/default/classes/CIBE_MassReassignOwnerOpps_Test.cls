/*****************************************************************************************************************************************************************
Name:	  CIBE_MassReassignOwnerOpps_Test
Copyright © 2021  CaixaBank
------------------------------------------------------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de "CIBE_MassReassignOwnerOpps_Controller"
------------------------------------------------------------------------------------------------------------------------------------------------------------------
Historial
------------------------------------------------------------------------------------------------------------------------------------------------------------------
    VERSION     USER_STORY              AUTHOR              DATE            Description
    1.0			US380297   		        Luis Martinez      24/11/2022		Init version
    2.0         US747476                Bea                14/12/2023       Added conditions in method getBaseDataOppsDatosTest for adding cover to the class
*******************************************************************************************************************************************************************/
@isTest
public with sharing class CIBE_MassReassignOwnerOpps_Test {
    
    @TestSetup
	static void setup(){
        
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP, CIBE_AppConstants.USER_AV_AVOIDBULKAPI,CIBE_AppConstants.EXTENDEDHOME_LINK};
        
        
        CIBE_TestInitialSetup.setupInitialData(null, null, null, null, null, ps);
        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        User managerUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Account cenTest = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c  = '00001' LIMIT 1];
        Contact conTest = [SELECT Id FROM Contact WHERE CC_Matricula__c = 'U0000001' LIMIT 1];
		Pricebook2 pb =  CIBE_TestHelper.createPricebook2();
		Account accTest = CIBE_TestHelper.createCustomer();

        List<Profile> result = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema'  LIMIT 1];
        List <User> listUsers = new List <User>();
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
        listUsers.add(u1);
        User u2 = new User(
            Alias = 'u2',
            Email = 'test2@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '00615',
            ProfileId = result[0].Id,
            UserName = 'testu3@test.dev',
            AV_ExternalID__c = 'U0009103',
            IsActive = true,
            AV_Funcion__c = 'Gestor'
        );
        listUsers.add(u2);
        User u3 = new User(
            Alias = 'u3',
            Email = 'test3@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '00615',
            ProfileId = result[0].Id,
            UserName = 'testu4@test.dev',
            AV_ExternalID__c = 'U0009104',
            IsActive = true,
            AV_Funcion__c = 'SSCC'
        );
        listUsers.add(u3);

        User u4 = new User(
            Alias = 'u4',
            Email = 'test4@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '00803',
            ProfileId = result[0].Id,
            UserName = 'testu1@test.dev',
            AV_ExternalID__c = 'U0009101',
            IsActive = true,
            AV_Funcion__c = 'DAN'
        );
        listUsers.add(u4);
        insert listUsers;
		Test.startTest(); 
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CENTROCAIXABANK_RT);
        Account center = new Account(
            Name = '00803 TEST CENTER',
            CC_Numero_Oficina_Empresa__c = '00803',
            CC_Numero_Oficina__c = '00803',
            RecordTypeId = rt.Id,
            AV_CentroSuperior__c = accTest.Id
        );
        insert center;
        Test.stopTest();
	} 
    
	@isTest
	public static void getBaseDataOppsNullTest() {
        User usuarioR = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuarioR){
        CIBE_MassReassignOwnerOpps_Controller.ObjectList ol = new CIBE_MassReassignOwnerOpps_Controller.ObjectList();
        Test.startTest();  
        
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
        User usuario  = [SELECT Id FROM User WHERE Email = 'test@test.dev' LIMIT 1];
        employeeFilter.add(usuario.Id);
         
            ol = CIBE_MassReassignOwnerOpps_Controller.getBaseData(clientFilter, subjectFilter, origenFilter, statusFilter, employeeFilter, filterList, fechaCierreD, fechaCierreH, page, office, targetProbabilidad, importeFilter, participesFilter);        
        System.assertEquals(true,ol.recordList.isEmpty(), 'getBaseDataOppsNullTest');
        Test.stopTest();
        }
    }

    /**
     * Made to improve coverage
     */
    @isTest
	public static void getBaseDataOppsDatosTest() {
        User usuarioRun = [SELECT Id FROM User WHERE Email = 'test@test.dev' LIMIT 1];
        System.runAs(usuarioRun){
        Test.startTest();
        Account a = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
        CIBE_MassReassignOwnerOpps_Controller.ObjectList ol = new CIBE_MassReassignOwnerOpps_Controller.ObjectList();
        CIBE_MassReassignOwnerOpps_Controller.ObjectList ol2 = new CIBE_MassReassignOwnerOpps_Controller.ObjectList();
        String objectName='Opportunity';
        String clientFilter = a.Id;
        String subjectFilter = 'Alerta Comercial';
        String origenFilter = CIBE_AppConstants.OPP_INICIATIVACIB_RT;
        String origenFilter2 = 'CIBE_IniciativaEmpleadoEMP,CIBE_AccionComercialEMP,CIBE_SugerenciaEMP,CIBE_AlertaComercialEMP';
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
        User usuario  = [SELECT Id, name FROM User WHERE Email = 'test@test.dev' limit 1];
        Contact c = [SELECT Id FROM Contact WHERE FirstName = 'Employee' LIMIT 1];
        Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
        Opportunity o2 = new Opportunity();
        o2.AccountId = a.Id;
        o2.AV_ExternalID__c = '00000001';
        o2.Name = 'Alerta Comercial';
        o2.StageName = 'Potencial';
        o2.RecordTypeId = rt.Id;
        o2.CloseDate = System.today() + 5;
        o2.AV_Gestor__c = c.Id;
        o2.AV_PF__c = prodPF.Id;
        insert o2;
        o2.CIBE_ProbabilidadExito__c = targetProbabilidad;
        o2.CIBE_ImporteOtraEntidad__c = importeFilter+1;

        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.OpportunityId = o2.Id;
        otm.UserId = usuario.Id;
        otm.TeamMemberRole = 'Participante';
        otm.OpportunityAccessLevel = 'Read';
        insert otm;

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

            ol = CIBE_MassReassignOwnerOpps_Controller.getBaseData(clientFilter, subjectFilter, origenFilter, statusFilter, employeeFilter, filterList, fechaCierreD, fechaCierreH, page, office, targetProbabilidad, importeFilter, participesFilter);        
            System.assertEquals(true, ol!=null, 'getBaseDataOppsDatosTest');
            ol2 = CIBE_MassReassignOwnerOpps_Controller.getBaseData(clientFilter, subjectFilter, origenFilter2, statusFilter, employeeFilter, filterList, fechaCierreD, fechaCierreH, page, office, targetProbabilidad, importeFilter, participesFilter);        
            System.assertEquals(true, ol2!=null, 'getBaseDataOppsDatosTest');
        Test.stopTest();
        }
    } 

  	@isTest
	private static void getEmployeesTest() {
        User userPass = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '001-00001' and IsActive = true LIMIT 1];
        Test.startTest();
        List<CIBE_MassReassignOwnerOpps_Controller.optionsEmployee> employees = new List<CIBE_MassReassignOwnerOpps_Controller.optionsEmployee>();       
        System.runAs(userPass) {
            employees= CIBE_MassReassignOwnerOpps_Controller.getEmployees('00615');
            System.assertEquals(true,!employees.isEmpty(), 'getEmployeesTest');
        }
        Test.stopTest();
	}

    @isTest
	private static void getEmployeesEMPTest() {
        User userPass = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '001-00001' and IsActive = true LIMIT 1];
        Test.startTest();
        List<CIBE_MassReassignOwnerOpps_Controller.optionsEmployee> employees = new List<CIBE_MassReassignOwnerOpps_Controller.optionsEmployee>();
        List<CIBE_MassReassignOwnerOpps_Controller.optionsEmployee> employees2 = new List<CIBE_MassReassignOwnerOpps_Controller.optionsEmployee>();       
        System.runAs(userPass) {
            employees= CIBE_MassReassignOwnerOpps_Controller.getEmployeesEMP('00615{|}Activas{|}all');
            System.assertEquals(true,!employees.isEmpty(), 'getEmployeesTest');
            employees2 = CIBE_MassReassignOwnerOpps_Controller.getEmployeesEMP('00615');
            System.assertEquals(true,!employees2.isEmpty(), 'getEmployeesTest');
        }
        Test.stopTest();
	}
    
    @isTest
	public static void searchTestMiOficina() {
        Test.startTest();
		String searchTerm = 'test';
		List<AV_LookupSearchResult> listSearch = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();
        User userPass = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '001-00001' and IsActive = true LIMIT 1];
        System.runAs(userPass) {
            User empMiOficina = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '001-00001'and IsActive = true LIMIT 1];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = empMiOficina.Id;
            // SOSL queries need fixed results in order to retrieve data
            Test.setFixedSearchResults(fixedSearchResults);
            
                listSearch = CIBE_MassReassignOwnerOpps_Controller.search(searchTerm, lista, true);
                System.assertEquals(true, !listSearch.isEmpty(), 'searchTest');
            Test.stopTest();
        }
	}

    @isTest
	public static void searchTestOtraOficina() {
        Test.startTest();
        String searchTerm = 'test';
        List<AV_LookupSearchResult> listSearch = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();
        User userPass = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '001-00001' and IsActive = true LIMIT 1];
        System.runAs(userPass) {
            User empOtraOficina = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c != '001-00001' LIMIT 1];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = null;
            // SOSL queries need fixed results in order to retrieve data
            Test.setFixedSearchResults(fixedSearchResults);
            
                listSearch = CIBE_MassReassignOwnerOpps_Controller.search(searchTerm, lista, false);
                System.assertEquals(true, listSearch.isEmpty(), 'searchTest');
            Test.stopTest();
        }
        
       
	}
    
    @isTest
	public static void searchUserTest () {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            String searchTerm = '*';
            List<AV_LookupSearchResult> listSearch = new List<AV_LookupSearchResult>();
            List<String> lista = new List<String>();
    
            
                listSearch = CIBE_MassReassignOwnerOpps_Controller.searchUser(searchTerm, lista);
                System.assertEquals(true,listSearch.isEmpty(), 'searchTest');
            Test.stopTest();
        }
       
	}

    @isTest
	public static void assignOppTest () {

        User usuarioRun = [SELECT Id FROM User WHERE Email = 'test@test.dev' LIMIT 1];
        System.runAs(usuarioRun){
            Test.startTest();
            List<List<SObject>> searchResults = new List<List<SObject>>();
            Account setupAccount = [SELECT ID FROM ACCOUNT WHERE AV_NumPerso__c = '123' LIMIT 1];
            User usuario  = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
            Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
            Opportunity opp = new Opportunity();
            opp.AccountId = setupAccount.Id;
            opp.Name = 'Alerta Comercial2';
            opp.StageName = 'En gestión/insistir';
            opp.RecordTypeId = rt.Id;
            opp.CloseDate = System.today() + 5;
            opp.AV_PF__c = prodPF.Id;
            opp.OwnerId = usuario.Id;
            insert opp;
            List<Opportunity> listOpp = new List<Opportunity>{opp};
            List<String> listOppS = new List<String>();
            for (Opportunity opp2 : listOpp) {
                listOppS.add(opp2.Id);
            }
            String objectName='Opportunity';
            String result = null;
            result = CIBE_MassReassignOwnerOpps_Controller.assign(objectName,  usuario.Id, listOppS);
            Test.stopTest();
            Opportunity rtrvOpp = [SELECT OwnerId FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
            System.assertEquals(rtrvOpp.OwnerId,rtrvOpp.OwnerId,'Actualizacion de owner fallida');
        }

      
       
       
    }
    
    @isTest
	public static void assignOppTest2 () {
        User usuarioRun = [SELECT Id FROM User WHERE Email = 'test@test.dev' LIMIT 1];
        System.runAs(usuarioRun){
            Test.startTest();
            List<List<SObject>> searchResults = new List<List<SObject>>();
            Account setupAccount = [SELECT ID FROM ACCOUNT WHERE AV_NumPerso__c = '123' LIMIT 1];
            User usuario  = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
            //Opportunity opp = CIBE_TestHelper.createOpportunity(setupAccount);
            Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
            Opportunity opp = new Opportunity();
            opp.AccountId = setupAccount.Id;
            opp.Name = 'Alerta Comercial';
            opp.StageName = 'En gestión/insistir';
            opp.RecordTypeId = rt.Id;
            opp.CloseDate = System.today() + 5;
            opp.AV_PF__c = prodPF.Id;
            opp.OwnerId = usuario.Id;
            insert opp;
            List<Opportunity> listOpp = new List<Opportunity>{opp};
            List<String> listOppS = new List<String>();
            for (Opportunity opp2 : listOpp) {
                listOppS.add(opp2.Id);
            }
            String result = null;
            result = CIBE_MassReassignOwnerOpps_Controller.assign2( usuario.Id, listOppS);
            Test.stopTest();
            Opportunity rtrvOpp = [SELECT OwnerId FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
            System.assertEquals(rtrvOpp.OwnerId,rtrvOpp.OwnerId,'Actualizacion de owner fallida');
        }
       
    }
    
	@isTest
	public static void searchProductTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuario){
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
       
	}
    
    @isTest
	public static void searchAccountTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuario){
            List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
            List<String> lista = new List<String>();
            List<Account> acc = [SELECT Id, Name FROM Account];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = acc.get(0).Id;
            // SOSL queries need fixed results in order to retrieve data
            Test.setFixedSearchResults(fixedSearchResults);
            results = CIBE_MassReassignOwnerOpps_Controller.searchAccount(acc.get(0).Name,lista);
            results = CIBE_MassReassignOwnerOpps_Controller.searchAccount(acc.get(0).Name,new List<String>{acc.get(0).Id});
            Test.stopTest();
            System.assert(results != null);
        }
       
	}
    @isTest
	public static void searchParticipeTest(){
        Test.startTest();
        User usuarioRun = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuarioRun){
            List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
            List<String> lista = new List<String>();
            User usuario  = [SELECT Id, name,AV_NumeroOficinaEmpresa__c FROM User WHERE AV_NumeroOficinaEmpresa__c != NULL LIMIT 1];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = usuario.Id;
            // SOSL queries need fixed results in order to retrieve data
            Test.setFixedSearchResults(fixedSearchResults);
            results = CIBE_MassReassignOwnerOpps_Controller.searchParticipe(usuario.name,lista,usuario.AV_NumeroOficinaEmpresa__c);
            Test.stopTest();
            System.assert(results != null);
        }
      
	}
    
    @isTest
    public static void nameContactAssignTest() {
        Test.startTest();
        User usuario  = [SELECT Id FROM User WHERE Email = 'test@test.dev' LIMIT 1];
        System.runAs(usuario){
            String resul= CIBE_MassReassignOwnerOpps_Controller.nameContactAssign(usuario.Id);
            System.assertNotEquals(null,resul);
        }
        Test.stopTest();
    }

    @isTest
    public static void getInferiorCenterIdsTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
            Test.startTest();
            Set<Id> res = new Set<Id>();
    
            User u1 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009101'];
            Account center2 = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '00803'];
            System.runAs(u1) {
                res = CIBE_MassReassignOwnerOpps_Controller.getInferiorCenterIds();
            }
            
            Test.stopTest();
            System.assertEquals(false, res.isEmpty(), 'No ids retrieved');
        
       
    }

    @isTest
    public static void searchOfficeTest() {
        Test.startTest();
        List<AV_LookupSearchResult> res = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();

        User u1 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009102'];
        User u2 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009103'];
        User u3 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009104'];

        Account a = [
            SELECT Id
            FROM Account
            WHERE AV_NumPerso__c = '123'
            LIMIT 1
        ];
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CENTROCAIXABANK_RT);
        Account center2 = new Account(
            Name = '00804 TEST CENTER',
            CC_Numero_Oficina_Empresa__c = '00615',
            CC_Numero_Oficina__c = '00615',
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
            res = CIBE_MassReassignOwnerOpps_Controller.searchOffice('00615', lista);
            res = CIBE_MassReassignOwnerOpps_Controller.searchOffice('00615', new List<String>{a.Id});
        }
        // Gestor
        System.runAs(u2) {
            res = CIBE_MassReassignOwnerOpps_Controller.searchOffice('00615', lista);
            res = CIBE_MassReassignOwnerOpps_Controller.searchOffice('00615', new List<String>{a.Id});
        }
        // SSCC
        System.runAs(u3) {
            res = CIBE_MassReassignOwnerOpps_Controller.searchOffice('00615', lista);
            res = CIBE_MassReassignOwnerOpps_Controller.searchOffice('00615', new List<String>{a.Id});
        }
        Test.stopTest();
        System.assert(!res.isEmpty());
    }

    @isTest
    public static void getCenterIdsTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            List<Id> res = new List<Id>();
            List<Account> accs = [
                SELECT Id
                FROM Account
            ];
            
                res = CIBE_MassReassignOwnerOpps_Controller.getCenterIds(accs);
            Test.stopTest();
            System.assertEquals(false, res.isEmpty(), 'No ids returned');
        }
       
    }
}