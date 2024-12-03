/*****************************************************************
 Name:  SIR_GetCapacidadYsolucion_Test
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase Test de la clase controladora externa del LWC SIR_LCMP_GetCapacidadYsolucion (sir_lwc_capacidadYsolucion)                                                                                                                  
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US US249658      Atmira         26/07/2021     	  Created    

*****************************************************************/
@isTest 
public class SIR_GetCapacidadYsolucion_Test {
   
    /*****************************************************************
        Proposito:  test1 sirve para comprobar toda la logica del controlador SIR_LCMP_GetCapacidadYsolucion                                                      
        Parameters: No
        Returns: No                                                        
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US US249658      Atmira         26/07/2021     	  Created    
        
	*****************************************************************/
     @isTest static void test1() {
        Test.startTest();
        SIR_Constantes constantes = new SIR_Constantes();
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
        SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
        List<SIR_FormularioRefinanciacion__c> lForm = new List<SIR_FormularioRefinanciacion__c>();
        lForm.add(formulario);
        SIR_LCMP_GetCapacidadYsolucion.getCapacidadFormulario(formulario.id);
        List<String> datosUpdate = new List<String>();
        datosUpdate.add(constantes.STRING_100); //SIR_SolucionFinalista__c
        datosUpdate.add(constantes.STRING_100); //SIR_ingresosFuturo__c
        datosUpdate.add(constantes.STRING_100); //SIR_textIngresosFuturo__c
        datosUpdate.add(constantes.STRING_100); //SIR_ratioAdmision__c
        datosUpdate.add(constantes.STRING_100); //SIR_solucionCortoPlazo__c
        datosUpdate.add(constantes.STRING_100); //SIR_solucionLargoPlazo__c
        datosUpdate.add(constantes.STRING_TEST); //SIR_tipoDificultad__c
        datosUpdate.add(constantes.STRING_100); //SIR_solucionAplicar__c
        datosUpdate.add(constantes.STRING_TEST); //SIR_solucionDeudaAplicar__c
        datosUpdate.add(constantes.STRING_TEST); //SIR_textSolucionAplicar__c
        SIR_LCMP_GetCapacidadYsolucion.guardarFormulario(formulario.id, datosUpdate);
   		Test.stopTest();

        System.assertNotEquals(null, SIR_LCMP_GetCapacidadYsolucion.guardarFormulario(formulario.id, datosUpdate), constantes.STRING_TEST);

   }
}