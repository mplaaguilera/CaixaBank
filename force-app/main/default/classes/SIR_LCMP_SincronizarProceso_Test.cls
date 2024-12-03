/*****************************************************************
    Name: SIR_LCMP_SincronizarProceso_Test
    Copyright © 2024 CaixaBank

    Proposito: Clase de test de SIR_LCMP_SincronizarProceso                                                                                                 
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         29/02/2024     	  Created    

*****************************************************************/
@isTest
public with sharing class SIR_LCMP_SincronizarProceso_Test {

    /*****************************************************************
        Proposito: sincronizar el proceso y la tarea                                                     
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         29/02/2024     	  Created    
        
	*****************************************************************/
    @isTest
    public static void sincronizarTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser', rol, 'System Administrator', 'U011111');
        System.runAs(usuario) {
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345644');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            Test.startTest();
            List<String> listString = SIR_LCMP_SincronizarProceso.sincronizarProceso(proceso.Id);
            Test.stopTest();
            Assert.areEqual('KO', listString[0], 'Ha ocurrido algún error inesperado. En sincronizarTest');
        }
    }

   
}