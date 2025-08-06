/*****************************************************************
 Name:  SIR_Batch_ControlCompromiso_Test
 Copyright © 2021  CaixaBank
 Proposito:   Clase Test de la clase SIR_Batch_ControlCompromiso                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         20/12/2021     	 Created    

*****************************************************************/

@istest
public with sharing class SIR_Batch_ControlCompromiso_Test {

    @testSetup static void setupMethod(){
        SIR_TestDataFactory.CrearIntegrationSetting('altaResultAcciones');
    }


    @istest
    public static void SIR_Batch_ControlCompromiso_Test1() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank','U012222');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        System.runAs(usuario) {
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
        SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.crearAccionProcesoAmistoso(proceso);
        SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);
        proceso.SIR_FechaCompromisoPago__c = Date.today().addDays(-1);
        proceso.SIR_fld_Situacion_SF__c = SIR_Constantes.PROCESO_SITUACION_COMPROMISO_DE_PAGO;
        update proceso;
        accion.SIREC__SIREC_fld_accion__c = '01';
        accion.SIREC__SIREC_fld_resultado__c = SIR_Constantes.ACCION_RESULTADO_COMPROMISO_DE_PAGO;
        update accion;
        Test.setMock(HttpCalloutMock.class, new SIR_SendNewAction_WSMock()); 
        Test.startTest(); 
        SIR_Batch_ControlCompromiso myBatchObject = new SIR_Batch_ControlCompromiso();
        Database.executeBatch(myBatchObject);
        Test.stopTest();
        Map<Id,SIREC__SIREC_obj_acciones__c> mapAcciones = new Map<Id,SIREC__SIREC_obj_acciones__c>([SELECT Id,SIREC__SIREC_fld_resultado__c  FROM SIREC__SIREC_obj_acciones__c ORDER BY CreatedDate DESC]);
        System.assertEquals(2, mapAcciones.keyset().size(), 'No se ha clonado');
        }
    }

    @istest
    public static void SIR_Batch_ControlCompromiso_Test2() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank','U012222');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        System.runAs(usuario) {
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
        SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.crearAccionProcesoAmistoso(proceso);
        SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);
        proceso.SIR_FechaCompromisoPago__c = Date.today().addDays(-1);
        proceso.SIR_fld_Situacion_SF__c = SIR_Constantes.PROCESO_SITUACION_COMPROMISO_DE_PAGO;
        update proceso;
        accion.SIREC__SIREC_fld_accion__c = '01';
        accion.SIREC__SIREC_fld_resultado__c = SIR_Constantes.ACCION_RESULTADO_COMPROMISO_DE_PAGO;
        update accion;
        SIREC__SIREC_obj_acciones__c accion2 = SIR_TestDataFactory.crearAccionProcesoAmistoso(proceso);
        accion2.SIREC__SIREC_fld_accion__c = '01';
        accion2.SIREC__SIREC_fld_resultado__c = SIR_Constantes.ACCION_RESULTADO_COMPROMISO_DE_PAGO;
        update accion2;
        Test.setMock(HttpCalloutMock.class, new SIR_SendNewAction_WSMock()); 
        Test.startTest(); 
        SIR_Batch_ControlCompromiso myBatchObject = new SIR_Batch_ControlCompromiso();
        Database.executeBatch(myBatchObject);
        Test.stopTest();
        Map<Id,SIREC__SIREC_obj_acciones__c> mapAcciones = new Map<Id,SIREC__SIREC_obj_acciones__c>([SELECT Id,SIREC__SIREC_fld_resultado__c  FROM SIREC__SIREC_obj_acciones__c ORDER BY CreatedDate DESC]);
        System.assertEquals(3, mapAcciones.keyset().size(), 'No se ha clonado');
        }
    }
}