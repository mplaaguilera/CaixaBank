/**********************************************************************************************************************
 Name:	  AV_SObjectRelatedInfoCController_Test
 Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Clase Test para AV_SObjectRelatedInfoCController.
=======================================================================================================================
Historial
---------------------
   VERSION		USER_STORY			AUTHOR				DATE				Description
   1.0			Test				Carolina Alonso	   	04/03/2020		  	Init version
   1.1			Test				Carolina Alonso	   	16/07/2020		  	Add test class for c2c
   1.2			Test 				Jashanpreet			19/02/2021			Added test for task object
   1.3			US316969			Víctor Santiago		17/02/2022			Added method testGetFieldsQueryLookup
   1.4			US542315			Patricia Solano		22/03/2023			Added setup and method testGetFieldsQueryCase 
   1.5			FIX					Patricia Solano		19/04/2023			Modified to set run as, assertions and user creation
   1.6			FIX					Patricia Villacañas	18/05/2023			Modified to set run as
***********************************************************************************************************************/
@isTest
public with sharing class AV_SObjectRelatedInfoCController_Test {

	@TestSetup
    static void setup(){

		User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545400', 'AV_SistematicaComercial');
		userGestor.Alias = 'gest';
		userGestor.Email = 'gestor-test@test.com';
		userGestor.IsActive = true;
        insert userGestor;

        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];

		System.runAs(userCli){
			Account account = AV_TestHelper.createCustomerSinInsert();
			account.OwnerId = userGestor.Id;
			insert account;
		}

		System.runAs(userGcf){
			Account account =  [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];

			Case myCase =  new Case();
			myCase.Subject = 'Test Case';
			myCase.OwnerId = userGestor.Id;
			insert myCase;

			RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKEXPCLIENT_RT);
			Task task = AV_TestHelper.createTareaExternalIdWithCustomerSinInsert(userGestor, 'ID-0001', account);
			Task taskWithCase = AV_TestHelper.createTareaExternalIdWithCustomerSinInsert(userGestor, 'ID-0002', account);
			taskWithCase.AV_Case__c = myCase.Id;

			List<Task> taskList = new List<Task>();
			taskList.add(task);
			taskList.add(taskWithCase);
			insert taskList;
		}
    }

	/**
	 * Test for SObject related to Account for method getIdFilterObject
	 */
	@isTest
	public static void testGetIdFilterObject() {
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		String filterId; 

		Account account =  [SELECT Id FROM Account WHERE CC_Numero_Documento__c = '9446386T' LIMIT 1];
		Case myCase =  [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
		myCase.AccountId = account.Id;
		update myCase;

		String filterType = 'Account';
		String filterName = 'Id';
		String typeName = 'Account';
		String recordId = account.Id;

		Test.startTest();
			System.runAs(userGestor){
				filterId = AV_SObjectRelatedInfoCController.getIdFilterObject(recordId, typeName, filterType, filterName);
			}
		Test.stopTest();

		System.assertEquals(account.Id, filterId);
	}

	/**
	 * Test for SObject related to Account for method getFieldsQuery
	 */
	@isTest
	public static void testGetFieldsQuery() {
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		
		List<AV_SObjectRelatedInfoCController.FieldSetMember> listFieldSet;
		List<Schema.FieldSetMember> listFSMember;
		Account account =  [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
		String recordId;

		Test.startTest();
			System.runAs(userGestor){

				String filterType = 'Account';
				String filterName = 'Id';
				String typeName = 'Account';
				String fieldSetName = 'AV_AccInformation';
				recordId = account.Id;
				listFieldSet = new List<AV_SObjectRelatedInfoCController.FieldSetMember>();
				listFieldSet = AV_SObjectRelatedInfoCController.getFieldsQuery(recordId, typeName, filterType,filterName, fieldSetName);
				listFSMember = Schema.SObjectType.Account.fieldSets.getMap().get(fieldSetName).getFields();
			}
		Test.stopTest();

		System.assertEquals(listFSMember.size(), listFieldSet.size());
		System.assertEquals(account.Id, recordId);
	}

	/**
	 * Test for SObject to call c2cMakeCall method
	 */
	@isTest
	public static void testMake2Call() {
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		String calledDevice;
		List<String> listMakeCall;

		Test.startTest();
			System.runAs(userGestor){
				calledDevice = '637053560';
				listMakeCall = AV_SObjectRelatedInfoCController.c2cMakeCall(calledDevice);
			}
		Test.stopTest();

		System.assertEquals(calledDevice, '637053560');
		System.assertNotEquals(listMakeCall, null);
	}
    
	/**
	 * Test for SObject related to Task for method getFieldsQuery
	 */
    @isTest
	public static void testGetTaskFieldsQuery() {
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		
		List<AV_SObjectRelatedInfoCController.FieldSetMember> listFieldSet;
		List<Schema.FieldSetMember> listFSMember;
		Task task =  [SELECT Id FROM Task WHERE AV_ExternalID__c = 'ID-0001' LIMIT 1];
		String recordId;

		Test.startTest();
			System.runAs(userGestor){
				String filterType = 'Task';
				String filterName = 'Id';
				String typeName = 'Task';
				String fieldSetName = 'AV_TaskInformation';
				recordId = task.Id;

				listFieldSet = new List<AV_SObjectRelatedInfoCController.FieldSetMember>();
				listFieldSet = AV_SObjectRelatedInfoCController.getFieldsQuery(recordId, typeName, filterType,filterName, fieldSetName);
				listFSMember = Schema.SObjectType.Task.fieldSets.getMap().get(fieldSetName).getFields();
			}
		Test.stopTest();

		System.assertEquals(listFSMember.size(), listFieldSet.size());
		System.assertEquals(task.Id, recordId);
	}

    /**
	 * Test for SObject related to Task for method getFieldsQuery
	 */
     @isTest
	public static void testGetTaskCompanionFieldsQuery() {
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];

		List<AV_SObjectRelatedInfoCController.FieldSetMember> listFieldSet;
		List<Schema.FieldSetMember> listFSMember;
		Task task  = [SELECT Id FROM Task WHERE AV_ExternalID__c = 'ID-0001' LIMIT 1];
		String recordId;

		Test.startTest();
			System.runAs(userGestor){

				String filterType = 'Task';
				String filterName = 'Id';
				String typeName = 'Task';
				String fieldSetName = 'AV_Companion';
				recordId = task.Id;

				listFieldSet = new List<AV_SObjectRelatedInfoCController.FieldSetMember>();
				listFieldSet = AV_SObjectRelatedInfoCController.getFieldsQuery(recordId, typeName, filterType,filterName, fieldSetName);
				listFSMember = Schema.SObjectType.Task.fieldSets.getMap().get(fieldSetName).getFields();
			}
		Test.stopTest();

		System.assertEquals(listFSMember.size(), listFieldSet.size());
		System.assertEquals(task.Id, recordId);
	}

    /**
	 * Test for SObject related to Task for method getFieldsQuery
	 */
    @isTest
	public static void testGetFieldsQueryLookup() {
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];

		List<AV_SObjectRelatedInfoCController.FieldSetMember> listFieldSet;
		List<Schema.FieldSetMember> listFSMember;
		Task task  =  [SELECT Id FROM Task WHERE AV_ExternalID__c = 'ID-0001' LIMIT 1];
		String recordId;

		Test.startTest();
			System.runAs(userGestor){
				String filterType = 'Task';
				String filterName = 'Id';
				String typeName = 'Task';
				String fieldSetName = 'AV_Interlocutor';
				recordId = task.Id;

				listFieldSet = new List<AV_SObjectRelatedInfoCController.FieldSetMember>();
				listFieldSet = AV_SObjectRelatedInfoCController.getFieldsQuery(recordId, typeName, filterType,filterName, fieldSetName);
				listFSMember = Schema.SObjectType.Task.fieldSets.getMap().get(fieldSetName).getFields();
			}
		Test.stopTest();

		System.assertEquals(listFSMember.size(), listFieldSet.size());
		System.assertEquals(task.Id, recordId);
	}

	/**
	 * Test for SObject related with client experience Task for method getFieldsQuery
	 */
	@isTest
	public static void testGetFieldsQueryCase() {
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];

		List<AV_SObjectRelatedInfoCController.FieldSetMember> listFieldSet;
		List<Schema.FieldSetMember> listFSMember;
		Task task = [SELECT Id FROM Task WHERE AV_ExternalID__c = 'ID-0002' LIMIT 1];
		String recordId;

		Test.startTest();
		System.runAs(userGestor){
			String filterType = 'Task';
			String filterName = 'Id';
			String typeName = 'Task';
			String fieldSetName = 'AV_CaseManagementTask';
			recordId = task.Id;
			
			listFieldSet = new List<AV_SObjectRelatedInfoCController.FieldSetMember>();
			listFieldSet = AV_SObjectRelatedInfoCController.getFieldsQuery(recordId, typeName, filterType,filterName, fieldSetName);
			listFSMember = Schema.SObjectType.Task.fieldSets.getMap().get(fieldSetName).getFields();
		}
		Test.stopTest();
			
		System.assertEquals(listFSMember.size(), listFieldSet.size());
		System.assertEquals(task.Id, recordId);
	}
}