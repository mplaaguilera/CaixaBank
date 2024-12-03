/**********************************************************************************************************************
Name:	  CIBE_CitaPrevia_SyncEvents_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Sync de Eventos Test
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY	   AUTHOR		   		DATE			Description
    1.0			Test Class	   Luis Martínez	   	20/10/2022		Init version
***********************************************************************************************************************/  
@isTest
public with sharing class CIBE_CitaPrevia_SyncEvents_Test {
    public static String username;
    @TestSetup
    static void setup(){
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        User usrGes = CIBE_TestHelper.loginUser('CIBE_Gestor', null, 'U0009009',ps);
        //Run As ByPass Non Setup Object
        System.runAs(new User(Id = UserInfo.getUserId())) {
            CIBE_TestHelper.activateLogger();
            CIBE_TestHelper.createPricebook2();
            Account acc = CIBE_TestHelper.createCaixaCenter();
            Account customer = CIBE_TestHelper.createCustomer();
            User usuario = CIBE_TestHelper.createUser('CIBE_Gestor');
            system.debug('@usuario: '+usuario);

            Contact contactAux = CIBE_TestHelper.createEmployee(acc, usuario);
            
            CBK_IntegrationSetting__c endpointConf = new CBK_IntegrationSetting__c(Name='CIBE_citaprevia_int', NamedCredential__c = 'CIBE_citaprevia_int');
            insert endpointConf;
            
        } 
        
        System.runAs(usrGes) {
            ID rtCli = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.ACCOUNT_CLIENTE_RT).getRecordTypeId();
            ID rtConId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.EMPLOYEE_RT).getRecordTypeId();
        
            Account acc = new Account(
                Name = 'Test Name2',
                RecordTypeId = rtCli,
                AV_NumPerso__c = '1234',
                AV_Negocio__c = 'BPA',
                ownerId = usrGes.Id
            );
        
            List<Account> lstCli = new List<Account>{acc};
            insert lstCli;
        
        }
    }   
    
    /**
    * Execute the class (CIBE_CitaPrevia_SyncEvents) and insert Event update event  
    */
    @isTest
    public static void insertOrUpdateEventTrueTest() {
        User runAsUser = new User();
        runAsUser = [SELECT Id, username, AV_ExternalID__c,AV_NumeroOficinaEmpresa__c FROM User 
        WHERE AV_ExternalID__c = 'U0009009' AND CreatedDate = TODAY AND CreatedbyId =:UserInfo.getUserId()LIMIT 1];
        System.runAs(runAsUser) {
            
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
            Account customer =  [SELECT Id FROM Account Where AV_NumPerso__c = '1234' AND  Name = 'Test Name2' AND ownerId=:runAsUser.id Limit 1];
            Contact contactoComercial = CIBE_TestHelper.createRepresentante(customer, null, '71234567');
            Test.startTest();
                Event customerEvent = CIBE_TestHelper.createEventConCliente(runAsUser, System.now(), customer);
                customerEvent.WhoId = contactoComercial.id;
                update customerEvent;
                List<Event> listEvent = new  List<Event>{customerEvent};
                String jsonString = json.serialize(listEvent);
                System.assert(jsonString!= null);
                CIBE_CitaPrevia_SyncEvents.insertOrUpdateEvent(jsonString, true);
            Test.stopTest();
            
        }
    }
    
    /**
* Execute the class (CIBE_CitaPrevia_SyncEvents) and insert Event update event  
*/
    @isTest
    public static void insertOrUpdateEventFalseTest() {
        
        User runAsUser = new User();
        runAsUser = [SELECT Id, username, AV_ExternalID__c,AV_NumeroOficinaEmpresa__c FROM User 
        WHERE AV_ExternalID__c = 'U0009009' AND CreatedDate = TODAY AND CreatedbyId =:UserInfo.getUserId()LIMIT 1];
        System.runAs(runAsUser) {
            
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
            Account customer =  [SELECT Id FROM Account Where AV_NumPerso__c = '1234' AND  Name = 'Test Name2' AND ownerId=:runAsUser.id Limit 1];
            Contact contactoComercial = CIBE_TestHelper.createRepresentante(customer, null, '71234567');
            Test.startTest();
                Event customerEvent = CIBE_TestHelper.createEventConCliente(runAsUser, System.now(), customer);
                customerEvent.WhoId = contactoComercial.id;
                // UndecidedEventRelation
                EventRelation uer = new EventRelation();
                uer.EventId = customerEvent.Id;
                uer.RelationId = contactoComercial.id;
                uer.IsInvitee = true;
                uer.Status = 'Accepted';
                insert uer;
        
                update customerEvent; 
                
                Event customerEvent2 = CIBE_TestHelper.createEventConCliente(runAsUser, System.now(), customer);
                customerEvent2.RecordTypeId = (CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT)).Id;
                update customerEvent2;
                
                Event customerEvent3 = CIBE_TestHelper.createEventConCliente(runAsUser, System.now(), customer);
                customerEvent3.AV_Tipo__c = CIBE_AppConstants.VIDEOLLAMADA_TIPO;
                
                update customerEvent3;
                
                List<Event> listEvent = new  List<Event>{customerEvent,customerEvent2,customerEvent3};
                String jsonString = json.serialize(listEvent);
                System.assert(jsonString!= null);
                CIBE_CitaPrevia_SyncEvents.insertOrUpdateEvent(jsonString, false);
            Test.stopTest();
            
        }
    }
    
    /**
* Execute the class (CIBE_CitaPrevia_SyncEvents) and insert Event not update event 
*/
    @isTest
    public static void getExternalIdRecurrentEventTest() {
        User runAsUser = new User();
        runAsUser = [SELECT Id, username, AV_ExternalID__c,AV_NumeroOficinaEmpresa__c FROM User 
        WHERE AV_ExternalID__c = 'U0009009' AND CreatedDate = TODAY AND CreatedbyId =:UserInfo.getUserId()LIMIT 1];
        System.runAs(runAsUser) {
            Map<String, String> mapEventsId =  new Map<String, String>();
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','KO'));
            Account customer =  [SELECT Id FROM Account Where AV_NumPerso__c = '1234' AND  Name = 'Test Name2' AND ownerId=:runAsUser.id Limit 1];
            Event customerEvent = CIBE_TestHelper.createEventConCliente(runAsUser, System.now(), customer);
            Event recurrenceEvent = CIBE_TestHelper.createEventConClienteRecurrente(runAsUser, customer);
            String externalId = '999999';
            AV_HeaderCustomActivity__c acthead = new AV_HeaderCustomActivity__c(
                AV_ExternalID__c = externalId,
                AV_ToDelete__c = true,
                IDTask__c = customerEvent.Id
            );
            insert acthead;
            EventRelation uer = new EventRelation();
            uer.EventId = customerEvent.Id;
            uer.RelationId = runAsUser.id;
            uer.IsInvitee = true;
            uer.Status = 'New';
            insert uer;
            
            Test.startTest();
                Map<Id,Event> mapRecurrentEvents = new Map<Id,Event>([SELECT Id,CreatedDate FROM Event]);
                Map<String, String> result = CIBE_CitaPrevia_SyncEvents.getExternalIdRecurrentEvent(mapRecurrentEvents);
                System.assert(result != null);
            Test.stopTest();
        }
    }
    
    /**
* Execute the class (CIBE_CitaPrevia_SyncEvents) and insert Event not update event 
*/
    @isTest
    public static void createRecurrentEventHeaderTest() {
        User runAsUser = new User();
        runAsUser = [SELECT Id, username, AV_ExternalID__c,AV_NumeroOficinaEmpresa__c FROM User 
        WHERE AV_ExternalID__c = 'U0009009' AND CreatedDate = TODAY AND CreatedbyId =:UserInfo.getUserId()LIMIT 1];        
        System.runAs(runAsUser) {
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
            Account customer =  [SELECT Id FROM Account Where AV_NumPerso__c = '1234' AND  Name = 'Test Name2' AND ownerId=:runAsUser.id Limit 1];
            String externalId = CIBE_CitaPrevia_SyncEvents.SUFFIX_EXTERNALID + '$OPP$#' + (Math.round(Math.random()*1000000) + Datetime.now().getTime());
            
            Test.startTest();
                Event customerEvent = CIBE_TestHelper.createEventConCliente(runAsUser, System.now(), customer);
                AV_HeaderCustomActivity__c headerActivity = CIBE_CitaPrevia_SyncEvents.createRecurrentEventHeader(customerEvent, externalid);
                System.assert(headerActivity!= null);
            Test.stopTest();
        }
    }
    
    /**
    * Execute the class (CIBE_CitaPrevia_SyncEvents) and insert Event not update event 
    */
    @isTest
    public static void checkCrmTaskOverrideTest() {
        List<CBK_Activity_Extension__c> listActExt =  new List<CBK_Activity_Extension__c>();
        List<CBK_Activity_Extension__c> listActExt2 =  new List<CBK_Activity_Extension__c>();
        User runAsUser = new User();
        runAsUser = [SELECT Id, username, AV_ExternalID__c,AV_NumeroOficinaEmpresa__c FROM User 
        WHERE AV_ExternalID__c = 'U0009009' AND CreatedDate = TODAY AND CreatedbyId =:UserInfo.getUserId()LIMIT 1];        
        System.runAs(runAsUser) {
            Test.startTest();
                Account customer =  [SELECT Id FROM Account Where AV_NumPerso__c = '1234' AND  Name = 'Test Name2' AND ownerId=:runAsUser.id Limit 1];
                Task tareaAC = CIBE_TestHelper.createTareaOtherExternalID(runAsUser);
                Contact contactAux = CIBE_TestHelper.createRepresentante(null, runAsUser, '000000000');
                Task experiencia = CIBE_TestHelper.createTareaExternalIdWithCustomerExp(runAsUser,'01928374', customer);
                experiencia.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_CIB_RT).Id;
                experiencia.Status='Closed';
                experiencia.AV_Valor1__c = 'Momento - Visita All-in-one';
                update experiencia;
                
                CBK_Activity_Extension__c actExt = new CBK_Activity_Extension__c();
                actExt.AV_AccionesARealizar__c = 'OECP';
                actExt.AV_ActivityId__c = experiencia.Id;
                actExt.AV_ReasignarCartera_Id_Task__c = tareaAC.Id;
                actExt.AV_StatusCodeAPI__c = '200';
                insert actExt ;
                listActExt.add(actExt);
                
                List<CBK_Activity_Extension__c> crmTaskToUpdate = CIBE_CitaPrevia_SyncEvents.checkCrmTaskOverride(listActExt);
                System.assert(!crmTaskToUpdate.isEmpty());
            
            Test.stopTest();   
        }
    }
    
    /**
    * Execute the class (CIBE_CitaPrevia_SyncEvents) and insert Event not update event 
    */
    @isTest
    public static void checkCrmTaskOverride2Test() {
        List<CBK_Activity_Extension__c> listActExt =  new List<CBK_Activity_Extension__c>();
        List<CBK_Activity_Extension__c> listActExt2 =  new List<CBK_Activity_Extension__c>();
    
        User runAsUser = new User();
        runAsUser = [SELECT Id, username, AV_ExternalID__c,AV_NumeroOficinaEmpresa__c FROM User 
        WHERE AV_ExternalID__c = 'U0009009' AND CreatedDate = TODAY AND CreatedbyId =:UserInfo.getUserId()LIMIT 1];
        System.runAs(runAsUser) {
            Test.startTest();
                Account customer =  [SELECT Id FROM Account Where AV_NumPerso__c = '1234' AND  Name = 'Test Name2' AND ownerId=:runAsUser.id Limit 1];
                Task tareaAC = CIBE_TestHelper.createTareaOtherExternalID(runAsUser);
                Contact contactAux = CIBE_TestHelper.createRepresentante(null, runAsUser, '000000000');
                Task experiencia = CIBE_TestHelper.createTareaExternalIdWithCustomerExp(runAsUser,'01928374', customer);
                experiencia.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_CIB_RT).Id;
                experiencia.Status='Closed';
                experiencia.AV_Valor1__c = 'Momento - Visita All-in-one';
                update experiencia;
                
                CBK_Activity_Extension__c actExt = new CBK_Activity_Extension__c();
                actExt.AV_AccionesARealizar__c = 'OECP';
                actExt.AV_ActivityId__c = experiencia.Id;
                actExt.AV_StatusCodeAPI__c = '200';
                insert actExt ;
                listActExt.add(actExt);
                
                List<CBK_Activity_Extension__c> crmTaskToUpdate = CIBE_CitaPrevia_SyncEvents.checkCrmTaskOverride(listActExt);
                System.assert(!crmTaskToUpdate.isEmpty());
            
            Test.stopTest();   
        }
    }
    
}