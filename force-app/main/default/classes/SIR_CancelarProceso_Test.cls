/*****************************************************************
 Name:  SIR_CancelarProceso_Test
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase Test de la clase SIR_CancelarProceso_WS                                                                                                          
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US US244035      Atmira         21/06/2021     	 Created    


*****************************************************************/
@isTest
public class SIR_CancelarProceso_Test {

    @testSetup static void setupMethod(){
        SIR_TestDataFactory.CrearIntegrationSetting('cancelarProcRefinanciacion');
    }


  /*****************************************************************
    Proposito:  test1 sirve para comprobar toda la logica del controlador SIR_CancelarProceso_WS                                                      
    Parameters: No
    Returns: No
    Throws [Exceptions]: No                                                          
    
    Historial
    -------- 
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US US244035      Atmira         21/06/2021     	   Created    

	*****************************************************************/
    @isTest static void correcto() {
        SIR_Constantes constantes = new SIR_Constantes();
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

   
   @isTest static void incorrecto() {
        SIR_Constantes constantes = new SIR_Constantes();
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

    @isTest static void falloConexion() {
        SIR_Constantes constantes = new SIR_Constantes();
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