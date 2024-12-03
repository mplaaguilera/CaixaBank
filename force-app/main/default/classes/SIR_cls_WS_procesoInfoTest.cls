@isTest
public with sharing class SIR_cls_WS_procesoInfoTest {

    @TestSetup static void makeData(){
        SIR_TestDataFactory.CrearIntegrationSetting('procesoInfo');
    }

    @isTest static void sincronizaProcesoEmptyBodyCatchExTest() {
        List<Object> response;
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('UsuarioTestSir',rol,'System Administrator','U012222');
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345644');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_procesoInfoMock());
            Test.startTest();
            response = SIR_cls_WS_procesoInfo.sincronizaProceso(proceso.Id,'12345644');
            Test.stopTest();
            Assert.areEqual('KO', (String)response[0], 'SIR_cls_WS_procesoInfoTest.sincronizaProcesoEmptyBodyCatchExTest No devuelve respuesta KO cuando debería');
        }
    }

    @isTest static void sincronizaProcesoBodyOkCode2Test() {
        List<Object> response;
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('UsuarioTestSir',rol,'System Administrator','U012222');
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345646');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_procesoInfoMock());
            Test.startTest();
            response = SIR_cls_WS_procesoInfo.sincronizaProceso(proceso.Id,'12345646');
            Test.stopTest();
            Assert.areEqual('KO', (String)response[0], 'SIR_cls_WS_procesoInfoTest.sincronizaProcesoBodyOkCode2Test No devuelve respuesta KO cuando debería');
        }
    }

    @isTest static void sincronizaProcesoBodyOkCode1Test() {
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
            response = SIR_cls_WS_procesoInfo.sincronizaProceso(proceso.Id,'12345645');
            Test.stopTest();
            Assert.areEqual('OK', (String)response[0], 'SIR_cls_WS_procesoInfoTest.sincronizaProcesoBodyOkCode1Test No devuelve respuesta OK cuando debería');
        }
    }

    @isTest static void sincronizaProcesoBodyOkStCode300Test() {
        List<Object> response;
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('UsuarioTestSir',rol,'System Administrator','U012222');
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345647');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            Test.setMock(HttpCalloutMock.class, new SIR_cls_WS_procesoInfoMock());
            Test.startTest();
            response = SIR_cls_WS_procesoInfo.sincronizaProceso(proceso.Id,'12345647');
            Test.stopTest();
            Assert.areEqual('KO', (String)response[0], 'SIR_cls_WS_procesoInfoTest.sincronizaProcesoBodyOkStCode300Test No devuelve respuesta KO cuando debería');
        }
    }

    @isTest static void sincronizaProcesoBodyOkStCode500Test() {
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
            response = SIR_cls_WS_procesoInfo.sincronizaProceso(proceso.Id,'12345648');
            Test.stopTest();
            Assert.areEqual('KO', (String)response[0], 'SIR_cls_WS_procesoInfoTest.sincronizaProcesoBodyOkStCode500Test No devuelve respuesta KO cuando debería');
        }
    }

    @isTest static void getRequestIntSettingNullTest(){
        HttpRequest response;
        Map<String, String> mHeaders = new  Map<String, String>();
        mHeaders.put('Content-Type', 'application/json');
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('UsuarioTestSir',rol,'System Administrator','U012222');
        System.runAs(usuario){
            Test.startTest();
            response = SIR_cls_WS_procesoInfo.getRequest(null, null, 'GET', mHeaders, false, false, '12345644');
            Test.stopTest();
            Assert.areEqual('System.HttpRequest[Endpoint=null, Method=null]', response.toString(), 'SIR_cls_WS_procesoInfoTest.getRequestIntSettingNullTest No devuelve System.HttpRequest[Endpoint=null, Method=null]');
        }
    }

    @isTest static void getRequestBodyTest(){
        HttpRequest response;
        Map<String, String> mHeaders = new  Map<String, String>();
        mHeaders.put('Content-Type', 'application/json');
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('UsuarioTestSir',rol,'System Administrator','U012222');
        System.runAs(usuario){
            Test.startTest();
            response = SIR_cls_WS_procesoInfo.getRequest('a', 'procesoInfo', 'GET', mHeaders, false, false, '12345644');
            Test.stopTest();
            Assert.areEqual('System.HttpRequest[Endpoint=callout:procesoInfo/12345644, Method=GET]', response.toString(), 'SIR_cls_WS_procesoInfoTest.getRequestBodyTest No devuelve System.HttpRequest[Endpoint=callout:procesoInfo/12345644, Method=GET]');
        }
    }
}