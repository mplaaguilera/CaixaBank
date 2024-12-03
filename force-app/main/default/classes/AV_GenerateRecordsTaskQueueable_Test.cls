/**********************************************************************************************************************
Name: AV_GenerateRecordsTaskQueueable_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase AV_GenerateRecordsTaskQueueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION        USER_STORY		AUTHOR              DATE                Description
	1.0            US466765         Patricia Solano     07/12/2022          Init version

***********************************************************************************************************************/
@isTest
public with sharing class AV_GenerateRecordsTaskQueueable_Test {
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
    public static void generateRecordsTaskQueueableOppTest() {
        Test.startTest();  
        User user = [SELECT ID FROM USER WHERE ID IN (SELECT AV_UsuarioAsociado__c FROM Contact) LIMIT 1];
        String externalId = 'Task-#681735';
        Account client = [SELECT ID FROM ACCOUNT WHERE AV_Numperso__c = '000000001' LIMIT 1];
        Task task = AV_TestHelper.createTareaExternalIdWithCustomer(user, externalId, client);
        Contact employee = [SELECT ID FROM CONTACT WHERE AV_UsuarioAsociado__c = :user.Id LIMIT 1];
        Opportunity opp1 = AV_TestHelper.createOpportunityIniciativaWithProduct(client, employee, '99999', AV_TestHelper.createProduct2(null,'9999'));
        Opportunity opp2 = AV_TestHelper.createOpportunityIniciativaWithProduct(client, employee, '88888', AV_TestHelper.createProduct2(null,'99999'));
        List<Opportunity> listOppos = new List<Opportunity>{opp1,opp2};
        insert listOppos;
        List<Task> listInsert = [SELECT ID FROM TASK ];
        System.enqueueJob(new AV_GenerateRecordsTaskQueueable(listInsert,new List<AV_CustomActivityOpportunity__c>(),new List<AV_ManagementHistory__c>(),true,true));
        Test.stopTest();
        List<Task> listTask = [SELECT Id FROM Task LIMIT 10];
        system.assert(!listTask.isEmpty());
    }

    @isTest
    public static void generateRecordsTaskQueueableTest() {
        Test.startTest();  
        User user = [SELECT ID FROM USER WHERE ID IN (SELECT AV_UsuarioAsociado__c FROM Contact) LIMIT 1];
        String externalId = 'Task-#681735';
        Account client = [SELECT ID FROM ACCOUNT WHERE AV_Numperso__c = '000000001' LIMIT 1];
        Task task = AV_TestHelper.createTareaExternalIdWithCustomer(user, externalId, client);
        Contact employee = [SELECT ID FROM CONTACT WHERE AV_UsuarioAsociado__c = :user.Id LIMIT 1];
        Opportunity opp1 = AV_TestHelper.createOpportunityIniciativaWithProduct(client, employee, '99999', AV_TestHelper.createProduct2(null,'9999'));
        Opportunity opp2 = AV_TestHelper.createOpportunityIniciativaWithProduct(client, employee, '88888', AV_TestHelper.createProduct2(null,'99999'));
        List<Opportunity> listOppos = new List<Opportunity>{opp1,opp2};
        insert listOppos;
        List<Task> listInsert = [SELECT ID FROM TASK ];
        System.enqueueJob(new AV_GenerateRecordsTaskQueueable(listInsert,new List<AV_CustomActivityOpportunity__c>(),new List<AV_ManagementHistory__c>(),false,true));
        Test.stopTest();
        List<Task> listTask = [SELECT Id FROM Task LIMIT 10];
        system.assert(!listTask.isEmpty());
    }
}