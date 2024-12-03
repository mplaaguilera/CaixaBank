/***************************************************************************
 * @description Name: SAC_ProrrogaAutomatica_Test.cls
 * Copyright © 2021  CaixaBank
 * =========================================================================
 * Proposito: Lanzar las notificaciones (campanita) de 
 * las prorrogas
 * =========================================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR           DATE         Description
 * 1.0            US254503         Esteve Llaó      23/08/2021   Creación
***************************************************************************/

@isTest
public with sharing class SAC_NotificacionProrrogaAutomatica_Test {
   
    @TestSetup
    static void makeData() {
        Account cuenta = new Account();
        cuenta.name = 'cuentaTest';
        SAC_DatabaseDML.insertDML(cuenta, false);

        Entitlement entitle = new Entitlement();
        entitle.name = 'EntitleTest';
        entitle.AccountId = cuenta.Id;
        entitle.SlaProcessId = [SELECT id, name, IsActive, versionNumber FROM SlaProcess WHERE name = 'SAC_Process' ORDER BY versionNumber DESC LIMIT 1].id;
        SAC_DatabaseDML.insertDML(entitle, false);

        User usuario = new User();
        usuario.Username = 'Name12345@test.com';
        usuario.Email = 'email@test.com';
        usuario.LastName = 'Usuario Test';
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce'].Id;
        usuario.Alias = 'alias';
        usuario.TimeZoneSidKey = 'GMT';
        usuario.LocaleSidKey = 'es_ES';
        usuario.EmailEncodingKey = 'ISO-8859-1';
        usuario.LanguageLocaleKey = 'en_US';
        usuario.isActive = true;
        usuario.userRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];
        SAC_DatabaseDML.insertDML(usuario, false);

        CC_MCC__c mcc = new CC_MCC__c();
        mcc.Name = 'PSD2';
        mcc.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        SAC_DatabaseDML.insertDML(mcc, false);

        Case casoReclamacion2 = new Case();
        casoReclamacion2.Subject = 'TestRec2';
        casoReclamacion2.Origin = 'Backoffice';
        casoReclamacion2.Status = 'SAC_001';
        casoReclamacion2.AccountId = cuenta.Id;
        casoReclamacion2.OwnerId = usuario.id;
        casoReclamacion2.OS_Alerta_Descripcion__c = 'Prorrogado';
        casoReclamacion2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        casoReclamacion2.SAC_Prorrogado__c = FALSE;
        SAC_DatabaseDML.insertDML(casoReclamacion2, false);

        List<Case> casos = new List<Case>();
        Case pretension1 = new Case();
        pretension1.SuppliedCompany = 'TestPret1';
        pretension1.Origin = 'Backoffice';
        pretension1.Status = 'SAC_001';
        pretension1.OwnerId = usuario.Id;
        pretension1.SAC_Reclamacion__c = casoReclamacion2.Id;
        pretension1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        pretension1.SEG_Detalle__c = mcc.Id;
        casos.add(pretension1);

        Case pretension2 = new Case();
        pretension2.SuppliedCompany = 'TestPret2';
        pretension2.Origin = 'Backoffice';
        pretension2.Status = 'SAC_001';
        pretension2.OwnerId = usuario.Id;
        pretension2.SAC_Reclamacion__c = casoReclamacion2.Id;
        pretension2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        pretension2.SEG_Detalle__c = mcc.Id;
        casos.add(pretension2);
        SAC_DatabaseDML.insertListDML(casos, false);

    }
    @isTest
    static void testProrroga() {
        User usuario1 = [SELECT Id FROM User WHERE username = 'Name12345@test.com'];

        Test.startTest();
        system.runAs(usuario1){
            Id rec = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
            List<Case> pretP = [SELECT Id, OS_Alerta_Descripcion__c,SAC_FechaRecepcion__c, OwnerId, SAC_Reclamacion__c FROM case WHERE RecordTypeId =: rec];
            Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, OS_Alerta_Descripcion__c,SAC_FechaRecepcion__c, OwnerId, SAC_Reclamacion__c FROM case WHERE RecordTypeId =: rec]);
            for (case pretensiones : pretP) {
                pretensiones.OS_Alerta_Descripcion__c = 'Prorrogado';   
            }
            SAC_NotificacionProrrogaAutomatica.notificacionProrrogaAutomatica(pretP, mapaCasos);
        }

        Test.stopTest();
        Id rec = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        Integer count = [SELECT Count() FROM case WHERE RecordTypeId =: rec];
        system.assertEquals(2, count, 'Notificacion no mandada');
    }
}