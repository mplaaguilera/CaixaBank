@isTest(SeeAllData=false)
private class CBK_Adoption_FWK_Batch_Test{
	@isTest 
	private static void testMethod1() {
		Test.startTest();
		CBK_Adoption_FWK_Batch batchT = new CBK_Adoption_FWK_Batch('200');
		Id batchId = Database.executeBatch(batchT);
		Test.stopTest();

		List<CBK_Adoption_FWK__c> lstfwk = [SELECT Id FROM CBK_Adoption_FWK__c limit 200];
		Boolean hasResults = lstfwk.size() > 0 ? true : false;
		
		System.assertNotEquals(null,batchId);
		System.assertEquals(true, hasResults);
	}
}