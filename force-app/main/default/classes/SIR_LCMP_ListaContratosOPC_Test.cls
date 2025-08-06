/*****************************************************************
    Name: SIR_LCMP_ListaContratosOPC_Test
    Copyright © 2024 CaixaBank

    Proposito: Clase de test de SIR_LCMP_ListaContratosOPC                                                                                                 
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         11/07/2024     	  Created    

*****************************************************************/
@isTest
public with sharing class SIR_LCMP_ListaContratosOPC_Test {

    /*****************************************************************
        Proposito: metodo para realizar el test de la clase SIR_LCMP_ListaContratosOPC                                                  
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         11/07/2024    	  Created    
        
	*****************************************************************/
    @isTest
    public static void test1() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser', rol, 'System Administrator', 'U011111');
        System.runAs(usuario) {
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345644');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            Test.startTest();
            SIREC__SIREC_obj_proceso__c getProceso = SIR_LCMP_ListaContratosOPC.getTarea(proceso.Id);            
          	List<String> updateTarea = SIR_LCMP_ListaContratosOPC.updateTarea(tarea.Id, 'Esto es una respuesta', 'Esto es una respuesta');
            Test.stopTest();
            Assert.areEqual(proceso.Id, getProceso.Id, 'Ha ocurrido algún error inesperado.');
        }
    }
}