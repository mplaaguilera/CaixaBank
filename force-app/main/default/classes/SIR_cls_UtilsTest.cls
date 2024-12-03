@isTest
public with sharing class SIR_cls_UtilsTest {

    @TestSetup
    static void makeData(){
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('HomeImpaAutoRefreshTestUser',rol,'AV_Usuario_CaixaBank','U012222');  
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
    }
    @isTest
    public static void getAppRtIdsTest() {
        User usuario = [SELECT Id FROM User LIMIT 1];
        System.runAs(usuario){
            List<Set<Id>> lstSetids = new List<Set<Id>>();
            Map<String, Schema.RecordTypeInfo> mapRTProcesos = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName();
            Map<String, Schema.RecordTypeInfo> mapRTAcciones = Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByDeveloperName();
            Test.startTest();
            lstSetids.add(SIR_cls_Utils.getAppRtIds(SIR_Constantes.APP_EMPRESA_DEVELOPERNAME,'SIREC__SIREC_obj_proceso__c'));
            lstSetids.add(SIR_cls_Utils.getAppRtIds(SIR_Constantes.APP_EMPRESA_DEVELOPERNAME,'SIREC__SIREC_obj_acciones__c'));
            lstSetids.add(SIR_cls_Utils.getAppRtIds(SIR_Constantes.APP_RETAIL_DEVELOPERNAME,'SIREC__SIREC_obj_proceso__c'));
            lstSetids.add(SIR_cls_Utils.getAppRtIds(SIR_Constantes.APP_RETAIL_DEVELOPERNAME,'SIREC__SIREC_obj_acciones__c'));
            Test.stopTest();
            Set<Id> setRtIds0 = new Set<Id>();
            setRtIds0.add(mapRTProcesos.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_EMP_FLUJO).getRecordTypeId());
            setRtIds0.add(mapRTProcesos.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PREVEMP).getRecordTypeId()); 
            Set<Id> setRtIds1 = new Set<Id>();
            setRtIds1.add(mapRTAcciones.get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_AMISTOSO_EMPRESA).getRecordTypeId());
            Set<Id> setRtIds2 = new Set<Id>();
            setRtIds2.add(mapRTProcesos.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PRESOL).getRecordTypeId());
            setRtIds2.add(mapRTProcesos.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_IMPA).getRecordTypeId()); 
            Set<Id> setRtIds3 = new Set<Id>();
            setRtIds3.add(mapRTAcciones.get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_AMISTOSO_WORKFLOW).getRecordTypeId());
            setRtIds3.add(mapRTAcciones.get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_PRESOL).getRecordTypeId());
            setRtIds3.add(mapRTAcciones.get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_AMISTOSO).getRecordTypeId());
            Assert.areEqual(setRtIds0, lstSetids.get(0), 'SIR_cls_UtilsTest.getAppRtIdsTest() No se obtinen correctamente los rtids de procesos para empresa');
            Assert.areEqual(setRtIds1, lstSetids.get(1), 'SIR_cls_UtilsTest.getAppRtIdsTest() No se obtinen correctamente los rtids de acciones para empresa');
            Assert.areEqual(setRtIds2, lstSetids.get(2), 'SIR_cls_UtilsTest.getAppRtIdsTest() No se obtinen correctamente los rtids de procesos para retail');
            Assert.areEqual(setRtIds3, lstSetids.get(3), 'SIR_cls_UtilsTest.getAppRtIdsTest() No se obtinen correctamente los rtids de acciones para retail');
        }
    }

    @isTest
    public static void getActorPrefixTest(){
        User usuario = [SELECT Id FROM User LIMIT 1];
        System.runAs(usuario){
            String prefix;
            String prefixmcsol;
            String prefixmcsolemp;
            Test.startTest();
            prefix = SIR_cls_Utils.getActorPrefix();
            prefixmcsol = SIR_cls_Utils.getActorPrefix('mcsolutions');
            prefixmcsolemp = SIR_cls_Utils.getActorPrefix('mcsolutionsEmp');
            Test.stopTest();            
            Assert.areEqual(SIR_Constantes.APP_ACT_MCSOL_PREFIX, prefixmcsol, 'SIR_cls_UtilsTest.getActorPrefixTest() No se ha obtenido el prefijo de mcsol correctamente');
            Assert.areEqual(SIR_Constantes.APP_ACT_MCSOLEMP_PREFIX, prefixmcsolemp, 'SIR_cls_UtilsTest.getActorPrefixTest() No se ha obtenido el prefijo de mcsol correctamente');
        }
    }


    public static void crearIntegrationSetting(String name){
        CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
            wsc.Name = name;
            wsc.NamedCredential__c = 'callout:' + name;
            insert wsc;
    }

    @isTest
    public static void getUsersAPITest(){

        SIR_Parametros__c param = new SIR_Parametros__c();
            param.Name = 'maxUserIntegration';
            param.SIR_Parametro__c = 'numberUsersIntegration';
            param.SIR_Valor__c = '1';
            param.SIR_Tipo__c = 'userApi';
            param.SIR_Activo__c = true;
            insert param;

            
        SIR_Parametros__c param1 = new SIR_Parametros__c();
            param1.Name = 'userIntegration_00';
            param1.SIR_Parametro__c = 'CambioGestorUser00';
            param1.SIR_Valor__c = 'SIR_SSMM';
            param1.SIR_Tipo__c = 'userApi';
            param1.SIR_Activo__c = true;
        insert param1;

        User usuario = [SELECT Id FROM User LIMIT 1];

        System.runAs(usuario){
            
            Test.startTest();
                List<String> usersAPI = SIR_cls_Utils.getUsersAPI();            
            Test.stopTest();            
            Assert.areEqual(usersAPI[0], 'SIR_SSMM', 'SIR_cls_UtilsTest.getUsersAPITest() No se ha obtenido el usuario API correctamente');
        }
    }

    @isTest
    public static void getEstrategiasNegocioTest(){
        User usuario = [SELECT Id FROM User LIMIT 1];
        List<SIREC__SIREC_obj_Catalogo__c> estrategias = SIR_TestDataFactory.crearCatalogoEstrategiasNegocio(2,'PRESOL');
        System.runAs(usuario){
           
            Test.startTest();
            List<SIREC__SIREC_obj_Catalogo__c> estrategiasPRESOL= SIR_cls_Utils.getEstrategiasNegocio('PRESOL');
            Test.stopTest();            
            Assert.areEqual( 2, estrategiasPRESOL.size(), 'SIR_cls_UtilsTest.getEstrategiasNegocioTest() No se ha obtenido el numero de estrategias esperada');
        }
    }
}