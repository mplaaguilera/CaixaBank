/*****************************************************************
 Name:  SIR_ValueAccion_Test
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase Test de la clase SIR_ValueAccion                                                                                                          
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US258874         Atmira         10/08/2021     	  Created    

*****************************************************************/
@isTest
public class SIR_ValueAccion_Test {
  /*****************************************************************
        Proposito:  test1 sirve para comprobar la logica de la clase SIR_ValueAccion                                                   
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
    	1.0            US258874         Atmira         10/08/2021     	  Created   
        
	*****************************************************************/    
    @istest static void test1(){
        SIR_Constantes constantes = new SIR_Constantes();
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
        SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.CrearAccion(proceso);
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        listAccion.add(accion);
        Test.startTest();
       	SIR_ValueAccion.valueAction(listAccion);
        Test.stopTest();
        System.assertEquals('174', accion.SIR_valorAccion__c , constantes.STRING_TEST);
    }
}