@isTest
public with sharing class GRR_Case_Test {

    private static Contact crearContacto() {
        Contact contacto = new Contact (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente'),
            LastName = 'Test',
            CC_Numero_Documento__c = '36592162J'
        );
        insert contacto;
        return contacto;
    }

    private static Case crearCasoConContacto(String idcont) {
        Contact contacto = [SELECT Id FROM Contact WHERE Id = :idcont];
        CC_MCC__c mccTematica = new CC_MCC__c(
            Name = 'MCC Tematica',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'TEGR-000001',
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
        );
        insert mccTematica;
        CC_MCC__c mccProducto = new CC_MCC__c(
            Name = 'MCC Producto',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio'),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'PRGR-000001',
            CC_Tematica__c = mccTematica.Id
        );
        insert mccProducto;
        CC_MCC__c mccMotivo = new CC_MCC__c(
            Name = 'MCC Motivo',
            CC_Fecha_Vigencia_Inicio__c = Date.today(),
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo'),
            CC_Tipo_Cliente__c = 'Cliente (GRR)',
            CC_Codigo_Externo__c = 'MOGR-000001',
            CC_Producto_Servicio__c = mccProducto.Id
        );
        insert mccMotivo;
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_Grupo_Colaborador'),    
            Name = 'Test GRR',
            OS_Negocio__c = 'GRR'
        );
        insert grupo;
        Case caso = new Case (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'),
            Subject = 'Caso Test',
            ContactId = contacto.Id,
            CC_MCC_Tematica__c = mccTematica.Id,
            CC_MCC_ProdServ__c = mccProducto.Id,
            CC_MCC_Motivo__c = mccMotivo.Id,
            CC_Grupo_Colaborador__c = grupo.Name,
            CC_Referencia_Correo_Saliente__c = '20240104084844'
        );           
        insert caso;
        String correoBody = 'Esto es una prueba para la operativa de Traslado a Colaborador\n\n';
        correoBody += 'CORREO INICIAL DESDE SF a COLABORADOR\n\n';
        correoBody += 'Por favor, mantén las siguientes referencias al responder a este correo electrónico: #@20240104084844#.';
        correoBody += 'ref:!00D7Z058vP.!5007Z0Q2hal:ref';
        EmailMessage correo = new EmailMessage (
            CC_Interno__c = true,
            FromAddress = 'barcelona@reputacional.caixabank.com',
            ParentId = caso.Id,
            toAddress = 'testGRR@pruebas.com',
            CC_Procedencia__c = 'Remitir Colaborador',
            CC_Grupo_Colab__c = grupo.Name,
            TextBody = correoBody
        );
        insert correo;
        // correo.TextBody = 'Esto es una prueba para la operativa de Traslado a Colaborador\n\n';
        // correo.TextBody += 'CORREO INICIAL DESDE SF a COLABORADOR\n\n';
        // correo.TextBody += 'Por favor, mantén las siguientes referencias al responder a este correo electrónico: #@20240104084844#.';
        // correo.TextBody += 'ref:!00D7Z058vP.!5007Z0Q2hal:ref';
        // update correo;
        return caso;
    }

    @isTest
    public static void testCrearCaso() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();

            Contact contacto = crearContacto();
            Map<String, Object> campos = new Map<String, Object>();
            campos.put('Origin', 'Email');
            campos.put('Subject', 'Test Subject');
            campos.put('Description', 'Test Description');
            campos.put('ContactId', contacto.Id);
    
            Case caso1 = GRR_Case.crearCaso('GRR_Cliente');
            Case caso2 = GRR_Case.crearCaso('GRR_Cliente', campos);
            System.assertEquals(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'), caso1.RecordTypeId);
            System.assertEquals('Email', caso2.Origin);

            Test.stopTest();
        }
    }

    @isTest
    public static void testReapertura() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();
            
            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            caso.Status = 'Rechazado';
            update caso;

            
            Case casoUpdate = GRR_Case.reapertura(caso.Id, 'Motivo reapertura');
            Task tarea = [SELECT Description FROM Task WHERE WhatId = :caso.Id AND Type = 'Reactivación'];
            System.assertEquals('Activo', casoUpdate.Status);
            System.assertEquals('Motivo reapertura', tarea.Description);
            
            Test.stopTest();
        }   
    }

    @isTest
    public static void testResponderCerrar() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();
            
            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            caso.Status = 'Activo';
            update caso;

            Case casoupdate = GRR_Case.responderCerrar(caso);       
            System.assertEquals('Cerrado', casoupdate.Status);
            
            Test.stopTest();
        }
    }

    @isTest
    public static void testHistoricoCorreosSinCliente() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();
            
            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);

            String resultado = GRR_Case.historicoCorreosSinCliente(caso.Id);
            System.assertEquals(true, resultado.contains('barcelona@reputacional.caixabank.com'));
            
            Test.stopTest();
        }
    }

}