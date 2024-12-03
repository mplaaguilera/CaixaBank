/**********************************************************************************************************************
Name:	  AV_LookupSearchResult_Test
Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase de test de "AV_LookupSearchResult"
=======================================================================================================================
Historial
---------------------
VERSION     USER_STORY              AUTHOR              DATE            Description
1.0         Init version            Sandra Gómez        04/05/2021      Init version
1.1			AV_Query IT		        Daniel Rodríguez	3/02/2022		Change AV_Query to SOQL for User and Account
***********************************************************************************************************************/
@isTest
public with sharing class AV_LookupSearchResult_Test {
    @TestSetup
	static void setup(){
		User usrTest = AV_TestHelper.createUser('Standard User');
	} 
    
	@isTest
	public static void createLookupSearchResultTest() {
        Test.startTest();
        User user = [Select Id, AV_ExternalID__c, Name From User Where profile.Name = 'Standard User' limit 1];
		/*User user = (User)new AV_Query('User')
									.selectFields('Id, AV_ExternalID__c, Name')
									.setLimit(1)
									.fetch();*/
		String userIcon = 'standard:user';
		AV_LookupSearchResult results = new AV_LookupSearchResult(user.Id,'User',userIcon,user.Name,'Matrícula • ' + user.AV_ExternalID__c);
        AV_LookupSearchResult results2 = new AV_LookupSearchResult(user.Id,'User',userIcon,'AAA '+user.Name,'Matrícula • ' + user.AV_ExternalID__c);
        String id=results.getId();
        String objectType=results.getSObjectType();
        String icon=results.getIcon();
        String title=results.getTitle();
        String subtitle=results.getSubtitle(); 
        Integer mayor=results.compareTo(results2);
        Test.stopTest();
        System.assertNotEquals(null,results);
    }
}