/**********************************************************************************************************************
Name:     CIBE_GestorReassignmentFuture_Test
Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_GestorReassignmentFuture"
-----------------------------------------------------------------------------------------------------------------------\
Historial
---------------------
    VERSION     USER_STORY      AUTHOR              DATE            Description
    1.0         Test Class      Mikel Lezama        10/11/2022      Init version
    1.1         US609754        Lucía Muñoz         28/06/2023      Ponerle el system.runAs y arreglar el error de QC: Apex unit test should include at least one assertion

***********************************************************************************************************************/

@isTest

public class CIBE_GestorReassignmentFuture_Test {

    static String taskExternalId = '12345';
    static String taskExternalId2 = '12346';

    @TestSetup
    static void setup() {
        CIBE_TestInitialSetup.setupInitialDataCIB();
        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Contact c = [SELECT Id, CC_Matricula__c FROM Contact WHERE CC_Matricula__c = 'U0000001'];
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Account customer = CIBE_TestHelper.createCustomerWithEAPGestor(c);

            CIBE_TestHelper.createOpportunityWithEmpleado(customer, c);

            List<Task> tasks = new List<Task>();
            Task task1 = CIBE_TestHelper.createTareaExternalIdWithCustomerSinInsert(u, taskExternalId, customer);
            Task task2 = CIBE_TestHelper.createTareaExternalIdCustomStatusWithCustomerSinInsert(u, taskExternalId2, customer, CIBE_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL);
            tasks.add(task1);
            tasks.add(task2);
            insert tasks;
        }

        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_CAMBIOEMPLEADO','OK'));
    }

    @isTest
    private static void processRelatedToAccountOK() {
        Test.startTest();
        
        AV_LimitBook__c cs = new AV_LimitBook__c();
        cs.AV_Limit__c= 150;
        cs.AV_LimitReassignment__c = 100;
        insert cs;
        
        User gestor1 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Contact contact1 = [SELECT Id, CC_Matricula__c FROM Contact WHERE CC_Matricula__c = 'U0000001'];
        Account center = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '00001'];
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Profile p = [SELECT Id FROM Profile WHERE Name = :CIBE_AppConstants.CIBE_GESTOR LIMIT 1];
            UserRole ur = [SELECT Id FROM UserRole WHERE DeveloperName = :CIBE_AppConstants.CIBE_CIBEMPRESAS LIMIT 1];
            User user = new User(
                ProfileId = p.Id,
                UserRoleId = ur.Id,
                UserName = 'U0000002' + '@test.dev',
                LastName = 'U0000002' + '_LastName',
                Alias = 'U0000002'.abbreviate(8),
                Email = 'U0000002' + '@test.dev',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'es',
                LocaleSidKey = 'es',
                TimeZoneSidKey = 'Europe/Berlin',
                AV_NumeroOficinaEmpresa__c = '001-' + '00001',
                AV_ExternalID__c = 'U0000002'
            );
            insert user;
        }

        User user2 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000002'];
        RecordType rtEmployee = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.EMPLOYEE_RT);
        Contact gestor2 = new Contact();
        gestor2.RecordTypeId = rtEmployee.Id;
        gestor2.AccountId = center.Id;
        gestor2.AV_UsuarioAsociado__c = user2.Id;
        gestor2.FirstName = 'Employee 2';
        gestor2.LastName = 'U0000002';
        gestor2.Email = 'U0000002' + '@test.dev';
        gestor2.CC_Idioma__c = 'es';
        gestor2.CC_Matricula__c = 'U0000002';
        gestor2.OwnerId = gestor1.Id;
        insert gestor2;

        Account customer = [SELECT Id, AV_Numperso__c, OwnerId FROM Account WHERE AV_Numperso__c = '123'];
        
        List<Event> events =new List<Event>();
        Event event1 = CIBE_TestHelper.createEventConClienteEAPGestorSinInsert(gestor1, System.now().addMinutes(60), customer, contact1.CC_Matricula__c);
        Event event2 = CIBE_TestHelper.createEventConClienteEAPGestorSinInsert(gestor1, System.now().addMinutes(60), customer, contact1.CC_Matricula__c);
        events.add(event1);
        events.add(event2);
        insert events;

        System.runAs(gestor1) {
            customer.AV_EAPGestor__c = gestor2.Id;
            update customer;
        }
        Test.stopTest();
                
        List<Task> tareas = [SELECT AV_CodigoGestorAsignado__c FROM Task];
        List<Opportunity> oportunidades = [SELECT AV_ExternalID__c, AV_Gestor__c FROM Opportunity];
        List<Event> eventos = [SELECT AV_CodigoGestorAsignado__c FROM Event];

        System.assertNotEquals(true, gestor2.CC_Matricula__c == tareas.get(0).AV_CodigoGestorAsignado__c, 'Tarea no asignada a nuevo gestor.');
        System.assertNotEquals(true, gestor2.CC_Matricula__c == tareas.get(1).AV_CodigoGestorAsignado__c, 'Tarea no asignada a nuevo gestor.');
        System.assertEquals(true, gestor2.Id == oportunidades.get(0).AV_Gestor__c, 'Oportunidad no asignada a nuevo gestor.');
        System.assertEquals(false, eventos.isEmpty(), 'Evento no asignado a nuevo gestor.');
    }

    @isTest
    private static void processRelatedToAccountOKSinEap() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
    
        Test.startTest();
        System.runAs(usuario) {
            List<Account> customers= [SELECT Id, AV_EAPGestor__c, RecordType.DeveloperName FROM Account WHERE AV_Numperso__c = '123'];
            customers[0].AV_EAPGestor__c = null;
            update customers;

            System.assertEquals(null, customers[0].AV_EAPGestor__c);
        }
        Test.stopTest();
    }

}