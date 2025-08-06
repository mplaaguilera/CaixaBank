/************************************************************************************************************************************************************************************************
 Name:      CIBE_NewEventControllerTest
 Copyright © 2023  CaixaBank
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test para la clase CIBE_NewEventController
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY       AUTHOR              DATE                Description
    1.0                             Álvaro, Lucía                           Init Version
    1.1            US774293         Bea                 12/02/2024          Se añade el método createOrUpdateTasks_Test y se mejoran otros metodos para aumentar la cobertura de la clase test
    1.2            FIX20241342      Gonzalo             01/10/2024          Añadimos métodos syncEventsTest y getGrupoComercialTest para ajustar cobertura
***************************************************************************************************************************************************************************************************/



@IsTest
public with sharing class CIBE_NewEventControllerTest {

    @TestSetup
    static void makeData(){
        List <String> psA = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        ID rtOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.OPP_INICIATIVAEMP_RT).getRecordTypeId();
        String rtAccountRelation = Schema.SObjectType.FinServ__AccountAccountRelation__c.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();
        Id rtRole = Schema.SObjectType.FinServ__ReciprocalRole__c.getRecordTypeInfosByDeveloperName().get('AccountRole').getRecordTypeId();

        
        CIBE_TestInitialSetup.setupInitialData(null, CIBE_AppConstants.CIBE_ROLEMP, null, null, null, psA);
        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        User usrGes = [SELECT Id, Name FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Contact c = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :usrGes.Id];

    
        System.runAs(usrSetup){

            Test.startTest();
            User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');

            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            RecordType rtGC = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_G_COMERCIAL_RT);

            Account acc = new Account(
                Name = 'Name',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '123',
                AV_Negocio__c = 'CIB',
                OwnerId = usrGes.Id
            );
            insert acc;


            Account acc2 = new Account(
                Name = 'Name2',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '631',
                AV_Negocio__c = 'CIB',
                OwnerId = usrGes.Id
            );
            insert acc2;

            Account accGC = new Account(
                Name = 'GC-Account',
                RecordTypeId = rtGC.Id,
                AV_NumPerso__c = '654',
                AV_Negocio__c = 'CIB',
                OwnerId = usrGes.Id
            );
            insert accGC;


            FinServ__ReciprocalRole__c role = new FinServ__ReciprocalRole__c(
                Name = 'Child',
                OwnerId = usrGes.Id,
                RecordTypeId = rtRole,
                FinServ__InverseRole__c = 'Cliente'
            );
            insert role;

            FinServ__ReciprocalRole__c role2 = new FinServ__ReciprocalRole__c  (
                Name = 'Parent',
                RecordTypeId = rtRole,
                FinServ__InverseRole__c = 'Child',
                OwnerId = usrGes.Id,
                FinServ__InverseRelationship__c = role.Id
            );
            insert role2;

            FinServ__AccountAccountRelation__c accR = new FinServ__AccountAccountRelation__c(
                RecordtypeId = rtAccountRelation, 
                FinServ__Account__c = acc.id,
                FinServ__RelatedAccount__c = accGC.id,
                FinServ__Role__c = role.id,
                OwnerId = usrGes.Id,
                AV_ToDelete__c = false
            );
            insert accR;

            FinServ__AccountAccountRelation__c accR2 = new FinServ__AccountAccountRelation__c(
                RecordtypeId = rtAccountRelation, 
                FinServ__Account__c = accGC.id,
                FinServ__RelatedAccount__c = acc2.Id,
                FinServ__Role__c = role2.id,
                AV_ToDelete__c = false,
                OwnerId = usrGes.Id
            );
            insert accR2;
        


            Contact cont = CIBE_TestHelper.createRepresentante(acc, usrSetup, '001');

            Product2 prod = new Product2();
            prod.Name = 'Product Test';
            prod.AV_Nivel__c = null;
            prod.AV_ExternalID__c = '50000';
            prod.AV_Profesional__c = false;
            prod.AV_Activo__c = true;
            prod.AV_OwnerId__c = usrGes.Id;
            insert prod;
			
        	String externalId = '999999';
        
        	AV_HeaderCustomActivity__c acthead = new AV_HeaderCustomActivity__c(
                AV_ExternalID__c = externalId,
                AV_ToDelete__c = true,
                OwnerId = usrGes.Id
            );
            insert acthead;
           
            RecordType rtE = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
            Event event = new Event();
            event.Subject = 'Call';
            event.WhatId = acc.Id;
            event.AV_Tipo__c = 'VLD';
            event.OwnerId = usrGes.Id;
            
            DateTime now = System.now();
            String randomExternalId = String.valueof((Math.random() * 10000000));
            event.AV_ExternalID__c = randomExternalId;
            event.RecordTypeId = rtE.Id;
            event.DurationInMinutes= 60;
            event.AV_Task__c=acthead.id;
            event.ActivityDateTime = now;
            event.StartDateTime = now;
            event.EndDateTime = System.now().addMinutes(60);
            event.CSBD_Evento_Estado__c = CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
            event.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
            event.Description = 'Prueba';
            event.WhoId = cont.Id;
            insert event;
        
        
            CIBE_TestHelper.createAccountTeamMember(usrGes, acc);


            AV_ProductExperience__c prodExp = new AV_ProductExperience__c();
            prodExp.AV_ExternalID__c = 'EMP_50000';
            prodExp.AV_ProductoFicha__c = prod.Id;
            insert prodExp;

            Opportunity opp = new Opportunity();
            opp.ownerId = usrGes.Id;
            opp.RecordTypeId = rtOpp;
            opp.CloseDate = System.today();
            opp.AccountId = acc.Id;
            opp.Name = 'Alerta Comercial Test';
            opp.StageName = 'CIBE_Vencido';
            opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
            opp.CIBE_LastUpdatedCerradoNegativo__c = Date.newInstance(2023, 10, 9);

        insert opp;  


        AccountContactRelation accRelation = new AccountContactRelation();
        accRelation.AccountId = acc.Id;
        accRelation.ContactId = c.Id;
        insert accRelation;
        }
        Test.stopTest();

    }

    @IsTest
    static void searchEmployeesTest(){
        User usuario = [SELECT Id, Name FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = usuario.Id;
            Test.setFixedSearchResults(fixedSearchResults);
            List<AV_LookupSearchResult> ususarios = CIBE_NewEventController.searchEmployees(usuario.Name);
            System.assert(!ususarios.isEmpty());
        }
        Test.stopTest();
    }

    @IsTest
    static void getContactosApoderadosTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Account acc = [SELECT Id FROM Account WHERE CreatedDate = TODAY  AND Name = 'Name'];
            List<Contact> contactosApoderados = CIBE_NewEventController.getContactosApoderados(acc.Id);
            System.assert(!contactosApoderados.isEmpty());
            
        }
        Test.stopTest();
    }

    @IsTest
    static void searchProductTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Account acc = [SELECT Id FROM Account WHERE CreatedDate = TODAY  AND Name = 'Name'];
            Product2 product = [SELECT Id, Name FROM Product2 WHERE Name = 'Product Test'];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = product.Id;
            Test.setFixedSearchResults(fixedSearchResults);
            List<AV_LookupSearchResult> productos = CIBE_NewEventController.searchProduct(product.Name, acc.Id);
            System.assert(!productos.isEmpty());
            
        }
        Test.stopTest();
    }

    @IsTest
    static void createEventTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        DateTime now = System.now();
        Test.startTest();
        System.runAs(usuario) {

            Account acc = [SELECT Id FROM Account WHERE CreatedDate = TODAY  AND Name = 'Name'];
            Contact c = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :usuario.Id];

            Event evento = new Event();
            evento.WhatId = acc.Id;
            evento.WhoId = c.Id;
            evento.OwnerId = usuario.Id;
            evento.Subject = 'Test';
            evento.ActivityDateTime = now;
            evento.StartDateTime = now;
            evento.FinServ__NextSteps__c = acc.id;
            evento.EndDateTime = System.now().addMinutes(60);
            String estado = 'Pendiente';

            CIBE_NewEventController.createEvent(evento, estado);
            List<Event> evnt = [SELECT Id FROM Event WHERE Subject = 'Test'];
            System.assert(!evnt.isEmpty());

        Test.stopTest();
        }
    }


    @IsTest
    static void createEventRelationTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            List<Contact> c = [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE AV_UsuarioAsociado__c = :usuario.Id];
            Event evento = [SELECT Id,RecordTypeId, AV_Tipo__c, CreatedById FROM Event WHERE Subject = 'Call'];
            List<String> attendees = new List<String>();

            if(!c.isEmpty()){
                for (Contact con : c) {
                    attendees.add(con.AV_UsuarioAsociado__c);
                }
            }

            CIBE_NewEventController.callApiTeams(evento, attendees, null);
            List<EventRelation> evntRelation = [SELECT Id FROM EventRelation WHERE EventId = :evento.Id];
            System.assert(evntRelation != null);
            
        }
        Test.stopTest();
    }

    @IsTest
    static void createEventRelationTest2(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            List<Contact> c = [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE AV_UsuarioAsociado__c = :usuario.Id];
            Contact personaContacto = [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE FirstName = 'Empleado'];
            Event evento = [SELECT Id,RecordTypeId, AV_Tipo__c, CreatedById FROM Event WHERE Subject = 'Call'];
            List<String> attendees = new List<String>();

            if(!c.isEmpty()){
                for (Contact con : c) {
                    attendees.add(con.AV_UsuarioAsociado__c);
                }
            }

            CIBE_NewEventController.callApiTeams(evento, attendees, personaContacto.Id);
            List<EventRelation> evntRelation = [SELECT Id FROM EventRelation WHERE EventId = :evento.Id];
            System.assert(evntRelation != null);
            
        }
        Test.stopTest();
    }

    @IsTest
    static void searchUserCXBTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Contact employee = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName = 'CC_Empleado' AND FirstName = 'Employee'];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = employee.Id;
            Test.setFixedSearchResults(fixedSearchResults);
            List<String> selectIds = new List<String>();
            List<AV_LookupSearchResult> results = CIBE_NewEventController.searchUserCXB(employee.Name, selectIds);
            System.assert(!results.isEmpty());
            
           
        }
        Test.stopTest();
    }


    @IsTest
    static void searchUserEMPTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Contact employee = [SELECT Id, Name, AccountId FROM Contact WHERE RecordType.DeveloperName = 'CIBE_Apoderado' AND FirstName = 'Empleado'];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = employee.Id;
            Test.setFixedSearchResults(fixedSearchResults);
            List<AV_LookupSearchResult> results = CIBE_NewEventController.searchUserEMP(employee.Name, new List<String>(),employee.AccountId);
            System.assert(!results.isEmpty());
        }
        Test.stopTest();
    }


    @IsTest
    static void searchUserTeamCXBTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Account acc = [SELECT Id FROM Account WHERE CreatedDate = TODAY  AND Name = 'Name'];
            List<AV_LookupSearchResult> results = CIBE_NewEventController.searchUserTeamCXB(acc.Id);
            System.assert(!results.isEmpty());
        }
        Test.stopTest();
    }

    @IsTest
    static void createOrUpdateOpportunitiesTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        Test.startTest();
        System.runAs(usuario) {
            Account acc = [SELECT Id FROM Account WHERE CreatedDate = TODAY  AND Name = 'Name'];
            Boolean insertOpp = true;
            Date today = System.Today();
            String todayString = String.valueOf(today);
            Map<String,Map<String,Object>> mapToTest = new Map<String,Map<String,Object>>();
            mapToTest.put((insertOpp)?'idProvisional0': 's',
                new Map<String,Object>{

                    'newPath' => 'En curso',
                    'id' => 'idProvisional0',
                    'Name' => 'Test',
                    'ProdId' => null,
                    'oppoDate' => todayString,
                    'fechaCierre' => todayString,
                    'probabilidad' => 'Media',
                    'comentario' => 'test',
                    'divisa' => '453',
                    'importe' => '666',
                    'impactoBalance' => null,
                    'impactoComisiones' => null,
                    'entidad' => 'true',
                    'vencimiento' => null,
                    'precio' => '234',
                    'margen' => '3',
                    'confidencial' => false,
                    'esg' => false,
                    'impactoBalance' => '12',
                    'impactoComisiones' => '111',
                    'vencimiento' => todayString,
                    'agendado' => true
                });


                CIBE_NewEventController.CreatedOpportunitiesWrapper testResponse = CIBE_NewEventController.createOrUpdateOpportunities(mapToTest,acc.Id, todayString, false);
                List<Opportunity> opp = [SELECT Id, closeDate FROM Opportunity WHERE Name = 'Test' AND StageName = 'En curso' and closeDate =:today and CIBE_AmountDivisa__c = 666 ];
                System.assert(!opp.isEmpty());
        }
        Test.stopTest();
    }

    @IsTest
    static void createOrUpdateOpportunities2Test(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario) {
            Account acc = [SELECT Id FROM Account WHERE CreatedDate = TODAY  AND Name = 'Name'];
            Opportunity opp = [SELECT Id, Name, StageName FROM Opportunity WHERE Name = 'Alerta Comercial Test' AND StageName = 'CIBE_Vencido'LIMIT 1];
            System.assert(opp != null);
            Boolean insertOpp = true;
            Date today = System.Today();
            String todayString = String.valueOf(today);
            Map<String,Map<String,Object>> mapToTest = new Map<String,Map<String,Object>>();
            mapToTest.put((insertOpp)?'isEditable': 's',
                new Map<String,Object>{
                    'newPath' => opp.StageName,
                    'stageName' => opp.StageName,
                    'id' => opp.Id,
                    'Name' => opp.Name,
                    'ProdId' => null,
                    'oppoDate' => todayString,
                    'fechaCierre' => todayString,
                    'probabilidad' => 'Media',
                    'comentario' => 'test',
                    'divisa' => '453',
                    'importe' => '666',
                    'impactoBalance' => null,
                    'impactoComisiones' => null,
                    'entidad' => 'true',
                    'vencimiento' => null,
                    'precio' => '234',
                    'margen' => '3',
                    'confidencial' => false,
                    'esg' => false,
                    'impactoBalance' => '12',
                    'impactoComisiones' => '111',
                    'vencimiento' => todayString,
                    'agendado' => true
                });

                CIBE_NewEventController.CreatedOpportunitiesWrapper testResponse = CIBE_NewEventController.createOrUpdateOpportunities(mapToTest,acc.Id, todayString, true);
                //List<Opportunity> oppList = [SELECT Id, closeDate, StageName FROM Opportunity WHERE Name = 'Alerta Comercial Test' AND StageName = :CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO];
                List<Opportunity> oppList = [SELECT Id, closeDate, StageName FROM Opportunity WHERE id =:opp.id];
                System.assert(!oppList.isEmpty());
        }
        Test.stopTest();
    }

    @IsTest
    static void createOrUpdateTasksTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Account acc = [SELECT Id FROM Account WHERE CreatedDate = TODAY  AND Name = 'Name'];
            Boolean insertTask = true;
            Date today = System.Today()+1;
            String todayString = String.valueOf(today);
            String externalId = String.valueof((Math.random() * 10000000));
            AV_HeaderCustomActivity__c acthead = new AV_HeaderCustomActivity__c(
                AV_ExternalID__c = externalId,
                AV_ToDelete__c = false,
                OwnerId = usuario.Id
            );
            RecordType rtTask = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);
            Map<String,Map<String,Object>> mapToTest = new Map<String,Map<String,Object>>();
            mapToTest.put((insertTask)?'idProvisional': 's',
                new Map<String,Object>{
                    'id' => 'idProvisional',
                    'rt' => rtTask.Id,
                    'accountId' => acc.Id,
                    'subject' => 'Subject test',
                    'tareaDate' => todayString,
                    'status' => 'Open',
                    'owner' => usuario.Id,
                    'comments' => 'Prueba de comentario',
                    'vinculed' => true,
                    'mainVinculed' => true,
                    'headerId' => acthead.Id,
                    'isEditable' => true
                });

                CIBE_NewEventController.CreatedTasksWrapper testResponse = CIBE_NewEventController.createOrUpdateTasks(mapToTest,acc.Id);
                List<Task> task = [SELECT Id, Status, Subject FROM Task WHERE Subject = 'Subject test' AND accountId=:acc.Id AND RecordtypeId =:rtTask.Id];
                System.assert(!task.isEmpty());
        }
        Test.stopTest();
    }

    @IsTest
    static void backupEventsAndAttendesTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        
        System.runAs(usuario) {
            List<String> recordsToDelete = new List<String>();
            String jsonEventToBackReport = null;

            Event evtCreated = [SELECT Id,AV_Task__c  FROM Event WHERE Subject = 'Call'];
            Id createdEvent = evtCreated.Id;

            User attende = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];
            Id idToTest;
			Test.startTest();
            List<String> idAttendes = CIBE_NewEventController.createEventRelation2((Id) createdEvent, new List<String>{attende.Id,attende.Id}, null);
            Test.stopTest();
            for(String ids : idAttendes){
                if(!ids.contains('Fail') && !ids.contains('valor')){
                    idToTest = (Id) ids;
                    break;
                }
            }
            String response = CIBE_NewEventController.backupEventsAndAttendes(recordsToDelete,jsonEventToBackReport,idToTest);
            System.assert(response == 'OK');
        }   
    }


    @IsTest
    static void getOppTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        
        System.runAs(usuario) {
            Opportunity opp = [SELECT Id, Name, StageName FROM Opportunity WHERE Name = 'Alerta Comercial Test' AND StageName = 'CIBE_Vencido'LIMIT 1];
            List<Opportunity> oppList = CIBE_NewEventController.getOpp(opp.Id);
            System.assert(!oppList.isEmpty());

        }  
        
    }

    @IsTest
    static void syncEventTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        DateTime now = System.now();
        Test.startTest();
        System.runAs(usuario) {
            Account acc = [SELECT Id FROM Account WHERE CreatedDate = TODAY  AND Name = 'Name'];
            Contact c = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :usuario.Id];

            Event evento = new Event();
            evento.WhatId = acc.Id;
            evento.WhoId = c.Id;
            evento.OwnerId = usuario.Id;
            evento.Subject = 'Test';
            evento.ActivityDateTime = now;
            evento.StartDateTime = now;
            evento.FinServ__NextSteps__c = acc.id;
            evento.EndDateTime = System.now().addMinutes(60);
            String estado = 'Pendiente';

           CIBE_NewEventController.createEvent(evento,estado);
           Event evnt = [SELECT Id, RecordTypeId, AV_Tipo__c FROM Event WHERE Subject = 'Test' WITH SECURITY_ENFORCED LIMIT 1];

           CIBE_NewEventController.syncEvents(evnt);
           List <Event> evnt1 = [SELECT Id, RecordTypeId, AV_Tipo__c FROM Event WHERE Subject = 'Test' WITH SECURITY_ENFORCED];
           System.assert(!evnt1.isEmpty());

        Test.stopTest();
        }
    }



    @IsTest
    static void updateEventGCTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        DateTime now = System.now();
        Test.startTest();
        System.runAs(usuario) {
            Event evento = [SELECT Id FROM Event WHERE Subject = 'Call' LIMIT 1];
            Account acc = [SELECT Id FROM Account WHERE CreatedDate = TODAY  AND Name = 'Name'];
            CIBE_NewEventController.updateEventGC(evento.Id, acc.Id);
            Event eventoUpdate = [SELECT Id, FinServ__NextSteps__c FROM Event WHERE Id = :evento.Id];
            System.assert(eventoUpdate.FinServ__NextSteps__c != null);
            System.assert(eventoUpdate.Id != null);

        Test.stopTest();
        }
    }


    @IsTest
    static void getContactoPrincipalTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario) {
            Account acc = [SELECT Id FROM Account WHERE CreatedDate = TODAY  AND Name = 'Name'];
            List<String> lstAccountId = new List<String> ();
            List<AccountContactRelation> result = CIBE_NewEventController.getContactoPrincipal(acc.Id,lstAccountId);
            System.assert(!result.isEmpty());
        Test.stopTest();
        }
    }

    @IsTest
    static void getGrupoComercialTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario) {
            Account acc = [SELECT Id FROM Account WHERE CreatedDate = TODAY  AND Name = 'Name'];
            List<AV_LookupSearchResult> result = CIBE_NewEventController.getGrupoComercial(acc.Id);
            System.assert(!result.isEmpty());
        Test.stopTest();
        }
    }


    @IsTest
    static void updateEventWithURLTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario) {
            Event evento = [SELECT Id, startDateTime, endDateTime, Subject FROM Event WHERE Subject = 'Call' LIMIT 1];
            Contact c = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :usuario.Id];
            List<String> att = new List<String>{c.Id};
            CIBE_NewEventController.updateEventWithURL(evento.Id, att, null, 'test');
            Event eventoUpd = [SELECT Id, Description FROM Event WHERE Id = :evento.Id LIMIT 1];
            System.assert(eventoUpd.Description != null);
        Test.stopTest();
        }
    }

    @IsTest
    static void processAsistentesTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario) {
            Event evento = [SELECT Id, startDateTime, endDateTime, Subject, RecordTypeId, AV_Tipo__c, CreatedById
            FROM Event WHERE Subject = 'Call' LIMIT 1];
            Contact c = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :usuario.Id];
            List<String> att = new List<String>{c.Id};
            List<Map<String, Object>> asistentes = new List<Map<String, Object>>();
            Map<String, Object> sinRegistrar = new Map<String, Object>();
            sinRegistrar.put('id', 'Idprovisional');
            sinRegistrar.put('email', 'test@test.es');
            sinRegistrar.put('tipoAsistente', 'Sin Registrar');
            sinRegistrar.put('enviarCita', true);

            Map<String, Object> asistenteCaixaBank = new Map<String, Object>();
            asistenteCaixaBank.put('id', c.Id);
            asistentes.add(sinRegistrar);
            asistentes.add(asistenteCaixaBank);
            CIBE_NewEventController.processAsistentes(evento, asistentes, null);
            Contact contNR = [SELECT Id FROM Contact WHERE email = 'test@test.es' LIMIT 1];
            System.assert(contNR != null);
        Test.stopTest();
        }
    }

}