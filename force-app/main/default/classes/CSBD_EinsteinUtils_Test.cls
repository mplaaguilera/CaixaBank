/*****************************************************************
 * Name: CSBD_EinsteinUtils_Test
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Testear el componente CSBD_EinsteinUtils
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US967512         David Ramos       19/08/24     Creación
*****************************************************************/
/**
 * @description     clase de test para el componente CSBD_EinsteinUtils
 */
@isTest
public with sharing class CSBD_EinsteinUtils_Test {
    @TestSetup
    static void makeData(){
        User usuarioGeneral = CSBD_Usuarios.usuarioGestor(); //la funcion ya hace el insert

        List<PermissionSet> permiSets = [SELECT Id FROM PermissionSet WHERE Name IN ('CSBD_PromptUser')];
        PermissionSet permiSet1 = permiSets[0];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet1.Id;
        insert(permiSetAssi);

        System.runAs(usuarioGeneral){

            //opportunity con producto
            Map<String, Object> camposOppl = new Map<String, Object>();
            camposOppl.put('CSBD_Producto__c', 'MyBox Vida');
            camposOppl.put('Description', 'descripcion');
            camposOppl.put('CSBD_Notas_gestor__c', 'notas gestor'); 
            CSBD_Opportunity.crearOportunidad('CSBD_CMB', camposOppl); //la funcion ya hace el insert

            //opportunity sin producto
            CSBD_Opportunity.crearOportunidad('CSBD_CMB'); //la funcion ya hace el insert
        }
    }
    //Como se usa metadatos no puedo asegurar que exista el que iba a usar
/*
    @isTest
    static void marcarCheckPrompt() {
        List<Opportunity> opps = [SELECT Id, CSBD_Producto__c, RecordTypeId FROM Opportunity WHERE CSBD_Producto__c = 'MyBox Vida'];
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        System.runAs(usuario){
            Test.startTest();
            CSBD_EinsteinUtils.marcarCheckPromptSiCumple(opps);
            Test.stopTest();
        }

        Opportunity oppAfterCheck = [SELECT Id, CSBD_Producto__c, CSBD_CumpleCondicionesPrompts__c FROM Opportunity WHERE CSBD_Producto__c = 'MyBox Vida'];

        System.assertEquals(true, oppAfterCheck.CSBD_CumpleCondicionesPrompts__c,'La oportunidad se marca correctamante');
    }
*/
    @isTest
    static void marcarCheckPromptNoCumple() {
        List<Opportunity> opps = [SELECT Id, CSBD_Producto__c, RecordTypeId, Description FROM Opportunity WHERE CSBD_Producto__c = null];
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        System.runAs(usuario){
            Test.startTest();
            CSBD_EinsteinUtils.marcarCheckPromptSiCumple(opps);
            Test.stopTest();
        }

        Opportunity oppAfterCheck = [SELECT Id, CSBD_Producto__c, CSBD_CumpleCondicionesPrompts__c FROM Opportunity WHERE CSBD_Producto__c = null];
        System.assertEquals(false, oppAfterCheck.CSBD_CumpleCondicionesPrompts__c,'La oportunidad no se marca, correctamante');
    }

    @isTest
    static void marcarHaUsadoIA() {
        Opportunity oldOpp = [SELECT Id, CSBD_Producto__c, RecordTypeId, CSBD_GptResumenInicialRich__c, CSBD_HaUsadoIA__c, StageName FROM Opportunity WHERE CSBD_Producto__c = 'MyBox Vida'];
        Opportunity newOpp = new Opportunity();
        
        //newOpp.StageName = 'Perdida';
        newOpp.CSBD_GptResumenInicialRich__c = 'algo';
        newOpp.id = oldOpp.id;

        Map<Id, Opportunity> mapOldObj = new Map<Id, Opportunity>();
        mapOldObj.put(oldOpp.Id, oldOpp);

        List<Opportunity> listNewObj = new List<Opportunity>();
        listNewObj.add(newOpp);

        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        System.runAs(usuario){
            Test.startTest();
            CSBD_EinsteinUtils.comprobarUsoPromptsYResumenCierre(listNewObj, mapOldObj);
            Test.stopTest();
        }

        Opportunity oppAfterCheck = [SELECT Id, CSBD_Producto__c, CSBD_HaUsadoIA__c FROM Opportunity WHERE CSBD_Producto__c = 'MyBox Vida'];

        System.assertEquals(true, oppAfterCheck.CSBD_HaUsadoIA__c,'La oportunidad se marca correctamante');
    }

    @isTest
    static void forzarException() {
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];
        Opportunity oldOpp = [SELECT Id, CSBD_Producto__c, RecordTypeId, CSBD_GptResumenInicialRich__c, CSBD_CumpleCondicionesPrompts__c,  CSBD_HaUsadoIA__c, StageName, Description FROM Opportunity WHERE CSBD_Producto__c = 'MyBox Vida'];
        Opportunity newOpp = new Opportunity();
        
        newOpp.StageName = 'Perdida';
        newOpp.CSBD_GptResumenInicialRich__c = 'algo';
        newOpp.CSBD_CumpleCondicionesPrompts__c = true;
        newOpp.Description = CSBD_EinsteinUtils.MENSAJEINICIAL;
        newOpp.id = oldOpp.id;

        Map<Id, Opportunity> mapOldObj = new Map<Id, Opportunity>();
        mapOldObj.put(oldOpp.Id, oldOpp);

        List<Opportunity> listNewObj = new List<Opportunity>();
        listNewObj.add(newOpp);

        UnsupportedOperationException exc;
        System.runAs(usuario){
            Test.startTest();
            try{
                CSBD_EinsteinUtils.comprobarUsoPromptsYResumenCierre(listNewObj, mapOldObj);
            }
            catch(UnsupportedOperationException listExc){
                exc = listExc;
            }
            Test.stopTest();
        }
        Boolean hayError = exc != null;
        System.assertEquals(true, hayError,'El error no se ha capturado correctamente');
    }

    @isTest
    static void generarResumenCierreException() {
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE CSBD_Producto__c = 'MyBox Vida'];
        Opportunity newOpp = new Opportunity();
        newOpp.id = opp.id;
        newOpp.CSBD_CumpleCondicionesPrompts__c = true;
        update newOpp;

        UnsupportedOperationException exc;
        System.runAs(usuario){
            Test.startTest();
            try{
                CSBD_EinsteinUtils.generarResumenCierre(newOpp.Id);
            }
            catch(UnsupportedOperationException listExc){
                exc = listExc;
            }
            Test.stopTest();
        }
        Boolean hayError = exc != null;
        System.assertEquals(true, hayError,'El error no se ha capturado correctamente');
    }
}