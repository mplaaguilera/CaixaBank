/*****************************************************************
 Name:  SIR_GetCargasFinancieras_Test
 Copyright © 2021  CaixaBank

Proposito:   Clase Test de la clase controladora externa del LWC SIR_LCMP_GetCargasFinancieras (sir_lwc_cargasFinancieras)                                                                                                                  

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US US249658      Atmira         26/07/2021     	  Created    

*****************************************************************/
@isTest 
public class SIR_GetCargasFinancieras_Test {
   /*****************************************************************
        Proposito:  test1 sirve para comprobar toda la logica del controlador SIR_LCMP_GetCargasFinancieras                                                      
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
         SIR_LCMP_GetCargasFinancieras.getCargasFormulario(formulario.id);
         SIR_LCMP_GetCargasFinancieras.getCaluladoraLink();
         List<String> datosUpdate = new List<String>();
         for(integer i = 0; i < 36; i++){
               datosUpdate.add(constantes.STRING_100); //SIR_SolucionFinalista__c
         }
         SIR_LCMP_GetCargasFinancieras.guardarFormulario(formulario.id, datosUpdate);
         Test.stopTest();
         System.assertNotEquals(null, SIR_LCMP_GetCargasFinancieras.guardarFormulario(formulario.id, datosUpdate), constantes.STRING_TEST);

   }
}