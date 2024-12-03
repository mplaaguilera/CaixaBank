/*****************************************************************
 Name:  SIR_arbolProceso_Test
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase test de LWC SIR_LCMP_arbolProceso                                                                                                                 
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US291328         Atmira         16/11/2021     	  Created    

*****************************************************************/
@istest
public with sharing class SIR_arbolProceso_Test {
    @isTest
    public static void testArbolEstrategias() {
        List<SIR_LCMP_arbolProceso.ProcesoWrapper> lstProcesoWrapper;
        SIR_Constantes constantes = new SIR_Constantes();
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProcesoFechaConcreta(cuenta);
        proceso.Name = 'testArbolEstrategias';
        proceso.SIREC__SIREC_fld_estrategia__c = 'E.6 – Sin prioridad';
        proceso.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION;
        update proceso; 
        SIR_TestDataFactory.crearHistoricoProceso(1, proceso);
        Test.startTest();
        lstProcesoWrapper = SIR_LCMP_arbolProceso.getProcesos(proceso.id);
        Test.stopTest();
        System.assertEquals(1, lstProcesoWrapper.size(),'No se ha generado el wrapper de proceso correctamente');
        System.assertEquals('testArbolEstrategias', lstProcesoWrapper[0].Name,'El nombre no se ha cogido correctamente');
        
    }
}