@istest
public with sharing class SIR_HomeImpaAutoRefresh_Test {

    @TestSetup 
    static void makeData(){

        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('HomeImpaAutoRefreshTestUser',rol,'AV_Usuario_CaixaBank','U012222');  
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);        
    }


    @istest
    public static void getQueryProcesosTest(){
        User usuario = [SELECT Id FROM User LIMIT 1];
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        List<SIREC__SIREC_obj_proceso__c> procesos;
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIR_TestDataFactory.crearProceso(cuenta);
            Test.startTest();
            SIR_Parametros__c setting = new SIR_Parametros__c();
            setting.Name = 'maxCajas_IMPA';
            setting.SIR_Valor__c = '8';
            setting.SIR_Parametro__c = 'maxCajas_IMPA';
            setting.SIR_Tipo__c = 'maxCajas_IMPA';
            insert setting;
            SIR_LCMP_HomeImpaAutoRefresh.getAgrupacionesEstrategias();
            procesos = SIR_LCMP_HomeImpaAutoRefresh.getQueryProcesos();
            Test.stopTest();
            
        }
        System.assertEquals(1, procesos.size(), 'SIR_HomeImpaAutoRefresh_Test.getQueryProcesosTest  No se obtiene el numero de procesos esperado');
        
    }

    @istest
    public static void getQueryFormulariosTest(){
        User usuario = [SELECT Id FROM User LIMIT 1];
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        List<SIR_FormularioRefinanciacion__c> formularios = new List<SIR_FormularioRefinanciacion__c>();
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
            Map<String,Schema.RecordTypeInfo> mapRTsObjectsFormulario = Schema.SObjectType.SIR_FormularioRefinanciacion__c.getRecordTypeInfosByDeveloperName();
            Id recordTypeForm = mapRTsObjectsFormulario.get('SIR_FormularioRefinanciacion').getRecordTypeId();             
            formulario.RecordTypeId = recordTypeForm;
            formulario.SIR_Estado__c = SIR_Constantes.FORMULARIOREFINANCIACION_ESTADO_EN_CURSO;
            update formulario;
            Test.startTest();
            formularios = SIR_LCMP_HomeImpaAutoRefresh.getQueryFormularios();
            Test.stopTest();
        }
        System.assertEquals(1, formularios.size(), 'SIR_HomeImpaAutoRefresh_Test.getQueryFormulariosTest  No se obtiene el numero de formularios esperado');
    }

    @istest
    public static void getQueryAccionesTest(){
        List<SIREC__SIREC_obj_acciones__c> acciones = new List<SIREC__SIREC_obj_acciones__c>();
        User usuario = [SELECT Id FROM User LIMIT 1];
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            Map<String,Schema.RecordTypeInfo> mapRTsObjectsProcesos = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName();
            Id recordTypeIdAmistoso = mapRTsObjectsProcesos.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_IMPA).getRecordTypeId();        
            proceso.RecordTypeId = recordTypeIdAmistoso;
            update proceso;
            SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.crearAccionProcesoAmistoso(proceso);
            accion.SIREC__SIREC_fld_responsable__c = usuario.Id;
            accion.SIREC__SIREC_fld_estado__c = SIR_Constantes.ACCION_ESTADO_PENDIENTE;
            update accion;
            Test.startTest();
            acciones = SIR_LCMP_HomeImpaAutoRefresh.getQueryAcciones();
            Test.stopTest();
        }
        System.assertEquals(1, acciones.size(), 'SIR_HomeImpaAutoRefresh_Test.getQueryAccionesTest  No se obtiene el numero de acciones esperado');
    }

    //@isTest(SeeAllData=true)
    @istest
    public static void getQueryReportsTest(){
        User usuario = [SELECT Id FROM User LIMIT 1];

        List<Report> informes = new List<Report>();
        System.runAs(usuario){
            Test.startTest();
            informes = SIR_LCMP_HomeImpaAutoRefresh.getQueryReports();
            Test.stopTest();
        }
        System.assertEquals(0, informes.size(), 'SIR_HomeImpaAutoRefresh_Test.getQueryReportsTest  No se obtiene el numero de informes esperado');
        //System.assertEquals(11, informes.size(), 'SIR_HomeImpaAutoRefresh_Test.getQueryReportsTest  No se obtiene el numero de informes esperado');
    }

}