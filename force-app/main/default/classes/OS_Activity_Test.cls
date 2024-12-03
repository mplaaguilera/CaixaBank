@isTest
public class OS_Activity_Test {
    @testSetup
    static void data(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = a.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        Entitlement e = new Entitlement();
        e.Name = 'COPS SLA';
        e.Type = 'Phone Support';
        e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'Entitlement Process COPS' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'cops'].Id;
        insert e;
        
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Case caso1 = new Case();
        caso1.CC_Idioma__c = 'es';
        caso1.RecordTypeId = recordTypeCaso;
        caso1.Subject = 'Prueba Alerta';
        caso1.Status = 'Pendiente Alerta';
        caso1.Origin = 'Phone';
        caso1.OwnerId = usuarioOperador.Id;
        caso1.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso1.CC_Canal_Resolucion__c = 'Teléfono COPS atención clientes';
        caso1.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso1.OS_Alerta_Fecha__c = System.now();
        caso1.OS_Alerta_Nuevo_Propietario__c = usuarioOperador.Id;
        insert caso1;

        Case caso2 = new Case();
        caso2.CC_Idioma__c = 'es';
        caso2.RecordTypeId = recordTypeCaso;
        caso2.Subject = 'Prueba crear actividad rechazo';
        caso2.Status = 'Rechazado';
        caso2.Origin = 'Phone';
        caso2.OwnerId = usuarioOperador.Id;
        caso2.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso2.CC_Canal_Resolucion__c = 'Teléfono COPS atención clientes';
        caso2.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso2;        
    }

    @isTest
    public static void crearActividad() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case caso = [SELECT Id, ownerId, Status FROM Case WHERE Status = 'Rechazado' LIMIT 1];
        System.assertEquals(0, [SELECT Id FROM Task WHERE Type = 'Rechazado' AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task')].size());
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Activity.crearActividad(caso.Id, caso.Status, 'Pruebas de actividad');
            Test.stopTest();

            System.assertEquals(1, [SELECT Id FROM Task WHERE Type = 'Rechazado' AND Subject = :caso.Status AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task')].size());
        }
    }
    
    @isTest
    public static void crearActividad2() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case caso = [SELECT Id, ownerId, Status FROM Case WHERE Status = 'Rechazado' LIMIT 1];
        System.assertEquals(0, [SELECT Id FROM Task WHERE Type = 'Rechazado' AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task')].size());
        
        System.runAs (usuarioOperador) {
            Test.startTest();
        		OS_Activity.crearActividad(caso.Id, caso.Status, 'Pruebas','Pruebas de actividad', null);
            Test.stopTest();

            System.assertEquals(1, [SELECT Id FROM Task WHERE Type = 'Rechazado' AND Subject = 'Pruebas' AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task')].size());
        }
    }
    
    @isTest
    public static void crearEventoAlerta() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case caso = [SELECT Id, OS_Alerta_Fecha__c, ownerId FROM Case WHERE Status = 'Pendiente Alerta' LIMIT 1];
        System.assertEquals(0, [SELECT Id FROM Event WHERE Type = 'Alerta programada'].size());

        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Activity.crearEvento(caso.Id, caso.OS_Alerta_Fecha__c, caso.ownerId, '');
            Test.stopTest();

            System.assertEquals(1, [SELECT Id FROM Event WHERE Type = 'Alerta programada'].size());
        }
    }

    @isTest
    public static void borrarEventoAlerta() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case caso = [SELECT Id, OS_Alerta_Fecha__c, ownerId FROM Case WHERE Status = 'Pendiente Alerta' LIMIT 1];
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Activity.crearEvento(caso.Id, caso.OS_Alerta_Fecha__c, caso.ownerId, 'descripcion');
            OS_Activity.borrarEvento(caso.Id, caso.OS_Alerta_Fecha__c);
            Test.stopTest();

            System.assertEquals(0, [SELECT Id FROM Event WHERE Type = 'Alerta programada' AND WhatId = :caso.Id].size());
        }
    }
}