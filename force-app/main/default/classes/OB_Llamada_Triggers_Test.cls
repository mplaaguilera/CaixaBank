@isTest
public with sharing class OB_Llamada_Triggers_Test {

    @isTest
    public static void auCambioPropietario() {
        
        User usuario1 = new User();
        usuario1.Username = 'usergeneral2@test.com';
        usuario1.Email = 'maria@test.com';
        usuario1.LastName = 'usuario Test 1';
        usuario1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'OB_Usuario_CaixaBank'].Id;
        usuario1.Alias = 'maria';
        usuario1.TimeZoneSidKey = 'GMT';
        usuario1.LocaleSidKey = 'es_ES';
        usuario1.EmailEncodingKey = 'ISO-8859-1';
        usuario1.LanguageLocaleKey = 'en_US';
        usuario1.isActive = true;       
        insert usuario1;

        User usuario2 = new User();
        usuario2.Username = 'usergeneral3@test.com';
        usuario2.Email = 'manel@test.com';
        usuario2.LastName = 'usuario Test 2';
        usuario2.ProfileId = [SELECT Id FROM Profile WHERE Name = 'OB_Usuario_CaixaBank'].Id;
        usuario2.Alias = 'manel';
        usuario2.TimeZoneSidKey = 'GMT';
        usuario2.LocaleSidKey = 'es_ES';
        usuario2.EmailEncodingKey = 'ISO-8859-1';
        usuario2.LanguageLocaleKey = 'en_US';
        usuario2.isActive = true;       
        insert usuario2;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            PermissionSet psResponsableOutbound = [SELECT Id FROM PermissionSet WHERE Name = 'OB_Outbound_Responsable'];

            PermissionSetAssignment psUsuario1 = new PermissionSetAssignment();
            psUsuario1.PermissionSetId = psResponsableOutbound.Id;
            psUsuario1.AssigneeId = usuario1.Id;

            PermissionSetAssignment psUsuario2 = new PermissionSetAssignment();
            psUsuario2.PermissionSetId = psResponsableOutbound.Id;
            psUsuario2.AssigneeId = usuario2.Id;
            
            insert new List<PermissionSetAssignment>{psUsuario1, psUsuario2};
        }

        CC_Llamada__c llamada = OB_Llamada.crearLlamada('OB_Cliente', new Map<String, Object>{'OwnerId' => usuario1.Id});

        Test.startTest();
        llamada.OwnerId = usuario2.Id;
        update llamada;
        Test.stopTest();

        List<Task> tareas = [SELECT RecordType.DeveloperName, Type, Subject, Status
                                FROM Task WHERE WhatId = :llamada.Id];

        String nameUsuario2 = [SELECT Name FROM User WHERE Id = :usuario2.Id].Name;

        System.assertEquals(1, tareas.size(), 'Se debería haber creado 1 única tarea');
        System.assertEquals('OB_Task', tareas[0].RecordType.DeveloperName, 'La tarea debería tener record type "OB_Clientee"');
        System.assertEquals('Cambio de propietario', tareas[0].Type, 'La tarea debería tener tipo "Cambio de propietario"');
        System.assertEquals('Reasignada a ' + nameUsuario2, tareas[0].Subject, 'La tarea debería tener asunto "Reasignada a ' + nameUsuario2 + '"');
        System.assertEquals('Completed', tareas[0].Status, 'La tarea debería estar cerrada');
    }

    @isTest
    public static void auValidacionRechazo() {
        CC_Llamada__c llamada1 = OB_Llamada.crearLlamada('OB_Cliente', new Map<String, Object>{'OB_Estado__c' => 'OB_Pendiente_Validacion'});
        llamada1.OB_Estado__c = 'OB_Cerrada';

        CC_Llamada__c llamada2 = OB_Llamada.crearLlamada('OB_Cliente', new Map<String, Object>{'OB_Estado__c' => 'OB_Pendiente_Validacion'});
        llamada2.OB_Estado__c = 'OB_Rechazada';

        Test.startTest();
        update new List<CC_Llamada__c>{llamada1, llamada2};
        Test.stopTest();

        List<Task> tareasLlamadaValidada = [SELECT RecordType.DeveloperName, Type, Subject, Status
                                            FROM Task WHERE WhatId = :llamada1.Id];

        List<Task> tareasLlamadaRechazada = [SELECT RecordType.DeveloperName, Type, Subject, Description, Status
                                                FROM Task WHERE WhatId = :llamada2.Id];

        System.assertEquals(1, tareasLlamadaValidada.size(), 'Se debería haber creado 1 única tarea de validación');
        System.assertEquals('OB_Task', tareasLlamadaValidada[0].RecordType.DeveloperName, 'La tarea de validación debería tener record type "OB_Cliente"');
        System.assertEquals('Validada', tareasLlamadaValidada[0].Type, 'La tarea de validación debería tener tipo "Validada"');
        System.assertEquals('Validada', tareasLlamadaValidada[0].Subject, 'La tarea de validación debería tener asunto "Validada"');
        System.assertEquals('Completed', tareasLlamadaValidada[0].Status, 'La tarea de validación debería estar cerrada');
        
        System.assertEquals(1, tareasLlamadaRechazada.size(), 'Se debería haber creado 1 única tarea de rechazo');
        System.assertEquals('OB_Task', tareasLlamadaRechazada[0].RecordType.DeveloperName, 'La tarea de rechazo debería tener record type "OB_Cliente"');
        System.assertEquals('Rechazada', tareasLlamadaRechazada[0].Type, 'La tarea de rechazo debería tener tipo "Rechazada"');
        System.assertEquals('Rechazada', tareasLlamadaRechazada[0].Subject, 'La tarea de rechazo debería tener asunto "Rechazada"');
        System.assertEquals('Completed', tareasLlamadaRechazada[0].Status, 'La tarea de rechazo debería estar cerrada');
        System.assert(tareasLlamadaRechazada[0].Description.startsWith('Motivo del rechazo: '), 'La tarea de rechazo debería detallar el error en la descripción');
    }
}