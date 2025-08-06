@istest
public with sharing class SIR_HomePresolAutoRefresh_Test {
    @istest
    public static void getQueryProcesosTest(){
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('HomePresolAutoRefreshTestUser',rol,'AV_Usuario_CaixaBank','U012222');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        List<SIREC__SIREC_obj_proceso__c> procesos;
        
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
				Name = SIR_Constantes.tipoProceso_PRESOL,
                SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_PRESOL_E1,	
            	SIREC__SIREC_fld_cliente__c    = cuenta.Id,
				SIREC__SIREC_fld_fechaInicio__c  = date.today(),
            	SIREC__SIREC_fld_fechaLimite__c  = date.today(),
            	SIREC__SIREC_fld_fechaSituacion__c = date.today(),
                SIREC__SIREC_fld_masterRecordId__c = String.valueof((Math.random() * 100000)),
                SIR_AccionActual__c = true,
                ownerId = usuario.Id,
                recordtypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL).getRecordTypeId()
			);
		    insert proceso;
            Test.startTest();
            SIR_Parametros__c setting = new SIR_Parametros__c();
            setting.Name = 'maxCajas_PRESOL';
            setting.SIR_Valor__c = '8';
            setting.SIR_Parametro__c = 'maxCajas_PRESOL';
            setting.SIR_Tipo__c = 'maxCajas_PRESOL';
            insert setting;
            SIR_LCMP_HomePresolAutoRefresh.getAgrupacionesEstrategias();
            procesos = SIR_LCMP_HomePresolAutoRefresh.getQueryProcesos();
            Test.stopTest();
            
        }
        System.assertEquals(1, procesos.size(), 'SIR_HomePresolAutoRefresh_Test.getQueryProcesosTest  No se obtiene el numero de procesos esperado');
        
    }

    
    @istest
    public static void getQueryReportsTest(){
        List<Report> informes = new List<Report>();
            Test.startTest();
            informes = SIR_LCMP_HomePresolAutoRefresh.getQueryReports();
            Test.stopTest();
        System.assertEquals(0, informes.size(), 'SIR_HomePresolAutoRefresh_Test.getQueryReportsTest  No se obtiene el numero de informes esperado');
    }

}