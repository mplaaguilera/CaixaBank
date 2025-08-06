/*****************************************************************
    Name: SIR_cls_WS_procOtrasUdsGestTest
    Copyright © 2021 CaixaBank

    Proposito: Clase Test de la clase controladora SIR_cls_WS_procOtrasUdsGest                                                                                                          

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US271097         Atmira         15/09/2021     	  Created    

*****************************************************************/

@isTest
public with sharing class SIR_cls_WS_procOtrasUdsGestTest {

    @testSetup 
    static void setupMethod() {
        SIR_TestDataFactory.CrearIntegrationSetting('consProcOtrasUdsGest');
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
    public static void sirClsWsprocOtrasUdsGestCorrectoTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
   		System.runAs(usuario){
            Account cliente = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_informacionCliente__c informacionCliente = SIR_TestDataFactory.CrearInfoCliente(cliente);
            informacionCliente.SIREC__SIREC_fld_masterRecordId__c = 'IdCorrecto';
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_procOtrasUdsGestMock());  
            test.startTest();
            List<String> lstProcesos = SIR_cls_WS_procOtrasUdsGest.getProcOtrasUdsGest(informacionCliente);
            test.stopTest();
            System.assertEquals('OK', lstProcesos.get(0), 'Test');
            System.assertEquals('Daniel Gonzalez', ((SIR_cls_WS_procOtrasUdsGest.datosResponseDto)JSON.deserialize(lstProcesos.get(1), SIR_cls_WS_procOtrasUdsGest.datosResponseDto.class)).listaProcesoOtrasUnidGestDto.get(0).empleado, 'Test');
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
    public static void sirClsWsProcOtrasUdsGestIncorrectoTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
   		System.runAs(usuario){
            Account cliente = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_informacionCliente__c informacionCliente = SIR_TestDataFactory.CrearInfoCliente(cliente);
            informacionCliente.SIREC__SIREC_fld_masterRecordId__c = 'IdINCorrecto';
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_procOtrasUdsGestMock());  
            test.startTest();
            List<String> lstProcesos = SIR_cls_WS_procOtrasUdsGest.getProcOtrasUdsGest(informacionCliente);
            test.stopTest();
            System.assertEquals('KO', lstProcesos.get(0), 'Test');
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
    public static void sirClsWsProcOtrasUdsGestFalloConexionTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
   		System.runAs(usuario){
            Account cliente = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_informacionCliente__c informacionCliente = SIR_TestDataFactory.CrearInfoCliente(cliente);
            informacionCliente.SIREC__SIREC_fld_masterRecordId__c = '';
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_procOtrasUdsGestMock());  
            test.startTest();
            List<String> lstProcesos = SIR_cls_WS_procOtrasUdsGest.getProcOtrasUdsGest(informacionCliente);
            test.stopTest();
            System.assertEquals('KO', lstProcesos.get(0), 'Test');
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
    public static void procOtrasUdsGestRequestMockTEst() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){
            Account cliente = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_informacionCliente__c informacionCliente = SIR_TestDataFactory.CrearInfoCliente(cliente);
            SIR_cls_WS_procOtrasUdsGest.ProcOtrasUdsGestRequest vBody =  new SIR_cls_WS_procOtrasUdsGest.ProcOtrasUdsGestRequest(informacionCliente);
            test.startTest();
            String otrosProcesosJson = SIR_cls_WS_procOtrasUdsGest.procOtrasUdsGestRequestMock(JSON.serialize(vBody));
            test.stopTest();
            SIR_cls_WS_procOtrasUdsGest.ProcOtrasUdsGestResponse resp = (SIR_cls_WS_procOtrasUdsGest.ProcOtrasUdsGestResponse)JSon.deserialize(otrosProcesosJson, SIR_cls_WS_procOtrasUdsGest.ProcOtrasUdsGestResponse.class);
            System.assertEquals('1', resp.codigoSalida, 'Mensaje incorrecto');
        }
    }
}