@isTest
public with sharing class CC_Contact_TRTest {
    @TestSetup
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
        }
    }

    @isTest
    private static void contactTriggerAI() {

        User admin = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1];
        
        System.runAs(admin) {
            Id centroRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            Id empleadoRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            Test.startTest();
            Account cuentaCentroCaixaBank = new Account(
                RecordTypeId = centroRecordTypeId,
                Name = 'Cuenta Centro CaixaBank Test 1',
                CC_Tipo_Centro__c = 'OF'
            );
            insert cuentaCentroCaixaBank;
        
            Contact contacto = new Contact(
                RecordTypeId = empleadoRecordTypeId,
                FirstName = 'Contacto OF',
                LastName = 'Test',
                AccountId = cuentaCentroCaixaBank.Id,
                CC_Idioma__c = 'es',
                Email = 'test@contact.com',
                AV_DescFuncion__c = 'DIRECCIÓN'
            );
            insert contacto;
            Test.stopTest();
            CC_Grupo_Colaborador_Contact__c grupoColaborador = [SELECT Id FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Contacto__c = :contacto.Id];
            System.assertNotEquals(grupoColaborador, null, 'No se ha realizado correctamente el proceso');
        }
    }

    @isTest
    private static void contactTriggerAU() {

        User admin = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1];

        System.runAs(admin) {
            Id centroRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            Id empleadoRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();        
        
            Account cuentaCentroCaixaBank = new Account(
                RecordTypeId = centroRecordTypeId,
                Name = 'Cuenta Centro CaixaBank Test 1',
                CC_Tipo_Centro__c = 'OF'
            );
            insert cuentaCentroCaixaBank;
        
            Contact contacto = new Contact(
                RecordTypeId = empleadoRecordTypeId,
                FirstName = 'Contacto OF',
                LastName = 'Test',
                AccountId = cuentaCentroCaixaBank.Id,
                CC_Idioma__c = 'es',
                Email = 'test@contact.com',
                AV_DescFuncion__c = 'DIRECCIÓN'
            );
            insert contacto;

            Test.startTest();
            contacto.CC_Matricula__c = '00000001';
            update contacto;
            Test.stopTest();
            CC_Grupo_Colaborador_Contact__c grupoColaborador = [SELECT Id FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Contacto__c = :contacto.Id];
            System.assertNotEquals(grupoColaborador, null, 'No se ha realizado correctamente el proceso');
        }
    }
}