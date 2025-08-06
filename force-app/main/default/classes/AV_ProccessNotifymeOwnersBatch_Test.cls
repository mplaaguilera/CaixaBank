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
        User u2 = AV_TestHelper.createUser('AV_Usuario_CaixaBank', 'CPid');
       
        Contact con =  AV_TestHelper.createEmployee(null,u2,u2.AV_ExternalId__c);
		
		RecordType rt = AV_AppUtilities.getRecordType('AV_NotifyMe__c', 'AV_NotifyMe');
		AV_NotifyMe__c noti = new AV_NotifyMe__c();
		noti.AV_Subject__c = 'Notify Me';
		noti.AV_ExternalId__c = '00000001';
		noti.AV_Status__c = 'AV_Pendiente';
		noti.RecordTypeId = rt.Id;
		noti.AV_Description__c = 'Nueva Notificación tipo NotifyMe';
		noti.AV_Employee__c = con.Id;
		noti.OwnerId = u2.Id;
		insert noti;
		
        con.AV_UsuarioAsociado__c = u2.Id;
        con.CC_Matricula__c = u2.AV_ExternalId__c;
        update con;
        
        System.runAs(u2) {
            AV_TestHelper.insertPermissionSet(u2.id, 'AV_GestorOperativa');
        }
	}
    
	/**
	 * Execute the Batch class (AV_ProccessNotifymeOwnersBatch)
	 */
	@isTest
	static void executeProccessNotifymeOwnersBatch() {
		User u2 = [SELECT Id FROM User where AV_ExternalID__c = 'CPid' LIMIT 1];
        Set<String> setUserIds = new Set<String>{u2.Id};
        AV_ProccessNotifymeOwnersBatch b = new AV_ProccessNotifymeOwnersBatch('300', setUserIds);
        AV_ProccessNotifymeOwnersBatch c = new AV_ProccessNotifymeOwnersBatch();
		Test.startTest();	
		Database.executeBatch(b);
		Test.stopTest();
        
        List<AV_NotifyMe__c> listNotifyme = [SELECT id, OwnerId FROM AV_NotifyMe__c LIMIT 1];
        for (AV_NotifyMe__c nm : listNotifyme) {
            System.assertEquals(u2.id, nm.OwnerId);
        }
	}
}