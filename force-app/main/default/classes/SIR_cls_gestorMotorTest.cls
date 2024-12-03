@isTest
public with sharing class SIR_cls_gestorMotorTest {
    @TestSetup
    static void makeData(){
        SIR_TestDataFactory.CrearIntegrationSetting('llamadaMotor');
        SIR_TestDataFactory.CrearIntegrationSetting('altaAccion');
        SIR_TestDataFactory.CrearIntegrationSetting('procesoInfo');
    }
    @isTest
    public static void avanzaMotorOKTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        usuario.EmployeeNumber = 'U012222';      
        update usuario;
        System.runAs(usuario) {
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345644');
        List<SIREC__SIREC_obj_tarea__c> lstTarea = SIR_TestDataFactory.createTarea(1,proceso);
        lstTarea.get(0).SIREC__SIREC_fld_tipo_tarea__c = 'SEL';
        update lstTarea;
        List<String> response = new List<String>();
        Map<String, Object> sirecTarea = SIR_TestDataFactory.createSirecRespone('idActividad','SEL',12345644,SIR_Constantes.PROCESO_SITUACION_NO_LOCALIZADO);
        Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_llamadaMotorMock());
        Test.startTest();
        response = SIR_cls_gestorMotor.avanzaMotor(lstTarea.get(0).Id);
        Test.stopTest();
        System.assertEquals('OK', response.get(0), 'No devuelve el OK que debería');
        System.assertEquals(2, [SELECT Id FROM SIREC__SIREC_obj_tarea__c].size(), 'No se ha creado la tarea nueva');
        }
    }


    @isTest
    public static void avanzaMotorErrorTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        usuario.EmployeeNumber = 'U012222';      
        update usuario;
        System.runAs(usuario) {
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345644');
        List<SIREC__SIREC_obj_tarea__c> lstTarea = SIR_TestDataFactory.createTarea(1,proceso);
        List<String> response = new List<String>();
        Map<String, Object> sirecTarea = SIR_TestDataFactory.createSirecRespone('idActividad','SEL',12345644,SIR_Constantes.PROCESO_SITUACION_NO_LOCALIZADO);
        Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_llamadaMotorMock());
        Test.startTest();
        response = SIR_cls_gestorMotor.avanzaMotor(lstTarea.get(0).Id);
        Test.stopTest();
        System.assertEquals('KO', response.get(0), 'No devuelve el KO que debería');
        System.assertEquals('Se ha producido un error en la sincronización, contacte con el administrador.', response.get(1), 'SIR_cls_gestorMotorTest.avanzaMotorErrorTest El mensaje que muestra no es el correcto');
        }
    }

    @isTest
    public static void avanzaMotorTareaErrorTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        usuario.EmployeeNumber = 'U012222';      
        update usuario;
        System.runAs(usuario) {
        List<String> response = new List<String>();
        Map<String, Object> sirecTarea = SIR_TestDataFactory.createSirecRespone('idActividad','SEL',12345644,SIR_Constantes.PROCESO_SITUACION_NO_LOCALIZADO);
        Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_llamadaMotorMock());
        Test.startTest();
        response = SIR_cls_gestorMotor.avanzaMotor('1234567890');
        Test.stopTest();
        System.assertEquals('KO', response.get(0), 'No devuelve el KO que debería');
        System.assertEquals('No se ha encontrado la tarea que ha de enviarse con id = 1234567890', response.get(1), 'SIR_cls_gestorMotorTest.avanzaMotorTareaErrorTest El mensaje que muestra no es el correcto');
        }
        
    }

    @isTest
    public static void enviarAccionTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        usuario.EmployeeNumber = 'U012222';      
        update usuario;
        System.runAs(usuario) {
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345644');
        List<SIREC__SIREC_obj_tarea__c> lstTarea = SIR_TestDataFactory.createTarea(1,proceso);
        SIREC__SIREC_obj_acciones__c accion =  SIR_TestDataFactory.crearAccion(proceso);
        accion.SIREC__SIREC_fld_tarea__c = lstTarea.get(0).Id;
        accion.SIREC__SIREC_fld_tipo__c = SIR_Constantes.ACCION_TIPO_VOLUNTAD_CLIENTE;        
        accion.SIREC__SIREC_fld_accion__c = SIR_Constantes.ACCION_TIPO_LLAMADA_EMITIDA;
        accion.SIREC__SIREC_fld_resultado__c = SIR_Constantes.ACCION_RESULTADO_NO_LOCALIZADO;
        accion.SIREC__SIREC_fld_persona__c = cuenta.Id;
        accion.SIREC__SIREC_fld_interviniente__c = cuenta.Id;
        accion.RecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByName().get(SIR_Constantes.ACCION_RECORDTYPE_NAME_PRESOL).getRecordTypeId();   
        update accion;
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
        //SIREC__SIREC_obj_tarea__c tarea = [SELECT Id FROM SIREC__SIREC_obj_tarea__c LIMIT 1];
        List<String> response = new List<String>();
        Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_altaAccionWorkflowMock());
        Test.startTest();
        response = SIR_cls_gestorMotor.enviarAccion(accion);
        Test.stopTest();
        System.assertEquals('OK', response.get(0), 'No devuelve el OK que debería');
        }

    }
    
    @isTest
    public static void enviarAccionKOTest() { 
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('primero',rol,'AV_Usuario_CaixaBank');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        usuario.EmployeeNumber = 'U012222';      
        update usuario;
        System.runAs(usuario) {
        Account cuenta = SIR_TestDataFactory.crearCuenta();
        SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345644');
        List<SIREC__SIREC_obj_tarea__c> lstTarea = SIR_TestDataFactory.createTarea(1,proceso);
        SIREC__SIREC_obj_acciones__c accion =  SIR_TestDataFactory.crearAccion(proceso);
        accion.SIREC__SIREC_fld_tarea__c = lstTarea.get(0).Id;
        accion.SIREC__SIREC_fld_tipo__c = SIR_Constantes.ACCION_TIPO_VOLUNTAD_CLIENTE;        
        accion.SIREC__SIREC_fld_accion__c = SIR_Constantes.ACCION_TIPO_LLAMADA_EMITIDA;
        accion.SIREC__SIREC_fld_resultado__c = SIR_Constantes.ACCION_RESULTADO_NO_LOCALIZADO;
        accion.SIREC__SIREC_fld_persona__c = cuenta.Id;
        accion.SIREC__SIREC_fld_interviniente__c = cuenta.Id;
        accion.RecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByName().get(SIR_Constantes.ACCION_RECORDTYPE_NAME_PRESOL).getRecordTypeId();   
        update accion;
        List<String> response = new List<String>();
        Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_altaAccionWorkflowMock());
        Test.startTest();
        response = SIR_cls_gestorMotor.enviarAccion(accion);
        Test.stopTest();
            Assert.areEqual('KO', (String)response[0], 'SIR_cls_gestorMotorTest.enviarAccionKOTest No devuelve respuesta KO cuando debería');
        }


    }
    
    @isTest
    public static void procesoInfoTest(){
        List<Object> response;
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('UsuarioTestSir',rol,'System Administrator','U012222');
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345645');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_procesoInfoMock());
            Test.startTest();
            response = SIR_cls_gestorMotor.procesoInfo(proceso.Id);
            Test.stopTest();
            Assert.areEqual('OK', (String)response[0], 'SIR_cls_WS_procesoInfoTest.sincronizaProcesoBodyOkCode1Test No devuelve respuesta OK cuando debería');
        }
    }
    
    @isTest 
    public static void sincronizaProcesoBodyOkStCode500Test() {
        List<Object> response;
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('UsuarioTestSir',rol,'System Administrator','U012222');
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345648');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_procesoInfoMock());
            Test.startTest();
            response = SIR_cls_gestorMotor.procesoInfo(proceso.Id);
            Test.stopTest();
            Assert.areEqual('KO', (String)response[0], 'SIR_cls_WS_procesoInfoTest.sincronizaProcesoBodyOkStCode500Test No devuelve respuesta KO cuando debería');
        }
    }
  
}