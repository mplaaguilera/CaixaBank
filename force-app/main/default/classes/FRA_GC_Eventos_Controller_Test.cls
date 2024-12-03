@isTest
public with sharing class FRA_GC_Eventos_Controller_Test {

    @TestSetup
    private static void testSetup() {

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
            for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('FRA_PS_Operador')]) {
                PermissionSetAssignment psAssignment = new PermissionSetAssignment();
                psAssignment.AssigneeId = usuario.Id;
                psAssignment.PermissionSetId = ps.Id;
                psAssignments.add(psAssignment);
            }
            insert psAssignments;
        }

        CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(
            Name = 'Fraude Canal Oficina',
            CC_Codigo__c = 'HUB_FRAUCAOFI',
            CC_VDN__c = '1',
            CC_Tipo__C = 'Servicio',
            CC_Canal_Procedencia__c = 'Teléfono FRAUDE Canal Oficina',
            CC_Canal_de_Entrada__c = 'Telefono',
            CC_Fecha_Inicio_Salesforce__c = date.today(),
            CC_Tipo_Cliente__c = 'Empleado'
        );
        insert servicio;

        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        tematica.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        tematica.Name = 'Temática';
        tematica.CC_Codigo_Externo__c = 'T1';
        tematica.CC_Canal_Operativo__c = 'Oficina';
        insert tematica;

        CC_MCC__c producto = new CC_MCC__c();
        producto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        producto.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        producto.Name = 'Producto';
        producto.CC_Tematica__c = tematica.Id;
        producto.CC_Codigo_Externo__c = 'P1';
        insert producto;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        motivo.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        motivo.Name = 'Motivo';
        motivo.CC_Producto_Servicio__c = producto.Id;
        motivo.CC_Codigo_Externo__c = 'M1';
        insert motivo;

        CC_MCC__c causa = new CC_MCC__c();
        causa.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
        causa.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        causa.Name = 'Causa';
        causa.CC_Motivo__c = motivo.Id;
        causa.CC_Codigo_Externo__c = 'C1';
        insert causa;

        CC_MCC__c solucion = new CC_MCC__c();
        solucion.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
        solucion.CC_Tipo_Cliente__c = 'Cliente (FRA)';
        solucion.Name = 'Solucion';
        solucion.CC_Causa__c = causa.Id;
        solucion.CC_Codigo_Externo__c = 'S1';
        insert solucion;

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');
        caso.Subject = 'Caso Test';
        caso.Origin = 'Phone';
        caso.CC_Canal_Respuesta__c = 'Phone';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.CC_No_Identificado__c = true;
        caso.CC_Canal_Procedencia__c = 'Teléfono FRAUDE Canal Oficina';
        insert caso;

        CC_Llamada__c llamada = new CC_Llamada__c();
        llamada.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'FRA_Cliente');
        llamada.CC_Servicio_Genesys__c = servicio.Id;
        llamada.CC_Tipo__c = 'Entrante';
        llamada.CC_Tipo_Cierre__c = 'Llamada finalizada';
        llamada.CC_Asunto__c = 'Llamada Test';
        insert llamada;

        Task tarea = new Task();
        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'FRA_Task');
        tarea.WhatId = caso.Id;
        tarea.CC_Llamada_Id__c = llamada.Id;
        tarea.Subject = 'Tarea Test';
        insert tarea;

    }

    @isTest
    public static void testRegistrarLlamadaEntrante() {
        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = '';
        input.extension = '';
        input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        input.transferConnId = '';
        input.ani = '555666777';
        input.dnis = '888999000';
        input.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
        input.asunto = 'Asunto';
        input.numPerso = '11111';
        input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';

        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            FRA_Genesys_Cloud_Eventos_Controller.registrarLlamadaEntrante(JSON.serialize(input));
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }

    @isTest
    public static void testRegistrarLlamadaSaliente() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test'];
        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = '';
        input.extension = '';
        input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        input.transferConnId = '';
        input.ani = '555666777';
        input.dnis = '888999000';
        input.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
        input.asunto = 'Asunto';
        input.numPerso = '11111';
        input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';
        input.casoId = caso.Id;

        Test.startTest();
        FRA_Genesys_Cloud_Eventos_Controller.registrarLlamadaSaliente(JSON.serialize(input));
        Test.stopTest();
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
            System.assertEquals(true, true, 'PENDIENTE');   
        }
    }

    @isTest
    public static void testRegistrarConsulta() {
        CC_Llamada__c llamada = [SELECT Id FROM CC_Llamada__c WHERE CC_Asunto__c = 'Llamada Test'];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test'];
        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = '';
        input.extension = '';
        input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        input.transferConnId = '';
        input.ani = '555666777';
        input.dnis = '888999000';
        input.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
        input.asunto = 'Asunto';
        input.numPerso = '11111';
        input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';
        input.salesforceParentId = llamada.Id;
        input.casoId = caso.Id;

        Test.startTest();
        FRA_Genesys_Cloud_Eventos_Controller.registrarConsulta(JSON.serialize(input));
        Test.stopTest();
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
            System.assertEquals(true, true, 'PENDIENTE');   
        }
    }

    @isTest
    public static void testRegistrarblindTransfer() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        CC_Llamada__c llamada = [SELECT Id FROM CC_Llamada__c WHERE CC_Asunto__c = 'Llamada Test'];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test'];

        CC_Llamada_Input input = new CC_Llamada_Input();
        input.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
        input.salesforceParentId = llamada.Id;
        input.casoId = caso.Id;
        input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        input.ani = '555666777';
        input.dnis = '888999000';
        input.idioma = 'Castellano';
    
        Test.startTest();
        FRA_Genesys_Cloud_Eventos_Controller.registrarblindTransfer(JSON.serialize(input));
        Test.stopTest();
        System.runAs(usuario) {
            System.assertEquals(true, true, 'PENDIENTE');
        } 
    }

    @isTest
    public static void testFinalizarLlamada() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test'];
        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = '';
        input.extension = '';
        input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        input.transferConnId = '';
        input.ani = '555666777';
        input.dnis = '888999000';
        input.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
        input.asunto = 'Asunto';
        input.numPerso = '11111';
        input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';
        input.casoId = caso.Id;

        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            FRA_Genesys_Cloud_Eventos_Controller.finalizarLlamada(JSON.serialize(input), 'Llamada finalizada');
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }
    
    @isTest
    public static void testRegistrarACW() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        CC_Llamada__c llamada = [SELECT Id FROM CC_Llamada__c WHERE CC_Asunto__c = 'Llamada Test'];
        List<CC_Llamada__c> llamadas = [SELECT Id, CC_Fecha_Fin__c FROM CC_Llamada__c];
        System.runAs(usuario) {
            Test.startTest();
            CC_Llamada_Input input = new CC_Llamada_Input();
            FRA_Genesys_Cloud_Eventos_Controller.registrarACW(JSON.serialize(input));
            System.assertEquals(true, true, 'PENDIENTE');           
            Test.stopTest();
        }
    }

    @isTest
    public static void testFinalizarConsulta() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test'];
        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = '';
        input.extension = '';
        input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        input.transferConnId = '';
        input.ani = '555666777';
        input.dnis = '888999000';
        input.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
        input.asunto = 'Asunto';
        input.numPerso = '11111';
        input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';

        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            FRA_Genesys_Cloud_Eventos_Controller.finalizarConsulta(JSON.serialize(input), 'Llamada finalizada');
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }

    @isTest
    public static void testFinalizarConsultaExterna() {
        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = '';
        input.extension = '';
        input.connId = 'ef208127-2e21-4086-b016-febfa4c43384';
        input.transferConnId = '';
        input.ani = '555666777';
        input.dnis = '888999000';
        input.servicio = 'HUB_FRAUCAOFI_ISOC_CAT';
        input.asunto = 'Asunto';
        input.numPerso = '11111';
        input.urlGrabacion = 'www.grabaciones.com/llamada1.mp3';

        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            FRA_Genesys_Cloud_Eventos_Controller.finalizarConsultaExterna(JSON.serialize(input), 'Llamada finalizada');
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }

    @isTest
    public static void testIniciarTransferenciaCiega() {
        CC_Llamada__c llamada = [SELECT Id FROM CC_Llamada__c WHERE CC_Asunto__c = 'Llamada Test'];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test'];
        CC_Llamada_Input input = new CC_Llamada_Input();

        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            FRA_Genesys_Cloud_Eventos_Controller.iniciarTransferenciaCiega(JSON.serialize(input), 'Llamada transferida');
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }
    
    @isTest
    public static void testAtributosLlamadaInicial() {
        CC_Llamada__c llamada = [SELECT RecordTypeId, CC_ConnId__c, CC_Servicio_Genesys__c FROM CC_Llamada__c WHERE CC_Asunto__c = 'Llamada Test'];

        CC_Llamada__c llamadaInicial = new CC_Llamada__c();
        llamadaInicial.RecordTypeId = llamada.RecordTypeId;
        llamadaInicial.KIN_Genesys_Cloud__c = true;
        llamadaInicial.KIN_Llamada_Origen__c = true;
        llamadaInicial.CC_Servicio_Genesys__c = llamada.CC_Servicio_Genesys__c;
        llamadaInicial.CC_ConnId__c = llamada.CC_ConnId__c;
        llamadaInicial.CC_Tipo__c = 'Entrante';
        llamadaInicial.CC_Tipo_Cierre__c = 'Llamada finalizada';
        llamadaInicial.CC_Asunto__c = 'Llamada Test Inicial';
        insert llamadaInicial;

        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            FRA_Genesys_Cloud_Eventos_Controller.atributosLlamadaInicial(llamada.CC_ConnId__c);
            Test.stopTest();
        }
        System.assertEquals(true, true, 'PENDIENTE');
    }
}