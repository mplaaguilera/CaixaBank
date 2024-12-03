/**********************************************************************************************************************
 Name:      AV_BuscadorClientes_Controller_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test class for AV_BuscadorClientes_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION		USER_STORY			AUTHOR				DATE		Description
   	1.0			US295559			Víctor Santiago		09/08/2022	Init version
    1.1			Fix					Sandra Gómez		01/12/2022	Error queries and whitout
    1.2         US493064            Elisabeth Rodríguez 21/12/2022  Modified getBooksTest
    1.3         US493064            Luis Fernández      12/01/2022  Fixed Test and augmented coverture
	1.4								Vladislav Lityagin  09/03/2023	Fixed Quality Clouds errors
    1.5         Fix                 Patricia Villacañas 16/05/2023  Modified to set run as

***********************************************************************************************************************/
@isTest
public with sharing class AV_BuscadorClientes_Controller_Test {
    
    @TestSetup
	static void setup(){
        
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545400', 'AV_SistematicaComercial');

            System.runAs(userGcf){
            List<User> usrList = new List<User>();
            //Profile p = [SELECT Id FROM Profile WHERE Name = 'AV_Usuario_CaixaBank'];
            List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'System Administrator\' LIMIT 1');
		    Profile p = (Profile) result.get(0);
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
                AV_Funcion__c = 'DC'
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
                AV_Funcion__c = 'DT'
            );
            // insert u3;
        User u4 = new User(
            Alias = 'u2',
            Email = 'test2@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '00615',
            ProfileId = p.Id,
            UserName = 'testu5@test.dev',
            AV_ExternalID__c = 'U0009105',
            IsActive = true,
            AV_Funcion__c = 'Gestor'
        );
        // insert u4;
        User u5 = new User(
            Alias = 'u3',
            Email = 'test3@test.dev',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '00615',
            ProfileId = p.Id,
            UserName = 'testu6@test.dev',
            AV_ExternalID__c = 'U0009106',
            IsActive = true,
            AV_Funcion__c = 'SSCC'
        );
            usrList.add(userGestor);
            usrList.add(usrOtraOficina);
            usrList.add(u1);
            usrList.add(u2);
            usrList.add(u3);
            usrList.add(u4);
            usrList.add(u5);
            insert usrList;
            List<Account> accList = new List<Account>();
            Account cenTest = AV_TestHelper.createCaixaCenter();
            Contact conTest = AV_TestHelper.createEmployee(cenTest, usrOtraOficina);
			Account accTest = AV_TestHelper.createCustomerSinInsert();            
            accTest.AV_EAPGestor__C  = conTest.Id;
            accList.add(accTest);
            RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_CTO_RT);
            Account center2 = new Account(
                Name = '00803 TEST CENTER',
                CC_Numero_Oficina_Empresa__c = '00803',
                CC_Numero_Oficina__c = '00803',
                RecordTypeId = rt.Id,
                AV_CentroSuperior__c = cenTest.Id,
                AV_Financiacion__c = 100,
                AV_Rentabilidad__c = 70,
                AV_AhorroEInversion__c = 60,
                AV_Satisfaccion__c = AV_AppConstants.ZERO,
                AV_Preconceived__c = 10
            );
            accList.add(center2);
            Account center3 = new Account(
                Name = '00804 TEST CENTER',
                CC_Numero_Oficina_Empresa__c = '00804',
                CC_Numero_Oficina__c = '00804',
                RecordTypeId = rt.Id,
                AV_CentroSuperior__c = cenTest.Id
            );
            accList.add(center3);
            insert accList;
            
            AV_Book__c car = AV_TestHelper.createPurse('00001EAP001');
            AV_TestHelper.createBookMember(accTest, car);
            AV_TestHelper.createBookManagement(conTest, car);
        }
	}
    
    @isTest
	public static void getBaseDataTestWithBook() {
        AV_BuscadorClientes_Controller.ObjectList ol = new AV_BuscadorClientes_Controller.ObjectList();
        AV_BuscadorClientes_Controller.ObjectList ol2 = new AV_BuscadorClientes_Controller.ObjectList();
        String page = '1'; //needed for pagination

        User usrOtraOficina = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '12345'];
        AV_Book__c car = [SELECT Id FROM AV_Book__c WHERE AV_ExternalID__c = '00001EAP001'];
        
 		Test.startTest();   
        System.runAs(usrOtraOficina){
            ol = AV_BuscadorClientes_Controller.getBaseData(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, page, null,null);
            ol2 = AV_BuscadorClientes_Controller.getBaseData(null, null, new List<String>{UserInfo.getUserId()}, car.Id, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, page, null, null);
        }
        Test.stopTest();
        System.assert(!ol.recordList.isEmpty(), 'getBaseDataOppsNullTest');
       
    }
    @isTest
	public static void getBaseDataTest() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
            AV_BuscadorClientes_Controller.ObjectList ol = new AV_BuscadorClientes_Controller.ObjectList();
            
            String office = '001-00001';
            String negocio = 'BPA';
            List<String> employeeFilter = new List<String>();
            String cartera = 'carteraId';
            String modelo = 'A';
            String edadMin = '18';
            String edadMax = '100';
            String ingresosMin = '0';
            String ingresosMax = '100000';
            String ahorroMin = '0';
            String ahorroMax = '10000';
            String financiacionMin = '0';
            String financiacionMax = '120';
            String rentabilidadMin = '0';
            String rentabilidadMax = '120';
            String exp = '1';
            String mybox = 'N';
            String preconMin = '1';
            String preconMax = '123456';
            String targetAuto = 'N';
            String page = '1'; //needed for pagination
            String grupo = 'Miembro';
            String interlocName = 'Nombre';
            User usuario  = [Select Id From User Where Email = 'test@test.dev' limit 1];
            employeeFilter.add(usuario.Id);
            
            AV_Book__c car = [SELECT Id FROM AV_Book__c WHERE AV_ExternalID__c = '00001EAP001'];
            
            Test.startTest();   
            ol = AV_BuscadorClientes_Controller.getBaseData(office, negocio, employeeFilter, cartera, modelo, edadMin, edadMax, ingresosMin, ingresosMax, ahorroMin, ahorroMax, financiacionMin, financiacionMax, rentabilidadMin, rentabilidadMax, exp, mybox, preconMin, preconMax, targetAuto, page, grupo, interlocName);
            Test.stopTest();
            System.assertEquals(true,ol.recordList.isEmpty(), 'getBaseDataOppsNullTest');
        }
    }



    @isTest
	private static void getEmployeesTest() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
            List<AV_BuscadorClientes_Controller.optionsEmployee> employees = new List<AV_BuscadorClientes_Controller.optionsEmployee>();
            Test.startTest();
            employees= AV_BuscadorClientes_Controller.getEmployees('00615');
            Test.stopTest();
            System.assertEquals(true,!employees.isEmpty(), 'getEmployeesTest');
        }
	}

    @isTest
    public static void searchOfficeTest() {
        List<AV_LookupSearchResult> res = new List<AV_LookupSearchResult>();
        List<String> lista = new List<String>();
        Test.startTest();
        List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'System Administrator\' LIMIT 1');
        User u1 = [SELECT Id, AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U0009102'];
        User u2 = [SELECT Id, AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U0009105'];
        User u3 = [SELECT Id, AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U0009106'];

        Account center2 = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c='00804'];
        Account a = [
            SELECT Id
            FROM Account
            WHERE CC_Numero_Oficina__c = '00615'
            LIMIT 1
        ];
        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = center2.Id;
        // SOSL queries need fixed results in order to retrieve data
        Test.setFixedSearchResults(fixedSearchResults);
        // Director
        System.runAs(u1) {
            res = AV_BuscadorClientes_Controller.searchOffice('00804', lista);
            res = AV_BuscadorClientes_Controller.searchOffice('00804', new List<String>{a.Id});
        }
        // Gestor
        System.runAs(u2) {
            res = AV_BuscadorClientes_Controller.searchOffice('00804', lista);
            res = AV_BuscadorClientes_Controller.searchOffice('00804', new List<String>{a.Id});
        }
        // SSCC
        System.runAs(u3) {
            res = AV_BuscadorClientes_Controller.searchOffice('00804', new List<String>{a.Id});
            res = AV_BuscadorClientes_Controller.searchOffice('00804', lista);
        }
        Test.stopTest();
        system.assertEquals(true, res.size()>0);
    }

    @isTest
	private static void getBooksTest() {
	    Test.startTest();
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
            List<AV_BuscadorClientes_Controller.OptionsBook> books = new List<AV_BuscadorClientes_Controller.OptionsBook>();
            Account accTest = [SELECT Id FROM ACCOUNT WHERE CC_Numero_Documento__c = '9446386T'];
            User usrOtraOficina = [SELECT Id FROM User WHERE AV_NumeroOficinaEmpresa__c = '12345'];
            Contact conTest = [SELECT Id FROM Contact LIMIT 1];
            accTest.AV_EAPGestor__C  = conTest.Id;
            update accTest;
            AV_Book__c car = [SELECT Id FROM AV_Book__c WHERE AV_ExternalID__c = '00001EAP001'];
            
            books = AV_BuscadorClientes_Controller.getBooks(usrOtraOficina.Id);
        	Test.stopTest();
            System.assert(!books.isEmpty(), 'Book not found');
        }
	}

    @isTest
    private static void mapClientDataTest() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
            List<AV_BuscadorClientes_Controller.ClientData> data = new List<AV_BuscadorClientes_Controller.ClientData>();
            Test.startTest();
            List<Account> accs = [
                SELECT Id,Name,CC_Numero_Documento__c,AV_Age__c,AV_Ingresos__c,AV_AhorroEInversion__c,AV_Financiacion__c,AV_Rentabilidad__c,AV_Vinculacion__c,AV_Satisfaccion__c,AV_EAPGestor__c,AV_EAPGestor__r.Name,Owner.AV_NumeroOficinaEmpresa__c,AV_Preconceived__c,AV_AttentionModel__c,AV_Negocio__c,AV_MyBox__c,AV_TargetAuto__c, AV_Group__c, AV_InterlocName__c
                FROM Account
            ];
            List<AV_BookMember__c> bm = [
                SELECT Id, AV_Cliente__c
                FROM AV_BookMember__c
            ];
            data = AV_BuscadorClientes_Controller.mapClientData(accs, bm, null);
            Test.stopTest();
            System.assertNotEquals(null, data, 'Client data not found');
        }
    }

    @isTest
    public static void getCenterIdsTest() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
            List<Id> res = new List<Id>();
            List<Account> accs = [
                SELECT Id
                FROM Account
            ];
            Test.startTest();
            res = AV_BuscadorClientes_Controller.getCenterIds(accs);
            Test.stopTest();
            System.assertEquals(false, res.isEmpty(), 'No ids returned');
        }
    }
}