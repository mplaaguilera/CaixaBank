public class CIBE_DeleteNotAssignedContactsBatch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
	public Integer recordsProcessed = 0;
    public Integer limitBatch = 100;
    public static final String BATCHNAME = 'CIBE_DeleteNotAssignedContacts';    
	private String avQuery;
	
    public CIBE_DeleteNotAssignedContactsBatch(){
        this.avQuery = setQuery();
    }
    public CIBE_DeleteNotAssignedContactsBatch(String avQuery){
        this.avQuery = avQuery;
    }
	
	private String setQuery(){ 
		String cibeQuery = 'SELECT Id, CIBE_AsistenteNoRegistrado__c FROM Contact ';
		cibeQuery += ' WHERE CIBE_AsistenteNoRegistrado__c = true ';
        cibeQuery += ' AND Createddate <= LAST_N_MONTHS:3 ';
		cibeQuery += ' LIMIT ' + Integer.valueOf(limitBatch);
		
		return cibeQuery;
    }
    
	/**
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(avQuery);
    }
    
	/**
	 * Update the Accounts
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Contact> param with the list of Contact.
	 */
    public void execute(Database.BatchableContext bc, List<Contact> scope){
        // Procesar cada batch de registros

		String methodName = 'execute';
		try{
            recordsProcessed = scope.size();
			Database.DeleteResult[] deletes = Database.delete(scope, false);
			boolean hasError = false;
			List<Object> objs = new List<Object>();
			Map<String, String> msjs = new Map<String, String>();
			for (Integer i = 0; i < scope.size(); i++) {
				Database.DeleteResult dr = deletes[i];
				if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
					msjs.put(scope[i].Id, ((String)dr.getErrors()[0].getMessage()));
					objs.add(scope[i]);
					hasError = true;
				}
			}
			if(hasError) {
				CBK_Log.error(msjs, objs);
			}

		}catch(System.Exception e){
			AV_LogDebug.printException(methodName, e);
		}
    }
    
	/**
	 * Print the results of the batch process
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
    public void finish(Database.BatchableContext bc){
        String methodName='finish';
		CBK_Log.debug(BATCHNAME+' '+methodName, 'Record Processes: ' + recordsProcessed);
    }

	/**
	 * Executes the scheduled Apex job
	 * @param sc	SchedulableContext param that contains the job ID
	 */
	public void execute(SchedulableContext sc) {
		Database.executeBatch(new CIBE_DeleteNotAssignedContactsBatch());
	}
}