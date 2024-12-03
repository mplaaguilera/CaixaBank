/*****************************************************************
 Name:  SIR_ListaProcesosClientePRESOL_Test
 Copyright © 2022  CaixaBank
============================================================
Proposito:   Clase Test de la clase controladora externa del LWC SIR_LCMP_ListaProcesosClientePRESOL                                                                                                          
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         01/04/2022     	 Created    

*****************************************************************/
@isTest
public class SIR_ListaProcesosClientePRESOL_Test {

    
    /*****************************************************************
        Proposito:  test1 sirve para comprobar la logica de la clase SIR_LCMP_ListaProcesosClientePRESOL                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         01/04/2022     	 Created    
        
	*****************************************************************/    
    @istest static void test1(){
        SIR_Constantes constantes = new SIR_Constantes();
        Test.startTest();
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        SIR_LCMP_ListaProcesosClientePRESOL.getProcesos(cuenta.Id);
        SIR_LCMP_ListaProcesosClientePRESOL.getURL(cuenta.Id);
        Test.stopTest();
        System.assertNotEquals(null,  SIR_LCMP_ListaProcesosClientePRESOL.getProcesos(cuenta.Id), constantes.STRING_TEST);        
        System.assertNotEquals(null,  SIR_LCMP_ListaProcesosClientePRESOL.getURL(cuenta.Id), constantes.STRING_TEST);            
    }
   

}