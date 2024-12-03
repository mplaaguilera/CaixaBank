/**********************************************************************************************************************
 Name:      AV_ProcessInactiveUserEventsBatch_Test
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_ProcessInactiveUserEventsBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION     USER_STORY      AUTHOR              DATE                Description
    1.0			US306420		Víctor Santiago     20/12/2021			Init version
	1.1			US306420		Sandra Gómez	    21/01/2022			Fix
    1.2	        AV_Query IT		Daniel Rodríguez	3/02/2022			Change AV_Query to SOQL for User and Account

***********************************************************************************************************************/
@isTest
private class AV_ProcessInactiveUserEventsBatch_Test {
    
    @TestSetup
    static void setup(){
        List<Event> evtsCliente = new List<Event>();
        List<AV_CustomActivityOpportunity__c> tOpps = new List<AV_CustomActivityOpportunity__c>();
        Test.startTest();
        User u = AV_TestHelper.createUser(null, 'U0009003121213');
        Account center = AV_TestHelper.createCaixaCenter();
        Contact c = AV_TestHelper.createEmployee(center, u,u.AV_ExternalId__c);
        Account a = AV_TestHelper.createCustomer();
		RecordType rt = AV_AppUtilities.getRecordType('Event', 'AV_EventosConCliente');
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        for (Integer i = 0; i < 10; i++) {
			Event e = new Event();
			e.Subject = 'Call' + i;
			e.OwnerId = u.Id;
			e.AV_ExternalID__c = '01928374' + i;
			e.RecordTypeId = rt.Id;
            e.DurationInMinutes = 60;
            e.WhatId = a.Id;
            if (i > 7) {
                e.ActivityDateTime = System.now().addDays(1);
            }else {
                e.ActivityDateTime = System.now().addDays(-1);
            }
            e.AV_CodigoGestorAsignado__c='U0009003121213';
            evtsCliente.add(e);
		}
		insert evtsCliente;
        AV_TestHelper.createPricebook2();
        Opportunity o = AV_TestHelper.createOpportunity(a);
        Test.stopTest();
    }

    @isTest
    static void executeProcessInactiveUserEventsBatch() {
        Set<String> extIds = new Set<String> {'019283740','019283741','019283742','019283743',
            '019283744','019283745','019283746','019283747','019283748','019283749'};
        Set<String> headersIds = new Set<String>();
        Opportunity opp = [SELECT OwnerId,AV_ExternalID__c,Id FROM Opportunity LIMIT 1];
        List<AV_HeaderCustomActivity__c> listheaders = [SELECT OwnerId,AV_ExternalID__c,Id FROM AV_HeaderCustomActivity__c  
                                                        WHERE AV_ExternalID__c IN :extIds];
        List<AV_CustomActivityOpportunity__c> listaTareaOpps = new List<AV_CustomActivityOpportunity__c>();
        Test.startTest();
        for (Integer i = 0; i < listheaders.size(); i++) {
            listaTareaOpps.add(AV_TestHelper.createTareaOportunidadSinInsert(opp, listheaders.get(i).Id));
        }
        insert listaTareaOpps;
  
        User u = [Select Id From User Where AV_ExternalID__c = 'U0009003121213' limit 1];
        AV_ProcessInactiveUserEventsBatch batch = new AV_ProcessInactiveUserEventsBatch('10000', new Set<String>{u.Id});
        Database.executeBatch(batch);
        User asesor = [Select Id From User Where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        

        List<AV_CustomActivityOpportunity__c> tareasOps = [SELECT OwnerId FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c IN :headersIds];
        for (AV_CustomActivityOpportunity__c to : tareasOps) {
            System.assertEquals(to.OwnerId, asesor.Id, 'Tarea-Oportunidad OwnerId not changed');
        }

        Test.stopTest();

        List<Event> evts = [SELECT OwnerId,Id FROM Event WHERE AV_ExternalID__c IN :extIds];
        for (Event e : evts) {
            System.assertEquals(e.OwnerId, asesor.Id, 'Events OwnerId not changed');
        }
       

        List<AV_HeaderCustomActivity__c> headers = [SELECT OwnerId FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c IN :extIds];
        for (AV_HeaderCustomActivity__c h : headers) {
            System.assertEquals(h.OwnerId, asesor.Id, 'Headers OwnerId not changed');
            headersIds.add(h.Id);
        }
    }
}