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
    1.6         DE85269             Gonzalo Ávila       07/12/2023  Modified searchOfficeTest method. 
    1.7          QC                Oscar Moreno        12/06/2024       Delete UserInfo.geetUserId()
    1.8        IN1180012          Oscar Moreno         11/09/2024  Add getInferiorCentersTest,compareToTest method

***********************************************************************************************************************/
@isTest
public with sharing class AV_BuscadorClientes_Controller_Test {
    
    @TestSetup
	static void setup(){
        
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545400', 'AV_SistematicaComercial');
        User userMultiGestor;
       

        System.runAs(userGcf){
            List<User> usrList = new List<User>();
            Profile p = [SELECT Id FROM Profile WHERE Name = 'AV_Usuario_CaixaBank'];
            List<AV_MultiEmployees__mdt> mdts = [SELECT Id,DeveloperName,AV_NumeroOficinaEmpresa__c,AV_Alias__c FROM AV_MultiEmployees__mdt LIMIT 1];


            userMultiGestor = new User(
                Alias = mdts[0].AV_Alias__c,
                Email = 'test@test.dev',
                EmailEncodingKey = 'UTF-8',
                LastName = 'multigestor',
                LanguageLocaleKey = 'es',
                LocaleSidKey = 'es',
                TimeZoneSidKey = 'Europe/Berlin',
                AV_NumeroOficinaEmpresa__c = mdts[0].AV_NumeroOficinaEmpresa__c,
                ProfileId = p.Id,
                UserName = 'testu1@test.dev',
                AV_ExternalID__c = 'U0009926',  
                IsActive = true
            );

         
            User usrOtraOficina = new User(
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
                AV_ExternalID__c = 'U0009826',  
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
            AV_NumeroOficinaEmpresa__c = '00616',
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
                AV_Funcion__c = 'DC' 
            );
    
            User u3 = new User(
                Alias = 'u3',
                Email = 'test3@test.dev',
                EmailEncodingKey = 'UTF-8',
                LastName = 'testLastName',
                LanguageLocaleKey = 'es',
                LocaleSidKey = 'es',
                TimeZoneSidKey = 'Europe/Berlin',
                AV_NumeroOficinaEmpresa__c = '00618',
                ProfileId = p.Id,
                UserName = 'testu4@test.dev',
                AV_ExternalID__c = 'U0009104',
                IsActive = true,
                AV_Funcion__c = 'DT'  
            );
            
            User u4 = new User(
                Alias = 'u2',
                Email = 'test2@test.dev',
                EmailEncodingKey = 'UTF-8',
                LastName = 'testLastName',
                LanguageLocaleKey = 'es',
                LocaleSidKey = 'es',
                TimeZoneSidKey = 'Europe/Berlin',
                AV_NumeroOficinaEmpresa__c = '00619',
                ProfileId = p.Id,
                UserName = 'testu5@test.dev',
                AV_ExternalID__c = 'U0009105',
                IsActive = true,
                AV_Funcion__c = 'Gestor'
            );
        
            User u5 = new User(
                Alias = 'u3',
                Email = 'test3@test.dev',
                EmailEncodingKey = 'UTF-8',
                LastName = 'testLastName',
                LanguageLocaleKey = 'es',
                LocaleSidKey = 'es',
                TimeZoneSidKey = 'Europe/Berlin',
                AV_NumeroOficinaEmpresa__c = '00617',
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
            usrList.add(userMultiGestor);
            insert usrList;

            AV_TestHelper.insertNeededPermissions(userMultiGestor);
            AV_TestHelper.insertNeededPermissions(usrOtraOficina);
            AV_TestHelper.insertNeededPermissions(u1);
            AV_TestHelper.insertNeededPermissions(u2);
            AV_TestHelper.insertNeededPermissions(u3);
            AV_TestHelper.insertNeededPermissions(u4);
            AV_TestHelper.insertNeededPermissions(u5);

            Test.startTest(); 
            List<Account> accList = new List<Account>();
            Account cenDT = AV_TestHelper.createCaixaCenterSinInsert();
            cenDT.CC_Numero_Oficina_Empresa__c = userMultiGestor.AV_NumeroOficinaEmpresa__c;
            cenDT.AV_TipoEstructura__c = '02';
            cenDT.AV_TipoCentroSuperior__c = 'TT'; 
            accList.add(cenDT);

            Account cenTest = AV_TestHelper.createCaixaCenter();
            Contact conTest = AV_TestHelper.createEmployeeSinInsert(cenTest, usrOtraOficina, 'U0009826');
            conTest.OwnerId = usrOtraOficina.Id;
            insert conTest;
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
            AV_Book__c car2 = AV_TestHelper.createPurse('00001EAP002'); 
            AV_BookMember__c bm = AV_TestHelper.createBookMember(accTest, car);
            AV_BookManagementMember__c bmm = AV_TestHelper.createBookManagement(conTest, car);
            Test.stopTest();
            
           
        }
        
	}
    
    @isTest
	public static void getBaseDataTestWithBook() {
        AV_BuscadorClientes_Controller.ObjectList ol = new AV_BuscadorClientes_Controller.ObjectList();
        AV_BuscadorClientes_Controller.ObjectList ol2 = new AV_BuscadorClientes_Controller.ObjectList();
        AV_BuscadorClientes_Controller.ObjectList ol3 = new  AV_BuscadorClientes_Controller.ObjectList();

        ol3.add(ol);
        String page = '1'; //needed for pagination

        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User usrOtraOficina = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009826'];
        // User userMultiGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009926'];
        AV_Book__c car = [SELECT Id FROM AV_Book__c WHERE AV_ExternalID__c = '00001EAP001'];
        
 		Test.startTest();   
        System.runAs(userGcf){
            ol = AV_BuscadorClientes_Controller.getBaseData(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, page, null,null);
            ol2 = AV_BuscadorClientes_Controller.getBaseData(null, null, new List<String>{usrOtraOficina.Id}, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, page, null, null);

        }
        Test.stopTest();
        System.assert(!ol.recordList.isEmpty(), 'getBaseDataOppsNullTest');
       
    }
    @isTest
	public static void getBaseDataTest() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        AV_Book__c car = [SELECT Id FROM AV_Book__c WHERE AV_ExternalID__c = '00001EAP001'];
        AV_Book__c car2 = [SELECT Id FROM AV_Book__c WHERE AV_ExternalID__c = '00001EAP002'];
        String cartera3 = car.Id + ',' + car2.Id;

        Test.startTest();   
        
        System.runAs(userGcf){
            AV_BuscadorClientes_Controller.ObjectList ol = new AV_BuscadorClientes_Controller.ObjectList();
            
            String office = '001-00001';
            String negocio = 'BPA';
            List<String> employeeFilter = new List<String>();
            String cartera = car.Id;
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
            
            
            AV_BuscadorClientes_Controller.ObjectList ol2 = new AV_BuscadorClientes_Controller.ObjectList();
            
            String office2 = '001-00001';
            String negocio2 = 'BPA';
            List<String> employeeFilter2 = new List<String>();
            String cartera2 = null;
            String modelo2 = 'A';
            String edadMin2 = '18';
            String edadMax2 = '100';
            String ingresosMin2 = '0';
            String ingresosMax2 = '100000';
            String ahorroMin2 = '0';
            String ahorroMax2 = '10000';
            String financiacionMin2 = '0';
            String financiacionMax2 = '120';
            String rentabilidadMin2 = '0';
            String rentabilidadMax2 = '120';
            String exp2 = '1';
            String mybox2 = 'N';
            String preconMin2 = '1';
            String preconMax2 = '123456';
            String targetAuto2 = 'N';
            String page2 = '1'; //needed for pagination
            String grupo2 = 'Miembro';
            String interlocName2 = 'Nombre';
            User usuario2  = [Select Id From User Where Email = 'test@test.dev' limit 1];
            employeeFilter2.add(usuario.Id);
            
            AV_BuscadorClientes_Controller.ObjectList ol4 = new  AV_BuscadorClientes_Controller.ObjectList();
            
            
            ol = AV_BuscadorClientes_Controller.getBaseData(office, negocio, employeeFilter, cartera, modelo, edadMin, edadMax, ingresosMin, ingresosMax, ahorroMin, ahorroMax, financiacionMin, financiacionMax, rentabilidadMin, rentabilidadMax, exp, mybox, preconMin, preconMax, targetAuto, page, grupo, interlocName);
            ol2 = AV_BuscadorClientes_Controller.getBaseData(office2, negocio2, employeeFilter2, cartera2, modelo2, edadMin2, edadMax2, ingresosMin2, ingresosMax2, ahorroMin2, ahorroMax2, financiacionMin2, financiacionMax2, rentabilidadMin2, rentabilidadMax2, exp2, mybox2, preconMin2, preconMax2, targetAuto2, page2, grupo2, interlocName2); 
            ol4 = AV_BuscadorClientes_Controller.getBaseData(office2, negocio2, employeeFilter2, cartera3, modelo2, edadMin2, edadMax2, ingresosMin2, ingresosMax2, ahorroMin2, ahorroMax2, financiacionMin2, financiacionMax2, rentabilidadMin2, rentabilidadMax2, exp2, mybox2, preconMin2, preconMax2, targetAuto2, page2, grupo2, interlocName2); 

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
        
        List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'System Administrator\' LIMIT 1');
        User u1 = [SELECT Id,AV_OriginalOfficeNumber__c, AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U0009102'];
        User u2 = [SELECT Id,AV_OriginalOfficeNumber__c, AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U0009105'];
        User u3 = [SELECT Id,AV_OriginalOfficeNumber__c, AV_NumeroOficinaEmpresa__c FROM User WHERE AV_ExternalID__c = 'U0009106'];
        Test.startTest();
        Account center2 = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c='00804'];
        Account a = [
            SELECT Id, CC_Numero_Oficina_Empresa__c
            FROM Account
            WHERE CC_Numero_Oficina__c = '00615'
            LIMIT 1
        ];
        Account acc1 = AV_TestHelper.createCaixaCenterSinInsert();
        acc1.Name = '00806 TEST CENTER';
        acc1.CC_Numero_Oficina_Empresa__c = u1.AV_NumeroOficinaEmpresa__c;
        acc1.CC_Numero_Oficina__c = '00532';
        acc1.OwnerId = u1.Id;


        Account acc2 = AV_TestHelper.createCaixaCenterSinInsert();
        acc2.Name = '00807 TEST CENTER';
        acc2.CC_Numero_Oficina_Empresa__c = u2.AV_NumeroOficinaEmpresa__c;
        acc2.CC_Numero_Oficina__c = '00533';
        acc2.OwnerId = u2.Id;
        

        Account acc3 = AV_TestHelper.createCaixaCenterSinInsert();
        acc3.Name = '00808 TEST CENTER';
        acc3.CC_Numero_Oficina_Empresa__c = u3.AV_NumeroOficinaEmpresa__c;
        acc3.CC_Numero_Oficina__c = '00534';
        acc3.OwnerId = u3.Id;
        insert new List<Account>{acc1,acc2,acc3};

        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = center2.Id;
        // SOSL queries need fixed results in order to retrieve data
        Test.setFixedSearchResults(fixedSearchResults);
        // Director
        System.runAs(u1) {
            res = AV_BuscadorClientes_Controller.searchOffice('00532', lista);
            res = AV_BuscadorClientes_Controller.searchOffice('00532', new List<String>{a.Id});
        }
        // Gestor
        System.runAs(u2) {
            res = AV_BuscadorClientes_Controller.searchOffice('00533', lista);
            res = AV_BuscadorClientes_Controller.searchOffice('00533', new List<String>{a.Id});
        }
        // SSCC
        System.runAs(u3) {
            res = AV_BuscadorClientes_Controller.searchOffice('00534', new List<String>{a.Id});
            res = AV_BuscadorClientes_Controller.searchOffice('00534', lista);
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
            User usrOtraOficina = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009826'];
          
            Contact conTest = [SELECT Id FROM Contact LIMIT 1];
            accTest.AV_EAPGestor__C  = conTest.Id;
            update accTest;
            AV_Book__c car = [SELECT Id FROM AV_Book__c WHERE AV_ExternalID__c = '00001EAP002'];
            
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
                SELECT Id, AV_Cliente__c,AV_CarteraPrincipal__c
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

    @isTest
    static void getInferiorCentersTest() {
        Test.startTest();
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
            Account cenTest = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '00615' LIMIT 1];
            Account center2 = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '00803' LIMIT 1];
            Account center3 = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '00804' LIMIT 1];

            List<Id> superiorCentersIds = new List<Id>{cenTest.Id};
            List<Account> result = AV_BuscadorClientes_Controller.getInferiorCenters(superiorCentersIds);

            System.assertEquals(2, result.size(), 'El tamaño del resultado debe ser 2');
        }
        Test.stopTest();
        
    }

    @isTest
    static void compareToTest() {
        // Step 1: Crear instancias de OptionsBook para las pruebas
        AV_BuscadorClientes_Controller.OptionsBook option1 = new AV_BuscadorClientes_Controller.OptionsBook('001', 'A');
        AV_BuscadorClientes_Controller.OptionsBook option2 = new AV_BuscadorClientes_Controller.OptionsBook('002', 'B');
        AV_BuscadorClientes_Controller.OptionsBook option3 = new AV_BuscadorClientes_Controller.OptionsBook('003', 'A');  
        AV_BuscadorClientes_Controller.OptionsBook option4 = new AV_BuscadorClientes_Controller.OptionsBook('004', null);     
        AV_BuscadorClientes_Controller.OptionsBook option5 = new AV_BuscadorClientes_Controller.OptionsBook('005', null);  
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
            System.assertEquals(-1, option1.compareTo(option2), 'A debe ser menor que B');
            System.assertEquals(1, option2.compareTo(option1), 'B debe ser mayor que A');
            System.assertEquals(0, option1.compareTo(option3), 'Ambas opciones deben ser iguales');
            System.assertEquals(-1, option1.compareTo(option4));
            System.assertEquals(0, option4.compareTo(option5));
            System.assertEquals(1, option4.compareTo(option1));
        }  
    }
}