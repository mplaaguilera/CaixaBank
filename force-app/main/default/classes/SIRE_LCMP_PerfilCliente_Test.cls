/*****************************************************************
 Name: SIRE_LCMP_PerfilCliente_Test
 Copyright © 2023  CaixaBank
============================================================
Proposito: Clase Test de la clase wrapper SIRE_LCMP_PerfilCliente                                                                                                               
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            		 	        Atmira         03/05/2023     	  Created   

*****************************************************************/
@isTest
public class SIRE_LCMP_PerfilCliente_Test {

    @testSetup 
    static void makeUserData(){
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTestSireLcmp',rol,'System Administrator','U0111111','09999');
    }

    /*****************************************************************
        Proposito:  sirePerfilClienteTest sirve para comprobar la logica de la clase SIRE_LCMP_PerfilCliente                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
    	1.0            			        Atmira         19/10/2023   	  Updated   
        
	*****************************************************************/   
    @istest
    static void sirePerfilClienteTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'usuarioTestSireLcmp@usertestsirec.com' LIMIT 1];
        SIR_Constantes constante = new SIR_Constantes();
        System.runAs(usuario){
            Test.startTest();      
                Account cuenta = SIR_TestDataFactory.crearCuenta();
                SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.crearInfoCliente(cuenta);
                SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
                SIRE_LCMP_PerfilCliente.wrapperCabecera(cuenta.Id); 
                SIRE_LCMP_PerfilCliente.wrapperCabecera(proceso.Id); 
            Test.stopTest();
            System.assertNotEquals(null, SIRE_LCMP_PerfilCliente.wrapperCabecera(cuenta.Id), constante.STRING_TEST);
            System.assertNotEquals(null, SIRE_LCMP_PerfilCliente.wrapperCabecera(proceso.Id), constante.STRING_TEST);
        }
    }
}