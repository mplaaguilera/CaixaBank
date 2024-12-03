/**********************************************************************************************************************
 Name:      AV_ProccessEventsOwnersBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_ProccessEventsOwnersBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY       AUTHOR               DATE                Description
   1.0            App FSC          Jashanpreet Singh    07/10/2020          Init version
   1.1			  US164515		   Sandra Gómez			27/01/2021			Remodel Test
   1.2			  App FSC		   David Rufo			11/02/2020			Improve batch for execution list users

***********************************************************************************************************************/
@isTest
private class AV_ProccessEventsOwnersBatch_Test {
	/**
	 * Create 10 Accounts with the field AV_BatchProccessOwners__c 'ToBeProcess'.
	 */
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
		User u1 = AV_TestHelper.createUser('AV_Usuario_CaixaBank', 'U0100001');
        //AV_LogDebug.printLogDebug('setup', 'User1: ' + u1);
        Contact con =  AV_TestHelper.createEmployee(null,u1);
        //AV_LogDebug.printLogDebug('setup', 'Contact: ' + con);
        
        List<Event> events = new List<Event>();
        Account acc = AV_TestHelper.createCustomer();
		RecordType rt = AV_AppUtilities.getRecordType('Event', 'AV_EventosConCliente');
        
		for (Integer i=0;i<10;i++) {
            Event evt = new Event();
            evt.Subject = 'Call '+ i;
            evt.OwnerId = u1.id;
            evt.AV_ExternalID__c = '01928374'+i;
            evt.RecordTypeId = rt.Id;
            evt.DurationInMinutes= 60;
            evt.WhatId =acc.id;
            evt.ActivityDateTime = datetime.now();
            evt.AV_CodigoGestorAsignado__c = 'U0100002';
            events.add(evt);
        }
		insert events;
        
        User u2 = AV_TestHelper.createUser('AV_Usuario_CaixaBank', 'U0100002');
        //AV_LogDebug.printLogDebug('setup', 'User2: ' + u2);
        con.AV_UsuarioAsociado__c = u2.Id;
        update con;
        
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            AV_TestHelper.insertPermissionSet(u1.id, 'AV_GestorOperativa');
            AV_TestHelper.insertPermissionSet(u2.id, 'AV_GestorOperativa');
        }
	}

	/**
	 * Execute the Batch class (AV_ProccessEventsOwnersBatch) 
	 */
	@isTest
	static void executeProccessEventsOwnersBatch() {
		User u2 = [SELECT Id FROM User where AV_ExternalID__c = 'U0100002' limit 1];
        Set<String> setUserIds = new Set<String>{u2.Id};
        AV_LogDebug.printLogDebug('executeProccessEventsOwnersBatch', 'User2: ' + u2);
        AV_ProccessEventsOwnersBatch b = new AV_ProccessEventsOwnersBatch('300', setUserIds);
        
		Test.startTest();	
		Database.executeBatch(b);
		Test.stopTest();
        
        List<Event> listEvt = [SELECT id, OwnerId FROM Event];
        for (Event evt : listEvt) {
            System.assertEquals(u2.id, evt.OwnerId);
        }
	}
}