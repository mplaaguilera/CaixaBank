/*****************************************************************
    Name: SIR_CancelarProcesoRefi_Test
    Copyright © 2021 CaixaBank
============================================================
    Proposito: Clase Test de la clase controladora externa del LWC SIR_LCMP_CancelarProcesoRefi                                                                                                          
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249673         Atmira         10/08/2021     	  Created    

*****************************************************************/
@isTest
public class SIR_CancelarProcesoRefi_Test {
    
    /*****************************************************************
        Proposito: cancelarProcesoRefi1 sirve para comprobar la logica de la clase SIR_LCMP_CancelarProcesoRefi                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
    	1.0            US249673         Atmira         10/08/2021     	  Created   
        
	*****************************************************************/    
    @isTest
    public static void cancelarProcesoRefi1() {
        SIR_Constantes constantes = new SIR_Constantes();
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){
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
    }

    /*****************************************************************
        Proposito: cancelarProcesoRefi2 sirve para comprobar la logica de la clase SIR_LCMP_CancelarProcesoRefi                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
    	1.0            US249673         Atmira         10/08/2021     	  Created   
        
	*****************************************************************/    
    @isTest 
    public static void cancelarProcesoRefi2() {
        SIR_Constantes constantes = new SIR_Constantes();
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){
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
    }

    /*****************************************************************
        Proposito: cancelarProcesoRefi3 sirve para comprobar la logica de la clase SIR_LCMP_CancelarProcesoRefi                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
    	1.0            US249673         Atmira         10/08/2021     	  Created   
        
	*****************************************************************/    
    @isTest 
    public static void cancelarProcesoRefi3() {
        SIR_Constantes constantes = new SIR_Constantes();
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario) {
            SIR_LCMP_CancelarProcesoRefi.throwException = true;
            Boolean hayExcepcion = false;
            try {
                Account cuenta = SIR_TestDataFactory.crearCuenta();
                SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
                proceso.SIREC__SIREC_fld_masterRecordId__c = 'TEST';
                update proceso;
                SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso); 
                Test.startTest();    
                SIR_LCMP_CancelarProcesoRefi.cancelarProceso(proceso.Id);
                SIR_LCMP_CancelarProcesoRefi.updateRegistros(proceso.Id);
                Test.stopTest();
            } catch(Exception ex) {
                hayExcepcion = true;
            }
            System.assertEquals(false, hayExcepcion, constantes.STRING_TEST);
        }
    }
}