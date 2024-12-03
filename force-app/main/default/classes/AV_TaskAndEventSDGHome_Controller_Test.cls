/**********************************************************************************************************************
Name:	  AV_TaskAndEventSDGHome_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Test para AV_TaskAndEventSDGHome_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	  AUTHOR		   	DATE				Description
	1.1			DE56793	      Patricia Solano  	16/11/2022		  	Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_TaskAndEventSDGHome_Controller_Test {
    
    @TestSetup
	static void setup(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
            List<User> listUser = new List<User>();
            Account account = AV_TestHelper.createCustomer();
            Pricebook2 pricebook = new Pricebook2();
            User u = AV_TestHelper.createUserSinInsert('','U012345','AV_SistematicaComercial');
            listUser.add(u);
            pricebook.Name = 'Standard Price Book';
            insert pricebook;

            User user = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U012344','AV_SistematicaComercial');
            listUser.add(user);

            insert listUser;

            Opportunity opportunity = AV_TestHelper.createOpportunity(account);

            Task task = AV_TestHelper.createTareaExternalIdWithCustomerSinInsert(user, '01928374', account);
            task.ActivityDate = System.today()+1;        
            insert task;

            String idTaskHeader = [SELECT AV_Task__c FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1].AV_Task__c;
        }        
	}

    @isTest
    public static void getTaskTodaytest(){
        User u = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U012345'];
        Opportunity opportunity =  [SELECT ID FROM Opportunity LIMIT 1];

        System.runAs(u){
            Test.startTest();
            AV_TaskAndEventSDGHome_Controller.DataResponse response = new AV_TaskAndEventSDGHome_Controller.DataResponse();
            response = AV_TaskAndEventSDGHome_Controller.getRecords('TodayTask');
            Test.stopTest();
            system.assertNotEquals(null, response);
        }
    }

    @isTest
    public static void getTaskPendingtest(){
        User u = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U012345'];
        Opportunity opportunity =  [SELECT ID FROM Opportunity LIMIT 1];

        System.runAs(u){
            Test.startTest();
            AV_TaskAndEventSDGHome_Controller.DataResponse response = new AV_TaskAndEventSDGHome_Controller.DataResponse();
            response = AV_TaskAndEventSDGHome_Controller.getRecords('PendingTask');
            Test.stopTest();
            system.assertNotEquals(null, response);
        }    
    }

    @isTest
    public static void getEventTodaytest(){
        User u = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U012345'];
        Opportunity opportunity = [SELECT ID FROM Opportunity LIMIT 1];

        System.runAs(u){
            Test.startTest();
            AV_TaskAndEventSDGHome_Controller.DataResponse response = new AV_TaskAndEventSDGHome_Controller.DataResponse();
            response = AV_TaskAndEventSDGHome_Controller.getRecords('TodayEvents');
            Test.stopTest();
            system.assertNotEquals(null, response);
        }    
    }

    @isTest
    public static void getEventPendingtest(){
        User u = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U012345'];
        Opportunity opportunity = [SELECT ID FROM Opportunity LIMIT 1];

        System.runAs(u){
            Test.startTest();
            AV_TaskAndEventSDGHome_Controller.DataResponse response = new AV_TaskAndEventSDGHome_Controller.DataResponse();
            response = AV_TaskAndEventSDGHome_Controller.getRecords('YesterdayEvents');
            Test.stopTest();
            system.assertNotEquals(null, response);
        }
    }
}