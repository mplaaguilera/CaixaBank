/**********************************************************************************************************************
Name:	  AV_TaskTriggerHelper_Test
Copyright © 2019  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_TaskTriggerHelper"
------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Eric Vázquez	   	   08/10/2020		Init version
2.0			Test Class	   Esperanza Conde 	   22/10/2020		Logic to copy contact date into real date
3.0			Test Class	   Eric Vázquez		   30/10/2020		Add test for validate delete Task
3.1			US286825 	   Daniel Rodríguez	   13/01/2022	    Add Method executeTaskTriggerDateOpp
3.2			AV_Query IT	   Daniel Rodríguez	   3/02/2022	    Change AV_Query to SOQL for User and Account
3.3			US302266	   Víctor Santiago	   11/02/2022	    Created method validateCreateManagementHistory
3.4         US339508       Luis Fernández      30/03/2022       Created method validateUpdateCentro
3.5         US310702       Luis Fernández      25/04/2022       Created method validateChangeOwner
3.6			US323785	   Jose María Pérez	   16/05/2022		Created Method calculateScoreTask
3.7         US322355       Luis Fernández      24/05/2022       Modified method validateSetMeetinLocation
3.8         US385253       Víctor Santiago     17/06/2022       Added validateUpdateTareaOpp and score to calculateTaskScore
3.9			Fix			   Patricia Solano 	   08/08/2022		Removed calculateTaskScoreDelete and calculateTaskScore Test
4.0			Quality Cloud  Patricia Solano 	   09/08/2022		Added assertNotEquals for TestValidateTaskOnboardingPositiveClosed Method 
4.1			Fix			   Luis Fernández	   11/08/2022		Added "insertOrUpdateCenterAndRtTest" method
4.2			DE63589		   Sandra Gómez		   01/09/2022		Add new method validateUpdateGCF
4.3			US457715	   Eduardo González	   19/10/2022		Add new method updateSin()
																Modify method updateTareaOpp()
4.4			US481618		Ángel Medina		18/01/2023		Add new method validateRecordChannel()			
4.5 		US464358		Luis Fernández		15/02/2023		Addes new method validateNotifyExperienciaClienteTasks	
4.6 		US592987	   	Laura Marrero		30/05/2023		Changed AV_Query to SOQL queries
4.7			US610044		Luis Fernández		26/06/2023		Added checkOftTypeValidate method	
4.8			PPM100265161	Ángel Medina		18/10/2024		Delete methods updateTareaOpp and validateRecordChannel				
***********************************************************************************************************************/
@isTest
public with sharing class AV_TaskTriggerHelper_Test {
	
	@TestSetup
	static void setup(){
	
        AV_TestHelper.activateLogger();
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;
        User usuInte = [Select Id from User where Profile.Name = 'API Only' and Alias = 'inte' and IsActive = true limit 1];
		Account center;
		System.runAs(usuInte){
            center= AV_TestHelper.createCaixaCenter();
        }

		User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];

		System.runAs(usuCli){
        	Account cliente = AV_TestHelper.createCustomer();     
        }
		Test.startTest();
		System.runAs(usuGcf){
			User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
			userGestor.Email = 'gestor-test@test.com';
			User usrTest = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01543678');
			List<User> listUserInsert = new List<User>();
			listUserInsert.add(userGestor);
			listUserInsert.add(usrTest);
			insert listUserInsert;

			Contact cnt = AV_TestHelper.createEmployee(center,userGestor,'U01545454');
			Account centro = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'CC_CentroCaixaBank' LIMIT 1];
			Contact cont = AV_TestHelper.createEmployee(centro,usrTest,'U01543678');
			AV_TestHelper.insertNeededPermissions(userGestor);
			AV_TestHelper.insertNeededPermissions(usrTest);
			AV_TestHelper.createTarea(usuGcf, System.today());
			
			
			List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
			CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
			listDummyWords.add(word);
			CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
			listDummyWords.add(word2);
			Database.insert(listDummyWords, false);
		}
		Test.stopTest();
	}

	/**
	 * Execute the Trigger class (AV_Task_BI_TRHan) and check if the cabecera-tarea is correct created.
	 */
	@isTest
	public static void executeTaskTrigger() {
		User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		Test.startTest();
		System.runAs(usuGcf){
			Task tarea = [Select Id, AV_ExternalID__c FROM Task Limit 1 ];
			AV_HeaderCustomActivity__c cabeceraTarea = [select AV_ExternalID__c from AV_HeaderCustomActivity__c where AV_ExternalID__c=:tarea.AV_ExternalID__c];
			System.assertEquals(cabeceraTarea.AV_ExternalID__c, tarea.AV_ExternalID__c);
		}
		Test.stopTest();
	}
	
	/**
	 * Execute the Trigger class (AV_Task_BU_TRHan) and check if the EAP Gestor has been modified correctly.
	 */
	@isTest
	public static void executeEventTriggerUpdatingEAPGestor() {
		User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		Task tarea = [Select Id, AV_CodigoGestorAsignado__c FROM Task Limit 1 ];
		Test.startTest();
		System.runAs(usuGcf){
			tarea.AV_CodigoGestorAsignado__c = 'U0009006';
			Database.update(tarea);
			Task cienteUpdated = [select AV_CodigoGestorAsignado__c from Task where Id = :tarea.Id];
			System.assertNotEquals(null, cienteUpdated.AV_CodigoGestorAsignado__c);
		}
		Test.stopTest();
	}
	
	@isTest
	public static void updateTaskToEnterNotifyExperienciaCliTask() {
		User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		User userGestor = [Select Id FROM User WHERE AV_ExternalID__c = 'U01545454'];
		Task tarea =[SELECT Id, RecordTypeId,OwnerId, ActivityDate FROM Task WHERE AV_ExternalID__c = '01928374'];
		CBK_SCH_PendingProcess__c sch = new CBK_SCH_PendingProcess__c();
		sch.ClassName__c = 'AV_NotifyExpCliTaskSchedulable';
		sch.RecordId__c = tarea.id;
		sch.OwnerId = userGestor.id;
		insert sch;
		RecordType rtExpTask = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKEXPCLIENT_RT);
		CBK_ScheduleControls__c scs = new CBK_ScheduleControls__c();
			scs.Name = 'ScheduleInfo';
			scs.Retries__c =3;
			scs.ExecutionPeriod__c = 1;
			insert scs;
		
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKEXPCLIENT_RT);
		List<Task> listTask = new List<Task>();
		Map<Id, Task> mapTaskOld = new Map<Id, task>();
		
		
		mapTaskOld.put(tarea.id, tarea);

		tarea.ownerId = userGestor.id;
		tarea.activityDate = System.today();
		tarea.recordTypeId = rtExpTask.id;
		listTask.add(tarea);
		update listTask;
		Test.startTest();
		System.runAs(userGestor){			
			AV_TaskTriggerHelper.notifyExperienciaCliTask(listTask, mapTaskOld, true);
		}
		Test.stopTest();
		List<Task> tareaUpdate= [SELECT Id FROM Task WHERE OwnerId =:UserGestor.id];
		System.assertNotEquals(tareaUpdate,null,'No se ha encontrado el Id de la tarea');
		
	}

	@isTest
	public static void updateTaskToEnterNotifyExperienciaCliTask2() {
		User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		User userGestor = [Select Id FROM User WHERE AV_ExternalID__c = 'U01545454'];
		Task tarea =[SELECT Id, RecordTypeId,OwnerId, ActivityDate FROM Task WHERE AV_ExternalID__c = '01928374'];
		
		RecordType rtExpTask = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKEXPCLIENT_RT);
		CBK_ScheduleControls__c scs = new CBK_ScheduleControls__c();
			scs.Name = 'ScheduleInfo';
			scs.Retries__c =3;
			scs.ExecutionPeriod__c = 1;
			insert scs;
		
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKEXPCLIENT_RT);
		List<Task> listTask = new List<Task>();
		Map<Id, Task> mapTaskOld = new Map<Id, task>();
		
		
		mapTaskOld.put(tarea.id, tarea);

		tarea.ownerId = userGestor.id;
		tarea.activityDate = System.today();
		tarea.recordTypeId = rtExpTask.id;
		listTask.add(tarea);
		update listTask;
		Test.startTest();
		System.runAs(userGestor){
			AV_TaskTriggerHelper.notifyExperienciaCliTask(listTask, mapTaskOld, true);
		}
		Test.stopTest();
		List<Task> tareaUpdate= [SELECT Id FROM Task WHERE OwnerId =:UserGestor.id];
		System.assertNotEquals(tareaUpdate,null,'No se ha encontrado el Id de la tarea');
		
	}

	 /**
	 * Execute the Trigger class (AV_Task_AU_TRHan, AV_Task_AI_TRHan) and check if task is Positive closed.
	 */
	@isTest
	public static void TestValidateTaskOnboardingPositiveClosed() {
		User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_GESTORES','OK'));
		Account customer = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' AND AV_Negocio__c = 'BPA'];
		Account acc = [SELECT Id FROM Account WHERE Name = '00615 STORE DOS DE MAIG-ROSSELLO' AND CC_Numero_Oficina_Empresa__c = '00615'];

			String labelProfile = 'Standard User';
			List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'' + labelProfile + '\' LIMIT 1');
			String username = AV_TestHelper.getEmail();
			Profile p = (Profile)result.get(0);
			User usuario = new User(
				Alias = 'tsAlias',
				Email = 'test2@test.dev',
				EmailEncodingKey = 'UTF-8',
				LastName = 'testLastName',
				LanguageLocaleKey = 'es',
				LocaleSidKey = 'es',
				TimeZoneSidKey = 'Europe/Berlin',
				ProfileId = p.Id,
				UserName = username,
				AV_ExternalID__c = 'U0009006'
				);
				insert usuario;
		Test.startTest();
		System.runAs(usuGcf){
				Contact empleado = AV_TestHelper.createEmployee(acc,usuario,'U0009006');
				AV_Book__c cartera= new AV_Book__c();
				cartera.Name='100368827';
				cartera.AV_ExternalID__c='U0009006';
				cartera.AV_Negocio__c = 'EMP';
				cartera.AV_Activa__c = 'S';
				insert cartera;
				AV_BookManagementMember__c carteraGestor= new AV_BookManagementMember__c();
				carteraGestor.AV_Cartera__c=cartera.Id;
				carteraGestor.AV_EmpleadoGestor__c=empleado.Id;
				carteraGestor.AV_ExternalID__c='U0009006';
				insert carteraGestor;
				RecordType rt = AV_AppUtilities.getRecordType('Task', 'AV_Onboarding');
				Task tarea  = new Task();
				tarea.Subject = 'Llamada Saliente';
				tarea.OwnerId = usuario.Id;
				tarea.WhatId = customer.Id;		
				tarea.Status = 'Gestionada positiva';
				tarea.Priority = 'Normal';
				tarea.AV_ExternalID__c = 'U0009006';
				tarea.RecordTypeId = rt.Id;
				insert tarea;
			Test.stopTest();
			List<CBK_Activity_Extension__c> cmpTarea = [SELECT AV_ReasignarCartera_JSONAPI__c FROM CBK_Activity_Extension__c WHERE AV_ReasignarCartera_Id_Cliente__c =:customer.Id AND AV_Reasignar_cartera_Owner__c =:usuario.Id];
			System.assertNotEquals(cmpTarea,null,'No se ha encontrado el Id de la tarea');
		}
	}

	/**
	 * Execute the Trigger class (AV_Opportunity_BD_TRHan) and check the OwnerId
	 */
	@isTest
	private static void validateDeleteTaskTest() {
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
		User userGestor = [SELECT Id FROM User WHERE Alias = 'tsAlias' AND AV_ExternalId__c = 'U01545454' LIMIT 1];

		Task task = [SELECT id,  AV_ExternalID__c, ActivityDate FROM Task LIMIT 1];
		task.OwnerId = userGestor.Id;
		update task;
        Test.startTest();
        System.runAs(userGestor){
            delete task;
        }
		Test.stopTest();
        List<Task> taskDeleted = [SELECT id, AV_ExternalID__c, ActivityDate FROM Task LIMIT 1];
        System.assertEquals(0 , taskDeleted.size());
	}
    
    @isTest
	public static void validateCreateCRMTask() {
		User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		Task ta = [SELECT id, Description FROM Task Limit 1];
		ta.Description= 'Prueba comentario 2';
		Test.startTest();
		System.runAs(usuGcf){
			update ta;
			Test.stopTest();
			List<CBK_Activity_Extension__c> comentario = [SELECT id, AV_CommentLastModifiedBy__c, AV_CommentLastModifiedDate__c FROM CBK_Activity_Extension__c WHERE  AV_ActivityId__c = :ta.id];
			System.assertNotEquals(comentario[0].AV_CommentLastModifiedBy__c,null);
			System.assertNotEquals(comentario[0].AV_CommentLastModifiedDate__c,null);
		}
	}
	
	/**
	 * Execute the Trigger class (AV_Task_Au_TRHan) and check if task of the opportunity has change
	 */
	@isTest
	public static void executeTaskTriggerDateOpp() {
		User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		DateTime activityDate = Datetime.newInstance(2020, 6, 4);
		Test.startTest();
		System.runAs(usuGcf){

			Account cliente = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];


			Account centroCaixa = new Account(
				Name = '00615 STORE DOS DE MAIG-ROSSELLO' , CC_Numero_Oficina_Empresa__c = '00615'
			);

			Contact empleado = new Contact(FirstName = 'Empleado',LastName = '1');
            Opportunity opp = AV_TestHelper.createOpportunityExternalId(cliente, empleado, '01928374');
            
			AV_CustomActivityOpportunity__c cusActOpp = AV_TestHelper.createTareaOportunidadExt(opp, '01928374');
			Task tarea  = [Select id from task limit 1];
			tarea.ActivityDate = Date.today();
			Database.update(tarea);
			Test.stopTest();   
			Task tareaUpdate = [SELECT id, ActivityDate FROM Task WHERE id = :tarea.Id];
			System.assertEquals(tarea.ActivityDate, tareaUpdate.ActivityDate);
		}
	}

	@isTest
	public static void validateCreateManagementHistory() {
		User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
		Test.startTest();
		System.runAs(usuGcf){
			Task t = new Task(
				Subject = 'Llamada Saliente',
				OwnerId = u.Id,	
				Status = 'Open',
				Priority = 'Normal',
				AV_ExternalID__c = '01593574628',
				RecordTypeId = rt.Id
			);
			insert t;
			List<AV_ManagementHistory__c> mh = [SELECT Id FROM AV_ManagementHistory__c WHERE AV_ActivityId__c = :t.Id];
			System.assertEquals(true, mh != null, 'Management History not created');
		}
        Test.stopTest();
	}

	@isTest
	public static void validateUpdateCentro(){
		User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		Test.startTest();
		System.runAs(usuGcf){
			User oldOwner = [SELECT Id FROM User LIMIT 1];
			User newOwner = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM User LIMIT 1];
			RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
			Task task = new Task(
			RecordTypeId = rt.Id,
			Subject= 'TestUpdate',
			OwnerId = oldOwner.Id,
			AV_Center__c= null,
			AV_ExternalID__c='TA1234567'
			);
			insert task;
			task.OwnerId= newOwner.Id;
			Database.update(task);
			Test.stopTest();
			String tskId = task.Id;
			Task newCenter = [SELECT AV_Center__c FROM Task WHERE Subject = 'TestUpdate' and Id = :tskId limit 1];
			String newOwnerCenter = newOwner.AV_NumeroOficinaEmpresa__c;
			System.AssertEquals(newCenter.AV_Center__c,newOwnerCenter,'No se ha actualizado el centro');
		}
	}
    
	@isTest 
	public static void validateChangeOwner(){
		User userGFc = [SELECT ID FROM USER WHERE Alias = 'AV-TF9' AND IsActive= true LIMIT 1];
		User userWithNoEap = [SELECT ID FROM USER WHERE ID NOT IN (SELECT AV_UsuarioAsociado__c FROM Contact) LIMIT 1];
		String userGFcId = userGFc.Id;
		Task existentTask = [SELECT ID,OwnerId FROM TASK  LIMIT 1];
		String taskId = existentTask.Id;
		Test.startTest();
		System.runAs(userGFc){
			RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
			Task task = new Task( 
				Subject= 'TestUpdate',
				RecordTypeId = rt.Id,
				OwnerId = userWithNoEap.id,
				AV_ExternalID__c='1111'
				);
			insert task;
			existentTask.OwnerId = userWithNoEap.Id;
			Database.update(existentTask);
			Test.stopTest();
			Task resultInsert = [SELECT ID,OwnerId FROM TASK WHERE AV_ExternalID__c ='1111' AND Subject = 'TestUpdate' LIMIT 1];
			Task resultUpdate = [SELECT ID,OwnerId FROM TASK WHERE Id = :taskId LIMIT 1];
			System.assertEquals(userGFc.Id,resultInsert.OwnerId,'No se ha actualizado el owner en el insert');
			System.assertEquals(userGFc.Id,resultUpdate.OwnerId,'No se ha actualizado el owner en la update');
		}
	}
		
	@isTest
	public static void insertOrUpdateCenterAndRtTest(){
		User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		Test.startTest();
		System.runAs(usuGcf){
			List<sObject> result = [SELECT ID FROM Profile WHERE NAME = 'AV_Usuario_CaixaBank' LIMIT 1];
			String username = AV_TestHelper.getEmail();
			Profile p = (Profile)result.get(0);
			User user = [SELECT Id FROM User LIMIT 1];
			Task tskTest = AV_TestHelper.createTareaOtherExternalID(user);
			Task tskTestRetrieve = [SELECT AV_CenterRtIndex__c,AV_Center__C FROM Task WHERE AV_ExternalId__c = '01928363' LIMIT 1];
			String tskTestCenterRT = tskTestRetrieve.AV_CenterRtIndex__c;
			tskTestRetrieve.AV_Center__c = '04135';
			Database.update(tskTestRetrieve);
			String tskTestCenterRTAfterUdt = [SELECT AV_CenterRtIndex__c FROM Task WHERE AV_ExternalId__c = '01928363' LIMIT 1].AV_CenterRtIndex__c;
			System.assertNotEquals(tskTestCenterRT,tskTestCenterRTAfterUdt,'El campo no se ha actualizado bien');
		}
		Test.stopTest();
	}
    
    @isTest
	public static void validateUpdateGCF(){
		User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		Test.startTest();
		System.runAs(usuGcf){
			Task tareaAntes =[Select Id, Status, AV_ToDelete__c, AV_Tipo__c, Description, AV_Center__c, AV_CodigoGestorAsignado__c, LastModifiedById from Task ];
			Task tareaCambio = tareaAntes;
			tareaCambio.Status = AV_AppConstants.GESTIONADO_POSITIVO_ESTADO;
			tareaCambio.AV_ToDelete__c = true;
				Database.update(tareaCambio);
				tareaCambio.Status = AV_AppConstants.NO_GESTIONADA;
				Task tareaCambio2 =[Select Id, Status, AV_ToDelete__c, AV_Tipo__c, Description, AV_Center__c, AV_CodigoGestorAsignado__c, LastModifiedById from Task where Id = :tareaAntes.Id limit 1];
				tareaCambio.AV_Center__c = '12345';
				Database.update(tareaCambio2);
				Task tareaDespues =[Select Id, Status, AV_ToDelete__c, AV_Tipo__c, Description, AV_Center__c, AV_CodigoGestorAsignado__c, LastModifiedById from Task where Id = :tareaAntes.Id limit 1];
				System.assertNotEquals(tareaDespues.AV_ToDelete__c,true);
				System.assertEquals(tareaDespues.Status,AV_AppConstants.GESTIONADO_POSITIVO_ESTADO);
				System.assertNotEquals(tareaDespues.AV_Center__c,'12345');
		}
        Test.stopTest();
	}
    
    @isTest
	public static void updateSin(){
		User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		Test.startTest();
		System.runAs(usuGcf){
			List <Contact> cntactUser = [SELECT Id, CC_Matricula__c FROM Contact WHERE AV_Usuarioasociado__c = :usuGcf.Id LIMIT 1];
			User userSinGestor = [SELECT Id FROM USER WHERE Alias = 'AV-TF9' AND Profile.Name = 'API Only' and isActive = true LIMIT 1];        
			List<Task> listTask = [SELECT Id, AV_ExternalID__c, OwnerId,Status FROM Task WHERE OwnerId = :userSinGestor.Id ];
			List<Task> listTaskAux = [SELECT Id, AV_ExternalID__c, OwnerId,Status FROM Task WHERE OwnerId = :userSinGestor.Id ];
			Map<Id, Task> mapTask = new Map<Id, task>();
			for(Task hca : listTask){
				hca.Status = 'Desactivada';
				mapTask.put(hca.Id, hca);
				}	

			AV_TaskTriggerHelper.updateSinGestor(listTaskAux,mapTask);
			Test.stopTest();
			System.assertNotEquals(listTaskAux, listTask);
		}
	}

	@isTest
	public static void validateNotifyExperienciaClienteTask(){
		RecordType rtExp = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK,AV_AppConstants.TASKEXPCLIENT_RT);
		User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454'];
		User us2 = AV_TestHelper.createUser('','9898','AV_SistematicaComercial');
		//Esto tiene que ser ejecutado por un usuario Administrador porque tiene que tener permisos para lanzar CBK_ScheduleProcess_Controller
		User usuAdmin = [Select Id from User where Email = 'oficinatecnica.salesforce@caixabanktech.com' and Alias = 'Admin 1' and IsActive = true limit 1]; 
		Task t1 = AV_TestHelper.createTareaExternalIdSinInsert(us,'123456');
		Task t2 = AV_TestHelper.createTareaExternalIdSinInsert(us,'123457');
		t1.ActivityDate = Date.today().addDays(5);
		t2.ActivityDate = Date.today();
		t1.RecordTypeId = rtExp.Id;
		t2.RecordTypeId = rtExp.Id;
		String errorExpected;	
		Test.startTest();
		System.runAs(usuAdmin){
			CBK_ScheduleControls__c scs = new CBK_ScheduleControls__c();
			scs.Name = 'ScheduleInfo';
			scs.Retries__c =0;
			insert scs;
			insert new List<Task>{t1,t2};
			t1.OwnerId = us2.Id;
			t1.AV_Tipo__c = AV_AppConstants.TASKOFFICETYPE;
			t1.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_SF_REPORT;
			t2.ActivityDate = t2.ActivityDate.addDays(5);
			List<CBK_SCH_PendingProcess__c> scheduleTestList= [SELECT Id FROM CBK_SCH_PendingProcess__c WHERE RecordId__C = :t2.Id];
			scheduleTestList[0].Queued__c = true;
			update scheduleTestList[0];
			update new List<Task>{t1,t2};
			t1.OwnerId = null;
			AV_TaskTriggerHelper.executeNotification(t2.OwnerId,t2.Id);
			Test.stopTest();
			scheduleTestList= [SELECT Id FROM CBK_SCH_PendingProcess__c WHERE RecordId__C IN (:t1.Id,:t2.Id)];
			System.assert(!scheduleTestList.isEmpty(),'Empty schedule List');	
		}	
	}

	@isTest 
    public static void checkOftTypeValidate(){
        User user = [SELECT Id FROM User WHERE Alias = 'tsAlias' LIMIT 1];
        Task t = AV_TestHelper.createTareaExternalIdSinInsert(user,'123457');
        Task t2 = AV_TestHelper.createTareaExternalIdSinInsert(user,'123458');
        Task t3 = AV_TestHelper.createTareaExternalIdSinInsert(user,'123459');
        insert new List<Task>{t,t2,t3};
            Test.startTest();
        System.runAs(user){
            t.AV_OrigenApp__c = '';
            t2.AV_Tipo__c = AV_AppConstants.TASKOFFICETYPE;
            t2.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_SF_REPORT;
            t3.AV_Tipo__c = AV_AppConstants.TASKOFFICETYPE;
            try{
                update new List<Task>{t,t2,t3};
                    }catch(Exception err){
                        AV_LogDebug.printLogDebug('Error', 'Something went wrong');
                    }
        }
        Test.stopTest();
        Task tRetri = [SELECT Id,AV_OrigenApp__c FROM Task WHERE AV_ExternalID__c = '123457' and Id = :t.Id];
        System.assert(String.isBlank(tRetri.AV_OrigenApp__c));
    }
    
    @isTest 
    public static void updateNextManagementDateOppTest(){
        User user = [SELECT Id FROM User WHERE Alias = 'tsAlias' LIMIT 1];
		Task t1;
        
        Test.startTest();
        System.runAs(user){

			RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
			Account cliente = new Account(
					FirstName = 'FirstNameTest',
					LastName = 'LastNameTest',
					RecordTypeId = rt.Id,
					AV_NumPerso__c = '1234',
					AV_Negocio__c = 'BPA',
					CC_Numero_Documento__c = '9446387T'
				);

			Account centroCaixa = new Account(
				Name = '00615 STORE DOS DE MAIG-ROSSELLO' , CC_Numero_Oficina_Empresa__c = '00615'
			);

			Contact empleado = new Contact(FirstName = 'Empleado',LastName = '1');
            Opportunity opp = AV_TestHelper.createOpportunityExternalId(cliente, empleado, '01928374');

			t1 = AV_TestHelper.createTareaExternalIdSinInsert(user,'123457');
			insert t1;

			AV_CustomActivityOpportunity__c oppTask = AV_TestHelper.createTareaOportunidad(opp, t1);


			Task t2 = t1.clone(false, true, false, false);
			t2.Id = t1.Id;
			t2.ActivityDate = date.newInstance(2024, 01, 15);
			Map<Id, Task> mapOlds = new Map<Id, Task> ();
			mapOlds.put(t2.Id, t2);
			Map<String, Task> mapToByPassTask = new Map<String, Task>();
			List<Task> listNews = new List<Task>();
			t1.ActivityDate = System.today();
			listNews.add(t1);



			AV_TaskTriggerHelper.updateNextManagementDateOpp(listNews, mapOlds, mapToByPassTask);		
        }
        Test.stopTest();
        Task tRetri = [SELECT Id,AV_OrigenApp__c FROM Task WHERE AV_ExternalID__c = '123457' and Id = :t1.Id];
        System.assert(String.isBlank(tRetri.AV_OrigenApp__c));
    }

}