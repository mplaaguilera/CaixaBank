/*****************************************************************
 * Name: SAC_MCC_AU_TRHan_Test
 * Copyright © 2021  CaixaBank
 *  
 * Proposito: Test para la clase SAC_MCC_AU_TRHan
 *  
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0             US523481      Raúl Santos          29/06/23        Creación
*****************************************************************/
@isTest
public with sharing class SAC_MCC_AU_TRHan_Test {

    @TestSetup
    static void makeData(){

        Id recTypeTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recTypeProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recTypeMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recTypeDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();

        //Usuario SAC General
        User usuarioAdm = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];      
        Database.insert(usuarioAdm);

        List<CC_MCC__c> listaMCCs = new List<CC_MCC__c>();
        CC_MCC__c mccTematica1 = new CC_MCC__c(
            RecordTypeId = recTypeTematica,
            Name = 'SACTematicaTestMCC',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = System.now(),
            CC_Codigo_Externo__c = 'TEST-0101',
            SAC_EscaladoObligatorio__c = false);
        Database.insert(mccTematica1);

        CC_MCC__c mccProdServ1 = new CC_MCC__c(
            RecordTypeId = recTypeProdServ,
            Name = 'SACProdServTestMCC',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = System.now(),
            CC_Codigo_Externo__c = 'TEST-010101',
            CC_Tematica__c = mccTematica1.id,
            SAC_EscaladoObligatorio__c = false);
        Database.insert(mccProdServ1);

        CC_MCC__c mccMotivo1 = new CC_MCC__c(
            RecordTypeId = recTypeMotivo,
            Name = 'SACMotivoTestMCC',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = System.now(),
            CC_Producto_Servicio__c = mccProdServ1.id,
            CC_Codigo_Externo__c = 'TEST-0102',
            SAC_EscaladoObligatorio__c = false);
        Database.insert(mccMotivo1);

        CC_MCC__c mccDetalle1 = new CC_MCC__c(
            RecordTypeId = recTypeDetalle,
            Name = 'SACDetalleTestMCC',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = System.now(),
            CC_Codigo_Externo__c = 'TEST-01010101',
            CC_Motivo__c = mccMotivo1.id,
            SAC_EscaladoObligatorio__c = false);
        Database.insert(mccDetalle1);
    }

    @isTest
    static void updateMccTest(){
        CC_MCC__c mccTematica = [SELECT Id, SAC_EscaladoObligatorio__c FROM CC_MCC__c WHERE Name = 'SACTematicaTestMCC' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

        Test.startTest();
        System.runAs(usuario) {
            mccTematica.SAC_EscaladoObligatorio__c = true;
            Database.update(mccTematica);
        }
        Test.stopTest();

        CC_MCC__c mccTematicaUpdate = [SELECT Id, SAC_EscaladoObligatorio__c FROM CC_MCC__c WHERE Name = 'SACTematicaTestMCC' LIMIT 1];

        System.assertNotEquals(false, mccTematicaUpdate.SAC_EscaladoObligatorio__c, 'Ha fallado al actualizar en campo escalado obligatorio del MCC');
    }
    
}