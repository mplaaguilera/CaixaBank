/**********************************************************************************************************************
Name:	  AV_MassCreateData_Test
Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Propósito: Test para dar cobertura a AV_MassCreateData
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY	   AUTHOR		   		DATE			Description
    1.0			Test Class	   Víctor Santiago 	    18/06/2021		Init version
	1.1			FIX			   Sandra Gómez			26/08/2021		Fix product opportunity
***********************************************************************************************************************/
@isTest
public with sharing class AV_MassCreateData_Test {

    public static Integer queryNumber = 20;
    public static String externalId = 'Task-#681735';

    @TestSetup
    static void setup() {
        Account centroCaixa = AV_TestHelper.createCaixaCenter();
		User usrTest = AV_TestHelper.createUser(null);
		Contact emp = AV_TestHelper.createEmployee(centroCaixa, usrTest);
        Account cli = AV_TestHelper.createCustomer();
        cli.AV_NumPerso__c = '00000001';
        Database.update(cli);
        AV_TestHelper.createPricebook2();
        Task t = AV_TestHelper.createTareaExternalIdWithCustomer(usrTest, externalId, cli);
        t.Subject = 'Task Iniciativa Gestor/a 1';
        Database.update(t);
        Opportunity o = AV_TestHelper.createOpportunity(cli);
        o.Name = 'Opportunity Alerta Comercial 1';
        Database.update(o);
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
    }

    // @isTest
    // public static void testGenerateData() {
    //     AV_MassCreateData.queryNUMBER = queryNumber;
    //     Test.startTest();
    //     AV_MassCreateData.generateData(queryNumber);
    //     Test.stopTest();
    // }

    @isTest
    public static void testGenerateTasks() {
        AV_MassCreateData.queryNUMBER = queryNumber;
        Test.startTest();
        AV_MassCreateData.generateData(queryNumber);
        AV_MassCreateData.generateTasks(queryNumber);
        Test.stopTest();
        List<Task> retrieveTasks = [SELECT ID FROM TASK LIMIT 10];
        System.assert(!retrieveTasks.isEmpty(),'NOK');
    }

    @isTest
    public static void testGenerateOpps() {
        AV_MassCreateData.queryNUMBER = queryNumber;
        Test.startTest();
        AV_MassCreateData.generateData(queryNumber);
        AV_MassCreateData.generateOpps(queryNumber);
        Test.stopTest();
        List<Opportunity> retrieveOppos = [SELECT ID FROM Opportunity LIMIT 10];
        System.assert(!retrieveOppos.isEmpty(),'NOK');

    }

    @isTest
    public static void testGenerateEvents() {
        AV_MassCreateData.queryNUMBER = queryNumber;
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        Test.startTest();
        AV_MassCreateData.generateData(queryNumber);
        AV_MassCreateData.generateEvents(queryNumber);
        Test.stopTest();
        List<Event> retrieveEvents = [SELECT ID FROM EVENT LIMIT 10];
        System.assert(!retrieveEvents.isEmpty(),'NOK');
    }

    @isTest
    public static void testGenerateLinkOppsToTasks() {
        AV_MassCreateData.queryNUMBER = queryNumber;
        Test.startTest();
        AV_MassCreateData.generateLinkOppsToTasks(queryNumber);
        Test.stopTest();
        List<AV_CustomActivityOpportunity__c> retrieveTaskOpp = [SELECT ID FROM AV_CustomActivityOpportunity__c LIMIT 10];
        System.assert(retrieveTaskOpp.isEmpty(),'NOK');
    }

    @isTest
    public static void testClearData() {
        AV_MassCreateData.queryNUMBER = queryNumber;
        Test.startTest();
        AV_MassCreateData.clearData();
        Test.stopTest();
        List<AV_DataAnalyticsTest__c> retrieveAll = [SELECT ID FROM AV_DataAnalyticsTest__c ];
        System.assert(retrieveAll.isEmpty(),'NOK');
    }
}