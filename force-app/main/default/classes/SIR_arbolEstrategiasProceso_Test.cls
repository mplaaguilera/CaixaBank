/*****************************************************************
 Name:  SIR_arbolEstrategiasProceso_Test
 Copyright © 2021  CaixaBank

Proposito:   Clase test de LWC SIR_LCMP_arbolEstrategiasProceso                                                                                                                 

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US291328         Atmira         16/11/2021     	  Created    
	2.0								Atmira		   27/12/2022	      Modificación
*****************************************************************/
@istest
public with sharing class SIR_arbolEstrategiasProceso_Test {
    @isTest
    public static void testArbolEstrategias() {
        List<SIR_LCMP_arbolEstrategiasProceso.ProcesoWrapper> lstProcesoWrapper;
        SIR_LCMP_arbolEstrategiasProceso.Items items = new SIR_LCMP_arbolEstrategiasProceso.Items(); 
        items.estrategia = 'estrategia';
        SIR_Constantes constantes = new SIR_Constantes();
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProcesoFechaConcreta(cuenta);
        proceso.SIR_ObjetivoProceso__c = 'EN GESTION';
        proceso.SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E6;//'E.6 – Sin prioridad';
        proceso.name  = SIR_Constantes.tipoProceso_Gestion1_90;
        proceso.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_FINALIZADO; 
		proceso.SIR_FechaInicioEstrategia__c = date.today().addDays(15);
        proceso.SIR_CicloImpago__c = 52;        
        update proceso;
        
        SIREC__SIREC_obj_proceso__c proceso2 = SIR_TestDataFactory.crearProcesoFechaConcreta(cuenta);
        proceso2.SIR_ObjetivoProceso__c = SIR_Constantes.PROCESO_OBJETIVO_INFORMATIVO;
        proceso2.SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E0;//'E.6 – Sin prioridad';
        proceso2.name  = SIR_Constantes.tipoProceso_Gestion1_90;
        proceso2.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION; 
		proceso2.SIR_FechaInicioEstrategia__c = date.today().addDays(10);
        proceso2.SIR_CicloImpago__c = 52;        
        update proceso2;
        
        SIR_TestDataFactory.crearHistoricoProceso(1, proceso);
        Test.startTest();
        lstProcesoWrapper = SIR_LCMP_arbolEstrategiasProceso.getProcesos(cuenta.id);
		Test.stopTest();
        System.assertEquals(1, lstProcesoWrapper.size(),'No se ha generado el wrapper de proceso correctamente');
        System.assertEquals(SIR_Constantes.tipoProceso_Gestion1_90, lstProcesoWrapper[0].Name,'El nombre no se ha cogido correctamente');
        //System.assertEquals(String.valueOf(date.today().addDays(-15)), lstProcesoWrapper[0].fechaInicio,'La fecha inicio no se ha cogido correctamente');
    }
    
    @isTest
    public static void testArbolEstrategias2() {
        List<SIR_LCMP_arbolEstrategiasProceso.ProcesoWrapper> lstProcesoWrapper;
        SIR_LCMP_arbolEstrategiasProceso.Items items = new SIR_LCMP_arbolEstrategiasProceso.Items(); 
        items.estrategia = 'estrategia';
        SIR_Constantes constantes = new SIR_Constantes();
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProcesoFechaConcreta(cuenta);
        proceso.SIR_ObjetivoProceso__c = 'EN GESTION';
        proceso.SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E6;//'E.6 – Sin prioridad';
        proceso.name  = SIR_Constantes.tipoProceso_Gestion1_90;
        proceso.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION; 
		proceso.SIR_FechaInicioEstrategia__c = date.today().addDays(15);
        proceso.SIR_CicloImpago__c = 52;        
        update proceso;
        
        SIREC__SIREC_obj_proceso__c proceso2 = SIR_TestDataFactory.crearProcesoFechaConcreta(cuenta);
        proceso2.SIR_ObjetivoProceso__c = 'EN GESTION';
        proceso2.SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E6;//'E.6 – Sin prioridad';
        proceso2.name  = SIR_Constantes.tipoProceso_Gestion1_90;
        proceso2.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_FINALIZADO; 
		proceso2.SIR_FechaInicioEstrategia__c = date.today().addDays(10);
        proceso2.SIR_CicloImpago__c = 52;        
        update proceso2;
        
        proceso.SIR_FechaInicioEstrategia__c = date.today().addDays(5);
        proceso.SIREC__SIREC_fld_fechaInicio__c  = date.today().addDays(5);
		proceso.SIREC__SIREC_fld_estrategia__c = 'E.3 – Cura del subjetivo';   
        update proceso;
        SIR_TestDataFactory.crearHistoricoProceso(1, proceso);
        Test.startTest();
        lstProcesoWrapper = SIR_LCMP_arbolEstrategiasProceso.getProcesos(cuenta.id);
		Test.stopTest();
        System.assertEquals(1, lstProcesoWrapper.size(),'No se ha generado el wrapper de proceso correctamente');
        System.assertEquals(SIR_Constantes.tipoProceso_Gestion1_90, lstProcesoWrapper[0].Name,'El nombre no se ha cogido correctamente');
        //System.assertEquals(String.valueOf(date.today().addDays(-15)), lstProcesoWrapper[0].fechaInicio,'La fecha inicio no se ha cogido correctamente');
    }
}