@istest
public with sharing class SIR_HomeImpaAutoRefresh_Test {

    @istest
    public static void getQueryProcesosTest(){
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('HomeImpaAutoRefreshTestUser',rol,'AV_Usuario_CaixaBank','U012222');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        List<SIREC__SIREC_obj_proceso__c> procesos;
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIR_TestDataFactory.crearProceso(cuenta);
            Test.startTest();
            procesos = SIR_LCMP_HomeImpaAutoRefresh.getQueryProcesos();
            Test.stopTest();
            
        }
        System.assertEquals(1, procesos.size(), 'SIR_HomeImpaAutoRefresh_Test.getQueryProcesosTest  No se obtiene el numero de procesos esperado');
        
    }

    @istest
    public static void getQueryFormulariosTest(){
        List<SIR_FormularioRefinanciacion__c> formularios = new List<SIR_FormularioRefinanciacion__c>();
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('HomeImpaAutoRefreshTestUser',rol,'AV_Usuario_CaixaBank','U012222');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.crearFormulario(proceso);
            formulario.RecordTypeId = Schema.SObjectType.SIR_FormularioRefinanciacion__c.getRecordTypeInfosByName().get(SIR_Constantes.FORMULARIOREFINANCIACION_RECORDTYPE_NAME_FORMULARIO_REFINANCIACION).getRecordTypeId();
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
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('HomeImpaAutoRefreshTestUser',rol,'AV_Usuario_CaixaBank','U012222');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            proceso.RecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO).getRecordTypeId();
            update proceso;
            SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.crearAccionProcesoAmistoso(proceso);
            accion.SIREC__SIREC_fld_responsable__c = UserInfo.getUserId();
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
        List<Report> informes = new List<Report>();
            Test.startTest();
            informes = SIR_LCMP_HomeImpaAutoRefresh.getQueryReports();
            Test.stopTest();
        System.assertEquals(0, informes.size(), 'SIR_HomeImpaAutoRefresh_Test.getQueryReportsTest  No se obtiene el numero de informes esperado');
        //System.assertEquals(11, informes.size(), 'SIR_HomeImpaAutoRefresh_Test.getQueryReportsTest  No se obtiene el numero de informes esperado');
    }

    @istest
    public static void getProcesosChartTest(){ 
        
        List<SIR_LCMP_HomeImpaAutoRefresh.ProcesoInfo> lstProcesos = new List<SIR_LCMP_HomeImpaAutoRefresh.ProcesoInfo>();
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('HomeImpaAutoRefreshTestUser',rol,'AV_Usuario_CaixaBank','U012222');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);
            proceso.RecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO).getRecordTypeId();
            update proceso;
            SIREC__SIREC_obj_acciones__c accion = SIR_TestDataFactory.crearAccionProcesoAmistoso(proceso);
            accion.SIREC__SIREC_fld_responsable__c = UserInfo.getUserId();
            accion.SIREC__SIREC_fld_estado__c = SIR_Constantes.ACCION_ESTADO_PENDIENTE;
            update accion;
            Test.startTest();
            lstProcesos = SIR_LCMP_HomeImpaAutoRefresh.getProcesos();
            Test.stopTest();
        }
        System.assertEquals(1, lstProcesos.size(), 'SIR_HomeImpaAutoRefresh_Test.getQueryReportsTest  No se obtiene el numero de procesos esperado');
        
    }

}