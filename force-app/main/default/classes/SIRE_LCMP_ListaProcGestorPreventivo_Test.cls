/*****************************************************************
 Name: SIRE_LCMP_ListaProcGestorPreventivo_Test
 Copyright © 2021 CaixaBank
============================================================
Proposito: Clase Test de la clase controladora externa del LWC Sire_lwc_ListaProcesosGestorPreventivo                                                                                                         
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            00000000         Atmira         23/06/2023     	  Created    
*****************************************************************/
@isTest
public class SIRE_LCMP_ListaProcGestorPreventivo_Test {

    /*****************************************************************
        Proposito:  getProcesosTest sirve para comprobar la logica de la clase SIRE_LCMP_ListaProcesosGestorPreventivo                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            00000000         Atmira         23/06/2023     	  Created    
	*****************************************************************/ 
    @istest static void getProcesosTest(){
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTestSirec',rol,'System Administrator','U0111111','01111');
        System.runAs(usuario){
            SIR_Constantes constantes = new SIR_Constantes();
            Test.startTest();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIRE_LCMP_ListaProcesosGestorPreventivo.getProcesos();
            SIRE_LCMP_ListaProcesosGestorPreventivo.getURL();
            Test.stopTest();
            Assert.areNotEqual(null,SIRE_LCMP_ListaProcesosGestorPreventivo.getProcesos(),constantes.STRING_TEST);        
            Assert.areNotEqual(null,SIRE_LCMP_ListaProcesosGestorPreventivo.getURL(),constantes.STRING_TEST);
        }
    }
}