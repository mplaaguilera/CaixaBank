@isTest
public with sharing class SIR_cls_gestorTareaTest {

    @isTest
    public static void insertTareaCatchExceptionTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'System Administrator', 'U012222');
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            result = SIR_cls_gestorTarea.insertTarea(respuestaSirec);
            Test.stopTest(); 
        }
        System.assertEquals('KO', result.get(0), 'SIR_cls_gestorTareaTest.insertTareaCatchExceptionTest: No se ha obtenido el KO');
    }

    @isTest
    public static void insertTareaSelTipoTareaTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'System Administrator', 'U012222');
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        respuestaSirec.put('tipoDialogoDim', SIR_Constantes.CODIGO_TAREA_SEL);
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            result = SIR_cls_gestorTarea.insertTarea(respuestaSirec);
            Test.stopTest(); 
        }
        System.assertEquals('KO', result.get(0), 'SIR_cls_gestorTareaTest.insertTareaSelTipoTareaTest: No se ha obtenido el KO');
    }

    @isTest
    public static void insertTareaConSeleccionTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'System Administrator', 'U012222');
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        Map<String, String> mapDescripcion = new Map<String, String>();
        List<Object> lstSeleccion = new List<Object>();
        mapDescripcion.put('idSeleccion', 'idSeleccion');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu');
        mapDescripcion.put('descripcionRes', 'respuestaUsu');
        lstSeleccion.add(mapDescripcion);
        respuestaSirec.put('seleccion', lstSeleccion);
        respuestaSirec.put('tipoDialogoDim', SIR_Constantes.CODIGO_TAREA_SEL);
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            result = SIR_cls_gestorTarea.insertTarea(respuestaSirec);
            Test.stopTest(); 
        }
        System.assertEquals('KO', result.get(0), 'SIR_cls_gestorTareaTest.insertTareaConSeleccionTest: No se ha obtenido el KO');
    }
    
    @isTest
    public static void insertTareaDoneTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'System Administrator', 'U012222');
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        Map<String, String> mapDescripcion = new Map<String, String>();
        List<Object> lstSeleccion = new List<Object>();
        mapDescripcion.put('idSeleccion', 'idSeleccion');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu');
        mapDescripcion.put('descripcionRes', 'respuestaUsu');
        lstSeleccion.add(mapDescripcion);
        respuestaSirec.put('seleccion', lstSeleccion);
        respuestaSirec.put('tipoDialogoDim', SIR_Constantes.CODIGO_TAREA_SEL);
        respuestaSirec.put('idProceso', 12345);
        respuestaSirec.put('idActividad', 54321);
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            update tarea;
            result = SIR_cls_gestorTarea.insertTarea(respuestaSirec);
            Test.stopTest(); 
        }
        System.assertEquals('OK', result.get(0), 'SIR_cls_gestorTareaTest.insertTareaDoneTest: No se ha obtenido el KO');
    }

    @isTest
    public static void insertTareaNullTareaIdTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'System Administrator', 'U012222');
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        Map<String, String> mapDescripcion = new Map<String, String>();
        List<Object> lstSeleccion = new List<Object>();
        mapDescripcion.put('idSeleccion', 'idSeleccion');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu');
        mapDescripcion.put('descripcionRes', 'respuestaUsu');
        lstSeleccion.add(mapDescripcion);
        respuestaSirec.put('seleccion', lstSeleccion);
        respuestaSirec.put('tipoDialogoDim', SIR_Constantes.CODIGO_TAREA_SEL);
        respuestaSirec.put('idProceso', 12345);
        respuestaSirec.put('idActividad', null);
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            update tarea;
            result = SIR_cls_gestorTarea.insertTarea(respuestaSirec);
            Test.stopTest(); 
        }
        System.assertEquals('OK', result.get(0), 'SIR_cls_gestorTareaTest.insertTareaNullTareaIdTest: No se ha obtenido el KO');
    }

    @isTest
    public static void evaluarInformarTareasProcesosCase1Test() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'System Administrator', 'U012222');
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        Map<String, String> mapDescripcion = new Map<String, String>();
        List<Object> lstSeleccion = new List<Object>();
        mapDescripcion.put('idSeleccion', 'idSeleccion');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu');
        mapDescripcion.put('descripcionRes', 'respuestaUsu');
        lstSeleccion.add(mapDescripcion);
        respuestaSirec.put('seleccion', lstSeleccion);
        respuestaSirec.put('tipoDialogoDim', SIR_Constantes.CODIGO_TAREA_SEL);
        respuestaSirec.put('idProceso', 12345);
        respuestaSirec.put('idActividad', 54321);
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            SIR_Constantes constantes = new SIR_Constantes();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            tarea.SIREC__SIREC_fld_codigo_tarea__c = SIR_Constantes.CODIGO_PROPUESTA_NEGOCIO;
            tarea.SIR_EmpleadoPREVEMP__c = SIR_Constantes.EMPLEADO_GESTION_RIESGOS;
            update tarea;
            result = SIR_cls_gestorTarea.insertTarea(respuestaSirec);
            Test.stopTest(); 
        }
        System.assertEquals('OK', result.get(0), 'SIR_cls_gestorTareaTest.evaluarInformarTareasProcesosCase1Test: No se ha obtenido el KO');
    }

    @isTest
    public static void evaluarInformarTareasProcesosCase2Test() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'System Administrator', 'U012222');
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        Map<String, String> mapDescripcion = new Map<String, String>();
        List<Object> lstSeleccion = new List<Object>();
        mapDescripcion.put('idSeleccion', 'idSeleccion');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu');
        mapDescripcion.put('descripcionRes', 'respuestaUsu');
        lstSeleccion.add(mapDescripcion);
        respuestaSirec.put('seleccion', lstSeleccion);
        respuestaSirec.put('tipoDialogoDim', SIR_Constantes.CODIGO_TAREA_SEL);
        respuestaSirec.put('idProceso', 12345);
        respuestaSirec.put('idActividad', 54321);
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            SIR_Constantes constantes = new SIR_Constantes();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            tarea.SIREC__SIREC_fld_codigo_tarea__c = SIR_Constantes.CODIGO_PROPUESTA_NEGOCIO;
            tarea.SIR_EmpleadoPREVEMP__c = SIR_Constantes.EMPLEADO_GESTION_NEGOCIO;
            update tarea;
            result = SIR_cls_gestorTarea.insertTarea(respuestaSirec);
            Test.stopTest(); 
        }
        System.assertEquals('OK', result.get(0), 'SIR_cls_gestorTareaTest.evaluarInformarTareasProcesosCase2Test: No se ha obtenido el KO');
    }

    @isTest
    public static void evaluarInformarTareasProcesosCase3Test() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'System Administrator', 'U012222');
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        Map<String, String> mapDescripcion = new Map<String, String>();
        List<Object> lstSeleccion = new List<Object>();
        mapDescripcion.put('idSeleccion', 'idSeleccion');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu');
        mapDescripcion.put('descripcionRes', 'respuestaUsu');
        lstSeleccion.add(mapDescripcion);
        respuestaSirec.put('seleccion', lstSeleccion);
        respuestaSirec.put('tipoDialogoDim', SIR_Constantes.CODIGO_TAREA_SEL);
        respuestaSirec.put('idProceso', 12345);
        respuestaSirec.put('idActividad', 54321);
        respuestaSirec.put('codigoProcesoSituacion', SIR_Constantes.PROCESO_SITUACION_NO_REQUIERE_ACCION_PREVENTIVA);
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            SIR_Constantes constantes = new SIR_Constantes();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            tarea.SIREC__SIREC_fld_codigo_tarea__c = SIR_Constantes.CODIGO_PROPUESTA_NEGOCIO;
            tarea.SIR_EmpleadoPREVEMP__c = SIR_Constantes.EMPLEADO_GESTION_NEGOCIO;
            update tarea;
            update proceso;
            result = SIR_cls_gestorTarea.insertTarea(respuestaSirec);
            Test.stopTest(); 
        }
        System.assertEquals('OK', result.get(0), 'SIR_cls_gestorTareaTest.evaluarInformarTareasProcesosCase3Test: No se ha obtenido el OK');
    }

    @isTest
    public static void evaluarInformarTareasProcesosCase4Test() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'System Administrator', 'U012222');
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        Map<String, String> mapDescripcion = new Map<String, String>();
        List<Object> lstSeleccion = new List<Object>();
        mapDescripcion.put('idSeleccion', 'idSeleccion');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu');
        mapDescripcion.put('descripcionRes', 'respuestaUsu');
        lstSeleccion.add(mapDescripcion);
        respuestaSirec.put('seleccion', lstSeleccion);
        respuestaSirec.put('tipoDialogoDim', SIR_Constantes.CODIGO_TAREA_SEL);
        respuestaSirec.put('idProceso', 12345);
        respuestaSirec.put('idActividad', 54321);
        respuestaSirec.put('codigoProcesoSituacion', SIR_Constantes.PROCESO_SITUACION_CON_ACCION_PREVENTIVA);
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            SIR_Constantes constantes = new SIR_Constantes();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            tarea.SIREC__SIREC_fld_codigo_tarea__c = SIR_Constantes.CODIGO_PROPUESTA_NEGOCIO;
            tarea.SIR_EmpleadoPREVEMP__c = SIR_Constantes.EMPLEADO_GESTION_NEGOCIO;
            update tarea;
            update proceso;
            result = SIR_cls_gestorTarea.insertTarea(respuestaSirec);
            Test.stopTest(); 
        }
        System.assertEquals('OK', result.get(0), 'SIR_cls_gestorTareaTest.evaluarInformarTareasProcesosCase4Test: No se ha obtenido el OK');
    }

    @isTest
    public static void evaluarInformarTareasProcesosCase5Test() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'System Administrator', 'U012222');
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        Map<String, String> mapDescripcion = new Map<String, String>();
        List<Object> lstSeleccion = new List<Object>();
        mapDescripcion.put('idSeleccion', 'idSeleccion');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu');
        mapDescripcion.put('descripcionRes', 'respuestaUsu');
        lstSeleccion.add(mapDescripcion);
        respuestaSirec.put('seleccion', lstSeleccion);
        respuestaSirec.put('tipoDialogoDim',SIR_Constantes.CODIGO_TAREA_SEL);
        respuestaSirec.put('idProceso', 12345);
        respuestaSirec.put('idActividad', 54321);
        respuestaSirec.put('codigoProcesoSituacion', SIR_Constantes.PROCESO_SITUACION_ACCION_RESTRICTIVA_PENDIENTE);
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            SIR_Constantes constantes = new SIR_Constantes();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            tarea.SIREC__SIREC_fld_codigo_tarea__c = SIR_Constantes.CODIGO_PROPUESTA_NEGOCIO;
            tarea.SIR_EmpleadoPREVEMP__c = SIR_Constantes.EMPLEADO_GESTION_NEGOCIO;
            update tarea;
            update proceso;
            result = SIR_cls_gestorTarea.insertTarea(respuestaSirec);
            Test.stopTest(); 
        }
        System.assertEquals('OK', result.get(0), 'SIR_cls_gestorTareaTest.evaluarInformarTareasProcesosCase5Test: No se ha obtenido el OK');
    }

    @isTest
    public static void evaluarInformarTareasProcesosCase6Test() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'System Administrator', 'U012222');
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        Map<String, String> mapDescripcion = new Map<String, String>();
        List<Object> lstSeleccion = new List<Object>();
        mapDescripcion.put('idSeleccion', 'idSeleccion');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu');
        mapDescripcion.put('descripcionRes', 'respuestaUsu');
        lstSeleccion.add(mapDescripcion);
        respuestaSirec.put('seleccion', lstSeleccion);
        respuestaSirec.put('tipoDialogoDim', SIR_Constantes.CODIGO_TAREA_SEL);
        respuestaSirec.put('idProceso', 12345);
        respuestaSirec.put('idActividad', 54321);
        respuestaSirec.put('codigoProcesoSituacion', SIR_Constantes.PROCESO_SITUACION_ACCION_RESTRICTIVA_APLICADA);
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            SIR_Constantes constantes = new SIR_Constantes();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            tarea.SIREC__SIREC_fld_codigo_tarea__c = SIR_Constantes.CODIGO_PROPUESTA_ORG_RESOLUTOR;
            tarea.SIR_EmpleadoPREVEMP__c = SIR_Constantes.EMPLEADO_GESTION_NEGOCIO;
            tarea.Name = 'Fecha estimada actuación';
            tarea.SIREC__SIREC_fld_tipo_tarea__c = SIR_Constantes.CODIGO_TAREA_DAT;
            update tarea;
            update proceso;
            result = SIR_cls_gestorTarea.insertTarea(respuestaSirec);
            Test.stopTest(); 
        }
        System.assertEquals('OK', result.get(0), 'SIR_cls_gestorTareaTest.evaluarInformarTareasProcesosCase6Test: No se ha obtenido el OK');
    }

    @isTest
    public static void upsertTareaTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'System Administrator', 'U012222');
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        Map<String, String> mapDescripcion = new Map<String, String>();
        List<Object> lstSeleccion = new List<Object>();
        mapDescripcion.put('idSeleccion', 'idSeleccion');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu');
        mapDescripcion.put('descripcionRes', 'respuestaUsu');
        lstSeleccion.add(mapDescripcion);
        respuestaSirec.put('seleccion', lstSeleccion);
        respuestaSirec.put('tipoDialogoDim', SIR_Constantes.CODIGO_TAREA_SEL);
        respuestaSirec.put('idProceso', 12345);
        respuestaSirec.put('idActividad', 54321);
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            SIR_Constantes constantes = new SIR_Constantes();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            tarea.SIREC__SIREC_fld_codigo_tarea__c = SIR_Constantes.CODIGO_PROPUESTA_ORG_RESOLUTOR;
            tarea.SIR_EmpleadoPREVEMP__c = SIR_Constantes.EMPLEADO_GESTION_NEGOCIO;
            tarea.Name = 'Fecha estimada actuación';
            tarea.SIREC__SIREC_fld_tipo_tarea__c = SIR_Constantes.CODIGO_TAREA_DAT;
            update tarea;
            proceso.SIR_fld_Situacion_SF__c = SIR_Constantes.PROCESO_SITUACION_ACCION_RESTRICTIVA_APLICADA;
            update proceso;
            result = SIR_cls_gestorTarea.upsertTarea(respuestaSirec, proceso);
            Test.stopTest(); 
        }
        Assert.areEqual('OK', result.get(0), 'SIR_cls_gestorTareaTest.upsertTareaTest: Se ha producido un error.');
    }

    @isTest
    public static void upsertTareaNullMrIdTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'System Administrator', 'U012222');
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        Map<String, String> mapDescripcion = new Map<String, String>();
        List<Object> lstSeleccion = new List<Object>();
        mapDescripcion.put('idSeleccion', 'idSeleccion');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu');
        mapDescripcion.put('descripcionRes', 'respuestaUsu');
        lstSeleccion.add(mapDescripcion);
        respuestaSirec.put('seleccion', lstSeleccion);
        respuestaSirec.put('tipoDialogoDim', SIR_Constantes.CODIGO_TAREA_SEL);
        respuestaSirec.put('idProceso', 12345);
        respuestaSirec.put('idActividad', null);
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            SIR_Constantes constantes = new SIR_Constantes();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            tarea.SIREC__SIREC_fld_codigo_tarea__c = SIR_Constantes.CODIGO_PROPUESTA_ORG_RESOLUTOR;
            tarea.SIR_EmpleadoPREVEMP__c = SIR_Constantes.EMPLEADO_GESTION_NEGOCIO;
            tarea.Name = 'Fecha estimada actuación';
            tarea.SIREC__SIREC_fld_tipo_tarea__c = SIR_Constantes.CODIGO_TAREA_DAT;
            update tarea;
            proceso.SIR_fld_Situacion_SF__c = SIR_Constantes.PROCESO_SITUACION_ACCION_RESTRICTIVA_APLICADA;
            update proceso;
            result = SIR_cls_gestorTarea.upsertTarea(respuestaSirec, proceso);
            Test.stopTest(); 
        }
        Assert.areEqual('OK', result.get(0), 'SIR_cls_gestorTareaTest.upsertTareaNullMrIdTest: Se ha producido un error.');
    }

    @isTest
    public static void upsertTareaExceptionTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'System Administrator', 'U012222');
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        Map<String, String> mapDescripcion = new Map<String, String>();
        List<Object> lstSeleccion = new List<Object>();
        mapDescripcion.put('idSeleccion', 'idSeleccion');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu');
        mapDescripcion.put('descripcionRes', 'respuestaUsu');
        lstSeleccion.add(mapDescripcion);
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            SIR_Constantes constantes = new SIR_Constantes();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            tarea.SIREC__SIREC_fld_codigo_tarea__c = SIR_Constantes.CODIGO_PROPUESTA_ORG_RESOLUTOR;
            tarea.SIR_EmpleadoPREVEMP__c = SIR_Constantes.EMPLEADO_GESTION_NEGOCIO;
            tarea.Name = 'Fecha estimada actuación';
            tarea.SIREC__SIREC_fld_tipo_tarea__c = SIR_Constantes.CODIGO_TAREA_DAT;
            update tarea;
            proceso.SIR_fld_Situacion_SF__c = SIR_Constantes.PROCESO_SITUACION_ACCION_RESTRICTIVA_APLICADA;
            update proceso;
            result = SIR_cls_gestorTarea.upsertTarea(respuestaSirec, proceso);
            Test.stopTest();
        }
        Assert.areEqual('KO', result.get(0), 'SIR_cls_gestorTareaTest.upsertTareaExceptionTest: Se ha producido un error al generar la excepción.');
    }

    @isTest
    public static void updateTareaPteSincroTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'System Administrator', 'U012222');
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        Map<String, String> mapDescripcion = new Map<String, String>();
        List<Object> lstSeleccion = new List<Object>();
        mapDescripcion.put('idSeleccion', 'idSeleccion');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu');
        mapDescripcion.put('descripcionRes', 'respuestaUsu');
        lstSeleccion.add(mapDescripcion);
        System.runAs(usuario) {
            Test.startTest();
            SIR_Constantes constantes = new SIR_Constantes();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            tarea.SIREC__SIREC_fld_codigo_tarea__c = SIR_Constantes.CODIGO_PROPUESTA_ORG_RESOLUTOR;
            tarea.SIR_EmpleadoPREVEMP__c = SIR_Constantes.EMPLEADO_GESTION_NEGOCIO;
            tarea.Name = 'Fecha estimada actuación';
            tarea.SIREC__SIREC_fld_tipo_tarea__c = SIR_Constantes.CODIGO_TAREA_DAT;
            update tarea;
            proceso.SIR_fld_Situacion_SF__c = SIR_Constantes.PROCESO_SITUACION_ACCION_RESTRICTIVA_APLICADA;
            update proceso;
            SIR_cls_gestorTarea.updateTareaPteSincro(tarea.Id);
            Test.stopTest(); 
        }
        SIREC__SIREC_obj_tarea__c tareaUpd = [SELECT Name FROM SIREC__SIREC_obj_tarea__c  LIMIT 1];
        System.assertEquals('Fecha estimada actuación', tareaUpd.Name, 'SIR_cls_gestorTareaTest.updateTareaPteSincroTest: No se ha modificado el Name de la Tarea.');
    }

    @isTest
    public static void updateTareaPteSincroExceptionTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'System Administrator', 'U012222');
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        Map<String, String> mapDescripcion = new Map<String, String>();
        List<Object> lstSeleccion = new List<Object>();
        mapDescripcion.put('idSeleccion', 'idSeleccion');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu');
        mapDescripcion.put('descripcionRes', 'respuestaUsu');
        lstSeleccion.add(mapDescripcion);
        try {
            System.runAs(usuario) {
                Test.startTest();
                SIR_Constantes constantes = new SIR_Constantes();
                Account cuenta = SIR_TestDataFactory.crearCuenta();
                SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345');
                SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
                tarea.SIREC__SIREC_fld_codigo_tarea__c = SIR_Constantes.CODIGO_PROPUESTA_ORG_RESOLUTOR;
                tarea.SIR_EmpleadoPREVEMP__c = SIR_Constantes.EMPLEADO_GESTION_NEGOCIO;
                tarea.Name = 'Fecha estimada actuación';
                tarea.SIREC__SIREC_fld_tipo_tarea__c = SIR_Constantes.CODIGO_TAREA_DAT;
                update tarea;
                proceso.SIR_fld_Situacion_SF__c = SIR_Constantes.PROCESO_SITUACION_ACCION_RESTRICTIVA_APLICADA;
                update proceso;
                SIR_cls_gestorTarea.updateTareaPteSincro('12345');
                Test.stopTest(); 
            }
        } catch(Exception ex) {
            Assert.areEqual('updateTareaPteSincro Invalid id: 12345',ex.getMessage(),'SIR_cls_gestorTareaTest.updateTareaPteSincroExceptionTest: No se produce la excepción esperada.');
        }
    }

    @isTest
    public static void updateTareaTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'System Administrator', 'U012222');
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        Map<String, String> mapDescripcion = new Map<String, String>();
        List<Object> lstSeleccion = new List<Object>();
        mapDescripcion.put('idSeleccion', 'idSeleccion');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu');
        mapDescripcion.put('descripcionRes', 'respuestaUsu');
        lstSeleccion.add(mapDescripcion);
        System.runAs(usuario) {
            Test.startTest();
            SIR_Constantes constantes = new SIR_Constantes();
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345');
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            tarea.SIREC__SIREC_fld_codigo_tarea__c = SIR_Constantes.CODIGO_PROPUESTA_ORG_RESOLUTOR;
            tarea.SIR_EmpleadoPREVEMP__c = SIR_Constantes.EMPLEADO_GESTION_NEGOCIO;
            tarea.Name = 'Fecha estimada actuación';
            tarea.SIREC__SIREC_fld_tipo_tarea__c = SIR_Constantes.CODIGO_TAREA_DAT;
            update tarea;
            proceso.SIR_fld_Situacion_SF__c = SIR_Constantes.PROCESO_SITUACION_ACCION_RESTRICTIVA_APLICADA;
            update proceso;
            SIR_cls_gestorTarea.updateTarea(tarea);
            Test.stopTest(); 
        }
        SIREC__SIREC_obj_tarea__c tareaUpd = [SELECT Name FROM SIREC__SIREC_obj_tarea__c  LIMIT 1];
        System.assertEquals('Fecha estimada actuación', tareaUpd.Name, 'SIR_cls_gestorTareaTest.updateTareaTest: No se ha modificado el Name de la Tarea.');
    }
}