@isTest
public with sharing class SACH_Case_Test {

    @testSetup
    static void data(){
        Contact contacto = new Contact(LastName = 'Test', CC_Numero_Documento__c = '36592162J', CC_Sexo__c = 'V');
        insert contacto;

        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.ContactId = contacto.Id;
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        insert caso;
    }

    /**
     * Comprobación de creación de un caso pasandole los campos por un mapa de objetos.
    */
    @isTest
    private static void testCrearCaso() {
        Map<String, Object> campos = new Map<String, Object>();
        Contact contacto = [Select id from Contact where CC_Numero_Documento__c = '36592162J' limit 1];

        // Creación de Caso
        campos.put('Origin', 'Email');
        campos.put('Subject', 'Test Subject');
        campos.put('Description', 'Test Description');
        campos.put('ContactId', contacto.Id);

        Test.startTest();
        Case caso = SACH_Case.crearCaso('SACH_Cliente', campos);
        Test.stopTest();

        Case casoCreado = [Select Origin from case where id = :caso.Id];
        system.assertEquals('Email', casoCreado.Origin, 'El origen no coincide.');
    }

    /**
     * Comprobación de reapertura de un caso.
    */
    @isTest
    private static void testReapertura() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test' LIMIT 1];
        caso.Status = 'Rechazado';
        update caso;

        Test.startTest();
        Case casoUpdate = SACH_Case.reapertura(caso.Id, 'motivo reapertura');
        Test.stopTest();

        System.assertEquals('Activo', casoUpdate.Status, 'No se ha reactivado el caso');

        Task tarea = [SELECT Description FROM Task WHERE WhatId = :caso.Id AND Type = 'Reactivación'];
        system.assertEquals('motivo reapertura', tarea.Description, 'Tarea de reactivación incorrecta');
    }
}