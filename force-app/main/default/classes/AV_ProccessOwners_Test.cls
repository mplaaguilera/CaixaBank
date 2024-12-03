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
   2.3 			  US649249	   	   Gonzalo Ávila	  	27/11/2023		    Include system.asserts in all methods

***********************************************************************************************************************/
@isTest
private class AV_ProccessOwners_Test {
	@TestSetup
	static void setup() {
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		AV_TestHelper.activateLogger();
		 
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
			AV_ExternalID__c = 'U0009003'
		);
		insert u1;
		Contact c =  AV_TestHelper.createEmployee(null,u1);
	}
	@isTest
	static void executeProccessOwnersBatch() {
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		User us=[SELECT id FROM USER LIMIT 1];
		String param = (String)us.id;
		Boolean check = true;
		System.runAs(userGcf){ 
		Test.startTest();
		try {
			AV_ProccessOwners.proccess( param );	
		} catch (Exception e) {
			e.getMessage();
			check = false;
		}	
		System.assert(check, 'executeProccessOwnersBatch Error');

		Test.stopTest();
	}
	}
}