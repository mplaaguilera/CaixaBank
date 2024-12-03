/*****************************************************************
    Name: SIR_HomeSolutions_Test
    Copyright © 2021 CaixaBank
============================================================
    Proposito: Clase Test de la clase controladora externa del LWC SIR_LCMP_HomeSolutions                                                                                                         
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         04/04/2022     	 Created    

*****************************************************************/
@isTest
public class SIR_HomeSolutions_Test {

    /*****************************************************************
        Proposito: homeSolutionsTest sirve para comprobar la logica de la clase SIR_LCMP_HomeSolutions para usuario SSCC                                                     
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         04/04/2022     	  Created    
        1.1                             Atmira         20/07/2022     	  Edited 
        
	*****************************************************************/    
    @isTest 
    public static void homeSolutionsTest() {
        SIR_Constantes constantes = new SIR_Constantes();
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest',rol,'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario) {
            Test.startTest();
            SIR_LCMP_HomeSolutions.getData('Impagados 1-90');
            SIR_LCMP_HomeSolutions.getData('PRESOL-Preventivo');
            SIR_LCMP_HomeSolutions.getURL('Impagados 1-90');
            SIR_LCMP_HomeSolutions.getURL('PRESOL-Preventivo');
            Test.stopTest();
            System.assertNotEquals(null, SIR_LCMP_HomeSolutions.getData('Impagados 1-90,PRESOL-Preventivo'), constantes.STRING_TEST);        
            System.assertNotEquals(null,  SIR_LCMP_HomeSolutions.getURL('Impagados 1-90'), constantes.STRING_TEST);    
        }
    }
}