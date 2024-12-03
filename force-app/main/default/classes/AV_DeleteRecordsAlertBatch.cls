/**********************************************************************************************************************
 Name:	  AV_DeleteRecordsAlertBatch
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Proceso Batch de borrado de Alertas cuando el campo To Delete está marcado
=======================================================================================================================
Historial
---------------------
   VERSION		USER_STORY		AUTHOR				DATE				Description
   1.0			App FSC			Maria Telleria		23/04/2020			Init version
   2.0			App FSC			Esperanza Conde		24/07/2020			Include LastModifiedDate = LAST_N_DAYS:7 in the query
   2.1			App FSC			Carolina Alonso		26/10/2020			Delete OrderBy in the query and Include RT
   2.2			App FSC		  	Sandra Gómez		04/11/2020			Modify method finish
   2.3			App FSC		    Esperanza Conde		11/12/2020			Improve the limit query: dynamic limit query
   2.4			App FSC		    Esperanza Conde	    18/12/2020			Include false in Delete method.
   2.5		    FIX11070844	    Oscar Moreno		19/07/2024			Fix error The Global modifier should be avoided.

***********************************************************************************************************************/
public class AV_DeleteRecordsAlertBatch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {

	public Integer recordsProcessed = 0;
	public static final String BATCHNAME = 'AV_DeleteAlerts';
	
	//public String AV_limit;

	/**
	 * Create a list of FinServ__Alert__c where the field AV_ToDelete__c is checked.
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {
		
		String query = 'SELECT ID, AV_ToDelete__c FROM FinServ__Alert__c WHERE AV_ToDelete__c = true'+
			+ ' AND LastModifiedDate = LAST_N_DAYS:7 AND RecordType.DeveloperName IN (\'AV_Alerta\')';
		
		String batchLimit = AV_SchedulerBatches.getLimit(BATCHNAME);
		if (String.isNotBlank(batchLimit)){
			query += ' LIMIT ' + batchLimit;
		}		
 		
		return Database.getQueryLocator(query);
		
	}
		
	/**
	 * Delete the selected list of 	FinServ__Alert__c
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<FinServ__Alert__c> param with the list of Alerts to delete
	 */
	public void execute(Database.BatchableContext bc, List<FinServ__Alert__c> scope){
		// Procesar cada batch de registros
		String methodName = 'execute';
		try{
			recordsProcessed= scope.size();
			AV_LogDebug.printLogDebug(methodName,'Data for delete: ' + scope.size());
			Database.delete(scope,false);
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
		Database.executeBatch(new AV_DeleteRecordsAlertBatch());
	}

	/**
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	public void finish(Database.BatchableContext bc){
		String methodName='finish';
		AV_LogDebug.printLogDebug(methodName, 'Record Processes: ' + recordsProcessed);
	}	
}