@isTest
public with sharing class CC_Task_Verificacion_Cliente_Test {
    @isTest
    public static void CasoPendienteRevision() {

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Pendiente Cliente';
        caso.Origin = 'Comentarios Stores';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;

        Task actividad = new Task();
        actividad.WhatId = caso.Id;
        actividad.Type = 'Rechazar Primer Nivel';
        actividad.Status = 'Open';
        insert actividad;

        List<Id> listaIdsTask = new List<Id>();
        listaIdsTask.add(actividad.Id);

        Test.startTest();
        CC_Task_Verificacion_Cliente.CC_Task_Verificacion_Cliente(listaIdsTask);
        Test.stopTest();
        
        Case resultadoCaso = [SELECT Status FROM Case WHERE Id = :actividad.WhatId LIMIT 1];
        System.assertEquals('Pendiente Revisión', resultadoCaso.Status);
    }

    @isTest
    public static void CasoCerrado() {

        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.Name = 'App\'s';
        tematica.CC_Tipo_Cliente__c = 'Cliente';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        insert tematica;

        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicio.Name = 'APP CaixaBank';
        productoServicio.CC_Detalle__c = 'CaixaBank';
        productoServicio.CC_Tipo_Cliente__c = 'Cliente';
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001';
        insert productoServicio;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.Name = 'Valoración positiva';
        motivo.CC_Tipo_Cliente__c = 'Cliente';
        motivo.CC_Producto_Servicio__c = productoServicio.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001';
        insert motivo;

        // Add account
        Account ac = new Account();
        ac.name='Acme Inc.';
        ac.name='Acme';                                   
        insert ac;

        // Add a contact 
        Contact c = new Contact(FirstName='Joe',LastName='Merged');
        insert c;

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.Status = 'Pendiente Cliente';
        caso.AccountId = ac.Id;
        caso.ContactId = c.Id;

        caso.CC_MCC_Tematica__c = tematica.Id;
        caso.CC_MCC_ProdServ__c = productoServicio.Id;
        caso.CC_MCC_Motivo__c = motivo.Id;

        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Accionista';
        caso.CC_Canal_Resolucion__c = 'Cajeros';
        caso.CC_Tipo_Contacto__c = 'Consulta';

        caso.CC_Detalles_Consulta__c = 'Cliente contacta para consultar un cajero.';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.CC_Canal_Operativo__c = 'Cajero';
        insert caso;

        Task actividad = new Task();
        actividad.WhatId = caso.Id;
        actividad.Type = 'Actividad manual';
        actividad.Subject = 'Verificación cliente';
        actividad.Status = 'Completed';
        actividad.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        insert actividad;
    }
}