/**********************************************************************************************************************
 Name:	  AV_DeleteRecordsContactBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch de borrado de Contact cuando el campo To Delete está marcado
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			App FSC				Maria Telleria		13/07/2020			Init version
	2.0			App FSC				Esperanza Conde		24/07/2020			Include LastModifiedDate = LAST_N_DAYS:7 in the query
	2.1			App FSC				Carolina Alonso		26/10/2020			Delete OrderBy in the query and Include RT
	2.2			App FSC				Sandra Gómez		04/11/2020			Modify method finish
	2.3			App FSC				Sandra Gómez		02/12/2020			Improve the limit query: dynamic limit query
	2.4			App FSC				Sandra Gómez		01/02/2021			Include enqueueJob
	2.5			Hotfix IOP Enero	Carolina Alonso		02/02/2021			Delete LastModifiedDate in the query
	2.6			FIX					David Rufo			31/05/2021			Use the Query FWK
	2.7			FIX					David Rufo			22/06/2021			Use the number of days via Custom Metadata
	2.8		    AV_Query IT	        Daniel Rodríguez    03/03/2022	        Change AV_Query to SOQL for User, Account, Contact
	2.9			OrgHealth			Carolina Alonso		17/03/2022			Change AV_Query logic to allow calling method with an external query
    3.0		    FIX11070844	    Oscar Moreno		   22/07/2024			Fix error The Global modifier should be avoided.

***********************************************************************************************************************/
public class AV_DeleteRecordsContactBatch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {

	public Integer recordsProcessed = 0;
	public static final String BATCHNAME = 'AV_DeleteContacts';
	
    private String avQuery = '';
	
    public AV_DeleteRecordsContactBatch(){
        avQuery = setQuery();
    }

    public AV_DeleteRecordsContactBatch(String avQuery){
        this.avQuery = avQuery;
    }
    
    private String setQuery(){
        Set<String> setRt = new Set<String>{AV_AppConstants.EMPLOYEE_RT};
        String batchLimit = AV_SchedulerBatches.getLimit(BATCHNAME);
		Integer numDays = AV_SchedulerBatches.getNumDays(BATCHNAME);
        /*AV_Query avQuery = new AV_Query('Contact')
                                    .selectFields('ID, AV_ToDelete__c')
                                    .addConditionEq('AV_ToDelete__c', true)
            						.addConditionEq('SystemModstamp', AV_Query.LAST_N_DAYS(numDays))
                                    .addConditionIn('RecordType.DeveloperName', setRt);

		if(String.isNotBlank(batchLimit)){
			avQuery.setLimit(Integer.valueOf(batchLimit));
    }*/
		List<String> listRTs = AV_AppUtilities.getListFromSet(setRt);
		if(String.isNotBlank(batchLimit)){
			avQuery = 'Select Id, AV_ToDelete__c From Contact Where SystemModstamp = LAST_N_DAYS:'+ numDays+ ' and RecordType.DeveloperName in ' +listRTs+' and AV_ToDelete__c = true limit '+ batchLimit+' ';
		}else{
			avQuery = 'Select Id, AV_ToDelete__c From Contact Where SystemModstamp = LAST_N_DAYS:'+ numDays+ ' and RecordType.DeveloperName in ' +listRTs+' and AV_ToDelete__c = true';
		}
        return avQuery;
    }
    
	/**
	 * Delete the selected list of Employees where the field AV_ToDelete__c is checked.
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String methodName = 'start';
        if(avQuery==null){
            avQuery = setQuery();
		}
		
		AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);

		//Enqueue the next delete batch
		AV_LogDebug.printLogDebug(methodName, 'Next delete job: \'AV_DeleteRecordsAccountBatchQueueable\'');
		System.enqueueJob(new AV_DeleteRecordsAccountBatchQueueable());
		return Database.getQueryLocator(avQuery);
		//return avQuery.getQueryLocator();
	}
		
	/**
	 * Delete the selected list of Contact
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Contact> param with the list of Sales to delete
	 */
	public void execute(Database.BatchableContext bc, List<Contact> scope){
		// Procesar cada batch de registros
		String methodName = 'execute';
		try{
			recordsProcessed = scope.size();
			AV_LogDebug.printLogDebug(methodName,'Data for delete: ' + scope.size());
			Database.delete(scope, false);
		}catch(System.Exception e){
			AV_LogDebug.printException(methodName, e);
		}
	}
	 /**
	 * Executes the scheduled Apex job
	 *
	 * @param sc	SchedulableContext param that contains the job ID
	 */
	 public void execute(SchedulableContext sc) {
		 Database.executeBatch(new AV_DeleteRecordsContactBatch());
	 }
		

	/**
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	public void finish(Database.BatchableContext bc){
		String methodName='finish';
		AV_LogDebug.printLogDebug(methodName, 'Record Processed: ' + recordsProcessed);
		//Database.executeBatch(new AV_DeleteRecordsAccountBatch());
	}	
}