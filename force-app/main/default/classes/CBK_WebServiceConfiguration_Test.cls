@isTest
private class CBK_WebServiceConfiguration_Test {

	@isTest
	private static void getServiceConfigTest() {
		CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'MyIntegrationTest';
		wsc.NamedCredential__c = 'callout:MyIntegrationTest';
		insert wsc;

		Test.startTest();
		CBK_IntegrationSetting__c wscnf = CBK_WebServiceConfiguration.getConfiguration('MyIntegrationTest');
		Boolean check = false;
		check = wscnf != null ? true : false;

		System.assertEquals(true,check);
		Test.stopTest();
	}
}