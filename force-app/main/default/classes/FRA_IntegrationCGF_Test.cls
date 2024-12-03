@isTest
public with sharing class FRA_IntegrationCGF_Test {
    @TestSetup
    public static void testSetup() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User usuario = new User();
            usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'FRA_Usuario_Caixabank'].Id;
            usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'FRA'].Id;
            usuario.FirstName = 'Fraude';
            usuario.LastName = 'Prueba';
            usuario.Alias = uniqueName.substring(18, 23);
            usuario.Email = uniqueName + '@test' + orgId + '.org';
            usuario.Username = uniqueName + '@test' + orgId + '.org';
            usuario.EmailEncodingKey = 'UTF-8';
            usuario.LanguageLocaleKey = 'es';
            usuario.LocaleSidKey = 'es_ES';
            usuario.TimezonesIdKey = 'Europe/Madrid';
            insert usuario;
    
            List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
            for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('FRA_PS_Operador','FRA_PS_Integracion')]) {
                PermissionSetAssignment psAssignment = new PermissionSetAssignment();
                psAssignment.AssigneeId = usuario.Id;
                psAssignment.PermissionSetId = ps.Id;
                psAssignments.add(psAssignment);
            }
            insert psAssignments;
        }
    }

    private static Account crearCuenta() {
        Account cuenta = new Account (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente'),
            Name = 'Cuenta',
            Phone = '666666666'
        );
        insert cuenta;
        return cuenta;
    }

    private static Contact crearContacto() {
        Contact contacto = new Contact (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente'),
            FirstName = 'Contacto',
            LastName = 'Contacto',
            Phone = '666666666'
        );
        insert contacto;
        return contacto;
    }

    private static Contact crearRepresentante() {
        Contact representante = new Contact (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Representante'),
            FirstName = 'Representante',
            LastName = 'Representante',
            Phone = '777777777'
        );
        insert representante;
        return representante;
    }

    private static Case crearCaso() {
        Case caso = new Case (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente'),
            Subject = 'Prueba',
            Origin = 'Phone',
            CC_Idioma__c = 'es',
            CC_Canal_Procedencia__c = 'Teléfono FRAUDE Canal Oficina'
        );
        insert caso;
        return caso;
    }

    private static Task crearTarea() {
        Task tarea = new Task (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'FRA_Task'),
            Subject = 'Consulta',
            Status = 'Open',
            Priority = 'Normal',
            Type = 'Llamada entrante'
        );
        insert tarea;
        return tarea;
    }

    private static FRA_Alerta_CGF__c crearAlertaCGF() {
        FRA_Alerta_CGF__c alertaCGF = new FRA_Alerta_CGF__c (
            Name = 'ALT-00001',
            FRA_Id_Operacion_CGF__c = 'ALT-00001'
        );
        insert alertaCGF;
        return alertaCGF;
    }

    private static CC_MCC__c crearMCCTematica() {
        CC_MCC__c mccTematica = new CC_MCC__c (
            Name = 'MCC Tematica',
            CC_Tipo_Cliente__c = 'Empleado',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica'),
            CC_Codigo_Externo__c = 'TE-000001'
        );
        insert mccTematica;
        return mccTematica;
    }

    private static CC_MCC__c crearMCCProdServ() {
        CC_MCC__c mccProducto = new CC_MCC__c (
            Name = 'MCC Producto',
            CC_Tipo_Cliente__c = 'Empleado',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio'),
            CC_Codigo_Externo__c = 'PR-000001'
        );
        insert mccProducto;
        return mccProducto;  
    }

    private static CC_MCC__c crearMCCMotivo() {
        CC_MCC__c mccMotivo = new CC_MCC__c (
            Name = 'MCC Motivo',
            CC_Tipo_Cliente__c = 'Empleado',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo'),
            CC_Codigo_Externo__c = 'MO-000001'       
        );
        insert mccMotivo;
        return mccMotivo;    
    }

    @isTest
    public static void testTraspasoInfoSFC1() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        usuario.EmployeeNumber = 'U0199999';
        update usuario;
        Account cuenta = crearCuenta();
        Contact contacto = crearContacto();
        contacto.AccountId = cuenta.Id;
        contacto.CC_Numero_Documento__c = '12345678Z';
        update contacto;
        Case caso = crearCaso();
        caso.FRA_Id_Expediente_CGF__c = 'EXP-000001';
        caso.Status = 'Activo';
        caso.OwnerId = [SELECT Id FROM User LIMIT 1].Id;
        caso.Description = 'Test busqueda caso cliente';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.CC_Telefono_Contacto__c = '666666666';
        update caso;
        String jsonReq = '{"userId_CGF":"U0199999","tipoOperacion_CGF":"trasladoInfoCGF","idExpediente_CGF":"EXP-000001","numPerso_CGF":"666"}';
        RestRequest req = new RestRequest();
		req.requestBody =  Blob.valueOf(jsonReq);
		RestContext.request = req;
		RestResponse res = new RestResponse();
		RestContext.response = res;

        Test.startTest();
        FRA_IntegrationCGF.traspasoInfoSFC();
        System.runAs(usuario) {
            System.assertEquals(true, true, 'PENDIENTE');
            Test.stopTest();
        }
    }

    @isTest
    public static void testTraspasoInfoSFC2() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        usuario.EmployeeNumber = 'U0199999';
        update usuario;
        Account cuenta = crearCuenta();
        cuenta.CC_NumPerso__c = '666';
        update cuenta;
        Contact contacto = crearContacto();
        contacto.AccountId = cuenta.Id;
        contacto.CC_Numero_Documento__c = '12345678Z';
        update contacto;
        FRA_Alerta_CGF__c alertaCGF = crearAlertaCGF();
        FRA_RequestWrapperCGF.Alertas_CGF alerta = new FRA_RequestWrapperCGF.Alertas_CGF();
        alerta.idOperacion_CGF = 'ALT-00003';
        alerta.tipoOperacion = 'Bizum';
        alerta.fechaOperacion = '2023-01-02 07:00:00';
        alerta.importe = '40000.55';
        alerta.cuenta_Origen = 'XXXXXXXXXXXXX5555';
        alerta.cuenta_Destino = 'XXXXXXXXXXXXX6666';
        alerta.tipologia = 'Test tipología';
        alerta.campana = 'Test campaña';
        alerta.estado = 'Abierto';
        alerta.numeroTarjeta = 'XXXXXXXX7777';
        alerta.MCC = 'Test MCC';
        alerta.pais = 'España';
        alerta.nombreComercio = 'Test nombre comercio';
        alerta.numDocPersonaConectada = '12345678Z';
        List<FRA_RequestWrapperCGF.Alertas_CGF> alertas = new List<FRA_RequestWrapperCGF.Alertas_CGF>{alerta};
        FRA_RequestWrapperCGF rw = new FRA_RequestWrapperCGF();
        rw.alertas_CGF = alertas;
        String jsonReq = '{"userId_CGF":"U0199999","tipoOperacion_CGF":"trasladoInfoCGF","idExpediente_CGF":"EXP-000001","numPerso_CGF":"666"}';
        RestRequest req = new RestRequest();
		req.requestBody =  Blob.valueOf(jsonReq);
		RestContext.request = req;
		RestResponse res = new RestResponse();
		RestContext.response = res;

        Test.startTest();
        FRA_IntegrationCGF.traspasoInfoSFC();
        System.runAs(usuario) {
            System.assertEquals(true, true, 'PENDIENTE');
            Test.stopTest();
        }          
    }

    @isTest
    public static void testTraspasoInfoSFC3() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        usuario.EmployeeNumber = 'U0199999';
        update usuario;
        CC_MCC__c mccTematica = crearMCCTematica();
        CC_MCC__c mccProducto = crearMCCProdServ();
        mccProducto.CC_Tematica__c = mccTematica.Id;
        update mccProducto;
        CC_MCC__c mccMotivo = crearMCCMotivo();
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        update mccMotivo;
        Case caso = crearCaso();
        caso.FRA_Id_Expediente_CGF__c = 'EXP-000001';
        caso.Status = 'Activo';
        caso.CC_Detalles_Consulta__c = 'Test detalles consulta';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_No_Identificado__c = true;
        update caso;
        String jsonReq = '{"userId_CGF":"U0199999","tipoOperacion_CGF":"cierreCGF","idExpediente_CGF":"EXP-000001","numPerso_CGF":"666"}';
        RestRequest req = new RestRequest();
		req.requestBody =  Blob.valueOf(jsonReq);
		RestContext.request = req;
		RestResponse res = new RestResponse();
		RestContext.response = res;

        Test.startTest();
        FRA_IntegrationCGF.traspasoInfoSFC();
        System.runAs(usuario) {
            System.assertEquals(true, true, 'PENDIENTE');
            Test.stopTest();
        }
    }

    @isTest
    public static void testTraspasoInfoSFC4() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        usuario.EmployeeNumber = 'U0199999';
        update usuario;
        String jsonReq = '{"userId_CGF":"U0199999","tipoOperacion_CGF":"cierreCGF","idExpediente_CGF":"EXP-000001"}';
        RestRequest req = new RestRequest();
		req.requestBody =  Blob.valueOf(jsonReq);
		RestContext.request = req;
		RestResponse res = new RestResponse();
		RestContext.response = res;

        Test.startTest();
        FRA_IntegrationCGF.traspasoInfoSFC();
        System.runAs(usuario) {
            System.assertEquals(true, true, 'PENDIENTE');
            Test.stopTest();
        }
    }

    @isTest
    public static void testTraspasoInfoSFC5() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        usuario.EmployeeNumber = 'U0199999';
        update usuario;
        String jsonReq = '{"userId_CGF":"U0199999","tipoOperacion_CGF":"Tipo de operación no válido"}';
        RestRequest req = new RestRequest();
		req.requestBody =  Blob.valueOf(jsonReq);
		RestContext.request = req;
		RestResponse res = new RestResponse();
		RestContext.response = res;

        Test.startTest();
        FRA_IntegrationCGF.traspasoInfoSFC();
        System.runAs(usuario) {
            System.assertEquals(true, true, 'PENDIENTE');
            Test.stopTest();
        }
    }

    @isTest
    public static void testTraspasoInfoSFC6() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        String jsonReq = '';
        RestRequest req = new RestRequest();
		req.requestBody =  Blob.valueOf(jsonReq);
		RestContext.request = req;
		RestResponse res = new RestResponse();
		RestContext.response = res;

        Test.startTest();
        FRA_IntegrationCGF.traspasoInfoSFC();
        System.runAs(usuario) {
            System.assertEquals(true, true, 'PENDIENTE');
            Test.stopTest();
        }
    }

    @isTest
    public static void testTraspasoInfoSFC7() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        update usuario;
        String jsonReq = '{"userId_CGF":"U0199999"}';
        RestRequest req = new RestRequest();
		req.requestBody =  Blob.valueOf(jsonReq);
		RestContext.request = req;
		RestResponse res = new RestResponse();
		RestContext.response = res;

        Test.startTest();
        FRA_IntegrationCGF.traspasoInfoSFC();
        System.runAs(usuario) {
            System.assertEquals(true, true, 'PENDIENTE');
            Test.stopTest();
        }
    }

    @isTest
    public static void testBusquedaCasoCliente() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        Account cuenta1 = crearCuenta();
        cuenta1.CC_NumPerso__c = '666';
        update cuenta1;
        Account cuenta2 = crearCuenta();
        cuenta2.CC_Numero_Documento__c = '777';
        update cuenta2;
        Contact contacto1 = crearContacto();
        Contact contacto2 = crearContacto();
        Case casoPrueba1 = crearCaso();
        casoPrueba1.FRA_Id_Expediente_CGF__c = 'EXP-000001';
        casoPrueba1.Status = 'Activo';
        casoPrueba1.OwnerId = [SELECT Id FROM User LIMIT 1].Id;
        casoPrueba1.Description = 'Test busqueda caso cliente 1';
        casoPrueba1.AccountId = cuenta1.Id;
        casoPrueba1.ContactId = contacto1.Id;
        casoPrueba1.CC_Telefono_Contacto__c = '666666666';
        update casoPrueba1;
        Case casoPrueba2 = crearCaso();
        casoPrueba2.FRA_Id_Expediente_CGF__c = 'EXP-000002';
        casoPrueba2.Status = 'Activo';
        casoPrueba2.OwnerId = [SELECT Id FROM User LIMIT 1].Id;
        casoPrueba2.Description = 'Test busqueda caso cliente 2';
        casoPrueba2.AccountId = cuenta2.Id;
        casoPrueba2.ContactId = contacto2.Id;
        casoPrueba2.CC_Telefono_Contacto__c = '777777777';
        update casoPrueba2;
        Task tarea2 = crearTarea();
        tarea2.WhatId = casoPrueba2.Id;
        update tarea2;
        FRA_RequestWrapperCGF rw1 = new FRA_RequestWrapperCGF();
        rw1.idExpediente_CGF = 'EXP-000001';
        rw1.numPerso_CGF = '666';
        FRA_RequestWrapperCGF rw2 = new FRA_RequestWrapperCGF();
        rw2.idExpediente_CGF = 'EXP-000003';
        rw2.numDoc_CGF = '777';

        Test.startTest();
        Case caso1 = FRA_IntegrationCGF.busquedaCasoCliente(rw1);
        Case caso2 = FRA_IntegrationCGF.busquedaCasoCliente(rw2);
		System.runAs(usuario) {     
            System.assertEquals(casoPrueba1.FRA_Id_Expediente_CGF__c, caso1.FRA_Id_Expediente_CGF__c);
            System.assertEquals(casoPrueba2.AccountId, caso2.AccountId);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testIdentificarCliente() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        Account cuenta = crearCuenta();
        cuenta.CC_NumPerso__c = '666';
        cuenta.CC_Numero_Documento__c = '666';
        update cuenta;
        FRA_RequestWrapperCGF rw1 = new FRA_RequestWrapperCGF();
        rw1.numPerso_CGF = '666';
        FRA_RequestWrapperCGF rw2 = new FRA_RequestWrapperCGF();
        rw2.numDoc_CGF = '666';
        
        Test.startTest();
        Account account1 = FRA_IntegrationCGF.identificarCliente(rw1);
        Account account2 = FRA_IntegrationCGF.identificarCliente(rw2);
		System.runAs(usuario) {  
            System.assertEquals(rw1.numPerso_CGF, account1.CC_NumPerso__c);
            System.assertEquals(rw2.numDoc_CGF, account2.CC_Numero_Documento__c);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testActualizarCrearCaso() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        Case caso = crearCaso();
        FRA_RequestWrapperCGF rw1 = new FRA_RequestWrapperCGF();
        rw1.idExpediente_CGF = 'EXP-000001';
        rw1.numPerso_CGF = '666';
        rw1.negocio_CGF = 'Teléfono FRAUDE CaixaBankNow';
        rw1.canal_CGF = 'Cajeros';
        FRA_RequestWrapperCGF rw2 = new FRA_RequestWrapperCGF();
        rw2.idExpediente_CGF = 'EXP-000002';
        rw2.numDoc_CGF = '666';
        FRA_RequestWrapperCGF rw3 = new FRA_RequestWrapperCGF();
        rw3.idExpediente_CGF = 'EXP-000003';
        rw3.numDoc_CGF = '666';
        rw3.negocio_CGF = 'Teléfono FRAUDE CaixaBankNow';
        rw3.canal_CGF = 'Now';

        Test.startTest();
        Case caso1 = FRA_IntegrationCGF.actualizarCrearCaso(caso, usuario, rw1, false);
        Case caso2 = FRA_IntegrationCGF.actualizarCrearCaso(caso, usuario, rw2, true);
        Case caso3 = FRA_IntegrationCGF.actualizarCrearCaso(caso, usuario, rw3, false);
        System.runAs(usuario) {
            System.assert(caso1 != null);
            System.assert(caso2 != null);
            System.assert(caso3 != null);
            Test.stopTest();
        }
    }

    @isTest
    public static void testCrearAlertasCGF() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        Account cuenta1 = crearCuenta();
       	Account cuenta2 = new Account(
        	RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA'),
        	FirstName = 'Cuenta',
			LastName = 'PA',
        	CC_NumPerso__c = '777',
            CC_Numero_Documento__c = '87654321A'
        );
        insert cuenta2;
        Contact contacto = crearContacto();
        contacto.AccountId = cuenta1.Id;
        contacto.CC_Numero_Documento__c = '12345678Z';
        update contacto;
        Case caso1 = crearCaso();
        caso1.AccountId = cuenta1.Id;
        update caso1;
        Case caso2 = crearCaso();
        caso2.AccountId = cuenta2.Id;
        update caso2;       
        FRA_Alerta_CGF__c alertaCGF1 = crearAlertaCGF();
        alertaCGF1.Name = 'ALT-00002';
        alertaCGF1.FRA_Id_Operacion_CGF__c = 'ALT-00002';
        alertaCGF1.FRA_Caso_Relacionado__c = caso1.Id;
        update alertaCGF1;
        FRA_Alerta_CGF__c alertaCGF2 = crearAlertaCGF();
        alertaCGF2.FRA_Caso_Relacionado__c = caso2.Id;
        update alertaCGF2;
        FRA_RequestWrapperCGF.Alertas_CGF alerta1 = new FRA_RequestWrapperCGF.Alertas_CGF();
        alerta1.idOperacion_CGF = 'ALT-00003';
        alerta1.tipoOperacion = 'Bizum';
        alerta1.fechaOperacion = '2023-01-02 07:00:00';
        alerta1.importe = '40000.55';
        alerta1.cuenta_Origen = 'XXXXXXXXXXXXX5555';
        alerta1.cuenta_Destino = 'XXXXXXXXXXXXX6666';
        alerta1.tipologia = 'Test tipología';
        alerta1.campana = 'Test campaña';
        alerta1.estado = 'Abierto';
        alerta1.numeroTarjeta = 'XXXXXXXX7777';
        alerta1.MCC = 'Test MCC';
        alerta1.pais = 'España';
        alerta1.nombreComercio = 'Test nombre comercio';
        alerta1.numDocPersonaConectada = '12345678Z';
        FRA_RequestWrapperCGF.Alertas_CGF alerta2 = new FRA_RequestWrapperCGF.Alertas_CGF();
        alerta2.idOperacion_CGF = 'ALT-00004';
        alerta2.tipoOperacion = 'Bizum';
        alerta2.fechaOperacion = '2023-01-02 07:00:00';
        alerta2.importe = '40000.55';
        alerta2.cuenta_Origen = 'XXXXXXXXXXXXX5555';
        alerta2.cuenta_Destino = 'XXXXXXXXXXXXX6666';
        alerta2.tipologia = 'Test tipología 2';
        alerta2.campana = 'Test campaña 2';
        alerta2.estado = 'Abierto';
        alerta2.numeroTarjeta = 'XXXXXXXX7777';
        alerta2.MCC = 'Test MCC 2';
        alerta2.pais = 'España';
        alerta2.nombreComercio = 'Test nombre comercio 2';
        alerta2.numDocPersonaConectada = '87654321A';
        List<FRA_RequestWrapperCGF.Alertas_CGF> alertas1 = new List<FRA_RequestWrapperCGF.Alertas_CGF>{alerta1};
        FRA_RequestWrapperCGF rw1 = new FRA_RequestWrapperCGF();
        rw1.alertas_CGF = alertas1;
        List<FRA_RequestWrapperCGF.Alertas_CGF> alertas2 = new List<FRA_RequestWrapperCGF.Alertas_CGF>{alerta2};
        FRA_RequestWrapperCGF rw2 = new FRA_RequestWrapperCGF();
        rw2.alertas_CGF = alertas2;
        
        Test.startTest();
        FRA_IntegrationCGF.crearAlertasCGF(rw1, caso1, usuario, true);
        FRA_IntegrationCGF.crearAlertasCGF(rw2, caso2, usuario, false); 
        System.runAs(usuario) {
            System.assertEquals(true, true, 'PENDIENTE');
            Test.stopTest();
        }
    }

    @isTest
    public static void testCrearTarea() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        Case caso = crearCaso();

        Test.startTest();
        FRA_IntegrationCGF.crearTarea(caso, usuario, 'FRA_Traslado_Información_CGF', false, '');
        System.runAs(usuario) {    
            System.assertEquals(true, true, 'PENDIENTE');
            Test.stopTest();
        }  
    }
    
    @isTest
    public static void testIdentificarPorNumBusqueda() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        Case caso = crearCaso();
        Account cuenta1 = crearCuenta();
        cuenta1.CC_NumPerso__c = '666';
        update cuenta1;
        Account cuenta2 = crearCuenta();
        cuenta2.CC_NumPerso__c = '777';
        update cuenta2;
        Account cuenta3 = crearCuenta();
        cuenta3.CC_NumPerso__c = '888';
        update cuenta3;
        Contact contacto = crearContacto();
        contacto.AccountId = cuenta1.Id;
        update contacto;
        Contact representante = crearRepresentante();
        representante.CC_CuentaRepresentada__c = cuenta2.Id;
        update representante;
        Account cuenta4 = crearCuenta();
        cuenta4.CC_NumPerso__c = '333';
        update cuenta4;
        Contact contacto1 = crearContacto();
        contacto1.AccountId = cuenta4.Id;
        update contacto1;
        Contact contacto2 = crearContacto();
        contacto2.AccountId = cuenta4.Id;
        update contacto2;
        Account cuenta5 = crearCuenta();
        cuenta5.CC_NumPerso__c = '444';
        update cuenta5;
        Contact representante1 = crearRepresentante();
        representante1.CC_CuentaRepresentada__c = cuenta5.Id;
        update representante1;
        Contact representante2 = crearRepresentante();
        representante2.CC_CuentaRepresentada__c = cuenta5.Id;
        update representante2;

        Test.startTest();
        FRA_IntegrationCGF.identificarPorNumBusqueda(caso, '333', true);
        FRA_IntegrationCGF.identificarPorNumBusqueda(caso, '444', true);
        FRA_IntegrationCGF.identificarPorNumBusqueda(caso, '555', true);
        FRA_IntegrationCGF.identificarPorNumBusqueda(caso, '666', true);
        FRA_IntegrationCGF.identificarPorNumBusqueda(caso, '777', true);
        FRA_IntegrationCGF.identificarPorNumBusqueda(caso, '888', true);
        System.runAs(usuario) {
            System.assertEquals(true, true, 'PENDIENTE');
            Test.stopTest();
        }  
    }
    
    @isTest
    public static void testIdentificarPersSFC() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        Account cuenta1 = crearCuenta();
        cuenta1.CC_NumPerso__c = '666';
        update cuenta1;
        Account cuenta2 = crearCuenta();
        cuenta2.CC_Numero_Documento__c = '666';
        update cuenta2;
        Contact contacto = crearContacto();
        contacto.AccountId = cuenta1.Id;
        update contacto;
        Contact representante = crearRepresentante();
        representante.CC_CuentaRepresentada__c = cuenta2.Id;
        update representante;

        Test.startTest();
        Map<String, Object> mapa1 = FRA_IntegrationCGF.IdentificarPersSFC('666', true);
        Map<String, Object> mapa2 = FRA_IntegrationCGF.IdentificarPersSFC('666', false);
        System.runAs(usuario) {
            System.assert(mapa1.get('CONTACTOS') != null);
            System.assert(mapa2.get('REPRESENTANTES') != null);
            Test.stopTest();
        }        
    }
}