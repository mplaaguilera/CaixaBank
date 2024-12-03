/*****************************************************************
 Name: SIR_ListaProcesosGestor_Test
 Copyright © 2021 CaixaBank
============================================================
Proposito: Clase Test de la clase controladora externa del LWC SIR_LCMP_ListaProcesosGestor                                                                                                         
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249684         Atmira         29/07/2021     	 Created    

*****************************************************************/
@isTest
public class SIR_ListaProcesosGestor_Test {

    /*****************************************************************
        Proposito: listaProcesosGestorTest sirve para comprobar la logica de la clase SIR_LCMP_ListaProcesosGestor                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249684         Atmira         29/07/2021     	  Created    
        
	*****************************************************************/    
    @isTest 
    public static void listaProcesosGestorTest(){
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){
            SIR_Constantes constantes = new SIR_Constantes();
            Test.startTest();
            SIR_LCMP_ListaProcesosGestor.getProcesos();
            SIR_LCMP_ListaProcesosGestor.getURL();
            Test.stopTest();
            System.assertNotEquals(null, SIR_LCMP_ListaProcesosGestor.getProcesos(), constantes.STRING_TEST);        
            System.assertNotEquals(null,  SIR_LCMP_ListaProcesosGestor.getURL(), constantes.STRING_TEST);  
        }
    }
}