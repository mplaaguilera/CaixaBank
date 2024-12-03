@isTest
public with sharing class CC_FinalizarLlamadas_Batch_Test {
    @testSetup
    static void makeData() {
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
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
            Id genesysRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Servicio_Genesys__c', 'CC_Servicio');
            Id llamadaRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'CC_Cliente');
            CC_Servicio_Genesys__c sGenesys = new CC_Servicio_Genesys__c ();
            sGenesys.Name = 'IMAGIN LEADS';
            sGenesys.CC_Codigo__c = 'IMAGIN_LEADS';
            sGenesys.CC_Tipo_Cliente__c = 'Cliente';
            sGenesys.CC_VDN__c = '1332';
            sGenesys.RecordTypeId = genesysRecordTypeId;
            insert sGenesys;
            
            CC_Llamada__c llamada = new CC_Llamada__c ();
            llamada.CC_Tipo__c = 'Entrante';
            llamada.CC_Tipo_Cierre__c = '';
            llamada.CC_Servicio_Genesys__c = sGenesys.Id;
            llamada.RecordTypeId = llamadaRecordTypeId;
            insert llamada;
        }
    }
    
    @isTest
    public static void comprobarBatch() {
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id)) {
            Test.startTest();
            CC_FinalizarLlamadas_Batch batch = new CC_FinalizarLlamadas_Batch();
            Database.executeBatch(batch);
            Test.stopTest();
            List<CC_Llamada__c> llamadas = [SELECT Id FROM CC_Llamada__c WHERE CC_Tipo_Cierre__c != '' LIMIT 1];
            System.assert(llamadas.size() > 0);
        }
    }
}