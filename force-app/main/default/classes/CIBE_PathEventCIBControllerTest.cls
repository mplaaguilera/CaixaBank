/**********************************************************************************************************************
Name:	  CIBE_PathEventCIBController
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de CIBE_PathEventCIBController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US743059    	Lucia	  	        22/01/2024		Init version
	
***********************************************************************************************************************/

@IsTest
public with sharing class CIBE_PathEventCIBControllerTest {

    @TestSetup
    static void makeData(){
        CIBE_TestInitialSetup.setupInitialDataCIB();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Account acc = CIBE_TestHelper.createCustomer();

        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_CIB_RT);
        Event event = new Event();
        event.Subject = 'Call';
        event.WhatId = acc.Id;
        event.AV_Tipo__c = 'VLD';
        event.OwnerId = usuario.Id;
        
        String externalId = '999999';
        AV_HeaderCustomActivity__c acthead = new AV_HeaderCustomActivity__c(
            AV_ExternalID__c = externalId,
            AV_ToDelete__c = true,
            OwnerId = usuario.Id
        );
        insert acthead;
        
        DateTime dtime = System.now();
        String randomExternalId = String.valueof((Math.random() * 10000000));
        event.AV_ExternalID__c = randomExternalId;
        event.RecordTypeId = rt.Id;
        event.DurationInMinutes= 60;
        event.AV_Task__c=acthead.id;
        event.ActivityDateTime = dtime;
        event.StartDateTime =  dtime;
        event.EndDateTime =  dtime.addMinutes(60);
        event.CSBD_Evento_Estado__c = 'Planificada';
        event.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
        event.Description = 'Prueba';
        insert event;
        
        CBK_Activity_Extension__c actExtension = [SELECT ID, CIBE_ComentarioCita__c, CIBE_ConclusionesCita__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :Event.Id];
        
        actExtension.CIBE_ComentarioCita__c = 'Comentario';
        actExtension.CIBE_ConclusionesCita__c = 'Conclusiones';
        update actExtension;
        
    }

    @isTest
    static void getEvent_Test(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){

            List<Event> evnt = [SELECT Id FROM Event WHERE Subject = 'Call'];
            CIBE_PathEventCIBController.getEvent(evnt[0].Id);
            System.assert(!evnt.isEmpty());
        }
        Test.stopTest();
    }

    @isTest
    static void updateEvent_Test(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){

            List<Event> evnt = [SELECT Id FROM Event WHERE Subject = 'Call'];
            CIBE_PathEventCIBController.updateEvent(evnt[0].Id, 'Realizada');
            System.assert(!evnt.isEmpty());
            List<Event> evntUpdate = [SELECT Id FROM Event WHERE Subject = 'Call' AND CSBD_Evento_Estado__c = 'Realizada'];
            System.assert(!evntUpdate.isEmpty());
            
        }
        Test.stopTest();
    }
}