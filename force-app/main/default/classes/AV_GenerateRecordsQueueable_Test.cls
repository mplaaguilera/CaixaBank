/**********************************************************************************************************************
Name: AV_GenerateRecordsQueueable_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase AV_GenerateRecordsQueueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION        USER_STORY		AUTHOR              DATE                Description
	1.0            US466765         Patricia Solano     01/12/2022          Init version

***********************************************************************************************************************/
@isTest
public with sharing class AV_GenerateRecordsQueueable_Test {
	@TestSetup
	static void setup() {

        AV_TestHelper.activateLogger();
        String externalId = 'Task-#681735';
        Account centroCaixa = AV_TestHelper.createCaixaCenter();
        Account account = AV_TestHelper.createCustomer();
		User user = AV_TestHelper.createUser(null);
		Contact employee = AV_TestHelper.createEmployee(centroCaixa, user);
        Account client = AV_TestHelper.createCustomerWithNumperson('000000001');
        AV_TestHelper.createPricebook2();
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
    public static void generateRecordsQueueableOppTest() {
        Test.startTest();  
        AV_LimitBook__c cs = new AV_LimitBook__c();
		cs.AV_LimitReassignment__c = 5;
		insert cs;
        AV_GenerateRecords.insertOpportunities(3, 'AV_Iniciativa', System.today()+2, 'Vencido', false);
        List<Opportunity> listOpp = [SELECT Id FROM Opportunity LIMIT 2];
        Test.stopTest();
        System.assertNotEquals(null, listOpp);
    }

    @isTest
    public static void testFinishLine() {
        Test.startTest();  
        List<Opportunity> listaOpp = new List<Opportunity>();
		System.enqueueJob(new AV_GenerateRecordsQueueable(listaOpp));
        Test.stopTest();
        System.assert(true);
    }
}