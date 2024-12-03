/**********************************************************************************************************************
Name:	  AV_RedirectChildEvent_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_RedirectChildEvent_Controller"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY			AUTHOR				DATE			Description
    1.0			Test Class		Vladislav Lityagin		24/03/2023		Init version
    1.1         Fix             Patricia Villacañas     18/05/2023      Modified to set run as
	1.2			Ejec. Lentas	Sandra Gómez			22/02/2024		Coverage
***********************************************************************************************************************/
@isTest
public with sharing class AV_RedirectChildEvent_Controller_Test {

	@TestSetup
    static void setup(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
            AV_TestHelper.activateLogger();
            List<User> usrList = new List<User>();
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
            Account acc = AV_TestHelper.createCustomer();
            User u = AV_TestHelper.createUserSinInsert('','U012345','AV_SistematicaComercial');
            usrList.add(u);
            User u2 = AV_TestHelper.createUserSinInsert('','U0123456','AV_SistematicaComercial');
            u2.Email = 'test2@test.dev';
            usrList.add(u2);
            insert usrList;
            AV_TestHelper.insertNeededPermissions(u);
            AV_TestHelper.insertNeededPermissions(u2);
            DateTime dt = System.now();
            RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTCLIENTE_RT);
            Event event = new Event();
            event.Subject = 'Call';
            event.OwnerId = u.Id;
           	event.AV_ExternalID__c = '12345';
            event.RecordTypeId = rt.Id;
            event.DurationInMinutes= 60;
            event.ActivityDateTime = dt;
            event.StartDateTime = dt;
            event.WhatId = acc.Id;
            event.AV_CodigoGestorAsignado__c='U012345';
            insert event;
            EventRelation invitee = new EventRelation(EventId = event.Id, RelationId = u2.Id, IsInvitee = true);
            insert invitee;
        }
    }
    
    @isTest
    public static void redirectToParentTest() {
        User u = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U012345'];
        System.runAs(u){
            Test.startTest();
            List<Event> evt = [SELECT Id FROM Event WHERE Subject='Call'];
            String parentId = AV_RedirectChildEvent_Controller.redirectToParent(evt[0].Id);
            Test.stopTest();
            system.assertEquals(true, parentId.length()>0);
        }
    }
}