@isTest
public class CC_WS_Methods_ALF_Test { 

    @isTest
    static void test01_getContactAccountByNumPerso() {
        // Testar control numperso.
        
        Test.startTest();
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '9910559714';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.size(), 1);
        
        // Crear contacto. 
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '9910559714';
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.size(), 1);
        
        // Crear cliente.
        Account a2 = new Account();
        a2.Name = 'Cliente prueba 2';
        a2.CC_NumPerso__c = '8810559714';
        a2.CC_FechaRefresco__c = date.today();
        insert a2;
        
        List<Account> o3 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 2'];
        System.assertEquals(o3.size(), 1);
        
        // Crear contacto.
        Contact b2 = new Contact();
        b2.LastName = 'Contacto prueba 2';
        b2.CC_NumPerso__c = '8810559714';
        b2.CC_FechaRefresco__c = date.today();
        insert b2;
        
        List<Contact> o4 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 2'];
        System.assertEquals(o4.size(), 1);
        
        Map<String,SObject> oNumPerso = new Map<String,SObject>();
        oNumPerso.put('8810559714##Cliente##ID', null);
        oNumPerso.put('9910559714##Cliente##ID', null);
        
        Map<String,SObject> oData = CC_WS_Methods_ALF.getContactAccountByNumPerso (oNumPerso);
        
        Test.stopTest();
        
        System.assertEquals(oData.size()>=1, true);
    }
    
    @isTest
    static void test02_getDataALFWSbyNumPerso() {
        // Testar respuesta ALF.
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.size(), 1);
        
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.size(), 1);
        
        // Crear teléfono y mail del contacto.
        String sRecordType1 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        String sRecordType2 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        
        CC_Canal_Com__c c1 = new CC_Canal_Com__c();
        c1.CC_NumPerso__c = '999910559714';
        c1.CC_ContactoId__c = b.Id;
        c1.CC_CuentaId__c = a.Id;
        c1.CC_Telefono__c = '956565656';
        c1.RecordTypeId = sRecordType1;
        insert c1;
        
        List<CC_Canal_Com__c> o3 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Telefono__c = '956565656'];
        System.assertEquals(o3.size(), 1);
        
        CC_Canal_Com__c c2 = new CC_Canal_Com__c();
        c2.CC_NumPerso__c = '999910559714';
        c2.CC_ContactoId__c = b.Id;
        c2.CC_CuentaId__c = a.Id;
        c2.CC_Email__c = 'prueba21@caixabank.com';
        c2.RecordTypeId = sRecordType2;
        insert c2;
        
        List<CC_Canal_Com__c> o4 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Email__c = 'prueba21@caixabank.com'];
        System.assertEquals(o4.size(), 1);
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP());
        CC_InterfaceSettings__mdt oConfigIntALF = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF');
        Map<String,Object> oData = CC_WS_Methods_ALF.getDataALFWSbyNumPerso ('','999910559714', 'INTALF01', '',null, null, oConfigIntALF);
        
        Test.stopTest();
        
        System.assertNotEquals(oData.get('Account##0##999910559714'), null);
    } 
    
    @isTest
    static void test03_getDataALFWSbyNumPerso() {
        // Testar respuesta ALF.
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.size(), 1);
        
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.size(), 1);
        
        // Crear teléfono y mail del contacto.
        String sRecordType1 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        String sRecordType2 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        
        CC_Canal_Com__c c1 = new CC_Canal_Com__c();
        c1.CC_NumPerso__c = '999910559714';
        c1.CC_ContactoId__c = b.Id;
        c1.CC_CuentaId__c = a.Id;
        c1.CC_Telefono__c = '956565656';
        c1.RecordTypeId = sRecordType1;
        insert c1;
        
        List<CC_Canal_Com__c> o3 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Telefono__c = '956565656'];
        System.assertEquals(o3.size(), 1);
        
        CC_Canal_Com__c c2 = new CC_Canal_Com__c();
        c2.CC_NumPerso__c = '999910559714';
        c2.CC_ContactoId__c = b.Id;
        c2.CC_CuentaId__c = a.Id;
        c2.CC_Email__c = 'prueba21@caixabank.com';
        c2.RecordTypeId = sRecordType2;
        insert c2;
        
        List<CC_Canal_Com__c> o4 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Email__c = 'prueba21@caixabank.com'];
        System.assertEquals(o4.size(), 1);
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP_02());
        CC_InterfaceSettings__mdt oConfigIntALF = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF');
        Map<String,Object> oData = CC_WS_Methods_ALF.getDataALFWSbyNumPerso ('','999910559714', 'INTALF02', '',null, null, oConfigIntALF);
        
        Test.stopTest();
        
        System.assertNotEquals(oData.get('Account##0##999910559714'), null);
    }
    
    @isTest
    static void test04_getDataALFWSbyNumPerso() {
        // Testar respuesta ALF.
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.size(), 1);
        
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.size(), 1);
        
        // Crear teléfono y mail del contacto.
        String sRecordType1 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        String sRecordType2 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        
        CC_Canal_Com__c c1 = new CC_Canal_Com__c();
        c1.CC_NumPerso__c = '999910559714';
        c1.CC_ContactoId__c = b.Id;
        c1.CC_CuentaId__c = a.Id;
        c1.CC_Telefono__c = '956565656';
        c1.RecordTypeId = sRecordType1;
        insert c1;
        
        List<CC_Canal_Com__c> o3 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Telefono__c = '956565656'];
        System.assertEquals(o3.size(), 1);
        
        CC_Canal_Com__c c2 = new CC_Canal_Com__c();
        c2.CC_NumPerso__c = '999910559714';
        c2.CC_ContactoId__c = b.Id;
        c2.CC_CuentaId__c = a.Id;
        c2.CC_Email__c = 'prueba21@caixabank.com';
        c2.RecordTypeId = sRecordType2;
        insert c2;
        
        List<CC_Canal_Com__c> o4 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Email__c = 'prueba21@caixabank.com'];
        System.assertEquals(o4.size(), 1);
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP_03());
        CC_InterfaceSettings__mdt oConfigIntALF = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF');
        Map<String,Object> oData = CC_WS_Methods_ALF.getDataALFWSbyNumPerso ('','999910559714', 'INTALF02', '',null, null, oConfigIntALF);
        
        Test.stopTest();
        
        System.assertNotEquals(oData.get('Account##0##999910559714'), null);
    }
    
    @isTest
    static void test05_getDataALFWSbyNumPerso() {
        // Testar respuesta ALF.
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.size(), 1);
        
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.size(), 1);
        
        // Crear teléfono y mail del contacto.
        String sRecordType1 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        String sRecordType2 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        
        CC_Canal_Com__c c1 = new CC_Canal_Com__c();
        c1.CC_NumPerso__c = '999910559714';
        c1.CC_ContactoId__c = b.Id;
        c1.CC_CuentaId__c = a.Id;
        c1.CC_Telefono__c = '956565656';
        c1.RecordTypeId = sRecordType1;
        insert c1;
        
        List<CC_Canal_Com__c> o3 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Telefono__c = '956565656'];
        System.assertEquals(o3.size(), 1);
        
        CC_Canal_Com__c c2 = new CC_Canal_Com__c();
        c2.CC_NumPerso__c = '999910559714';
        c2.CC_ContactoId__c = b.Id;
        c2.CC_CuentaId__c = a.Id;
        c2.CC_Email__c = 'prueba21@caixabank.com';
        c2.RecordTypeId = sRecordType2;
        insert c2;
        
        List<CC_Canal_Com__c> o4 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Email__c = 'prueba21@caixabank.com'];
        System.assertEquals(o4.size(), 1);
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP_04());
        CC_InterfaceSettings__mdt oConfigIntALF = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF');
        Map<String,Object> oData = CC_WS_Methods_ALF.getDataALFWSbyNumPerso ('','999910559714', 'INTALF02', '',null, null, oConfigIntALF);
        
        Test.stopTest();
        
        System.assertNotEquals(oData.get('Account##0##999910559714'), null);
    }
    
    @isTest
    static void test06_getDataALFWSbyNumPerso() {
        // Testar respuesta ALF - Empresas.
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.size(), 1);
        
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.size(), 1);
        
        // Crear teléfono y mail del contacto.
        String sRecordType1 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        String sRecordType2 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        
        CC_Canal_Com__c c1 = new CC_Canal_Com__c();
        c1.CC_NumPerso__c = '999910559714';
        c1.CC_ContactoId__c = b.Id;
        c1.CC_CuentaId__c = a.Id;
        c1.CC_Telefono__c = '956565656';
        c1.RecordTypeId = sRecordType1;
        insert c1;
        
        List<CC_Canal_Com__c> o3 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Telefono__c = '956565656'];
        System.assertEquals(o3.size(), 1);
        
        CC_Canal_Com__c c2 = new CC_Canal_Com__c();
        c2.CC_NumPerso__c = '999910559714';
        c2.CC_ContactoId__c = b.Id;
        c2.CC_CuentaId__c = a.Id;
        c2.CC_Email__c = 'prueba21@caixabank.com';
        c2.RecordTypeId = sRecordType2;
        insert c2;
        
        List<CC_Canal_Com__c> o4 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Email__c = 'prueba21@caixabank.com'];
        System.assertEquals(o4.size(), 1);
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP_05());
        CC_InterfaceSettings__mdt oConfigIntALF = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF');
        Map<String,Object> oData = CC_WS_Methods_ALF.getDataALFWSbyNumPerso ('','999910559714', 'INTALF03', '',null, null, oConfigIntALF);
        
        Test.stopTest();
        
        System.assertNotEquals(oData.get('Account##0##999910559714'), null);
    }
    
    @isTest
    static void test07_getDataALFWSbyNumPerso() {
        // Testar respuesta ALF - Empresas.
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.size(), 1);
        
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.size(), 1);
        
        // Crear teléfono y mail del contacto.
        String sRecordType1 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        String sRecordType2 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        
        CC_Canal_Com__c c1 = new CC_Canal_Com__c();
        c1.CC_NumPerso__c = '999910559714';
        c1.CC_ContactoId__c = b.Id;
        c1.CC_CuentaId__c = a.Id;
        c1.CC_Telefono__c = '956565656';
        c1.RecordTypeId = sRecordType1;
        insert c1;
        
        List<CC_Canal_Com__c> o3 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Telefono__c = '956565656'];
        System.assertEquals(o3.size(), 1);
        
        CC_Canal_Com__c c2 = new CC_Canal_Com__c();
        c2.CC_NumPerso__c = '999910559714';
        c2.CC_ContactoId__c = b.Id;
        c2.CC_CuentaId__c = a.Id;
        c2.CC_Email__c = 'prueba21@caixabank.com';
        c2.RecordTypeId = sRecordType2;
        insert c2;
        
        List<CC_Canal_Com__c> o4 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Email__c = 'prueba21@caixabank.com'];
        System.assertEquals(o4.size(), 1);
        
        Test.startTest();
        
        Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALF_WSDL_01());
        CC_InterfaceSettings__mdt oConfigIntALF = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF');
        Map<String,Object> oData = CC_WS_Methods_ALF.getDataALFWSbyNumPerso ('','999910559714', 'AP2WL01', '',null, null, oConfigIntALF);
        
        Test.stopTest();
        
        System.assertNotEquals(oData.get('Account##0##999910559714'), null);
    }
    
    @isTest
    static void test08_getDataALFWSbyNumPerso() {
        // Testar respuesta ALF - forzado error confidencial
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.size(), 1);
        
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.size(), 1);
        
        // Crear teléfono y mail del contacto.
        String sRecordType1 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        String sRecordType2 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        
        CC_Canal_Com__c c1 = new CC_Canal_Com__c();
        c1.CC_NumPerso__c = '999910559714';
        c1.CC_ContactoId__c = b.Id;
        c1.CC_CuentaId__c = a.Id;
        c1.CC_Telefono__c = '956565656';
        c1.RecordTypeId = sRecordType1;
        insert c1;
        
        List<CC_Canal_Com__c> o3 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Telefono__c = '956565656'];
        System.assertEquals(o3.size(), 1);
        
        CC_Canal_Com__c c2 = new CC_Canal_Com__c();
        c2.CC_NumPerso__c = '999910559714';
        c2.CC_ContactoId__c = b.Id;
        c2.CC_CuentaId__c = a.Id;
        c2.CC_Email__c = 'prueba21@caixabank.com';
        c2.RecordTypeId = sRecordType2;
        insert c2;
        
        List<CC_Canal_Com__c> o4 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Email__c = 'prueba21@caixabank.com'];
        System.assertEquals(o4.size(), 1);
        
        Test.startTest();
        CC_InterfaceSettings__mdt oConfigIntALF = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF');
        Map<String,Object> oData = CC_WS_Methods_ALF.getDataALFWSbyNumPerso ('','999910559714', 'AP2WL01', '',null, null, oConfigIntALF);
        
        Test.stopTest();
        
        System.assertNotEquals(oData.get('Account##0##999910559714'), null);
    }
    
    @isTest
    static void test09_getDataLOVMeta() {
        // Test obtener metadatos existentes.

        List<String> oDatos = new List<String>();
        oDatos.add('CC_Idioma_ALF');
        
        Test.startTest();
        
		Map<String, Object> oConfig = CC_MetodosUtiles.getLOVMeta (oDatos);
        
        Test.stopTest();
        
        System.assertNotEquals(oConfig,null);  
        System.assertEquals(oConfig.size()==1,true);
    }
    
   /* @isTest
    static void test10_getHttpALF_RRSS() {
        // Testar WebService HTTP Alfabético Búsqueda RRSS - Respuesta correcta.
        
        Test.startTest();
        
        CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF_RRSS');
        
		Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALFRRSS_WSDL_01());

        Map<String,Object> oData = CC_WS_Methods_ALF.getDataALFWSbyRRSS ('@twitter', 'RRSS', '', 'Twitter', 'IDSP', 'IDSP2', '');
        
        Test.stopTest();
        
        System.assertNotEquals(oData.get('NUMPER_RRSS'), null);
    }*/

    @isTest
    static void test11_getHttpALF_DOC() {
        // Testar WebService HTTP Alfabético Búsqueda DOC - Respuesta correcta.
        
        Test.startTest();
        
        CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF_RRSS');
        
		Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALFCONS_WSDL_01());
		CC_InterfaceSettings__mdt oConfigDOC = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF_DOC');
        Map<String,Object> oData = CC_WS_Methods_ALF.getDataALFWSbyDOC ('12345679H', 'DOC', '', '','',oConfigDOC);
        
        Test.stopTest();
        
        System.assertNotEquals(oData.get('NUMPER_DOC'), null);
    }

    @isTest
    static void testGetDataALFWSbyNumPersoCaracteristicasOrigen() {
        // Testar respuesta ALF - Empresas.
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.size(), 1);
        
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.size(), 1);
        
        // Crear teléfono y mail del contacto.
        String sRecordType1 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        String sRecordType2 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        
        CC_Canal_Com__c c1 = new CC_Canal_Com__c();
        c1.CC_NumPerso__c = '999910559714';
        c1.CC_ContactoId__c = b.Id;
        c1.CC_CuentaId__c = a.Id;
        c1.CC_Telefono__c = '956565656';
        c1.RecordTypeId = sRecordType1;
        insert c1;
        
        List<CC_Canal_Com__c> o3 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Telefono__c = '956565656'];
        System.assertEquals(o3.size(), 1);
        
        CC_Canal_Com__c c2 = new CC_Canal_Com__c();
        c2.CC_NumPerso__c = '999910559714';
        c2.CC_ContactoId__c = b.Id;
        c2.CC_CuentaId__c = a.Id;
        c2.CC_Email__c = 'prueba21@caixabank.com';
        c2.RecordTypeId = sRecordType2;
        insert c2;
        
        List<CC_Canal_Com__c> o4 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Email__c = 'prueba21@caixabank.com'];
        System.assertEquals(o4.size(), 1);
        
        Test.startTest();
        
        Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALF_WSDL_01());
        CC_InterfaceSettings__mdt oConfigIntALF = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF');
        Map<String,Object> oData = CC_WS_Methods_ALF.getDataALFWSbyNumPerso ('','999910559714', 'AP2WL01', '',null, null, oConfigIntALF);
        
        Test.stopTest();
        
        System.assertNotEquals(oData.get('Account##0##999910559714'), null);
        
        Account accountResult = (Account) oData.get('Account##0##999910559714');
        System.assert(accountResult.CBK_OrigenBankia__c, 'La cuenta tiene caracterísiticas Origen Bankia');
        //System.assert(accountResult.CBK_OrigenCompartido__c, 'La cuenta tiene caracterísiticas Origen Compartido');
        System.assert(accountResult.CC_FirmaDigitalizada__c, 'La cuenta tiene caracterísiticas Firma digitalizada');
        System.assert(accountResult.CC_DocumentoDigitalizado__c, 'La cuenta tiene caracterísiticas Documento digitalizado');
    }
    
    @isTest
    static void testgetDataALFWS_RepresentantesJuridicos() {
        // Testar respuesta ALF - Empresas.
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.size(), 1);
        
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.size(), 1);
        
        // Crear teléfono y mail del contacto.
        String sRecordType1 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        String sRecordType2 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        
        CC_Canal_Com__c c1 = new CC_Canal_Com__c();
        c1.CC_NumPerso__c = '999910559714';
        c1.CC_ContactoId__c = b.Id;
        c1.CC_CuentaId__c = a.Id;
        c1.CC_Telefono__c = '956565656';
        c1.RecordTypeId = sRecordType1;
        insert c1;
        
        List<CC_Canal_Com__c> o3 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Telefono__c = '956565656'];
        System.assertEquals(o3.size(), 1);
        
        CC_Canal_Com__c c2 = new CC_Canal_Com__c();
        c2.CC_NumPerso__c = '999910559714';
        c2.CC_ContactoId__c = b.Id;
        c2.CC_CuentaId__c = a.Id;
        c2.CC_Email__c = 'prueba21@caixabank.com';
        c2.RecordTypeId = sRecordType2;
        insert c2;
        
        List<CC_Canal_Com__c> o4 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Email__c = 'prueba21@caixabank.com'];
        System.assertEquals(o4.size(), 1);
        
        Test.startTest();
        
        Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALF_WSDL_01());
        CC_InterfaceSettings__mdt oConfigIntALF = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF');
        Map<String,Object> oData = CC_WS_Methods_ALF.getDataALFWS_RepresentantesJuridicos ('999910559714', '', oConfigIntALF);
        
        Test.stopTest();
        
        system.Assert(oData != null);
    }
}