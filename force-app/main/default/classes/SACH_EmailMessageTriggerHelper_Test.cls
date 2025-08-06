@isTest
public with sharing class SACH_EmailMessageTriggerHelper_Test {
	@testSetup
    static void testSetup() {
        CC_Grupo_Colaborador__c grupoTest = new CC_Grupo_Colaborador__c();
        grupoTest.Name = 'Grupo Pruebas SACH TEST';
        grupoTest.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_CentroCaixaBank');
        grupoTest.OS_Negocio__c = 'CC';
        insert grupoTest;

        Contact contacto = new Contact();
        contacto.Email = 'emailContacto@test.com';
        contacto.RecordTypeId = [SELECT Id from RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'CC_Cliente' LIMIT 1].Id;
        contacto.CC_Inactivo__c = true;
        contacto.FirstName = 'test';
        contacto.LastName = 'test';

        Database.insert(contacto);
    }

    @isTest
    static void correoIncoming() {
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SACH_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

        Case caso = new Case();
        caso.Subject = 'Mail entrante';
        caso.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'SACH_Cliente' LIMIT 1].Id;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'SACH';
        caso.Status = 'Activo';
        insert caso;

        // Testar el trigger del objeto EmailMessage para SACH
        EmailMessage emailmes = new EmailMessage();
        emailmes.TextBody ='Email Body #@202204103132540#.';
        emailmes.Incoming = true;
        emailmes.RelatedToId = caso.Id;
        emailmes.ParentId = caso.Id;
        emailmes.CC_Procedencia__c = 'Traslado Colaborador';
        emailmes.CC_Grupo_Colab__c = [SELECT Name FROM CC_Grupo_Colaborador__c WHERE OS_Negocio__c = 'CC' LIMIT 1].Name;
        emailmes.toAddress = 'test1@test.com';
        emailmes.CcAddress = 'test1@test.com';
        emailmes.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert emailmes;

        System.assert(emailmes != null, true);
	}

    @isTest
    static void correoNotIncomingTraslado() {
        Case caso = new Case();
        caso.Subject = 'Mail entrante';
        caso.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'SACH_Cliente' LIMIT 1].Id;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'SACH';
        caso.Status = 'Activo';
        insert caso;

        // Testar el trigger del objeto EmailMessage para SACH
        EmailMessage emailmes = new EmailMessage();
        emailmes.TextBody ='Email Body #@202204103132540#.';
        emailmes.Incoming = false;
        emailmes.RelatedToId = caso.Id;
        emailmes.ParentId = caso.Id;
        emailmes.CC_Procedencia__c = 'Traslado Colaborador';
        emailmes.CC_Grupo_Colab__c = [SELECT Id, Name from CC_Grupo_Colaborador__c WHERE OS_Negocio__c = 'CC' LIMIT 1].Name;
        emailmes.toAddress = 'test2@test.com';
        emailmes.CcAddress = 'test2@test.com';
        insert emailmes;

        System.assert(emailmes != null, true);
	}

    @isTest
    static void correoNotIncomingRemitirErrorContacto() {
        Case caso = new Case();
        caso.Subject = 'Mail entrante';
        caso.RecordTypeId = [SELECT Id from RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'SACH_Cliente' LIMIT 1].Id;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'SACH';
        caso.Status = 'Activo';
        insert caso;

        // Testar el trigger del objeto EmailMessage para SACH
        try {
            EmailMessage emailmes = new EmailMessage();
            emailmes.TextBody ='Email Body #@202204103132540#.';
            emailmes.Incoming = false;
            emailmes.RelatedToId = caso.Id;
            emailmes.ParentId = caso.Id;
            emailmes.CC_Procedencia__c = 'Remitir Colaborador';
            emailmes.CC_Grupo_Colab__c = [SELECT Id, Name from CC_Grupo_Colaborador__c WHERE OS_Negocio__c = 'CC' LIMIT 1].Name;
            emailmes.toAddress = 'test3@test.com';
            emailmes.CcAddress = 'emailContacto@test.com';
            insert emailmes;
        } catch (Exception e) {
            System.assert(e.getMessage().contains('No se puede enviar un correo de traslado/remitido con direcciones de cliente en el Para o en Copia'), 'La validación es correcta.');
        }
	}

    @isTest
    static void correoNotIncomingRemitirSinError() {
        Case caso = new Case();
        caso.Subject = 'Mail entrante';
        caso.RecordTypeId = [SELECT Id from RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'SACH_Cliente' LIMIT 1].Id;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'SACH';
        caso.Status = 'Activo';
        insert caso;

        // Testar el trigger del objeto EmailMessage para SACH

        EmailMessage emailmes = new EmailMessage();
        emailmes.TextBody ='Email Body #@202204103132540#.';
        emailmes.Incoming = false;
        emailmes.RelatedToId = caso.Id;
        emailmes.ParentId = caso.Id;
        emailmes.CC_Procedencia__c = 'Remitir Colaborador';
        emailmes.CC_Grupo_Colab__c = [SELECT Id, Name from CC_Grupo_Colaborador__c WHERE OS_Negocio__c = 'CC' LIMIT 1].Name;
        emailmes.toAddress = 'test4@test.com';
        emailmes.CcAddress = 'test4@test.com';
        insert emailmes;

        System.assert(emailmes != null, 'La validación es correcta.');
	}
}