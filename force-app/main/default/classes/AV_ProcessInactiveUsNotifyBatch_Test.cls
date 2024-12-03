/**********************************************************************************************************************
 Name:      AV_ProcessInactiveUsNotifyBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_ProcessInactiveUserNotifyMeBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        	USER_STORY       AUTHOR              DATE               Description
   	1.0            	US306420         Sandra Gómez        20/12/2021         Init version
	1.1		        AV_Query IT	     Daniel Rodríguez	 7/02/2022	        Change AV_Query to SOQL for User and Account
    1.2        		US592987		 Ángel Medina		 30/05/2023			Changed AV_Query to SOQL queries
	
***********************************************************************************************************************/
@isTest
private class AV_ProcessInactiveUsNotifyBatch_Test {
	/**
	 * Create 1 Notifyme with the field AV_Employee__c and OwnerId.
	 */
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();
		User u1 = AV_TestHelper.createUser('AV_Usuario_CaixaBank', 'U01000012');
		Contact con =  AV_TestHelper.createEmployee(null,u1);
		
		RecordType rt = AV_AppUtilities.getRecordType('AV_NotifyMe__c', 'AV_NotifyMe');
		AV_NotifyMe__c noti = new AV_NotifyMe__c();
		noti.AV_Subject__c = 'Notify Me';
		noti.AV_ExternalId__c = '00000001';
		noti.AV_Status__c = 'AV_Pendiente';
		noti.RecordTypeId = rt.Id;
		noti.AV_Description__c = 'Nueva Notificación tipo NotifyMe';
		noti.AV_Employee__c = con.Id;
		noti.OwnerId = u1.Id;
		insert noti;
		
		System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
			AV_TestHelper.insertPermissionSet(u1.id, 'AV_GestorOperativa');
		}
	}
	
	/**
	 * Execute the Batch class (AV_ProcessInactiveUserNotifyMeBatch)
	 */
	@isTest
	static void executeProcessInactiveUserNotifyMeBatch() {
		User u1 = [Select Id From User Where AV_ExternalID__c = 'U01000012'];
       
		Set<String> setUserIds = new Set<String>{u1.Id};
		AV_LogDebug.printLogDebug('executeProcessInactiveUserNotifyMeBatch', 'User1: ' + u1);
		AV_ProcessInactiveUserNotifyMeBatch b = new AV_ProcessInactiveUserNotifyMeBatch('10000', setUserIds);
		
		Test.startTest();
		User userCli = [Select Id From User Where Profile.Name = 'API Only' and Alias = 'AV-TF9' limit 1];
        
		Database.executeBatch(b);
		Test.stopTest();
		AV_NotifyMe__c notichange = [SELECT Id, OwnerId FROM AV_NotifyMe__c];
        
		System.assertEquals(userCli.Id, notichange.OwnerId);
	}
}