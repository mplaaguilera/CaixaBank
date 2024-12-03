public inherited sharing class CBK_DataTableView_Controller {
	@AuraEnabled(cacheable = true)
	public static List<SObject> retriveRecords(String sQuery, String recordId) {
		sQuery = sQuery.replace('@RecordId', recordId);
		CBK_log.debug('Query Data Table: ' + sQuery, LoggingLevel.INFO);
		List<SObject> newlstObj = new List<SObject> ();

		List<task> lstObj = Database.query(sQuery);
		CBK_log.debug('lstObj: ' + lstObj, LoggingLevel.INFO);
		return Database.query(sQuery);
	}
}