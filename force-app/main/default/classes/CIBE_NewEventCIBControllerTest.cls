/**********************************************************************************************************************
 Name:      CIBE_NewEventCIBControllerTest
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de la clase CIBE_NewEventCIBController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY       AUTHOR           DATE                Description
    1.0            US743059         Lucia            14/12/2023          Init version
***********************************************************************************************************************/

@IsTest
public with sharing class CIBE_NewEventCIBControllerTest {


    @TestSetup
    static void makeData(){
        CIBE_TestInitialSetup.setupInitialDataCIB();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

            Test.startTest();

            User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
			
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account acc = new Account(
                Name = 'Name',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '123',
                AV_Negocio__c = 'CIB',
                ownerId = usuario.Id
            );
            insert acc;
			
            Contact c = CIBE_TestHelper.createRepresentante(acc, usrTest, '001');
           

            Account acc2 = new Account(
                Name = 'Sin Cliente',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '453',
                AV_Negocio__c = 'CIB',
                ownerId = usuario.Id
            );
            insert acc2;
         
			
			
	        // RecordType rtOpp = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
            // Opportunity opp = new Opportunity();
            // opp.AccountId = acc.Id;
            // opp.Name = 'Alerta Comercial';
            // opp.StageName = 'En gestión/insistir';
            // opp.RecordTypeId = rtOpp.Id;
            // opp.CloseDate = System.today() + 5;
            // opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
            // opp.OwnerId = usuario.Id;
            // insert opp;
			

            CIBE_TestHelper.createEvent(usuario, system.now(), acc);
            
            // String externalId = '999999';
            // AV_HeaderCustomActivity__c acthead = new AV_HeaderCustomActivity__c(
            //     AV_ExternalID__c = externalId,
            //     AV_ToDelete__c = true,
            //     OwnerId = usuario.Id
            // );
            // insert acthead;
            
            // String randomExternalId = String.valueof((Math.random() * 10000000));
            // event.AV_ExternalID__c = randomExternalId;
            // event.RecordTypeId = rtE.Id;
            // event.DurationInMinutes= 60;
            // event.AV_Task__c=acthead.id;
            // event.ActivityDateTime = System.now();
            // event.StartDateTime = System.now();
            // event.EndDateTime = System.now().addMinutes(60);
            // //event.CSBD_Evento_Estado__c = CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
            // event.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
            // event.Description = 'Prueba';
            // event.WhoId = c.Id;

            // insert event;
			
            CIBE_TestHelper.createAccountTeamMember(usuario, acc);

            CIBE_TestHelper.createProduct(null,null);

          Test.stopTest();
    }




    @IsTest
    static void searchEmployees_Test(){
        User usuario = [SELECT Id, Name FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = usuario.Id;
            Test.setFixedSearchResults(fixedSearchResults);
            List<AV_LookupSearchResult> ususarios = CIBE_NewEventCIBController.searchEmployees(usuario.Name);
            System.assert(!ususarios.isEmpty());
        }
        Test.stopTest();
    }

    @IsTest
    static void getContactosApoderados_Test(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Account acc = [SELECT Id FROM Account WHERE CreatedDate = TODAY  AND Name = 'Name'];
            List<Contact> contactosApoderados = CIBE_NewEventCIBController.getContactosApoderados(acc.Id);
            System.assert(!contactosApoderados.isEmpty());
            
        }
        Test.stopTest();
    }


    @IsTest
    static void createEvent_Test(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
			DateTime dt = System.now();
            Account acc = [SELECT Id,name FROM Account WHERE CreatedDate = TODAY  AND Name = 'Name'];
            Contact c = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :usuario.Id];

            Event evento = new Event();
            evento.WhatId = acc.Id;
            evento.WhoId = c.Id;
            evento.OwnerId = usuario.Id;
            evento.ActivityDateTime = dt;
            evento.StartDateTime = dt;
            evento.EndDateTime = dt.addMinutes(60);

            CIBE_NewEventCIBController.createEvent(evento);
            String subjectPattern = acc.Name + ' / Equipo Caixabank';
            List<Event> evnt = [SELECT Id FROM Event WHERE Subject = :subjectPattern];
            System.assert(!evnt.isEmpty());

        Test.stopTest();
        }
    }

    @IsTest
    static void createEventRelation_Test(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            List<Contact> c = [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE AV_UsuarioAsociado__c = :usuario.Id];
            Event evento = [SELECT Id,RecordTypeId, AV_Tipo__c, OwnerId, CreatedById FROM Event WHERE Subject = 'Call'];
            List<String> attendees = new List<String>();

            if(!c.isEmpty()){
                for (Contact con : c) {
                    attendees.add(con.AV_UsuarioAsociado__c);
                }
            }

            CIBE_NewEventCIBController.callApiTeams(evento, attendees, null);
            List<EventRelation> evntRelation = [SELECT Id FROM EventRelation WHERE EventId = :evento.Id];
            System.assert(evntRelation != null);
            
        }
        Test.stopTest();
    }


    @IsTest
    static void backupEventsAndAttendes_Test(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            List<String> recordsToDelete = new List<String>();
            String jsonEventToBackReport = null;

            Event evtCreated = [SELECT Id,AV_Task__c  FROM Event WHERE Subject = 'Call'];
            Id createdEvent = evtCreated.Id;

            User attende = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003'];
            Id idToTest;

            List<String> idAttendes = CIBE_NewEventCIBController.createEventRelation2(createdEvent, new List<String>{attende.Id,attende.Id}, null);
            for(String ids : idAttendes){
                if(!ids.contains('Fail') && !ids.contains('valor')){
                    idToTest = (Id) ids;
                    break;
                }
            }
            String response = CIBE_NewEventCIBController.backupEventsAndAttendes(recordsToDelete,jsonEventToBackReport,idToTest);
            System.assert(response == 'OK');
        }
        Test.stopTest();
    }


    @IsTest
    static void searchUserCXB_Test(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Contact employee = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName = 'CC_Empleado' AND FirstName = 'Employee'];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = employee.Id;
            Test.setFixedSearchResults(fixedSearchResults);
            List<String> selectIds = new List<String>();
            List<AV_LookupSearchResult> results = CIBE_NewEventCIBController.searchUserCXB(employee.Name, selectIds);
            System.assert(!results.isEmpty());
            
           
        }
        Test.stopTest();
    }

    @IsTest
    static void searchUserTeamCXB_Test(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Account acc = [SELECT Id FROM Account WHERE CreatedDate = TODAY  AND Name = 'Name'];
            List<AV_LookupSearchResult> results = CIBE_NewEventCIBController.searchUserTeamCXB(acc.Id);
            System.assert(!results.isEmpty());
        }
        Test.stopTest();
    }

    @isTest
	public static void getTipoOperacionPicklistTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usuario) {
            Test.startTest();
                List<CIBE_NewEventCIBController.OptionsField> listValues = CIBE_NewEventCIBController.getRegardingPicklistValue();
                System.assert(!listValues.isEmpty());
            Test.stopTest(); 
        }
    }

    @isTest
	public static void getAccountSinClienteTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usuario) {
            Test.startTest();
                List<Account> listValues = CIBE_NewEventCIBController.getAccountSinCliente();
                System.assert(!listValues.isEmpty());
            Test.stopTest(); 
        }
    }

    @IsTest
    public static void testProcessAsistentes (){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Contact employee = [SELECT Id, Name FROM Contact WHERE FirstName = 'Empleado'];
        Contact employee2 = [SELECT Id, Name FROM Contact WHERE FirstName = 'Employee'];
        System.runAs(usuario){
        Test.StartTest();
            Account acc = [SELECT Id FROM Account WHERE Name = 'Name' limit 1];
        	Event newEvnt = new Event(ownerId = usuario.Id, whatId = acc.Id,  DurationInMinutes = 30, ActivityDateTime = System.now());
            insert newEvnt;
            List<Map<String, Object>> asistentes = new List<Map<String, Object>>();
            Map<String, Object> sinRegistrar = new Map<String, Object>();
            sinRegistrar.put('id', 'Idprovisional');
            sinRegistrar.put('email', 'test@test.es');
            sinRegistrar.put('tipoAsistente', 'Sin Registrar');
            sinRegistrar.put('enviarCita', true);
            Map<String, Object> asistenteCaixaBank = new Map<String, Object>();
            asistenteCaixaBank.put('id', employee.Id);
            asistenteCaixaBank.put('tipoAsistente', 'CaixaBank');
            asistenteCaixaBank.put('enviarCita', true);
            Map<String, Object> asistenteCliente = new Map<String, Object>();
            asistenteCliente.put('id', employee.Id);
            asistenteCliente.put('tipoAsistente', 'Cliente');
            asistenteCliente.put('enviarCita', true);
            asistentes.add(sinRegistrar);
            asistentes.add(asistenteCaixaBank);
            asistentes.add(asistenteCliente);
            
            CIBE_NewEventCIBController.processAsistentes(newEvnt, asistentes, null);
            
            List<CIBE_RelaccionadoCita__c> relCita = [SELECT Id From CIBE_RelaccionadoCita__c WHERE CIBE_Email__c = 'test@test.es'];
            System.assert(!relCita.isEmpty());
        }
        Test.stopTest();
    }

    @isTest
	public static void createProductCIBTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usuario) {
            Test.startTest();
                Event evtCreated = [SELECT Id,AV_Task__c  FROM Event WHERE Subject = 'Call'];
                Product2 prod = [SELECT Id FROM Product2 WHERE AV_ExternalID__c = '50003'];
                List<Map<String, Object>> takedProducts = new List<Map<String, Object>>();
                Map<String, Object> productos = new Map<String, Object>();

                productos.put('comentario', 'test123');
                productos.put('idProducto', prod.Id);

                takedProducts.add(productos);

                CIBE_NewEventCIBController.createProductCIB(takedProducts, evtCreated);

                List<CIBE_RelaccionadoCita__c> relProduct = [SELECT Id FROM CIBE_RelaccionadoCita__c WHERE CIBE_Producto__c = :prod.Id];
                System.assert(!relProduct.isEmpty());
            Test.stopTest(); 
        }
    }


    @IsTest
    static void searchUserClientes_Test(){
        User usuario = [SELECT Id, Name FROM User WHERE AV_ExternalID__c = 'U0000001'];
                
        Test.startTest();
        System.runAs(usuario) {
            Contact employee = [SELECT Id, Name FROM Contact WHERE FirstName = 'Empleado'];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = employee.Id;
            Test.setFixedSearchResults(fixedSearchResults);
            Account acc = [SELECT Id FROM Account WHERE CreatedDate = TODAY  AND Name = 'Name'];
            List<String> selectIds = new List<String>();
            List<AV_LookupSearchResult> contactosApoderados = CIBE_NewEventCIBController.searchUserClientes(employee.Name, selectIds, acc.Id);
            System.assert(!contactosApoderados.isEmpty());
            
        }
    }

}