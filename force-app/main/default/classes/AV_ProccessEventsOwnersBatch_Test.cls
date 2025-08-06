@isTest
private class AV_ProccessEventsOwnersBatch_Test {
    @TestSetup
    static void setup() {
        AV_TestHelper.activateLogger();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));

        User u1 = AV_TestHelper.createUser('AV_Usuario_CaixaBank', 'U0100001');
        Contact con = AV_TestHelper.createEmployee(null, u1);

        List<Event> events = new List<Event>();
        Account acc = AV_TestHelper.createCustomer();
        RecordType rt = AV_AppUtilities.getRecordType('Event', 'AV_EventosConCliente');
        Datetime now = Datetime.now(); 

        for (Integer i = 0; i < 1; i++) {
            Event evt = new Event();
            evt.Subject = 'Call ' + i;
            evt.OwnerId = u1.id;
            evt.AV_ExternalID__c = '01928374' + i;
            evt.RecordTypeId = rt.Id;
            evt.DurationInMinutes = 60;
            evt.WhatId = acc.id;
            evt.ActivityDateTime = now;
            evt.AV_CodigoGestorAsignado__c = 'U0100002';
            events.add(evt);
        }
        insert events;

        User u2 = AV_TestHelper.createUser('AV_Usuario_CaixaBank', 'U0100002');
        con.AV_UsuarioAsociado__c = u2.Id;
        update con;

        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            AV_TestHelper.insertPermissionSet(u1.id, 'AV_GestorOperativa');
            AV_TestHelper.insertPermissionSet(u2.id, 'AV_GestorOperativa');
        }
    }

    @isTest
    static void executeProccessEventsOwnersBatch() {
        User u2 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0100002' LIMIT 1];
        Set<String> setUserIds = new Set<String>{u2.Id};
        AV_LogDebug.printLogDebug('executeProccessEventsOwnersBatch', 'User2: ' + u2);
        AV_ProccessEventsOwnersBatch b = new AV_ProccessEventsOwnersBatch('10', setUserIds);
        AV_ProccessEventsOwnersBatch c = new AV_ProccessEventsOwnersBatch();  

        Test.startTest();    
        Database.executeBatch(b);
        Test.stopTest();

        List<Event> listEvt = [SELECT id, OwnerId FROM Event];
        for (Event evt : listEvt) {
            System.assertEquals(u2.id, evt.OwnerId);
        }
    }
}