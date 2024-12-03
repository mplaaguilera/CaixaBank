@isTest
public with sharing class SIR_cls_gestorTareaTest {
  @TestSetup
    static void makeData(){

        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('testUser',rol,'AV_Usuario_CaixaBank','U012222');  

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        System.runAs(usuario){
           Account cuenta = SIR_TestDataFactory.crearCuenta();        
           SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta, '12345');                 
           SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoCTLWS(proceso);                             
        }   
    }
    
    @isTest
    public static void upsertTareaCatchExceptionTest() {
        User usuario = [SELECT Id FROM User LIMIT 1];
        SIREC__SIREC_obj_tarea__c tarea = [SELECT Id FROM SIREC__SIREC_obj_tarea__c LIMIT 1];
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            result = SIR_cls_gestorTarea.upsertTarea(respuestaSirec, tarea);
            Test.stopTest(); 
        }
        System.assertEquals('KO', result.get(0), 'SIR_cls_gestorTareaTest.upsertTareaCatchExceptionTest: No se ha obtenido el KO');
    }

    @isTest
    public static void upsertTareaSelTipoTareaTest() {
        User usuario = [SELECT Id FROM User LIMIT 1];
        SIREC__SIREC_obj_tarea__c tarea = [SELECT Id FROM SIREC__SIREC_obj_tarea__c LIMIT 1];
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        respuestaSirec.put('tipoDialogoDim', SIR_Constantes.CODIGO_TAREA_SEL);
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            result = SIR_cls_gestorTarea.upsertTarea(respuestaSirec,tarea);
            Test.stopTest(); 
        }
        System.assertEquals('KO', result.get(0), 'SIR_cls_gestorTareaTest.upsertTareaSelTipoTareaTest: No se ha obtenido el KO');
    }

    @isTest
    public static void upsertTareaConSeleccionTest() {
        User usuario = [SELECT Id FROM User LIMIT 1];
        SIREC__SIREC_obj_tarea__c tarea = [SELECT Id FROM SIREC__SIREC_obj_tarea__c LIMIT 1];
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
            result = SIR_cls_gestorTarea.upsertTarea(respuestaSirec, tarea);
            Test.stopTest(); 
        }
        System.assertEquals('KO', result.get(0), 'SIR_cls_gestorTareaTest.upsertTareaConSeleccionTest: No se ha obtenido el KO');
    }
    
    @isTest
    public static void evaluarInformarTareasProcesosCase1Test() {
        User usuario = [SELECT Id FROM User LIMIT 1];
        SIREC__SIREC_obj_proceso__c proceso = [SELECT Id from SIREC__SIREC_obj_proceso__c LIMIT 1];
        
        Map<String, Object> respuestaSirec = new Map<String, Object>();
        Map<String, String> mapDescripcion = new Map<String, String>();
        List<Object> lstSeleccion = new List<Object>();
        mapDescripcion.put('idSeleccion', 'idSeleccion');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu');
        mapDescripcion.put('descripcionRes', 'respuestaUsu');
        lstSeleccion.add(mapDescripcion);
        respuestaSirec.put('seleccion', lstSeleccion);
        respuestaSirec.put('tipoDialogoDim', SIR_Constantes.CODIGO_TAREA_SEL);
        respuestaSirec.put('idProceso', 12345); // masterRecordId del proceso creado en makeData
        respuestaSirec.put('idActividad', 54321);
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            tarea.SIREC__SIREC_fld_codigo_tarea__c = SIR_Constantes.CODIGO_PROPUESTA_NEGOCIO;
            tarea.SIR_EmpleadoPREVEMP__c = SIR_Constantes.EMPLEADO_GESTION_RIESGOS;
            update tarea;
            result = SIR_cls_gestorTarea.upsertTarea(respuestaSirec, tarea);
            Test.stopTest(); 
        }
        System.assertEquals('OK', result.get(0), 'SIR_cls_gestorTareaTest.evaluarInformarTareasProcesosCase1Test: No se ha obtenido el KO');
    }

    @isTest
    public static void inicializaAlReabrirProceso() {
        User usuario = [SELECT Id FROM User LIMIT 1];
        SIREC__SIREC_obj_proceso__c proceso = [SELECT Id, SIREC__SIREC_fld_situacion__c, SIREC__SIREC_fld_masterRecordId__c, SIR_PropuestaProceso__c from SIREC__SIREC_obj_proceso__c LIMIT 1];
        SIREC__SIREC_obj_tarea__c tarea = [SELECT Id from SIREC__SIREC_obj_tarea__c LIMIT 1];
        proceso.SIR_PropuestaProceso__c= 'Refinanciar';
        proceso.SIREC__SIREC_fld_situacion__c = SIR_Constantes.PROCESO_SITUACION_ILOCALIZADO;
        update proceso;

        Map<String, Object> respuestaSirec = new Map<String, Object>();
        Map<String, String> mapDescripcion = new Map<String, String>();
        List<Object> lstSeleccion = new List<Object>();
        mapDescripcion.put('idSeleccion', 'idSeleccion');
        mapDescripcion.put('respuestaUsu', 'respuestaUsu');
        mapDescripcion.put('descripcionRes', 'respuestaUsu');
        lstSeleccion.add(mapDescripcion);
        respuestaSirec.put('seleccion', lstSeleccion);
        respuestaSirec.put('tipoDialogoDim', SIR_Constantes.CODIGO_TAREA_SEL);
        respuestaSirec.put('idProceso', Integer.valueOf(proceso.SIREC__SIREC_fld_masterRecordId__c));
        respuestaSirec.put('idActividad', 54321);
        respuestaSirec.put('codigoProcesoSituacion', SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION);
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            
            result = SIR_cls_gestorTarea.upsertTarea(respuestaSirec, tarea);
            Test.stopTest(); 
        }
        Assert.areEqual(null, [SELECT SIR_PropuestaProceso__c FROM SIREC__SIREC_obj_proceso__c LIMIT 1].SIR_PropuestaProceso__c, 'SIR_cls_gestorTareaTest.inicializaAlReabrirProceso: No se inicializado el campo SIR_PropuestaProceso__c');
    }

    @isTest
    public static void evaluarPropuestaNegocioTest() {
        User usuario = [SELECT Id FROM User LIMIT 1];
        SIREC__SIREC_obj_proceso__c proceso = [SELECT Id from SIREC__SIREC_obj_proceso__c LIMIT 1];
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
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            tarea.SIREC__SIREC_fld_codigo_tarea__c = SIR_Constantes.CODIGO_PROPUESTA_NEGOCIO;
            tarea.SIR_EmpleadoPREVEMP__c = SIR_Constantes.EMPLEADO_GESTION_NEGOCIO;
            update tarea;
            update proceso;
            result = SIR_cls_gestorTarea.upsertTarea(respuestaSirec, tarea);
            Test.stopTest(); 
        }
        System.assertEquals('OK', result.get(0), 'SIR_cls_gestorTareaTest.evaluarInformarTareasProcesosCase3Test: No se ha obtenido el OK');
    }

    @isTest
    public static void updateTareaPteSincroTest() {
        User usuario = [SELECT Id FROM User LIMIT 1];
        SIREC__SIREC_obj_proceso__c proceso = [SELECT Id from SIREC__SIREC_obj_proceso__c LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
            update tarea;
            SIR_cls_gestorTarea.updateTareaPteSincro(tarea.Id);
            Test.stopTest(); 
        }
        SIREC__SIREC_obj_tarea__c tareaUpd = [SELECT SIREC__SIREC_fld_estado__c FROM SIREC__SIREC_obj_tarea__c WHERE SIREC__SIREC_fld_tipo_tarea__c = :SIR_Constantes.CODIGO_TAREA_SEL LIMIT 1];
        Assert.areEqual('Pendiente Sincronización', tareaUpd.SIREC__SIREC_fld_estado__c, 'SIR_cls_gestorTareaTest.updateTareaPteSincroTest: No se ha actualizado el estado de la Tarea.');
    }

    @isTest
    public static void updateTareaPteSincroExceptionTest() {
        User usuario = [SELECT Id FROM User LIMIT 1];
        SIREC__SIREC_obj_proceso__c proceso = [SELECT Id from SIREC__SIREC_obj_proceso__c LIMIT 1];
        try {
            System.runAs(usuario) {
                Test.startTest();
                SIREC__SIREC_obj_tarea__c tarea = SIR_TestDataFactory.crearTareaTipoSEL(proceso);
                tarea.SIREC__SIREC_fld_codigo_tarea__c = SIR_Constantes.CODIGO_PROPUESTA_ORG_RESOLUTOR;
                tarea.SIR_EmpleadoPREVEMP__c = SIR_Constantes.EMPLEADO_GESTION_NEGOCIO;
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
        User usuario = [SELECT Id FROM User LIMIT 1];
        SIREC__SIREC_obj_proceso__c proceso = [SELECT Id from SIREC__SIREC_obj_proceso__c LIMIT 1];
        SIREC__SIREC_obj_tarea__c tarea = [SELECT Id, SIREC__SIREC_fld_tipo_tarea__c from SIREC__SIREC_obj_tarea__c LIMIT 1];

        System.runAs(usuario) {
            Test.startTest();     
            tarea.SIREC__SIREC_fld_tipo_tarea__c = SIR_Constantes.CODIGO_TAREA_DAT;
            SIR_cls_gestorTarea.updateTarea(tarea);
            Test.stopTest(); 
        }
        SIREC__SIREC_obj_tarea__c tareaUpd = [SELECT SIREC__SIREC_fld_tipo_tarea__c FROM SIREC__SIREC_obj_tarea__c where SIREC__SIREC_fld_proceso__c = :proceso.id LIMIT 1];
        System.assertEquals(SIR_Constantes.CODIGO_TAREA_DAT, tareaUpd.SIREC__SIREC_fld_tipo_tarea__c, 'SIR_cls_gestorTareaTest.updateTareaTest: No se actualizado el tipo de tarea');
  
    }

    @isTest
    public static void upsertTareaOPC() {
        String masterPadre= '1234';
        String masterHijo= '3456';
        String masterTareaHija = '87878787' ;
        User usuario = [SELECT Id FROM User LIMIT 1];
        Account cuenta = [SELECT Id FROM Account LIMIT 1];
        SIREC__SIREC_obj_proceso__c procesoPadre = SIR_TestDataFactory.crearProcesoPrevemp(cuenta, masterPadre);                               
        SIREC__SIREC_obj_tarea__c tareaPadre = SIR_TestDataFactory.crearTareaTipoCTLWS(procesoPadre); 

        Map<String, Object> respuestaSirec = new Map<String, Object>();
        respuestaSirec.put('idProceso',Integer.valueOf(masterHijo)); // nuevo masterRecordId del proceso AP/PP
        respuestaSirec.put('tipoDialogoDim', SIR_Constantes.CODIGO_TAREA_OPC);
        respuestaSirec.put('codigoAct', 'OPC1');
        respuestaSirec.put('idActividad', Integer.valueOf(masterTareaHija)); // masterRecordId de la tarea que llega de conector
        
        Map<String, String> mapOpc = new Map<String, String>();
        mapOpc.put('idPrimaria', 'ID_PROPUESTA');
        mapOpc.put('funcionEje', SIR_Constantes.FUNCION_EJE_PLANPAGO);
        List<Object> lstOpc = new List<Object>();
        lstOpc.add(mapOpc);
        respuestaSirec.put('opc', lstOpc);
        
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            
            SIREC__SIREC_obj_tarea__c tareaAnterior = [SELECT Id, SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_tipo_tarea__c, SIREC__SIREC_fld_codigo_tarea__c,
                                                           SIREC__SIREC_fld_SEL_respuestas_cod__c, SIREC__SIREC_fld_seleccion__c, SIREC__SIREC_fld_DAT_importe__c,SIREC__SIREC_fld_DAT_fecha__c, SIREC__SIREC_fld_DAT_textoLargo__c, SIREC__SIREC_fld_accessToken__c  
                                                    FROM SIREC__SIREC_obj_tarea__c WHERE Id = :tareaPadre.id];
            result = SIR_cls_gestorTarea.upsertTarea(respuestaSirec, tareaAnterior);
            Test.stopTest(); 
        }
        Assert.areEqual('ID_PROPUESTA' , [SELECT SIR_IdPropuestaOPC__c from SIREC__SIREC_obj_tarea__c WHERE SIREC__SIREC_fld_masterRecordId__c = :masterTareaHija].SIR_IdPropuestaOPC__c, 'SIR_cls_gestorTareaTest.upsertTareaOPC No se ha guardado el idPropuesta');
        //Assert.areEqual(masterTareaHija, [SELECT SIREC__SIREC_fld_tareaOPCPendiente__r.SIREC__SIREC_fld_masterRecordId__c from SIREC__SIREC_obj_proceso__c WHERE SIREC__SIREC_fld_masterRecordId__c = :masterPadre].SIREC__SIREC_fld_tareaOPCPendiente__r.SIREC__SIREC_fld_masterRecordId__c, 'SIR_cls_gestorTareaTest.upsertTareaOPC No se ha creado el proceso AP/PP o asignado la tarea Hija');
    }

    @isTest
    public static void insertInfoProcesoHijo() {
        String masterPadre= '1234';
        String masterHijo= '3456';
        String masterTareaPadre = '12121212' ;
        String masterTareaHija = '34343434' ;
        User usuario = [SELECT Id FROM User LIMIT 1];
        Account cuenta = [SELECT Id FROM Account LIMIT 1];
        SIREC__SIREC_obj_proceso__c procesoPadre = SIR_TestDataFactory.crearProcesoPrevemp(cuenta, masterPadre);                               
        SIREC__SIREC_obj_proceso__c procesoHijo = SIR_TestDataFactory.crearProcesoHijo(procesoPadre, masterHijo);
        SIREC__SIREC_obj_tarea__c tareaPadre = SIR_TestDataFactory.crearTareaTipoCTLWS(procesoPadre); 
        SIREC__SIREC_obj_tarea__c tareaHijo = SIR_TestDataFactory.crearTareaTipoOPCC(procesoHijo); 
        procesoPadre.SIREC__SIREC_fld_tareaOPCPendiente__c = tareaHijo.Id;

        Map<String, Object> respuestaSirec = new Map<String, Object>();
        respuestaSirec.put('idProceso',Integer.valueOf(masterPadre));
        respuestaSirec.put('idActividad',Integer.valueOf(masterTareaPadre));
        respuestaSirec.put('tipoDialogoDim', SIR_Constantes.CODIGO_TAREA_BAT);
        respuestaSirec.put('codigoAct', 'BAT-FEACPP');
        Map<String, Object> infoProcesoHijo = new Map<String, Object>();
        infoProcesoHijo.put('idProceso',Integer.valueOf(masterHijo));
        infoProcesoHijo.put('idActividad',Integer.valueOf(masterTareaHija));
        infoProcesoHijo.put('codigoAct', 'CTL-SEGUIMIENTO');
        respuestaSirec.put('infoProcesoHijo', infoProcesoHijo);
        
        List<String> result;
        System.runAs(usuario) {
            Test.startTest();
            
            result = SIR_cls_gestorTarea.upsertTarea(respuestaSirec, tareaPadre);
            Test.stopTest(); 
        }
        Assert.areEqual(masterTareaPadre, [SELECT SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_masterRecordId__c from SIREC__SIREC_obj_proceso__c WHERE SIREC__SIREC_fld_masterRecordId__c = :masterPadre].SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_masterRecordId__c, 'SIR_cls_gestorTareaTest.insertInfoProcesoHijo: No se ha asignado la tarea Padre');
        Assert.areEqual(masterTareaHija, [SELECT SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_masterRecordId__c from SIREC__SIREC_obj_proceso__c WHERE SIREC__SIREC_fld_masterRecordId__c = :masterHijo].SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_masterRecordId__c, 'SIR_cls_gestorTareaTest.insertInfoProcesoHijo: No se ha asignado la tarea Hija');
    }
    
}