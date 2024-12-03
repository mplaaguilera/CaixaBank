/**********************************************************************************************************************
Name:      AV_GestorReassignmentTQueueable_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase AV_GestorReassignmentTaskQueueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION        USER_STORY		AUTHOR              DATE                Description
	1.0            Init             Sandra Gómez        05/04/2022          Init version
	1.1			   US649249			Gonzalo Ávila		28/11/2023			Include system.asserts in all methods

***********************************************************************************************************************/
@isTest
public with sharing class AV_GestorReassignmentTQueueable_Test {
	@TestSetup
	static void setup() {
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
	}

	@isTest
	public static void validateTaskQueueble() {
		//AV_TestHelper.createUser('','U0181273981391');
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		User us = AV_TestHelper.createUser('','U0181273981392');
		List<Task> listInsertTask = new List<Task>();
        AV_LimitBook__c cs = new AV_LimitBook__c();
        cs.AV_Limit__c= 150;
        cs.AV_LimitReassignment__c = 100;
        insert cs;
		Integer maxSize = (Integer) AV_LimitBook__c.getOrgDefaults().AV_LimitReassignment__c;
        RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
		for(Integer i=0;i<maxSize;i++) {
            Task tarea  = new Task();
            tarea.Subject = 'Llamada Saliente';
            tarea.OwnerId = us.Id;		
            tarea.Status = 'Open';
            tarea.Priority = 'Normal';
            tarea.AV_ExternalID__c = '6543211234'+i;	
            tarea.RecordTypeId = rt.Id;
			listInsertTask.add(tarea);
		}
		insert listInsertTask;
		List<Task> listTask= [Select Id, OwnerId from Task];
		for(Task ta: listTask) {
			ta.OwnerId=us.Id;
		}
		listTask[0].AV_Tipo__c = 'badValuePickList';
        AV_GestorReassignmentTaskQueueable.doChainJob = false;
		id jobID;
		String id;
		System.runAs(userGcf){
		Test.startTest();
		jobID = System.enqueueJob(new AV_GestorReassignmentTaskQueueable(listTask,null));
		id = jobId.to15();
		System.assert(!String.isEmpty(id), 'ValidateTaskQueueble Error');
		Test.stopTest();
		}
	}
	@isTest
	public static void validateTaskQueuebleChaniJob() {
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		List<Task> listTask= [Select Id, OwnerId from Task];
		List<Event> listEvent= [Select Id, OwnerId from Event];
        AV_GestorReassignmentTaskQueueable.doChainJob = false;
		id jobID;
		String id;
		System.runAs(userGcf){
		Test.startTest();
			jobID = System.enqueueJob(new AV_GestorReassignmentTaskQueueable(listTask,listEvent));
			id = jobId.to15();
			System.assert(!String.isEmpty(id), 'ValidateTaskQueueableChaniJob Error');

		Test.stopTest();
		}
	}
}