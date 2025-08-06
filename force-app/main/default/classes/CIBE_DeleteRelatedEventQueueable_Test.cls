/**********************************************************************************************************************
Name:	  CIBE_DeleteRelatedEventQueueable_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Test para eliminar la clase CIBE_DeleteRelatedEventQueueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			Init version        Lucía		        30/05/2023			Init version

***********************************************************************************************************************/

@isTest
public with sharing class CIBE_DeleteRelatedEventQueueable_Test {

    @TestSetup
    static void makeData(){
        CIBE_TestInitialSetup.setupInitialDataEMP();
        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);


        System.runAs(u){
            Account acc = CIBE_TestHelper.createCustomer(u);

            Event evento = new Event();
            evento.Subject = 'Call';
            evento.WhatId = acc.Id;
                String externalId = '999999';
                String randomExternalId = String.valueof((Math.random() * 10000000));
                evento.AV_ExternalID__c = randomExternalId;
                evento.RecordTypeId = rt.Id;
                evento.DurationInMinutes= 60;
                evento.AV_Tipo__c = 'EC';
                evento.ActivityDateTime = System.now();
                evento.CSBD_Evento_Estado__c = CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
                evento.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
                evento.OwnerId = u.Id;
            insert evento;



            CBK_Activity_Extension__c eventExtension = new CBK_Activity_Extension__c();
            eventExtension.AV_ActivityId__c = evento.Id;
            eventExtension.OwnerId = u.Id;
        
            insert eventExtension;

            AV_ManagementHistory__c hsitory = new AV_ManagementHistory__c();
            hsitory.AV_ActivityId__c = evento.Id;
            hsitory.OwnerId = u.Id;
            insert hsitory;

            Contact empleado  = CIBE_TestHelper.createEmployee(acc, u);
            Opportunity opp =  CIBE_TestHelper.createOpportunityExternalId(acc, empleado, evento.AV_ExternalID__c);
            List<AV_HeaderCustomActivity__c> listHeaderEvent = [SELECT Id FROM AV_HeaderCustomActivity__c];
            AV_CustomActivityOpportunity__c cao = CIBE_TestHelper.createTareaOportunidad(opp,listHeaderEvent[0].id);
        }
    }


    @isTest
	public static void validateQueueble() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        List<AV_ManagementHistory__c> managementHistoryList = new List<AV_ManagementHistory__c>();
        List<CBK_Activity_Extension__c> eventExtensionList = new List<CBK_Activity_Extension__c>();
        List<AV_CustomActivityOpportunity__c> eventOppList = new List<AV_CustomActivityOpportunity__c>();
        List<AV_HeaderCustomActivity__c> listHeaderEvent = new List<AV_HeaderCustomActivity__c>();
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
        System.runAs(usuario) {
            List<Event> listEvent = [SELECT Id,AV_Task__c,AV_ExternalID__c, OwnerId  FROM Event WHERE  recordTypeId =: rt.id ];
            Map<Id, Event> mapIdsEvent = new Map<Id, Event>(listEvent);
            listHeaderEvent = [SELECT Id FROM AV_HeaderCustomActivity__c];
            Test.startTest();
            delete listEvent;
            Test.stopTest();
            managementHistoryList = [Select Id From AV_ManagementHistory__c WHERE AV_ActivityId__c =: listEvent[0].id];
            eventExtensionList = [Select Id From CBK_Activity_Extension__c];
            eventOppList = [Select Id, AV_Task__c From AV_CustomActivityOpportunity__c];
            listHeaderEvent = [SELECT Id FROM AV_HeaderCustomActivity__c];
            System.assertEquals(true, managementHistoryList.isEmpty());
            System.assertEquals(true, eventExtensionList.isEmpty());
            System.assertEquals(true, eventOppList.isEmpty());
            System.assertEquals(true, listHeaderEvent.isEmpty());
        }
       
	}
}