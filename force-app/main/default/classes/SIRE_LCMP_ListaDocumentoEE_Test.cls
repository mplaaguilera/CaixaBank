/*****************************************************************
    Name: SIRE_LCMP_ListaDocumentoEE_Test
    Copyright © 2023 CaixaBank

    Proposito: Clase de test de SIRE_LCMP_ListaDocumentoEE                                                                                                 
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         07/11/2023     	  Created    

*****************************************************************/
@isTest
public with sharing class SIRE_LCMP_ListaDocumentoEE_Test {

    /*****************************************************************
        Proposito: getQueryProcesoTest sirve para recuperar el número del cliente asociado al proceso.                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         07/11/2023    	  Created    
        
	*****************************************************************/
    @isTest
    public static void getQueryProcesoTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser', rol, 'System Administrator', 'U011111');
        System.runAs(usuario) {
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345644');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            Test.startTest();
            List<SIREC__SIREC_obj_proceso__c> listProceso = SIRE_LCMP_ListaDocumentoEE.getQueryProceso(proceso.Id);
            Test.stopTest();
            Assert.areEqual(proceso.Id, listProceso[0].Id, 'Ha ocurrido algún error inesperado. En getQueryProcesoTest');
        }
    }

    /*****************************************************************
        Proposito: callWsDocumentoEETest sirve para realizar la llamada al WS.                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         07/11/2023    	  Created    
        
	*****************************************************************/
    @isTest
    public static void callWsDocumentoEETest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser', rol, 'System Administrator', 'U011111');
        System.runAs(usuario) {
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345644');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            Test.startTest();
            List<Object> listObj = SIRE_LCMP_ListaDocumentoEE.callWsDocumentoEE('111111');
            Test.stopTest();
            Assert.areEqual('KO', listObj[0], 'Ha ocurrido algún error inesperado. En callWsDocumentoEETest');
        }
    }

    /*****************************************************************
        Proposito: callWsDownloadDocumentoEETest sirve para realizar la llamada al WS para descargar el documento.                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         08/11/2023    	  Created    
        
	*****************************************************************/
    @isTest
    public static void callWsDownloadDocumentoEETest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser', rol, 'System Administrator', 'U011111');
        System.runAs(usuario) {
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345644');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            Test.startTest();
            List<Object> listObj = SIRE_LCMP_ListaDocumentoEE.callWsDownloadDocumentoEE('111111'); // Cambiar la llamada por el WS correcto.
            Test.stopTest();
            Assert.areEqual('KO', listObj[0], 'Ha ocurrido algún error inesperado. En callWsDownloadDocumentoEETest');
        }
    }

    /*****************************************************************
        Proposito: sendDocumentoEETest sirve para realizar la llamada para enviar el documento de EE a SIREC.                                                     
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         08/11/2023    	  Created    
        
	*****************************************************************/
    @isTest
    public static void sendDocumentoEETest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser', rol, 'System Administrator', 'U011111');
        System.runAs(usuario) {
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345644');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
         
            Test.startTest();
            List<Object> resultado = SIRE_LCMP_ListaDocumentoEE.sendDocumentoEE('ID_DOCUMENTO@NOMBRE_DOCUMENTO@TIPO_DOCUMENTO@rrrrr', tarea.Id);
            Test.stopTest();
            
            List<SIREC__SIREC_obj_tarea__c> tareaModif = [ SELECT Id, SIR_IdDocumentoEE__c, SIR_NombreDocumentoEE__c, SIR_TipoDocumentoEE__c
                                                           FROM SIREC__SIREC_obj_tarea__c WHERE Id = :tarea.ID LIMIT 1];           

            Assert.areEqual(tareaModif[0].SIR_IdDocumentoEE__c, 'ID_DOCUMENTO', 'No se ha grabado el ID_DOCUMENTO En sendDocumentoEETest');
            Assert.areEqual(tareaModif[0].SIR_NombreDocumentoEE__c, 'NOMBRE_DOCUMENTO', 'No se ha grabado el NOMBRE_DOCUMENTO En sendDocumentoEETest');
            Assert.areEqual(tareaModif[0].SIR_TipoDocumentoEE__c, 'TIPO_DOCUMENTO', 'No se ha grabado el TIPO_DOCUMENTO En sendDocumentoEETest');
        }
    }
}