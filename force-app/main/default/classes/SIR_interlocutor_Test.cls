/*****************************************************************
 Name:  SIR_GetProfileClient_Test
 Copyright © 2022  CaixaBank
============================================================
Proposito:   Clase Test de la clase controladora externa del LWC SIR_LCMP_interlocutor                                                                                                                 
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            			        Atmira         13/06/2022     	  Created  

*****************************************************************/
@isTest
public class SIR_interlocutor_Test {
	 /*****************************************************************
        Proposito:  Comprobar toda la logica del controlador SIR_LCMP_interlocutor                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            					Atmira         13/06/2022     	  Created 
        
	*****************************************************************/
    @isTest static void test1() {       
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        String idInformacionCliente;
        SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.crearInfoCliente(cuenta);
        Test.startTest();
		idInformacionCliente = SIR_LCMP_interlocutor.getInterlocutores(cuenta.Id);
   		Test.stopTest();
        System.assertEquals(idInformacionCliente, infoCliente.id, 'El id no coincide');
   }
}