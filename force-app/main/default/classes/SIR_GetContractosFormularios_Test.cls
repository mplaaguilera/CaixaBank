/*****************************************************************
 Name:  SIR_GetContractosFormularios_Test
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase Test de la clase controladora externa del LWC SIR_LCMP_GetContractosFormulario (sir_lwc_GetContractosFormulario)                                                                                                                  
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US US244051      Atmira         05/07/2021     	  Created    


*****************************************************************/
@isTest
public class SIR_GetContractosFormularios_Test {
 /*****************************************************************
        Proposito:  test1 sirve para comprobar toda la logica del controlador SIR_LCMP_GetContractosFormulario                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US US244051      Atmira         05/07/2021     	  Created    
        
	*****************************************************************/
    @isTest static void test1() {
		
        SIR_Constantes constante = new SIR_Constantes();

        Test.startTest();
        
        // Creación Account 
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        // Se crea un contrato
       	Contract contrato = SIR_TestDataFactory.crearContrato(cuenta);
        contrato.SIREC__SIREC_fld_indicadorDeuda__c = constante.STRING_MAYUS_S;
        update(contrato);
        //Creamos en proceso
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
        // Creamos proceso contrato 
        SIREC__SIREC_obj_procesoContrato__c procesoContrato = SIR_TestDataFactory.crearProcesoContrato(proceso,contrato);
        //Creamos formulario
        SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
        // Ejecutamos el metodo para cubrir el codigo
        List<Contract> listContrat = new List<Contract>();
        listContrat = SIR_LCMP_GetContratosFormulario.getcontratosDeuda(formulario.Id); 
        contrato.SIREC__SIREC_fld_indicadorDeuda__c = constante.STRING_MAYUS_N;
        update(contrato);
        
        List<Contract> listContrat1 = new List<Contract>();
        listContrat1 = SIR_LCMP_GetContratosFormulario.getcontratosSinDeuda(formulario.Id);
         
   		Test.stopTest();
        system.assertNotEquals(null, listContrat1, constante.STRING_TEST);
        system.assertNotEquals(null, listContrat , constante.STRING_TEST);

   }
}