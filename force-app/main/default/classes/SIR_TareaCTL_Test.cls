/*****************************************************************
 Name:  SIR_TareaCTL_Test
 Copyright © 2022  CaixaBank
============================================================
Proposito:   Clase Test de la clase controladora externa del LWC SIR_LCMP_TareaCTL                                                                                                          
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         28/09/2022     	  Created    

*****************************************************************/
@istest
public with sharing class SIR_TareaCTL_Test {
    
    @TestSetup
    static void makeData(){

        SIR_TestDataFactory.CrearIntegrationSetting('llamadaMotor');
    }
    
    @isTest static void test1() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank','U012222');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        SIREC__SIREC_obj_proceso__c proceso, resproceso;
        SIREC__SIREC_obj_tarea__c tarea;
        List<String> response = new List<String>();
        System.runAs(usuario) {
        Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_llamadaMotorMock());
        Test.startTest();
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345644');
        tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);       
        resproceso = SIR_LCMP_TareaCTL.getTarea(proceso.id);
        response = SIR_LCMP_TareaCTL.llamadaWS(tarea.Id);
        
        Test.stopTest();
        }
        Assert.areEqual(proceso.id, resproceso.Id, 'SIR_TareaCTL_Test No se ha obtenido el id del proceso.');
    }
    
    
}