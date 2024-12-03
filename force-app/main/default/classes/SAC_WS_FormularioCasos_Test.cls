/*****************************************************************
 * Name: SAC_WS_FormularioCasos_Test
 * Copyright © 2021  CaixaBank
 *
 * Proposito: Clase test de la clase apex SAC_WS_FormularioCasos
 *
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             --             Nicolás García   04/08/21     Creación
*****************************************************************/
@isTest
public class SAC_WS_FormularioCasos_Test {
    
    /*****************************************************************
     * Proposito: Método para creación de formulario
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --            Nicolás García  04/08/21     Creación
    *****************************************************************/
    @TestSetup
    static void makeData(){

        User usuarioGeneral;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0]; 
            usuarioGeneral.Username = 'usertest0@test.com.testSetup';     
            SAC_DatabaseDML.insertDML(usuarioGeneral, false);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);
        }
    }
	@isTest
    static void crearFormularioGGH01() {
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        a.CC_Numero_Documento__c = '23663942R';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.isEmpty(), false, 'No se ha recuperado la cuenta');
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        b.CC_Numero_Documento__c = '23663942R';
        b.AccountId = a.Id;
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.isEmpty(), false, 'No se ha recuperado el contacto');
        
        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
        oData.Aplicacion = 'FORMGGH';
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
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        SAC_WS_FormularioCasos.RepresentanteLegal repLegal = new SAC_WS_FormularioCasos.RepresentanteLegal();
        repLegal.repLegalDoc = '22334455J';
        repLegal.repLegalRazon = 'SOCIEDAD SA';
        repLegal.repTipoDoc = 'DNI';
        SAC_WS_FormularioCasos.GastosReclamados gastoRec = new SAC_WS_FormularioCasos.GastosReclamados();
        gastoRec.gastosGestoria = 1000;
        gastoRec.gastosNotaria = 200;
        gastoRec.gastosOtros = 1000;
        gastoRec.numPrestamo = '1234567';
        gastoRec.totalReclamado = 2200;
        oData.repLegal = true;
        oData.representanteLegal = repLegal;
        oData.gastosReclamados = new List<SAC_WS_FormularioCasos.GastosReclamados>{gastoRec};
        
        oEntrada.add(oData);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = SAC_WS_FormularioCasos.createCase(oEntrada);
            
            System.assertNotEquals(oRes, null, 'Error al crear el caso desde SAC_WS_FormularioCasos');
            Test.stopTest();
        }   
    }
	
    @isTest
    static void crearFormularioFraude01() {
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        a.CC_Numero_Documento__c = '23663942R';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.isEmpty(), false, 'Error al recuperar la cuenta');
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        b.CC_Numero_Documento__c = '23663942R';
        b.AccountId = a.Id;
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.isEmpty(), false, 'Error al recuperar el contacto');

        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
        oData.Aplicacion = 'FORMFRAUDE';
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
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-002';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        oData.repLegal = true;
        SAC_WS_FormularioCasos.RepresentanteLegal repLegal = new SAC_WS_FormularioCasos.RepresentanteLegal();
        repLegal.repLegalDoc = '22334455J';
        repLegal.repLegalRazon = 'SOCIEDAD SA';
        repLegal.repTipoDoc = 'DNI';
        oData.representanteLegal = repLegal;
        SAC_WS_FormularioCasos.OpReclamadas op = new SAC_WS_FormularioCasos.OpReclamadas();
        op.fechas = '21/10/2024';
        op.importe = 1000;
        op.producto = 'prod 01';
        oData.opReclamadas = new List<SAC_WS_FormularioCasos.OpReclamadas>{op};
        oEntrada.add(oData);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = SAC_WS_FormularioCasos.createCase(oEntrada);
           
            System.assertNotEquals(oRes, null, 'Error al crear el caso desde SAC_WS_FormularioCasos');
            Test.stopTest();
        }   
    }

    @isTest
    static void crearFormularioWeb01() {
        
        Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'Oficina';
        SAC_DatabaseDML.insertDML(mccTematica, false);
        
        Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        mccProducto.CC_Canal_Operativo__c = 'Oficina';
        SAC_DatabaseDML.insertDML(mccProducto, false);
        
        Id recordTypeIdMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        mccMotivo.CC_Canal_Operativo__c = 'Oficina';
        SAC_DatabaseDML.insertDML(mccMotivo, false);
        
        Id recordTypeIdWeb = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
       	CC_MCC__c mccConvWeb = new CC_MCC__c();
        mccConvWeb.Name = 'Test';
        mccConvWeb.CC_Tipo_Cliente__c = 'SAC';
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
        mccConvWeb.CC_Canal_Operativo__c = 'Oficina';
        SAC_DatabaseDML.insertDML(mccConvWeb, false);
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        a.CC_Numero_Documento__c = '23663942R';
        SAC_DatabaseDML.insertDML(a, false);
        
        System.assertEquals([SELECT Count() FROM Account WHERE Name = 'Cliente prueba 1'], 1, 'Error al recuperar la cuenta');
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        b.CC_Numero_Documento__c = '23663942R';
        b.AccountId = a.Id;
        SAC_DatabaseDML.insertDML(b, false);
        
        System.assertEquals([SELECT Count() FROM Contact WHERE LastName = 'Contacto prueba 1'], 1, 'Error al recuperar el contacto');

        
        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
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
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        //oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        oEntrada.add(oData); //Forzado duplicado.
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData2 = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
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
        oData2.userAgent = 'X';
        oData2.IP = 'X';
        oData2.REFUSUARIO = '001-001';
        oData2.Tipo = 'X';
        oData2.Web = 'X';
        oData2.Servicio = 'X';
        
        List<Sac_WS_FormularioCasos.WrapperAdjunto> ficherosAdjuntosAux = new List<Sac_WS_FormularioCasos.WrapperAdjunto>();
        
        Sac_WS_FormularioCasos.WrapperAdjunto fichero = new Sac_WS_FormularioCasos.WrapperAdjunto();
        fichero.base64 = 'aaa';
        fichero.extension = 'PDF';
        fichero.nombreFichero = 'prueba';
        
        ficherosAdjuntosAux.add(fichero);
        
        oData2.FicherosAdjuntos = ficherosAdjuntosAux;
        
        oEntrada.add(oData2);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = SAC_WS_FormularioCasos.createCase(oEntrada);
            System.assertNotEquals(oRes, null, 'Error al crear el caso desde SAC_WS_FormularioCasos');
            Test.stopTest();
        }   
    }
    
    @isTest
    static void crearFormularioWeb02() {

        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
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
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        //oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        oEntrada.add(oData); //Forzado duplicado.
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = SAC_WS_FormularioCasos.createCase(oEntrada);
            System.assertNotEquals(oRes, null, 'Error al crear el caso desde SAC_WS_FormularioCasos');
            Test.stopTest();
        }    
    }
    
    @isTest
    static void crearFormularioWeb03() {
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        a.CC_Numero_Documento__c = '23663942R';
        SAC_DatabaseDML.insertDML(a, false);
        
        System.assertEquals([SELECT Count() FROM Account WHERE Name = 'Cliente prueba 1'], 1, 'Error al recuperar la cuenta');
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        b.CC_Numero_Documento__c = '23663942R';
        b.AccountId = a.Id;
        SAC_DatabaseDML.insertDML(b, false);
        
        System.assertEquals([SELECT Count() FROM Contact WHERE LastName = 'Contacto prueba 1'], 1, 'Error al recuperar el contacto');
        
        // Crear cliente.
        Account a1 = new Account();
        a1.Name = '1Cliente prueba 1';
        a1.CC_NumPerso__c = '899910559714';
        a1.CC_Numero_Documento__c = '23663942R';
        SAC_DatabaseDML.insertDML(a1, false);
        
        System.assertEquals([SELECT Count() FROM Account WHERE Name = '1Cliente prueba 1'], 1, 'Error al recuperar la cuenta');
        
        // Crear contacto.
        Contact b1 = new Contact();
        b1.LastName = '1Contacto prueba 1';
        b1.CC_NumPerso__c = '899910559714';
        b1.CC_Numero_Documento__c = '23663942R';
        b1.AccountId = a1.Id;
        SAC_DatabaseDML.insertDML(b1, false);
        
        System.assertEquals([SELECT Count() FROM Contact WHERE LastName = '1Contacto prueba 1'], 1, 'Error al recuperar el contacto');
        
        // Crear cliente.
        Account a11 = new Account();
        a11.Name = '11Cliente prueba 1';
        a11.CC_NumPerso__c = '';
        a11.CC_Numero_Documento__c = '23663942R';
        SAC_DatabaseDML.insertDML(a11, false);
        
        System.assertEquals([SELECT Count() FROM Account WHERE Name = '11Cliente prueba 1'], 1, 'Error al recuperar la cuenta');

        
        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
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
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        //oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        oEntrada.add(oData); //Forzado duplicado.
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData2 = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
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
        oData2.userAgent = 'X';
        oData2.IP = 'X';
        oData2.REFUSUARIO = '001-001';
        oData2.Tipo = 'X';
        oData2.Web = 'X';
        oData2.Servicio = 'X';
        //oData2.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData2);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = SAC_WS_FormularioCasos.createCase(oEntrada);
            System.assertNotEquals(oRes, null, 'Error al crear el caso desde SAC_WS_FormularioCasos');
            Test.stopTest();
        }    
    }
    
    @isTest
    static void crearFormularioWebError01() {

        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
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
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        //oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = SAC_WS_FormularioCasos.createCase(oEntrada);
            System.assertNotEquals(oRes, null, 'Error al crear el caso desde SAC_WS_FormularioCasos');
            Test.stopTest();
        }   
    }
    
    @isTest
    static void crearFormularioWebError02() {

        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
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
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        //oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = SAC_WS_FormularioCasos.createCase(oEntrada);
            System.assertNotEquals(oRes, null, 'Error al crear el caso desde SAC_WS_FormularioCasos');
            Test.stopTest(); 
        }  
    }
    
    @isTest
    static void crearFormularioWebError03() {

        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
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
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        //oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = SAC_WS_FormularioCasos.createCase(oEntrada);
            System.assertNotEquals(oRes, null, 'Error al crear el caso desde SAC_WS_FormularioCasos');
            Test.stopTest();
        }  
    }
    
    @isTest
    static void crearFormularioWebError04() {

        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
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
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        //oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = SAC_WS_FormularioCasos.createCase(oEntrada);
            System.assertNotEquals(oRes, null, 'Error al crear el caso desde SAC_WS_FormularioCasos');
            Test.stopTest();
        }  
    }
    
    @isTest
    static void crearFormularioWebError06() {

        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
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
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        //oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = SAC_WS_FormularioCasos.createCase(oEntrada);
            System.assertNotEquals(oRes, null, 'Error al crear el caso desde SAC_WS_FormularioCasos');
            Test.stopTest(); 
        }   
    }
    
    @isTest
    static void crearFormularioWebError07() {

        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
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
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        //oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = SAC_WS_FormularioCasos.createCase(oEntrada);
            System.assertNotEquals(oRes, null, 'Error al crear el caso desde SAC_WS_FormularioCasos');
            Test.stopTest();
        }    
    }

    /*@isTest
    static void crearFormularioWebDuplicado() {

        Case caso = new Case(CC_Numero_Documento__c = '47736797K', CC_MailTelfNotif__c = 'TEST@TEST.ES', CC_SuppliedProducto__c = '001',
                            CC_Motivo__c = 'Twitter',Status = 'Activo',CC_Idioma__c = 'es',CC_Tipo_Cliente__c = 'Cliente', Origin = 'Email',
                            CC_Tipo_Contacto__c = 'Consulta', CC_Canal_Procedencia__c='Formulario web');
        //casito.CC_MCC_Motivo__c = motiv.Id;
        //casito.CC_MCC_ProdServ__c = prod.Id;
        //casito.CC_MCC_Tematica__c = tem.Id;
        insert caso;        
        
        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes;
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
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        //oData.FicherosAdjuntos = 'X';
        oEntrada.add(oData);
        oRes = SAC_WS_FormularioCasos.createCase(oEntrada);

        String estadoCasoDuplicado = [SELECT Status FROM Case WHERE CC_RefExterna__c = '001-001'].Status;
        System.assertEquals('Pendiente Revisión', estadoCasoDuplicado);
    }*/

    @isTest
    static void crearFormularioWebRobot() {

        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
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
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        //oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = SAC_WS_FormularioCasos.createCase(oEntrada);
            System.assertNotEquals(oRes, null, 'Error al crear el caso desde SAC_WS_FormularioCasos');
            System.assertEquals(oRes[0].sCodError, '4', 'Error al crear el caso desde SAC_WS_FormularioCasos');
            System.assertEquals(oRes[0].sDetalleError, 'NIF incluido en la lista CC_MailCenter_Blacklist_NIF. Petición proveniente del robot de comprobación.', 'Error al crear el caso desde SAC_WS_FormularioCasos');
            Test.stopTest();
        }
    }
    
    @isTest
    static void crearMicrobank01() {
        
        Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'Oficina';
        SAC_DatabaseDML.insertDML(mccTematica, false);
        
        Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        mccProducto.CC_Canal_Operativo__c = 'Oficina';
        SAC_DatabaseDML.insertDML(mccProducto, false);
        
        Id recordTypeIdMotivo =  Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        mccMotivo.CC_Canal_Operativo__c = 'Oficina';
        SAC_DatabaseDML.insertDML(mccMotivo, false);
        
        Id recordTypeIdWeb = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
       	CC_MCC__c mccConvWeb = new CC_MCC__c();
        mccConvWeb.Name = 'Test';
        mccConvWeb.CC_Tipo_Cliente__c = 'SAC';
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
        mccConvWeb.CC_Canal_Operativo__c = 'Oficina';
        SAC_DatabaseDML.insertDML(mccConvWeb, false);
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        a.CC_Numero_Documento__c = '23663942R';
        SAC_DatabaseDML.insertDML(a, false);
        
        System.assertEquals([SELECT Count() FROM Account WHERE Name = 'Cliente prueba 1'], 1, 'Error al recuperar la cuenta');
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        b.CC_Numero_Documento__c = '23663942R';
        b.AccountId = a.Id;
        SAC_DatabaseDML.insertDML(b, false);
        
        System.assertEquals([SELECT Count() FROM Contact WHERE LastName = 'Contacto prueba 1'], 1, 'Error al recuperar el contacto');

        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
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
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        //oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = SAC_WS_FormularioCasos.createCase(oEntrada);
            System.assertNotEquals(oRes, null, 'Error al crear el caso desde SAC_WS_FormularioCasos');
            Test.stopTest();
        }  
    }
    
    @isTest
    static void crearFormularioWebCIF() {

        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
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
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        //oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        oEntrada.add(oData); //Forzado duplicado.
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = SAC_WS_FormularioCasos.createCase(oEntrada);
            System.assertNotEquals(oRes, null, 'Error al crear el caso desde SAC_WS_FormularioCasos');
            Test.stopTest();
        }   
    }

    @isTest
    static void crearFormularioWebVacio() {

        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
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
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        //oData.FicherosAdjuntos = 'X';
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData2 = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
        oData2.Aplicacion = null;
        oData2.id = null;
        oData2.entidad = null;
        oData2.Nombre = null;
        oData2.Apellido1 = null;
        oData2.Apellido2 = null;
        oData2.EMAIL = null;
        oData2.Telefono = null;
        oData2.NIF = null;
        oData2.Cliente = null;
        oData2.NumOf = null;
        oData2.ClienteLOE = null;
        oData2.Codiusu = null;
        oData2.Producto = null;
        oData2.Ambito = null;
        oData2.Motivo = null;
        oData2.Idioma = null;
        oData2.Texto = null;
        oData2.CertificadoDigital = null;
        oData2.Origen = null;
        oData2.Referer = null;
        oData2.userAgent = null;
        oData2.IP = null;
        oData2.REFUSUARIO = null;
        oData2.Tipo = null;
        oData2.Web = null;
        oData2.Servicio = null;

        oEntrada.add(oData);
        oEntrada.add(oData2);
       

        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output>();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            oRes = SAC_WS_FormularioCasos.createCase(oEntrada);
            //System.assertNotEquals(oRes, null);
            Test.stopTest();
        }   
        Assert.areNotEqual(oRes.size(), 0, 'No se ha obtenido el resultado esperado');
    }

    @isTest
    static void crearFormularioWebIA() {

        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c();
        settings.Name = 'SAC_Formulario';
        settings.SAC_IAactiva__c = true;
        settings.SAC_Shadow__c = false;
        settings.SAC_Porcentaje__c = 100;
            
        SAC_DatabaseDML.insertDML(settings, false);
        
        Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'Oficina';
        SAC_DatabaseDML.insertDML(mccTematica, false);
        
        Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        mccProducto.CC_Canal_Operativo__c = 'Oficina';
        SAC_DatabaseDML.insertDML(mccProducto, false);
        
        Id recordTypeIdMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        mccMotivo.CC_Canal_Operativo__c = 'Oficina';
        SAC_DatabaseDML.insertDML(mccMotivo, false);
        
        Id recordTypeIdWeb = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
       	CC_MCC__c mccConvWeb = new CC_MCC__c();
        mccConvWeb.Name = 'Test';
        mccConvWeb.CC_Tipo_Cliente__c = 'SAC';
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
        mccConvWeb.CC_Canal_Operativo__c = 'Oficina';
        SAC_DatabaseDML.insertDML(mccConvWeb, false);
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        a.CC_Numero_Documento__c = '23663942R';
        SAC_DatabaseDML.insertDML(a, false);
        
        System.assertEquals([SELECT Count() FROM Account WHERE Name = 'Cliente prueba 1'], 1, 'Error al recuperar la cuenta');
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        b.CC_Numero_Documento__c = '23663942R';
        b.AccountId = a.Id;
        SAC_DatabaseDML.insertDML(b, false);
        
        System.assertEquals([SELECT Count() FROM Contact WHERE LastName = 'Contacto prueba 1'], 1, 'Error al recuperar el contacto');

        
        List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input> oEntrada = new List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input>();
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
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
        oData.userAgent = 'X';
        oData.IP = 'X';
        oData.REFUSUARIO = '001-001';
        oData.Tipo = 'X';
        oData.Web = 'X';
        oData.Servicio = 'X';
        //oData.FicherosAdjuntos = 'X';
        
        oEntrada.add(oData);
        oEntrada.add(oData); //Forzado duplicado.
        
        SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input oData2 = new SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Input();
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
        oData2.userAgent = 'X';
        oData2.IP = 'X';
        oData2.REFUSUARIO = '001-001';
        oData2.Tipo = 'X';
        oData2.Web = 'X';
        oData2.Servicio = 'X';
        
        List<Sac_WS_FormularioCasos.WrapperAdjunto> ficherosAdjuntosAux = new List<Sac_WS_FormularioCasos.WrapperAdjunto>();
        
        Sac_WS_FormularioCasos.WrapperAdjunto fichero = new Sac_WS_FormularioCasos.WrapperAdjunto();
        fichero.base64 = 'aaa';
        fichero.extension = 'PDF';
        fichero.nombreFichero = 'prueba';
        
        ficherosAdjuntosAux.add(fichero);
        
        oData2.FicherosAdjuntos = ficherosAdjuntosAux;
        
        oEntrada.add(oData2);
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_WS_FormularioCasos.SAC_WS_FormularioCasos_Output> oRes = SAC_WS_FormularioCasos.createCase(oEntrada);
            System.assertNotEquals(oRes, null, 'Error al crear el caso desde SAC_WS_FormularioCasos');
            Test.stopTest();
        }   
    }
}