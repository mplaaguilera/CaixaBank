/**********************************************************************************************************************
 Name:	  AV_DeleteAccountTeamMemberBatch_Test
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para eliminar AccountTeamMembers.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Daniel Rodriguez	02/12/2021			Test version
	1.1			Fix Confidencial	Carolina Alonso	26/09/2022			Add condition to check that the record is from MC's proyect (AV_Tipo__c = 'MC')

***********************************************************************************************************************/
@isTest
public class AV_DeleteAccountTeamMemberBatch_Test {

	/**
	 * Create Data to test.
	 */
	@TestSetup
	static void setup() {
		Account centroCaixa = AV_TestHelper.createCaixaCenter();

		Account cliente = AV_TestHelper.createCustomer();
		cliente.AV_Confidencial__c = true;
		update cliente;
        String matriculaSample = 'U0009003';
        String labelProfile = 'Standard User';
        List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'' + labelProfile + '\' LIMIT 1');
        Profile p = (Profile)result.get(0);
        User u1 = new User(
            Alias = 'tsAlias',
            Email = 'testdevdev@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            ProfileId = p.Id,
            UserName = 'testdevdev@test.com.dev',
            AV_ExternalID__c = matriculaSample
        );
        insert u1;
  
        
        AccountTeamMember accTM = new AccountTeamMember();
        accTM.UserId = u1.id;
        accTM.accountId = cliente.id;
        accTM.AccountAccessLevel = 'Read';
        accTM.OpportunityAccessLevel = 'Read';
        accTM.CaseAccessLevel = 'Read';
        accTM.ContactAccessLevel = 'Read';
		accTM.AV_Tipo__c = 'MC';
        insert accTM;
	}
	/**
	 * Execute the Batch class (AV_DeleteAccountTeamMemberBatch) 
	 */
	@isTest
	static void executeConfidentialBatch() {
    
		Test.startTest();	
		
		String nameBatch = 'AV_DeleteAccountTeamMemberBatch';
		AV_SchedulerBatches.activate(nameBatch);
		System.assertEquals(1, [select count() from CronTrigger WHERE CronJobDetail.Name = :nameBatch]);
		CronTrigger ct = [SELECT State FROM CronTrigger WHERE CronJobDetail.Name = :nameBatch ];
		System.assertEquals('WAITING', ct.State);
		AV_LogDebug.printLogDebug('executeBatchDeleteRecord', 'CT: ' + ct);

		Test.stopTest();
	}
}