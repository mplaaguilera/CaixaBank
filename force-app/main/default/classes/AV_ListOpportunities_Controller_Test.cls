/**********************************************************************************************************************
 Name:	  AV_ListOpportunities_Controller_Test
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase de Test para el controlador AV_ListOpportunities_Controller
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Esperanza Conde		13/10/2020			Test Class
	1.1			App FSC			Álvaro López		18/10/2020			Test updated in order to cover the App FSC changes
	1.1			FIX				Sandra Gómez		26/08/2021			Fix product opportunity
	1.2			FIX 			Luis Fernández		11/07/2022			Changed AV_Queries to SOQL queries
	1.3			US481572		Patricia Solano 	27/01/2023	        Add TestSetup and add runAs at all test methods
***********************************************************************************************************************/
@isTest
public class AV_ListOpportunities_Controller_Test {

	@TestSetup
    static void setup(){
		User user = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		
        System.runAs(user) {
			Account account = AV_TestHelper.createCustomer();
			Pricebook2 pricebook = AV_TestHelper.createPricebook2();
			Opportunity opportunity = AV_TestHelper.createOpportunity(account);
			Task task  = AV_TestHelper.createTarea(null);
        }
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
    }

	/**
	 * Check ActivityOpp from task
	 */
	@isTest
	public static void retrieveListOppTest() {
		User user = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(user) {
			Test.startTest();
			Account account = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
			Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1];
			Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial' LIMIT 1];
			Task task = [SELECT Id FROM Task WHERE Subject = 'Llamada Saliente' LIMIT 1];
			String idCabeceraTarea = [SELECT Id,AV_Task__C FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1].AV_Task__C;
			AV_CustomActivityOpportunity__c taskOpp = AV_TestHelper.createTareaOportunidad(opportunity, idCabeceraTarea);
			task.AV_Task__c = idCabeceraTarea;
			update task;
			String recInfo = AV_ListOpportunities_Controller.getRecordInfo(String.valueOf(task.id), 'Task');
			List<AV_ListOpportunities_Controller.OppTaskResponse> listActivityOpp = AV_ListOpportunities_Controller.retrieveListOpp(recInfo);
			Test.stopTest();
			System.assertEquals(1, listActivityOpp.size());
		}
    }
    
    /**
	 * check opp from customer of the task
	 */
	@isTest
	public static void retrieveListWithOutTaskTest() {
		User user = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(user) {
			Test.startTest();
			Account account = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
			Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1];
			Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial' LIMIT 1];
			Task task = [SELECT Id FROM Task WHERE Subject = 'Llamada Saliente' LIMIT 1];
			String idCabeceraTarea = [SELECT Id,AV_Task__C FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1].AV_Task__C;
			task.AV_Task__c = idCabeceraTarea;
			task.WhatId = account.Id;
			update task;
			String recInfo = AV_ListOpportunities_Controller.getRecordInfo(String.valueOf(task.id), 'Task');
			List<AV_ListOpportunities_Controller.OppResponse> listOpp = AV_ListOpportunities_Controller.retrieveListWithOutTask(recInfo);
			Test.stopTest();
			System.assertEquals(1, listOpp.size());
		}
    }
	
    /**
	 * get value status field
	 */
	@isTest
	public static void getStatusValueTest() {
		User user = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(user) {
			Test.startTest();
			List<Map<String, String>> listMapValue = AV_ListOpportunities_Controller.getStatusValues('Opportunity', 'StageName');
			Test.stopTest(); 
			if(!listMapValue.isEmpty()){
				System.assert(listMapValue != Null); 
			}
		}
    }
}