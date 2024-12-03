/**********************************************************************************************************************
Name:	  AV_MassReassignOwnerOpps_Controller_Test
Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de "AV_MassReassignOwnerOpps_Controller"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION     USER_STORY              AUTHOR              DATE            Description
    1.0			US377759   		        Víctor Santiago 	24/05/2022		Init version
    1.1			US295471   		        Víctor Santiago 	15/07/2022		Mejorada cobertura + getInferiorCenterIdsTest
                                                                            searchOfficeTest + getCenterIdsTest 
    1.2         DE798963                Oscar Moreno        02/10/2023      Modify assignOppTest method                                                                     
***********************************************************************************************************************/
@isTest
public with sharing class AV_MassReassignOwnerOpps_Controller_Test {
      
    @TestSetup
	static void setup(){
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;
        AV_TestHelper.activateLogger();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'AV_Usuario_CaixaBank'];
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
        //insert usrOtraOficina;
        User usrTestApiOnly = AV_TestHelper.createUserSinInsert('API Only', null);
        User usrMiOficina = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank', null);
        usrMiOficina.AV_NumeroOficinaEmpresa__c = '13297'; //used in searchTestMiOficina
        insert new List<User>{usrOtraOficina, usrMiOficina, usrTestApiOnly};

		Account accTest = AV_TestHelper.createCustomerSinInsert();
		Account cenTest = AV_TestHelper.createCaixaCenterSinInsert();
        insert new List<Account>{accTest, cenTest};
		Contact conTest = AV_TestHelper.createEmployeeSinInsert(cenTest, usrOtraOficina);
        Contact conTest2 = AV_TestHelper.createEmployeeSinInsert(cenTest,usrMiOficina);
        insert new List<Contact>{conTest,conTest2};
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		      
		
	} 
    
	@isTest
	public static void getBaseDataOppsNullTest() {

        AV_MassReassignOwnerOpps_Controller.ObjectList ol = new AV_MassReassignOwnerOpps_Controller.ObjectList();
        String clientFilter = null;
        String subjectFilter = null;
        String origenFilter = 'AV_Iniciativa';
        String statusFilter = null;
        Date dueDate2Filter = null;
        Date dueDateFilter = null;
        List<String> employeeFilter = new List<String>();
        String[] filterList = null;
        Date fechaGestionFilter = null;
        Date fechaCierreFilter = null;
        String myBoxFilter = null;
        Boolean preconceivedFilter = null;
        String targetAutoFilter = null;
        String office = null;
        String potencial = null;
        Date fechaModif = null;
        List<String> indicadoresCli = new List<String>();
        String page = '1'; //needed for pagination
        List<User> usuario  = [Select Id,ProfileId From User LIMIT 3];
        Set<String> userIDs = new Set<String>();
        for(User u :usuario){
            userIDs.add(u.id);
        }
        employeeFilter.addAll(userIDs);
        
 		Test.startTest();   
        ol = AV_MassReassignOwnerOpps_Controller.getBaseData(clientFilter, subjectFilter, origenFilter, statusFilter, dueDate2Filter, dueDateFilter, employeeFilter, filterList, fechaCierreFilter, fechaGestionFilter, page, myBoxFilter, preconceivedFilter, targetAutoFilter, office,potencial,fechaModif,indicadoresCli);
       	System.assertEquals(true,ol.recordList.isEmpty(), 'getBaseDataOppsNullTest');
         ol = AV_MassReassignOwnerOpps_Controller.getBaseData(clientFilter, subjectFilter, 'all', statusFilter, dueDate2Filter, dueDateFilter, employeeFilter, filterList, fechaCierreFilter, fechaGestionFilter, page, myBoxFilter, preconceivedFilter, targetAutoFilter, office,potencial,fechaModif,indicadoresCli);
        Test.stopTest();
    }

    /**
     * Made to improve coverage
     */
    @isTest
	public static void getBaseDataOppsDatosTest() {
        Account a = [SELECT Id FROM Account LIMIT 1];
        AV_MassReassignOwnerOpps_Controller.ObjectList ol = new AV_MassReassignOwnerOpps_Controller.ObjectList();
        String objectName='Opportunity';
        String clientFilter = a.Id;
        String subjectFilter = 'Subject Test';
        String origenFilter = 'AV_Iniciativa';
        String statusFilter = 'En gestión/insistir';
        Date dueDate2Filter = null;
        Date dueDateFilter = null;
        String[] filterList = null;
        List<String> employeeFilter = new List<String>();
        Date fechaGestionFilter = System.today();
        Date fechaCierreFilter = System.today();
        String myBoxFilter = 'N';
        Boolean preconceivedFilter = true;
        String targetAutoFilter = 'N';
        String office = null;
        String potencial = null;
        Date fechaModif = null;
        List<String> indicadoresCli = new List<String>();
        String page = '1'; //needed for pagination
        Test.startTest();
        Contact c = [SELECT Id FROM Contact WHERE FirstName = 'Empleado' LIMIT 1];
        AV_TestHelper.createOpportunityWithEmpleado(a, c);
        User usuario  = [Select Id From User Where Email = 'test@test.dev' limit 1];
        employeeFilter.add(usuario.Id);
        ol = AV_MassReassignOwnerOpps_Controller.getBaseData(clientFilter, subjectFilter, origenFilter, statusFilter, dueDate2Filter, dueDateFilter, employeeFilter, filterList, fechaCierreFilter, fechaGestionFilter, page, myBoxFilter, preconceivedFilter, targetAutoFilter, office,potencial,fechaModif,indicadoresCli);
        System.assertEquals(true, ol!=null, 'getBaseDataOppsDatosTest');
        Test.stopTest();
    } 
  
	@isTest
	private static void getEmployeesTest() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User u = [SELECT Id FROM User WHERE AV_ProfileName__c = :AV_AppConstants.AV_PROFILE AND AV_NumeroOficinaEmpresa__c = '13297' LIMIT 1];
        Contact cntUser = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :u.Id];
        Account client = [SELECT Id FROM ACCOUNT WHERE CC_Numero_Documento__c = '9446386T'];

        AV_TestHelper.insertNeededPermissions(u);
        System.runAs(userGcf){
            
            Opportunity opp = AV_TestHelper.createOpportunityWithEmpleadoSinInsert(client,cntUser);
            opp.OwnerId = u.Id;
            insert opp;
            Account offi = [Select Id From Account where CC_Numero_Oficina__c = '00615'];
            update new Account(Id = offi.Id,OwnerId = u.Id);
        }

        System.runAs(u){
	
        List<AV_MassReassignOwnerOpps_Controller.optionsEmployee> employees = new List<AV_MassReassignOwnerOpps_Controller.optionsEmployee>();
        
        Test.startTest();
            Id[] fixedSearchResults = new Id[2];
            fixedSearchResults[0] = u.Id;
            fixedSearchResults[1] = userGcf.Id;
            Test.setFixedSearchResults(fixedSearchResults);
            String ofi = '00615';
            
            employees= AV_MassReassignOwnerOpps_Controller.getEmployees(ofi);
            Opportunity opp = [SELECT Id, StageName, AV_Center__c, RecordTypeId,RecordType.DeveloperName FROM Opportunity WHERE OwnerId = :u.Id];
            String oficinaData = opp.AV_Center__c+'{|}' + opp.StageName+'{|}'+ opp.RecordType.DeveloperName;
            employees= AV_MassReassignOwnerOpps_Controller.getEmployees(oficinaData);
            String oficinaData2 = '13297{|}' + opp.StageName+'{|}all';
            List<AV_MassReassignOwnerOpps_Controller.optionsEmployee> employees2= AV_MassReassignOwnerOpps_Controller.getEmployees(oficinaData2);
        System.assertEquals(true,!employees.isEmpty(), 'getEmployeesTest');
	}
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
            listSearch = AV_MassReassignOwnerOpps_Controller.search(searchTerm, lista, true);
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
            listSearch = AV_MassReassignOwnerOpps_Controller.search(searchTerm, lista, false);
            System.assertEquals(true, listSearch.isEmpty(), 'searchTest');
            Test.stopTest();
        }
	}
    
    @isTest
	public static void searchUserTest () {
        User userPass = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '13297' LIMIT 1];
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
	
		String searchTerm = '*';
		List<AV_LookupSearchResult> listSearch = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();

        Test.startTest();
        System.runAs(userPass){
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = userPass.Id;
            Test.setFixedSearchResults(fixedSearchResults);

        listSearch = AV_MassReassignOwnerOpps_Controller.searchUser(searchTerm, lista);
            System.assertEquals(true,!listSearch.isEmpty(), 'searchTest');
            lista.add(userGcf.Id);
            listSearch = AV_MassReassignOwnerOpps_Controller.searchUser(searchTerm, new List<String>{userGcf.Id});
        Test.stopTest();
	}
	}

    @isTest
	public static void assignOppTest () {
		List<List<SObject>> searchResults = new List<List<SObject>>();
        Account setupAccount = [SELECT ID FROM ACCOUNT LIMIT 1];
 
        Test.startTest();
        Opportunity opp = AV_TestHelper.createOpportunity(setupAccount);
        List<Opportunity> listOpp = new List<Opportunity>{opp};
        String objectName='Opportunity';	
        String result = null;
        User usuario  = [Select Id From User Where Alias = 'AV-TF9' limit 1];
        result = AV_MassReassignOwnerOpps_Controller.assign(objectName, usuario.Id, listOpp);
        Test.stopTest();
        Opportunity rtrvOpp = [SELECT OwnerId FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        System.assertEquals(rtrvOpp.OwnerId,usuario.Id,'Actualizacion de owner fallida');
    }	
    
	@isTest
	public static void searchProductTest(){

    	List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();
        Test.startTest();
        Product2 p2 = AV_TestHelper.createProduct(null, '1');
        Product2 p22 = AV_TestHelper.createProduct(null, '10');
        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = p2.Id;
        // SOSL queries need fixed results in order to retrieve data
        Test.setFixedSearchResults(fixedSearchResults);
        results = AV_MassReassignOwnerOpps_Controller.searchProduct(p2.Name,lista);
        results = AV_MassReassignOwnerOpps_Controller.searchProduct('*',new List<String>{p22.Id});
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
        results = AV_MassReassignOwnerOpps_Controller.searchAccount(acc.get(0).Name,lista);
        results = AV_MassReassignOwnerOpps_Controller.searchAccount(acc.get(0).Name,new List<String>{acc.get(1).Id});
        Test.stopTest();
        System.assert(results != null);
	}
    
    @isTest
    public static void nameContactAssignTest() {
        Test.startTest();
        User usuario  = [Select Id From User Where Email = 'test@test.dev' limit 1];
        String resul= AV_MassReassignOwnerOpps_Controller.nameContactAssign(usuario.Id);
        Test.stopTest();
        System.assertNotEquals(null,resul);
    }

    @isTest
    public static void gcfUserOnlyInGetBaseData() {
        String gcfId = (String)[SELECT ID FROM USER WHERE Alias = 'AV-TF9' LIMIT 1].Id;
        AV_MassReassignOwnerOpps_Controller.ObjectList ol = new AV_MassReassignOwnerOpps_Controller.ObjectList();
        String objectName='Task';
        String clientFilter = null;
        String subjectFilter = null;
        String origenFilter = 'AV_Iniciativa';
        String statusFilter = null;
        Date dueDate2Filter = null;
        Date dueDateFilter = null;
        String[] filterList = null;
        List<String> employeeFilter = new List<String>();
        employeeFilter.add(gcfId);
        Date fechaGestionFilter = null;
        Date fechaCierreFilter = null;
        String myBoxFilter = null;
        Boolean preconceivedFilter = null;
        String targetAutoFilter = null;
        String office = null;
        String potencial = null;
        Date fechaModif = null;
        List<String> indicadoresCli = new List<String>();
        String page = '1'; //needed for pagination
        Test.startTest();
        ol = AV_MassReassignOwnerOpps_Controller.getBaseData(clientFilter, subjectFilter, origenFilter, statusFilter, dueDate2Filter, dueDateFilter, employeeFilter, filterList, fechaCierreFilter, fechaGestionFilter, page, myBoxFilter, preconceivedFilter, targetAutoFilter, office,potencial,fechaModif,indicadoresCli);
        System.assertEquals(true, ol.recordList.isEmpty(), 'gcfUserInGetBaseData');
        Test.stopTest();
    }

    @isTest
    public static void gcfUserInGetBaseData() {
        String gcfId = (String) [SELECT Id FROM USER WHERE Alias = 'AV-TF9' LIMIT 1].Id;
        AV_MassReassignOwnerOpps_Controller.ObjectList ol = new AV_MassReassignOwnerOpps_Controller.ObjectList();
        String objectName='Task';
        String clientFilter = null;
        String subjectFilter = null;
        String origenFilter = 'AV_Iniciativa';
        String statusFilter = null;
        Date dueDate2Filter = null;
        Date dueDateFilter = null;
        String[] filterList = null;
        List<String> employeeFilter = new List<String>();
        employeeFilter.add(gcfId);
        Date fechaGestionFilter = null;
        Date fechaCierreFilter = null;
        String myBoxFilter = null;
        Boolean preconceivedFilter = null;
        String targetAutoFilter = null;
        String office = null;
        String potencial = null;
        Date fechaModif = null;
        List<String> indicadoresCli = new List<String>();

        String page = '1'; //needed for pagination
        Test.startTest();
        ol = AV_MassReassignOwnerOpps_Controller.getBaseData(clientFilter, subjectFilter, origenFilter, statusFilter, dueDate2Filter, dueDateFilter, employeeFilter, filterList, fechaCierreFilter, fechaGestionFilter, page, myBoxFilter, preconceivedFilter, targetAutoFilter, office,potencial,fechaModif,indicadoresCli);
        System.assertEquals(true, ol.recordList.isEmpty(), 'gcfUserInGetBaseData');
        Test.stopTest();
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
        RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_CTO_RT);
        Account center2 = new Account(
            Name = '00803 TEST CENTER',
            CC_Numero_Oficina_Empresa__c = '00803',
            CC_Numero_Oficina__c = '00803',
            RecordTypeId = rt.Id,
            AV_CentroSuperior__c = a.Id
        );
        insert center2;
        System.runAs(u1) {
            res = AV_MassReassignOwner_Controller.getInferiorCenterIds(u1);
        }
        
        Test.stopTest();
        System.assertEquals(false, res.isEmpty(), 'No ids retrieved');
    }



    @isTest 
    public static void getOfficePermissionTest(){
 
         User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
         User u = [SELECT Id FROM User WHERE AV_ProfileName__c = :AV_AppConstants.AV_PROFILE AND AV_NumeroOficinaEmpresa__c = '13297' LIMIT 1];
         AV_TestHelper.insertNeededPermissions(u);
         Account oficina1;
         Account oficina2;
         Account oficina3;
         Account oficina4;
         List<Id> officesIds = new List<Id>();
         List<Account> accountsJerarquia = new List<Account>();
         Map<String,Account> mapOfiAcc = new Map<String,Account>();
 
         System.runAs(userGcf){
             oficina1 = AV_TestHelper.createCaixaCenterSinInsert();
             oficina1.CC_Numero_Oficina__c = 'ofi1';
             oficina1.CC_Numero_Oficina_Empresa__c = 'ofi1';
             oficina1.Name = 'ofi1Name';
             // oficina1.OwnerId = u.Id;
 
             oficina2 = AV_TestHelper.createCaixaCenterSinInsert();
             oficina2.CC_Numero_Oficina__c = 'ofi2';
             oficina2.CC_Numero_Oficina_Empresa__c = 'ofi2';
             oficina2.Name = 'ofi2Name';
             // oficina2.OwnerId = u.Id;
 
             oficina3 = AV_TestHelper.createCaixaCenterSinInsert();
             oficina3.CC_Numero_Oficina__c = 'ofi3';
             oficina3.CC_Numero_Oficina_Empresa__c = 'ofi3';
             oficina3.Name = 'ofi3Name';
             // oficina3.OwnerId = u.Id;
 
             oficina4 = AV_TestHelper.createCaixaCenterSinInsert();
             oficina4.CC_Numero_Oficina__c = 'ofi4';
             oficina4.CC_Numero_Oficina_Empresa__c = 'ofi4';
             oficina4.Name = 'ofi4Name';
             // oficina4.OwnerId = u.Id;
                  
        Test.startTest();

         insert new List<Account>{oficina1,oficina2,oficina3,oficina4};
         accountsJerarquia = [SELECT Id,CC_Numero_Oficina__c FROM Account WHERE CC_Numero_Oficina__c IN ('ofi1','ofi2','ofi3','ofi4')];
         for(Account acc : accountsJerarquia){
             mapOfiAcc.put(acc.CC_Numero_Oficina__c,acc);
         }
         mapOfiAcc.get('ofi1').AV_CentroSuperior__c = mapOfiAcc.get('ofi2').Id; 
         mapOfiAcc.get('ofi1').OwnerId = u.Id; 
         mapOfiAcc.get('ofi2').AV_CentroSuperior__c = mapOfiAcc.get('ofi3').Id; 
         mapOfiAcc.get('ofi2').OwnerId = u.Id; 
         mapOfiAcc.get('ofi3').AV_CentroSuperior__c = mapOfiAcc.get('ofi4').Id; 
         mapOfiAcc.get('ofi3').OwnerId = u.Id; 
         mapOfiAcc.get('ofi4').OwnerId = u.Id; 
         
         for(Account acc : accountsJerarquia){
             // acc.OwnerId = u.Id;
             // if(acc.CC_Numero_Oficina__c != 'ofi1'){
                 officesIds.add(acc.Id);
             // }
         }
         update new List<Account>{
         mapOfiAcc.get('ofi1'),
         mapOfiAcc.get('ofi2'),
         mapOfiAcc.get('ofi3'),
         mapOfiAcc.get('ofi4')
         };
         Test.stopTest();

         // update new List<Account>{oficina1,oficina2,oficina3,oficina4};
         
     }
         
         System.runAs(u){
             Id result = AV_MassReassignOwner_Controller.getOfficePermission(officesIds,oficina1);
             Id result2 = AV_MassReassignOwner_Controller.getOfficePermission(new List<String>{(String) mapOfiAcc.get('ofi1').Id},oficina1);
 
             System.assert(result != null);
 
         }
 
 
 
 
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
        // insert u1;
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
        // insert u2;
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
        // insert u3;
        insert new List<User>{u1,u2,u3};
        Account a = [
            SELECT Id
            FROM Account
            WHERE CC_Numero_Oficina__c = '00615'
            LIMIT 1
        ];
        RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_CTO_RT);
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
            res = AV_MassReassignOwnerOpps_Controller.searchOffice('00804', lista);
            res = AV_MassReassignOwnerOpps_Controller.searchOffice('00804', new List<String>{a.Id});
        }
        // Gestor
        System.runAs(u2) {
            res = AV_MassReassignOwnerOpps_Controller.searchOffice('00804', lista);
            res = AV_MassReassignOwnerOpps_Controller.searchOffice('00804', new List<String>{a.Id});
        }
        // SSCC
        System.runAs(u3) {
            res = AV_MassReassignOwnerOpps_Controller.searchOffice('00804', lista);
            res = AV_MassReassignOwnerOpps_Controller.searchOffice('00804', new List<String>{a.Id});
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
        res = AV_MassReassignOwnerOpps_Controller.getCenterIds(accs);
        Test.stopTest();
        System.assertEquals(false, res.isEmpty(), 'No ids returned');
    }

    @isTest 
    public static void goverGetIndicadorCliOptions(){
        Test.startTest();
        List<Map<String,String>> optionsCli = AV_MassReassignOwnerOpps_Controller.getIndicadorCliOptions();
        Test.stopTest();
        System.assert(!optionsCli.isEmpty());
    }
}