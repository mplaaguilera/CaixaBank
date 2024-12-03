/*****************************************************************
 Name:  SIR_CancelarProcesoRefi_Test
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase Test de la clase controladora externa del LWC SIR_LCMP_CancelarProcesoRefi                                                                                                          
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249673         Atmira         10/08/2021     	  Created    

*****************************************************************/
@isTest
public class SIR_CancelarProcesoRefi_Test {
    
    /*****************************************************************
        Proposito:  test1 sirve para comprobar la logica de la clase SIR_LCMP_CancelarProcesoRefi                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
    	1.0            US249673         Atmira         10/08/2021     	  Created   
        
	*****************************************************************/    
    @istest static void test1(){
        SIR_Constantes constantes = new SIR_Constantes();
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
        SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso); 
        Test.startTest();
        SIR_LCMP_CancelarProcesoRefi.comprobarPropietario(proceso.Id);
        SIR_LCMP_CancelarProcesoRefi.cancelarProceso(proceso.Id);
        SIR_LCMP_CancelarProcesoRefi.updateRegistros(proceso.Id);
        Test.stopTest();
        System.assertNotEquals(null, SIR_LCMP_CancelarProcesoRefi.cancelarProceso(proceso.Id), constantes.STRING_TEST);
        System.assertNotEquals(null,SIR_LCMP_CancelarProcesoRefi.updateRegistros(proceso.Id), constantes.STRING_TEST);
    }
     /*****************************************************************
        Proposito:  test1 sirve para comprobar la logica de la clase SIR_LCMP_CancelarProcesoRefi                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
    	1.0            US249673         Atmira         10/08/2021     	  Created   
        
	*****************************************************************/    
    @istest static void test2(){
        SIR_Constantes constantes = new SIR_Constantes();
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
        proceso.SIREC__SIREC_fld_masterRecordId__c = 'TEST';
        update proceso;
        SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso); 
        Test.startTest();
        SIR_LCMP_CancelarProcesoRefi.cancelarProceso(proceso.Id);
        SIR_LCMP_CancelarProcesoRefi.updateRegistros(proceso.Id);
        Test.stopTest();
        System.assertNotEquals(null, SIR_LCMP_CancelarProcesoRefi.cancelarProceso(proceso.Id), constantes.STRING_TEST);
        System.assertNotEquals(null,SIR_LCMP_CancelarProcesoRefi.updateRegistros(proceso.Id), constantes.STRING_TEST);
    }
     /*****************************************************************
        Proposito:  test1 sirve para comprobar la logica de la clase SIR_LCMP_CancelarProcesoRefi                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
    	1.0            US249673         Atmira         10/08/2021     	  Created   
        
	*****************************************************************/    
    @istest static void test3(){
 
        SIR_LCMP_CancelarProcesoRefi.throwException = true;
        Boolean hayExcepcion = false;
        SIR_Constantes constantes = new SIR_Constantes();

        try{
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            proceso.SIREC__SIREC_fld_masterRecordId__c = 'TEST';
            update proceso;
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso); 
            Test.startTest();    
            SIR_LCMP_CancelarProcesoRefi.cancelarProceso(proceso.Id);
            SIR_LCMP_CancelarProcesoRefi.updateRegistros(proceso.Id);
            Test.stopTest();
        }catch(Exception ex){
            hayExcepcion = true;
        }
        
        //Comprobamos el resultado esperado
        System.assertEquals(false, hayExcepcion, constantes.STRING_TEST);
    }

}