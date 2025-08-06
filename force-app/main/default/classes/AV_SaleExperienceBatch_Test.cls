/**********************************************************************************************************************
 Name:	  AV_SaleExperienceBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para actualizar Ventas.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Carolina Alonso		04/05/2020			Test version
	1.1			App FSC			David Rufo			24/08/2020			Update treat business client like BPA for: 
																		empty cases + others differents than BPA, BPE, NEG

***********************************************************************************************************************/
@isTest
public class AV_SaleExperienceBatch_Test {
	
	/**
	 * Create Venta without productexperience associated.
	 */
	@TestSetup
	static void setup() {
		AV_ProductExperience__c prodExp = AV_TestHelper.createPFExperience();
		Account customerBPA = AV_TestHelper.createCustomer();
        Account customerNoBusiness = AV_TestHelper.createCustomerWithBusiness(null);
        Account customerMIC = AV_TestHelper.createCustomerWithBusiness('MIC');
		Product2 prodPF = AV_TestHelper.createProduct(null,null);
		Product2 prodN20 = AV_TestHelper.createProduct(prodPF,'20');
		Product2 prodN10 = AV_TestHelper.createProduct(prodN20,'10');
        Product2 prodN1 = AV_TestHelper.createProduct(prodN10,'1');
		AV_Sales__c venta1 = AV_TestHelper.createSales(customerBPA, prodN10);
        AV_Sales__c venta2 = AV_TestHelper.createSales(customerNoBusiness, prodN10);
        AV_Sales__c venta3 = AV_TestHelper.createSales(customerMIC, prodN1);
	}

	/**
	 * Execute the Batch class (AV_SaleExperienceBatch) 
	 */
	@isTest
	static void executeBatchSaleExperience() {
		Test.startTest();

		String nameBatch = 'AV_SaleExperience';
		AV_SchedulerBatches.activate(nameBatch);
		System.assertEquals(1, [select count() from CronTrigger WHERE CronJobDetail.Name = :nameBatch]);
		CronTrigger ct = [SELECT State FROM CronTrigger WHERE CronJobDetail.Name = :nameBatch ];
		System.assertEquals('WAITING', ct.State);
		AV_LogDebug.printLogDebug('executeBatchDeleteRecord', 'CT: ' + ct);

		Test.stopTest();
	}


	/**
	 * Execute the Batch class (AV_SaleExperienceBatch) 
	 */
	@isTest
	static void executeBatchSaleExperienceCatch() {
		Test.startTest();

		String nameBatch = 'AV_SaleExperience';
		AV_SchedulerBatches.activate(nameBatch);
		System.assertEquals(1, [select count() from CronTrigger WHERE CronJobDetail.Name = :nameBatch]);
		CronTrigger ct = [SELECT State FROM CronTrigger WHERE CronJobDetail.Name = :nameBatch ];
		
		Test.stopTest();
		
	}
}