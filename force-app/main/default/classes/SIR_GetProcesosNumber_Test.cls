/*****************************************************************
    Name: SIR_GetProcesosNumber_Test
    Copyright © 2021 CaixaBank
============================================================
    Proposito: Clase Test de la clase controladora externa del LWC SIR_LCMP_GetProcesosNumber                                                                                                          
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249684         Atmira         07/07/2021     	 Created    

*****************************************************************/
@isTest
public class SIR_GetProcesosNumber_Test {

    /*****************************************************************
        Proposito: getProcesosNumberTest sirve para comprobar la logica de la clase SIR_LCMP_GetProcesosNumber                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249684         Atmira         15/07/2021     	  Created    
        
	*****************************************************************/    
    @isTest
    public static void getProcesosNumberTest() {
        SIR_Constantes constantes = new SIR_Constantes();
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario) {
            Test.startTest();
            SIR_LCMP_GetProcesosNumber.getHomeUrl();
            SIR_LCMP_GetProcesosNumber.getProcesosNumber();
            Test.stopTest();
            System.assertNotEquals(null, SIR_LCMP_GetProcesosNumber.getHomeUrl(), constantes.STRING_TEST);
            System.assertNotEquals(null, SIR_LCMP_GetProcesosNumber.getProcesosNumber(), constantes.STRING_TEST);
        }
    }
}