@isTest
public with sharing class SAC_TratarMensajesInteraccion_Test {
    
     @TestSetup
    static void makeData() {
        //usuario a usar
        User usuario = new User();
        usuario.Username = 'Name124@test.com';
        usuario.Email = 'email@test.com';
        usuario.LastName = 'Usuario Test';
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        usuario.Alias = 'alias';
        usuario.TimeZoneSidKey = 'GMT';
        usuario.LocaleSidKey = 'es_ES';
        usuario.EmailEncodingKey = 'ISO-8859-1';
        usuario.LanguageLocaleKey = 'en_US';
        usuario.isActive = true;
        insert usuario;
        
        SAC_Interaccion__c consulta = new SAC_Interaccion__c();
        consulta.OwnerId = usuario.id;
        consulta.SAC_Observaciones_Interaccion__c = 'observacion test';
        insert consulta;
        

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailServiceConsulta' LIMIT 1];
        String headerValueSTR = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
		email.relatedToId = consulta.id;
        email.Headers = '[{"value": "' + headerValueSTR + '","name": "X-SDFC-Original-RCPT"}]';
        insert email; 
    }
    
    @isTest
    static void pegarInteraccionMessageTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'Name124@test.com' Limit 1];
        List<EmailMessage> mensajes = [SELECT id,relatedToId, HtmlBody,Subject FROM EmailMessage WHERE FromAddress = 'test@abc.org'];
        SAC_Interaccion__c consulta = [SELECT id,SAC_Observaciones_Interaccion__c,SAC_Titulo__c, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Observaciones_Interaccion__c = 'observacion test' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        insert permiSetAssi;

        Test.startTest();
        System.runAs(usuario) {
            SAC_TratarMensajesInteraccion.pegarInteraccionMessage(mensajes);
        }
        Test.stopTest();
		
        SAC_Interaccion__c consultaFinal = [SELECT id,SAC_Observaciones_Interaccion__c,SAC_Titulo__c,SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Observaciones_Interaccion__c = 'observacion test' LIMIT 1];
        
        System.assertNotEquals(null,consultaFinal.SAC_Estado__c, 'no se ha podido actualizar');
        
    }

}