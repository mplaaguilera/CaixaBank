@isTest
public with sharing class EV_AccountTriggerHelper_Test {
    @TestSetup
	static void makeData(){
		Account personAccount = EV_TestHelper.createCustomer();
	}


	@isTest
	public static void updateLastModifiedDateTest() {
		//Set<String> selectFieldsAccount = new Set<String>{'Id', 'CC_Numero_Documento__c', 'EV_LastModifiedDateAC__c,AV_Idioma__c,AV_EAPGestor__c'};

		Account customer = [SELECT Id, CC_Numero_Documento__c, EV_LastModifiedDateAC__c, AV_Idioma__c, AV_EAPGestor__c FROM Account where AV_NumPerso__c = '123'];
		Map<Id, Account> mapOld = new Map<Id, Account>{customer.Id => customer};
		List<Account> listNew = new List<Account>();
		customer.CC_Numero_Documento__c = '48133896Z';
		
		//update customer;
		listNew.add(customer);
		Test.startTest();
		//EV_AccountTriggerHelper.updateLastModifiedDate(listNew, mapOld);
		update customer;
		
		System.assertEquals('48133896Z', customer.CC_Numero_Documento__c);
		Test.stopTest();
		
	}
	

}