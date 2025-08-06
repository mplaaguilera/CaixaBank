/**********************************************************************************************************************
 Name:	  AV_PreconcedidoBatch_Test
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase de test para AV_PreconcedidoBatch.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Carolina Alonso		30/06/2020			Test version

***********************************************************************************************************************/
@isTest
public class AV_PreconcedidoBatch_Test {

	/**
	 * Create Data to test.
	 */
	@TestSetup
	static void setup() {
		Account cliente = AV_TestHelper.createCustomer();
		Product2 prodPF = AV_TestHelper.createProduct(null,null);
		Product2 prodN20 = AV_TestHelper.createProduct(prodPF,'20');
		Product2 prodN10 = AV_TestHelper.createProduct(prodN20,'10');
		AV_ProductExperience__c prodExp = AV_TestHelper.createPFExperience();
		prodExp.AV_ProductoFicha__c = prodN10.Id;
		update prodExp;
		AV_ProductClient__c pfCliente = AV_TestHelper.createPFCliente();
		pfCliente.AV_ImportePreconcedido__c = 15000.51;
		pfCliente.AV_Cliente__c = cliente.Id;
		pfCliente.AV_ProductoFicha__c = prodExp.Id;
		update pfCliente;
	}
	/**
	 * Execute the Batch class (AV_PreconcedidoBatch) 
	 */
	@isTest
	static void executePreconcedidoBatchOnePFCliente() {
		Test.startTest();	
		

		String nameBatch = 'AV_PreconcedidoBatch';
		AV_SchedulerBatches.activate(nameBatch);
		System.assertEquals(1, [select count() from CronTrigger WHERE CronJobDetail.Name = :nameBatch]);
		CronTrigger ct = [SELECT State FROM CronTrigger WHERE CronJobDetail.Name = :nameBatch ];
		System.assertEquals('WAITING', ct.State);
		AV_LogDebug.printLogDebug('executeBatchDeleteRecord', 'CT: ' + ct);

		Test.stopTest();
	}

	/**
	 * Execute the Batch class (AV_PreconcedidoBatch) 
	 */
	@isTest
	static void executePreconcedidoBatchMorePFCliente() {
		Test.startTest();	
		Account cliente = [SELECT Id FROM Account LIMIT 1];

		AV_ProductClient__c pfCliente2 = AV_TestHelper.createPFCliente();
		pfCliente2.AV_ImportePreconcedido__c = 10000.00;
		pfCliente2.AV_Cliente__c = cliente.Id;
		update pfCliente2;

		AV_ProductClient__c pfCliente3 = AV_TestHelper.createPFCliente();
		pfCliente3.AV_ImportePreconcedido__c = 25000.00;
		pfCliente3.AV_Cliente__c = cliente.Id;
		update pfCliente3;

		String nameBatch = 'AV_PreconcedidoBatch';
		AV_SchedulerBatches.activate(nameBatch);
		System.assertEquals(1, [select count() from CronTrigger WHERE CronJobDetail.Name = :nameBatch]);
		CronTrigger ct = [SELECT State FROM CronTrigger WHERE CronJobDetail.Name = :nameBatch ];
		System.assertEquals('WAITING', ct.State);
		AV_LogDebug.printLogDebug('executeBatchDeleteRecord', 'CT: ' + ct);

		Test.stopTest();
	}

	/**
	 * Execute the Batch class (AV_PreconcedidoBatch) 
	 */
	@isTest
	static void executePFClienteOldValueSmaller() {
		Test.startTest();	
		Account cliente = [SELECT Id FROM Account LIMIT 1];

		AV_ProductClient__c pfCliente2 = AV_TestHelper.createPFCliente();
		pfCliente2.AV_ImportePreconcedido__c = 10000.00;
		pfCliente2.AV_Cliente__c = cliente.Id;
		update pfCliente2;

		AV_ProductClient__c pfCliente3 = AV_TestHelper.createPFCliente();
		pfCliente3.AV_ImportePreconcedido__c = 20000.00;
		pfCliente3.AV_Cliente__c = cliente.Id;
		update pfCliente3;

		String nameBatch = 'AV_PreconcedidoBatch';
		AV_SchedulerBatches.activate(nameBatch);
		System.assertEquals(1, [select count() from CronTrigger WHERE CronJobDetail.Name = :nameBatch]);
		CronTrigger ct = [SELECT State FROM CronTrigger WHERE CronJobDetail.Name = :nameBatch ];
		System.assertEquals('WAITING', ct.State);
		AV_LogDebug.printLogDebug('executeBatchDeleteRecord', 'CT: ' + ct);

		Test.stopTest();
	}

	/**
	 * Execute the Batch class (AV_PreconcedidoBatch) 
	 */
	@isTest
	static void executePreconcedidoBatchWithoutValues() {
		Test.startTest();	
		AV_ProductClient__c pfCliente = [SELECT Id FROM AV_ProductClient__c LIMIT 1];
		pfCliente.AV_ImportePreconcedido__c = null;
		update pfCliente;

		String nameBatch = 'AV_PreconcedidoBatch';
		AV_SchedulerBatches.activate(nameBatch);
		System.assertEquals(1, [select count() from CronTrigger WHERE CronJobDetail.Name = :nameBatch]);
		CronTrigger ct = [SELECT State FROM CronTrigger WHERE CronJobDetail.Name = :nameBatch ];
		System.assertEquals('WAITING', ct.State);
		AV_LogDebug.printLogDebug('executeBatchDeleteRecord', 'CT: ' + ct);

		Test.stopTest();
	}
}