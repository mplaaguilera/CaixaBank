@isTest
public with sharing class AM_Task_AI_TRHan_Test {


    @isTest
    static void testRechazoActividadTraslado() {
        Test.startTest();
        User adminUser = CC_TestDataFactory.insertUserAdmin();

        System.runAs(adminUser) {
            
            Account acc = new Account();
            acc.Name = 'Prueba';
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            acc.CC_Numero_Documento__c = '45855598S';
            acc.CC_NumPerso__c = '533752';
            insert acc;

            Id clienteContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Contact contacto = new Contact ();
            contacto.RecordTypeId = clienteContactRT;
            contacto.LastName = 'cnt';
            contacto.FirstName = 'prueba';
            contacto.Email = 'test@test.com';
            contacto.AccountId = acc.Id;
            insert contacto;

            Case caso = new Case();
            caso.recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.CC_Tipo_Contacto__c = 'Consulta';
            caso.CC_Canal_Procedencia__c = 'Accionista';
            caso.CC_Canal_Resolucion__c = 'Accionista';
            caso.CC_Canal_Operativo__c = 'App CaixaBankPay';
            caso.Origin = 'Email';
            caso.Status = 'Inactivo ';
            caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
            caso.CC_Detalles_Solucion__c = 'Detalles Solución';
            caso.AccountId = acc.Id;
            caso.ContactId = contacto.Id;

            insert caso;

            Task tarea = new Task();
            tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('AM_Task').getRecordTypeId();
            tarea.Status = 'Rechazada';
            tarea.Type = 'Traslado Colaborador';
            tarea.WhatId = caso.Id;
            insert tarea;

            List<Case> casos = [SELECT Id, Status FROM Case WHERE Id = :caso.Id];


            System.assertEquals('Activo',casos[0].Status,  'El caso no se ha actualizado a Activo');
        }
        Test.stopTest();
    }

    @isTest
    static void planificarCierreAutomaticoTest() {
        Test.startTest();
        User adminUser = CC_TestDataFactory.insertUserAdmin();

        System.runAs(adminUser) {
            
            Account acc = new Account();
            acc.Name = 'Prueba';
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            acc.CC_Numero_Documento__c = '45855598S';
            acc.CC_NumPerso__c = '533752';
            insert acc;

            Id clienteContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Contact contacto = new Contact ();
            contacto.RecordTypeId = clienteContactRT;
            contacto.LastName = 'cnt';
            contacto.FirstName = 'prueba';
            contacto.Email = 'test@test.com';
            contacto.AccountId = acc.Id;
            insert contacto;

            Case caso = new Case();
            caso.recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.CC_Tipo_Contacto__c = 'Consulta';
            caso.CC_Canal_Procedencia__c = 'Accionista';
            caso.CC_Canal_Resolucion__c = 'Accionista';
            caso.CC_Canal_Operativo__c = 'App CaixaBankPay';
            caso.Origin = 'Email';
            caso.Status = 'Inactivo ';
            caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
            caso.CC_Detalles_Solucion__c = 'Detalles Solución';
            caso.AccountId = acc.Id;
            caso.ContactId = contacto.Id;

            insert caso;

            Task tarea = new Task();
            tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('AM_Task').getRecordTypeId();
            tarea.Status = 'Open';
            tarea.Type = 'Solicitud Información';
            tarea.WhatId = caso.Id;
            tarea.CC_Fecha_FinPlazo_SolInf__c = System.now();
            insert tarea;

            List<CBK_SCH_PendingProcess__c> pdp = [SELECT Id FROM CBK_SCH_PendingProcess__c WHERE RecordId__c = :tarea.WhatId];

            System.assertEquals(false, pdp.isEmpty(), 'No se ha programado el pending process');
        }
        Test.stopTest();
    }
    

}