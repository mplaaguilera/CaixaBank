/*****************************************************************
 Name:  SIR_cls_WS_altaAccionWorkflowTest
 Copyright © 2021  CaixaBank

Proposito:   Clase Test de la clase controladora SIR_cls_WS_altaAccionWorkflow                                                                                                          

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US448852         Atmira         03/10/2022     	  Created    

*****************************************************************/
@isTest
public class SIR_cls_WS_altaAccionWorkflowTest {

    @testSetup static void setupMethod(){
        SIR_TestDataFactory.CrearIntegrationSetting('altaAccion');
    }
 
    /*****************************************************************
        Proposito:  sendActionOK sirve para comprobar la logica de la clase SIR_cls_WS_altaAccionWorkflowTest que obtiene una respuesta correcta                                             
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
    	1.0            US448852         Atmira         03/10/2022     	  Created   
        
	*****************************************************************/    
    @istest static void sendActionOK(){
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank','U012222');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        System.runAs(usuario) {
           	
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.CrearAccion(proceso);
            SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);
            accion.SIREC__SIREC_fld_tipo__c = SIR_Constantes.ACCION_TIPO_VOLUNTAD_CLIENTE;        
            accion.SIREC__SIREC_fld_accion__c = SIR_Constantes.ACCION_TIPO_LLAMADA_EMITIDA;
            accion.SIREC__SIREC_fld_resultado__c = SIR_Constantes.ACCION_RESULTADO_NO_LOCALIZADO;
            accion.SIREC__SIREC_fld_persona__c = cuenta.Id;
            accion.SIREC__SIREC_fld_interviniente__c = cuenta.Id;
            accion.RecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByName().get(SIR_Constantes.ACCION_RECORDTYPE_NAME_PRESOL).getRecordTypeId();            

            update accion;
            listAccion.add(accion);
            // alta catalogo accion
            SIR_CatalogoSirec__c catalogoA = new SIR_CatalogoSirec__c(
				Name = SIR_Constantes.CATALOGO_API_MAPEO_ACCIONES_PRESOL,
            	SIR_Descripcion__c = SIR_Constantes.ACCION_TIPO_LLAMADA_EMITIDA, 
                SIR_Codigo__c = accion.SIREC__SIREC_fld_tipo__c+'|A|'+accion.SIREC__SIREC_fld_accion__c,
                SIR_MasterRecordId__c = SIR_Constantes.CATALOGO_API_MAPEO_ACCIONES_PRESOL+'|'+accion.SIREC__SIREC_fld_tipo__c+'|A|'+accion.SIREC__SIREC_fld_accion__c
            
			);
            insert catalogoA;
            // alta catalogo respuesta
            SIR_CatalogoSirec__c catalogoR = new SIR_CatalogoSirec__c(
                Name = SIR_Constantes.CATALOGO_API_MAPEO_ACCIONES_PRESOL,
                SIR_Descripcion__c = SIR_Constantes.ACCION_TIPO_LLAMADA_EMITIDA, 
                SIR_Codigo__c = accion.SIREC__SIREC_fld_tipo__c+'|R|'+accion.SIREC__SIREC_fld_resultado__c,
                SIR_MasterRecordId__c = SIR_Constantes.CATALOGO_API_MAPEO_ACCIONES_PRESOL+'|'+accion.SIREC__SIREC_fld_tipo__c+'|R|'+accion.SIREC__SIREC_fld_resultado__c
            );
            insert catalogoR;
            List<Object> lstResponse;
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_altaAccionWorkflowMock()); 
            Test.startTest(); 
            lstResponse = SIR_cls_WS_altaAccionWorkflow.sendAction(accion.Id);
            Test.stopTest();
            
            System.assertEquals('OK', lstResponse.get(0),'Respuesta incorrecta en sendActionOK');
        }   
    }

    @istest static void sendActionKO(){
		
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank','U012222');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        System.runAs(usuario) {
           	
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.CrearAccion(proceso);
            SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);
            accion.SIREC__SIREC_fld_tipo__c = SIR_Constantes.ACCION_TIPO_VOLUNTAD_CLIENTE;        
            accion.SIREC__SIREC_fld_accion__c = SIR_Constantes.ACCION_TIPO_LLAMADA_EMITIDA;
            accion.SIREC__SIREC_fld_resultado__c = SIR_Constantes.ACCION_RESULTADO_RECOBRO;
            accion.SIREC__SIREC_fld_persona__c = cuenta.Id;
            accion.SIREC__SIREC_fld_interviniente__c = cuenta.Id;
            update accion;
            listAccion.add(accion);
            List<Object> lstResponse;
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_altaAccionWorkflowMock()); 
            Test.startTest(); 
            lstResponse = SIR_cls_WS_altaAccionWorkflow.sendAction(accion.Id);
            Test.stopTest();
            System.assertEquals('KO', lstResponse.get(0),'No tiene permisos para enviar esta accion');
        }   
    }
    
    @istest static void sendActionException(){
		
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank','U012222');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        System.runAs(usuario) {
            
            SIR_SendNewAction_WS.throwException = true;
        	Boolean hayExcepcion = false;
           	
            try{
                Account cuenta = SIR_TestDataFactory.crearCuenta();
                SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
                SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.CrearAccion(proceso);
                SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);
                accion.SIREC__SIREC_fld_accion__c = '02';
                accion.SIREC__SIREC_fld_resultado__c = SIR_Constantes.ACCION_RESULTADO_RECOBRO;
                accion.SIREC__SIREC_fld_responsable__c = usuario.Id;
                update accion;
                listAccion.add(accion);                
                List<Object> lstResponse;
                Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_altaAccionWorkflowMock()); 
                Test.startTest();    
                lstResponse = SIR_cls_WS_altaAccionWorkflow.sendAction(accion.Id);
                Test.stopTest();
            }catch(Exception ex){
            	hayExcepcion = true;
        	}
            
            System.assertEquals(false, hayExcepcion, constantes.STRING_TEST);
        }    
    }


    @istest static void sendActionException2(){
		
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank','U012222');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        System.runAs(usuario) {
            
            SIR_SendNewAction_WS.throwException = true;
        	Boolean hayExcepcion = false;
           	
            try{
                Account cuenta = SIR_TestDataFactory.crearCuenta();
                SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
                SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.CrearAccion(proceso);
                SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);
                accion.SIREC__SIREC_fld_accion__c = '10';
                accion.SIREC__SIREC_fld_resultado__c = SIR_Constantes.ACCION_RESULTADO_RECOBRO;
                accion.SIREC__SIREC_fld_responsable__c = usuario.Id;
                update accion;
                listAccion.add(accion);
                List<Object> lstResponse;
                Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_altaAccionWorkflowMock()); 
                Test.startTest();    
                lstResponse = SIR_cls_WS_altaAccionWorkflow.sendAction(accion.Id);
                Test.stopTest();
            }catch(Exception ex){
            	hayExcepcion = true;
        	}
            
            System.assertEquals(false, hayExcepcion, constantes.STRING_TEST);
        }    
    }
    
    @istest static void sendActionErroActionId(){
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank','U012222');
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        System.runAs(usuario) {
            List<Object> lstResponse;
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_altaAccionWorkflowMock()); 
            Test.startTest();    
            	lstResponse = SIR_cls_WS_altaAccionWorkflow.sendAction('IdErroneo');
            Test.stopTest();
            Assert.areEqual('KO', lstResponse.get(0), 'sendActionErroActionId No se ha producido el error esperado');
            Assert.areEqual('No se ha encontrado la accion que ha de enviarse con id = IdErroneo', lstResponse.get(1), 'sendActionErroActionId No se ha producido el error esperado');
        }
        
        
    }
}