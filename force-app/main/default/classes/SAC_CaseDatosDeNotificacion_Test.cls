/*****************************************************************
 * Name: SAC_CaseDatosDeNotificacion_Test
 * Copyright © 2021  CaixaBank
 * ============================================================
 * Proposito: Poner a prueba la clase SAC_CaseDatosDeNotificacion 
 * ============================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US213187       Marcela Neira   11/05/21       Creación
*****************************************************************/
@isTest
public with sharing class SAC_CaseDatosDeNotificacion_Test {
    @TestSetup
    static void makeData(){

        //Usuario con perfil SAC_General para ejecutar la acción
        User usuarioGeneral = new User();
        usuarioGeneral.Username = 'usergeneral@test.com';
        usuarioGeneral.Email = 'email@test.com';
        usuarioGeneral.LastName = 'usuarioGeneral Test';
        usuarioGeneral.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id; 
        usuarioGeneral.Alias = 'alias';
        usuarioGeneral.TimeZoneSidKey = 'GMT';
        usuarioGeneral.LocaleSidKey = 'es_ES';
        usuarioGeneral.EmailEncodingKey = 'ISO-8859-1';
        usuarioGeneral.LanguageLocaleKey = 'en_US';
        usuarioGeneral.isActive = true;       
        insert usuarioGeneral;

        Account cuentaA = new  Account();
        cuentaA.Name = 'Cuenta A';
        cuentaA.Phone = '123456789';
        cuentaA.CC_Email__c = 'cuenta@mail.com';
        cuentaA.billingStreet  = 'Calle Mayor 55';
        cuentaA.BillingCountry = 'España';
        cuentaA.OwnerId = usuarioGeneral.id;

        insert cuentaA;

        Account cuentaB = new  Account();
        cuentaB.Name = 'Cuenta B';
        cuentaB.Phone = '0000000';
        cuentaB.CC_Email__c = 'correoCuentaB@mail.com';
        cuentaB.billingStreet  = 'Avenida Solar';
        cuentaB.BillingCountry = 'España';
        cuentaB.BillingPostalCode = '80500';
        cuentab.BillingState = 'Zaragoza';
        cuentaB.OwnerId = usuarioGeneral.id;

        insert cuentaB;

        Case reclamacion = new Case();
        reclamacion.Subject = 'Tarjeta';
        reclamacion.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        reclamacion.OwnerId =usuarioGeneral.id;
        reclamacion.AccountId=cuentaA.id;
        reclamacion.SAC_DireccionPostalNotificacion__c = 'Calle comino';
        insert reclamacion;

    }
@istest
    static void crearReclamacionConCuentaTest(){

        Id recorType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();        
        User usuario = [SELECT id FROM User WHERE Email = 'email@test.com'];

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);       
        insert psa;       

        system.runAs(usuario){ 
            Case miReclamacion = new Case();
            miReclamacion.Subject = 'Reclamacion';
            miReclamacion.RecordTypeId = recorType;
            miReclamacion.AccountId = [SELECT Id FROM Account WHERE CC_Email__c = 'correoCuentaB@mail.com'].Id;

            Test.startTest();
            insert miReclamacion;
            Test.stopTest();
        }

        String direccionReclamacion = [SELECT SAC_DireccionPostalNotificacion__c FROM Case WHERE Subject = 'Reclamacion'].SAC_DireccionPostalNotificacion__c;

        System.assertEquals(null, direccionReclamacion, 'No se modifico la dirección');
    }
/*@istest
    static void modificarReclamacionAOtraCuentaTest(){

        String primeraDireccion;
        String segundaDireccion;
        Map<Id,Case> reclamacionOld = new Map<Id,Case>();
        Map<Id,Case> reclamacionNew  =new Map<Id,Case>();
        Id recorType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();        
        User usuario = [SELECT id FROM User WHERE Email = 'email@test.com'];

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);       
        insert psa;       

        
        system.runAs(usuario){ 
            Case miReclamacion =[SELECT Id, AccountId, SAC_DireccionPostalNotificacion__c FROM Case WHERE Subject = 'Tarjeta'];
            reclamacionOld.put(miReclamacion.id, miReclamacion);

            miReclamacion.AccountId = [SELECT Id FROM Account WHERE CC_Email__c = 'correoCuentaB@mail.com'].Id;
            primeraDireccion = miReclamacion.SAC_DireccionPostalNotificacion__c;

            SAC_CaseReclamante__c reclamante = new SAC_CaseReclamante__c(SAC_Account__c = miReclamacion.AccountId,
					                                                             SAC_Case__c = miReclamacion.Id,
					                                                             SAC_ReclamantePrincipal__c = true);

			insert reclamante;

            reclamacionNew.put(miReclamacion.id, miReclamacion);

            Test.startTest();
            SAC_CaseDatosDeNotificacion.rellenarDatos(reclamacionNew, reclamacionOld);
            //update miReclamacion;
            Test.stopTest();
        }

        segundaDireccion = [SELECT SAC_DireccionPostalNotificacion__c FROM Case WHERE Subject = 'Tarjeta'].SAC_DireccionPostalNotificacion__c;

        System.assertNotEquals(primeraDireccion, segundaDireccion, 'No se modifico la dirección');
    }

*/
}