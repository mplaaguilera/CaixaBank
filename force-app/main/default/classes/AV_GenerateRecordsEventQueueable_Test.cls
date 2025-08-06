/**********************************************************************************************************************
Name: AV_GenerateRecordsEventQueueable_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase AV_GenerateRecordsEventQueueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION        USER_STORY		AUTHOR              DATE                Description
	1.0            US466765         Patricia Solano     07/12/2022          Init version

***********************************************************************************************************************/
@isTest
public with sharing class AV_GenerateRecordsEventQueueable_Test {
    @TestSetup
    static void setup(){
        AV_TestHelper.activateLogger();
        Account centroCaixa = AV_TestHelper.createCaixaCenter();
        Account accTest = AV_TestHelper.createCustomer();
		User user = AV_TestHelper.createUser(null);
		Contact employee = AV_TestHelper.createEmployee(centroCaixa, user);
        Account client = AV_TestHelper.createCustomerWithNumperson('000000001');
        AV_TestHelper.createPricebook2();
    }

    @isTest
    public static void generateRecordsEventQueueableTest() {
        Test.startTest();  
        User user = [SELECT ID FROM USER WHERE ID IN (SELECT AV_UsuarioAsociado__c FROM Contact) LIMIT 1];
        String externalId = 'Task-#681735';
        Account client = [SELECT ID FROM ACCOUNT WHERE AV_Numperso__c = '000000001' LIMIT 1];
        Contact employee = [SELECT ID FROM CONTACT WHERE AV_UsuarioAsociado__c = :user.Id LIMIT 1];
        Opportunity opp1 = AV_TestHelper.createOpportunityIniciativaWithProduct(client, employee, '99999', AV_TestHelper.createProduct2(null,'9999'));
        Opportunity opp2 = AV_TestHelper.createOpportunityIniciativaWithProduct(client, employee, '88888', AV_TestHelper.createProduct2(null,'99999'));
        List<Opportunity> listOppos = new List<Opportunity>{opp1,opp2};
        insert listOppos;
        Event event1 = AV_TestHelper.createEvent(user,System.today(),client);
  
        List<Event> listInsert = [SELECT Id FROM Event LIMIT 10];
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        System.enqueueJob(new AV_GenerateRecordsEventQueueable(listInsert,new List<AV_CustomActivityOpportunity__c>(),false));
        Test.stopTest();
        List<Event> listEvent = [SELECT Id FROM Event LIMIT 10];
        system.assert(!listEvent.isEmpty());
    }

    @isTest
    public static void generateRecordsEventQueueableOppTest() {
        Test.startTest();  
        User user = [SELECT ID FROM USER WHERE ID IN (SELECT AV_UsuarioAsociado__c FROM Contact) LIMIT 1];
        String externalId = 'Task-#681735';
        Account client = [SELECT ID FROM ACCOUNT WHERE AV_Numperso__c = '000000001' LIMIT 1];
        Contact employee = [SELECT ID FROM CONTACT WHERE AV_UsuarioAsociado__c = :user.Id LIMIT 1];
        Opportunity opp1 = AV_TestHelper.createOpportunityIniciativaWithProduct(client, employee, '99999', AV_TestHelper.createProduct2(null,'9999'));
        Opportunity opp2 = AV_TestHelper.createOpportunityIniciativaWithProduct(client, employee, '88888', AV_TestHelper.createProduct2(null,'99999'));
        List<Opportunity> listOppos = new List<Opportunity>{opp1,opp2};
        insert listOppos;
        Event event1 = AV_TestHelper.createEvent(user,System.today(),client);
  
        List<Event> listInsert = [SELECT Id FROM Event LIMIT 10];
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        System.enqueueJob(new AV_GenerateRecordsEventQueueable(listInsert,new List<AV_CustomActivityOpportunity__c>(),true));
        Test.stopTest();
        List<Event> listEvent = [SELECT Id FROM Event LIMIT 10];
        system.assert(!listEvent.isEmpty());
    }
}