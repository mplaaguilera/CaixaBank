/*****************************************************************
 * Name: SAC_LCMP_ReenvioCartaPostal_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_LCMP_ReenvioCartaPostal
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US330921     Marcela Neira     14/02/22      Creación
*****************************************************************/
@istest
public without sharing class SAC_LCMP_ReenvioCartaPostal_Test {
    @TestSetup
    static void makeData(){

        //Usuario SAC General
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral){
            //Cuenta
            Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
            cuenta.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Generico').getRecordTypeId();
            Database.insert(cuenta);
            
            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'Reclamacion');
            camposRecl.put('AccountId', cuenta.Id);
            
            Case caso = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);

            //Reclamacion sin RT
            Case caso2 = New Case(Subject = 'Sin RT', AccountId = cuenta.id);

            Database.insert(caso);
            Database.insert(caso2);
            
            SAC_DocumentoEnvio__c documento = new SAC_DocumentoEnvio__c(SAC_Caso__c = caso.id, SAC_TipoDocumento__c = 'redacción');
            Database.insert(documento);
        }
    }
    
    @istest
    static void reenvioRedaccionCartaPostal_Test() {
        Case caso = [SELECT id FROM case WHERE Subject = 'Reclamacion'];
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];

        System.runAs(usuarioGeneral){
            Test.startTest();
            SAC_LCMP_ReenvioCartaPostal.reenvioRedaccionCartaPostal(caso.id);        
            Test.stopTest();
        }
        SAC_DocumentoEnvio__c documentoEnvio = [SELECT Id FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c = :caso.id 
                                                AND SAC_TipoDocumento__c = 'reenvioRedaccion' ];

        System.assertNotEquals(null, documentoEnvio, 'No se ha hecho el reenvio de la carta postal');
    }

    @istest
    static void reenvioRedaccionCartaPostalNegativo_Test() {
        Boolean hayError;
        Case caso = [SELECT id FROM case WHERE Subject = 'Sin RT'];
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];

        System.runAs(usuarioGeneral){
            Test.startTest();
            try {
                SAC_LCMP_ReenvioCartaPostal.reenvioRedaccionCartaPostal(caso.id);        
            } catch (Exception e) {
                hayError= true;
            } 
            Test.stopTest();
        }
        System.assertEquals(true, hayError, 'No ha saltado el error');
    }
}