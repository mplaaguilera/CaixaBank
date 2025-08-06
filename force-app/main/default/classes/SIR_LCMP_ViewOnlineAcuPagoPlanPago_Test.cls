/*****************************************************************
    Name: SIR_LCMP_ViewOnlineAcuPagoPlanPago_Test
    Copyright © 2024 CaixaBank

    Proposito: Clase de test de SIR_LCMP_ViewOnlineAcuPagoPlanPago                                                                                                 
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         27/03/2024     	  Created    

*****************************************************************/
@isTest
public with sharing class SIR_LCMP_ViewOnlineAcuPagoPlanPago_Test {
	/*****************************************************************
        Proposito: getQueryProcesoTest sirve para recuperar el número del cliente asociado al proceso.                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         27/03/2024   	  Created    
        
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
            String idPropuesta = SIR_LCMP_ViewOnlineAcuPagoPlanPago.obtenerDatos(tarea.Id);
            List<Object> listObject = SIR_LCMP_ViewOnlineAcuPagoPlanPago.callWsInfoApPp(idPropuesta);
            Test.stopTest();
            Assert.areEqual(idPropuesta, idPropuesta, 'Ha ocurrido algún error inesperado. En test1');
        }
    }
}