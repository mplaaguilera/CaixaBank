/**********************************************************************************************************************
Name:	  AV_TaskTriggerHelperSharing_Test
Copyright © 2019  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_TaskTriggerHelperSharing"
------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Fix      	   Patricia Solano	    07/08/2022		Init version
1.1			Fix      	   Sandra Gómez	    	21/11/2023		Change profile of user
***********************************************************************************************************************/
@isTest
public without sharing class AV_TaskTriggerHelperSharing_Test {
	@TestSetup
	static void setup(){
		AV_TestHelper.activateLogger();
		final String MATRICULA_SAMPLE = 'U0009003';
		String labelProfile;
		if (String.isBlank(labelProfile)){
			labelProfile = 'AV_Usuario_CaixaBank';
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
			AV_ExternalID__c = MATRICULA_SAMPLE,
			AV_NumeroOficinaEmpresa__c = '001-10101'
		);
		
		User userTest = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U013213981238');
		List<User> users = new List<User>{u1,userTest};
		insert users;
		System.runAs(userTest){
			AV_TestHelper.createTarea(userTest, System.today());
			Pricebook2 pb = new Pricebook2();
			pb.Name = 'Standard Price Book';
			insert pb;
			List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
			CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
			listDummyWords.add(word);
			CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
			listDummyWords.add(word2);
			Database.insert(listDummyWords, false);
		}
		Account cliente = AV_TestHelper.createCustomerSinInsert();
		Account centroCaixa = AV_TestHelper.createCaixaCenterSinInsert();
		List<Account> accs = new List<Account>{cliente, centroCaixa};
		insert accs;
		Contact empleado  = AV_TestHelper.createEmployee(centroCaixa, u1);
	}

    @isTest
	public static void calculateTaskScore(){
		Test.startTest();
		RecordType rtIniciativa = AV_AppUtilities.getRecordType('Task','AV_Otros');
		User owner = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM USER WHERE AV_NumeroOficinaEmpresa__c = '001-10101' AND AV_ExternalID__c = 'U0009003' limit 1];
		Account acc= [select id,AV_Priority__c from account limit 1];
		Task tskIniciativa = new Task (
			Subject = 'tskIniciativa',
			OwnerId = owner.id,
			WhatId=acc.id,
			RecordTypeId= rtIniciativa.id
		);
		AV_Score__c score = new AV_Score__c(
            AV_Active__c = true,
            AV_Object__c = 'Task',
            Name = 'Otros',
            AV_RecordType__c = 'AV_Otros',
            AV_Score__c = 100
        );
        insert score;
        Database.insert(tskIniciativa);
        tskIniciativa.status='No gestionada';
		Database.update(tskIniciativa);
		Test.stopTest();
        System.assertEquals(true, acc.AV_Priority__c!=0, 'Score not added');
	}

	@isTest
	public static void calculateTaskScoreDelete(){
		Test.startTest();
		RecordType rtIniciativa = AV_AppUtilities.getRecordType('Task','AV_Otros');
		User owner = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM USER WHERE AV_NumeroOficinaEmpresa__c = '001-10101' AND AV_ExternalID__c = 'U0009003' limit 1];
		Account acc= [select id,AV_Priority__c from account limit 1];
		Decimal originalScore = acc.AV_Priority__c;
		AV_Score__c score = new AV_Score__c(
            AV_Active__c = true,
            AV_Object__c = 'Task',
            Name = 'Otros',
            AV_RecordType__c = 'AV_Otros',
            AV_Score__c = 100
        );
        insert score;
		Task tskIniciativa = new Task (
			Subject = 'tskIniciativa',
			OwnerId = owner.id,
			WhatId=acc.id,
			RecordTypeId= rtIniciativa.id,
			Status='Open'
		);
		insert tskIniciativa;
        Database.delete(tskIniciativa);
		Account acc2= [select id,AV_Priority__c from account limit 1];
		Test.stopTest();
        System.assertEquals(true, acc2.AV_Priority__c==0, 'Score not added. Priority: ' + acc2.AV_Priority__c);
	}
}