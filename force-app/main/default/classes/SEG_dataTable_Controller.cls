public inherited sharing class SEG_dataTable_Controller {

	@AuraEnabled(cacheable = true)
	public static List<SObject> retriveRecords(String sQuery, String recordId) {
		sQuery = sQuery.replace('@RecordId', recordId);
		System.debug('Query Data Table: ' + sQuery);
		return Database.query(sQuery);
	}
}