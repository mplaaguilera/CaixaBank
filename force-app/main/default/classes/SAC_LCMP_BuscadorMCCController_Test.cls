/*********************************************************************************
 * Name: SAC_LCMP_BuscadorMCCController_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Clase test de SAC_LCMP_BuscadorMCCController
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US750018       Sergio Martín        17/01/24         Creación 
*********************************************************************************/
@isTest
public with sharing class SAC_LCMP_BuscadorMCCController_Test {
    @TestSetup
    static void makeData(){
        User usuario = new User();
        usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        usuario.Username = 'ustestesteo@test.com'; 

        Database.insert(usuario);

        Id recTypeTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recTypeProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recTypeMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recTypeDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();

        //MCC
        CC_MCC__c mccTematica1 = new CC_MCC__c(
        RecordTypeId = recTypeTematica,
        Name = 'Avales MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-0101',
        OwnerId = usuario.id);
        Database.insert(mccTematica1);

        CC_MCC__c mccProdServ1 = new CC_MCC__c(
        RecordTypeId = recTypeProdServ,
        Name = 'Avales Fianzas y Otras Garantías MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101',
        CC_Tematica__c = mccTematica1.id,
        OwnerId = usuario.id);
        Database.insert(mccProdServ1);

        CC_MCC__c mccMotivo1 = new CC_MCC__c(
        RecordTypeId = recTypeMotivo,
        Name = 'Discrepancia con importe deuda reclamada MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Producto_Servicio__c = mccProdServ1.id,
        CC_Codigo_Externo__c = 'TEST-0102',
        OwnerId = usuario.id);
        Database.insert(mccMotivo1);

        CC_MCC__c mccDetalle1 = new CC_MCC__c(
        RecordTypeId = recTypeDetalle,
        Name = 'Discrepancia con importe deuda MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101012',
        CC_Motivo__c = mccMotivo1.id,
        OwnerId = usuario.id);
        Database.insert(mccDetalle1);

        CC_MCC__c mccDetalle2 = new CC_MCC__c(
        RecordTypeId = recTypeDetalle,
        Name = 'Discrepancia con importe deuda MCC Cambio MCC',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101013',
        CC_Motivo__c = mccMotivo1.id,
        OwnerId = usuario.id);
        Database.insert(mccDetalle2);

        //GRUPOS
        List<CC_Grupo_Colaborador__c> listGrupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupoResp = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion', 1)[0];
        grupoResp.OwnerId = usuario.id;
        grupoResp.SAC_DeveloperName__c = 'COPS';
        listGrupos.add(grupoResp);
        Database.insert(listGrupos);

        //GRUPO MCC
		CC_MCC_Grupo_Colaborador__c relacionMCCGrupo = new CC_MCC_Grupo_Colaborador__c();
		relacionMCCGrupo.CC_MCC__c = mccDetalle1.Id;
		relacionMCCGrupo.CC_Grupo_Colaborador__c = grupoResp.Id;
		relacionMCCGrupo.SAC_PorcentajeAsignacion__c = 100;
		relacionMCCGrupo.Name = 'Prueba';
		relacionMCCGrupo.SAC_MaximoDeCasosDiarios__c = 1;
        relacionMCCGrupo.SPV_Tipo_Cliente__c = 'SAC';
		Database.insert(relacionMCCGrupo);

        List<Case> lstRecl = new List<Case>();
        //RECLAMACION 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl.put('SEG_Detalle__c', mccDetalle1.id);
        camposRecl.put('CC_MCC_Tematica__c', mccTematica1.id);
        camposRecl.put('CC_MCC_Motivo__c', mccMotivo1.id);
        camposRecl.put('CC_MCC_ProdServ__c', mccProdServ1.id);
        camposRecl.put('OwnerId', usuario.Id);
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        lstRecl.add(casoReclamacion);
        Database.insert(lstRecl);

        //PRETENSION 1
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'pruebaMCC');
        camposPret.put('Origin', 'Backoffice');
        camposPret.put('OwnerId', usuario.Id);
        camposPret.put('Status', 'SAC_001');
		camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret.put('CC_MCC_Tematica__c', mccTematica1.Id);
        camposPret.put('CC_MCC_ProdServ__c', mccProdServ1.Id);
        camposPret.put('CC_MCC_Motivo__c', mccMotivo1.Id);
        camposPret.put('SEG_Detalle__c', mccDetalle1.Id);
        
        Case casoPretension1 = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        Database.insert(casoPretension1);
    }


    @isTest
    static void buscarResultadosTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);
        CC_MCC__c mcct = [SELECT id FROM CC_MCC__c WHERE Name = 'Avales MCC Clase Test' LIMIT 1];
        CC_MCC__c mccp = [SELECT id FROM CC_MCC__c WHERE Name = 'Avales Fianzas y Otras Garantías MCC Clase Test' LIMIT 1];
        CC_MCC__c mccm = [SELECT id FROM CC_MCC__c WHERE Name = 'Discrepancia con importe deuda reclamada MCC Clase Test' LIMIT 1];

        List<SObject> listaResultado1 = new List<sObject>();
        List<SObject> listaResultado2 = new List<sObject>();
        List<SObject> listaResultado3 = new List<sObject>();
        List<SObject> listaResultado4 = new List<sObject>();
        List<SObject> listaResultado5 = new List<sObject>();

        System.RunAs(usuario){
            listaResultado1 = SAC_LCMP_BuscadorMCCController.buscarResultados('Prov', 'buscadorTematica', '');
            listaResultado2 = SAC_LCMP_BuscadorMCCController.buscarResultados('Prov', 'buscadorProducto', mcct.id);
            listaResultado3 = SAC_LCMP_BuscadorMCCController.buscarResultados('Prov', 'buscadorMotivo', mccp.id);
            listaResultado4 = SAC_LCMP_BuscadorMCCController.buscarResultados('Prov', 'buscadorDetalle', mccm.id);
            listaResultado5 = SAC_LCMP_BuscadorMCCController.buscarResultados('Prov', 'buscadorNivelDetalle', mccm.id);
        }
        Test.stopTest();
        
        Assert.areNotEqual(null, listaResultado1, 'No se ha podido cargar la lista');
        Assert.areNotEqual(null, listaResultado2, 'No se ha podido cargar la lista');
        Assert.areNotEqual(null, listaResultado3, 'No se ha podido cargar la lista');
        Assert.areNotEqual(null, listaResultado4, 'No se ha podido cargar la lista');
        Assert.areNotEqual(null, listaResultado5, 'No se ha podido cargar la lista');
    }


    @isTest
    static void buscarGruposDetalleTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);
        CC_MCC__c mccd = [SELECT id FROM CC_MCC__c WHERE Name = 'Discrepancia con importe deuda MCC Clase Test' LIMIT 1];

        List<SObject> listaResultado1 = new List<sObject>();

        System.RunAs(usuario){
            listaResultado1 = SAC_LCMP_BuscadorMCCController.buscarGruposDetalle(mccd.id);
        }
        Test.stopTest();
        
        Assert.areNotEqual(null, listaResultado1, 'No se ha podido cargar la lista');
    }


    @isTest
    static void actualizarCasoTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);
        
        CC_MCC__c mccd = [SELECT id FROM CC_MCC__c WHERE Name = 'Discrepancia con importe deuda MCC Cambio MCC' LIMIT 1];
        Case pretension = [SELECT id, SEG_Detalle__c FROM Case WHERE SuppliedCompany = 'pruebaMCC' limit 1];

        System.RunAs(usuario){
            SAC_LCMP_BuscadorMCCController.actualizarCaso(pretension.id, mccd.id);
        }
        Test.stopTest();
        
        Case pretensionCambioMCC = [SELECT id, SEG_Detalle__c FROM Case WHERE SuppliedCompany = 'pruebaMCC' limit 1];
        Assert.areEqual(mccd.id, pretensionCambioMCC.SEG_Detalle__c, 'No se ha podido cambiar la tipificación del MCC');
    }


    @isTest
    static void obtenerClasificacionActualTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);
        
        CC_MCC__c mccId = [SELECT id FROM CC_MCC__c WHERE Name = 'Discrepancia con importe deuda MCC Clase Test' LIMIT 1];
        Case pretension = [SELECT id, SEG_Detalle__c FROM Case WHERE SuppliedCompany = 'pruebaMCC' limit 1];
        Case pretensionClasificada;

        System.RunAs(usuario){
            pretensionClasificada = SAC_LCMP_BuscadorMCCController.obtenerClasificacionActual(pretension.id);
        }
        Test.stopTest();
        
        Assert.areEqual(mccId.id, pretensionClasificada.SEG_Detalle__c, 'No se ha podido obtener la tipificación del MCC');
    }
}