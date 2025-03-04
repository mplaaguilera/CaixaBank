/*****************************************************************
 * Name: SAC_Case_BI_TRHan_Test
 * Copyright © 2019  CaixaBank
 * 
 * Proposito: Testear la clase SAC_Case_BI_TRHan
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US200213         Carlos Solis         23/04/21     Creación
 * 1.1            US563153         Jose Carlos Blanco   23/03/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@isTest
public with sharing class SAC_Case_BI_TRHan_Test {
    @TestSetup
    static void makeData() {

        Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
        SAC_DatabaseDML.insertDML(cuenta, false);
        //Database.insert(cuenta);


        Entitlement entitle = SAC_TestDataFactory.crearEntitlement(cuenta.id);
        SAC_DatabaseDML.insertDML(entitle, false);
        //Database.insert(entitle);

        List<CC_MCC__c> mccs = SAC_TestDataFactory.crearMCCs();
        SAC_DatabaseDML.insertListDML(mccs, false);
        //Database.insert(mccs);

        CC_MCC__c mccTematica = [SELECT Id FROM CC_MCC__c WHERE Name = 'Tematica' LIMIT 1];
        
        //RECLAMACION
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('AccountId', cuenta.Id);
        camposRecl.put('SEG_Detalle__c', mccTematica.id);
        camposRecl.put('SlaStartDate', system.today());
        camposRecl.put('SAC_FechaRecepcion__c', system.today());

        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(casoReclamacion, false);
        //Database.insert(casoReclamacion);

        //PRETENSION
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('Subject', 'TestPret');
        camposPret.put('AccountId', cuenta.Id);
        camposPret.put('SEG_Detalle__c', mccTematica.id);
        camposPret.put('SlaStartDate', system.today());
        camposPret.put('SAC_FechaRecepcion__c', system.today());

        Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        SAC_DatabaseDML.insertDML(casoPretension, false);
        //Database.insert(casoPretension);

        List<User> usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1);
        usuarioGeneral[0].Username = 'ustestesteo@test.com';
        SAC_DatabaseDML.insertListDML(usuarioGeneral, false);       
        //Database.insert(usuarioGeneral);
    }

    @isTest
    static void asignarEntitlement_Test() {
        List <Entitlement> entls = [select id, SlaProcess.name from Entitlement where SlaProcess.name = 'SAC_Process' limit 1];
        List<Case> listaCasosRec = [select id, SAC_CasoRelacionado__c, RecordTypeId, EntitlementId from Case where subject = 'TestRec'];

        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true];
		System.runAs(usuario){
            Test.startTest();
            SAC_Case_BI_TRHan.asignarEntitlement(listaCasosRec);
            Test.stopTest();
        }
        system.assertEquals(entls[0].id, listaCasosRec[0].entitlementId, 'El entitlement no se ha asignado');
    }

    @isTest
    static void asignarEntitlementPretension_Test() {
        List <Entitlement> entls = [select id, SlaProcess.name from Entitlement where SlaProcess.name = 'SAC_Process' limit 1];
        List<Case> listaCasosPret = [select id, SAC_CasoRelacionado__c, RecordTypeId, EntitlementId from Case where subject = 'TestPret'];

        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true];
		System.runAs(usuario){
            Test.startTest();
            SAC_Case_BI_TRHan.asignarEntitlement(listaCasosPret);
            Test.stopTest();
        }
        system.assertEquals(entls[0].id, listaCasosPret[0].entitlementId, 'El entitlement no se ha asignado');
    }
}