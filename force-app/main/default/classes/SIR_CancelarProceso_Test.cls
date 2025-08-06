/*****************************************************************
    Name: SIR_CancelarProceso_Test
    Copyright © 2021 CaixaBank
============================================================
    Proposito: Clase Test de la clase SIR_CancelarProceso_WS                                                                                                          
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US US244035      Atmira         21/06/2021     	 Created    

*****************************************************************/
@isTest
public class SIR_CancelarProceso_Test {

    @testSetup 
    static void setupMethod() {
        SIR_TestDataFactory.CrearIntegrationSetting('cancelarProcRefinanciacion');
    }

    /*****************************************************************
        Proposito:  cancelarProcesoTest sirve para comprobar toda la logica del controlador SIR_CancelarProceso_WS                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US US244035      Atmira         21/06/2021     	   Created    

	*****************************************************************/
    @isTest 
    public static void cancelarProcesoTest() {
        SIR_Constantes constantes = new SIR_Constantes();
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.CrearAccion(proceso);
            SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);
            proceso.SIREC__SIREC_fld_masterRecordId__c ='Idcorrecto';
            update proceso;
            Test.setMock(HttpCalloutMock.class, new SIR_CancelarProceso_WSMock());  
            Test.startTest();    
            List<String> lstresponse =SIR_CancelarProceso_WS.cancelarProceso(proceso.Id);
            Test.stopTest();
            system.assertEquals(lstresponse.get(0), 'OK', constantes.STRING_TEST);
        }
    }

    /*****************************************************************                                                  
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira       
        
	*****************************************************************/  
    @isTest 
    public static void cancelarProcesoKOTest() {
        SIR_Constantes constantes = new SIR_Constantes();
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.CrearAccion(proceso);
            SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);
            proceso.SIREC__SIREC_fld_masterRecordId__c ='IdIncorrecto';
            update proceso;
            Test.setMock(HttpCalloutMock.class, new SIR_CancelarProceso_WSMock()); 
            Test.startTest();    
            List<String> lstresponse =SIR_CancelarProceso_WS.cancelarProceso(proceso.Id);
            Test.stopTest();
            system.assertEquals(lstresponse.get(0), 'KO', constantes.STRING_TEST);
        }
    }

    /*****************************************************************                                                  
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira       
        
	*****************************************************************/  
    @isTest 
    public static void cancelarProcesoNoConnTest() {
        SIR_Constantes constantes = new SIR_Constantes();
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.CrearAccion(proceso);
            SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);
            proceso.SIREC__SIREC_fld_masterRecordId__c ='Fallo de conexión';
            update proceso;
            Test.setMock(HttpCalloutMock.class, new SIR_CancelarProceso_WSMock()); 
            Test.startTest();    
            List<String> lstresponse =SIR_CancelarProceso_WS.cancelarProceso(proceso.Id);
            Test.stopTest();
            system.assertEquals(lstresponse.get(0), 'KO', constantes.STRING_TEST);
        }
    }
}