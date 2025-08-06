/**********************************************************************************************************************
 Name:	  CIBE_Oportunidades_Vinculadas_Cntr_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Test para el controlador CIBE_Oportunidades_Vinculadas_Controller
Proposito: Clase de Test para el controlador CIBE_FeedItemUtilities
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Jose Maria			21/07/2022			Test Class
    1.1			US584194		Lucía   			03/07/2023			metodos nuevos roleCib y updateEventCIBTest

***********************************************************************************************************************/

@isTest
public with sharing class CIBE_Oportunidades_Vinculadas_Cntr_Test {
    
    @TestSetup
    static void setup(){

        CIBE_TestHelper.loginUser(null, CIBE_AppConstants.CIBE_ROLEMP, 'U0000001', new List<String>{
            CIBE_AppConstants.CIBE_OPERATIVAEMP,
            CIBE_AppConstants.CIBE_CUSTOMMETADATA
        });
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];


        ID rtOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.OPP_INICIATIVAEMP_RT).getRecordTypeId();
        ID rtAcc = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.ACCOUNT_CLIENTE_RT).getRecordTypeId();

        System.runAs(usuario) {

            Account acc = new Account(
                Name = 'Sin Cliente',
                AV_InterlocName__c = 'Sin Cliente',
                RecordTypeId = rtAcc,
                AV_NumPerso__c = '12345',
                AV_Negocio__c = 'EMP',
                OwnerId = usuario.Id
            );
            insert acc;

            RecordType rtEmployee = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.EMPLOYEE_RT);
            Contact employee = new Contact();
            employee.RecordTypeId = rtEmployee.Id;
            employee.AV_UsuarioAsociado__c = usuario.Id;
            employee.FirstName = 'Employee';
            employee.LastName = 'U0000001';
            employee.Email = 'U0000001' + '@test.dev';
            employee.CC_Idioma__c = 'es';
            employee.CC_Matricula__c = 'U0000001';
            employee.OwnerId = usuario.Id;
            insert employee;
        

            Event event  = CIBE_TestHelper.createEvent(usuario, System.now(), acc);
            event.AV_Tipo__c = 'EC';
            update event;

            Opportunity opp = new Opportunity();
                opp.AccountId = acc.Id;
                opp.Name = 'Alerta Comercial';
                opp.StageName = 'En gestión/insistir';
                opp.RecordTypeId = rtOpp;
                opp.CloseDate = System.today() + 5;
                opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
                opp.AV_ExternalID__c = event.AV_ExternalID__c;
                opp.OwnerId = usuario.Id;
            insert opp;


            // String idCabeceraTarea = [SELECT AV_Task__c FROM Event WHERE AV_ExternalID__c = :event.AV_ExternalID__c LIMIT 1].AV_Task__c;
            // AV_CustomActivityOpportunity__c tareaOpp= new AV_CustomActivityOpportunity__c();
            // tareaOpp.Name = 'Llamada Saliente - Alerta Comercial';
            // tareaOpp.AV_Opportunity__c = opp.Id;
            // tareaOpp.AV_Task__c = idCabeceraTarea;
            // tareaOpp.OwnerId = usuario.Id;
            // insert tareaOpp;

            RecordType rtTask = AV_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_EMP_RT);
            Task tarea  = new Task();
            tarea.Subject = 'Llamada Saliente';
            tarea.AV_Tipo__C = 'VC';
            tarea.OwnerId = usuario.Id;
            tarea.Status = 'Pendiente no localizado';
            tarea.Priority = 'Normal';
            tarea.AV_ExternalID__c = '01928363';
            tarea.RecordTypeId = rtTask.Id;
            tarea.ActivityDate = System.today()-3;
            insert tarea;

        }
    }
            
    
	@isTest
	public static void getStatusValueTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
                List<Map<String, String>> listMapValue = CIBE_Oportunidades_Vinculadas_Controller.getStatusValues('Opportunity', 'StageName');
                System.assert(listMapValue != Null); 
            Test.stopTest();
        }
    }
    
    
	@isTest
	public static void getRecordInfoTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();    
                Event evento = [SELECT Id FROM Event WHERE Subject = 'Call' LIMIT 1];
                List<AV_CustomActivityOpportunity__c> listActivityOpp  = CIBE_Oportunidades_Vinculadas_Controller.getRecordInfo(String.valueOf(evento.id), 'Event');	
                System.assert(listActivityOpp != Null); 
            Test.stopTest();
        }

    }
    
        
    @isTest
	public static void unlinkOppTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();    
                Event evento = [SELECT Id, AV_Task__c FROM Event WHERE Subject = 'Call' LIMIT 1];
                Opportunity  opp = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial' LIMIT 1];
                CIBE_Oportunidades_Vinculadas_Controller.unlinkOpp(opp.Id, evento.id);
                List<AV_CustomActivityOpportunity__c> lstDelete = [SELECT Id FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c=:opp.Id Limit 1];
                System.assertEquals(0, lstDelete.size()); 
            Test.stopTest();	
        }
    }
    

    @isTest
	public static void unlinkOppTest2() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();    
                Event evento = [SELECT Id, AV_Task__c FROM Event WHERE Subject = 'Call' LIMIT 1];
                Opportunity  opp = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial' LIMIT 1];
                CIBE_TestHelper.createTareaOportunidad(opp, evento.AV_Task__c);
                CIBE_Oportunidades_Vinculadas_Controller.unlinkOpp(opp.Id, evento.id);
                List<AV_CustomActivityOpportunity__c> lstDelete = [SELECT Id FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c=:opp.Id Limit 1];
                System.assertEquals(0, lstDelete.size()); 
            Test.stopTest();	
        }
    }
    
    // Event
    @isTest
	public static void linkOppTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();  
                Event event = [SELECT Id, OwnerId, AV_Task__c, AV_ExternalID__c FROM Event WHERE Subject = 'Call' LIMIT 1];
                Opportunity opp = [SELECT Id, OwnerId FROM Opportunity WHERE Name = 'Alerta Comercial' LIMIT 1];
                String idCabeceraTarea = [SELECT AV_Task__c FROM Event WHERE AV_ExternalID__c = :event.AV_ExternalID__c LIMIT 1].AV_Task__c;
                AV_CustomActivityOpportunity__c tareaOpp= new AV_CustomActivityOpportunity__c();
                tareaOpp.Name = 'Llamada Saliente - Alerta Comercial';
                tareaOpp.AV_Opportunity__c = opp.Id;
                tareaOpp.AV_Task__c = idCabeceraTarea;
                tareaOpp.OwnerId = usuario.Id;
                insert tareaOpp;
                String cadena = CIBE_Oportunidades_Vinculadas_Controller.linkOpp(event.Id,opp.Id);	
                System.assert(cadena == 'KO');
                Task tarea = [select id, Description, AV_Task__c from Task where subject = 'Llamada Saliente'];
                AV_CustomActivityOpportunity__c tareaOpp2 = new AV_CustomActivityOpportunity__c();
                tareaOpp2.Name = 'Llamada Saliente - Alerta Comercial';
                tareaOpp2.AV_Opportunity__c = opp.Id;
                tareaOpp2.AV_Task__c = tarea.AV_Task__c;
                tareaOpp2.OwnerId = usuario.Id;
                insert tareaOpp2;
                String cadena2 = CIBE_Oportunidades_Vinculadas_Controller.linkOpp(tarea.Id,opp.Id);	
                System.assert(cadena2 == 'KO');
            Test.stopTest();
        }
    }

    @isTest
	public static void updateMainRecordTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Event evento = new Event ();
        Opportunity  opp = new Opportunity();

        System.runAs(usuario) {
        Test.startTest();   
            evento = [SELECT Id , AV_ExternalID__c FROM Event WHERE RecordType.developername =:CIBE_AppConstants.EVENT_CLIENTE_RT AND subject = 'Call' LIMIT 1];
            opp = [SELECT Id FROM Opportunity WHERE Name ='Alerta Comercial' AND RecordType.developername =:CIBE_AppConstants.OPP_INICIATIVAEMP_RT LIMIT 1];
            String idCabeceraTarea = [SELECT AV_Task__c FROM Event WHERE AV_ExternalID__c = :evento.AV_ExternalID__c LIMIT 1].AV_Task__c;
            AV_CustomActivityOpportunity__c tareaOpp= new AV_CustomActivityOpportunity__c();
            tareaOpp.Name = 'Llamada Saliente - Alerta Comercial';
            tareaOpp.AV_Opportunity__c = opp.Id;
            tareaOpp.AV_Task__c = idCabeceraTarea;
            tareaOpp.OwnerId = usuario.Id;
            insert tareaOpp;
            CIBE_Oportunidades_Vinculadas_Controller.updateMainRecord(evento.id,opp.Id);
            List<AV_CustomActivityOpportunity__c> co = [SELECT id FROM AV_CustomActivityOpportunity__c];
        Test.stopTest();
        System.assert(co.isEmpty() == false ); 
        System.assertEquals(false, co.isEmpty());
        }

    }
    
    @isTest
	public static void retrieveListWithOutTaskTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuario) {
        Test.startTest();
            Event evento = [SELECT Id FROM Event WHERE Subject = 'Call' LIMIT 1];
            Opportunity  opp = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial' LIMIT 1];
            List <AV_CustomActivityOpportunity__c> tareaOpp = [select id,AV_Opportunity__c from AV_CustomActivityOpportunity__c];
            List<Opportunity> listOpp=CIBE_Oportunidades_Vinculadas_Controller.retrieveListWithOutTask(tareaOpp,evento.id,'Event');
            System.assert(evento.id != null ); 
        Test.stopTest();
        }
    }

    @isTest
	public static void retrieveListWithOutTaskTest2() {
        ID rtAcc = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.ACCOUNT_CLIENTE_RT).getRecordTypeId();

        CIBE_TestHelper.loginUser(null, CIBE_AppConstants.CIBE_ROLECIB, 'U0000002', new List<String>{
            CIBE_AppConstants.CIBE_OPERATIVAEMP,
            CIBE_AppConstants.CIBE_CUSTOMMETADATA
        });
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000002' LIMIT 1];

        System.runAs(usuario) {
        Test.startTest();
            Account acc = new Account(
                Name = 'Test',
                RecordTypeId = rtAcc,
                AV_NumPerso__c = '000',
                OwnerId = usuario.Id
            );
            insert acc;
            Event evento  = CIBE_TestHelper.createEvent(usuario, System.now(), acc);
            List <AV_CustomActivityOpportunity__c> tareaOpp = [select id,AV_Opportunity__c from AV_CustomActivityOpportunity__c];
            List<Opportunity> listOpp=CIBE_Oportunidades_Vinculadas_Controller.retrieveListWithOutTask(tareaOpp,evento.id,'Event');
            System.assert(evento.id != null ); 
        Test.stopTest();
        }
    }
    
    @isTest
	public static void getOppFieldsTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Test.startTest();
        System.runAs(usuario) {
            List<Opportunity>  opp = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial' LIMIT 1];
            Opportunity oportunity=CIBE_Oportunidades_Vinculadas_Controller.getOppFields(opp[0].Id);	
            System.assert(opportunity.id != null ); 
        Test.stopTest();
        }

    }
    
    @isTest
	public static void updateEventEMPTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];        
        System.runAs(usuario) {
            Test.startTest();
                Event evento = [SELECT Id, OwnerId FROM Event WHERE AV_Tipo__c = 'EC' AND OwnerId = :usuario.Id LIMIT 1 ];
                CIBE_Oportunidades_Vinculadas_Controller.updateEvent(evento.Id);
                Event evento2 = [SELECT Id, CSBD_Evento_Estado__c  FROM Event WHERE Id =: evento.Id];
                System.assertEquals('Gestionada Positiva', evento2.CSBD_Evento_Estado__c); 
        Test.stopTest();

        }
    }

    
    
    @isTest
	public static void updateRecordsTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();    
                Opportunity  opp = [SELECT id, AV_Comentarios__c FROM Opportunity WHERE Name = 'Alerta Comercial' LIMIT 1];
                
                Map<String, Object> mapDato= new Map<String, Object>();
                    mapDato.put('id',opp.id);
                    mapDato.put('encurso','En Tramite');
                    mapDato.put('status','En Curso');
                    mapDato.put('exito','Alta');
                    mapDato.put('amount','123');
                    mapDato.put('closedate', System.now());
                    mapDato.put('lastcoment','texto de prueba ');
                
                List<Map<String, Object>> listDato= new List<Map<String, Object>> ();
                listDato.add(mapDato);
                
                CIBE_Oportunidades_Vinculadas_Controller.updateRecords(listDato);
                
                System.assert(opp.AV_Comentarios__c != null);
            Test.stopTest();
        }

    }
    
    @isTest
	public static void updateTaskTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuario) {
        Test.startTest();
            Task tarea = [select id, Description from Task where subject = 'Llamada Saliente'];
            CIBE_Oportunidades_Vinculadas_Controller.updateTask(tarea.id,'comentario de prueba','open','VC');
        Test.stopTest();
        System.assert(tarea.Description != 'comentario de prueba' ); 
        }

    }
    
    @isTest
	public static void insertManagementHistoryTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
                CIBE_Oportunidades_Vinculadas_Controller.insertManagementHistory('','comentario de prueba','open','CTO');
                List<AV_ManagementHistory__c> mh = [select id, AV_Comment__c from AV_ManagementHistory__c];
            Test.stopTest();
        System.assert(mh.isEmpty() == false ); 
        }

    }

    @isTest
	public static void roleEmpTest() {
        User usuario = [SELECT Id, UserRole.DeveloperName FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
                Boolean emp = CIBE_Oportunidades_Vinculadas_Controller.roleEMP();
            Test.stopTest();
            System.assertEquals(true, emp);
        }
    }

    @isTest
	public static void roleCIBTest() {
        CIBE_TestHelper.loginUser(null, CIBE_AppConstants.CIBE_ROLECIB, null, new List<String>{
            CIBE_AppConstants.CIBE_OPERATIVACIB,
            CIBE_AppConstants.CIBE_CUSTOMMETADATA
            });
        User u1 = [SELECT Id FROM User WHERE UserRole.DeveloperName = 'CIB' AND AV_ExternalID__c = 'U0009003'  LIMIT 1];
        System.runAs(u1) {
            Test.startTest();
                Boolean cib = CIBE_Oportunidades_Vinculadas_Controller.roleCIB();
            Test.stopTest();
            System.assertEquals(true, cib);
        }
    }

    @isTest
	public static void roleCIBEMPTest() {
        CIBE_TestHelper.loginUser(null, CIBE_AppConstants.CIBE_CIBEMPRESAS, null, new List<String>{
            CIBE_AppConstants.CIBE_OPERATIVACIB,
            CIBE_AppConstants.CIBE_CUSTOMMETADATA
            });
        User u1 = [SELECT Id FROM User WHERE UserRole.DeveloperName = 'CIBE_CIBEmpresas' AND AV_ExternalID__c = 'U0009003'  LIMIT 1];
        System.runAs(u1) {
            Test.startTest();
                Boolean cib = CIBE_Oportunidades_Vinculadas_Controller.roleCIB2();
            Test.stopTest();
            System.assertEquals(true, cib);
        }
    }


    @isTest
	public static void getActionsTest() {
        Map<String,CIBE_FlowActions__mdt> flowM = CIBE_FlowActions__mdt.getAll();
        List<CIBE_Oportunidades_Vinculadas_Controller.Action> actionf = new List<CIBE_Oportunidades_Vinculadas_Controller.Action>();
        User usuario = [SELECT Id, UserRole.DeveloperName FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];

        System.runAs(usuario) {
            Test.startTest();   
                actionf = CIBE_Oportunidades_Vinculadas_Controller.getActions('CIBE_AltaDeEvento');
            Test.stopTest();
        }
        System.assertEquals(actionf.size()>0,true); 
    }
    
    
    @isTest
    public static void getOppTeamMemberTest(){
        Boolean result; 
        List<Opportunity> oppList = [SELECT ID, Ownerid FROM Opportunity limit 1];
        User usuario = [SELECT Id, UserRole.DeveloperName FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();   
                result = CIBE_Oportunidades_Vinculadas_Controller.getOppTeamMember(oppList[0].Id, oppList[0].ownerId);
            Test.stopTest();
        }
        System.assertEquals(result,false); 
    }
    
    
    @isTest
    public static void getTaskFieldsTest(){
        Test.startTest();
    	Task result;
		Task tsk = [Select id from Task limit 1]; 
        User usuario = [SELECT Id, UserRole.DeveloperName FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuario) {
            result = CIBE_Oportunidades_Vinculadas_Controller.getTaskFields(tsk.Id);
        }
        Test.stopTest();
        System.assertNotEquals(result, null);    
    }
    
    @isTest
    public static void getTaskRecordTypeTest(){
        Test.startTest();
    	String result;
		Task tsk = [Select id from Task limit 1]; 
        User usuario = [SELECT Id, UserRole.DeveloperName FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        System.runAs(usuario) {
            result = CIBE_Oportunidades_Vinculadas_Controller.getTaskRecordTypeName(tsk.Id);
        }
        Test.stopTest();
        System.assertNotEquals(result, null);    
    }
    
    
    @isTest
    public static void testOpportunityWrapper(){
        Test.startTest();
        CIBE_Oportunidades_Vinculadas_Controller.OpportunityWrapper wrap = new CIBE_Oportunidades_Vinculadas_Controller.OpportunityWrapper();
        List<Opportunity> oppListBefore = [Select id, LastModifieddate FROM Opportunity WHERE Name = 'Alerta Comercial'];
        wrap.id = oppListBefore[0].Id;
        wrap.cerradonegativo = 'Anulada' ;
        wrap.status = 'Cerrado Negativo';
        wrap.exito = 'Alta';
        wrap.amount = 121212;
        wrap.closedate = System.today();
        wrap.lastcoment = 'Last comment';
        
        User usuario = [SELECT Id, UserRole.DeveloperName FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
       
        System.runAs(usuario) {
            CIBE_Oportunidades_Vinculadas_Controller.updateOpportunity(wrap);
            List<Opportunity> oppListAfter = [Select id, LastModifieddate FROM Opportunity WHERE Name = 'Alerta Comercial'];
        	System.assertNotEquals(oppListBefore[0].LastModifieddate, oppListAfter[0].LastModifieddate);
        }
        Test.stopTest();
        
    }
    
}