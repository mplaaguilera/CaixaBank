/*****************************************************************
 Name:  SIR_ListaProcesosCliente_Test
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase Test de la clase controladora externa del LWC SIR_LCMP_ListaProcesosCliente                                                                                                          
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249685         Atmira         29/07/2021     	 Created    

*****************************************************************/
@isTest
public class SIR_ListaProcesosCliente_Test {

    
    /*****************************************************************
        Proposito:  test1 sirve para comprobar la logica de la clase SIR_LCMP_ListaProcesosCliente                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249685         Atmira         29/07/2021     	  Created    
        
	*****************************************************************/    
    @istest static void test1(){
        SIR_Constantes constantes = new SIR_Constantes();
        Test.startTest();
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        SIR_LCMP_ListaProcesosCliente.getProcesos(cuenta.Id);
        SIR_LCMP_ListaProcesosCliente.getURL(cuenta.Id);
        Test.stopTest();
        System.assertNotEquals(null,  SIR_LCMP_ListaProcesosCliente.getProcesos(cuenta.Id), constantes.STRING_TEST);        
        System.assertNotEquals(null,  SIR_LCMP_ListaProcesosCliente.getURL(cuenta.Id), constantes.STRING_TEST);            
    }
   

}