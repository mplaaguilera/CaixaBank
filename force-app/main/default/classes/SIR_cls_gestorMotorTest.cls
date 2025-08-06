@isTest
public with sharing class SIR_cls_gestorMotorTest {
    @TestSetup
    static void makeData(){
       
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'AV_Usuario_CaixaBank','U012222');  

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        System.runAs(usuario){
           Account cuenta = SIR_TestDataFactory.crearCuenta();        
           SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345645');                 
           SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);     
           
           SIR_TestDataFactory.CrearIntegrationSetting('llamadaMotor');
           SIR_TestDataFactory.CrearIntegrationSetting('altaAccion');        
           SIR_TestDataFactory.CrearIntegrationSetting('procesoInfo','{idProceso}');  
           
        }   
    }
    @isTest
    public static void avanzaMotorOKTest() {
        User usuario = [SELECT Id FROM User LIMIT 1];
        SIREC__SIREC_obj_tarea__c tarea = [SELECT Id FROM SIREC__SIREC_obj_tarea__c LIMIT 1];
        System.runAs(usuario) {           
            List<String> response = new List<String>();           
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_llamadaMotorMock());
            Test.startTest();
              response = SIR_cls_gestorMotor.avanzaMotor(tarea.id);
            Test.stopTest();
            System.assertEquals('OK', response.get(0), 'No devuelve el OK que debería');
            System.assertEquals(2, [SELECT Id FROM SIREC__SIREC_obj_tarea__c].size(), 'No se ha creado la tarea nueva');
        }
    }


    @isTest
    public static void avanzaMotorErrorTest() {
        User usuario = [SELECT Id FROM User LIMIT 1]; 
        System.runAs(usuario) {
            SIREC__SIREC_obj_proceso__c proceso = [SELECT Id FROM SIREC__SIREC_obj_proceso__c LIMIT 1]; 
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoCTLWS(proceso); 
            List<String> response = new List<String>();
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_llamadaMotorMock());
            Test.startTest();
              response = SIR_cls_gestorMotor.avanzaMotor(tarea.Id);
            Test.stopTest();
            System.assertEquals('KO', response.get(0), 'No devuelve el KO que debería');
            System.assertEquals('Se ha producido un error en la sincronización, contacte con el administrador.', response.get(1), 'SIR_cls_gestorMotorTest.avanzaMotorErrorTest El mensaje que muestra no es el correcto');
        }
    }

    @isTest
    public static void enviarAccionTest() {
        User usuario = [SELECT Id FROM User LIMIT 1]; 
        System.runAs(usuario) {
           
           SIREC__SIREC_obj_proceso__c proceso = [SELECT Id, SIREC__SIREC_fld_cliente__c FROM SIREC__SIREC_obj_proceso__c LIMIT 1];
           SIREC__SIREC_obj_tarea__c tarea = [SELECT Id FROM SIREC__SIREC_obj_tarea__c LIMIT 1];

           SIREC__SIREC_obj_acciones__c accion =  SIR_TestDataFactory.crearAccion(proceso);
           accion.SIREC__SIREC_fld_tarea__c = tarea.Id;
           accion.SIREC__SIREC_fld_tipo__c = SIR_Constantes.ACCION_TIPO_VOLUNTAD_CLIENTE;        
           accion.SIREC__SIREC_fld_accion__c = SIR_Constantes.ACCION_TIPO_LLAMADA_EMITIDA;
           accion.SIREC__SIREC_fld_resultado__c = SIR_Constantes.ACCION_RESULTADO_NO_LOCALIZADO;
           accion.SIREC__SIREC_fld_persona__c = proceso.SIREC__SIREC_fld_cliente__c;
           accion.SIREC__SIREC_fld_interviniente__c = proceso.SIREC__SIREC_fld_cliente__c;
           accion.RecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByDeveloperName().get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_PRESOL).getRecordTypeId();   
           
           update accion;
           SIREC__SIREC_obj_Catalogo__c  catalogoA = new SIREC__SIREC_obj_Catalogo__c (
               Name = SIR_Constantes.CATALOGO_API_MAPEO_ACCIONES_PRESOL,
               SIREC__SIREC_fld_Descripcion__c = SIR_Constantes.ACCION_TIPO_LLAMADA_EMITIDA, 
               SIREC__SIREC_fld_Codigo__c = accion.SIREC__SIREC_fld_tipo__c+'|A|'+accion.SIREC__SIREC_fld_accion__c,
               SIREC__SIREC_fld_MasterRecordId__c   = SIR_Constantes.CATALOGO_API_MAPEO_ACCIONES_PRESOL+'|'+accion.SIREC__SIREC_fld_tipo__c+'|A|'+accion.SIREC__SIREC_fld_accion__c
        
           );
           insert catalogoA;
           // alta catalogo respuesta
           SIREC__SIREC_obj_Catalogo__c  catalogoR = new SIREC__SIREC_obj_Catalogo__c (
               Name = SIR_Constantes.CATALOGO_API_MAPEO_ACCIONES_PRESOL,
               SIREC__SIREC_fld_Descripcion__c = SIR_Constantes.ACCION_TIPO_LLAMADA_EMITIDA, 
               SIREC__SIREC_fld_Codigo__c = accion.SIREC__SIREC_fld_tipo__c+'|R|'+accion.SIREC__SIREC_fld_resultado__c,
               SIREC__SIREC_fld_MasterRecordId__c   = SIR_Constantes.CATALOGO_API_MAPEO_ACCIONES_PRESOL+'|'+accion.SIREC__SIREC_fld_tipo__c+'|R|'+accion.SIREC__SIREC_fld_resultado__c
           );
           insert catalogoR;
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
        User usuario = [SELECT Id FROM User LIMIT 1]; 
        System.runAs(usuario) {
           
           SIREC__SIREC_obj_proceso__c proceso = [SELECT Id, SIREC__SIREC_fld_cliente__c FROM SIREC__SIREC_obj_proceso__c LIMIT 1];
           SIREC__SIREC_obj_tarea__c tarea = [SELECT Id FROM SIREC__SIREC_obj_tarea__c LIMIT 1];

           SIREC__SIREC_obj_acciones__c accion =  SIR_TestDataFactory.crearAccion(proceso);
           accion.SIREC__SIREC_fld_tarea__c = tarea.Id;
           accion.SIREC__SIREC_fld_tipo__c = SIR_Constantes.ACCION_TIPO_VOLUNTAD_CLIENTE;        
           accion.SIREC__SIREC_fld_accion__c = SIR_Constantes.ACCION_TIPO_LLAMADA_EMITIDA;
           accion.SIREC__SIREC_fld_resultado__c = SIR_Constantes.ACCION_RESULTADO_NO_LOCALIZADO;
           accion.SIREC__SIREC_fld_persona__c = proceso.SIREC__SIREC_fld_cliente__c;
           accion.SIREC__SIREC_fld_interviniente__c = proceso.SIREC__SIREC_fld_cliente__c;
           accion.RecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByDeveloperName().get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_PRESOL).getRecordTypeId();   
           
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
        List<String> response = new List<String>();
        User usuario = [SELECT Id FROM User LIMIT 1]; 
        System.runAs(usuario){
         
            SIREC__SIREC_obj_proceso__c proceso = [SELECT Id, SIREC__SIREC_fld_masterRecordId__c FROM SIREC__SIREC_obj_proceso__c LIMIT 1];
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_procesoInfoMock());
            Test.startTest();
               response = SIR_cls_gestorMotor.procesoInfo(proceso.Id);
            Test.stopTest();
            Assert.areEqual('OK', response.get(0), 'SIR_cls_WS_procesoInfoTest.procesoInfoTest No devuelve respuesta OK cuando debería');
        }
    }
    
    @isTest 
    public static void procesoInfoKOTest() {
        List<Object> response;
        User usuario = [SELECT Id FROM User LIMIT 1]; 
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = [SELECT Id, SIREC__SIREC_fld_masterRecordId__c FROM SIREC__SIREC_obj_proceso__c LIMIT 1];
            proceso.SIREC__SIREC_fld_masterRecordId__c = '12345648';
            update proceso;
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_procesoInfoMock());
            Test.startTest();
            response = SIR_cls_gestorMotor.procesoInfo(proceso.Id);
            Test.stopTest();
            Assert.areEqual('KO', (String)response[0], 'SIR_cls_WS_procesoInfoTest.procesoInfoKOTest No devuelve respuesta KO cuando debería');
        }
    }
 
}