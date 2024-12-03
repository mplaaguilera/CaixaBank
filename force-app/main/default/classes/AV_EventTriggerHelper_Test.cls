/**********************************************************************************************************************
Name:	  AV_EventTriggerHelper_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_EventTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY	   		AUTHOR		   			DATE				Description
    1.0			Test Class	   		Eric Vázquez	   	   	08/10/2020			Init version
    2.0			Test Class	   		Esperanza Conde 	   	21/10/2020			Logic to copy contact date into real date
    2.1			US147562	   		Sandra Gómez		   	14/01/2020			Added new method validateCreateCRMTask
	2.2			FIX Outlook			David Rufo				30/06/2021			Method to identify events from outlook
    2.3			-                   Víctor Santiago         22/11/2021          Commented method testOppoReminderEvent
	2.4			US286825 			Daniel Rodríguez		13/01/2022			Add new method executeEventTriggerFromOppDate
    2.5		    AV_Query IT	        Daniel Rodríguez        07/03/2022	        Change AV_Query to SOQL for User, Account, Contact
    2.6		    US304978		    Víctor Santiago		    8/04/2022			Added methods validateSetMeetingLocation
	2.7			Fix-bucle			Sandra Gómez			19/04/2022			Change method updateNextManagementDateOpp queries in for
    2.8         US430868            Luis Fernández          17/08/2022          Added assertEquals to methods that does not have
    2.9         -                   Elisabeth Rodríguez     08/11/2022          Added executeEventTriggerDelete method
    3.0			FIX				    Patricia Solano		    10/01/2023		    Modify method setEventChanelAndPurposeTest to fix QualityClouds errors
    3.1         US481618		    Ángel Medina		    18/01/2023		    Add new method validateRecordChannel()
                                                                                Modify 	methods
 	3.2         US538800            Sandra Gómez            15/02/2023          Change method setEventChanelAndPurposeTest
	3.3			Ejec. Lentas		Sandra Gómez			22/02/2024			Coverage
	1.4			PPM100538432   		Sandra Gómez			19/09/2024			Coverage
***********************************************************************************************************************/
@isTest
public with sharing class AV_EventTriggerHelper_Test {
    
    @TestSetup
    static void setup(){
        Test.startTest();
        AV_TestHelper.activateLogger();
        Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;     
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        List<User> userBPAList = [SELECT Id,AV_ExternalId__c,AV_NumeroOficinaEmpresa__c FROM User WHERE Alias = :AV_AppConstants.BPA_EVENT_USER AND  Profile.Name = 'AV_Usuario_CaixaBank' LIMIT 1];
        User userBPA;
        Account cliente;
        Account center;        
        System.runAs(usuGcf){
            User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545400', 'AV_SistematicaComercial');
            userGestor.Alias = 'gest';
            userGestor.Email = 'gestor-test@test.com';
            userGestor.IsActive = true;
            List<User> usersToAdd = new List<User>{userGestor};
           
            List<Contact> cont = new List<Contact>{AV_TestHelper.createEmployeeSinInsert(center,userGestor,userGestor.AV_ExternalID__c)};
            List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
            Boolean bpaTestCreated = false;
            if(userBPAList.isEmpty()){
                userBPA = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','000001','AV_SistematicaComercial');
                userBPA.Alias = AV_AppConstants.BPA_EVENT_USER;
                userBPA.AV_NumeroOficinaEmpresa__c = '001-00000';
                userBPA.AV_NumeroOficinaEmpresa__c = '000001';
                userBPA.AV_ExternalId__c = 'EXAMPLE80';
                usersToAdd.add(userBPA);
                bpaTestCreated = true;
            }else{
                userBPA = userBPAList[0];
            }
            insert usersToAdd;

            cont.add(AV_TestHelper.createEmployeeSinInsert(null,userBPA,userBPA.AV_ExternalID__c));
            insert cont;
            AV_TestHelper.insertNeededPermissions(userGestor);
            if(bpaTestCreated){
                AV_TestHelper.insertNeededPermissions(userBPA);

            }
            cliente = AV_TestHelper.createCustomerSinInsert();
            cliente.OwnerId = userGestor.Id;
            center= AV_TestHelper.createCaixaCenterSinInsert();
            center.OwnerId = userGestor.Id;
            List<Account> listAcc =new List<Account>{cliente,center};
            Database.insert(listAcc, false);

        }

        Test.stopTest();
    }
    
    @isTest
    private static void validateOutlookEvent() {

        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        system.runAs(usuGcf){
            User userGt = [SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND AV_ExternalID__c='U01545400' LIMIT 1];
            Account cliente = [Select Id from Account WHERE CC_Numero_Documento__c = '9446386T' limit 1];
            Account center = [Select Id from Account WHERE CC_Numero_Oficina_Empresa__c = '00615' limit 1];
            Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGt.Id];
            AV_TestHelper.createTarea(userGt, System.today());
            Event evTest = AV_TestHelper.createEvent(userGt, Datetime.now(),cliente);
            evTest.CSBD_Evento_Estado__c='Pendiente'; 
            Opportunity opp = AV_TestHelper.createOpportunityExternalId(cliente, cont, evTest.AV_ExternalID__c);
            Test.startTest();
            String lhtid = evTest.AV_Task__c;
            AV_TestHelper.createTareaOportunidad(opp,lhtid);
            List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
            CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
            listDummyWords.add(word);
            CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
            listDummyWords.add(word2);
            Database.insert(listDummyWords, false);
        }
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTGESTOR_RT);
        User us = [Select Id from User where AV_ExternalId__c='U01545400' limit 1];
        Event event = new Event();
		event.Subject = 'Test Event 001-A - Outlook';
		event.RecordTypeId = rt.Id;
		event.DurationInMinutes = 60;
        event.ActivityDateTime = System.now();
        event.OwnerId = us.Id;
        event.Description = 'Prueba texto descripcion outlook: https://pexip.me/teams';
        system.runAs(us){
            insert event;
        }
        Test.stopTest();
        Event evtFinal = [SELECT id, AV_OrigenApp__c FROM Event WHERE Id =: event.Id  LIMIT 1];
        System.assertEquals('AV_Salesforce', evtFinal.AV_OrigenApp__c);
    }

    @isTest
    private static void validateForbiddenWordsTest() {

        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        system.runAs(usuGcf){
            User userGt = [SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND AV_ExternalID__c='U01545400' LIMIT 1];
            Account cliente = [Select Id from Account WHERE CC_Numero_Documento__c = '9446386T' limit 1];
            Account center = [Select Id from Account WHERE CC_Numero_Oficina_Empresa__c = '00615' limit 1];
            Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGt.Id];
            AV_TestHelper.createTarea(userGt, System.today());
            Event evTest = AV_TestHelper.createEvent(userGt, Datetime.now(),cliente);
            evTest.CSBD_Evento_Estado__c='Pendiente'; 
            Opportunity opp = AV_TestHelper.createOpportunityExternalId(cliente, cont, evTest.AV_ExternalID__c);
        Test.startTest();
          
            String lhtid = evTest.AV_Task__c;
            AV_TestHelper.createTareaOportunidad(opp,lhtid);
            List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
            CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
            listDummyWords.add(word);
            CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
            listDummyWords.add(word2);
            Database.insert(listDummyWords, false);
        }
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        List<Event> listClients = [Select Description, Subject, Location, AV_OrigenApp__c From Event limit 6];
        User us = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true limit 1];
        System.runAs(us){
            String errorMessage = '';
            if(!listClients.isEmpty()) {
                listClients[0].AV_OrigenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP;
                listClients[0].Description += ' ABELLOTS and CAUCASIC';
                Database.SaveResult[] srList = Database.update(listClients,false);
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            errorMessage = String.valueOf(err.getStatusCode());
                        }
                    }
                }
            }
            System.assert(errorMessage == null || errorMessage == '', errorMessage);
            Test.stopTest();
        }
    }

    /**
	 * Execute the Trigger class (AV_Event_BI_TRHan) and check if the cabecera-tarea is correct created.
	 */
	@isTest
	public static void executeEventTrigger() {
        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        system.runAs(usuGcf){
            User userGt = [SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND AV_ExternalID__c='U01545400' LIMIT 1];
            Account cliente = [Select Id from Account WHERE CC_Numero_Documento__c = '9446386T' limit 1];
            Account center = [Select Id from Account WHERE CC_Numero_Oficina_Empresa__c = '00615' limit 1];
            Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGt.Id];
            AV_TestHelper.createTarea(userGt, System.today());
            Event evTest = AV_TestHelper.createEvent(userGt, Datetime.now(),cliente);
            evTest.CSBD_Evento_Estado__c='Pendiente'; 
            Opportunity opp = AV_TestHelper.createOpportunityExternalId(cliente, cont, evTest.AV_ExternalID__c);
            String lhtid = evTest.AV_Task__c;
            AV_TestHelper.createTareaOportunidad(opp,lhtid);
            List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
            CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
            listDummyWords.add(word);
            CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
            listDummyWords.add(word2);
            Database.insert(listDummyWords, false);
        }
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        User us = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		Test.startTest();
            System.runAs(us){
                Event evento = [Select Id,AV_ExternalID__c FROM Event Limit 1 ];
                AV_HeaderCustomActivity__c cabeceraTarea = [select AV_ExternalID__c from AV_HeaderCustomActivity__c where AV_ExternalID__c = :evento.AV_ExternalID__c];
                System.assertEquals(cabeceraTarea.AV_ExternalID__c, evento.AV_ExternalID__c);
            }
		Test.stopTest();
	}

	/**
	 * Execute the Trigger class (AV_Event_BI_TRHan) and check if the cabecera-tarea is correct created.
	 */
	@isTest
	public static void executeEventTriggerFromOpp() {
        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        Opportunity opp;
        User userGt = [SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND AV_ExternalID__c='U01545400' LIMIT 1];
        system.runAs(usuGcf){
            Account cliente = [Select Id from Account WHERE CC_Numero_Documento__c = '9446386T' limit 1];
            Account center = [Select Id from Account WHERE CC_Numero_Oficina_Empresa__c = '00615' limit 1];
            Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGt.Id];
            AV_TestHelper.createTarea(userGt, System.today());
            Event evTest = AV_TestHelper.createEvent(userGt, Datetime.now(),cliente);
            evTest.CSBD_Evento_Estado__c='Pendiente'; 
            opp = AV_TestHelper.createOpportunityExternalId(cliente, cont, evTest.AV_ExternalID__c);
            Test.startTest();
           
            String lhtid = evTest.AV_Task__c;
            AV_TestHelper.createTareaOportunidad(opp,lhtid);
            List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
            CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
            listDummyWords.add(word);
            CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
            listDummyWords.add(word2);
            Database.insert(listDummyWords, false);
        }
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
		DateTime activityDate = Datetime.newInstance(2020, 6, 4);
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
		Account cliente = [SELECT id FROM Account WHERE  AV_NumPerso__c = '123'];
        System.runAs(userGt){
            AV_TestHelper.createEventWithOpp(userGt, activityDate, opp, cliente);
            Event eventoCreado = [select AV_AssociatedOpportunityId__c from Event where AV_AssociatedOpportunityId__c = :opp.Id];
            System.assertEquals(eventoCreado.AV_AssociatedOpportunityId__c, opp.Id);
        }
		Test.stopTest();
    }

    /**
    * Execute the Trigger class (AV_Event_BU_TRHan) and check if the EAP Gestor has been modified correctly.
    */
	@isTest
	public static void executeEventTriggerUpdatingEAPGestor() {
        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        system.runAs(usuGcf){
            User userGt = [SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND AV_ExternalID__c='U01545400' LIMIT 1];
            Account cliente = [Select Id from Account WHERE CC_Numero_Documento__c = '9446386T' limit 1];
            Account center = [Select Id from Account WHERE CC_Numero_Oficina_Empresa__c = '00615' limit 1];
            Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGt.Id];
            AV_TestHelper.createTarea(userGt, System.today());
            Event evTest = AV_TestHelper.createEvent(userGt, Datetime.now(),cliente);
            evTest.CSBD_Evento_Estado__c='Pendiente'; 
            Opportunity opp = AV_TestHelper.createOpportunityExternalId(cliente, cont, evTest.AV_ExternalID__c);
            String lhtid = evTest.AV_Task__c;
            AV_TestHelper.createTareaOportunidad(opp,lhtid);
            List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
            CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
            listDummyWords.add(word);
            CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
            listDummyWords.add(word2);
            Database.insert(listDummyWords, false);
        }
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        Test.startTest();
        User userGFc = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_MOCNT','OK'));
        System.runAs(userGFc){
            Event evento = [Select Id, AV_CodigoGestorAsignado__c FROM Event Limit 1 ];
            evento.AV_CodigoGestorAsignado__c = 'U0009003';
            Database.update(evento);
            Event cienteUpdated = [select AV_CodigoGestorAsignado__c from Event where Id = :evento.Id];
            System.assertNotEquals(null, cienteUpdated.AV_CodigoGestorAsignado__c);
            evento.AV_CodigoGestorAsignado__c = '';
            Database.update(evento);
            evento = [select AV_CodigoGestorAsignado__c,OwnerId from Event where Id = :evento.Id];
            System.assertEquals(evento.ownerId,userGFc.id,'El owner no se ha actualizado');
        }
		Test.stopTest();
    }
    
    @isTest 
    public static void executeEventTriggerInsertingEAPGestor(){
        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        system.runAs(usuGcf){
            User userGt = [SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND AV_ExternalID__c='U01545400' LIMIT 1];
            Account cliente = [Select Id from Account WHERE CC_Numero_Documento__c = '9446386T' limit 1];
            Account center = [Select Id from Account WHERE CC_Numero_Oficina_Empresa__c = '00615' limit 1];
            Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGt.Id];
            AV_TestHelper.createTarea(userGt, System.today());
            Event evTest = AV_TestHelper.createEvent(userGt, Datetime.now(),cliente);
            evTest.CSBD_Evento_Estado__c='Pendiente'; 
            Opportunity opp = AV_TestHelper.createOpportunityExternalId(cliente, cont, evTest.AV_ExternalID__c);
            String lhtid = evTest.AV_Task__c;
            AV_TestHelper.createTareaOportunidad(opp,lhtid);
            List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
            CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
            listDummyWords.add(word);
            CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
            listDummyWords.add(word2);
            Database.insert(listDummyWords, false);
        }
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        Test.startTest();        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'API Only' and Alias = 'AV-TF9' and isActive = true LIMIT 1];
        Contact cnt = new Contact(
            FirstName = 'cnt',
            LastName = 'Test',
            CC_Matricula__c = '00000',
            AV_UsuarioAsociado__c = U.id,
            Email = 'ejemplo@test.com'
        );
        insert cnt;
        Account acc = new Account(
            AV_EAPGestor__c= cnt.Id,
            FirstName = 'test',
            LastName = 'test',
            AV_Negocio__c = 'BPA'
        );
        insert acc;
        String matriculaGestor = cnt.CC_Matricula__c;
        Event event;
        System.runAs(u){
            event= new Event();
            event.WhatId = acc.Id;//cli.Id;
            event.OwnerId = u.Id;   
            event.DurationInMinutes= 60;
            event.ActivityDateTime = Datetime.now();
            event.AV_Tipo__c = 'CTO';
            event.StartDateTime =event.ActivityDateTime;
            event.EndDateTime = Datetime.now().addMinutes(60);
            event.CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE;
            insert event;
        }
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        Event rtvEvt = [SELECT AV_CodigoGestorAsignado__c FROM EVENT WHERE ID = :event.id LIMIT 1];
        System.assertEquals(rtvEvt.AV_CodigoGestorAsignado__c,matriculaGestor,'No se ha actualizado bien');
        Test.stopTest();
    }

     /**
	 * Execute the Trigger class (AV_Event_AI_TRHan).
	 */
	@isTest
	public static void executeEventSync() {
        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];

        system.runAs(usuGcf){
            User userGt = [SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND AV_ExternalID__c='U01545400' LIMIT 1];
            Account cliente = [Select Id from Account WHERE CC_Numero_Documento__c = '9446386T' limit 1];
            Account center = [Select Id from Account WHERE CC_Numero_Oficina_Empresa__c = '00615' limit 1];
            Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGt.Id];
            AV_TestHelper.createTarea(userGt, System.today());
            Event evTest = AV_TestHelper.createEvent(userGt, Datetime.now(),cliente);
            evTest.CSBD_Evento_Estado__c='Pendiente'; 
            Opportunity opp = AV_TestHelper.createOpportunityExternalId(cliente, cont, evTest.AV_ExternalID__c);
            Test.startTest();
            
            String lhtid = evTest.AV_Task__c;
            AV_TestHelper.createTareaOportunidad(opp,lhtid);
            List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
            CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
            listDummyWords.add(word);
            CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
            listDummyWords.add(word2);
            Database.insert(listDummyWords, false);
        }
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        Event e = [SELECT Id,Subject, AV_origenApp__c from Event Limit 1];
            System.runAs(usuGcf){
                Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_MOCNT','OK'));
                e.Subject = 'Test update';
                e.AV_origenApp__c = 'AV_Salesforce';
                update e;
            }
        Test.stopTest();   
		System.assertEquals(e.Subject,'Test update');
    }
    
    @isTest
    public static void validateCreateCRMTask() {
        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        system.runAs(usuGcf){
            User userGt = [SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND AV_ExternalID__c='U01545400' LIMIT 1];
            Account cliente = [Select Id from Account WHERE CC_Numero_Documento__c = '9446386T' limit 1];
            Account center = [Select Id from Account WHERE CC_Numero_Oficina_Empresa__c = '00615' limit 1];
            Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGt.Id];
            AV_TestHelper.createTarea(userGt, System.today());
            Event evTest = AV_TestHelper.createEvent(userGt, Datetime.now(),cliente);
            evTest.CSBD_Evento_Estado__c='Pendiente'; 
            Opportunity opp = AV_TestHelper.createOpportunityExternalId(cliente, cont, evTest.AV_ExternalID__c);
            String lhtid = evTest.AV_Task__c;
            AV_TestHelper.createTareaOportunidad(opp,lhtid);
            List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
            CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
            listDummyWords.add(word);
            CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
            listDummyWords.add(word2);
            Database.insert(listDummyWords, false);
        }
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        Test.startTest();
        User us = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        DateTime activityDate = Datetime.newInstance(2020, 6, 4);
        Account acc = [SELECT id FROM Account WHERE  AV_NumPerso__c = '123'];
        Event evento = AV_TestHelper.createEvent(us,activityDate,acc);
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        System.runAs(us){
            evento.Description= 'Prueba comentario';
            update evento;
        }
        Test.stopTest();
        CBK_Activity_Extension__c comentario = [SELECT id, AV_CommentLastModifiedBy__c, AV_CommentLastModifiedDate__c FROM CBK_Activity_Extension__c WHERE  AV_ActivityId__c = :evento.id];
        System.assertNotEquals(comentario.AV_CommentLastModifiedBy__c,null);
        System.assertNotEquals(comentario.AV_CommentLastModifiedDate__c,null);
    }
    
    /**
	 * Execute the Trigger class (AV_Event_AU_TRHan) and check if date of event has changed
	 */
	@isTest
	public static void executeEventTriggerFromOppDate() {

        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        system.runAs(usuGcf){
            User userGt = [SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND AV_ExternalID__c='U01545400' LIMIT 1];
            Account cliente = [Select Id from Account WHERE CC_Numero_Documento__c = '9446386T' limit 1];
            Account center = [Select Id from Account WHERE CC_Numero_Oficina_Empresa__c = '00615' limit 1];
            Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGt.Id];
            AV_TestHelper.createTarea(userGt, System.today());
            Event evTest = AV_TestHelper.createEvent(userGt, Datetime.now(),cliente);
            evTest.CSBD_Evento_Estado__c='Pendiente'; 
            Opportunity opp = AV_TestHelper.createOpportunityExternalId(cliente, cont, evTest.AV_ExternalID__c);
            Test.startTest();
            
            String lhtid = evTest.AV_Task__c;
            AV_TestHelper.createTareaOportunidad(opp,lhtid);
            List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
            CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
            listDummyWords.add(word);
            CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
            listDummyWords.add(word2);
            Database.insert(listDummyWords, false);
        }
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        DateTime activityDate = Datetime.newInstance(2020, 6, 4);
        Event ev = [Select id, AV_ExternalID__c, ActivityDate from Event limit 1];
        Event ev2 = [Select id, AV_ExternalID__c, ActivityDate, StartDateTime, EndDateTime from Event limit 1];
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        System.runAs(usuGcf){
            ev2.StartDateTime = datetime.now().adddays(1);
            ev2.EndDateTime = datetime.now().adddays(1);
            update ev2;
        }
		Test.stopTest();
        System.assertEquals(ev.ActivityDate, ev2.ActivityDate);
    }

    @isTest
    public static void validateSetMeetingLocation() {
        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        User userGt = [SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND AV_ExternalID__c='U01545400' LIMIT 1];
        Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGt.Id LIMIT 1];
        system.runAs(userGt){
            Account cliente = [Select Id from Account WHERE CC_Numero_Documento__c = '9446386T' limit 1];
            Account center = [Select Id from Account WHERE CC_Numero_Oficina_Empresa__c = '00615' limit 1];
            // Contact cont = AV_TestHelper.createEmployee(center,userGt,userGt.AV_ExternalID__c);
            Event evTest = AV_TestHelper.createEvent(userGt, Datetime.now(),cliente);
            evTest.CSBD_Evento_Estado__c='Pendiente'; 
            Opportunity opp = AV_TestHelper.createOpportunityExternalId(cliente, cont, evTest.AV_ExternalID__c);
            Test.startTest();
            String lhtid = evTest.AV_Task__c;
            AV_TestHelper.createTareaOportunidad(opp,lhtid);
            List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
            CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
            listDummyWords.add(word);
            CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
            listDummyWords.add(word2);
            Database.insert(listDummyWords, false);
        }
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTGESTOR_RT);
        User u = [SELECT Id, AV_NumeroOficinaEmpresa__c, AV_ExternalID__c FROM User WHERE AV_NumeroOficinaEmpresa__c != null AND Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Event e2 = new Event(
            Subject = 'Inserted event test',
            OwnerId = u.Id,
            AV_ExternalID__c = String.valueof((Math.random() * 10000000)),
            RecordTypeId = rt.Id,
            DurationInMinutes= 60,
            AV_Tipo__c = 'CTO',
            AV_CodigoGestorAsignado__c = '001-99999',
            CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE,
            AV_OrigenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP,
            AV_BranchPhysicalMeet__c = '00001'
        );
        System.runAs(u){
            e2.ActivityDateTime = System.now();
            e2.StartDateTime = e2.ActivityDateTime;
            e2.EndDateTime = e2.StartDateTime.addMinutes(60);
            insert e2;
        }
        Test.stopTest();
        Event e2Inserted = [SELECT Id, Location, AV_Center__c FROM Event WHERE Subject = 'Inserted event test' AND DurationInMinutes = 60 LIMIT 1];
        System.assertEquals(e2Inserted.Location, '00001');
    }
    
    @isTest 
    public static void validateChangeOwner(){
        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        system.runAs(usuGcf){
            User userGt = [SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND AV_ExternalID__c='U01545400' LIMIT 1];
            Account cliente = [Select Id from Account WHERE CC_Numero_Documento__c = '9446386T' limit 1];
            Account center = [Select Id from Account WHERE CC_Numero_Oficina_Empresa__c = '00615' limit 1];
            Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGt.Id];
            AV_TestHelper.createTarea(userGt, System.today());
            Event evTest = AV_TestHelper.createEvent(userGt, Datetime.now(),cliente);
            evTest.CSBD_Evento_Estado__c='Pendiente'; 
            Opportunity opp = AV_TestHelper.createOpportunityExternalId(cliente, cont, evTest.AV_ExternalID__c);
            String lhtid = evTest.AV_Task__c;
            AV_TestHelper.createTareaOportunidad(opp,lhtid);
            List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
            CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
            listDummyWords.add(word);
            CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
            listDummyWords.add(word2);
            Database.insert(listDummyWords, false);
        }
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        Test.startTest();
        User userGFc = [SELECT Id FROM User WHERE Alias = 'AV-TF9' AND IsActive= true LIMIT 1];
        User userWithNoEap = [SELECT ID FROM USER WHERE ID NOT IN (SELECT AV_UsuarioAsociado__c FROM Contact) AND AV_ExternalID__c != null and AV_NumeroOficinaEmpresa__c != null LIMIT 1];
        Event event = [SELECT Id FROM Event WHERE Subject = 'Call' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_MOCNT', 'OK'));
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        event.OwnerId = userWithNoEap.Id;
        System.runAs(userGFc){
            Database.update(event);
        }
        Test.stopTest();
        Event result = [SELECT Id, OwnerId FROM Event WHERE Subject = 'Call' LIMIT 1];
        System.assertEquals(userGFc.id,result.OwnerId,'No se ha actualizado el owner');
    }
    
    @isTest 
    public static void validateUpdateNextManagementOpp(){

        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        system.runAs(usuGcf){
            User userGt = [SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND AV_ExternalID__c='U01545400' LIMIT 1];
            Account cliente = [Select Id from Account WHERE CC_Numero_Documento__c = '9446386T' limit 1];
            Account center = [Select Id from Account WHERE CC_Numero_Oficina_Empresa__c = '00615' limit 1];
            Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGt.Id];
            AV_TestHelper.createTarea(userGt, System.today());
            Event evTest = AV_TestHelper.createEvent(userGt, Datetime.now(),cliente);
            evTest.CSBD_Evento_Estado__c='Pendiente'; 
            Opportunity opp = AV_TestHelper.createOpportunityExternalId(cliente, cont, evTest.AV_ExternalID__c);
            Test.startTest();
            String lhtid = evTest.AV_Task__c;
            AV_TestHelper.createTareaOportunidad(opp,lhtid);
            List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
            CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
            listDummyWords.add(word);
            CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
            listDummyWords.add(word2);
            Database.insert(listDummyWords, false);
        }
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_MOCNT','OK'));
        User userG = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND AV_ExternalID__c='U01545400' LIMIT 1];     
        Event evento = [SELECT Id,OwnerId, ActivityDate, AV_ExternalID__c,AV_Task__c FROM Event LIMIT 1 ];
        String extId = evento.AV_ExternalID__c;
        AV_HeaderCustomActivity__c headerTask = [Select id,OwnerId, AV_ExternalID__c from AV_HeaderCustomActivity__c where AV_ExternalID__c =: extId];
        headerTask.OwnerId = userG.Id;
        update headerTask;
        Opportunity opp = [SELECT Id,OwnerId FROM Opportunity LIMIT 1];
        String lhtid = evento.AV_Task__c;
        AV_CustomActivityOpportunity__c cao = AV_TestHelper.createTareaOportunidad(opp,lhtid);
        cao.OwnerId = userG.Id;
        update cao;
  		System.runAs(userG){
            evento.ActivityDateTime = System.now() + 100;
            evento.CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE;
            update evento;
        }
        Test.stopTest();
        Opportunity retrivOpp = [SELECT AV_FechaProximoRecordatorio__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        Event retrivEvt = [SELECT ActivityDate FROM Event WHERE Id = :evento.id LIMIT 1];
        System.assertEquals(retrivOpp.AV_FechaProximoRecordatorio__c,retrivEvt.ActivityDate,'No se ha actualizado bien');
    }
    

    @isTest 
    public static void setEventChanelAndPurposeTest(){
        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        system.runAs(usuGcf){
            User userGt = [SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND AV_ExternalID__c='U01545400' LIMIT 1];
            Account cliente = [Select Id from Account WHERE CC_Numero_Documento__c = '9446386T' limit 1];
            Account center = [Select Id from Account WHERE CC_Numero_Oficina_Empresa__c = '00615' limit 1];
            Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGt.Id];
            AV_TestHelper.createTarea(userGt, System.today());
            Event evTest = AV_TestHelper.createEvent(userGt, Datetime.now(),cliente);
            evTest.CSBD_Evento_Estado__c='Pendiente'; 
            Opportunity opp = AV_TestHelper.createOpportunityExternalId(cliente, cont, evTest.AV_ExternalID__c);
            String lhtid = evTest.AV_Task__c;
            AV_TestHelper.createTareaOportunidad(opp,lhtid);
            List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
            CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
            listDummyWords.add(word);
            CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
            listDummyWords.add(word2);
            Database.insert(listDummyWords, false);
        }
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_MOCNT', 'OK'));
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        RecordType clienteEvtRt = AV_AppUtilities.getRecordType('Event','AV_EventosConCliente');
		RecordType customerRt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, AV_AppConstants.ACCOUNT_PA_RT);
        User us  = [SELECT Id FROM User WHERE AV_ExternalID__c='U01545400' LIMIT 1];
        User sinGestorEap = [SELECT ID FROM USER WHERE Alias = 'AV-TF9'];
        Account customer = [SELECT Id FROM Account WHERE RecordTypeId = :customerRt.id LIMIT 1];
        Event eventoCliente = new Event();
        eventoCliente.OwnerId = us.Id;
        eventoCliente.WhatId = customer.Id; 
        eventoCliente.Location = 'Microsoft Teams';
        eventoCliente.subject = 'TestEvento';
        eventoCliente.RecordTypeId = clienteEvtRt.Id;
        eventoCliente.StartDateTime = System.now().addDays(1);
        eventoCliente.EndDateTime = eventoCliente.StartDateTime.addHours(1);
        eventoCliente.CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE;
        eventoCliente.AV_OrigenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP;
		eventoCliente.AV_Tipo__c = 'CTO';   
        eventoCliente.AV_Chanel__c = '002';
        eventoCliente.AV_CodigoGestorAsignado__c = '001-99999';
        System.runAs(us){
            insert eventoCliente;
        }
        Event eventoOutMC = new Event();
        eventoOutMC.OwnerId = SinGestorEap.Id;
        eventoOutMC.WhatId = customer.Id; 
        eventoOutMC.Location = 'EQUIPO';
        eventoOutMC.subject = 'TestEventoOutMc';
        eventoOutMC.RecordTypeId = clienteEvtRt.Id;
        eventoOutMC.StartDateTime = System.now().addDays(1);
        eventoOutMC.EndDateTime = eventoCliente.StartDateTime.addHours(1);
        eventoOutMC.CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE;
        eventoOutMC.AV_OrigenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP;
		eventoOutMC.AV_Tipo__c = 'CTO'; 
        eventoOutMC.AV_CodigoGestorAsignado__c = '001-99999';
        System.runAs(SinGestorEap){
            insert eventoOutMc;
        }
        String channel = [SELECT AV_Chanel__c FROM Event WHERE Subject ='TestEvento' LIMIT 1].AV_Chanel__c;
        String channelOutMC = [SELECT AV_Chanel__c FROM Event WHERE Subject = 'TestEventoOutMc' LIMIT 1].AV_Chanel__c;
        Test.stopTest();
        System.assertEquals(AV_AppConstants.CHANEL_MC,channel,'');
        System.assert(String.isBlank(channelOutMC));
    }

    /**
	 * Execute the Trigger class (AV_Event_AD_TRHan)
	 */
	@isTest
	public static void executeEventTriggerDelete() {
        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        Event evTest;
        User userGt = [SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND AV_ExternalID__c='U01545400' LIMIT 1];
        system.runAs(usuGcf){
            Account cliente = [Select Id from Account WHERE CC_Numero_Documento__c = '9446386T' limit 1];
            Account center = [Select Id from Account WHERE CC_Numero_Oficina_Empresa__c = '00615' limit 1];
            Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGt.Id ];
            AV_TestHelper.createTarea(userGt, System.today());
            evTest = AV_TestHelper.createEvent(userGt, Datetime.now(),cliente);
            evTest.CSBD_Evento_Estado__c='Pendiente'; 
            Opportunity opp = AV_TestHelper.createOpportunityExternalId(cliente, cont, evTest.AV_ExternalID__c);
        Test.startTest();
            
            String lhtid = evTest.AV_Task__c;
            AV_TestHelper.createTareaOportunidad(opp,lhtid);
            List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
            CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
            listDummyWords.add(word);
            CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
            listDummyWords.add(word2);
            Database.insert(listDummyWords, false);
        }
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        Event ev = [Select id, AV_ExternalID__c, ActivityDate from Event WHERE Id = :evTest.Id limit 1];
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        System.runAs(userGt){
            delete ev;
        }
		Test.stopTest();
        List<Event> eventDeleted = [Select id, AV_ExternalID__c, ActivityDate from Event limit 1];
        System.assertEquals(0 , eventDeleted.size());
    }    
    
	@isTest
	public static void changeSubjectToCanceledTest() {
        User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        system.runAs(usuGcf){
            User userGt = [SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND AV_ExternalID__c='U01545400' LIMIT 1];
            Account cliente = [Select Id from Account WHERE CC_Numero_Documento__c = '9446386T' limit 1];
            Account center = [Select Id from Account WHERE CC_Numero_Oficina_Empresa__c = '00615' limit 1];
            Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGt.Id];
            AV_TestHelper.createTarea(userGt, System.today());
            Event evTest = AV_TestHelper.createEvent(userGt, Datetime.now(),cliente);
            evTest.CSBD_Evento_Estado__c='Pendiente'; 
            Opportunity opp = AV_TestHelper.createOpportunityExternalId(cliente, cont, evTest.AV_ExternalID__c);
            String lhtid = evTest.AV_Task__c;
            AV_TestHelper.createTareaOportunidad(opp,lhtid);
            List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
            CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
            listDummyWords.add(word);
            CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
            listDummyWords.add(word2);
            Database.insert(listDummyWords, false);
        }
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        Test.startTest();
        User userGFc = [SELECT ID FROM USER WHERE Alias = 'AV-TF9' AND IsActive= true LIMIT 1];
        RecordType rtCliente = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT,AV_AppConstants.EVENTCLIENTE_RT);
        Event ev = [Select id, CSBD_Evento_Estado__c, RecordType.Name, RecordTypeId from Event limit 1];
        if(ev.RecordTypeId  == rtCliente.Id){
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
            ev.AV_ToDelete__c = true;
            System.runAs(userGFc){
                update ev;
            }
            Event evResult = [Select id, CSBD_Evento_Estado__c from Event WHERE Id = : ev.Id limit 1];
            System.assertEquals( 'Cancelado' , evResult.CSBD_Evento_Estado__c);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testDeleteEvent() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];  
        User userGt = [SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND AV_ExternalID__c='U01545400' LIMIT 1];
        Account cliente = [Select Id from Account WHERE CC_Numero_Documento__c = '9446386T' limit 1];
        Account center = [Select Id from Account WHERE CC_Numero_Oficina_Empresa__c = '00615' limit 1];
        Contact cont = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGt.Id];
        Event evTest = AV_TestHelper.createEvent(userGt, Datetime.now(),cliente);
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_DELCNT','OK'));
        Test.startTest();
        List<Event> listEvent = new List<Event> {evTest};
        System.runAs(usuarioGcf){
            AV_EventTriggerHelper.deleteEvent(listEvent);
            delete evTest;
        }
        Test.stopTest();
        List<Event> eventAfter = [Select Id from Event WHERE Id = :evTest.Id limit 1];
        System.assertEquals(eventAfter.isEmpty(), true);
    }

    @isTest
    public static void assignPoolEventsTest(){
        List<AV_MultiEmployees__mdt> mdts = [SELECT Id,DeveloperName,AV_NumeroOficinaEmpresa__c, AV_Alias__c FROM AV_MultiEmployees__mdt LIMIT 1];
        User userGt = [SELECT Id, AV_ExternalID__c FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND AV_ExternalID__c='U01545400' LIMIT 1];
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];  
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        List<User> userBPAList = [SELECT Id,AV_ExternalId__c,AV_NumeroOficinaEmpresa__c FROM User WHERE Alias = :AV_AppConstants.BPA_EVENT_USER AND  Profile.Name = 'AV_Usuario_CaixaBank' LIMIT 1];
        User userBPA;
        Boolean createBPA = false;
        Boolean createMulti = false;
        if(!userBPAList.isEmpty()){
            userBPA = userBPAList[0];
        }else{
            createBPA = true;
        }
        List<User> userMultigestorList = [SELECT Id,AV_ExternalId__c,AV_NumeroOficinaEmpresa__c FROM User WHERE Alias = :mdts[0].AV_Alias__c AND  AV_NumeroOficinaEmpresa__c = :mdts[0].AV_NumeroOficinaEmpresa__c LIMIT 1];
        User userMultigestor;
        if(!userMultigestorList.isEmpty()){
            userMultigestor = userMultigestorList[0];
        }else{
            createMulti = true;
        }

        if(createBPA || createMulti){
            List<User> usersToAdd = new List<User>();
            if(createBPA){
                userBPA = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','000001','AV_SistematicaComercial');
                userBPA.Alias = AV_AppConstants.BPA_EVENT_USER;
                userBPA.AV_NumeroOficinaEmpresa__c = '001-00000';
                userBPA.AV_NumeroOficinaEmpresa__c = '000001';
                userBPA.AV_ExternalId__c = 'EXAMPLE80';
                usersToAdd.add(userBPA);
            }
            
            if(createMulti){
                
                userMultigestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','0099101','AV_SistematicaComercial');
                userMultigestor.Alias = mdts[0].AV_Alias__c;
                userMultigestor.AV_NumeroOficinaEmpresa__c = mdts[0].AV_NumeroOficinaEmpresa__c;
                usersToAdd.add(userMultigestor);
            }

            insert usersToAdd;
            if(createBPA){
                AV_TestHelper.createEmployee(null,userBPA,userBPA.AV_ExternalID__c);
            }
        }


        Account dTCenter = AV_TestHelper.createCaixaCenterSinInsert();
        dTCenter.AV_TipoEstructura__c = '02';
        dTCenter.AV_TipoCentroSuperior__c = 'TT';
        dTCenter.CC_Numero_Oficina_Empresa__c = mdts[0].AV_NumeroOficinaEmpresa__c;
        dTCenter.CC_Numero_Oficina__c = dTCenter.CC_Numero_Oficina__c;
        insert dTCenter;
        Account center = [Select Id from Account WHERE CC_Numero_Oficina_Empresa__c = '00615' limit 1];
        update new Account(Id = center.Id,AV_CentroSuperior__c = dTCenter.Id);
        Account cliente = [Select Id from Account WHERE CC_Numero_Documento__c = '9446386T' limit 1];

        System.runAs(usuarioGcf){
            Test.startTest();
            Event evt = AV_TestHelper.createEventExternalIdSinInsert(userBPA,System.today().addDays(3),'001843475',cliente);
            evt.AV_Center__c = '00615';
            insert evt;
            Event correctEvt = [SELECT Id,OwnerId FROM Event WHERE Id = :evt.Id];
            System.assert(correctEvt.OwnerId == userMultigestor.Id,'Se esperaba a '+userMultigestor.Id+'pero se obtuvo a '+correctEvt.OwnerId);
            Test.stopTest();
        }



    }
}