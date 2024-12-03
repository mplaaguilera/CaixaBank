/*****************************************************************
    Name:  SIR_cls_WS_altaProcRefinanciacionMock
    Copyright © 2021  CaixaBank

    Proposito:   Clase de test de la clase SIR_cls_WS_altaProcRefinanciacio                                                                                               
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US258825         Atmira         17/09/2021     	  Created    

    *****************************************************************/


@istest
public with sharing class SIR_cls_WS_altaProcRefinanciacionTest {

    @testSetup static void setupMethod(){ 
        SIR_TestDataFactory.CrearIntegrationSetting('altaProcRefinanciacion');
    }

    @istest
    public static void correcto() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        
   		System.runAs(usuario){
            SIR_Constantes constantes = new SIR_Constantes();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.CrearAccion(proceso);
            SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);
            infoCliente.SIREC__SIREC_fld_masterRecordId__c = 'Correcto';
            update infoCliente;
            List<String> lstString = new List<String>();
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_altaProcRefinanciacionMock()); 
            Test.startTest();
                List<String> lstResponse = SIR_cls_WS_altaProcRefinanciacion.altaProcRefinanciacion(proceso.Id);
            Test.stopTest();
            system.assertEquals(lstresponse.get(0), 'OK', constantes.STRING_TEST);
            system.assertEquals(lstresponse.get(1), 'IdProcesoCorrecto', constantes.STRING_TEST);
        }
    }

    @istest
    public static void incorrecto() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        
   		System.runAs(usuario){
            SIR_Constantes constantes = new SIR_Constantes();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.CrearAccion(proceso);
            SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);
            infoCliente.SIREC__SIREC_fld_masterRecordId__c = 'INCorrecto';
            update infoCliente;
            List<String> lstString = new List<String>();
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_altaProcRefinanciacionMock()); 
            Test.startTest();
                List<String> lstResponse = SIR_cls_WS_altaProcRefinanciacion.altaProcRefinanciacion(proceso.Id);
            Test.stopTest();
            system.assertEquals(lstresponse.get(0), 'KO', constantes.STRING_TEST);
        }
    }

    @istest
    public static void altaProcRefinanciacionMockTest(){
        SIR_Constantes constantes = new SIR_Constantes();
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
        SIR_cls_WS_altaProcRefinanciacion.AltaProcRefinanciacionRequest vBody =  new SIR_cls_WS_altaProcRefinanciacion.AltaProcRefinanciacionRequest(proceso.Id);
        SIR_cls_WS_altaProcRefinanciacion.AltaProcRefinanciacionResponse responseJson = new SIR_cls_WS_altaProcRefinanciacion.AltaProcRefinanciacionResponse();
        String idProcesoSirec = 'idProcesoSirec' + Integer.valueof((Math.random() * 100));
        SIR_cls_WS_altaProcRefinanciacion.DatosResponseDto datosResponseDto = new SIR_cls_WS_altaProcRefinanciacion.DatosResponseDto();
        datosResponseDto.idProcesoGestion = idProcesoSirec;
        responseJson.datosResponseDto = datosResponseDto;
        responseJson.codigoSalida = '1';
        
        test.startTest();
        String procesoJson = SIR_cls_WS_altaProcRefinanciacion.altaProcRefinanciacionMock(JSON.serialize(vBody));
        test.stopTest();
        system.assertNotEquals(Json.serializePretty(responseJson), procesoJson, 'Test');
    }

}