/*****************************************************************
    Name: SIR_ListaProcesosGestorPRESOL_Test
    Copyright © 2021 CaixaBank
============================================================
    Proposito: Clase Test de la clase controladora externa del LWC SIR_LCMP_ListaProcesosGestorPRESOL                                                                                                         
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         04/04/2022     	 Created    

*****************************************************************/
@isTest
public class SIR_ListaProcesosGestorPRESOL_Test {

    /*****************************************************************                                                    
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         04/04/2022     	  Created    
        
	*****************************************************************/    
    @isTest 
    public static void getProcesosTest() {
        SIR_Constantes constantes = new SIR_Constantes();
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){
            Test.startTest();
            List<SIREC__SIREC_obj_proceso__c> procesos = SIR_LCMP_ListaProcesosGestorPRESOL.getProcesos();
            Test.stopTest();
            System.assertNotEquals(null, procesos, constantes.STRING_TEST); 
        }
    }
   
    /*****************************************************************                                                    
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         04/04/2022     	  Created    
        
	*****************************************************************/    
    @isTest 
    public static void getURLTest() {
        SIR_Constantes constantes = new SIR_Constantes();
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        String url;
        System.runAs(usuario){
            Test.startTest();
            url = SIR_LCMP_ListaProcesosGestorPRESOL.getURL();
            Test.stopTest();
            System.assertNotEquals(null,  url, constantes.STRING_TEST);   
        }
    }
}