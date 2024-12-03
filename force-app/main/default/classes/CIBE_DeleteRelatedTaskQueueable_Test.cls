/**********************************************************************************************************************
Name:      CIBE_DeleteRelatedTaskQueueable_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase CIBE_DeleteRelatedTaskQueueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION        USER_STORY		AUTHOR              DATE                Description
	1.0            Init             Luis Martínez       05/01/2023          Init version

***********************************************************************************************************************/
@isTest
public with sharing class CIBE_DeleteRelatedTaskQueueable_Test {
    @TestSetup
	static void setup() {
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];

        System.runAs(usuario) {
            AV_Score__c sc= new AV_Score__c();
                sc.Name = 'Otros';
                sc.AV_Active__c = true;
                sc.AV_Object__c = 'Task';
                sc.AV_RecordType__c = 'AV_Otros';
                sc.AV_Score__c = 10000;
            insert sc;
            //AV_TestHelper.activateLogger();
            Pricebook2 pb = new Pricebook2();
                pb.Name = 'Standard Price Book';
            insert pb;
            User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);

            Task task = new Task();
            task.Subject = 'Prueba test insert';
            task.recordtypeid = rt.id;
            task.ownerid= usrTest.id;
            task.Description = 'Prueba test insert';
            task.AV_CodigoGestorAsignado__c = '123456';
            task.Status = CIBE_AppConstants.TASK_STATUS_PENDIENTE;
            task.ActivityDate = System.now().Date();
            task.AV_AssociatedOpportunityId__c='1234';
            
            insert task;
            Account cliente = CIBE_TestHelper.createCustomer();
            Account centroCaixa = CIBE_TestHelper.createCaixaCenter();
            Contact empleado  = CIBE_TestHelper.createEmployee(centroCaixa, usrTest,usrTest.AV_ExternalId__c);
            Opportunity opp =  CIBE_TestHelper.createOpportunityExternalId(cliente, empleado, task.AV_ExternalID__c);
            List<AV_HeaderCustomActivity__c> listHeaderTask = [SELECT Id FROM AV_HeaderCustomActivity__c];
            AV_CustomActivityOpportunity__c cao = CIBE_TestHelper.createTareaOportunidad(opp,listHeaderTask[0].id);

		}
	}

	@isTest
	public static void validateQueueble() {
        User us =[Select Id, UserRole.Name from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        List<AV_ManagementHistory__c> managementHistoryList = new List<AV_ManagementHistory__c>();
        List<CBK_Activity_Extension__c> taskExtensionList = new List<CBK_Activity_Extension__c>();
        List<AV_CustomActivityOpportunity__c> taskOppList = new List<AV_CustomActivityOpportunity__c>();
        List<AV_HeaderCustomActivity__c> listHeaderTask = new List<AV_HeaderCustomActivity__c>();
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);
        System.runAs(us) {
            List<Task> listTask = [SELECT Id,AV_Task__c,AV_ExternalID__c, OwnerId, AV_CodigoGestorAsignado__c FROM Task WHERE  recordTypeId =: rt.id ];
            Map<Id, Task> mapIdsTask = new Map<Id, Task>(listTask);
            Test.startTest();
            delete listTask;
            Test.stopTest();
            managementHistoryList = [Select Id From AV_ManagementHistory__c WHERE AV_ActivityId__c =: listTask[0].id];
            taskExtensionList = [Select Id From CBK_Activity_Extension__c];
            taskOppList = [Select Id From AV_CustomActivityOpportunity__c];
            listHeaderTask = [SELECT Id FROM AV_HeaderCustomActivity__c];
        }
        System.assertEquals(managementHistoryList.isEmpty(), true);
        System.assertEquals(taskExtensionList.isEmpty(), true);
        System.assertEquals(taskOppList.isEmpty(), true);
        System.assertEquals(listHeaderTask.isEmpty(), true);
	}
}