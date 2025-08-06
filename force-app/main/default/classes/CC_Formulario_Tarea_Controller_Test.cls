@isTest
public with sharing class CC_Formulario_Tarea_Controller_Test {
    @TestSetup
    static void makeData() {
        //crear usuarios CC
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        PermissionSet psOperadorCliente = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;

        User usuarioAdmin = new User();
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = roleCC;
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';
        insert usuarioAdmin;

        System.runAs(usuarioAdmin) {
            User operador = new User();        
            operador.profileId = profileId;
            operador.UserRoleId = roleCC;
            operador.FirstName = '';
            operador.LastName = 'Operador Cliente';
            operador.Email = 'tuser000@amamama.com';
            operador.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
            operador.CompanyName = 'MST';
            operador.Title = 'title';
            operador.Alias = 'alias';
            operador.TimeZoneSidKey = 'Europe/Paris';
            operador.EmailEncodingKey = 'UTF-8';
            operador.LanguageLocaleKey = 'es';
            operador.LocaleSidKey = 'es_ES';        
            insert operador;
            insert new PermissionSetAssignment(AssigneeId = operador.Id, PermissionSetId = psOperadorCliente.Id);
            insert new PermissionSetAssignment(AssigneeId = operador.Id, PermissionSetId = psClasses.Id);

            Case caso = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(),
            Origin = 'Email',
            Status = 'Activo',
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            OwnerId = operador.Id,
            CC_Canal_Procedencia__c = 'Formulario web',
            Subject = 'Cita gestor'
            );
            insert caso;

            Task tarea = new Task();
            tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
            tarea.Subject = 'Cita gestor solicitada correctamente';
            tarea.Description = 'Se ha generado la cita correctamente.';
            tarea.Status = 'Completed';
            tarea.Priority = 'Normal';
            tarea.ActivityDate = date.today();
            tarea.WhatId = caso.Id;
            tarea.OwnerId = operador.Id;
            tarea.Type = 'Cita gestor';
            insert tarea;

            String medio = 'Entrevista';
            CBK_Activity_Extension__c tareaExtension = new CBK_Activity_Extension__c();
            tareaExtension.CC_Tipo_de_cita__c = medio;
            tareaExtension.AV_ActivityId__c = tarea.Id;
            insert tareaExtension;
        }
    }

    @isTest
    public static void getActivityExtensionId() {
        User operador = [SELECT Id FROM User WHERE LastName = 'Operador Cliente' LIMIT 1];
        Task tarea = [SELECT Id FROM Task WHERE Subject = 'Cita gestor solicitada correctamente' LIMIT 1];
        System.runAs(operador) {
            Id resultado = CC_Formulario_Tarea_Controller.getActivityExtensionId(tarea.Id);
            System.assertNotEquals(resultado, null, 'No se ha creado correctamente la activity extension');
        }
    }
}