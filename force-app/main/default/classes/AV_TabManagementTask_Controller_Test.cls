/**********************************************************************************************************************
 Name:	  AV_TabManagementTask_Controller_Test
 Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Test para AV_TabManagementTask_Controller.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			Test    		Sandra Gómez 	    17/02/2021		Init version
	1.1			Test    		Víctor Santiago 	25/02/2021		Added validateGetTaskStatus and validateUpdateTaskNotLocated methods
	1.2			Test    		Víctor Santiago 	26/02/2021		Added 10 secs offset to validateUpdateTaskReminder datetime
	1.3			Test    		Víctor Santiago 	15/04/2021		Updated methods: validateUpdateTask,
																					 validateUpdateTaskNotLocated,
																					 validateUpdateTaskReminder
	1.4			US254520   		Víctor Santiago 	09/08/2021		New methods created: validateUpdateTaskExperiencia,
																						 validateGetExperienciaClientData
	1.5			US268687		Maria Martinez		27/09/2021		New methods created: validateGetResponseHGM
	1.6			US288303		Sandra Gómez		15/11/2021		change methods
	1.7			US268502		Daniel Rodríguez	31/01/2022		Add validateupdateTaskReportOpp method 
	1.8			US310702		Víctor Santiago		27/04/2022		Added EAPGestor to validateUpdateTaskAC 
	1.9			US517394		Patricia Solano		09/02/2023		Modify validateGetResponseHGM and setup 
	2.0         US308354        Elisabeth R         01/03/2023     Added getIsIntouchTest method and fixed QC errors

***********************************************************************************************************************/
@isTest
public with sharing class AV_TabManagementTask_Controller_Test {

	/**
	 * Create Task
	 */
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();
		User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User usuarioCli =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];
		User usuario = AV_TestHelper.createUser('AV_Usuario_CaixaBank','U0009003');
		Contact contactAux = AV_TestHelper.createRepresentante(null, usuario, 'U0009003');
		Task tarea = AV_TestHelper.createTareaExternalId(usuario,'999991');
		System.runAs(usuarioCli){
			Account cuenta = AV_TestHelper.createCustomerCompanySinInsert();
			cuenta.AV_Idioma__c = '001';
			cuenta.AV_NumPerso__c = '213465';
			Database.insert(cuenta);
		}
		System.runAs(usuarioCli){
			Account cuenta = [SELECT Id FROM Account WHERE AV_NumPerso__c ='213465' LIMIT 1];
			Task experiencia = AV_TestHelper.createTareaExternalIdWithCustomer(usuario,'01928374', cuenta);
			experiencia.RecordTypeId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKEXPCLIENT_RT).Id;
            experiencia.Status= 'Open';
            experiencia.AV_SurveyValue__c = 11;
			experiencia.AV_Valor5__c = 'token: E2j5VVFkG4u180y';
			Schema.DescribeFieldResult externalIdObjectField = Task.AV_ExternalId__C.getDescribe();
			Schema.sObjectField externalIdField = externalIdObjectField.getSObjectField();
			Database.upsert(experiencia,externalIdField,false);
	
			CBK_Activity_Extension__c actExt = new CBK_Activity_Extension__c();
			actExt.AV_AccionesARealizar__c = 'OECP';
			actExt.AV_ActivityId__c = experiencia.Id;
			Database.insert(actExt);
	
			Date todaysDate = system.today();
			Datetime currentDateTime = Datetime.now();
			AV_ManagementHistory__c historial = AV_TestHelper.createManagementHistory(tarea, todaysDate, currentDateTime);
			AV_ManagementHistory__c historialExp = AV_TestHelper.createManagementHistory(experiencia, todaysDate, currentDateTime);

			Task tareaAC = AV_TestHelper.createTareaOtherExternalID(new User(Id=UserInfo.getUserId()));
            Event eventTest= AV_TestHelper.createEventExternalIdSinInsert(usuario, todaysDate, null,cuenta);
            eventTest.Subject='Llamada Saliente';
			
            insert(eventTest);
		}
		AV_CustomActivityOpportunity__c customActivity = new AV_CustomActivityOpportunity__c();
		customActivity.AV_Task__c = tarea.AV_Task__C;
		Database.insert(customActivity);
		
		CBK_Activity_Extension__c activityExt = new CBK_Activity_Extension__c();
		activityExt.AV_ActivityId__c = tarea.Id;
		Database.insert(activityExt);
		AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition WHERE DeveloperName = 'AV_CaixaBankCRM' LIMIT 1];        
		UserAppInfo app = new UserAppInfo(AppDefinitionId = appDefinition.DurableId, UserId = UserInfo.getUserId(), FormFactor = 'Small');
		Database.insert(app);
        
	}


	     


	@isTest
	public static void validateUpdateTask() {
		String result;
		Test.startTest();
		Task tarea = [SELECT Id,Description,OwnerId FROM Task WHERE Subject = 'Llamada Saliente' AND Status = :AV_AppConstants.TASK_STATUS_PENDIENTE  AND AV_ExternalID__C = '999991' LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];
		Date todaysDate = system.today();
		Contact cnt = [SELECT ID FROM CONTACT WHERE CC_Matricula__c ='U0009003'];
		System.runAs(owner) {
			result = AV_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva','VLD',todaysDate,'Prueba updateTask',null,null,null,cnt.Id, todaysDate);
		}
		List<Task> tareaActualizada = [SELECT Id,Status,AV_Tipo__C,Description FROM Task WHERE Id = :tarea.Id];
		Test.stopTest();
		System.assertEquals('Gestionada positiva',tareaActualizada[0].Status);
		System.assertEquals('VLD',tareaActualizada[0].AV_Tipo__c);
		System.assertEquals(todaysDate.format()+' - Prueba updateTask', tareaActualizada[0].Description);
	}
    
    @isTest
	public static void validateUpdateTaskReportOpp() {
		User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		Test.startTest();
		Task tarea = [SELECT Id,Description,Subject,OwnerId,WhatId, ActivityDate FROM Task LIMIT 1];
		tarea.OwnerId = usuarioGcf.Id;
		update tarea;
		
		System.runAs(usuarioGcf) {
			tarea.Status = 'Gestionada positiva';
			update tarea;
		}
		Date todaysDate = system.today();
		AV_TabManagementTask_Controller.updateTaskReportOpp(tarea.id,tarea.Subject,'VLD', tarea.Description, tarea.ActivityDate, tarea.OwnerId, tarea.WhatId,null);
		List<Task> tareaActualizada = [SELECT Id,Status,AV_Tipo__c,Description FROM Task WHERE Id = :tarea.id];
		Test.stopTest();
		System.assertEquals('Gestionada positiva',tareaActualizada[0].Status);
		System.assertEquals('VLD',tareaActualizada[0].AV_Tipo__c);
	}

	@isTest
	public static void validateUpdateTaskExperiencia() {
		Task exp = [SELECT Id,Description,OwnerId FROM Task WHERE AV_ExternalID__c = '01928374' ];
		Date todaysDate = system.today();
		User owner = [SELECT Id FROM User WHERE Id = :exp.OwnerId];
		Test.startTest();
		Contact ownerCnt = [SELECT Id FROM Contact LIMIT 1];
		System.runAs(owner) {
			AV_TabManagementTask_Controller.updateTask(exp.id,'Gestionada positiva','VLD',todaysDate,'Prueba updateTask con exp cliente','OECP','MO','P',ownerCnt.Id, todaysDate);
		}
		Test.stopTest();
		List<Task> tareaActualizada = [SELECT Id, Status, AV_Tipo__c, Description FROM Task WHERE Id = :exp.Id ];
	    CBK_Activity_Extension__c actExt = [SELECT Id, AV_AccionesARealizar__c, AV_MotivoCierreExperienciaCliente__c, AV_ValoracionGestion__c 
	  	FROM CBK_Activity_Extension__c where AV_ActivityId__c = :exp.Id LIMIT 1];
		System.assertEquals('Gestionada positiva',tareaActualizada[0].Status);
		System.assertEquals('VLD',tareaActualizada[0].AV_Tipo__c);
		System.assertEquals(todaysDate.format()+' - Prueba updateTask con exp cliente', tareaActualizada[0].Description);
		System.assertEquals('OECP',actExt.AV_AccionesARealizar__c);
		System.assertEquals('MO',actExt.AV_MotivoCierreExperienciaCliente__c);
		System.assertEquals('P',actExt.AV_ValoracionGestion__c);
	}
    
    @isTest
	public static void validateUpdateTaskAC() {
		Test.startTest();
        String result;
		User owner = new User();
		owner.Id = UserInfo.getUserId();
		Account centroCaixa = AV_TestHelper.createCaixaCenter();
		Contact emplo = AV_TestHelper.createEmployee(centroCaixa, owner);
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKALERTACOM_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		tarea.OwnerId = owner.Id;	
		tarea.Status = 'Pendiente no localizado';
		tarea.Priority = 'Normal';
		tarea.AV_ExternalID__c = '01928888';
		tarea.RecordTypeId = rt.Id;
		tarea.ActivityDate = System.today()-3;
		Database.insert(tarea);
		Date todaysDate = system.today();
		String result2;
		System.runAs(owner) {
			result = AV_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva','VLD',todaysDate,'Prueba updateTask',null,null,null,emplo.id, todaysDate);
			result2 = AV_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva','VLD',todaysDate.addDays(5),'Prueba updateTask',null,null,null,emplo.Id, todaysDate);
		}
		List<Task> tareaActualizada = [SELECT Id, Status, AV_Tipo__c, Description FROM TASK WHERE Id = :tarea.Id ];
		Test.stopTest();

		System.assertEquals('Gestionada positiva',tareaActualizada[0].Status);
		System.assertEquals('VLD',tareaActualizada[0].AV_Tipo__c);
		System.assertEquals(todaysDate.format()+' - Prueba updateTask', tareaActualizada[0].Description);
		System.assertEquals(Label.AV_ErrorGTDueDate,result2,'Error');
	}

	@isTest
	public static void validateUpdateTaskNotLocated() {
		Task tarea = [SELECT Id,Description,OwnerId FROM TASK LIMIT 1];
		Date todaysDate = system.today();
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];

		Test.startTest();
		system.runAs(owner){
			AV_TabManagementTask_Controller.updateTaskNotLocated(tarea.id,'Pendiente no localizado','VLD',todaysDate,'Prueba updateTaskNotLocated');
		}
		Test.stopTest();
		List<Task> tareaActualizada  = [SELECT Id,Status,AV_Tipo__c,Description FROM Task WHERE Id = :tarea.Id];
		System.assertEquals('Pendiente no localizado',tareaActualizada[0].Status);
		System.assertEquals('VLD',tareaActualizada[0].AV_Tipo__c);
		System.assertEquals(todaysDate.format()+' - Prueba updateTaskNotLocated', tareaActualizada[0].Description);
	}
    
    @isTest
	public static void validateUpdateTaskReminder() {
		Test.startTest();
		Task tarea = [SELECT Id,Description FROM Task LIMIT 1];
		Datetime currentDateTime = Datetime.now().addSeconds(10); // tolerancia añadida para cuando se llame a updateTaskReminder
		AV_TabManagementTask_Controller.updateTaskReminder(tarea.id,currentDateTime,'Prueba updateTaskReminder');
		List<Task> tareaActualizada = [SELECT Id, ReminderDateTime, IsReminderSet, Description FROM Task WHERE Id = :tarea.Id ];
		//Test Failing
		User gestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank');
		tarea.RecordTypeId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKCONTACTGCF_RT).Id;
		update tarea;
		String result;
		try{
			System.runAs(gestor){
				result = AV_TabManagementTask_Controller.updateTaskReminder(tarea.Id, currentDateTime, 'Forzando validation rule');
			}
		}catch(Exception err){
			System.assertNotEquals('OK', result,'error');
		}
		Test.stopTest();
		System.assertEquals(true,tareaActualizada[0].IsReminderSet);
		System.assertEquals(currentDateTime,tareaActualizada[0].ReminderDateTime);
		System.assertEquals(currentDateTime.date().format() + ' - Prueba updateTaskReminder', tareaActualizada[0].Description);
	}

    @isTest
	public static void validateGetRecordType() { 
		Test.startTest();
		Task tarea = [SELECT Id,OwnerId FROM Task LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];

		Datetime currentDateTime = Datetime.now();
		system.runAs(owner){
			String recordType = AV_TabManagementTask_Controller.getRecordType(tarea.id);
			System.assertEquals('AV_Otros',recordType);

		}
		Test.stopTest();
	}
    
    @isTest
    public static void getRecordTypeTestWithoutIdCorrect(){
        Test.startTest();
		Task tarea = [SELECT Id,OwnerId FROM Task LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];
        String idFail = 'FAIL'; 
		String results = null;
		system.runAs(owner){
			try {
				results=AV_TabManagementTask_Controller.getRecordType(idFail);
			}catch(Exception e){
				results = 'Controled Fail';
			}
			System.assertEquals('Controled Fail', results);
		}
		Test.stopTest(); 

    }
    
    @isTest
	public static void validateGetManagementHistory() {
		Test.startTest();
		Task tarea = [SELECT Id,OwnerId FROM Task LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];

		List<AV_TabManagementTask_Controller.DataTableWrapper> results = new List<AV_TabManagementTask_Controller.DataTableWrapper>();
		system.runAs(owner){
			results = AV_TabManagementTask_Controller.getManagementHistory(tarea.id);
			System.assertEquals(false,results.isEmpty());

		}

        Test.stopTest();
	}
    
    @isTest
	public static void validateGetPickListValuesByRecordTypeId() {
		Test.startTest();
		Task tarea = [SELECT Id,OwnerId FROM Task LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];
		system.runAs(owner){
			List<Map<String, String>> lista = AV_TabManagementTask_Controller.getPickListValuesByRecordTypeId('Task',tarea.id,'AV_Tipo__c','AV_TaskTipoExperienciaCliente');
			System.assertEquals(false,lista.isEmpty());

		}
        Test.stopTest();
	}

	@isTest
	public static void validateGetTaskStatus() {
		Task tarea = [SELECT Status,OwnerId FROM Task LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];
		system.runAs(owner){
			Test.startTest();
			Task tarea1 = AV_TabManagementTask_Controller.getTaskStatus(tarea.id);	
			Test.stopTest();
			System.assertEquals(false, String.isEmpty(tarea1.Status));
		}
		
	}
    
	@isTest
	public static void validateGetExperienciaClientData() {
		User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		System.runAs(usuarioGcf) {
			Task exp = [SELECT Id,Description FROM Task WHERE AV_ExternalID__C = '01928374'];
			Test.startTest();
			AV_TabManagementTask_Controller.ExpClienteDataWrapper result = AV_TabManagementTask_Controller.getExperienciaClienteData(exp.Id);
			Test.stopTest();
			System.assertNotEquals(result, null, 'Empty experiencia cliente');
		}
	}

	@isTest
	public static void validateGetResponseHGMEng(){
		Test.startTest();
		User usuarioCli =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];
		System.runAs(usuarioCli) {
			Account cliente = AV_TestHelper.createCustomerWithNumpersonSinInsert('123656');
			cliente.AV_Idioma__c = '010';
			Database.insert(cliente);
		}
		Account cliente = [SELECT Id FROM Account WHERE AV_NumPerso__c ='123656'];
		Task tarea = [SELECT Id, CreatedDate, AV_SurveyValue__c FROM Task WHERE AV_ExternalID__C = '01928374'];
		tarea.WhatId = cliente.Id;
		tarea.AV_SurveyValue__c = 11;
		tarea.AV_Valor5__c = 'token: E2j5VVFkG4u180y';
		update tarea;
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('HGMSURVEYID', 'OK'));
		Date todaysDate = system.today();
		AV_TabManagementTask_Controller.getResponseHGM(tarea.Id, todaysDate);
		Test.stopTest();
		CBK_Activity_Extension__c actiEx = [SELECT id FROM CBK_Activity_Extension__c  WHERE AV_ActivityId__c =:tarea.Id LIMIT 1];
		System.assertNotEquals(actiEx, null);
	}

	@isTest
	public static void validateGetResponseHGMCat(){
		Test.startTest();
		User usuarioCli =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];
		System.runAs(usuarioCli) {
			Account cliente = AV_TestHelper.createCustomerWithNumpersonSinInsert('123656');
			cliente.AV_Idioma__c = '001';
			Database.insert(cliente);
		}
		Account cliente = [SELECT Id FROM Account WHERE AV_NumPerso__c ='123656'];
		Task tarea = [SELECT Id, CreatedDate, AV_SurveyValue__c FROM Task WHERE AV_ExternalID__C = '01928374'];
		tarea.WhatId = cliente.Id;
		tarea.AV_SurveyValue__c = 12;
		tarea.AV_Valor5__c = 'E2j5VVFkG4u180y';
		update tarea;
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('HGMSURVEYID', 'OK'));
		Date todaysDate = system.today();
		AV_TabManagementTask_Controller.getResponseHGM(tarea.Id, todaysDate);
		Test.stopTest();
		CBK_Activity_Extension__c actiEx = [SELECT id FROM CBK_Activity_Extension__c  WHERE AV_ActivityId__c =:tarea.Id LIMIT 1];
		System.assertNotEquals(actiEx, null);
	}


	@isTest
	public static void validateShowAssingPurse(){
		Task tarea = [SELECT Id,OwnerId FROM Task WHERE AV_ExternalID__C = '01928374'];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];
        CBK_Activity_Extension__c tareaExtension = [SELECT AV_StatusCodeAPI__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :tarea.Id ];
		tareaExtension.AV_ReasignarCartera_Id_Task__c = tarea.Id;
		tareaExtension.AV_StatusCodeAPI__c = '200';
		Database.update(tareaExtension);
		system.runAs(owner){
			Test.startTest();
			Boolean result =  AV_TabManagementTask_Controller.showAssignPurse(tarea.Id);
			Test.stopTest();
			System.assertEquals(false, result, 'StatusCode distinto 200');
		}
		
	}
    
    @isTest
    public static void getContactTestWithAccountId(){
        Test.startTest();   
        String searchTerm = '';
        List<Task> taskId = [SELECT id,OwnerId From Task LIMIT 10];
		User owner = [SELECT Id FROM User WHERE Id = :taskId[0].OwnerId];
        List<String> selectedIds = new List<String>();   
        for(Task auxId : taskId){
            selectedIds.add(auxId.id);
        }
        Account accountAux = [SELECT Id FROM Account Limit 1];
        String accountId = accountAux.Id;
		Id[] fixedSearchResults = new Id[1];
		fixedSearchResults[0] = accountId;
		// SOSL queries need fixed results in order to retrieve data
		Test.setFixedSearchResults(fixedSearchResults);
		system.runAs(owner){
			List<AV_LookupSearchResult> results =AV_TabManagementTask_Controller.getContact(searchTerm, selectedIds, accountId);
			System.assertNotEquals(null, results);

		}
      	Test.stopTest();      
    }
    
    @isTest
    public static void getContactTestWithoutAccountId(){
        Test.startTest();   
        String searchTerm = '';
        List<String> selectedIds = new List<String>();     
        Account accountAux = [SELECT Id FROM Account Limit 1];
        String accountId = accountAux.Id;
		Task taskAux = [SELECT Id,OwnerId FROM task LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :taskAux.OwnerId];
		system.runAs(owner){
			List<AV_LookupSearchResult> results =AV_TabManagementTask_Controller.getContact(searchTerm, selectedIds, accountId);
			System.assertNotEquals(null, results);
		}
		Test.stopTest();      

    }
    
    @isTest
    public static void getContactTaskTest(){        
        Task taskAux = [SELECT Id,OwnerId FROM task LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :taskAux.OwnerId];

        String idRecords = taskAux.Id;
		system.runAS(owner){
			Test.startTest();       

			Task results =AV_TabManagementTask_Controller.getContactTask(idRecords);
			Test.stopTest();      
			 System.assertNotEquals(null, results);
		}
        
	}
    
    @isTest
    public static void acccountClienteTest(){
        Test.startTest();
        Account acc = [SELECT Id, RecordType.DeveloperName FROM Account  LIMIT 1];
        acc.RecordType.DeveloperName = 'CC_Cliente';
        String accountId = acc.Id;      
		Task taskAux = [SELECT Id,OwnerId FROM task LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :taskAux.OwnerId];
		system.runAs(owner){
			Boolean results=AV_TabManagementTask_Controller.acccountCliente(accountId);
			System.assertNotEquals(null, results);
		}  
		Test.stopTest(); 

	}
    
    @isTest
    public static void insertOrUpdateActivityExtTest(){
        Test.startTest();
        Task taskAux = [SELECT Id,OwnerId FROM task LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :taskAux.OwnerId];

        String taskId =  taskAux.Id;
        String acciones;      
        String motivo;
        String valoracion;
		system.runAs(owner){
			String results=AV_TabManagementTask_Controller.insertOrUpdateActivityExt(taskId, acciones, motivo, valoracion);
			System.assertNotEquals(null, results);

		}
        Test.stopTest(); 
    }
    
	@isTest
    public static void insertOrUpdateActivityExtJsonTest(){
        Test.startTest();
        Task taskAux = [SELECT Id,OwnerId FROM task LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :taskAux.OwnerId];

        String taskId =  taskAux.Id;
        String jsonEncuesta;      
        String estadoEncuenta;
		system.runAs(owner){
			String results=AV_TabManagementTask_Controller.insertOrUpdateActivityExt(taskId, jsonEncuesta, estadoEncuenta);
			CBK_Activity_Extension__c record = [SELECT ID,AV_ActivityId__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c != null LIMIT 1];
			String resultFail;
			try{
				 resultFail = AV_TabManagementTask_Controller.insertOrUpdateActivityExt(record.AV_ActivityId__c,jsonEncuesta, '1234567890100');
			}catch(Exception err){
				System.assertNotEquals('OK', resultFail,'Error');
			}
			System.assertNotEquals(null, results);
		}
		Test.stopTest(); 

    }

	@isTest
	public static void insertEventRelatedToTaskTestTipe0(){
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
		String result;
		Date todaysDate = system.today();
		Task tarea = [SELECT Id,Subject,Description,OwnerId,AccountId FROM TASK WHERE Status = :AV_AppConstants.TASK_STATUS_PENDIENTE LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];
		Contact cnt = AV_TestHelper.createEmployee(null,owner);
		Account center = [SELECT ID FROM ACCOUNT WHERE RECORDTYPE.DeveloperName = :AV_AppConstants.ACCOUNT_ENT_RT LIMIT 1];
		tarea.whatId = center.Id;
		update tarea;
		system.runAs(owner){
			result = AV_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva','CTO',todaysDate,'Prueba updateTask',null,null,null,tarea.AccountId, todaysDate);

		}
		List<Event> retrieveEvents = [SELECT Id FROM EVENT Where Subject = :tarea.Subject ];
		Test.stopTest();
		System.assert(!retrieveEvents.isEmpty());
	}

	@isTest
	public static void insertEventRelatedToTaskTestTipe1(){
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
		String result;
		Date todaysDate = system.today();
		Task tarea = [SELECT Id,Subject,Description,OwnerId,AccountId,AV_Task__c FROM TASK WHERE Status = :AV_AppConstants.TASK_STATUS_PENDIENTE LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId ];
		Contact cnt = AV_TestHelper.createEmployee(null,owner);
		Account center = [SELECT ID FROM ACCOUNT WHERE RECORDTYPE.DeveloperName = :AV_AppConstants.ACCOUNT_ENT_RT LIMIT 1];
		tarea.whatId = center.Id;
		update tarea;
		system.runAs(owner){
			result = AV_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva',AV_AppConstants.CITA_TELEFONICA_TIPO,todaysDate,'Prueba updateTask',null,null,null,tarea.AccountId, todaysDate);
		}
		List<Event> retrieveEvents = [SELECT Id FROM EVENT Where Subject = :tarea.Subject ];
		Test.stopTest();
		System.assert(!retrieveEvents.isEmpty());
	}

	@isTest
	public static void insertEventRelatedToTaskTestTipeVisita(){
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
		String result;
		Date todaysDate = system.today();
		Task tarea = [SELECT Id,Subject,Description,OwnerId,AccountId,AV_Task__c FROM TASK WHERE Status = :AV_AppConstants.TASK_STATUS_PENDIENTE LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];
		Contact cnt = AV_TestHelper.createEmployee(null,owner);
		Account center = [SELECT ID FROM ACCOUNT WHERE RECORDTYPE.DeveloperName = :AV_AppConstants.ACCOUNT_ENT_RT LIMIT 1];
		tarea.whatId = center.Id;
		update tarea;
		system.runAs(owner){
			result = AV_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva',AV_AppConstants.VISITA_TIPO,todaysDate,'Prueba updateTask',null,null,null,tarea.AccountId, todaysDate);
		}
		List<Event> retrieveEvents = [SELECT Id FROM EVENT Where Subject = :tarea.Subject ];
		Test.stopTest();
		System.assert(!retrieveEvents.isEmpty());
	}

	@isTest
	public static void insertEventRelatedToTaskTestTipe2(){
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
		String result;
		Date todaysDate = system.today();
		Task tarea = [SELECT Id,Subject,Description,OwnerId,AccountId FROM TASK WHERE Status = :AV_AppConstants.TASK_STATUS_PENDIENTE LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];
		Contact cnt = AV_TestHelper.createEmployee(null,owner);
		Account center = [SELECT ID FROM ACCOUNT WHERE RECORDTYPE.DeveloperName = :AV_AppConstants.ACCOUNT_ENT_RT LIMIT 1];
		tarea.whatId = center.Id;
		update tarea;
		
		system.runAs(owner){
			result = AV_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva',AV_AppConstants.LLAMADA_TIPO,todaysDate,'Prueba updateTask',null,null,null,tarea.AccountId, todaysDate);
		}
		List<Event> retrieveEvents = [SELECT Id FROM EVENT Where Subject = :tarea.Subject ];
		Test.stopTest();
		System.assert(!retrieveEvents.isEmpty());
	}

	@isTest
	public static void testingFails(){
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
		Date todaysDate = system.today();
		Task tarea = [SELECT Id,OwnerId FROM Task WHERE OwnerId != :UserInfo.getUserId() LIMIT 1];
		Task tarea2 = [SELECT Id,OwnerId FROM Task WHERE Id != :tarea.id LIMIT 1];
		User owner = [SELECT Id FROM USER WHERE Id != :UserInfo.getUserId() AND Id IN (SELECT AV_UsuarioAsociado__c FROM Contact)];
		String error2;
		system.runAs(owner){

		try{
			 error2 =  AV_TabManagementTask_Controller.updateTask(tarea2.id,'Gestionada positiva',AV_AppConstants.LLAMADA_TIPO,todaysDate,'Prueba updateTask','NNN',null,null,null, todaysDate);
		}catch(Exception err){
			System.assertNotEquals('OK', error2,'error');
		}
        }
		tarea.OwnerId = owner.Id;
		tarea2.WhatId = null;
		tarea2.status = AV_AppConstants.GESTIONADO_POSITIVO_ESTADO;
		tarea2.RecordTypeId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT).ID;
		update new List<Task>{tarea,tarea2};
		String error1 =  AV_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva',AV_AppConstants.LLAMADA_TIPO,todaysDate,'Prueba updateTask',null,null,null,null, todaysDate);
		String errorInsertEvent;
		try{
			errorInsertEvent = AV_TabManagementTask_Controller.updateTaskReportOpp(tarea2.id,'Gestionada positiva','badValuePicklist','Prueba updateTask',todaysDate,null,null,null);
		}catch(Exception err){
			System.assertNotEquals('OK', errorInsertEvent,'error');
		}
		String errorBadPicklist;
		try{
			errorBadPicklist = AV_TabManagementTask_Controller.updateTask(tarea2.id,'Gestionada positiva','badValuePickList',todaysDate,'Prueba updateTask',null,null,null,null, todaysDate);
		}catch(Exception err){
			System.assertNotEquals('OK', errorBadPicklist,'error');
		}
		User badOwner = [SELECT Id FROM User WHERE Id = :tarea2.OwnerId];
		badOwner.AV_ExternalID__C = null;
		update badOwner;
		try{
			errorInsertEvent =  AV_TabManagementTask_Controller.updateTask(tarea2.id,'Gestionada positiva',AV_AppConstants.LLAMADA_TIPO,todaysDate,'Prueba updateTask',null,null,null,null, todaysDate);
		}catch(Exception err){
			System.assertNotEquals('OK', errorInsertEvent,'error');

		}
		String updateTaskNotLOcatedFail;
		try{
			updateTaskNotLOcatedFail = AV_TabManagementTask_Controller.updateTaskNotLocated(tarea.Id,'Gestionada positiva' , 'badValueType', todaysDate, null);
		}catch(Exception err){

			System.assertNotEquals('OK', updateTaskNotLOcatedFail,'error');
		}
		String updateTaskReminderFail ;
		try{
			updateTaskReminderFail = AV_TabManagementTask_Controller.updateTaskNotLocated(tarea.Id,'Gestionada positiva' , 'badValueType', todaysDate, null);
		}catch(Exception err){
			System.assertNotEquals('OK', updateTaskReminderFail,'error');
		}
		Test.stopTest();
		System.assertEquals(error1,Label.AV_CMP_DiffUserOwner,'Error');
		
	}


	@isTest
	public static void getIsIntouchTest(){
		Test.startTest();
		
		User employee = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
		// Contact cnt = AV_TestHelper.createEmployee(null, employee, 'U0009003');


        system.runAs(employee){
           Boolean result = AV_TabManagementTask_Controller.getIsIntouch('U0009003');
           System.assertEquals(result, false);

        }

		Test.stopTest();
	}

}