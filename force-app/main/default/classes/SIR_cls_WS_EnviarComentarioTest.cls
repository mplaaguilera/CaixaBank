/*****************************************************************
    Name: SIR_cls_WS_EnviarComentarioTest
    Copyright © 2021 CaixaBank

    Proposito: Clase Test de la clase controladora SIR_cls_WS_EnviarComentario                                                                                                          

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US271096         Atmira         15/09/2021     	  Created    

*****************************************************************/
@isTest
public with sharing class SIR_cls_WS_EnviarComentarioTest {

    @testSetup static void setupMethod() {
        SIR_TestDataFactory.CrearIntegrationSetting('altaComentarioGestor');
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
    public static void sirClsWsEnviarComentarioCorrectoTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero', rol, 'AV_Usuario_CaixaBank');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        Integer pre;
   		System.runAs(usuario){
            Account cliente = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_informacionCliente__c informacionCliente = SIR_TestDataFactory.CrearInfoCliente(cliente);
            informacionCliente.SIREC__SIREC_fld_codigoEmpleado__c = 'CódigoEmpleado';
            informacionCliente.SIREC__SIREC_fld_fechaModificacion__c = Datetime.now();
            informacionCliente.SIREC__SIREC_fld_masterRecordId__c = 'masterRecordId';
            informacionCliente.SIREC__SIREC_fld_comentariosRecuperaciones__c = 'Comentario correcto';
            List<SIREC__SIREC_obj_informacionCliente__c> lstInformacionCliente = new List<SIREC__SIREC_obj_informacionCliente__c>();
            lstInformacionCliente.add(informacionCliente);
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_EnviarComentarioMock());  
            pre = [SELECT Id FROM CBK_Log__c].size();
            test.startTest();
            update informacionCliente;
            test.stopTest();
        }
        System.assertEquals(0, [Select Id, Apex_Class__c from CBK_Log__c where Apex_Class__c = 'SIR_cls_WS_EnviarComentario'].size(), 'SIR_cls_WS_EnviarComentarioTest.sirClsWsEnviarComentarioCorrectoTest: Se ha producido un error no esperado');
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
    public static void sirClsWsEnviarComentarioIncorrectoTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero', rol, 'AV_Usuario_CaixaBank');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        Integer pre;
   		System.runAs(usuario){
            Account cliente = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_informacionCliente__c informacionCliente = SIR_TestDataFactory.CrearInfoCliente(cliente);
            informacionCliente.SIREC__SIREC_fld_codigoEmpleado__c = 'CódigoEmpleado';
            informacionCliente.SIREC__SIREC_fld_fechaModificacion__c = Datetime.now();
            informacionCliente.SIREC__SIREC_fld_masterRecordId__c = 'masterRecordId';
            informacionCliente.SIREC__SIREC_fld_comentariosRecuperaciones__c = 'Comentario Incorrecto';
            List<SIREC__SIREC_obj_informacionCliente__c> lstInformacionCliente = new List<SIREC__SIREC_obj_informacionCliente__c>();
            lstInformacionCliente.add(informacionCliente);
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_EnviarComentarioMock());  
            pre = [SELECT Id FROM CBK_Log__c].size();
            test.startTest();
            update informacionCliente;
            test.stopTest();
        }
        List<CBK_Log__c> lstLogs = [Select Id, Apex_Class__c, Log_Message__c from CBK_Log__c where Apex_Class__c = 'SIR_cls_WS_EnviarComentario'];
        System.assertEquals(1, lstLogs.size(), 'SIR_cls_WS_EnviarComentarioTest.sirClsWsEnviarComentarioIncorrectoTest: Se ha producido un error no esperado');
        System.assert(lstLogs[0].Log_Message__c.Contains('errorCodigoSoft'), 'SIR_cls_WS_EnviarComentarioTest.sirClsWsEnviarComentarioIncorrectoTest: El error no es errorCodigoSoft');
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
    public static void sirClsWsEnviarFalloConexionTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero', rol, 'AV_Usuario_CaixaBank');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        Integer pre;
   		System.runAs(usuario){
            Account cliente = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_informacionCliente__c informacionCliente = SIR_TestDataFactory.CrearInfoCliente(cliente);           
            informacionCliente.SIREC__SIREC_fld_codigoEmpleado__c = 'CódigoEmpleado';
            informacionCliente.SIREC__SIREC_fld_fechaModificacion__c = Datetime.now();
            informacionCliente.SIREC__SIREC_fld_masterRecordId__c = 'masterRecordId';
            informacionCliente.SIREC__SIREC_fld_comentariosRecuperaciones__c = 'Fallo de conexión';
            List<SIREC__SIREC_obj_informacionCliente__c> lstInformacionCliente = new List<SIREC__SIREC_obj_informacionCliente__c>();
            lstInformacionCliente.add(informacionCliente);
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_EnviarComentarioMock()); 
            pre = [SELECT Id FROM CBK_Log__c].size(); 
            test.startTest();
            update informacionCliente;
            test.stopTest();
        }
        List<CBK_Log__c> lstLogs = [Select Id, Apex_Class__c, Log_Message__c from CBK_Log__c where Apex_Class__c = 'SIR_cls_WS_EnviarComentario'];
        System.assertEquals(1, lstLogs.size(), 'SIR_cls_WS_EnviarComentarioTest.sirClsWsEnviarFalloConexionTest: No se ha producido el error esperado');
        System.assert(lstLogs[0].Log_Message__c.Contains('404'), 'SIR_cls_WS_EnviarComentarioTest.sirClsWsEnviarComentarioIncorrectoTest: El error no es 404');
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
    public static void sendComentarioMockTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest', rol, 'System Administrator', 'U0111111', '001-09999');
        System.runAs(usuario){
            Account cliente = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_informacionCliente__c informacionCliente = SIR_TestDataFactory.CrearInfoCliente(cliente);
            //List<Id> lstInformacionCliente = new List<Id>(informacionCliente.Id);
            informacionCliente.SIREC__SIREC_fld_fechaModificacion__c = Date.today();
            informacionCliente.SIREC__SIREC_fld_comentariosRecuperaciones__c = 'Comentario';
            update informacionCliente;
            SIR_cls_WS_EnviarComentario.ComentarioGestorRequest vBody =  new SIR_cls_WS_EnviarComentario.ComentarioGestorRequest(informacionCliente);
            Test.startTest();
            String response = SIR_cls_WS_EnviarComentario.sendComentarioMock(JSON.serialize(vBody));
            Test.stopTest();
            SIR_cls_WS_EnviarComentario.ComentarioGestorResponse resp = (SIR_cls_WS_EnviarComentario.ComentarioGestorResponse)JSon.deserialize(response, SIR_cls_WS_EnviarComentario.ComentarioGestorResponse.class);
            System.assertEquals('errorcodigoOracle', resp.errorResponseDto.codigoOracle,  'No se obtiene el mock correctamente');
            System.assertEquals('errorCodigoSoft', resp.errorResponseDto.codigoSoft, 'No se obtiene el mock correctamente');
            System.assertEquals('errordescripcionError', resp.errorResponseDto.descripcionError, 'No se obtiene el mock correctamente');
        }
    }
}