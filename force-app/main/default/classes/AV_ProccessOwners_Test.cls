/**********************************************************************************************************************
 Name:      AV_ProccessOwners_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_ProccessOwners
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY       AUTHOR               DATE                Description
   1.0            App FSC          Sandra Gómez         27/01/2021          Init version
   1.1			  USXXXXXX		   Daniel Rodriguez	    22/11/2021			add FWK Batches

***********************************************************************************************************************/
@isTest
private class AV_ProccessOwners_Test {
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();
		String MATRICULA_SAMPLE = 'U0009003';
		String labelProfile;
		if (String.isBlank(labelProfile)){
			labelProfile = 'Standard User';
		}
		List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'' + labelProfile + '\' LIMIT 1');
		Profile p = (Profile)result.get(0);
		User u1 = new User(
			Alias = 'tsAlias',
			Email = 'test@test.dev',
			EmailEncodingKey = 'UTF-8',
			LastName = 'testLastName',
			LanguageLocaleKey = 'es',
			LocaleSidKey = 'es',
			TimeZoneSidKey = 'Europe/Berlin',
			ProfileId = p.Id,
			UserName = 'testdevdev@test.com.dev',
			AV_ExternalID__c = MATRICULA_SAMPLE
		);
		insert u1;
		Contact c =  AV_TestHelper.createEmployee(null,u1);
	}
	@isTest
	static void executeProccessOwnersBatch() {
		User us=[SELECT id FROM USER LIMIT 1];
		String param = (String)us.id;
		Test.startTest();
		AV_ProccessOwners.proccess( param );
		Test.stopTest();
	}
}