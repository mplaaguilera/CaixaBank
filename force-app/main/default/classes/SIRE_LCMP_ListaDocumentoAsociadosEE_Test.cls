/*****************************************************************
    Name: SIRE_LCMP_ListaDocumentoAsociadosEE_Test
    Copyright © 2023 CaixaBank

    Proposito: Clase de test de SIRE_LCMP_ListaDocumentoAsociadosEE                                                                                                              

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            			        Atmira         09/11/2023     	  Created    

*****************************************************************/
@isTest
public with sharing class SIRE_LCMP_ListaDocumentoAsociadosEE_Test {

    /*****************************************************************
        Proposito: getQueryTareasDocTest sirve para realizar una query para recuperar las Tareas de tipo DAT-EE que están asociadas al Proceso.                                                   
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         09/11/2023    	  Created    
        
	*****************************************************************/
    @isTest
    public static void getQueryTareasDocTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser', rol, 'System Administrator', 'U011111');
        System.runAs(usuario) {
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345644');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            tarea.SIREC__SIREC_fld_codigo_tarea__c = 'DAT-EE';
            update tarea;
            Test.startTest();
            List<SIREC__SIREC_obj_tarea__c> taskList = SIRE_LCMP_ListaDocumentoAsociadosEE.getQueryTareasDoc(proceso.Id);
            List<SIREC__SIREC_obj_tarea__c> taskList2 = SIRE_LCMP_ListaDocumentoAsociadosEE.getQueryTareasDoc(cuenta.Id);
            Test.stopTest();
            Assert.areEqual(tarea.Id, taskList[0].Id);
        }
    }

    /*****************************************************************
        Proposito: callWsDownloadDocumentoEETest sirve para realizar la llamada al WS para poder descargar el documento.                        
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         09/11/2023    	  Created    
        
	*****************************************************************/
    @isTest
    public static void callWsDownloadDocumentoEETestKO() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser', rol, 'System Administrator', 'U011111');
        System.runAs(usuario) {
            Test.startTest();
            List<Object> objectList = SIRE_LCMP_ListaDocumentoAsociadosEE.callWsDownloadDocumentoEE('123456');
            Test.stopTest();
            Assert.areEqual('KO', objectList[0]);
        }
    }
}