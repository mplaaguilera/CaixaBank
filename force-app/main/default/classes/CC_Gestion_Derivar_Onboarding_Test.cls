@isTest
public with sharing class CC_Gestion_Derivar_Onboarding_Test {

    @TestSetup
    static void makeData(){
        User admin = CC_TestDataFactory.insertUserAdmin();
        System.runAs(admin) {
            User operador = CC_TestDataFactory.insertUserOperadorCliente('U01A1B2C');

            List<Account> lstAccounts = new List<Account>();
            Account cuenta = new Account(
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA'),
                FirstName = 'Cuenta',
                LastName = 'Test',
                CC_Email__c = 'cuenta@test.com',
                PersonMobilePhone = '+34 123456789',
                PersonBirthdate = Date.newInstance(2000, 05, 22),
                CC_NumPerso__c = '206'
            );
            lstAccounts.add(cuenta);
            insert lstAccounts;

            List<Contact> lstContacts = new List<Contact>();
            Contact contacto = new Contact(
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente'),
                FirstName = 'Contacto',
                LastName = 'Test',
                CC_Idioma__c = 'es',
                Email = 'contacto@test.com'
            );
            lstContacts.add(contacto);
            insert lstContacts;

            CC_MCC__c tematica = new CC_MCC__c();
            tematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            tematica.Name = 'Tematica';
            tematica.CC_Tipo_Cliente__c = 'Cliente';
            tematica.CC_Codigo_Externo__c = 'TE-000001';
            tematica.CC_Canal_Operativo__c = 'App BrokerNow';
            insert tematica;

            CC_MCC__c producto = new CC_MCC__c();
            producto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            producto.Name = 'Producto';
            producto.CC_Detalle__c = 'CaixaBank';
            producto.CC_Tipo_Cliente__c = 'Cliente';
            producto.CC_Tematica__c = tematica.Id;
            producto.CC_Codigo_Externo__c = 'PR-000001';
            insert producto;

            CC_MCC__c motivo = new CC_MCC__c();
            motivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            motivo.Name = 'Motivo';
            motivo.CC_Tipo_Cliente__c = 'Cliente';
            motivo.CC_Producto_Servicio__c = producto.Id;
            motivo.CC_Codigo_Externo__c = 'MO-000001';
            insert motivo;

            Case caso = new Case();
            caso.OwnerId = operador.Id;
            caso.Subject = 'Caso prueba';
            caso.AccountId = cuenta.Id;
            caso.ContactId = contacto.Id;
            caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso.CC_Detalles_Consulta__c = 'Test';
            caso.CC_MCC_Tematica__c = tematica.Id;
            caso.CC_MCC_ProdServ__c = producto.Id;
            caso.CC_MCC_Motivo__c = motivo.Id;
            insert caso;
        }
    }

    @isTest
    public static void envioCoreoAutomatico() {
        User operador = [SELECT Id FROM User WHERE LastName = 'Operador Cliente' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso prueba' LIMIT 1];
        System.runAs(operador) {
            Test.startTest();
                CC_Gestion_Derivar_Onboarding.envioCorreoAutomatico(caso.Id);
                System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id AND Subject = 'Derivación a BPO'], 'No se ha creado la tarea de derivación a BPO correctamente');
            Test.stopTest();
        }
    }

    @isTest
    public static void cerrarCaso() {
        User operador = [SELECT Id FROM User WHERE LastName = 'Operador Cliente' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso prueba' LIMIT 1];
        System.runAs(operador) {
            Test.startTest();
                CC_Gestion_Derivar_Onboarding.cerrarCaso(caso.Id);
                System.assertEquals('Cerrado', [SELECT Status FROM Case WHERE Id = :caso.Id].Status, 'El caso no se ha cerrado correctamente');
            Test.stopTest();
        }
    }

}