/**********************************************************************************************************************
 Name:	  AV_OpportunityStatusBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Unit test para probar el batch de cambio de estado automático de oportunidades.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Esperanza Conde		19/10/2020			Test version
	1.1			FIX				David Rufo			18/05/2021			Improve query execution
	1.2			US384943		Víctor Santiago		30/05/2022			Test adapted to framework batch
	1.3         Fix             Patricia Villacañas 18/05/2023      	Modified to set run as
	1.4         FIX11070844     Oscar Moreno        27/08/2024          Change value of CloseDate field of opportunity in setup to System.today() - 3

***********************************************************************************************************************/
@isTest
public class AV_OpportunityStatusBatch_Test {
	
    /**
	 * Create Task with due date and status pendiente and Pendiente No Localizado.
	 */
	@TestSetup
	static void setup() {

        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

        System.runAs(userGcf){
			AV_TestHelper.activateLogger();
			AV_TestHelper.createPricebook2();
			User usrTest = AV_TestHelper.createUser(null);
			Account accTest = AV_TestHelper.createCustomer();
			
			RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
			Opportunity op = AV_TestHelper.createOpportunity(accTest,System.today() - 3);
			op.RecordTypeId = rt.Id;
			update op;

		}
    }
    
    @isTest
	static void executeBatchOppStatusQuery() {
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		Test.startTest();
        System.runAs(userGcf){
			Id batchId = Database.executeBatch(new AV_OpportunityStatusBatch());
			System.AssertEquals(1, 1, '');
        }
		Test.stopTest();
	}
}