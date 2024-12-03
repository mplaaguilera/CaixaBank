@isTest
private class CBK_VS_ChangeOwner_Controller_Test{

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

	@isTest 
	private static void testMethod1() {
		User usuario = [SELECT id FROM User WHERE LastName = 'Administrator' LIMIT 1];
		list<CBK_Adoption_FWK__c> lstcbkAdop = new List<CBK_Adoption_FWK__c>();
		CBK_Adoption_FWK__c cbkAdop; 
		for(Integer  i = 0; i <= 11; i++){
			cbkAdop = new CBK_Adoption_FWK__c();
			cbkAdop.CBK_FWK_Name__c = 'Framework Test ' + i;
			cbkAdop.CBK_Project__c = 'CBK';
			cbkAdop.RecordTypeId =  Schema.getGlobalDescribe().get('CBK_Adoption_FWK__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Information').getRecordTypeId();
			cbkAdop.OwnerId = usuario.Id;
			lstcbkAdop.add(cbkAdop);
	 	}

		Database.SaveResult[] lstResp = Database.insert(lstcbkAdop, false);
	
		System.runAs(usuario){
			PageReference testPage = Page.CBK_VS_ChangeOwner;
			Test.setCurrentPage(testPage);

			ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstcbkAdop);
			stdSetController.setSelected(lstcbkAdop);
			CBK_VS_ChangeOwner_Controller lstIdVF = new CBK_VS_ChangeOwner_Controller(stdSetController);
			System.assertEquals(lstIdVF.getIDs.size(), lstcbkAdop.size(), 'Registros VF Page. Ids a cambiar');
			
		}
	}
 }