/*****************************************************************
    Name: SIRE_LCMP_ConsultaFormDinamicoOPC_Test
    Copyright © 2024 CaixaBank

    Proposito: Clase de test de SIRE_LCMP_ConsultaFormDinamicoOPC                                                                                                 
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         23/01/2024     	  Created    

*****************************************************************/
@isTest
public with sharing class SIRE_LCMP_ConsultaFormDinamicoOPC_Test {

    /*****************************************************************
        Proposito: metodo para realizar el test de la clase SIRE_LCMP_ConsultaFormDinamicoOPC                                                  
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         23/01/2024    	  Created    
        
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
            SIREC__SIREC_obj_tarea__c getTareaOPC = SIRE_LCMP_ConsultaFormDinamicoOPC.getTarea(tarea.Id);            
          	Test.stopTest();
            Assert.areEqual(tarea.Id, getTareaOPC.Id, 'Ha ocurrido algún error inesperado.');
        }
    }
}