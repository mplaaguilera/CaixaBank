/**********************************************************************************************************************
 Name:      AV_ProcessInactiveUserAccountsBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_ProcessInactiveUserAccountsBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY       AUTHOR               DATE                Description
   	1.0            App FSC         Sandra Gómez         17/12/2021          Init version
	1.1			   AV_Query IT		Daniel Rodríguez	3/02/2022			Change AV_Query to SOQL for User and Account

***********************************************************************************************************************/
@isTest
private class AV_ProcessInactiveUserAccountsBatch_Test {
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();
		User u1 = AV_TestHelper.createUser('AV_Usuario_CaixaBank', 'U01000012');
		Contact con =  AV_TestHelper.createEmployee(null,u1);
		List<Account> accounts = new List<Account>();
		RecordType rt = AV_AppUtilities.getRecordType('Account', 'CC_ClientePA');
		// Insertar 10 Cuentas 
		for (Integer i=0;i<10;i++) {
			Account acc = new Account(
					FirstName = 'FirstName',
					LastName = 'LastName' + i,
					RecordTypeId = rt.Id,
					AV_NumPerso__c = '123' + i,
					AV_Negocio__c = 'BPA',
					AV_EAPGestor__c = con.Id,
					OwnerId = u1.Id
				);
			accounts.add(acc);
		}
		insert accounts;
	}

	/**
	 * Execute the Batch class (AV_ProcessInactiveUserAccountsBatch) 
	 */
	@isTest
	static void executeProcessInactiveUserAccountsBatch() {
		User u1 = [Select Id From User Where AV_ExternalID__c = 'U01000012'];
        /*User u1 = (User)new AV_Query('User')
										.selectFields('Id')
										.addConditionEq('AV_ExternalID__c', 'U01000012')
										.fetch();*/
		Set<String> setUserIds = new Set<String>{u1.Id};
		AV_LogDebug.printLogDebug('executeProcessInactiveUserAccountsBatch', 'User1: ' + u1);
		AV_ProcessInactiveUserAccountsBatch b = new AV_ProcessInactiveUserAccountsBatch('10000', setUserIds);
        
		Test.startTest();
		User userCli = [Select Id From User Where Profile.Name = 'API Only' and Alias = 'FC-TF9' limit 1];
		/*User userCli = (User)new AV_Query('User')
										.selectFields('Id')
										.addConditionEq('Profile.Name', 'API Only')
										.addConditionLike('Username', 'cli-integration%')
										.fetch();*/
		Database.executeBatch(b);
		Test.stopTest();
		
		List<Account> listData = [SELECT id, OwnerId FROM Account];
		for (Account acc : listData) {
			System.assertEquals(userCli.Id, acc.OwnerId);
		}
	}
}