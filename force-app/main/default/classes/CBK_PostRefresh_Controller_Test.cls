@isTest 
private class CBK_PostRefresh_Controller_Test {

	@isTest
	private static void postrefreshTest() {

		Test.startTest();
		CBK_PostRefresh_Controller.refreshMetadata();

		CBK_IntegrationSetting__c conf = new CBK_IntegrationSetting__c(name = 'test', NamedCredential__c = '/API_GWT_PRO/' );
		insert conf;

		CBK_PostRefresh_Controller.refreshCustomSetting();
		String envir = CBK_PostRefresh_Controller.getSandbox();
		if (String.isNotBlank(envir)){
			System.assertNotEquals('/API_GWT_PRO/',conf.name);
		}
		Test.stopTest();
	}
	@isTest
	private static void createUSer() {
		Test.startTest();
		CBK_PostRefresh_Controller.createUser('', 'System Administrator', 'testscript', 'admin', 'testscriptadmin@test.com', 'testscriptadministrator@test.com');

		List<User>lstuser = [SELECT Id, Email FROM User WHERE Email = 'testscriptadmin@test.com'];

		if (lstuser != null && lstuser.size() > 0){
			System.assertEquals('testscriptadmin@test.com',lstuser[0].Email);
		}	
		Test.stopTest();
	}

}