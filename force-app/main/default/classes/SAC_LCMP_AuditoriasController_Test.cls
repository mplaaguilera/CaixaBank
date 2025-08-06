/***********************************************************************
 * Name: SAC_LCMP_AuditoriasController_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Clase test de SAC_LCMP_AuditoriasController
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US361683         Carlos Gómez        07/11/23         Creación 
*************************************************************************/
@isTest
public with sharing class SAC_LCMP_AuditoriasController_Test {
    @TestSetup
    static void makeData(){
        Test.startTest();
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];

        //Usuario Admin
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);

        User usuario = new User();
        System.RunAs(usuarioAdmin) {
            usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            usuario.Username = 'ustestesteo@test.com'; 
            usuario.UserRoleId = uRole.id;      
            SAC_DatabaseDML.insertDML(usuario, false);
        }
        Test.stopTest();

        Id recTypeTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recTypeProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recTypeMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recTypeDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();

        //MCC
        CC_MCC__c mccTematica1 = new CC_MCC__c(
        RecordTypeId = recTypeTematica,
        Name = 'Avales MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-0101');
        SAC_DatabaseDML.insertDML(mccTematica1, false);

        CC_MCC__c mccProdServ1 = new CC_MCC__c(
        RecordTypeId = recTypeProdServ,
        Name = 'Avales Fianzas y Otras Garantías MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101',
        CC_Tematica__c = mccTematica1.id);
        SAC_DatabaseDML.insertDML(mccProdServ1, false);

        CC_MCC__c mccMotivo1 = new CC_MCC__c(
        RecordTypeId = recTypeMotivo,
        Name = 'Discrepancia con importe deuda reclamada MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Producto_Servicio__c = mccProdServ1.id,
        CC_Codigo_Externo__c = 'TEST-0102');
        SAC_DatabaseDML.insertDML(mccMotivo1, false);

        CC_MCC__c mccDetalle2 = new CC_MCC__c(
        RecordTypeId = recTypeDetalle,
        Name = 'Discrepancia con importe deuda MCC Clase Test',
        CC_Tipo_Cliente__c = 'SAC',
        CC_Codigo_Externo__c = 'TEST-010101012',
        CC_Motivo__c = mccMotivo1.id,
        SAC_GenerarTaskMisClientes__c = true);
        SAC_DatabaseDML.insertDML(mccDetalle2, false);

        //GRUPOS
        List<CC_Grupo_Colaborador__c> listGrupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupo1 = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor', 1)[0];
        grupo1.OwnerId = usuario.id;
        listGrupos.add(grupo1);

        CC_Grupo_Colaborador__c grupo2 = SAC_TestDataFactory.crearGrupoColaborador('GrupoLetrados', 1)[0];
        grupo2.OwnerId = usuario.id;
        listGrupos.add(grupo2);

        CC_Grupo_Colaborador__c grupoResp = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion', 1)[0];
        grupoResp.OwnerId = usuario.id;
        grupoResp.SAC_DeveloperName__c = 'COPS';
        listGrupos.add(grupoResp);
        SAC_DatabaseDML.insertListDML(listGrupos, false);

        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact = SAC_TestDataFactory.crearColaboradorContact(usuario.Id,listGrupos[0].Id);
        grupoColaboradorContact.SAC_Auditor__c = true;
        SAC_DatabaseDML.insertDML(grupoColaboradorContact, false);

        // CC_Grupo_Colaborador_Contact__c grupoColaboradorContact2 = SAC_TestDataFactory.crearColaboradorContact(usuario.Id,listGrupos[1].Id);
        // grupoColaboradorContact2.SAC_Auditor__c = true;
        // Database.insert(grupoColaboradorContact2);

        List<Case> lstRecl = new List<Case>();
        //RECLAMACION 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'Cerrado');
        camposRecl.put('SAC_StatusAuxiliar__c', 'Cerrado');
        camposRecl.put('OwnerId', usuario.Id);
        camposRecl.put('SEG_SRAuditoria__c', false);
        camposRecl.put('SEG_Grupo__c', listGrupos[0].Id);
        camposRecl.put('SAC_GrupoLetrado__c', listGrupos[1].Id);
        camposRecl.put('SAC_Letrado__c', usuario.Name);
        camposRecl.put('CC_Importe_Abonado__c', 50);
        camposRecl.put('CC_MCC_Tematica__c', mccTematica1.Id);
        camposRecl.put('CC_MCC_ProdServ__c', mccProdServ1.Id);
        camposRecl.put('CC_MCC_Motivo__c', mccMotivo1.Id);
        camposRecl.put('SEG_Detalle__c', mccDetalle2.Id);
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        lstRecl.add(casoReclamacion);

        //RECLAMACION 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('Status', 'Alta');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl2.put('OwnerId', usuario.Id);
        
        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        lstRecl.add(casoReclamacion2);
        SAC_DatabaseDML.insertListDML(lstRecl, false);


        //PRETENSION 1
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'prueba');
        camposPret.put('Origin', 'Backoffice');
        camposPret.put('OwnerId', usuario.Id);
        camposPret.put('Status', 'SAC_009');
        camposPret.put('SAC_StatusAuxiliar__c', 'SAC_009');
		camposPret.put('SAC_Reclamacion__c', lstRecl[0].Id);
        camposPret.put('CC_MCC_Tematica__c', mccTematica1.Id);
        camposPret.put('CC_MCC_ProdServ__c', mccProdServ1.Id);
        camposPret.put('CC_MCC_Motivo__c', mccMotivo1.Id);
        camposPret.put('SEG_Detalle__c', mccDetalle2.Id);
        
        Case casoPretension1 = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        SAC_DatabaseDML.insertDML(casoPretension1, false);


        //AUDITORIA
        SEG_Auditoria__c auditoriaPadre = new SEG_Auditoria__c();
        auditoriaPadre.SAC_NombreAuditoria__c = 'AuditoriaPadreTest';
        auditoriaPadre.SAC_Tipo__c = 'SAC_Todas';
        auditoriaPadre.SAC_DictamenManual__c = 'SAC_Pendiente';
        auditoriaPadre.RecordTypeId = Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName().get('SAC_AuditoriaGeneral').getRecordTypeId();
        auditoriaPadre.OwnerId = usuario.Id;
        SAC_DatabaseDML.insertDML(auditoriaPadre, false);

        //AUDITORIA
        SEG_Auditoria__c auditoria = new SEG_Auditoria__c();
        auditoria.SAC_NombreAuditoria__c = 'AuditoriaTest';
        auditoria.SAC_Tipo__c = 'SAC_Todas';
        auditoria.SAC_DictamenManual__c = 'SAC_Pendiente';
        auditoria.SAC_Reclamacion__c = casoReclamacion.id;
        auditoria.SAC_AuditoriaGeneral__c = auditoriaPadre.Id;
        auditoria.RecordTypeId = Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName().get('SAC_Auditoria').getRecordTypeId();
        auditoria.OwnerId = usuario.Id;
        SAC_DatabaseDML.insertDML(auditoria, false);

        //AUDITORIA
        SEG_Auditoria__c auditoriaFin = new SEG_Auditoria__c();
        auditoriaFin.SAC_NombreAuditoria__c = 'AuditoriaFinalizadaTest';
        auditoriaFin.SAC_Tipo__c = 'SAC_Todas';
        auditoriaFin.SAC_DictamenManual__c = 'SAC_OK';
        auditoriaFin.SAC_Reclamacion__c = casoReclamacion2.id;
        auditoriaFin.RecordTypeId = Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName().get('SAC_Auditoria').getRecordTypeId();
        auditoriaFin.SAC_Observaciones__c = 'Obs prueba';
        auditoriaFin.SAC_Replica__c = 'Replica prueba';
        auditoriaFin.OwnerId = usuario.Id;
        SAC_DatabaseDML.insertDML(auditoriaFin, false);

        //AUDITORIA COMPLETADA
        SEG_Auditoria__c auditoriaCompletada = new SEG_Auditoria__c();
        auditoriaCompletada.SAC_NombreAuditoria__c = 'AuditoriaCompletadaTest';
        auditoriaCompletada.SAC_Tipo__c = 'SAC_Altas';
        auditoriaCompletada.SAC_DictamenManual__c = 'SAC_OK';
        auditoriaCompletada.SAC_Estado__c = 'SAC_Completada';
        auditoriaCompletada.SAC_Reclamacion__c = casoReclamacion.id;
        auditoriaCompletada.SAC_AuditoriaGeneral__c = auditoriaPadre.Id;
        auditoriaCompletada.RecordTypeId = Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName().get('SAC_Auditoria').getRecordTypeId();
        auditoriaCompletada.SAC_Observaciones__c = 'Obs prueba completada';
        auditoriaCompletada.OwnerId = usuario.Id;
        SAC_DatabaseDML.insertDML(auditoriaCompletada, false);

        System.runAs(usuario) {
            EmailMessage em  = new EmailMessage();
            em.relatedtoId = auditoriaPadre.Id;
            em.Subject = 'emTestAuditoria';
            SAC_DatabaseDML.insertDML(em, false);
        }
    }

    @isTest
    static void buscarResultadosTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        CC_MCC__c mcct = [SELECT id FROM CC_MCC__c WHERE Name = 'Avales MCC Clase Test' LIMIT 1];
        CC_MCC__c mccp = [SELECT id FROM CC_MCC__c WHERE Name = 'Avales Fianzas y Otras Garantías MCC Clase Test' LIMIT 1];
        CC_MCC__c mccm = [SELECT id FROM CC_MCC__c WHERE Name = 'Discrepancia con importe deuda reclamada MCC Clase Test' LIMIT 1];
        CC_Grupo_Colaborador__c grupoProv = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Proveedor 0' LIMIT 1];

        List<SObject> listaResultado1 = new List<sObject>();
        List<SObject> listaResultado2 = new List<sObject>();
        List<SObject> listaResultado3 = new List<sObject>();
        List<SObject> listaResultado4 = new List<sObject>();
        List<SObject> listaResultado5 = new List<sObject>();
        List<SObject> listaResultado6 = new List<sObject>();
        List<SObject> listaResultado7 = new List<sObject>();
        List<SObject> listaResultado8 = new List<sObject>();

        System.RunAs(usuario){
            listaResultado1 = SAC_LCMP_AuditoriasController.buscarResultados('Prov', 'buscadorGrupoProveedor', '');
            listaResultado2 = SAC_LCMP_AuditoriasController.buscarResultados('Letr', 'buscadorGrupoLetrado', '');
            listaResultado3 = SAC_LCMP_AuditoriasController.buscarResultados('Prov', 'buscadorTematica', '');
            listaResultado3 = SAC_LCMP_AuditoriasController.buscarResultados('Test', 'buscadorGestor', grupoProv.id);
            listaResultado4 = SAC_LCMP_AuditoriasController.buscarResultados('Prov', 'buscadorProducto', mcct.id);
            listaResultado5 = SAC_LCMP_AuditoriasController.buscarResultados('Prov', 'buscadorMotivo', mccp.id);
            listaResultado6 = SAC_LCMP_AuditoriasController.buscarResultados('Prov', 'buscadorDetalle', mccm.id);
            listaResultado7 = SAC_LCMP_AuditoriasController.buscarResultados('Prov', 'buscadorVariosGruposProv', grupoProv.Id);
            listaResultado8 = SAC_LCMP_AuditoriasController.buscarResultados('Prov', 'buscadorGrupoResolver', '');
        }
        Test.stopTest();
        
        Assert.areNotEqual(null, listaResultado1, 'No se ha podido cargar la lista');
        Assert.areNotEqual(null, listaResultado2, 'No se ha podido cargar la lista');
        Assert.areNotEqual(null, listaResultado3, 'No se ha podido cargar la lista');
        Assert.areNotEqual(null, listaResultado4, 'No se ha podido cargar la lista');
        Assert.areNotEqual(null, listaResultado5, 'No se ha podido cargar la lista');
        Assert.areNotEqual(null, listaResultado6, 'No se ha podido cargar la lista');
        Assert.areNotEqual(null, listaResultado7, 'No se ha podido cargar la lista');
        Assert.areNotEqual(null, listaResultado8, 'No se ha podido cargar la lista');
    }

    @isTest
    static void buscarReclamacionAuditoriaTest(){
        Test.startTest();
        User usuario = [SELECT id, Name FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        CC_Grupo_Colaborador__c g1 = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordType.DeveloperName = 'SAC_GrupoProveedores' LIMIT 1];
        CC_Grupo_Colaborador__c g2 = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordType.DeveloperName = 'SAC_Letrados' LIMIT 1];
        CC_MCC__c mcct = [SELECT id FROM CC_MCC__c WHERE Name = 'Avales MCC Clase Test' LIMIT 1];
        CC_MCC__c mccp = [SELECT id FROM CC_MCC__c WHERE Name = 'Avales Fianzas y Otras Garantías MCC Clase Test' LIMIT 1];
        CC_MCC__c mccm = [SELECT id FROM CC_MCC__c WHERE Name = 'Discrepancia con importe deuda reclamada MCC Clase Test' LIMIT 1];
        CC_MCC__c mccd = [SELECT id FROM CC_MCC__c WHERE Name = 'Discrepancia con importe deuda MCC Clase Test' LIMIT 1];

        List<SAC_LCMP_AuditoriasController.ReclamacionWrapper> wrapperRec1 = new List<SAC_LCMP_AuditoriasController.ReclamacionWrapper>();
        List<SAC_LCMP_AuditoriasController.ReclamacionWrapper> wrapperRec2 = new List<SAC_LCMP_AuditoriasController.ReclamacionWrapper>();

        List<String> sentidoResolucion = new List<String>();
        sentidoResolucion.add('SAC_001');
        System.RunAs(usuario){
            wrapperRec1 = SAC_LCMP_AuditoriasController.buscarReclamacionAuditoria('Negociación',true,null,null,g1.Id,g2.Id,usuario.Id,usuario.Name,10,100, sentidoResolucion, new List<String>{mcct.Id}, new List<String>{mccp.Id}, new List<String>{mccm.Id}, new List<String>{mccd.Id}, 1);
            wrapperRec2 = SAC_LCMP_AuditoriasController.buscarReclamacionAuditoria('Negociación', false,null,null,g1.Id,g2.Id,usuario.Id,usuario.Name,10,100,sentidoResolucion, new List<String>{mcct.Id}, new List<String>{mccp.Id}, new List<String>{mccm.Id}, new List<String>{mccd.Id}, 1);
        }
        Test.stopTest();

        Assert.areNotEqual(null, wrapperRec1, 'No se ha podido cargar la lista');
        Assert.areNotEqual(null, wrapperRec2, 'No se ha podido cargar la lista');
    }


    @isTest
    static void comprobarGruposUserTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        CC_Grupo_Colaborador__c g1 = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordType.DeveloperName = 'SAC_GrupoProveedores' LIMIT 1];
        CC_Grupo_Colaborador__c g2 = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordType.DeveloperName = 'SAC_Letrados' LIMIT 1];
        String cadenaGrupos = g1.Id +';'+ g2.Id;
        SAC_LCMP_AuditoriasController.InfoGruposUser infoGrupos;

        System.RunAs(usuario){
           infoGrupos = SAC_LCMP_AuditoriasController.comprobarGruposUser(cadenaGrupos, usuario.id);
        }

        Test.stopTest();
        Assert.areNotEqual(null, infoGrupos, 'No se ha podido cargar la lista');

    }

    @isTest
    static void crearAuditoriaTest(){
        Test.startTest();
        User usuario = [SELECT id, Name FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];

        CC_Grupo_Colaborador__c g1 = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordType.DeveloperName = 'SAC_GrupoProveedores' LIMIT 1];
        CC_Grupo_Colaborador__c g2 = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordType.DeveloperName = 'SAC_Letrados' LIMIT 1];
        CC_MCC__c mcct = [SELECT id, Name FROM CC_MCC__c WHERE Name = 'Avales MCC Clase Test' LIMIT 1];
        CC_MCC__c mccp = [SELECT id, Name FROM CC_MCC__c WHERE Name = 'Avales Fianzas y Otras Garantías MCC Clase Test' LIMIT 1];
        CC_MCC__c mccm = [SELECT id, Name FROM CC_MCC__c WHERE Name = 'Discrepancia con importe deuda reclamada MCC Clase Test' LIMIT 1];
        CC_MCC__c mccd = [SELECT id, Name FROM CC_MCC__c WHERE Name = 'Discrepancia con importe deuda MCC Clase Test' LIMIT 1];
        List<Case> reclamaciones = [SELECT id FROM Case WHERE Subject = 'TestRec'];
        List<String> listCasos = new List<String>();

        for(Case rec : reclamaciones){
            listCasos.add(rec.Id);
        }
       

        
        System.RunAs(usuario){
            SAC_LCMP_AuditoriasController.crearAuditoria('AuditoriaTest', 'SAC_Altas', 'SAC_SLACalidadTrue', null, null, g1.id, g2.Id, usuario.id, usuario.id, 10, 100, 'SAC_001', mcct.id, mccp.id, mccm.id, mccd.id, mcct.Name, mccp.Name, mccm.Name, mccd.Name, g1.id, listCasos);
        }
        Test.stopTest();

        SEG_Auditoria__c auditoria = [SELECT id FROM SEG_Auditoria__c WHERE SAC_NombreAuditoria__c = 'AuditoriaTest' limit 1];
        Assert.areNotEqual(null, auditoria.id, 'no se pudo recuperar la auditoria');
    }

    @isTest
    static void getAuditoriasHijasTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];

        SEG_Auditoria__c auditoriaPadre = [SELECT Id FROM SEG_Auditoria__c WHERE SAC_NombreAuditoria__c = 'AuditoriaPadreTest'];

        List<SEG_Auditoria__c> auditorias = new List<SEG_Auditoria__c>();

        System.RunAs(usuario){
            auditorias = SAC_LCMP_AuditoriasController.getAuditoriasHijas(auditoriaPadre.Id);
        }
        Test.stopTest();
        Assert.areNotEqual(null, auditorias, 'no se pudo recuperar la auditoria');
    }
    
    @isTest
    static void crearAuditoriaReclamacionTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        List<PermissionSetAssignment> lstPsAssigment = new List<PermissionSetAssignment>();
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_AdministradorGrupos'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        lstPsAssigment.add(permiSetAssi);

        PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuario.Id;
        permiSetAssi2.PermissionSetId = permiSet2.Id;
        lstPsAssigment.add(permiSetAssi2);
        SAC_DatabaseDML.insertListDML(lstPsAssigment, false);

        Case caso = [SELECT id, SEG_SRAuditoria__c  FROM Case WHERE Subject = 'TestRec' limit 1];

        System.RunAs(usuario){
            SAC_LCMP_AuditoriasController.crearAuditoriaReclamacion(caso, 'SAC_Altas', 'AuditoriaTest', 'SAC_SLACalidadTrue');
        }

        Test.stopTest();
        SEG_Auditoria__c audi = [SELECT id FROM SEG_Auditoria__c WHERE SAC_NombreAuditoria__c = 'AuditoriaTest' limit 1];
        Assert.areNotEqual(null, audi.id, 'no se pudo recuperar la auditoria');
    }

    @isTest
    static void getAuditoriaReclamacionTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        Case caso = [SELECT id, SEG_SRAuditoria__c  FROM Case WHERE Subject = 'TestRec' limit 1];
        SAC_LCMP_AuditoriasController.InfoAuditoriaReclamacion infoAuditoria;
        List<PermissionSetAssignment> lstPsAssigment = new List<PermissionSetAssignment>();

        PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuario.Id;
        permiSetAssi2.PermissionSetId = permiSet2.Id;
        lstPsAssigment.add(permiSetAssi2);
        SAC_DatabaseDML.insertListDML(lstPsAssigment, false);

        System.RunAs(usuario){
            infoAuditoria = SAC_LCMP_AuditoriasController.getAuditoriaReclamacion(caso);
        }
        Test.stopTest();
        Assert.areNotEqual(null, infoAuditoria, 'no se pudo recuperar la informacion');
    }

    
    @isTest
    static void finalizarAuditoriaReclamacionTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        Case caso = [SELECT id, SEG_SRAuditoria__c  FROM Case WHERE Subject = 'TestRec2' limit 1];
        SEG_Auditoria__c audi = [SELECT id, SAC_Estado__c FROM SEG_Auditoria__c WHERE SAC_NombreAuditoria__c = 'AuditoriaFinalizadaTest' limit 1];
        List<PermissionSetAssignment> lstPsAssigment = new List<PermissionSetAssignment>();

        PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuario.Id;
        permiSetAssi2.PermissionSetId = permiSet2.Id;
        lstPsAssigment.add(permiSetAssi2);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        lstPsAssigment.add(permiSetAssi);
        SAC_DatabaseDML.insertListDML(lstPsAssigment, false);

        System.RunAs(usuario){
            SAC_LCMP_AuditoriasController.finalizarAuditoriaReclamacion(caso, audi.id);
        }
        Test.stopTest();
        SEG_Auditoria__c audiFinal = [SELECT SAC_Estado__c, id FROM SEG_Auditoria__c WHERE SAC_NombreAuditoria__c = 'AuditoriaFinalizadaTest' limit 1 ];
        Assert.areEqual('SAC_Completada', audiFinal.SAC_Estado__c , 'No se ha podido finalizar la auditoria');
    }

    @isTest
    static void comprobarPermisosAuditoriaTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];

        Case caso = [SELECT id, SEG_SRAuditoria__c, SEG_Grupo__c  FROM Case WHERE Subject = 'TestRec2' limit 1];

        Boolean tienePermisos ;

        System.RunAs(usuario){
            tienePermisos = SAC_LCMP_AuditoriasController.comprobarPermisosCreacionAuditoria(caso);
        }
        Test.stopTest();
        Assert.areEqual(true, tienePermisos, 'no tiene permisos');
    }


    @isTest
    static void replicarAuditoriaReclamacionTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        Case caso = [SELECT id, SEG_SRAuditoria__c, SEG_Grupo__c  FROM Case WHERE Subject = 'TestRec2' limit 1];
        SEG_Auditoria__c audi = [SELECT id, SAC_Estado__c FROM SEG_Auditoria__c WHERE SAC_NombreAuditoria__c = 'AuditoriaFinalizadaTest' limit 1];
        List<PermissionSetAssignment> lstPsAssigment = new List<PermissionSetAssignment>();

        PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuario.Id;
        permiSetAssi2.PermissionSetId = permiSet2.Id;
        lstPsAssigment.add(permiSetAssi2);
        
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        lstPsAssigment.add(permiSetAssi);
        SAC_DatabaseDML.insertListDML(lstPsAssigment, false);

        System.RunAs(usuario){
            SAC_LCMP_AuditoriasController.replicarAuditoriaReclamacion(caso, audi.id);
        }
        Test.stopTest();
        SEG_Auditoria__c audiRevisada = [SELECT id, SAC_Estado__c FROM SEG_Auditoria__c WHERE SAC_NombreAuditoria__c = 'AuditoriaFinalizadaTest' limit 1];
        Assert.areEqual('SAC_Revisada', audiRevisada.SAC_Estado__c, 'No se ha revisado la auditoría');
    }

    @isTest
    static void getEmailMessagesByAuditoriaIdTest() {
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        List<PermissionSetAssignment> lstPsAssigment = new List<PermissionSetAssignment>();

        PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuario.Id;
        permiSetAssi2.PermissionSetId = permiSet2.Id;
        lstPsAssigment.add(permiSetAssi2);
        SAC_DatabaseDML.insertListDML(lstPsAssigment, false);

        SEG_Auditoria__c auditoriaPadre = [SELECT Id FROM SEG_Auditoria__c WHERE SAC_NombreAuditoria__c = 'AuditoriaPadreTest' LIMIT 1];
        List<EmailMessage> listaEM = new List<EmailMessage>();

        System.runAs(usuario) {
            listaEM = SAC_LCMP_AuditoriasController.getEmailMessagesByAuditoriaId(auditoriaPadre.Id);
        }
        Test.stopTest();

        Assert.areEqual(!listaEM.isEmpty(), true, 'No se han recuperado los emails');
    }

    @isTest
    static void comprobarEnvioEmailTest() {
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        List<PermissionSetAssignment> lstPsAssigment = new List<PermissionSetAssignment>();

        PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuario.Id;
        permiSetAssi2.PermissionSetId = permiSet2.Id;
        lstPsAssigment.add(permiSetAssi2);
        SAC_DatabaseDML.insertListDML(lstPsAssigment, false);

        SEG_Auditoria__c audi = [SELECT Id FROM SEG_Auditoria__c WHERE SAC_NombreAuditoria__c = 'AuditoriaTest' LIMIT 1];
        Boolean envioEmail;

        System.runAs(usuario) {
            envioEmail = SAC_LCMP_AuditoriasController.comprobarEnvioEmail(audi.Id);
        }
        Test.stopTest();

        Assert.areEqual(envioEmail, true, 'Todas las auditorias no están completadas o revisadas');
    }

    @isTest
    static void enviarEmailsAuditoresTest() {
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        List<PermissionSetAssignment> lstPsAssigment = new List<PermissionSetAssignment>();

        PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuario.Id;
        permiSetAssi2.PermissionSetId = permiSet2.Id;
        lstPsAssigment.add(permiSetAssi2);
        SAC_DatabaseDML.insertListDML(lstPsAssigment, false);

        SEG_Auditoria__c audi = [SELECT Id FROM SEG_Auditoria__c WHERE SAC_NombreAuditoria__c = 'AuditoriaTest' LIMIT 1];

        System.runAs(usuario) {
            SAC_LCMP_AuditoriasController.enviarEmailsAuditores(audi.Id);
        }

        Assert.areNotEqual(0, [SELECT Count() FROM EmailMessage WHERE CreatedDate = TODAY], 'No se ha podido efectuar el envío de email');
        Test.stopTest();
    }

    @isTest
    static void crearProgramacionAuditoria() {
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];
        List<PermissionSetAssignment> lstPsAssigment = new List<PermissionSetAssignment>();

        PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuario.Id;
        permiSetAssi2.PermissionSetId = permiSet2.Id;
        lstPsAssigment.add(permiSetAssi2);
        SAC_DatabaseDML.insertListDML(lstPsAssigment, false);

        System.runAs(usuario) {
            Date dToday = CBK_UtilsDate.todayDT();
            SAC_LCMP_AuditoriasController.crearProgramacionAuditoria('testAuditoriaAutomaticaTest', 'SAC_Altas', 'SAC_SLACalidadTrue', dToday, dToday, 'Hoy', null, null, 10, 11, null, null, null, null, null, null, null, null, null,  1, null, true, 'Diaria: Lunes');
        }
    
        SEG_Auditoria__c auditoria = [SELECT Id FROM SEG_Auditoria__c WHERE RecordType.DeveloperName = 'SAC_AuditoriaAutomatica' AND SAC_NombreAuditoria__c = 'testAuditoriaAutomaticaTest' LIMIT 1];
       
        Assert.areNotEqual(null, auditoria, 'No se ha podido crear la auditoria');
        Test.stopTest();
    }
}