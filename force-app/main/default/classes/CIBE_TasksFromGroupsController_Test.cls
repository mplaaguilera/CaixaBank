/**********************************************************************************************************************
Name:	  CIBE_TasksFromGroupsController_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_TasksFromGroupsController"
-----------------------------------------------------------------------------------------------------------------------
Historial
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Test Class		Alex Campos			09/05/2022		Init version

-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/
@isTest
public class CIBE_TasksFromGroupsController_Test {

    @TestSetup
	static void setup() {
        CIBE_TestInitialSetup.setupInitialDataEMP();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
            Account acc = CIBE_TestHelper.createCustomer(u);

            Task tsk = CIBE_TestHelper.createTareaOtherExternalID(u);
            tsk.Status = 'Open';
            tsk.WhatId = acc.Id;
            tsk.ownerId = u.Id;
            update tsk;
        }
    }
    
	@isTest
	public static void getDataTest() {
        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        System.runAs(u) {
            Map<Id, Account> clients = new Map<Id, Account>([SELECT Id FROM Account WHERE Recordtype.DeveloperName = 'CC_Cliente']);
           	
            Test.startTest();
            List<CIBE_TasksFromGroupsController.TaskWrapper> result = CIBE_TasksFromGroupsController.getRecords(0, new List<Id>(clients.keySet()));
   			
            System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }
    
}