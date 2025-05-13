@isTest
public with sharing class OS_feedbackCognitive_Test {
    
    @TestSetup
    static void makeData(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();
        User usuarioOperador2 = OS_Usuarios.usuarioOperador();
        usuarioOperador2.FirstName = 'OP222';
        usuarioOperador2.OS_Inicio_Vigencia_Agente_Backup__c = System.today().addDays(-1);
        usuarioOperador2.OS_Fin_Vigencia_Agente_Backup__c = System.today().addDays(+1);
        usuarioOperador2.OS_Agente_Backup__c = usuarioOperador.Id;
        usuarioOperador2.OS_Cola_Backup__c = null;
        update usuarioOperador2;

        User usuarioAdmin = OS_Usuarios.usuarioAdmin();
           
    }

    

    @isTest
    public static void crearActividadCierreAfterInsert() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
		caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.Status = 'Cerrado';

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';

        // Ejecución de la prueba
        System.runAs (usuarioOperador) {
            Test.startTest();
            insert caso;
            insert contacto;
            Test.stopTest();

            // Evaluación del resultado de la prueba
            System.assertNotEquals(null, [SELECT Id FROM Task WHERE WhatId = :caso.Id], 'Comprobamos no hay caso coincidente.');
        }
    }


    @isTest
    public static void testBackupCasosReactivados() {
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Profile.Name = 'System Administrator' LIMIT 1];
        User usuarioOperador2 = [SELECT Id, OS_Agente_Backup__c FROM User WHERE FirstName = 'OP222' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
		caso.Origin = 'Phone';
        caso.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.Status = 'Rechazado';
        caso.OwnerId = usuarioOperador2.Id;
        insert caso;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';

        System.runAs (usuarioAdmin) {
            Test.startTest();
            caso.Status = 'Activo';
            update caso;
            insert contacto;
            Test.stopTest();

            Case querycaso = [SELECT OwnerId FROM Case WHERE Id = :caso.Id];
            System.assertEquals(usuarioOperador2.OS_Agente_Backup__c, querycaso.OwnerId, 'Comprobamos el propietario del caso coincide con el usuario asignado.');
        }
    }

    @isTest
    public static void testBackupCasosReactivadosColas() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Profile.Name = 'System Administrator' LIMIT 1];

        Group testGroup = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name = '2N CCI Holabank'];

        Case caso2 = new Case();
        caso2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
		caso2.Origin = 'Phone';
        caso2.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso2.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso2.CC_Idioma__c = 'es';
        caso2.Subject = 'Asunto';
        caso2.Description = 'Descripción';
        caso2.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso2.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso2.Status = 'Rechazado';
        caso2.OwnerId = usuarioOperador.Id;
        insert caso2;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';

        System.runAs (usuarioAdmin) {
            Test.startTest();
            caso2.Status = 'Activo';
            update caso2;
            insert contacto;
            Test.stopTest();

            Case querycaso2 = [SELECT OwnerId FROM Case WHERE Id = :caso2.Id];
            System.assertEquals(testGroup.Id, querycaso2.OwnerId, 'Comprobamos el propietario del caso coincide con el grupo asignado.');
        }
    }
}