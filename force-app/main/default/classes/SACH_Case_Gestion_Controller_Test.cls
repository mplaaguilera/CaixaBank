@isTest
public with sharing class SACH_Case_Gestion_Controller_Test {
    
    
    @testSetup
    static void data(){
        
        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        
        Contact contacto = new Contact(LastName = 'Test', CC_Numero_Documento__c = '36592162J', CC_Sexo__c = 'V');
        insert contacto;
        
        //Preparación de los datos
        Case caso = new Case();
        caso.Subject = 'Caso Test'; 
        caso.ContactId = contacto.Id;
        caso.RecordTypeId = rtCaso;
        insert caso;
               
    }
    
    
    /**
     * Comprobar la creación de tarea.
    */
    @isTest
    private static void testCrearActividadMotivo() {
    	
        Id rtTarea = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Task').getRecordTypeId();
        
        Case caso = [Select Id, contactId from Case where Subject = 'Caso Test' limit 1];

        Test.startTest();
        SACH_Case_Gestion_Controller.crearActividad(caso.Id, 'Correo - Entrada', 'Test Motivo');
        Test.stopTest();

        Task tareaCreada = [Select Status, WhatId, Subject, Description, Type from Task where whatId = :caso.Id limit 1];
        
        system.assertEquals('Completed', tareaCreada.Status, 'El campo Status no coincide con la tarea.');
        system.assertEquals(caso.Id, tareaCreada.WhatId, 'El campo WhatId no coincide con la tarea.');
        system.assertEquals('Correo - Entrada', tareaCreada.Subject, 'El campo Subject no coincide con la tarea.');
        system.assertEquals('Test Motivo', tareaCreada.Description, 'El campo Description no coincide con la tarea.');
        system.assertEquals('Correo - Entrada', tareaCreada.Type, 'El campo Type no coincide con la tarea.');
        
    }
    
    /**
     * Comprobar reabrir tarea de colaborador.
    */
    @isTest
    private static void testReabrirTareaTrasladoColab() {
    
        Map<String, Object> camposTarea = new Map<String, Object>();
        Id rtTarea = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Task').getRecordTypeId();
        
        Case caso = [Select Id, contactId from Case where Subject = 'Caso Test' limit 1];
        
        Task tarea = new Task();
        tarea.RecordTypeId = rtTarea;
        tarea.WhatId = caso.Id;
        tarea.WhoId = caso.ContactId;
        tarea.Status = 'Completed';
        tarea.Type = 'Traslado Colaborador';
        tarea.TaskSubtype = 'Email';
        tarea.Subject = 'Test Subject';
        tarea.ActivityDate = System.today();
        insert tarea;

        Test.startTest();
        SACH_Case_Gestion_Controller.reabrirTareaTrasladoColaborador(caso.Id);
        Test.stopTest();

        Task tareaUpdate = [Select id, Status from Task where Id = :tarea.Id limit 1];
        
		system.assertEquals('Open', tareaUpdate.Status, 'El campo Status no coincide con la tarea.');
        
    }
    
    /**
     * Comprobar la extracción de los MCCs temática.
    */
    @isTest
    private static void testGetValueMCCTematica() {
    
        Id rtMCC = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();

        CC_MCC__c mcc = new CC_MCC__c();
        mcc.Name = 'Prueba Tematica';
        mcc.RecordTypeId = rtMCC;
        mcc.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mcc.CC_Codigo_Externo__c = '11111111';
        insert mcc;

        Test.startTest();
        List<OT_Picklist.Item> listItem = SACH_Case_Gestion_Controller.getValueMCC('Cliente (SACH)', 'CC_Tematica', null);
        Test.stopTest();

        system.assertEquals('Prueba Tematica', listItem.get(0).label, 'La temática no coincide.');
        system.assertEquals(mcc.Id, listItem.get(0).value, 'La temática no coincide.');
        
    }
    
    /**
     * Comprobar la extracción de los MCCs.
    */
    @isTest
    private static void testGetValueMCCProducto() {
    
        Id rtMCCTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id rtMCCProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();

        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'Prueba Tematica';
        mccTematica.RecordTypeId = rtMCCTematica;
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccTematica.CC_Codigo_Externo__c = '11111111';
        insert mccTematica;
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Prueba Producto';
        mccProducto.RecordTypeId = rtMCCProducto;
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccProducto.CC_Codigo_Externo__c = '22222222';
        mccProducto.CC_Tematica__c = mccTematica.Id;
        insert mccProducto;

        Test.startTest();
        List<OT_Picklist.Item> listItem = SACH_Case_Gestion_Controller.getValueMCC('Cliente (SACH)', 'CC_Producto_Servicio', mccTematica.Id);
        Test.stopTest();

        system.assertEquals('Prueba Producto', listItem.get(0).label, 'El producto no coincide.');
        system.assertEquals(mccProducto.Id, listItem.get(0).value, 'El producto no coincide.');
        
    }
    
    /**
     * Comprobar la extracción de los MCCs.
    */
    @isTest
    private static void testGetValueMCCMotivo() {
    
        Id rtMCCTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id rtMCCProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id rtMCCMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();

        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'Prueba Tematica';
        mccTematica.RecordTypeId = rtMCCTematica;
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccTematica.CC_Codigo_Externo__c = '11111111';
        insert mccTematica;
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Prueba Producto';
        mccProducto.RecordTypeId = rtMCCProducto;
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccProducto.CC_Codigo_Externo__c = '22222222';
        mccProducto.CC_Tematica__c = mccTematica.Id;
        insert mccProducto;
        
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Prueba Motivo';
        mccMotivo.RecordTypeId = rtMCCMotivo;
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccMotivo.CC_Codigo_Externo__c = '33333333';
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        insert mccMotivo;

        Test.startTest();
        List<OT_Picklist.Item> listItem = SACH_Case_Gestion_Controller.getValueMCC('Cliente (SACH)', 'CC_Motivo', mccProducto.Id);
        Test.stopTest();

        system.assertEquals('Prueba Motivo', listItem.get(0).label, 'El motivo no coincide.');
        system.assertEquals(mccMotivo.Id, listItem.get(0).value, 'El motivo no coincide.');
        
    }
    
    
    /**
     * Comprobar la extracción de los MCCs.
    */
    @isTest
    private static void testGetValueMCCCausa() {
    
        Id rtMCCTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id rtMCCProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id rtMCCMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id rtMCCCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();

        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'Prueba Tematica';
        mccTematica.RecordTypeId = rtMCCTematica;
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccTematica.CC_Codigo_Externo__c = '11111111';
        insert mccTematica;
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Prueba Producto';
        mccProducto.RecordTypeId = rtMCCProducto;
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccProducto.CC_Codigo_Externo__c = '22222222';
        mccProducto.CC_Tematica__c = mccTematica.Id;
        insert mccProducto;
        
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Prueba Motivo';
        mccMotivo.RecordTypeId = rtMCCMotivo;
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccMotivo.CC_Codigo_Externo__c = '33333333';
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        insert mccMotivo;
        
        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Prueba Causa';
        mccCausa.RecordTypeId = rtMCCCausa;
        mccCausa.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccCausa.CC_Codigo_Externo__c = '44444444';
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        insert mccCausa;

        Test.startTest();
        List<OT_Picklist.Item> listItem = SACH_Case_Gestion_Controller.getValueMCC('Cliente (SACH)', 'CC_Causa', mccMotivo.Id);
        Test.stopTest();

        system.assertEquals('Prueba Causa', listItem.get(0).label, 'La causa no coincide.');
        system.assertEquals(mccCausa.Id, listItem.get(0).value, 'La causa  no coincide.');
        
    }
    
    /**
     * Comprobar la extracción de los MCCs.
    */
    @isTest
    private static void testGetValueMCCSolucion() {
    
        Id rtMCCTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id rtMCCProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id rtMCCMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id rtMCCCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id rtMCCSolucion = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();

        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'Prueba Tematica';
        mccTematica.RecordTypeId = rtMCCTematica;
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccTematica.CC_Codigo_Externo__c = '11111111';
        insert mccTematica;
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Prueba Producto';
        mccProducto.RecordTypeId = rtMCCProducto;
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccProducto.CC_Codigo_Externo__c = '22222222';
        mccProducto.CC_Tematica__c = mccTematica.Id;
        insert mccProducto;
        
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Prueba Motivo';
        mccMotivo.RecordTypeId = rtMCCMotivo;
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccMotivo.CC_Codigo_Externo__c = '33333333';
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        insert mccMotivo;
        
        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Prueba Causa';
        mccCausa.RecordTypeId = rtMCCCausa;
        mccCausa.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccCausa.CC_Codigo_Externo__c = '44444444';
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        insert mccCausa;
        
        CC_MCC__c mccSolucion = new CC_MCC__c();
        mccSolucion.Name = 'Prueba Solucion';
        mccSolucion.RecordTypeId = rtMCCSolucion;
        mccSolucion.CC_Tipo_Cliente__c = 'Cliente (SACH)';
        mccSolucion.CC_Codigo_Externo__c = '55555555';
        mccSolucion.CC_Causa__c = mccCausa.Id;
        insert mccSolucion;

        Test.startTest();
        List<OT_Picklist.Item> listItem = SACH_Case_Gestion_Controller.getValueMCC('Cliente (SACH)', 'CC_Solucion', mccCausa.Id);
        Test.stopTest();

        system.assertEquals('Prueba Solucion', listItem.get(0).label, 'La solución no coincide.');
        system.assertEquals(mccSolucion.Id, listItem.get(0).value, 'La solución no coincide.');
    }
}