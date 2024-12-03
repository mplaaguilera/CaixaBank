/**********************************************************************************************************************
Name:	  AV_GestorReassignmentFuture_Test
Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_GestorReassignmentFuture"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY	   	AUTHOR		   		DATE			Description
    1.0			Test Class	   	Víctor Santiago	   	03/02/2021		Init version
    1.1			Test Class	   	Víctor Santiago	   	08/02/2021		Redone
    1.2			Test Class	   	Víctor Santiago	   	19/03/2021		Redone
	1.3			DE46491/DE46686	Sandra Gómez		03/06/2021		add method processRelatedToAccountOKSinEap
	1.4			FIX				Sandra Gómez		27/08/2021		Fix product opportunity
	1.5			DE52465			Daniel Rodríguez	20/10/2021		Fix method processRelatedToAccount
    1.6		    AV_Query IT	    Daniel Rodríguez	04/02/2022	    Change AV_Query to SOQL for User, Account, Contact
    1.7         Fix             Patricia Villacañas 17/05/2023      Modified to set run as

***********************************************************************************************************************/
@isTest
public class AV_GestorReassignmentFuture_Test {
    static String taskExternalId = '12345';
    static String taskExternalId2 = '12346';
    static String oppExternalId = '00000002';
    
    @TestSetup
	static void setup() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

        System.runAs(userGcf){
           
           AV_LimitBook__c cs = new AV_LimitBook__c();
           cs.AV_Limit__c= 150;
           cs.AV_LimitReassignment__c = 100;
     	   insert cs;
        
           AV_TestHelper.activateLogger();
           Account centroCaixa = AV_TestHelper.createCaixaCenter();
        
           List<User>userList=new List<User>();
           List<Contact>contactList=new List<Contact>();
        
        
		   User usrTest = AV_TestHelper.createUserSinInsert(null,null);
           User usrTest2 = AV_TestHelper.createUserSinInsert(null,null);
           userList.add(usrTest);
           userList.add(usrTest2);
           insert userList;
        
           // Empleado gestor 1  
		   Contact gestor1 = AV_TestHelper.createEmployeeSinInsert(centroCaixa, usrTest);
           gestor1.CC_Matricula__c = 'U01XYZ01';
           contactList.add(gestor1);

        
           // Empleado gestor 2 
		   Contact gestor2 = AV_TestHelper.createEmployeeSinInsert(centroCaixa, usrTest2);
           gestor2.CC_Matricula__c = 'U01XYZ02';
           contactList.add(gestor2);
           upsert contactList;
        
           // Cuenta cliente con empleado gestor 1 asignado
           Account accTest = AV_TestHelper.createCustomerWithEAPGestor(gestor1);
        
                
           // Task Open & Task Pendiente no localizado con gestor 1 y cuenta cliente asignados
           List<Task> taskList =new List<Task>();
           Task tskTest = AV_TestHelper.createTareaExternalIdWithCustomerSinInsert(usrTest, taskExternalId, accTest);
           Task tskTestPNL = AV_TestHelper.createTareaExternalIdCustomStatusWithCustomerSinInsert(usrTest, taskExternalId2, accTest, AV_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL);
        
           taskList.add(tskTest);
           taskList.add(tskTestPNL);
           insert taskList;
        
           // Event con gestor 1 y cuenta cliente asignados
           List<Event> eventList =new List<Event>();
           Event eventTest = AV_TestHelper.createEventConClienteEAPGestorSinInsert(usrTest, System.now().addMinutes(60), accTest, gestor1.CC_Matricula__c);
           // Event eventTest = AV_TestHelper.createEventConClienteEAPGestor(usrTest, System.now()-14, accTest, gestor1.CC_Matricula__c);
           Event eventTest2 = AV_TestHelper.createEventConClienteEAPGestorSinInsert(usrTest, System.now().addMinutes(60), accTest, gestor1.CC_Matricula__c);
           // Event eventTest2 = AV_TestHelper.createEventConClienteEAPGestor(usrTest, System.now()-14, accTest, gestor1.CC_Matricula__c);
           eventList.add(eventTest);
           eventList.add(eventTest2);
           insert eventList;
        
           AV_TestHelper.createPricebook2();
        }
        
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_CAMBIOEMPLEADO','OK'));
    }
    
    @isTest
    private static void processRelatedToAccountOK() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_MOCNT', 'OK'));
		String oppExternalId = '00000002';
        Set<Id> gestorId = new Set<Id>();
        Set<Id> gestorId2 = new Set<Id>();
        List<Opportunity> listOppTest = new List<Opportunity>();
        
        Test.startTest();
        List<Contact> gestores= [Select Id, CC_Matricula__c,AV_UsuarioAsociado__c, AV_UsuarioAsociado__r.IsActive From Contact Where CC_Matricula__c = 'U01XYZ01'];
        List<Contact> gestores2= [Select Id, CC_Matricula__c, AV_UsuarioAsociado__c,AV_UsuarioAsociado__r.IsActive From Contact Where CC_Matricula__c = 'U01XYZ02'];
        User employe = [SELECT ID FROM USER WHERE ID = :gestores[0].AV_UsuarioAsociado__c LIMIT 1];

        List<Account> customers= [Select Id, Name, AV_NumPerso__c, AV_EAPGestor__c From Account Where AV_NumPerso__c != null limit 1]; 
        Opportunity oppTest = AV_TestHelper.createOpportunityWithEmpleado(customers.get(0), gestores2.get(0));

        System.runAs(userGcf){
            gestorId.add(gestores.get(0).Id);
            gestorId2.add(gestores2.get(0).Id);
            List<Account> customers2= [Select Id, Name, AV_NumPerso__c, AV_EAPGestor__c From Account Where AV_NumPerso__c != null limit 1];     
            AV_GestorReassignmentQueueable.doChainJob = false;

            String gstrId = gestores2.get(0).Id;
            Event evtTst = AV_TestHelper.createEventConClienteEAPGestor(employe,System.now()+10,customers.get(0),gstrId);
            listOppTest.add(oppTest);
            customers.get(0).AV_EAPGestor__c = gestores2.get(0).Id;
            AV_GestorReassignmentFuture.processRelatedToAccount(JSON.serialize(customers), gestorId2, JSON.serialize(customers2), gestorId, true );
            customers.get(0).AV_EAPGestor__c = null;
            evtTst.AV_CodigoGestorAsignado__c = gestores.get(0).CC_Matricula__c;
            Database.update(evtTst);
            AV_GestorReassignmentFuture.processRelatedToAccount(JSON.serialize(customers), gestorId2, JSON.serialize(customers2), gestorId, true );
        }
        Test.stopTest();

        List<Task> tareas = [SELECT AV_CodigoGestorAsignado__c FROM Task WHERE (AV_ExternalID__c = '12345' OR AV_ExternalID__c = '12346')];

        List<Opportunity> oportunidades = [SELECT AV_ExternalID__c,AV_Gestor__c FROM Opportunity
        WHERE (AV_ExternalID__c = '00000001' OR AV_ExternalID__c = :oppExternalId)];
        
        List<Event> eventos = [SELECT AV_CodigoGestorAsignado__c FROM Event WHERE AV_CodigoGestorAsignado__c = :gestores.get(0).CC_Matricula__c ];
        // Task Status = Open    
        System.assertNotEquals(true, gestores.get(0).CC_Matricula__c == tareas.get(0).AV_CodigoGestorAsignado__c, 'Tarea no asignada a nuevo gestor.');
        // Task Status = Pendiente no localizado  
        System.assertNotEquals(true, gestores.get(0).CC_Matricula__c == tareas.get(1).AV_CodigoGestorAsignado__c, 'Tarea no asignada a nuevo gestor.');
        // Opportunity StageName = Potencial
        System.assertEquals(true, gestores2.get(0).Id == oportunidades.get(0).AV_Gestor__c, 'Oportunidad no asignada a nuevo gestor.');
        // CSBD_Evento_Estado__c = Pendiente
        System.assertEquals(false, eventos.isEmpty(), 'Evento no asignado a nuevo gestor.');
    }
    
    @isTest
    private static void processRelatedToAccountOKSinEap() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Test.startTest();
        
        List<Contact> gestores= [Select Id, CC_Matricula__c, AV_UsuarioAsociado__r.IsActive From Contact Where CC_Matricula__c = 'U01XYZ01' or CC_Matricula__c = 'U01XYZ02'];
        List<Account> customers= [Select Id, AV_EAPGestor__c From Account Where AV_EAPGestor__c = null limit 1]; 

        System.runAs(userGcf){
            Opportunity oppTest = AV_TestHelper.createOpportunityWithEmpleado(customers.get(0), gestores.get(0));
            customers[0].AV_EAPGestor__c=null;
            update customers;
        }
		Test.stopTest();
        System.assertEquals(null, customers.get(0).AV_EAPGestor__c);
    }
}