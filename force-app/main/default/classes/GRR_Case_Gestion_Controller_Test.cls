@isTest
public with sharing class GRR_Case_Gestion_Controller_Test {

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
        Case caso = new Case (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'),
            Subject = 'Caso Test',
            ContactId = contacto.Id
        );           
        insert caso;
        return caso;
    }

    @isTest
    public static void testGetValueMCCTematica() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();

            CC_MCC__c mcc = new CC_MCC__c();
            mcc.Name = 'Prueba Tematica';
            mcc.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            mcc.CC_Tipo_Cliente__c = 'Cliente (GRR)';
            mcc.CC_Codigo_Externo__c = 'TEGR-000001';
            insert mcc;

            List<OT_Picklist.Item> listItem = GRR_Case_Gestion_Controller.getValueMCC('Cliente (GRR)', 'CC_Tematica', null);
            System.assertEquals('Prueba Tematica', listItem.get(0).label);
            System.assertEquals(mcc.Id, listItem.get(0).value);

            Test.stopTest();
        }
    }

    @isTest
    public static void testCrearActividad() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();

            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);

            GRR_Case_Gestion_Controller.crearActividad(caso.Id, 'Correo - Entrada', 'Test Motivo');
            Task tareaCreada = [SELECT Status, WhatId, Subject, Description, Type FROM Task WHERE WhatId = :caso.Id LIMIT 1];
            System.assertEquals('Completed', tareaCreada.Status);
            System.assertEquals(caso.Id, tareaCreada.WhatId);
            System.assertEquals('Correo - Entrada', tareaCreada.Subject);
            System.assertEquals('Test Motivo', tareaCreada.Description);
            System.assertEquals('Correo - Entrada', tareaCreada.Type);

            Test.stopTest();
        }
    }

    @isTest
    public static void testCrearActividadRetipificacion() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();

            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            CC_MCC__c mccTematica2 = new CC_MCC__c(
                Name = 'MCC Tematica 2',
                CC_Fecha_Vigencia_Inicio__c = Date.today(),
                CC_Tipo_Cliente__c = 'Cliente (GRR)',
                CC_Codigo_Externo__c = 'TEGR-000002',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
            );
            insert mccTematica2;
            CC_MCC__c mccProducto2 = new CC_MCC__c(
                Name = 'MCC Producto 2',
                CC_Fecha_Vigencia_Inicio__c = Date.today(),
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio'),
                CC_Tipo_Cliente__c = 'Cliente (GRR)',
                CC_Codigo_Externo__c = 'PRGR-000002',
                CC_Tematica__c = mccTematica2.Id
            );
            insert mccProducto2;
            CC_MCC__c mccMotivo2 = new CC_MCC__c(
                Name = 'MCC Motivo 2',
                CC_Fecha_Vigencia_Inicio__c = Date.today(),
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo'),
                CC_Tipo_Cliente__c = 'Cliente (GRR)',
                CC_Codigo_Externo__c = 'MOGR-000002',
                CC_Producto_Servicio__c = mccProducto2.Id
            );
            insert mccMotivo2;

            GRR_Case_Gestion_Controller.crearActividadRetipificacion(caso.Id, mccTematica2.Id, mccProducto2.Id, mccMotivo2.Id);
            Task tareaCreada = [SELECT Id, Status FROM Task LIMIT 1];
            System.assertEquals(tareaCreada != null, true);    

            Test.stopTest();
        }
    }

}