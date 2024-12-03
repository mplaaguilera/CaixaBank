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
		
		List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP, CIBE_AppConstants.USER_AV_AVOIDBULKAPI};
        
        CIBE_TestInitialSetup.setupInitialData(null, null, null, null, null, ps);

        User admin = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        User us = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];

		Test.startTest();
		List<Task> listaTareas = new List<Task>();

// Alerta comercial
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
		// Contact contactAux = CIBE_TestHelper.createRepresentante(null, us, '000000000');

// Experiecia Cliente CIB
		Task experienciaCIB = CIBE_TestHelper.createTareaExternalIdWithCustomerExp(us,'01928374', acc);
			experienciaCIB.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_CIB_RT).Id;
			experienciaCIB.Status='Gestionada positiva';
			experienciaCIB.AV_Valor1__c = 'Momento - Visita All-in-one';
			experienciaCIB.AV_SurveyValue__c = 14;
			experienciaCIB.OwnerId = us.Id;
		listaTareas.add(experienciaCIB);

		CBK_Activity_Extension__c actExtExpCib = new CBK_Activity_Extension__c();
			actExtExpCib.AV_AccionesARealizar__c = 'OECP';
			actExtExpCib.AV_ActivityId__c = experienciaCIB.Id;
		Database.insert(actExtExpCib);


// Experiecia Cliente EMP
		Task experienciaEMP = CIBE_TestHelper.createTareaExternalIdWithCustomerExp(us,'01928333', acc);
			experienciaEMP.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_EMP_RT).Id;
			experienciaEMP.Status='Closed';
			experienciaEMP.AV_Valor1__c = 'Momento - Visita All-in-one';
			experienciaEMP.AV_SurveyValue__c = 14;
			experienciaEMP.OwnerId = us.Id;
		listaTareas.add(experienciaEMP);


		CBK_Activity_Extension__c actExtExpEmp = new CBK_Activity_Extension__c();
			actExtExpEmp.AV_AccionesARealizar__c = 'OECP';
			actExtExpEmp.AV_ActivityId__c = experienciaEMP.Id;
		Database.insert(actExtExpEmp);
		
// Otros CIB
		RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_CIB_RT);
		Task tareaOtrosCIB  = new Task();
			tareaOtrosCIB.Subject = 'Prueba';
			tareaOtrosCIB.OwnerId = us.Id;
			tareaOtrosCIB.Status = 'Pendiente no localizado';
			tareaOtrosCIB.Priority = 'Normal';
			tareaOtrosCIB.RecordTypeId = rt.Id;
			tareaOtrosCIB.ActivityDate = System.today()-3;
		listaTareas.add(tareaOtrosCIB);
		
		AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition LIMIT 1];        
		UserAppInfo app = new UserAppInfo(AppDefinitionId = appDefinition.DurableId, UserId = admin.Id, FormFactor = 'Small');
		Database.insert(app);

// Otros EMP
		RecordType rt2 = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);
		Task tareaOtrosEMP  = new Task();
			tareaOtrosEMP.Subject = 'Prueba';
			if (us!=null){			
				tareaOtrosEMP.OwnerId = us.Id;
			}else{
				tareaOtrosEMP.OwnerId = admin.Id;
			}	
			tareaOtrosEMP.Status = 'Pendiente no localizado';
			tareaOtrosEMP.Priority = 'Normal';
			tareaOtrosEMP.RecordTypeId = rt2.Id;
			tareaOtrosEMP.ActivityDate = System.today();
			tareaOtrosEMP.AV_NoGestionable__c = true;
		listaTareas.add(tareaOtrosEMP);
		
		upsert listaTareas;
		Test.stopTest();
	
	}
    
    @isTest
	public static void validateUpdateTask() {
		String result;
		User us = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
		Date todaysDate = system.today();
		Test.startTest();
		System.runAs(us) {
			Task tarea = [SELECT Id, Description, OwnerId FROM Task WHERE Subject = 'Llamada Saliente' AND Status = :CIBE_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL LIMIT 1];
			Contact cnt = [SELECT ID FROM CONTACT LIMIT 1];
			result = CIBE_TabManagementTask_Controller.updateTask(tarea.id,'Completed','VLD',todaysDate,'Prueba updateTask',null,null,null,cnt.Id, todaysDate, true);
		
		List<Task> tareaActualizada = [SELECT Id,Status,AV_Tipo__C,Description FROM Task WHERE Id = :tarea.Id];
		
		System.assertEquals('OK', result);
		System.assertEquals('Completed',tareaActualizada[0].Status);
		System.assertEquals('VLD',tareaActualizada[0].AV_Tipo__c);
		System.assertEquals(todaysDate.format()+' - Prueba updateTask', tareaActualizada[0].Description);

		
		Test.stopTest();
		}
	}

	@isTest
	public static void validateUpdateTaskExperienciaCIB() {

		User us = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];		
		Date todaysDate = system.today();
		Test.startTest();
		System.runAs(us) {
			Task tarea = [SELECT Id,Description,OwnerId FROM Task WHERE AV_ExternalID__c = '01928374' AND RecordType.DeveloperName = : CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_CIB_RT LIMIT 1];
			Contact ownerCnt = [SELECT ID FROM CONTACT LIMIT 1];
			CIBE_TabManagementTask_Controller.updateTask(tarea.id,'Pendiente','VLD',todaysDate,'Prueba updateTask','OECP', 'MO', 'P',ownerCnt.Id, todaysDate, true);
		
		
		List<Task> tareaActualizada = [SELECT Id, Status, AV_Tipo__c, Description FROM Task WHERE Id = :tarea.Id ];
		CBK_Activity_Extension__c actExt = [SELECT Id, AV_AccionesARealizar__c, AV_MotivoCierreExperienciaCliente__c, AV_ValoracionGestion__c 
												FROM CBK_Activity_Extension__c where AV_ActivityId__c = :tarea.Id LIMIT 1];
		System.assertEquals('Pendiente',tareaActualizada[0].Status);
		System.assertEquals('VLD',tareaActualizada[0].AV_Tipo__c);
		System.assertEquals('OECP',actExt.AV_AccionesARealizar__c);
		System.assertEquals('MO',actExt.AV_MotivoCierreExperienciaCliente__c);
		System.assertEquals('P',actExt.AV_ValoracionGestion__c);
		Test.stopTest();
		}
	}

	@isTest
	public static void validateUpdateTaskExperienciaEMP() {

		String result;
		User us = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
		Date todaysDate = system.today();
		Test.startTest();
		System.runAs(us) {
			Task tarea = [SELECT Id, Description, OwnerId FROM Task WHERE AV_ExternalID__c = '01928333' AND RecordType.DeveloperName = :CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_EMP_RT LIMIT 1];
			
			Contact cnt = [SELECT ID FROM CONTACT LIMIT 1];
			result = CIBE_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva','VLD',todaysDate,'Prueba updateTask','OECP', 'MO', 'P',cnt.Id, todaysDate, true);
		
		List<Task> tareaActualizada = [SELECT Id,Status,AV_Tipo__C,Description FROM Task WHERE Id = :tarea.Id];

		CBK_Activity_Extension__c actExt = [SELECT Id, AV_AccionesARealizar__c, AV_MotivoCierreExperienciaCliente__c, AV_ValoracionGestion__c 
												FROM CBK_Activity_Extension__c where AV_ActivityId__c = :tarea.Id LIMIT 1];
		
		System.assertEquals('Gestionada positiva',tareaActualizada[0].Status);
		System.assertEquals('VLD',tareaActualizada[0].AV_Tipo__c);
		System.assertEquals('OECP',actExt.AV_AccionesARealizar__c);
		System.assertEquals('MO',actExt.AV_MotivoCierreExperienciaCliente__c);
		System.assertEquals('P',actExt.AV_ValoracionGestion__c);
		Test.stopTest();
		}
		
		
	}

    @isTest
	public static void validateUpdateTaskAC() {

		Test.startTest();
        String result;
		User us = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
		Date todaysDate = system.today();
				
		System.runAs(us) {
			Contact cnt = [SELECT ID FROM CONTACT LIMIT 1];

			Task tarea = [SELECT Id, Description, OwnerId FROM Task WHERE Subject = 'Llamada Saliente' AND RecordType.Developername = :CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT
				AND Status = 'Pendiente no localizado' LIMIT 1];
			result = CIBE_TabManagementTask_Controller.updateTask(tarea.id,'Pendiente','ESE',todaysDate, 'Prueba updateTask','OECP', 'MO', 'P',cnt.Id, todaysDate, true);
		
		List<Task> tareaActualizada = [SELECT Id, Status, AV_Tipo__c FROM TASK WHERE Id = :tarea.Id ];
		
		System.assertEquals('Pendiente',tareaActualizada[0].Status);
		System.assertEquals('ESE',tareaActualizada[0].AV_Tipo__c);
		Test.stopTest();
		}
	}

	@isTest
	public static void validateUpdateTaskACError() {

		Test.startTest();
        String result;
		User owner = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		Account centroCaixa = CIBE_TestHelper.createCaixaCenter();
		Contact emplo = CIBE_TestHelper.createEmployee(centroCaixa, owner);
		Task tarea = [SELECT Id, Description, OwnerId FROM Task WHERE Subject = 'Llamada Saliente' AND RecordType.Developername = :CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT LIMIT 1];
		Date todaysDate = system.today();
		
		System.runAs(owner) {
			result = CIBE_TabManagementTask_Controller.updateTask(tarea.id,'Completada','VLD',todaysDate.addDays(5),'Prueba updateTask',null,null,null,emplo.Id, todaysDate, true);
		}
		List<Task> tareaActualizada2 = [SELECT Id, Status FROM TASK WHERE Id = :tarea.Id ];
		Test.stopTest();
		System.assertEquals('Pendiente no localizado',tareaActualizada2[0].Status);
		// System.assertEquals(todaysDate.format()+' - Prueba updateTask', tareaActualizada[0].Description);
		System.assertEquals(Label.AV_ErrorGTDueDate,result);
	}

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
    public static void getRecordTypeTestWithoutIdCorrect(){
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
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
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		System.runAs(gestor) {
			Test.startTest();
				SObject tarea = [SELECT Id FROM Task LIMIT 1];
				System.assertEquals(false,CIBE_TabManagementTask_Controller.getManagementHistory(tarea.id).isEmpty());
			Test.stopTest();
		}
	}
    
    @isTest
	public static void validateGetPickListValuesByRecordTypeId() {
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
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
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
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
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
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
			CBK_Activity_Extension__c tareaExtension = [SELECT AV_StatusCodeAPI__c FROM CBK_Activity_Extension__c LIMIT 1];

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
    public static void getContactTaskTest(){        
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
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
    public static void accountClienteTest(){
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
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
		System.runAs(owner){  
			String results=CIBE_TabManagementTask_Controller.insertOrUpdateActivityExt(taskId, jsonEncuesta, estadoEncuenta, '');
			Test.stopTest(); 
			System.assertNotEquals(null, results);
		}
    }
    
    @isTest
    public static void showAssignPurseTest(){
		Task tarea = [SELECT Id,OwnerId FROM Task WHERE AV_ExternalID__C = '01928374'];
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];
        CBK_Activity_Extension__c tareaExtension = [SELECT AV_StatusCodeAPI__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :tarea.Id ];
		tareaExtension.AV_ReasignarCartera_Id_Task__c = tarea.Id;
		tareaExtension.AV_StatusCodeAPI__c = '200';
		Database.update(tareaExtension);
		System.runAs(owner){
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
		User owner = [SELECT Id FROM User WHERE Id = :tarea.OwnerId];
		insert new AV_CustomActivityOpportunity__c( AV_Task__c = tarea.AV_Task__C);
		Contact cnt = CIBE_TestHelper.createEmployee(null,owner);
		Account center = [SELECT ID FROM ACCOUNT WHERE RECORDTYPE.DeveloperName = :CIBE_AppConstants.ACCOUNT_CLIENTE_RT LIMIT 1];
		tarea.whatId = center.Id;
		update tarea;
		System.runAs(owner){
			result = CIBE_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva','VLD',todaysDate,'Prueba updateTask',null,null,null,tarea.AccountId, todaysDate, false);
		}
		List<Event> retrieveEvents = [SELECT Id FROM EVENT WHERE Subject = :tarea.Subject ];
		Test.stopTest();
		System.assert(!retrieveEvents.isEmpty());
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

			Account clientePA = CIBE_TestHelper.createCustomer();
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
		User owner = [SELECT Id FROM User WHERE Id = :tareaNoG.OwnerId LIMIT 1];
		System.runAs(owner){
			Boolean result = CIBE_TabManagementTask_Controller.getNoGestionable(tareaNoG.Id);
			System.assertEquals(true, result);
		}
	}


	@isTest
	public static void validateGetPickListValuesByRecordTypeId2() {
		User gestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		System.runAs(gestor) {
			Test.startTest();
				SObject tarea = [SELECT Id FROM Task LIMIT 1];
				List<Map<String, String>> lista = CIBE_TabManagementTask_Controller.getPickListValuesByRecordTypeId2('Task',tarea.id,'AV_Tipo__c');
			Test.stopTest();
			System.assertEquals(false,lista.isEmpty());
		}
	}


	@isTest
	public static void validateUpdateTaskOtrosCIB() {
		String result;
		User us = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
		Date todaysDate = system.today();
		Test.startTest();
		System.runAs(us) {
			Task tarea = [SELECT Id, Description, OwnerId FROM Task WHERE Subject = 'Prueba' AND RecordType.DeveloperName = :CIBE_AppConstants.TASK_OTROS_CIB_RT LIMIT 1];
			
			Contact cnt = [SELECT ID FROM CONTACT LIMIT 1];
			result = CIBE_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva','VLD',todaysDate,'Prueba updateTask',null, null, null,cnt.Id, todaysDate, true);
		
		List<Task> tareaActualizada = [SELECT Id,Status,AV_Tipo__C,Description FROM Task WHERE Id = :tarea.Id];
		
		System.assertEquals('OK', result);
		System.assertEquals('Gestionada positiva',tareaActualizada[0].Status);
		System.assertEquals('VLD',tareaActualizada[0].AV_Tipo__c);
		System.assertEquals(todaysDate.format()+' - Prueba updateTask', tareaActualizada[0].Description);
		Test.stopTest();
		}
	}

	@isTest
	public static void validateUpdateTaskOtrosEMP() {
		String result;
		User us = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
		Date todaysDate = system.today();
		Test.startTest();
		System.runAs(us) {
			Task tarea = [SELECT Id, Description, OwnerId FROM Task WHERE Subject = 'Prueba' AND RecordType.DeveloperName = :CIBE_AppConstants.TASK_OTROS_EMP_RT LIMIT 1];
			
			Contact cnt = [SELECT ID FROM CONTACT LIMIT 1];
			result = CIBE_TabManagementTask_Controller.updateTask(tarea.id,'Gestionada positiva','VLD',todaysDate,'Prueba updateTask',null, null, null,cnt.Id, todaysDate, true);
		
		List<Task> tareaActualizada = [SELECT Id,Status,AV_Tipo__C,Description FROM Task WHERE Id = :tarea.Id];
		
		System.assertEquals('OK', result);
		System.assertEquals('Gestionada positiva',tareaActualizada[0].Status);
		System.assertEquals('VLD',tareaActualizada[0].AV_Tipo__c);
		System.assertEquals(todaysDate.format()+' - Prueba updateTask', tareaActualizada[0].Description);
		Test.stopTest();
		}
	}

}