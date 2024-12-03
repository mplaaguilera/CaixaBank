/**********************************************************************************************************************
Name:      AV_DeleteRelatedTaskQueueable_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase AV_DeleteRelatedTaskQueueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION        USER_STORY		AUTHOR              DATE                Description
	1.0            Init             Sandra Gómez        05/01/2023          Init version

***********************************************************************************************************************/
@isTest
public with sharing class AV_DeleteRelatedTaskQueueable_Test {
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
            AV_TestHelper.activateLogger();
            AV_TestHelper.createPricebook2();
            User us = AV_TestHelper.createUser('AV_Usuario_CaixaBank','U0181273981391','AV_SistematicaComercial');
            Account cliente = AV_TestHelper.createCustomerSinInsert();
            Account centroCaixa = AV_TestHelper.createCaixaCenterSinInsert();
            List<Account> accs = new List<Account>{cliente, centroCaixa};
            insert accs;
            Contact empleado  = AV_TestHelper.createEmployee(centroCaixa, us);
            List<Opportunity> listOpportunityInsert = new List<Opportunity>();
            for (Integer i=0;i<10;i++) {
                listOpportunityInsert.add(AV_TestHelper.createOpportunityIniciativaWithChecktPrioritySinInsert(cliente, empleado, '5011'+i,'8348'+i));
            }
            insert listOpportunityInsert;
		}
	}

	@isTest
	public static void validateQueueble() {
        User us =[Select Id, UserRole.Name from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        List<AV_ManagementHistory__c> managementHistoryList= new List<AV_ManagementHistory__c>();
        List<CBK_Activity_Extension__c> taskExtensionList= new List<CBK_Activity_Extension__c>();
        List<AV_CustomActivityOpportunity__c> taskOppList= new List<AV_CustomActivityOpportunity__c>();
        List<AV_HeaderCustomActivity__c> listHeaderTask= new List<AV_HeaderCustomActivity__c>();
        System.runAs(us) {
            List<Task> listTask = [SELECT Id,AV_Task__c,AV_ExternalID__c, OwnerId, AV_CodigoGestorAsignado__c FROM Task];
            Map<Id, Task> mapIdsTask = new Map<Id, Task>(listTask);
            Test.startTest();
            delete listTask;
            Test.stopTest();
            managementHistoryList = [Select Id From AV_ManagementHistory__c];
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