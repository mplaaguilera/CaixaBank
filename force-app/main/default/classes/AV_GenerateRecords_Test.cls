/**********************************************************************************************************************
Name:	  AV_GenerateRecords
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase AV_GenerateRecords
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY                                          AUTHOR              DATE			Description
    1.0         US466765                                            Patricia Solano     24/11/2022		Init version

***********************************************************************************************************************/
@isTest
public with sharing class AV_GenerateRecords_Test {

    @TestSetup
    static void setup(){
        AV_TestHelper.activateLogger();
        String externalId = 'Task-#681735';
        Account centroCaixa = AV_TestHelper.createCaixaCenter();
        Account account = AV_TestHelper.createCustomer();
		User user = AV_TestHelper.createUser(null);
		Contact employee = AV_TestHelper.createEmployee(centroCaixa, user);
        Account client = AV_TestHelper.createCustomerWithNumperson('000000001');
        AV_TestHelper.createPricebook2();
        Task task = AV_TestHelper.createTareaExternalIdWithCustomer(user, externalId, client);
        Opportunity opportunitty = AV_TestHelper.createOpportunityIniciativaWithEmpleadoWithoutExternalId(account, employee);
        List<Product2> products = new List<Product2>{AV_TestHelper.createProduct2(null, '12334'),
        AV_TestHelper.createProduct2(null, '123345'),
        AV_TestHelper.createProduct2(null, '1233456'),
        AV_TestHelper.createProduct2(null, '12334678')};

        for(Product2 p : products){
            p.RecordTypeId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_PRODUCT,AV_AppConstants.PRODUCT_PF_RT).Id;
            p.AV_Nivel__c = null;
        }
        update products;
    }

    @isTest
    public static void insertTasksTest() {
        Test.startTest();  
        AV_GenerateRecords.insertTasks(10, 'AV_Otros', System.today(),System.today(), System.today(), 'Open', false);
        List<Task> tasks = [SELECT Id FROM Task WHERE RecordType.DeveloperName = 'AV_Otros' LIMIT 10];
        Test.stopTest();
        System.assertNotEquals(null, tasks);
    }

    @isTest
    public static void insertOpportunitiesTest() {
        Test.startTest();  
        AV_GenerateRecords.insertOpportunities(3, 'AV_Iniciativa', System.today()+2, 'Vencido', false);
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'AV_Iniciativa' LIMIT 10];
        Test.stopTest();
        System.assertNotEquals(null, opportunities);
    }

    @isTest
    public static void insertTasksLinkOppTest() {
        Test.startTest();  
        AV_GenerateRecords.insertTasks(3, 'AV_Otros', System.today(),System.today(), System.today(), null, true);
        List<Task> tasksOpps = [SELECT Id FROM Task WHERE RecordType.DeveloperName = 'AV_MorosidadNormativa' LIMIT 10];
        Test.stopTest();
        System.assertNotEquals(null, tasksOpps);
    }

    @isTest
    public static void insertEventsTest() {
        Test.startTest();  
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        AV_GenerateRecords.insertEvents(10, 'AV_EventosConCliente', System.today(), 'CTO', 'Gestionada Positiva', true);
        List<Event> events = [SELECT Id FROM Event WHERE RecordType.DeveloperName = 'AV_EventosConCliente' LIMIT 10];
        Test.stopTest();
        System.assertNotEquals(null, events);
    }

    @isTest
    public static void insertEventsGeAssestorATest() {
        Test.startTest();  
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        AV_GenerateRecords.insertEvents(10, 'AV_EventosGestorA', System.today(), 'CTO', 'Gestionada Positiva', false);
        List<Event> eventsGestor = [SELECT Id FROM Event WHERE RecordType.DeveloperName = 'AV_EventosGestorA' LIMIT 10];
        Test.stopTest();
        System.assertNotEquals(null, eventsGestor);
    }
}