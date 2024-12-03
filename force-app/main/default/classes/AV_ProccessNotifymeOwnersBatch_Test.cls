/**********************************************************************************************************************
 Name:      AV_ProccessNotifymeOwnersBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_ProccessNotifymeOwnersBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        	USER_STORY       AUTHOR              DATE               Description
   	1.0            	App FSC          Sandra Gómez        28/01/2021         Init version
	1.1            	App FSC          David Rufo          10/02/2021         Fix performance problem
	1.2				App FSC			 David Rufo			 11/02/2020			Improve batch for execution list users

***********************************************************************************************************************/
@isTest
private class AV_ProccessNotifymeOwnersBatch_Test {
	
    /**
	 * Create 1 Notifyme with the field AV_Employee__c and OwnerId.
	 */
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();
		User u1 = AV_TestHelper.createUser('AV_Usuario_CaixaBank', 'U0100001');
        User u2 = AV_TestHelper.createUser('AV_Usuario_CaixaBank', 'U0100002');
        //AV_LogDebug.printLogDebug('setup', 'User1: ' + u1);
        //AV_LogDebug.printLogDebug('setup', 'User2: ' + u2);
        Contact con =  AV_TestHelper.createEmployee(null,u1);
        //AV_LogDebug.printLogDebug('setup', 'Contact: ' + con);
		
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
		
        con.AV_UsuarioAsociado__c = u2.Id;
        update con;
        
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            AV_TestHelper.insertPermissionSet(u1.id, 'AV_GestorOperativa');
            AV_TestHelper.insertPermissionSet(u2.id, 'AV_GestorOperativa');
        }
	}
    
	/**
	 * Execute the Batch class (AV_ProccessNotifymeOwnersBatch)
	 */
	@isTest
	static void executeProccessNotifymeOwnersBatch() {
		User u2 = [SELECT Id FROM User where AV_ExternalID__c = 'U0100002'];
        Set<String> setUserIds = new Set<String>{u2.Id};
        AV_LogDebug.printLogDebug('executeProccessNotifymeOwnersBatch', 'User2: ' + u2);
        AV_ProccessNotifymeOwnersBatch b = new AV_ProccessNotifymeOwnersBatch('300', setUserIds);
        
		Test.startTest();	
		Database.executeBatch(b);
		Test.stopTest();
        
        List<AV_NotifyMe__c> listNotifyme = [SELECT id, OwnerId FROM AV_NotifyMe__c];
        for (AV_NotifyMe__c nm : listNotifyme) {
            System.assertEquals(u2.id, nm.OwnerId);
        }
	}
}