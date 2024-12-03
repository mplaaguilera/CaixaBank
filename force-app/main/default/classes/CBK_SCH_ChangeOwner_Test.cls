@isTest
private class CBK_SCH_ChangeOwner_Test{

	@testSetup static void setup(){
		User user = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema'].Id,
            LastName = 'Administrator',
            Email = 'test@test.com',
            Username = 'test@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
        insert user;
		
	}

	@isTest static void testMethod1() {
		
		list<CBK_Adoption_FWK__c> lstcbkAdop = new List<CBK_Adoption_FWK__c>();
		CBK_ScheduleControls__c schInf = new CBK_ScheduleControls__c(name = 'ScheduleInfo', Retries__c = 0, ExecutionPeriod__c = 1, Date_Last_Execution__c = datetime.now() );
		insert schInf;
		CBK_Adoption_FWK__c cbkAdop; 
		for(Integer  i = 0; i <= 1; i++){
			cbkAdop = new CBK_Adoption_FWK__c();
			cbkAdop.CBK_FWK_Name__c = 'Framework Test ' + i;
			cbkAdop.CBK_Project__c = 'CBK';
			cbkAdop.RecordTypeId =  Schema.getGlobalDescribe().get('CBK_Adoption_FWK__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Information').getRecordTypeId();
			//cbkAdop.OwnerId = usr[0].Id;
			lstcbkAdop.add(cbkAdop);
		}

		Database.SaveResult[] lstResp = Database.insert(lstcbkAdop, false);

		List<string> lstId = new List<string>();

		for(Database.SaveResult res : lstResp){
			lstId.add(res.id);
		}

		List<User> usr = [SELECT id FROM User WHERE LastName = 'Administrator' LIMIT 1];
		List<CBK_SCH_PendingProcess__c> lstPending = new List<CBK_SCH_PendingProcess__c> ();
		CBK_SCH_PendingProcess__c pp = new CBK_SCH_PendingProcess__c();
		Datetime vToday = datetime.now();
		pp.Type__c = 'ChangeOwner';
		pp.RecordId__c = lstcbkAdop[0].Id;
		pp.Param1__c = 'CBK_Adoption_FWK__c';
		pp.Param2__c = usr[0].Id;
		pp.Schedule_Time__c = vToday.addDays(- 1);
		pp.ClassName__c = 'CBK_SCH_ChangeOwner';
		pp.Retries__c = 0;
		lstPending.add(pp);

		pp = new CBK_SCH_PendingProcess__c();
		pp.Type__c = 'ChangeOwner';
		pp.RecordId__c = lstcbkAdop[1].Id;
		pp.Param1__c = 'CBK_Adoption_FWK__c';
		pp.Param2__c = usr[0].Id;
		pp.Schedule_Time__c = vToday.addDays(- 1);
		pp.ClassName__c = 'CBK_SCH_ChangeOwner';
		pp.Retries__c = 0;
		lstPending.add(pp);

		CBK_SCH_ChangeOwner implClass = new CBK_SCH_ChangeOwner();
		implClass.lstInfoProcess = lstPending;
		System.enqueueJob(implClass);	

		List<CBK_Adoption_FWK__c> lstChangeOwner =  [SELECT Id, OwnerId FROM CBK_Adoption_FWK__c WHERE Id IN :lstId];

		System.assertEquals(lstChangeOwner.size(), lstId.size());
	}
}