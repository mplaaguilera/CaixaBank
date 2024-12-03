/**********************************************************************************************************************
Name:	  AV_MassReassignOwner_Controller_Test
Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de "AV_MassReassignOwner_Controller"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION     USER_STORY              AUTHOR              DATE            Description
    1.0         Home Custom             Manuel Hernando     28/04/2021      Init version
    1.1         FIX         		    Sandra Gómez        20/05/2021      Add method nameContactAssignTest and searchAccountTest
	1.2			FIX						Sandra Gómez		26/08/2021		Fix product opportunity
	1.3			US268502				Daniel Rodriguez	01/02/2022		Add method searchUser for report Opportunity
    1.4			AV_Query IT		        Daniel Rodríguez	3/02/2022		Change AV_Query to SOQL for User and Account
    1.5			US293288   		        Víctor Santiago 	11/02/2022		Add/change methods searchTestMiOficina and searchTestOtraOficina
    1.6			US377759   		        Víctor Santiago 	25/05/2022		Added getInferiorCenterIdsTest, searchOfficeTest, getCenterIdsTest
    1.7         US430868                Luis Fernández      19/08/2022      Added assertEquals to methods that does not have
    1.8			FIX					    Patricia Villacañas	26/05/2023		Modified to set run as
***********************************************************************************************************************/
@isTest
public with sharing class AV_MassReassignOwner_Controller_Test {
  
    @TestSetup
	static void setup(){
        
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;
        AV_TestHelper.activateLogger();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'AV_Usuario_CaixaBank'];
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        
        
        List<User> usersList = new List<User>();
        User usrOtraOficina = new User(
            AV_ExternalID__c = 'U0009826',
            Alias = 'tsAlias',
            Email = 'test@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '00615',//12345
            ProfileId = p.Id,
            UserName = 'test@test.dev.devsfc01',
            IsActive = true,
            AV_Funcion__c = 'DT'
        );
        User usrMiOficina;
        System.runAs(userGcf){
            //insert usrOtraOficina;
            usersList.add(usrOtraOficina);
            usrMiOficina = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','');
            usrMiOficina.AV_NumeroOficinaEmpresa__c = '13297'; //used in searchTestMiOficina
            usersList.add(usrMiOficina);
            //update usrMiOficina;
            Account accTest = AV_TestHelper.createCustomer(); 
            User usrTestApiOnly = AV_TestHelper.createUserSinInsert('API Only','');
            usersList.add(usrTestApiOnly);
            insert usersList;
            
            Account cenTest = AV_TestHelper.createCaixaCenter();
            Contact conTest = AV_TestHelper.createEmployeeSinInsert(cenTest, usrOtraOficina);
            Contact usrMiOtraOfincaCnt = AV_TestHelper.createEmployeeSinInsert(cenTest,usrMiOficina);
            insert new List<Contact>{conTest,usrMiOtraOfincaCnt};
        
        }

        AV_MassReassignOwner_Controller.OptionsEmployee p1 = new AV_MassReassignOwner_Controller.OptionsEmployee('value1','label1');
        AV_MassReassignOwner_Controller.OptionsEmployee p2 = new AV_MassReassignOwner_Controller.OptionsEmployee('value2','label2');
        p1.compareTo(p1);
        p2.compareTo(p1);
        p1.compareTo(p2);
        AV_MassReassignOwner_Controller.OptionsOffice p3 = new AV_MassReassignOwner_Controller.OptionsOffice('value2','label2','code');

        
        
        
        
	}   
  
	@isTest
	public static void getBaseDataTaskDatosTest() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User usuario  = [Select Id, AV_NumeroOficinaEmpresa__c From User Where Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009826' limit 1];
        Test.startTest();
    
        AV_TestHelper.insertNeededPermissions(usuario);
        AV_MassReassignOwner_Controller.ObjectList listTasks;
        Task tsk = new Task();
        
        System.runAs(usuario){
            AV_MassReassignOwner_Controller.ObjectList ol = new AV_MassReassignOwner_Controller.ObjectList();
            String objectName='Task';
            String[] statusFilter = new String[]{'Open'};
            String page = '1'; //needed for pagination
            tsk = AV_TestHelper.createTarea(usuario);
            tsk.OwnerId = usuario.Id;
            String[] employeeFilter = new String[]{usuario.Id};
            List<Task> listTask = [SELECT AV_CenterRtIndex__c, OwnerId FROM Task WHERE Id = :tsk.id];
            listTasks =  AV_MassReassignOwner_Controller.getBaseData(objectName, null, null, 'Iniciativa Gestor/a', statusFilter, null, null, employeeFilter, null, null, null, page, null, null, null, usuario.AV_NumeroOficinaEmpresa__c);
        }
        Test.stopTest();
        System.assertEquals(true, !listTasks.isEmpty(), 'getBaseDataOppsDatosTest');
    }   
    
 
	@isTest
	private static void getEmployeesTest() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User u = [SELECT Id FROM User WHERE AV_ProfileName__c = :AV_AppConstants.AV_PROFILE AND AV_NumeroOficinaEmpresa__c = '13297' LIMIT 1];
        AV_TestHelper.insertNeededPermissions(u);
        Account client = [SELECT Id FROM ACCOUNT WHERE CC_Numero_Documento__c = '9446386T'];
        Test.startTest();
        List<AV_MassReassignOwner_Controller.optionsEmployee> employees = new List<AV_MassReassignOwner_Controller.optionsEmployee>();
        System.runAs(userGcf){
            
            Task tU = AV_TestHelper.createTarea(u);
            Account offi = [Select Id From Account where CC_Numero_Oficina__c = '00615'];
            update new Account(Id = offi.Id,OwnerId = u.Id);
        }
        System.runAs(u){
            String ofi = '00615';
            
            AV_MassReassignOwner_Controller.getEmployees('');
            Id[] fixedSearchResults = new Id[2];
            fixedSearchResults[0] = u.Id;
            fixedSearchResults[1] = userGcf.Id;
            Test.setFixedSearchResults(fixedSearchResults);

            employees= AV_MassReassignOwner_Controller.getEmployees(ofi);
            Task t = [SELECT Id, Status, AV_Origen__c, RecordTypeId,RecordType.DeveloperName,AV_CenterRtIndex__c FROM Task WHERE OwnerId = :u.Id];
            update new Task(Id = t.Id,AV_Center__c = '13297');
            Task t1 = [SELECT AV_CenterRtIndex__c FROM Task WHERE Id = :t.Id];
            String oficinaData = '13297{|}' + t.Status+'{|}'+ t.RecordType.DeveloperName;
            employees= AV_MassReassignOwner_Controller.getEmployees(oficinaData);
        }
        
        System.assertEquals(true,!employees.isEmpty(), 'getEmployeesTest');
        Test.stopTest();
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
        Test.startTest();
        System.runAs(userGcf){
            oficina1 = AV_TestHelper.createCaixaCenterSinInsert();
            oficina1.CC_Numero_Oficina__c = 'ofi1';
            oficina1.CC_Numero_Oficina_Empresa__c = 'ofi1';
            oficina1.Name = 'ofi1Name';

            oficina2 = AV_TestHelper.createCaixaCenterSinInsert();
            oficina2.CC_Numero_Oficina__c = 'ofi2';
            oficina2.CC_Numero_Oficina_Empresa__c = 'ofi2';
            oficina2.Name = 'ofi2Name';

            oficina3 = AV_TestHelper.createCaixaCenterSinInsert();
            oficina3.CC_Numero_Oficina__c = 'ofi3';
            oficina3.CC_Numero_Oficina_Empresa__c = 'ofi3';
            oficina3.Name = 'ofi3Name';

            oficina4 = AV_TestHelper.createCaixaCenterSinInsert();
            oficina4.CC_Numero_Oficina__c = 'ofi4';
            oficina4.CC_Numero_Oficina_Empresa__c = 'ofi4';
            oficina4.Name = 'ofi4Name';
        
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
                officesIds.add(acc.Id);
        }

        update new List<Account>{
        mapOfiAcc.get('ofi1'),
        mapOfiAcc.get('ofi2'),
        mapOfiAcc.get('ofi3'),
        mapOfiAcc.get('ofi4')
    };
        
    }
        
        System.runAs(u){
            Id result = AV_MassReassignOwner_Controller.getOfficePermission(officesIds,oficina1);
            Id result2 = AV_MassReassignOwner_Controller.getOfficePermission(new List<String>{(String) mapOfiAcc.get('ofi4').Id},mapOfiAcc.get('ofi4'));

            System.assert(result != null);

        }
    Test.stopTest();




    } 
    @isTest
	public static void searchTestMiOficina() {
		String searchTerm = 'test';
		List<AV_LookupSearchResult> listSearch = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();
        User userPass = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '13297' LIMIT 1];
        System.runAs(userPass) {
            User emp  = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
            User empMiOficina = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '13297' LIMIT 1];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = empMiOficina.Id;
            // SOSL queries need fixed results in order to retrieve data
            Test.setFixedSearchResults(fixedSearchResults);
            Test.startTest();
            listSearch = AV_MassReassignOwner_Controller.search(searchTerm, lista, true);
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
            User emp  = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
            User empOtraOficina = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c != '13297' LIMIT 1];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = empOtraOficina.Id;
            // SOSL queries need fixed results in order to retrieve data
            Test.setFixedSearchResults(fixedSearchResults);
            Test.startTest();
            User u = [
                SELECT Id
                FROM User
                WHERE Id != :empOtraOficina.Id
                LIMIT 1
            ];
            listSearch = AV_MassReassignOwner_Controller.search(searchTerm, lista, true);
            System.assert(listSearch.isEmpty());
            listSearch = AV_MassReassignOwner_Controller.search(searchTerm, new List<String>{u.Id}, false);
            System.assert(listSearch.isEmpty());
            Test.stopTest();
        }
	}
    
    @isTest
	public static void searchUserTest () {
		String searchTerm = '*';
		List<AV_LookupSearchResult> listSearch = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Test.startTest();
        System.runAs(userGcf){
    
        User u = [SELECT Id FROM User WHERE AV_ProfileName__c = :AV_AppConstants.AV_PROFILE AND AV_NumeroOficinaEmpresa__c = '001-03044' LIMIT 1];
        User u2 = [SELECT Id FROM User WHERE AV_ProfileName__c = :AV_AppConstants.AV_PROFILE AND AV_NumeroOficinaEmpresa__c = '001-03044' AND Id != :u.Id LIMIT 1];

        
        Id[] fixedSearchResults = new Id[2];
        fixedSearchResults[0] = u.Id;
        fixedSearchResults[1] = u2.Id;
        // SOSL queries need fixed results in order to retrieve data
        Test.setFixedSearchResults(fixedSearchResults);
        listSearch = AV_MassReassignOwner_Controller.searchUser(searchTerm, lista);
        System.assert(!listSearch.isEmpty());
        listSearch = AV_MassReassignOwner_Controller.searchUser(searchTerm, new List<String>{u2.Id});
        }
        Test.stopTest();
	}

    @isTest
	public static void assignOppTest () {
		List<List<SObject>> searchResults = new List<List<SObject>>();
        Task opp = AV_TestHelper.createTarea(null);
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Test.startTest();
        System.runAs(userGcf){
        List<Task> listOpp = new List<Task>{opp};
        String objectName='Opportunity';	
        String result = null;
        User usuario  = [Select Id From User Where Email = 'test@test.dev' limit 1];
        result = AV_MassReassignOwner_Controller.assign(objectName, usuario.Id, listOpp);
        Test.stopTest();
        System.assertEquals(result,'1');
        }
    }	

    @isTest
	public static void assignTaskTest () {
		List<List<SObject>> searchResults = new List<List<SObject>>();
        Task tsk = AV_TestHelper.createTarea(null);
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Test.startTest();
        System.runAs(userGcf){
        List<Task> listTask = new List<Task>{tsk};
        String objectName='Task';	
        String result = null;
        User usuario  = [Select Id From User Where Email = 'test@test.dev' limit 1];
        result = AV_MassReassignOwner_Controller.assign(objectName, usuario.Id, listTask);
        Test.stopTest();
        System.assertEquals(result,'1');
        }
    }
    
    @isTest
	public static void searchAccountTest(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Test.startTest();
        System.runAs(userGcf){
    	List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();
        List<Account> acc = [Select Id, Name From Account];
        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = acc.get(0).Id;
        // SOSL queries need fixed results in order to retrieve data
        Test.setFixedSearchResults(fixedSearchResults);
        results = AV_MassReassignOwner_Controller.searchAccount(acc.get(0).Name,lista);
        results = AV_MassReassignOwner_Controller.searchAccount(acc.get(0).Name,new List<String>{acc.get(1).Id});
        Test.stopTest();
        System.assert(!results.isEmpty());
        }
	}
    
    @isTest
    public static void nameContactAssignTest() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Test.startTest();
        System.runAs(userGcf){
        User usuario  = [Select Id From User Where Email = 'test@test.dev' limit 1];
        String resul= AV_MassReassignOwner_Controller.nameContactAssign(usuario.Id);
        Test.stopTest();
        System.assertNotEquals(null,resul);
        }
    }

    @isTest
    public static void gcfUserOnlyInGetBaseData() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Test.startTest();
        System.runAs(userGcf){

        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Iniciativa Gestor/a').getRecordTypeId();

        User gcf = [SELECT ID FROM USER WHERE ALIAS = 'AV-TF9' LIMIT 1];
        String gcfId = (String) gcf.Id;
        AV_MassReassignOwner_Controller.ObjectList ol = new AV_MassReassignOwner_Controller.ObjectList();
        String objectName='Task';
        Account acc = AV_TestHelper.createCustomerSinInsert();
        Account center = AV_TestHelper.createCaixaCenterSinInsert();
        center.CC_Numero_Oficina__c = '93124';
        center.Name = 'centro test';
		center.CC_Numero_Oficina_Empresa__c = '001-93124';
        insert center;
        acc.AV_MyBox__c = 'S';
        acc.AV_IsPreconceived__c = false;
        acc.AV_TargetAuto__c = 'S';
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
        acc.FirstName = 'FirstName3';
		acc.LastName = 'LastName3';
		acc.RecordTypeId = rt.Id;
		acc.AV_NumPerso__c = '121';
		acc.AV_Negocio__c = 'BPA';
        acc.CC_Numero_Documento__c = '1446382T';
        acc.AV_OficinaPrincipal__c= center.id;
        Database.insert(acc);
        Task tskToRetrieve = AV_TestHelper.createTarea(gcf);
        tskToRetrieve.AV_Center__c = '93124';
        tskToRetrieve.WhatId = acc.Id;
        tskToRetrieve.status = 'Open';
        tskToRetrieve.AV_CenterRtIndex__c = '93124-' + taskRecordTypeId;
        Database.update(tskToRetrieve);
        String page = '1'; //needed for pagination
        String[] employeeFilter = new String[]{gcfId};
        String[] statusFilter = new String[]{'Open'};
       	ol = AV_MassReassignOwner_Controller.getBaseData(objectName, null, null, 'Iniciativa Gestor/a', statusFilter, null, null, employeeFilter, null, null, null, page, 'S', false, 'S','93124');
        System.assertEquals(true, !ol.isEmpty(), 'gcfUserInGetBaseData');
        }
        Test.stopTest();
    }

    @isTest
    public static void gcfUserInGetBaseData() {

        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Iniciativa Gestor/a').getRecordTypeId();

        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Test.startTest();
        System.runAs(userGcf){
        User usuario  = [Select Id From User Where Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009826' limit 1];
        String gcfId = (String) [SELECT ID FROM USER WHERE ALIAS = 'AV-TF9' LIMIT 1].Id;
        AV_MassReassignOwner_Controller.ObjectList ol = new AV_MassReassignOwner_Controller.ObjectList();
        Task tskToRetrieve = AV_TestHelper.createTarea(userGcf);
        Account acc = AV_TestHelper.createCustomerSinInsert();
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
        acc.AV_IsPreconceived__c = true;
                acc.FirstName = 'FirstName1';
				acc.LastName = 'LastName1';
				acc.RecordTypeId = rt.Id;
				acc.AV_NumPerso__c = '122';
				acc.AV_Negocio__c = 'BPA';
            	acc.CC_Numero_Documento__c = '9446382T';
        Database.insert(acc);
        tskToRetrieve.AV_Center__c = '00123';
        tskToRetrieve.subject = 'Tarea';
        tskToRetrieve.activityDate = Date.today();
        tskToRetrieve.WhatId = acc.id;
        Database.update(tskToRetrieve);
        String objectName='Task';
        String page = '1'; //needed for pagination
        String[] employeeFilter = new String[]{gcfId,usuario.Id};
		String[] statusFilter = new String[]{'Open'};
       	ol = AV_MassReassignOwner_Controller.getBaseData(objectName, null, 'Tare', 'Iniciativa Gestor/a', statusFilter, Date.today().addDays(1), Date.today().addDays(-1), employeeFilter, null, null, null, page, 'N', true, 'N', '00120');
		Test.stopTest();
        System.assertEquals(false, !ol.isEmpty(), 'gcfUserInGetBaseData');
        }
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
            res = AV_MassReassignOwner_Controller.searchOffice('00804', lista);
            res = AV_MassReassignOwner_Controller.searchOffice('00804', new List<String>{a.Id});
            System.assert(!res.isEmpty());
        }
        // Gestor
        System.runAs(u2) {
            res = AV_MassReassignOwner_Controller.searchOffice('00804', lista);
            res = AV_MassReassignOwner_Controller.searchOffice('00804', new List<String>{a.Id});
            System.assert(res.isEmpty());
        }
        // SSCC
        System.runAs(u3) {
            res = AV_MassReassignOwner_Controller.searchOffice('00804', lista);
            res = AV_MassReassignOwner_Controller.searchOffice('00804', new List<String>{a.Id});
            System.assert(!res.isEmpty());
        }
        Test.stopTest();
    }

    @isTest
    public static void getCenterIdsTest() {
        List<Id> res = new List<Id>();
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Test.startTest();
        System.runAs(userGcf){
        List<Account> accs = [
            SELECT Id
            FROM Account
        ];
        res = AV_MassReassignOwner_Controller.getCenterIds(accs);
        }
        Test.stopTest();
        System.assertEquals(false, res.isEmpty(), 'No ids returned');
    }
    
    @isTest
	public static void getBaseDataNotAssigned() {
           
        User userPass = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '13297' LIMIT 1];
        AV_MassReassignOwner_Controller.ObjectList ol = new AV_MassReassignOwner_Controller.ObjectList();
        String objectName='Task';
        String[] statusFilter = new String[]{'Open'};
        User usuario  = [Select Id From User Where Email = 'test@test.dev' AND AV_ExternalID__c = 'U0009826' limit 1];
        String page = '1'; //needed for pagination
        Task tsk = AV_TestHelper.createTarea(usuario);
        String[] employeeFilter = new String[]{usuario.Id};
        Test.startTest();
        System.runAs(userPass) {

        	AV_MassReassignOwner_Controller.ObjectList listTasks =  AV_MassReassignOwner_Controller.getBaseData(objectName, null, null, 'notAssigned', statusFilter, null, null, employeeFilter, null, null, null, page, null, null, null, null);

        System.assertEquals(false, !listTasks.isEmpty(), 'getBaseDataNotAssigned');
        }
       	Test.stopTest();
    } 

    
    
    
    
}