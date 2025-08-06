/*****************************************************************
    Name: SIR_GetOtrosProcesos_Test
    Copyright © 2021 CaixaBank
============================================================
    Proposito: Clase Test de la clase controladora externa del LWC SIR_LCMP_GetOtrosProcesos                                                                                                          
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US244045         Atmira         04/08/2021     	  Created    

*****************************************************************/
@isTest
public class SIR_GetOtrosProcesos_Test {
 
    /*****************************************************************
        Proposito: getOtrosProcesosTest sirve para comprobar la logica de la clase SIR_LCMP_EnviarFormulario                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
    	1.0            US244045         Atmira         04/08/2021     	  Created   
        
	*****************************************************************/    
    @isTest
    public static void getOtrosProcesosTest() {
        SIR_Constantes constantes = new SIR_Constantes();
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario) {
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta); 
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            Test.startTest();    
            SIR_LCMP_GetOtrosProcesos.getProcesos(cuenta.Id);
            Test.stopTest();
            System.assertNotEquals(null,SIR_LCMP_GetOtrosProcesos.getProcesos(cuenta.Id), constantes.STRING_TEST);
        }
    }
}