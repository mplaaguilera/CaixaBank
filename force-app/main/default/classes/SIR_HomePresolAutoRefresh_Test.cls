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
            SIR_LCMP_HomePresolAutoRefresh.getQueryRecordTypeProceso();
            procesos = SIR_LCMP_HomePresolAutoRefresh.getQueryProcesos();
            Test.stopTest();
            
        }
        System.assertEquals(1, procesos.size(), 'SIR_HomePresolAutoRefresh_Test.getQueryProcesosTest  No se obtiene el numero de procesos esperado');
        
    }

    @istest
    public static void getQueryAccionesTest(){
        List<SIREC__SIREC_obj_acciones__c> acciones = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();

        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('HomePresolAutoRefreshTestUser',rol,'AV_Usuario_CaixaBank','U012222');
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);

        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
				Name = SIR_Constantes.tipoProceso_PRESOL,
                SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_PRESOL_E1,	
                SIREC__SIREC_fld_Situacion__c = SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION,
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
            SIREC__SIREC_obj_acciones__c accionNew = new SIREC__SIREC_obj_acciones__c(
				SIREC__SIREC_fld_proceso__c  = proceso.Id,
            	SIR_valorAccion__c			 = '174', 
                SIREC__SIREC_fld_responsable__c = usuario.Id,
                SIREC__SIREC_fld_tipo__c = SIR_Constantes.ACCION_TIPO_LLAMADA_EMITIDA,
                SIREC__SIREC_fld_fechaContacto__c = Date.today(),
                SIREC__SIREC_fld_estado__c = SIR_Constantes.ACCION_ESTADO_PENDIENTE,
                recordtypeId = Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByName().get(SIR_Constantes.ACCION_RECORDTYPE_NAME_PRESOL).getRecordTypeId()  	
			);
		    insert accionNew;
            
            Test.startTest();
            acciones = SIR_LCMP_HomePresolAutoRefresh.getQueryAcciones();
            Test.stopTest();
        }
        System.assertEquals(1, acciones.size(), 'SIR_HomePresolAutoRefresh_Test.getQueryAccionesTest  No se obtiene el numero de acciones esperado');
    }

    @istest
    public static void getQueryTareasTest(){
        List<SIREC__SIREC_obj_tarea__c> tareas = new List<SIREC__SIREC_obj_tarea__c>();
        SIR_Constantes constantes = new SIR_Constantes();

        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('HomePresolAutoRefreshTestUser',rol,'AV_Usuario_CaixaBank','U012222');
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);

        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
				Name = SIR_Constantes.tipoProceso_PRESOL,
                SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_PRESOL_E1,	
                SIREC__SIREC_fld_Situacion__c = SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION,
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

            SIREC__SIREC_obj_tarea__c tareaAcc = new SIREC__SIREC_obj_tarea__c(
                SIREC__SIREC_fld_proceso__c = proceso.Id,
                SIREC__SIREC_fld_masterRecordId__c = String.valueof((Math.random() * 100000)),
                SIREC__SIREC_fld_codigo_tarea__c = 'ACT',
                Name = 'Tarea ACT',
                SIREC__SIREC_fld_tipo_tarea__c = 'ACT',
                SIREC__SIREC_fld_fechaLimite__c = Date.today().adddays(60),
                SIREC__SIREC_fld_estado__c = SIR_Constantes.TAREA_ESTADO_PENDIENTE
            );
            insert tareaAcc;

            SIREC__SIREC_obj_acciones__c acc = new SIREC__SIREC_obj_acciones__c(
                SIREC__SIREC_fld_proceso__c = proceso.Id,
                SIREC__SIREC_fld_tarea__c = tareaAcc.Id,
                SIREC__SIREC_fld_accion__c = 'LLAMADA EMITIDA',
                SIREC__SIREC_fld_tipo__c = 'Llamada',
                SIREC__SIREC_fld_fechaContacto__c = date.today(),
                SIREC__SIREC_fld_interviniente__c = cuenta.Id,
                SIR_accionEnviada__c = false,
                SIREC__SIREC_fld_estado__c = SIR_Constantes.ACCION_ESTADO_PENDIENTE,
                RecordTypeId = Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByName().get(SIR_Constantes.ACCION_RECORDTYPE_NAME_PRESOL).getRecordTypeId(),
                SIREC__SIREC_fld_responsable__c = UserInfo.getUserId()
            );
            insert acc;
            
            Test.startTest();
            tareas = SIR_LCMP_HomePresolAutoRefresh.getQueryTareas();
            Test.stopTest();
        }
        System.assertEquals(1, tareas.size(), 'SIR_HomePresolAutoRefresh_Test.getQueryTareaTest  No se obtiene el numero de tarea esperado');
    }

    
    @istest
    public static void getQueryReportsTest(){
        List<Report> informes = new List<Report>();
            Test.startTest();
            informes = SIR_LCMP_HomePresolAutoRefresh.getQueryReports();
            Test.stopTest();
        System.assertEquals(0, informes.size(), 'SIR_HomePresolAutoRefresh_Test.getQueryReportsTest  No se obtiene el numero de informes esperado');
    }

    @istest
    public static void getProcesosChartTest(){ 
        
        List<SIR_LCMP_HomePresolAutoRefresh.ProcesoInfo> lstProcesos = new List<SIR_LCMP_HomePresolAutoRefresh.ProcesoInfo>();
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('HomePresolAutoRefreshTestUser',rol,'AV_Usuario_CaixaBank','U012222');
        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        SIR_Constantes constantes = new SIR_Constantes();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_gestorSolutions'];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
				Name = SIR_Constantes.tipoProceso_PRESOL,
                SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_PRESOL_E1,	
                SIREC__SIREC_fld_Situacion__c = SIR_Constantes.PROCESO_SITUACION_PENDIENTE_INICIO_GESTION,
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
            lstProcesos = SIR_LCMP_HomePresolAutoRefresh.getProcesos();
            Test.stopTest();
        }
        System.assertEquals(1, lstProcesos.size(), 'SIR_HomePresolAutoRefresh_Test.getProcesosChartTest  No se obtiene el numero de procesos esperado');
        
    }
}