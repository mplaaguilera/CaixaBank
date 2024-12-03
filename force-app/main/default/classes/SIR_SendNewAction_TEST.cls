/*****************************************************************
 Name:  SIR_SendNewAction_TEST
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase Test de la clase controladora SIR_SendNewAction_WS                                                                                                          
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US244045         Atmira         04/08/2021     	  Created    

*****************************************************************/
@isTest
public class SIR_SendNewAction_TEST {

    @testSetup static void setupMethod(){
        SIR_TestDataFactory.CrearIntegrationSetting('altaResultAcciones');
    }
 
    /*****************************************************************
        Proposito:  sendActionOK sirve para comprobar la logica de la clase SIR_SendNewAction_WS que obtiene una respuesta correcta                                             
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
    	1.0            US244045         Atmira         04/08/2021     	  Created   
        
	*****************************************************************/    
    @istest static void sendActionOK(){
		
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank', 'U012222');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        System.runAs(usuario) {
           	
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.CrearAccion(proceso);
            SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);
            accion.SIREC__SIREC_fld_accion__c = '01';
            accion.SIREC__SIREC_fld_resultado__c = SIR_Constantes.ACCION_RESULTADO_RECOBRO;
            accion.SIREC__SIREC_fld_persona__c = cuenta.Id;
            accion.SIREC__SIREC_fld_interviniente__c = cuenta.Id;
            update accion;
            listAccion.add(accion);
            List<String> lstResponse;
            Test.setMock(HttpCalloutMock.class, new SIR_SendNewAction_WSMock()); 
            Test.startTest(); 
            lstResponse = SIR_SendNewAction_WS.sendAction(accion.Id);
            Test.stopTest();
            System.assertEquals('OK', lstResponse.get(0),'Respuesta incorrecta en sendActionOK');
        }   
    }

    @istest static void sendActionKO(){
		
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank', 'U012222');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        System.runAs(usuario) {
           	
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.CrearAccion(proceso);
            SIREC__SIREC_obj_informacionCliente__c infoCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);
            accion.SIREC__SIREC_fld_accion__c = '01';
            accion.SIREC__SIREC_fld_resultado__c = SIR_Constantes.ACCION_RESULTADO_RECOBRO;
            accion.SIREC__SIREC_fld_persona__c = cuenta.Id;
            accion.SIREC__SIREC_fld_interviniente__c = cuenta.Id;
            update accion;
            listAccion.add(accion);
            List<String> lstResponse;
            Test.setMock(HttpCalloutMock.class, new SIR_SendNewAction_WSMock()); 
            Test.startTest(); 
            lstResponse = SIR_SendNewAction_WS.sendAction(accion.Id);
            Test.stopTest();
            System.assertEquals('KO', lstResponse.get(0),'No tiene permisos para enviar esta accion');
        }   
    }
    
    @istest static void sendActionException(){
		
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank', 'U012222');
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
                List<String> lstResponse;
                Test.setMock(HttpCalloutMock.class, new SIR_SendNewAction_WSMock()); 
                Test.startTest();    
                lstResponse = SIR_SendNewAction_WS.sendAction(accion.Id);
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
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank', 'U012222');
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
                List<String> lstResponse;
                Test.setMock(HttpCalloutMock.class, new SIR_SendNewAction_WSMock()); 
                Test.startTest();    
                lstResponse = SIR_SendNewAction_WS.sendAction(accion.Id);
                Test.stopTest();
            }catch(Exception ex){
            	hayExcepcion = true;
        	}
            
            System.assertEquals(false, hayExcepcion, constantes.STRING_TEST);
        }    
    }
}