@isTest
public with sharing class AM_SchedulableTask_Test {

    @isTest
    static void schedulableTest() {
        Test.startTest();
        User adminUser = CC_TestDataFactory.getUserAdmin();

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

            List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();
            CBK_SCH_PendingProcess__c pendingProcessTask = new CBK_SCH_PendingProcess__c();
            pendingProcessTask.recordId__c = tarea.WhatId;
            pendingProcessTask.Schedule_Time__c = tarea.CC_Fecha_FinPlazo_SolInf__c;
            pendingProcessTask.className__c = 'AM_SchedulableTask';
            listaPendingProcess.add(pendingProcessTask);

            AM_SchedulableTask sca = new AM_SchedulableTask();
            sca.work(listaPendingProcess);

            System.assertNotEquals(null, sca, 'No se ha podido lanzar schedulable');
        }
        Test.stopTest();
    }
}