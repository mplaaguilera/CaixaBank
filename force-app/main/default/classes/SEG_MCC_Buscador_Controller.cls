public with sharing class SEG_MCC_Buscador_Controller {

	@AuraEnabled(cacheable=true)
	public static List<sObject> querySalesforceRecord(String queryString) {
		return Database.query(queryString);
	}
}