@isTest
public class CC_WS_Casos_Test {
    
    @isTest
    static void crearFormularioWeb_01() {
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        Id recordTypeIdWeb = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_ConvMCCWeb').getRecordTypeId();
       	CC_MCC__c mccConvWeb = new CC_MCC__c();
        mccConvWeb.Name = 'Test';
        mccConvWeb.CC_Tipo_Cliente__c = 'Cliente';
        mccConvWeb.CC_Equivalencia_Formulario__c = 'MC-001-001-001';
        mccConvWeb.CC_Fecha_Vigencia_Inicio__c = Date.newInstance(2019,05,05);
        mccConvWeb.RecordTypeId = recordTypeIdWeb;
        mccConvWeb.CC_WebMCCTematica__c = mccTematica.Id;
        mccConvWeb.CC_WebMCCProducto__c = mccProducto.Id; 
        mccConvWeb.CC_WebMCCMotivo__c = mccMotivo.Id;
        mccConvWeb.CC_MCCWeb_Origen__c = 'MC';
        mccConvWeb.CC_MCCWeb_Motivo__c = '001';
        mccConvWeb.CC_MCCWeb_Producto__c = '001';
        mccConvWeb.CC_MCCWeb_Ambito__c = '001';
        insert mccConvWeb;
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        a.CC_Numero_Documento__c = '23663942R';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.size(), 1);
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        b.CC_Numero_Documento__c = '23663942R';
        b.AccountId = a.Id;
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.size(), 1);

        
        List<CC_WS_Casos.CC_WS_Casos_Input> oEntrada = new List<CC_WS_Casos.CC_WS_Casos_Input>();
        
        CC_WS_Casos.CC_WS_Casos_Input oData = new CC_WS_Casos.CC_WS_Casos_Input();
        oData.Aplicacion = 'FORMWEB';
        oData.id = 'X';
        oData.entidad = 'X';
        oData.Nombre = 'X';
        oData.Apellido1 = 'X';
        oData.Apellido2 = 'X';
        oData.EMAIL = 'TEST@TEST.ES';
        oData.Telefono = '900606060';
        oData.NIF = '23663942R';
        oData.Cliente = 'X';
        oData.NumOf = 'X';
        oData.ClienteLOE = 'X';
        oData.Codiusu = 'X';
        oData.Producto = '001';
        oData.Ambito = '001';
        oData.Motivo = '001';
        oData.Idioma = 'es';
        oData.Texto = 'X';
        oData.CertificadoDigital = 'X';
        oData.Origen = 'X';
        oData.Referer = 'X';
        oData.User_Agent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        oEntrada.add(oData); //Forzado duplicado.
        
        CC_WS_Casos.CC_WS_Casos_Input oData2 = new CC_WS_Casos.CC_WS_Casos_Input();
        oData2.Aplicacion = 'FORMWEB';
        oData2.id = 'X1';
        oData2.entidad = 'X1';
        oData2.Nombre = 'X1';
        oData2.Apellido1 = 'X1';
        oData2.Apellido2 = 'X1';
        oData2.EMAIL = 'TEST@TEST.ES';
        oData2.Telefono = '900606060';
        oData2.NIF = '23663942R';
        oData2.Cliente = 'X1';
        oData2.NumOf = 'X1';
        oData2.ClienteLOE = 'X1';
        oData2.Codiusu = 'X1';
        oData2.Producto = '001';
        oData2.Ambito = '001';
        oData2.Motivo = '001';
        oData2.Idioma = 'es';
        oData2.Texto = 'X1';
        oData2.CertificadoDigital = 'X';
        oData2.Origen = 'X';
        oData2.Referer = 'X';
        oData2.User_Agent = 'X';
        oData2.IP = 'X';
        oData2.REFUSUARIO = '001-001';
        oData2.Tipo = 'X';
        oData2.Web = 'X';
        oData2.Servicio = 'X';
        oData2.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData2);
        
        Test.startTest();
        
        List<CC_WS_Casos.CC_WS_Casos_Output> oRes = CC_WS_Casos.createCase(oEntrada);
        
        System.assertNotEquals(oRes, null);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void crearFormularioWeb_02() {

        List<CC_WS_Casos.CC_WS_Casos_Input> oEntrada = new List<CC_WS_Casos.CC_WS_Casos_Input>();
        
        CC_WS_Casos.CC_WS_Casos_Input oData = new CC_WS_Casos.CC_WS_Casos_Input();
        oData.Aplicacion = 'FORMWEB';
        oData.id = 'X';
        oData.entidad = 'X';
        oData.Nombre = 'X';
        oData.Apellido1 = 'X';
        oData.Apellido2 = 'X';
        oData.EMAIL = 'TEST@TEST.ES';
        oData.Telefono = '900606060';
        oData.NIF = '23663942R';
        oData.Cliente = 'X';
        oData.NumOf = 'X';
        oData.ClienteLOE = 'X';
        oData.Codiusu = 'X';
        oData.Producto = '001';
        oData.Ambito = '001';
        oData.Motivo = '001';
        oData.Idioma = 'es';
        oData.Texto = 'X';
        oData.CertificadoDigital = 'X';
        oData.Origen = 'X';
        oData.Referer = 'X';
        oData.User_Agent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        oEntrada.add(oData); //Forzado duplicado.
        
        Test.startTest();
        
        List<CC_WS_Casos.CC_WS_Casos_Output> oRes = CC_WS_Casos.createCase(oEntrada);
        
        System.assertNotEquals(oRes, null);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void crearFormularioWeb_03() {
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        a.CC_Numero_Documento__c = '23663942R';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.size(), 1);
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        b.CC_Numero_Documento__c = '23663942R';
        b.AccountId = a.Id;
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.size(), 1);
        
        // Crear cliente.
        Account a1 = new Account();
        a1.Name = '1Cliente prueba 1';
        a1.CC_NumPerso__c = '899910559714';
        a1.CC_Numero_Documento__c = '23663942R';
        insert a1;
        
        List<Account> o11 = [SELECT Id FROM Account WHERE Name = '1Cliente prueba 1'];
        System.assertEquals(o11.size(), 1);
        
        // Crear contacto.
        Contact b1 = new Contact();
        b1.LastName = '1Contacto prueba 1';
        b1.CC_NumPerso__c = '899910559714';
        b1.CC_Numero_Documento__c = '23663942R';
        b1.AccountId = a1.Id;
        insert b1;
        
        List<Contact> o21 = [SELECT Id FROM Contact WHERE LastName = '1Contacto prueba 1'];
        System.assertEquals(o21.size(), 1);
        
        // Crear cliente.
        Account a11 = new Account();
        a11.Name = '11Cliente prueba 1';
        a11.CC_NumPerso__c = '';
        a11.CC_Numero_Documento__c = '23663942R';
        insert a11;
        
        List<Account> o111 = [SELECT Id FROM Account WHERE Name = '11Cliente prueba 1'];
        System.assertEquals(o111.size(), 1);

        
        List<CC_WS_Casos.CC_WS_Casos_Input> oEntrada = new List<CC_WS_Casos.CC_WS_Casos_Input>();
        
        CC_WS_Casos.CC_WS_Casos_Input oData = new CC_WS_Casos.CC_WS_Casos_Input();
        oData.Aplicacion = 'FORMWEB';
        oData.id = 'X';
        oData.entidad = 'X';
        oData.Nombre = 'X';
        oData.Apellido1 = 'X';
        oData.Apellido2 = 'X';
        oData.EMAIL = 'TEST@TEST.ES';
        oData.Telefono = '900606060';
        oData.NIF = '23663942R';
        oData.Cliente = 'X';
        oData.NumOf = 'X';
        oData.ClienteLOE = 'X';
        oData.Codiusu = 'X';
        oData.Producto = '001';
        oData.Ambito = '001';
        oData.Motivo = '001';
        oData.Idioma = 'es';
        oData.Texto = 'X';
        oData.CertificadoDigital = 'X';
        oData.Origen = 'X';
        oData.Referer = 'X';
        oData.User_Agent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        oEntrada.add(oData); //Forzado duplicado.
        
        CC_WS_Casos.CC_WS_Casos_Input oData2 = new CC_WS_Casos.CC_WS_Casos_Input();
        oData2.Aplicacion = 'FORMWEB';
        oData2.id = 'X1';
        oData2.entidad = 'X1';
        oData2.Nombre = 'X1';
        oData2.Apellido1 = 'X1';
        oData2.Apellido2 = 'X1';
        oData2.EMAIL = 'TEST@TEST.ES';
        oData2.Telefono = '900606060';
        oData2.NIF = '23663942R';
        oData2.Cliente = 'X1';
        oData2.NumOf = 'X1';
        oData2.ClienteLOE = 'X1';
        oData2.Codiusu = 'X1';
        oData2.Producto = '001';
        oData2.Ambito = '001';
        oData2.Motivo = '001';
        oData2.Idioma = 'es';
        oData2.Texto = 'X1';
        oData2.CertificadoDigital = 'X';
        oData2.Origen = 'X';
        oData2.Referer = 'X';
        oData2.User_Agent = 'X';
        oData2.IP = 'X';
        oData2.REFUSUARIO = '001-001';
        oData2.Tipo = 'X';
        oData2.Web = 'X';
        oData2.Servicio = 'X';
        oData2.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData2);
        
        Test.startTest();
        
        List<CC_WS_Casos.CC_WS_Casos_Output> oRes = CC_WS_Casos.createCase(oEntrada);
        
        System.assertNotEquals(oRes, null);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void crearFormularioWeb_error01() {

        List<CC_WS_Casos.CC_WS_Casos_Input> oEntrada = new List<CC_WS_Casos.CC_WS_Casos_Input>();
        
        CC_WS_Casos.CC_WS_Casos_Input oData = new CC_WS_Casos.CC_WS_Casos_Input();
        oData.Aplicacion = '';
        oData.id = 'X';
        oData.entidad = 'X';
        oData.Nombre = 'X';
        oData.Apellido1 = 'X';
        oData.Apellido2 = 'X';
        oData.EMAIL = 'TEST@TEST.ES';
        oData.Telefono = '900606060';
        oData.NIF = '23663942R';
        oData.Cliente = 'X';
        oData.NumOf = 'X';
        oData.ClienteLOE = 'X';
        oData.Codiusu = 'X';
        oData.Producto = '001';
        oData.Ambito = '001';
        oData.Motivo = '001';
        oData.Idioma = 'es';
        oData.Texto = 'X';
        oData.CertificadoDigital = 'X';
        oData.Origen = 'X';
        oData.Referer = 'X';
        oData.User_Agent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        
        Test.startTest();
        
        List<CC_WS_Casos.CC_WS_Casos_Output> oRes = CC_WS_Casos.createCase(oEntrada);
        
        System.assertNotEquals(oRes, null);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void crearFormularioWeb_error02() {

        List<CC_WS_Casos.CC_WS_Casos_Input> oEntrada = new List<CC_WS_Casos.CC_WS_Casos_Input>();
        
        CC_WS_Casos.CC_WS_Casos_Input oData = new CC_WS_Casos.CC_WS_Casos_Input();
        oData.Aplicacion = 'FORMWEB';
        oData.id = 'X';
        oData.entidad = 'X';
        oData.Nombre = 'X';
        oData.Apellido1 = 'X';
        oData.Apellido2 = 'X';
        oData.EMAIL = 'TEST@TEST.ES';
        oData.Telefono = '900606060';
        oData.NIF = '';
        oData.Cliente = 'X';
        oData.NumOf = 'X';
        oData.ClienteLOE = 'X';
        oData.Codiusu = 'X';
        oData.Producto = '001';
        oData.Ambito = '001';
        oData.Motivo = '001';
        oData.Idioma = 'es';
        oData.Texto = 'X';
        oData.CertificadoDigital = 'X';
        oData.Origen = 'X';
        oData.Referer = 'X';
        oData.User_Agent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        
        Test.startTest();
        
        List<CC_WS_Casos.CC_WS_Casos_Output> oRes = CC_WS_Casos.createCase(oEntrada);
        
        System.assertNotEquals(oRes, null);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void crearFormularioWeb_error03() {

        List<CC_WS_Casos.CC_WS_Casos_Input> oEntrada = new List<CC_WS_Casos.CC_WS_Casos_Input>();
        
        CC_WS_Casos.CC_WS_Casos_Input oData = new CC_WS_Casos.CC_WS_Casos_Input();
        oData.Aplicacion = 'FORMWEB';
        oData.id = 'X';
        oData.entidad = 'X';
        oData.Nombre = 'X';
        oData.Apellido1 = 'X';
        oData.Apellido2 = 'X';
        oData.EMAIL = 'TEST@TEST.ES';
        oData.Telefono = '900606060';
        oData.NIF = '23663942R';
        oData.Cliente = 'X';
        oData.NumOf = 'X';
        oData.ClienteLOE = 'X';
        oData.Codiusu = 'X';
        oData.Producto = '001';
        oData.Ambito = '001';
        oData.Motivo = '001';
        oData.Idioma = 'es';
        oData.Texto = 'X';
        oData.CertificadoDigital = 'X';
        oData.Origen = 'X';
        oData.Referer = 'X';
        oData.User_Agent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        
        Test.startTest();
        
        List<CC_WS_Casos.CC_WS_Casos_Output> oRes = CC_WS_Casos.createCase(oEntrada);
        
        System.assertNotEquals(oRes, null);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void crearFormularioWeb_error04() {

        List<CC_WS_Casos.CC_WS_Casos_Input> oEntrada = new List<CC_WS_Casos.CC_WS_Casos_Input>();
        
        CC_WS_Casos.CC_WS_Casos_Input oData = new CC_WS_Casos.CC_WS_Casos_Input();
        oData.Aplicacion = '';
        oData.id = 'X';
        oData.entidad = 'X';
        oData.Nombre = 'X';
        oData.Apellido1 = 'X';
        oData.Apellido2 = 'X';
        oData.EMAIL = 'TEST@TEST.ES';
        oData.Telefono = '900606060';
        oData.NIF = '23663942R';
        oData.Cliente = 'X';
        oData.NumOf = 'X';
        oData.ClienteLOE = 'X';
        oData.Codiusu = 'X';
        oData.Producto = '001';
        oData.Ambito = '001';
        oData.Motivo = '001';
        oData.Idioma = 'es';
        oData.Texto = '';
        oData.CertificadoDigital = 'X';
        oData.Origen = 'X';
        oData.Referer = 'X';
        oData.User_Agent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        
        Test.startTest();
        
        List<CC_WS_Casos.CC_WS_Casos_Output> oRes = CC_WS_Casos.createCase(oEntrada);
        
        System.assertNotEquals(oRes, null);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void crearFormularioWeb_error06() {

        List<CC_WS_Casos.CC_WS_Casos_Input> oEntrada = new List<CC_WS_Casos.CC_WS_Casos_Input>();
        
        CC_WS_Casos.CC_WS_Casos_Input oData = new CC_WS_Casos.CC_WS_Casos_Input();
        oData.Aplicacion = 'FORMWEB';
        oData.id = 'X';
        oData.entidad = 'X';
        oData.Nombre = 'X';
        oData.Apellido1 = 'X';
        oData.Apellido2 = 'X';
        oData.EMAIL = 'TEST@TEST.ES';
        oData.Telefono = '900606060';
        oData.NIF = '23663942R';
        oData.Cliente = 'X';
        oData.NumOf = 'X';
        oData.ClienteLOE = 'X';
        oData.Codiusu = 'X';
        oData.Producto = '';
        oData.Ambito = '001';
        oData.Motivo = '001';
        oData.Idioma = 'es';
        oData.Texto = 'X';
        oData.CertificadoDigital = 'X';
        oData.Origen = 'X';
        oData.Referer = 'X';
        oData.User_Agent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        
        Test.startTest();
        
        List<CC_WS_Casos.CC_WS_Casos_Output> oRes = CC_WS_Casos.createCase(oEntrada);
        
        System.assertNotEquals(oRes, null);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void crearFormularioWeb_error07() {

        List<CC_WS_Casos.CC_WS_Casos_Input> oEntrada = new List<CC_WS_Casos.CC_WS_Casos_Input>();
        
        CC_WS_Casos.CC_WS_Casos_Input oData = new CC_WS_Casos.CC_WS_Casos_Input();
        oData.Aplicacion = 'FORMWEB';
        oData.id = 'X';
        oData.entidad = 'X';
        oData.Nombre = 'X';
        oData.Apellido1 = 'X';
        oData.Apellido2 = 'X';
        oData.EMAIL = 'TEST@TEST.ES';
        oData.Telefono = '900606060';
        oData.NIF = '23663942R';
        oData.Cliente = 'X';
        oData.NumOf = 'X';
        oData.ClienteLOE = 'X';
        oData.Codiusu = 'X';
        oData.Producto = '006';
        oData.Ambito = '006';
        oData.Motivo = '006';
        oData.Idioma = 'es';
        oData.Texto = 'X';
        oData.CertificadoDigital = 'X';
        oData.Origen = 'X';
        oData.Referer = 'X';
        oData.User_Agent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        
        Test.startTest();
        
        List<CC_WS_Casos.CC_WS_Casos_Output> oRes = CC_WS_Casos.createCase(oEntrada);
        
        System.assertNotEquals(oRes, null);
        
        Test.stopTest();
        
    }

    @isTest
    static void crearFormularioWeb_Duplicado() {

        Case caso = new Case(CC_Numero_Documento__c = '47736797K', CC_MailTelfNotif__c = 'TEST@TEST.ES', CC_SuppliedProducto__c = '001',
                            CC_Motivo__c = 'Twitter',Status = 'Activo',CC_Idioma__c = 'es',CC_Tipo_Cliente__c = 'Cliente', Origin = 'Email',
                            CC_Tipo_Contacto__c = 'Consulta', CC_Canal_Procedencia__c='Formulario web');
        //casito.CC_MCC_Motivo__c = motiv.Id;
        //casito.CC_MCC_ProdServ__c = prod.Id;
        //casito.CC_MCC_Tematica__c = tem.Id;
        insert caso;        
        
        List<CC_WS_Casos.CC_WS_Casos_Input> oEntrada = new List<CC_WS_Casos.CC_WS_Casos_Input>();
        CC_WS_Casos.CC_WS_Casos_Input oData = new CC_WS_Casos.CC_WS_Casos_Input();
        List<CC_WS_Casos.CC_WS_Casos_Output> oRes;
        oData.Aplicacion = 'FORMWEB';
        oData.id = 'X';
        oData.entidad = 'X';
        oData.Nombre = 'X';
        oData.Apellido1 = 'X';
        oData.Apellido2 = 'X';
        oData.EMAIL = 'TEST@TEST.ES';
        oData.Telefono = '900606060';
        oData.NIF = '47736797K';
        oData.Cliente = 'X';
        oData.NumOf = 'X';
        oData.ClienteLOE = 'X';
        oData.Codiusu = 'X';
        oData.Producto = '001';
        oData.Ambito = '001';
        oData.Motivo = '001';
        oData.Idioma = 'es';
        oData.Texto = 'X';
        oData.CertificadoDigital = 'X';
        oData.Origen = 'X';
        oData.Referer = 'X';
        oData.User_Agent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        oData.FicherosAdjuntos = 'X';
        oEntrada.add(oData);
        oRes = CC_WS_Casos.createCase(oEntrada);

        String estadoCasoDuplicado = [SELECT Status FROM Case WHERE CC_RefExterna__c = '001-001'].Status;
        System.assertEquals('Pendiente Revisión', estadoCasoDuplicado);
    }

    @isTest
    static void crearFormularioWeb_Robot() {

        List<CC_WS_Casos.CC_WS_Casos_Input> oEntrada = new List<CC_WS_Casos.CC_WS_Casos_Input>();
        
        CC_WS_Casos.CC_WS_Casos_Input oData = new CC_WS_Casos.CC_WS_Casos_Input();
        oData.Aplicacion = 'FORMWEB';
        oData.id = 'X';
        oData.entidad = 'X';
        oData.Nombre = 'X';
        oData.Apellido1 = 'X';
        oData.Apellido2 = 'X';
        oData.EMAIL = 'TEST@TEST.ES';
        oData.Telefono = '900606060';
        oData.NIF = [SELECT CC_Valor__c FROM CC_Valores__mdt WHERE CC_Lista__c = 'CC_MailCenter_Blacklist_NIF' LIMIT 1].CC_Valor__c;
        oData.Cliente = 'X';
        oData.NumOf = 'X';
        oData.ClienteLOE = 'X';
        oData.Codiusu = 'X';
        oData.Producto = '006';
        oData.Ambito = '006';
        oData.Motivo = '006';
        oData.Idioma = 'es';
        oData.Texto = 'X';
        oData.CertificadoDigital = 'X';
        oData.Origen = 'X';
        oData.Referer = 'X';
        oData.User_Agent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        
        Test.startTest();
        
        List<CC_WS_Casos.CC_WS_Casos_Output> oRes = CC_WS_Casos.createCase(oEntrada);
        
        System.assertNotEquals(oRes, null);
        System.assertEquals(oRes[0].sCodError, '4');
        System.assertEquals(oRes[0].sDetalleError, 'NIF incluido en la lista CC_MailCenter_Blacklist_NIF. Petición proveniente del robot de comprobación.');
        
        Test.stopTest();
    }
    
    @isTest
    static void crearMicrobank_01() {
        
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        Id recordTypeIdWeb = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_ConvMCCWeb').getRecordTypeId();
       	CC_MCC__c mccConvWeb = new CC_MCC__c();
        mccConvWeb.Name = 'Test';
        mccConvWeb.CC_Tipo_Cliente__c = 'Cliente';
        mccConvWeb.CC_Equivalencia_Formulario__c = 'MC-001-001-001';
        mccConvWeb.CC_Fecha_Vigencia_Inicio__c = Date.newInstance(2019,05,05);
        mccConvWeb.RecordTypeId = recordTypeIdWeb;
        mccConvWeb.CC_WebMCCTematica__c = mccTematica.Id;
        mccConvWeb.CC_WebMCCProducto__c = mccProducto.Id; 
        mccConvWeb.CC_WebMCCMotivo__c = mccMotivo.Id;
        mccConvWeb.CC_MCCWeb_Origen__c = 'MC';
        mccConvWeb.CC_MCCWeb_Motivo__c = '001';
        mccConvWeb.CC_MCCWeb_Producto__c = '001';
        mccConvWeb.CC_MCCWeb_Ambito__c = '001';
        insert mccConvWeb;
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        a.CC_Numero_Documento__c = '23663942R';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.size(), 1);
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        b.CC_Numero_Documento__c = '23663942R';
        b.AccountId = a.Id;
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.size(), 1);

        List<CC_WS_Casos.CC_WS_Casos_Input> oEntrada = new List<CC_WS_Casos.CC_WS_Casos_Input>();
        
        CC_WS_Casos.CC_WS_Casos_Input oData = new CC_WS_Casos.CC_WS_Casos_Input();
        oData.Aplicacion = 'FORMWEB';
        oData.id = 'X';
        oData.entidad = 'X';
        oData.Nombre = 'X';
        oData.Apellido1 = 'X';
        oData.Apellido2 = 'X';
        oData.EMAIL = 'TEST@TEST.ES';
        oData.Telefono = '900606060';
        oData.NIF = '23663942R';
        oData.Cliente = 'X';
        oData.NumOf = 'X';
        oData.ClienteLOE = 'X';
        oData.Codiusu = 'X';
        oData.Producto = '900';
        oData.Ambito = '020';
        oData.Motivo = '900';
        oData.Idioma = 'es';
        oData.Texto = 'X';
        oData.CertificadoDigital = 'X';
        oData.Origen = 'X';
        oData.Referer = 'X';
        oData.User_Agent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        
        Test.startTest();
        
        List<CC_WS_Casos.CC_WS_Casos_Output> oRes = CC_WS_Casos.createCase(oEntrada);
        
        System.assertNotEquals(oRes, null);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void crearFormularioWeb_CIF() {

        List<CC_WS_Casos.CC_WS_Casos_Input> oEntrada = new List<CC_WS_Casos.CC_WS_Casos_Input>();
        
        CC_WS_Casos.CC_WS_Casos_Input oData = new CC_WS_Casos.CC_WS_Casos_Input();
        oData.Aplicacion = 'FORMWEB';
        oData.id = 'X';
        oData.entidad = 'X';
        oData.Nombre = 'X';
        oData.Apellido1 = 'X';
        oData.Apellido2 = 'X';
        oData.EMAIL = 'TEST@TEST.ES';
        oData.Telefono = '900606060';
        oData.NIF = 'H14962526';
        oData.Cliente = 'X';
        oData.NumOf = 'X';
        oData.ClienteLOE = 'X';
        oData.Codiusu = 'X';
        oData.Producto = '001';
        oData.Ambito = '001';
        oData.Motivo = '001';
        oData.Idioma = 'es';
        oData.Texto = 'X';
        oData.CertificadoDigital = 'X';
        oData.Origen = 'X';
        oData.Referer = 'X';
        oData.User_Agent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        oEntrada.add(oData); //Forzado duplicado.
        
        Test.startTest();
        
        List<CC_WS_Casos.CC_WS_Casos_Output> oRes = CC_WS_Casos.createCase(oEntrada);
        
        System.assertNotEquals(oRes, null);
        
        Test.stopTest();
        
    }
}