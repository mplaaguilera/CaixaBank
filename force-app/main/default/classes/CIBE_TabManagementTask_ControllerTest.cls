/**********************************************************************************************************************
Name:	  classCIBE_TabManagementTask_ControllerTest
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de cobertura para classCIBE_TabManagementTask_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US420186    	Jose Maria	  	    20/10/2021		Init version copy retail methods 
	1.1 		US592987		Ángel Medina		21/06/2023		Changed AV_Query to SOQL queries
	1.2 		DE77150 		Lucia				29/06/2023		Modificado los metodos validateHGM, validateHGM2 y poner el runAs 
	1.3			US585878		Bea					28/09/2023		Added getGestionable() method
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_TabManagementTask_ControllerTest {

	/**
	 * Create Task
	 */
	@TestSetup
	static void setup() {
		
        User us = CIBE_TestHelper.createUser('CIBE_Gestor');
		System.runAs(new User(Id = UserInfo.getUserId())) {
			List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS};
			List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
			List<PermissionSet> perSet = [SELECT Id FROM PermissionSet WHERE Name =:listPermissionsSet];
			for(PermissionSet ps: perSet){
				PermissionSetAssignment pa = new PermissionSetAssignment(AssigneeId = us.Id, PermissionSetId = ps.Id);
				permissionSetList.add(pa);
			}
			insert permissionSetList;	
		}
		
		List<Task> listaTareas = new List<Task>();

		Task tareaAC = CIBE_TestHelper.createTareaOtherExternalID(us);
		RecordType rtAcc = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        Account acc = new Account(
            Name = 'Name',
            RecordTypeId = rtAcc.Id,
            AV_NumPerso__c = '9123459',
            AV_Negocio__c = 'CIB',
			OwnerId = us.Id
        );
        insert acc;
		Contact contactAux = CIBE_TestHelper.createRepresentante(null, us, '000000000');
		Task experiencia = CIBE_TestHelper.createTareaExternalIdWithCustomerExp(us,'01928374', acc);
		experiencia.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_CIB_RT).Id;
		experiencia.Status='Closed';
		experiencia.AV_Valor1__c = 'Momento - Visita All-in-one';
		experiencia.AV_SurveyValue__c = 14;
		experiencia.OwnerId = us.Id;

		listaTareas.add(experiencia);
		//Database.update(experiencia);
		CBK_Activity_Extension__c actExt = new CBK_Activity_Extension__c();
		actExt.AV_AccionesARealizar__c = 'OECP';
		actExt.AV_ActivityId__c = experiencia.Id;
		Database.insert(actExt);
        
		RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_CIB_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Prueba';
		if (us!=null){
			tarea.OwnerId = us.Id;
		}else{
			tarea.OwnerId = UserInfo.getUserId();
		}		
		tarea.Status = 'Pendiente no localizado';
		tarea.Priority = 'Normal';
		//tarea.AV_ExternalID__c = '01928363';
		tarea.RecordTypeId = rt.Id;
		tarea.ActivityDate = System.today()-3;

		listaTareas.add(tarea);
		//insert tarea;
		// WHERE DeveloperName = 'CIBE_MisClientesEMP'
		AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition LIMIT 1];        
		UserAppInfo app = new UserAppInfo(AppDefinitionId = appDefinition.DurableId, UserId = UserInfo.getUserId(), FormFactor = 'Small');

		Database.insert(app);

		RecordType rt2 = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_CIB_RT);
		Task tareaNoGest  = new Task();
		tareaNoGest.Subject = 'Prueba';
		if (us!=null){			
			tareaNoGest.OwnerId = us.Id;
			System.debug('@@@Entra en el if y el Owner de la tarea es : ' + tareaNoGest.OwnerId);
		}else{
			tareaNoGest.OwnerId = UserInfo.getUserId();
			System.debug('@@@Entra en el else y el Owner de la tarea es : ' + tareaNoGest.OwnerId);
		}	
		//tareaNoGest.OwnerId = us.Id;	
		tareaNoGest.Status = 'Pendiente no localizado';
		tareaNoGest.Priority = 'Normal';
		tareaNoGest.RecordTypeId = rt2.Id;
		tareaNoGest.ActivityDate = System.today();
		tareaNoGest.AV_NoGestionable__c = true;
		// Task tareaNoGest = CIBE_TestHelper.createTareaOtherExternalID(us);
		// tareaNoGest.AV_NoGestionable__c = true;
		System.debug('@@@Owner de tareaNoGest antes del upsert: ' + tareaNoGest.OwnerId);
		listaTareas.add(tareaNoGest);
		upsert listaTareas;
		
	
	}
    
    @isTest
	public static void validateUpdateTask() {
		String result;
		Test.startTest();
		Task tarea = [SELECT Id, Description, OwnerId FROM Task WHERE Subject = 'Llamada Saliente' AND Status = :CIBE_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];
		Date todaysDate = system.today();
		Contact cnt = [SELECT ID FROM CONTACT LIMIT 1];
		System.runAs(owner) {
			result = CIBE_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva','VLD',todaysDate,'Prueba updateTask',null,null,null,cnt.Id, todaysDate, true);
		}
		List<Task> tareaActualizada = [SELECT Id,Status,AV_Tipo__C,Description FROM Task WHERE Id = :tarea.Id];
		
		
		System.assertEquals('OK', result);
		System.assertEquals('Gestionada positiva',tareaActualizada[0].Status);
		System.assertEquals('VLD',tareaActualizada[0].AV_Tipo__c);
		System.assertEquals(todaysDate.format()+' - Prueba updateTask', tareaActualizada[0].Description);

		
		Test.stopTest();
	}

	@isTest
	public static void validateUpdateTaskExperiencia() {

		Task exp = [SELECT Id,Description,OwnerId FROM Task WHERE AV_ExternalID__c = '01928374' ];
		Date todaysDate = system.today();
		//User owner = [SELECT Id FROM User WHERE Id = :exp.OwnerId];
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' AND Profile.Name = :CIBE_AppConstants.CIBE_GESTOR AND CreatedById =:UserInfo.getUserId() ];
		Test.startTest();
		Contact ownerCnt = [SELECT Id FROM Contact LIMIT 1];
		System.runAs(gestor) {
			CIBE_TabManagementTask_Controller.updateTask(exp.id,'Gestionada positiva','VLD',todaysDate,'Prueba updateTask con exp cliente','OECP','MO','P',ownerCnt.Id, todaysDate, true);
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
	public static void validateUpdateTaskOtros() {
		String result;
		Test.startTest();
		Task tarea = [SELECT Id, Description, OwnerId FROM Task WHERE Subject = 'Llamada Saliente' AND Status = :CIBE_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL LIMIT 1];
		tarea.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_CIB_RT).Id;
		Database.update(tarea);
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];
		Date todaysDate = system.today();
		Contact cnt = [SELECT ID FROM CONTACT LIMIT 1];

		System.runAs(owner) {
			result = CIBE_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva','VLD',todaysDate,'Prueba updateTask',null, null, null,cnt.Id, todaysDate, true);
		}
		List<Task> tareaActualizada = [SELECT Id,Status,AV_Tipo__C,Description FROM Task WHERE Id = :tarea.Id];
		CBK_Activity_Extension__c actExt = [SELECT Id, AV_AccionesARealizar__c, AV_MotivoCierreExperienciaCliente__c, AV_ValoracionGestion__c 
											FROM CBK_Activity_Extension__c where AV_ActivityId__c = :tarea.Id LIMIT 1];
		
		System.assertEquals('OK', result);
		System.assertEquals('Gestionada positiva',tareaActualizada[0].Status);
		System.assertEquals('VLD',tareaActualizada[0].AV_Tipo__c);
		System.assertEquals(todaysDate.format()+' - Prueba updateTask', tareaActualizada[0].Description);
		
		tarea.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT).Id;
		Database.update(tarea);
		System.runAs(owner) {
			result = CIBE_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva','VLD',todaysDate,'Prueba updateTask','DCSAM','AT','P',cnt.Id, todaysDate, true);
		}
		
		System.assertEquals('OK', result);
		System.assertEquals('Gestionada positiva',tareaActualizada[0].Status);
		System.assertEquals('VLD',tareaActualizada[0].AV_Tipo__c);
		System.assertEquals(todaysDate.format()+' - Prueba updateTask', tareaActualizada[0].Description);

		Test.stopTest();
	}

    @isTest
	public static void validateUpdateTaskAC() {

		Test.startTest();
        String result;
		// User owner = [
			// SELECT Id
			// FROM User
			// WHERE Id = :UserInfo.getUserId()
		// ];

		User owner = new User();
		owner.Id = UserInfo.getUserId();
		Account centroCaixa = CIBE_TestHelper.createCaixaCenter();
		Contact emplo = CIBE_TestHelper.createEmployee(centroCaixa, owner);
		RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT);
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
		tarea.OwnerId = owner.Id;	
		tarea.Status = 'Pendiente no localizado';
		tarea.Priority = 'Normal';
		tarea.AV_ExternalID__c = '01928888';
		tarea.RecordTypeId = rt.Id;
		tarea.ActivityDate = System.today()-3;
		insert tarea;
		Date todaysDate = system.today();
		String result2;
		System.runAs(owner) {
			result = CIBE_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva','VLD',todaysDate,'Prueba updateTask',null,null,null,emplo.id, todaysDate, true);
			result2 = CIBE_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva','VLD',todaysDate.addDays(5),'Prueba updateTask',null,null,null,emplo.Id, todaysDate, true);
		}
		List<Task> tareaActualizada = [SELECT Id, Status, AV_Tipo__c, Description FROM TASK WHERE Id = :tarea.Id ];
		Test.stopTest();

		System.assertEquals('Gestionada positiva',tareaActualizada[0].Status);
		System.assertEquals('VLD',tareaActualizada[0].AV_Tipo__c);
		System.assertEquals(todaysDate.format()+' - Prueba updateTask', tareaActualizada[0].Description);
		System.assertEquals(Label.AV_ErrorGTDueDate,result2,'Error');
	}

	// @isTest
	// public static void validateupdateTaskReportOpp() {
	// 	Test.startTest();
	// 	Task tarea = (Task) new AV_Query('Task')
	// 								.selectFields('Id, Description, Subject, ownerId, WhatId, ActivityDate')
	// 								.setLimit(1)
	// 								.fetch();
    //     tarea.Status = 'Gestionada positiva';
    //     update tarea;
	// 	Date todaysDate = system.today();
	// 	CIBE_TabManagementTask_Controller.updateTaskReportOpp(tarea.id,tarea.Subject,'VLD', tarea.Description, tarea.ActivityDate, tarea.OwnerId, tarea.WhatId,null);
	// 	List<Task> tareaActualizada = new AV_Query('Task')
	// 								.selectFields('Id, Status, AV_Tipo__c, Description')
	// 								.addConditionEq('Id',tarea.id)
	// 								.run();
	// 	Test.stopTest();
		
	// 	System.assertEquals('Gestionada positiva',tareaActualizada[0].Status);
	// 	System.assertEquals('VLD',tareaActualizada[0].AV_Tipo__c);
	
	// }

	@isTest
	public static void validateUpdateTaskNotLocated() {
		Task tarea = [SELECT Id, Description, OwnerId FROM Task LIMIT 1];
		Date todaysDate = system.today();
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];
		System.runAs(owner) {
		Test.startTest();
		CIBE_TabManagementTask_Controller.updateTaskNotLocated(tarea.id,'Pendiente no localizado','VLD',todaysDate,'Prueba updateTaskNotLocated');
		Test.stopTest();
		List<Task> tareaActualizada = [SELECT Id, Status, AV_Tipo__c, Description FROM Task WHERE Id = :tarea.id];
		System.assertEquals('Pendiente no localizado',tareaActualizada[0].Status);
		System.assertEquals('VLD',tareaActualizada[0].AV_Tipo__c);
		System.assertEquals(todaysDate.format()+' - Prueba updateTaskNotLocated', tareaActualizada[0].Description);
	}
	}
    
    @isTest
	public static void validateUpdateTaskReminder() {
		Test.startTest();
		Task tarea = [SELECT Id, OwnerId, Description FROM Task LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];
		System.runAs(owner) {
		Datetime currentDateTime = Datetime.now().addSeconds(10); // tolerancia añadida para cuando se llame a updateTaskReminder
		CIBE_TabManagementTask_Controller.updateTaskReminder(tarea.id,currentDateTime,'Prueba updateTaskReminder');
		List<Task> tareaActualizada = [SELECT Id, ReminderDateTime, IsReminderSet, Description FROM Task WHERE Id = :tarea.id];
		Test.stopTest();

		System.assertEquals(true,tareaActualizada[0].IsReminderSet);
		System.assertEquals(currentDateTime,tareaActualizada[0].ReminderDateTime);
		System.assertEquals(currentDateTime.date().format() + ' - Prueba updateTaskReminder', tareaActualizada[0].Description);
	}
	}
    
    @isTest
	public static void validateGetRecordType() {
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' AND Profile.Name = :CIBE_AppConstants.CIBE_GESTOR AND CreatedById =:UserInfo.getUserId() ];
		Test.startTest();
		SObject tarea = [SELECT Id FROM Task LIMIT 1];
		System.runAs(gestor) {
		Datetime currentDateTime = Datetime.now();
		String recordType = CIBE_TabManagementTask_Controller.getRecordType(tarea.id);
		Test.stopTest();
		System.assertEquals('CIBE_AlertaComercialCIB',recordType);
	}
	}
    
    @isTest
    public static void getRecordTypeTestWithoutIdCorrect(){
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' AND Profile.Name = :CIBE_AppConstants.CIBE_GESTOR AND CreatedById =:UserInfo.getUserId() ];
		System.runAs(gestor) {

        Test.startTest();
        String idFail = 'FAIL'; 
		String results = null;
		try {
			results=CIBE_TabManagementTask_Controller.getRecordType(idFail);
		}catch(Exception e){
			results = 'Controled Fail';
		}
        Test.stopTest(); 
        System.assertEquals('Controled Fail', results);
    }
    }
    
    @isTest
	public static void validateGetManagementHistory() {
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' AND Profile.Name = :CIBE_AppConstants.CIBE_GESTOR AND CreatedById =:UserInfo.getUserId() ];
		System.runAs(gestor) {
		Test.startTest();
		SObject tarea = [SELECT Id FROM Task LIMIT 1];
		System.assertEquals(false,CIBE_TabManagementTask_Controller.getManagementHistory(tarea.id).isEmpty());
        Test.stopTest();
	}
	}
    
    @isTest
	public static void validateGetPickListValuesByRecordTypeId() {
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' AND Profile.Name = :CIBE_AppConstants.CIBE_GESTOR AND CreatedById =:UserInfo.getUserId() ];
		System.runAs(gestor) {

		Test.startTest();
		SObject tarea = [SELECT Id FROM Task LIMIT 1];
		List<Map<String, String>> lista = CIBE_TabManagementTask_Controller.getPickListValuesByRecordTypeId('Task',tarea.id,'AV_Tipo__c','CIBE_TaskTipo');
        Test.stopTest();
        System.assertEquals(false,lista.isEmpty());
	}
	}

	@isTest
	public static void validateGetTaskStatus() {
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' AND Profile.Name = :CIBE_AppConstants.CIBE_GESTOR AND CreatedById =:UserInfo.getUserId() ];
		System.runAs(gestor) {

		SObject tarea = [SELECT Status FROM Task LIMIT 1];
		Test.startTest();
		Task tarea1 = CIBE_TabManagementTask_Controller.getTaskStatus(tarea.id);	
		Test.stopTest();
		
		System.assertEquals(false, String.isEmpty(tarea1.Status));
	}
    
	}
    
	@isTest
	public static void validateGetExperienciaClientData() {
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' AND Profile.Name = :CIBE_AppConstants.CIBE_GESTOR AND CreatedById =:UserInfo.getUserId() ];
		System.runAs(gestor) {
		
		Task exp = [SELECT Id,Description FROM Task WHERE AV_ExternalID__c = '01928374' ];

		Test.startTest();
		CIBE_TabManagementTask_Controller.ExpClienteDataWrapper result = CIBE_TabManagementTask_Controller.getExperienciaClienteData(exp.Id);
		Test.stopTest();

		System.assertNotEquals(result, null, 'Empty experiencia cliente');
	}
	}



	@isTest
	public static void validateShowAssingPurse(){
		Task tarea = [SELECT Id, OwnerId FROM Task LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];
		System.runAs(owner) {
		// Task tarea = (Task) new AV_Query('Task')
		// 							.selectField('Id')
		// 							.fetch();
		CBK_Activity_Extension__c tareaExtension = [SELECT AV_StatusCodeAPI__c FROM CBK_Activity_Extension__c];
		// CBK_Activity_Extension__c tareaExtension=(CBK_Activity_Extension__c)new AV_Query('CBK_Activity_Extension__c')
		// 							.selectFields('AV_StatusCodeAPI__c')
		// 							//.addConditionEq('AV_ActivityId__c', tarea.Id)
		// 							.fetch();
		tareaExtension.AV_ReasignarCartera_Id_Task__c = tarea.Id;
		tareaExtension.AV_StatusCodeAPI__c = '200';
		Database.update(tareaExtension);
		Test.startTest();
		Boolean result =  CIBE_TabManagementTask_Controller.showAssignPurse(tarea.Id);
		Test.stopTest();
		System.assertEquals(false, result, 'StatusCode distinto 200');
		}

	}
    
    @isTest
    public static void getContactTestWithAccountId(){
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' AND Profile.Name = :CIBE_AppConstants.CIBE_GESTOR AND CreatedById =:UserInfo.getUserId() ];
		System.runAs(gestor) {
        Test.startTest();   
        String searchTerm = '';
        List<Task> taskId = [SELECT id From Task LIMIT 10];
        List<String> selectedIds = new List<String>();     
        for(Task auxId : taskId){
            selectedIds.add(auxId.id);
        }
        Account accountAux = [SELECT Id FROM Account Limit 1];
        String accountId = accountAux.Id;
        List<AV_LookupSearchResult> results =CIBE_TabManagementTask_Controller.getContact(searchTerm, selectedIds, accountId);
      	Test.stopTest();      
       	System.assertNotEquals(null, results);
    }
    }
    
    @isTest
    public static void getContactTestWithoutAccountId(){
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' AND Profile.Name = :CIBE_AppConstants.CIBE_GESTOR AND CreatedById =:UserInfo.getUserId() ];
		System.runAs(gestor) {
        Test.startTest();   
        String searchTerm = '';
        List<String> selectedIds = new List<String>();     
        Account accountAux = [SELECT Id FROM Account Limit 1];
        String accountId = accountAux.Id;
        List<AV_LookupSearchResult> results =CIBE_TabManagementTask_Controller.getContact(searchTerm, selectedIds, accountId);
      	Test.stopTest();      
       	System.assertNotEquals(null, results);
    }
    }
    
    @isTest
    public static void getContactTaskTest(){        
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' AND Profile.Name = :CIBE_AppConstants.CIBE_GESTOR AND CreatedById =:UserInfo.getUserId() ];
		System.runAs(gestor) {

        Test.startTest();       
        Task taskAux = [SELECT Id FROM task LIMIT 1];
        String idRecords = taskAux.Id;
        Task results =CIBE_TabManagementTask_Controller.getContactTask(idRecords);
      	Test.stopTest();      
       	System.assertNotEquals(null, results);
	}
	}
    
    @isTest
    public static void acccountClienteTest(){
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' AND Profile.Name = :CIBE_AppConstants.CIBE_GESTOR AND CreatedById =:UserInfo.getUserId() ];
		System.runAs(gestor) {
        Test.startTest();
        Account acc = [SELECT Id, RecordType.DeveloperName FROM Account  LIMIT 1];
        acc.RecordType.DeveloperName = 'CC_Cliente';
        String accountId = acc.Id;        
        Boolean results=CIBE_TabManagementTask_Controller.acccountCliente(accountId);
        Test.stopTest(); 
        System.assertNotEquals(null, results);
	}
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
			String results=CIBE_TabManagementTask_Controller.insertOrUpdateActivityExt(taskId, acciones, motivo, valoracion);
			System.assertNotEquals(null, results);
		}
        Test.stopTest(); 
    }
    
    @isTest
    public static void insertOrUpdateActivityExtJsonTest(){
        Test.startTest();
        Task taskAux = [SELECT Id, OwnerId FROM task LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :taskAux.OwnerId];
        String taskId =  taskAux.Id;
        String jsonEncuesta;      
        String estadoEncuenta;
		system.runAs(owner){  
        String results=CIBE_TabManagementTask_Controller.insertOrUpdateActivityExt(taskId, jsonEncuesta, estadoEncuenta, '');
        Test.stopTest(); 
        System.assertNotEquals(null, results);
		}
        
    }
    
    @isTest
    public static void showAssignPurseTest(){
        // Test.startTest();
        // Task taskAux = [SELECT Id FROM task LIMIT 1];
        // String taskId =  taskAux.Id;

        // Boolean results=CIBE_TabManagementTask_Controller.showAssignPurse(taskId);
        // Test.stopTest(); 
        // System.assertNotEquals(false, results);

		Task tarea = [SELECT Id,OwnerId FROM Task WHERE AV_ExternalID__C = '01928374'];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];
        CBK_Activity_Extension__c tareaExtension = [SELECT AV_StatusCodeAPI__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :tarea.Id ];
		tareaExtension.AV_ReasignarCartera_Id_Task__c = tarea.Id;
		tareaExtension.AV_StatusCodeAPI__c = '200';
		Database.update(tareaExtension);
		system.runAs(owner){
			Test.startTest();
			Boolean result =  CIBE_TabManagementTask_Controller.showAssignPurse(tarea.Id);
			Test.stopTest();
			System.assertEquals(false, result, 'StatusCode distinto 200');
		}
        
    }

	@isTest
	public static void insertEventRelatedToTaskTestTipe0(){
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));

		String result;
		Date todaysDate = system.today();
	
		Task tarea = [SELECT Id,Subject,Description,OwnerId,AccountId FROM TASK WHERE Status = :CIBE_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];
		Contact cnt = CIBE_TestHelper.createEmployee(null,owner);
		Account center = [SELECT ID FROM ACCOUNT WHERE RECORDTYPE.DeveloperName = :CIBE_AppConstants.ACCOUNT_CLIENTE_RT LIMIT 1];
		tarea.whatId = center.Id;
		update tarea;
		System.runAs(owner){
			result = CIBE_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva','VLD',todaysDate,'Prueba updateTask',null,null,null,tarea.AccountId, todaysDate, false);
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
	
		Task tarea = [SELECT Id,Subject,Description,OwnerId,AccountId,AV_Task__c FROM TASK WHERE Status = :CIBE_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId LIMIT 1];
		System.runAs(owner){
		insert new AV_CustomActivityOpportunity__c( AV_Task__c = tarea.AV_Task__C);
		Contact cnt = CIBE_TestHelper.createEmployee(null,owner);
		Account center = [SELECT ID FROM ACCOUNT WHERE RECORDTYPE.DeveloperName = :CIBE_AppConstants.ACCOUNT_CLIENTE_RT LIMIT 1];
		tarea.whatId = center.Id;
		update tarea;
		result = CIBE_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva','VLD',todaysDate,'Prueba updateTask',null,null,null,tarea.AccountId, todaysDate, false);
		List<Event> retrieveEvents = [SELECT Id FROM EVENT WHERE Subject = :tarea.Subject ];
		Test.stopTest();
		System.assert(!retrieveEvents.isEmpty());
		}

	}

	@isTest
	public static void insertEventRelatedToTaskTestTipeVisita(){

		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));

		String result;
		Date todaysDate = system.today();
	
		Task tarea = [SELECT Id,Subject,Description,OwnerId,AccountId,AV_Task__c FROM TASK WHERE Status = :CIBE_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId LIMIT 1];
		System.runAs(owner){

		insert new AV_CustomActivityOpportunity__c( AV_Task__c = tarea.AV_Task__C);
		Contact cnt = CIBE_TestHelper.createEmployee(null,owner);
		Account center = [SELECT ID FROM ACCOUNT WHERE RECORDTYPE.DeveloperName = :CIBE_AppConstants.ACCOUNT_CLIENTE_RT LIMIT 1];
		tarea.whatId = center.Id;
		update tarea;
		result = CIBE_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva','VLD',todaysDate,'Prueba updateTask',null,null,null,tarea.AccountId, todaysDate, false);
		List<Event> retrieveEvents = [SELECT Id FROM EVENT Where Subject = :tarea.Subject ];
		Test.stopTest();
		System.assert(!retrieveEvents.isEmpty());
		}

	}

	@isTest
	public static void insertEventRelatedToTaskTestTipe2(){

		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));

		String result;
		Date todaysDate = system.today();
	
		Task tarea = [SELECT Id,Subject,Description,OwnerId,AccountId FROM TASK WHERE Status = :CIBE_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL LIMIT 1];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId LIMIT 1];
		System.runAs(owner){

		Contact cnt = CIBE_TestHelper.createEmployee(null,owner);
		Account center = [SELECT ID FROM ACCOUNT WHERE RECORDTYPE.DeveloperName = :CIBE_AppConstants.ACCOUNT_CLIENTE_RT LIMIT 1];
		tarea.whatId = center.Id;
		update tarea;
		result = CIBE_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva','VLD',todaysDate,'Prueba updateTask',null,null,null,tarea.AccountId, todaysDate, false);
		List<Event> retrieveEvents = [SELECT Id FROM EVENT Where Subject = :tarea.Subject ];
		Test.stopTest();
		System.assert(!retrieveEvents.isEmpty());
		}

	}

	@isTest
	public static void validateHGM(){
        Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('HGMCUSTOMER', 'OK'));

		Task tarea = [SELECT Id, OwnerId FROM Task WHERE AV_ExternalID__C = '01928374'];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId LIMIT 1];
		System.runAs(owner){

		Account clientePA = AV_TestHelper.createCustomer();
		clientePA.AV_NumPerso__c = null;
		update clientePA;
		tarea.WhatId = clientePA.Id;
		update tarea;

		Date todaysDate = System.today();
		String result = CIBE_TabManagementTask_Controller.validateHGM(tarea.Id, todaysDate);
		System.assertNotEquals(null, result);
		Test.stopTest();
	}
	}

	@isTest
	public static void validateHGM2(){
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('HGMCUSTOMER', 'OK'));
		RecordType rtContact = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.CONTACT_APODERADO_RT);
		Task tarea = [SELECT Id, OwnerId FROM Task WHERE AV_ExternalID__C = '01928374'];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId LIMIT 1];
		System.runAs(owner){
			Test.startTest();
			Account cliente = [SELECT ID FROM ACCOUNT WHERE RECORDTYPE.DeveloperName = :CIBE_AppConstants.ACCOUNT_CLIENTE_RT LIMIT 1];
			Contact employee = new Contact();
			employee.RecordTypeId = rtContact.Id;
			employee.FirstName = 'Empleado';
			employee.LastName = '1';
			employee.CC_Idioma__c = 'es';
			employee.CC_Matricula__c = '71234567';
			employee.AccountId = cliente.Id;
			employee.AV_UsuarioAsociado__c = owner.Id;
			employee.OwnerId = owner.Id;
			insert employee;

			tarea.CC_Empleado_Gestor__c = employee.Id;
		tarea.WhatId = cliente.Id;
		update tarea;

		Date todaysDate = System.today();
		String result = CIBE_TabManagementTask_Controller.validateHGM(tarea.Id, todaysDate);
		System.assertNotEquals(null, result);
		Test.stopTest(); 
	}
}

@isTest
	public static void getGestionable() {
		Task tareaNoG = [SELECT Id, AV_NoGestionable__c, OwnerId FROM Task WHERE AV_NoGestionable__c = true LIMIT 1];
		System.debug('@@@Owner de tareaNoG' + tareaNoG.OwnerId);
		User owner = [SELECT Id FROM User WHERE Id = :tareaNoG.OwnerId LIMIT 1];
		System.runAs(owner){
			Boolean result = CIBE_TabManagementTask_Controller.getNoGestionable(tareaNoG.Id);
			System.assertEquals(true, result);
		}
	}
	
}