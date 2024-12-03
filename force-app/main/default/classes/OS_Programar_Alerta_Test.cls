@isTest
public class OS_Programar_Alerta_Test {

    @testSetup
    public static void testSetup() {
        User usuarioOperador = OS_Usuarios.usuarioOperador();

    }
    
    @isTest
    public static void programarAlerta() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        caso.Subject = 'Prueba Alerta';
        caso.Status = 'Pendiente Alerta';
        caso.Origin = 'Phone';
        caso.OwnerId = usuarioOperador.Id;
        caso.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso.CC_Canal_Resolucion__c = 'Teléfono COPS atención clientes';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.OS_Alerta_Fecha__c = System.now();
        caso.OS_Alerta_Nuevo_Propietario__c = usuarioOperador.Id;
        insert caso;

        insert new Event(
            WhatId = caso.Id,
            StartDateTime = caso.OS_Alerta_Fecha__c,
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Event', 'OS_Alerta'),
            Type = 'Alerta programada',
            OwnerId = usuarioOperador.Id,
            Subject = 'Alerta programada',
            EndDateTime = caso.OS_Alerta_Fecha__c
        );

        System.runAs (usuarioOperador) {       
            Test.startTest();
            OS_Programar_Alerta.programarAlerta(new List<Id>{caso.Id});
            Test.stopTest();
            
            Case casoActual = [SELECT Id, OwnerId FROM Case WHERE Id = :caso.Id];
            System.assertEquals(UserInfo.getUserId(), casoActual.OwnerId);
            Event evento = [SELECT OwnerId, OS_Alerta_Vencida__c, OS_CaseNumber__c FROM Event LIMIT 1];
            System.assertNotEquals(null, evento.OS_CaseNumber__c);
            System.assertEquals(true, evento.OS_Alerta_Vencida__c);  
            System.assertEquals(UserInfo.getUserId(), evento.OwnerId);
        }
    }

    @isTest
    public static void programarAlerta2() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case caso2 = new Case();
        caso2.CC_Idioma__c = 'es';
        caso2.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        caso2.Subject = 'Prueba Alerta';
        caso2.Status = 'Activo';
        caso2.Origin = 'Phone';
        caso2.OwnerId = usuarioOperador.Id;
        caso2.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso2.CC_Canal_Resolucion__c = 'Teléfono COPS atención clientes';
        caso2.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso2.OS_Alerta_Fecha__c = System.now();
        caso2.OS_Alerta_Nuevo_Propietario__c = usuarioOperador.Id;
        caso2.EntitlementID = null;
        insert caso2;

        insert new Event(
            WhatId = caso2.Id,
            StartDateTime = caso2.OS_Alerta_Fecha__c,
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Event', 'OS_Alerta'),
            Type = 'Alerta programada',
            Subject = 'Alerta programada2',
            EndDateTime = caso2.OS_Alerta_Fecha__c,
            OwnerId = usuarioOperador.Id
        );

        System.runAs (usuarioOperador) {       
            Test.startTest();
            caso2.Status = 'Pendiente Alerta';
            update caso2;
            OS_Programar_Alerta.programarAlerta(new List<Id>{caso2.Id});
            Test.stopTest();
            
            Case casoActual2 = [SELECT Id, OwnerId, OS_Alerta_Nuevo_Propietario__c, Status, CaseNumber,OS_Alerta_Fecha__c, OS_Alerta_Descripcion__c FROM Case WHERE Id = :caso2.Id];
            Event evento2 = [SELECT OwnerId, OS_Alerta_Vencida__c, OS_CaseNumber__c FROM Event WHERE WhatId = :casoActual2.Id];
            System.assertEquals(usuarioOperador.Id, casoActual2.OwnerId);

            System.assertEquals('Activo', casoActual2.Status);
            System.assertEquals(null, casoActual2.OS_Alerta_Fecha__c);
            System.assertEquals(null, casoActual2.OS_Alerta_Nuevo_Propietario__c);
            System.assertEquals(null, casoActual2.OS_Alerta_Descripcion__c);

            System.assertEquals(casoActual2.CaseNumber, evento2.OS_CaseNumber__c);
            System.assertEquals(true, evento2.OS_Alerta_Vencida__c);  
            System.assertEquals(usuarioOperador.Id, evento2.OwnerId);
        }
    }
}