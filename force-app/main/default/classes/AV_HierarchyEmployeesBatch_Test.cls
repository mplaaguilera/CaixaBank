/**********************************************************************************************************************
 Name:	  AV_HierarchyEmployeesBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch de actualización de Supervisores de Contactos
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Carolina Alonso		05/05/2020			Test version

***********************************************************************************************************************/
@isTest
public class AV_HierarchyEmployeesBatch_Test {

	/**
	 * Create Contact without an associated Supervisor.
	 */
	@TestSetup
	static void setup() {
		Account centroCaixa = AV_TestHelper.createCaixaCenter();
		Contact supervisor  = AV_TestHelper.createEmployee(centroCaixa, null);
		centroCaixa.AV_MatriculaResponsable1__c = supervisor.Id;
		update centroCaixa;
		Contact empleado  = AV_TestHelper.createEmployee(centroCaixa, null);
	}

	/**
	 * Execute the Batch class (AV_HierarchyEmployees) 
	 */
	@isTest
	static void executeBatchHierarchyEmployees() {
		Test.startTest();

		String nameBatch = 'AV_HierarchyEmployees';
		AV_SchedulerBatches.activate(nameBatch);
		System.assertEquals(1, [select count() from CronTrigger WHERE CronJobDetail.Name = :nameBatch]);
		
		Test.stopTest();
	}
}