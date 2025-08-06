@isTest
public with sharing class CC_MostrarTaskAV_Controller_Test {
    @testSetup
    static void makeData() {
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
            Subject = 'Tarea gestor'
            );
            insert caso;

            Task tarea = new Task();
            tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('AV_AlertaComercial').getRecordTypeId();
            tarea.Subject = 'Tarea gestor solicitada correctamente';
            tarea.Description = 'Se ha generado la tarea correctamente.';
            tarea.Status = 'Completed';
            tarea.Priority = 'Normal';
            tarea.ActivityDate = date.today();
            tarea.WhatId = caso.Id;
            tarea.OwnerId = operador.Id;
            tarea.Type = 'Tarea gestor';
            tarea.AV_Case__c = caso.Id;
            insert tarea;
        }
    }

    @isTest
    public static void getTaskAV() {
        User operador = [SELECT Id FROM User WHERE LastName = 'Operador Cliente' LIMIT 1];        
        Id caso = [SELECT Id FROM Case WHERE Subject = 'Tarea gestor' LIMIT 1].Id;
        System.runAs(operador) {
            List<CC_MostrarTaskAV_Controller.modelTimeLine> resultado = CC_MostrarTaskAV_Controller.getTaskAV(caso);
            System.assertEquals(resultado.size(), 1, 'Se ha creado correctamente');
        }
    }
}