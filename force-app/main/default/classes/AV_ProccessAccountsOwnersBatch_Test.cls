/**********************************************************************************************************************
 Name:      AV_ProccessAccountsOwnersBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_ProccessAccountsOwnersBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY       AUTHOR               DATE                Description
   	1.0            App FSC          Jashanpreet Singh   07/10/2020          Init version
	1.1            App FSC          David Rufo         	10/02/2021          Fix performance problem

***********************************************************************************************************************/
@isTest
private class AV_ProccessAccountsOwnersBatch_Test {
	
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();
		User u1 = AV_TestHelper.createUser('AV_Usuario_CaixaBank', 'U0100001');
        User u2 = AV_TestHelper.createUser('AV_Usuario_CaixaBank', 'U000900312');
        Contact con =  AV_TestHelper.createEmployee(null,u1,u1.AV_ExternalId__c);

		List<Account> accounts = new List<Account>();
        RecordType rt = AV_AppUtilities.getRecordType('Account', 'CC_ClientePA');
        
		/**
		 * Create 10 Accounts with the field AV_BatchProccessOwners__c 'ToBeProcess'.
		 */
		// Insertar 10 Cuentas 
		for (Integer i=0;i<1;i++) {
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
        
        con.AV_UsuarioAsociado__c = u2.Id;
        con.CC_Matricula__c = u2.AV_ExternalId__c;
        update con;

		
	}

	/**
	 * Execute the Batch class (AV_ProccessAccountsOwnersBatch) 
	 */
	@isTest
	static void executeProccessAccountsOwnersBatch() {
        User u2 = [SELECT Id FROM User where AV_ExternalID__c = 'U000900312' limit 1];
        Set<String> setUserIds = new Set<String>{u2.Id};
        AV_LogDebug.printLogDebug('executeProccessAccountsOwnersBatch', 'User2: ' + u2);	
        
		AV_ProccessAccountsOwnersBatch b = new AV_ProccessAccountsOwnersBatch('300', setUserIds);
        
        Test.startTest();	
		Database.executeBatch(b);
		Test.stopTest();
        
        List<Account> listData = [SELECT id, OwnerId,AV_EAPGestor__r.AV_UsuarioAsociado__c FROM Account];
        for (Account acc : listData) {
            System.assertEquals(acc.AV_EAPGestor__r.AV_UsuarioAsociado__c, u2.id);
        }
	}
}