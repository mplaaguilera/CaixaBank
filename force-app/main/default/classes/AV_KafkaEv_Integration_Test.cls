/**********************************************************************************************************************
Name:	  AV_KafkaEv_Integration_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: clase test de AV_KafkaEv_Integration
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY                                 AUTHOR                            DATE            COMMENTS
    1.0         US-0006226                                 David Ramos Dominguez             02/10/2023      Created
***********************************************************************************************************************/
@isTest
public with sharing class AV_KafkaEv_Integration_Test {
    
    private static final String METADATA = 'AV_KafkaEvent';
    
    @TestSetup
	static void setup() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        
        System.runAs(userGcf){
            //necesito una Account Oficina, una Account Cliente con AV_OficinaPrincipal__c=Oficina, un Event con WhatId=Cliente
            AV_TestHelper.activateLogger();
            Account oficina = AV_TestHelper.createCaixaCenter();
            oficina.CC_Numero_Oficina_Empresa__c = 'XXX-00615'; //before insert Account trigger hace substring(4,9) de CC_Numero_Oficina_Empresa__c
            update(oficina);
            Account cliente = AV_TestHelper.createCustomer();
            cliente.AV_OficinaPrincipal__c = oficina.Id;
            update(cliente);

            // RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
            // Account cliente = new Account(
            //         FirstName = 'FirstName',
            //         LastName = 'LastName',
            //         RecordTypeId = rt.Id,
            //         AV_NumPerso__c = '123',
            //         AV_Negocio__c = 'BPA',
            //         CC_Numero_Documento__c = '9446386T',
            //         AV_OficinaPrincipal__c = oficina.Id
            //         // AV_Confidencial__c = false
            //     );
            // insert cliente;

            User u = AV_TestHelper.createUser('Standard User');

            Datetime activityDate = Datetime.newInstance(2090, 10, 02);
            Event evento1 = AV_TestHelper.createEvent(u, activityDate,  cliente); 
            //genera un evento con RecordType AV_EventosConCliente
            
            Event evento2 = AV_TestHelper.createEventVideocCall(u, activityDate,  cliente); 
            // //aunque se pongan a null manualmente se les asigna una EndDateTime y StartDateTime automaticamente
            // evento2.EndDateTime = null;
            // evento2.StartDateTime = null;
            evento2.Subject = null;
            Contact c = AV_TestHelper.createEmployee(oficina, userGcf);
            evento2.WhoId = c.id; //tiene que ser Contact
            evento2.AV_ExternalID__c = null;
            evento2.AV_InOutbound__c = null;
            evento2.AV_Task__c = null;
            evento2.AV_Tipo__c = null;
            evento2.CSBD_Evento_Estado__c = null;
            evento2.AV_OrigenApp__c = null;
            evento2.Location = 'Barcelona';
            evento2.AV_AssociatedOpportunityId__c = 'XXXXXX';
            evento2.AV_BranchPhysicalMeet__c = 'Barcelona';
            evento2.AV_Center__c = oficina.Id;

            Event eventoRecurrente = AV_TestHelper.createEventConClienteRecurrente(userGcf, cliente);

            List<Event> evs = new List<Event>();
            evs.add(evento1);
            evs.add(evento2);
            evs.add(eventoRecurrente);
            
            update(evs);
            //EVENTGESTOR_RT
        }
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_JOBLEVEL','OK'));
    }

    public static List<Event> createListEvents(Integer numEvents){
        user avUser;
        avUser = AV_TestHelper.createUser('AV_Usuario_CaixaBank');
        Account acc = new Account();
        acc = AV_TestHelper.createCustomer();
        Datetime activityDate = Datetime.newInstance(2023, 10, 02);

        List<Event> events = new List<Event>();

        for (Integer i = 0; i<numEvents; i++){
            Event e = new Event();
            e = AV_TestHelper.createEvent(avUser,activityDate,acc);
            events.add(e);
        }

        return events;
    }

    @isTest
    private static void testSendEventNoOfficeFilter(){
        User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];

        List<Event> events = new List<Event>();
        //events = createListEvents(5);
        events = [SELECT ID, ENDDATETIME, OWNERID, STARTDATETIME, SUBJECT, WHATID, WHOID, RECORDTYPEID, AV_CODIGOGESTORASIGNADO__C, AV_EXTERNALID__C, AV_INOUTBOUND__C, AV_TASK__C, AV_TIPO__C, AV_TODELETE__C, CSBD_EVENTO_ESTADO__C, AV_ORIGENAPP__C, ISALLDAYEVENT, LOCATION, ISPRIVATE, ISRECURRENCE2, AV_ASSOCIATEDOPPORTUNITYID__C, LASTMODIFIEDBYID, AV_BRANCHPHYSICALMEET__C, AV_CENTER__C, CREATEDDATE,IsRecurrence FROM Event LIMIT 5];
        String integrationId = '0000002';
        Integer result;
        system.debug('list of events is created with size:');
        system.debug(events.size());
        String originalNameMd;
        String newNameMd = 'AV_KafkaEventTest1';
        String finalNameMd;
        Test.startTest();
        
        System.runAs(userCli){
            originalNameMd = AV_KafkaEv_Integration.getMetadataName();
            //hacer que el metadato no tenga offices para filtrar
            AV_KafkaEv_Integration.setMetadataName(newNameMd);

            AV_KafkaEv_Integration.syncEventsKafka(events);
            
            //devolver el valor original al metadato
            AV_KafkaEv_Integration.setMetadataName(originalNameMd);
            finalNameMd = AV_KafkaEv_Integration.getMetadataName();
        }
        Test.stopTest();

        System.assertEquals(originalNameMd, finalNameMd, 'The metadata has the original value at the end');
    }

    @isTest
    private static void testSendEventWithOfficeFilter(){
        User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];

        List<Event> events = new List<Event>();
        //events = createListEvents(5);
        events = [SELECT ID, ENDDATETIME, OWNERID, STARTDATETIME, SUBJECT, WHATID, WHOID, RECORDTYPEID, AV_CODIGOGESTORASIGNADO__C, AV_EXTERNALID__C, AV_INOUTBOUND__C, AV_TASK__C, AV_TIPO__C, AV_TODELETE__C, CSBD_EVENTO_ESTADO__C, AV_ORIGENAPP__C, ISALLDAYEVENT, LOCATION, ISPRIVATE, ISRECURRENCE2, AV_ASSOCIATEDOPPORTUNITYID__C, LASTMODIFIEDBYID, AV_BRANCHPHYSICALMEET__C, AV_CENTER__C, CREATEDDATE,IsRecurrence FROM Event LIMIT 5];
        String integrationId = '0000002';
        Integer result;
        system.debug('list of events is created with size:');
        system.debug(events.size());
        String originalNameMd;
        String newNameMd = 'AV_KafkaEventTest2';
        String finalNameMd;
        Test.startTest();
        
        System.runAs(userCli){
            originalNameMd = AV_KafkaEv_Integration.getMetadataName();
            //hacer que el metadato tenga el num office que pone AV_TestHelper.createEvent para filtrar
            AV_KafkaEv_Integration.setMetadataName(newNameMd);

            AV_KafkaEv_Integration.syncEventsKafka(events);
            
            //devolver el valor original al metadato
            AV_KafkaEv_Integration.setMetadataName(originalNameMd);
            finalNameMd = AV_KafkaEv_Integration.getMetadataName();
        }
        Test.stopTest();

        System.assertEquals(originalNameMd, finalNameMd, 'The metadata has the original value at the end');
    }
}