/**********************************************************************************************************************
 Name:	  AV_ProccessNotifymeOwnersBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para cambiar el ownerId de las AV_NotifyMe__c.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Sandra Gómez	    28/01/2021			Init version

	1.1			App FSC			David Rufo			11/02/2020			Improve batch for execution list users
	1.2			US254531		Sandra Gómez		18/08/2021			add query LastModifiedDate
	1.3			USXXXXXX		Sandra Gómez		22/11/2021			add FWK Batches
	1.4         US592987	    Ángel Medina		29/05/2023		    Changed AV_Query to SOQL queries
	1.5         FIX28080841     Oscar Moreno        30/08/2024          Fix error The Global modifier should be avoided.
***********************************************************************************************************************/
public class AV_ProccessNotifymeOwnersBatch implements Database.Batchable<sObject>, Database.Stateful{
	
    public Integer recordsProcessed = 0;
	public String limitBatch;
	public Set<String> setUserIds;
    
    public AV_ProccessNotifymeOwnersBatch(String limitQuery, Set<String> userId) {
		limitBatch = limitQuery;
		setUserIds = new Set<String>();
        setUserIds.addAll(userId);
    }

	public AV_ProccessNotifymeOwnersBatch(){}
	
	/**
	 * Get a list of AV_Notifyme__c for process owners

	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {

		String methodName = 'start';
		AV_LogDebug.printLogDebug(methodName, 'Batch limit: ' + limitBatch);
        AV_LogDebug.printLogDebug(methodName, 'List users ids: ' + setUserIds);

		String avQuery = 'SELECT Id, OwnerId, AV_Employee__r.AV_UsuarioAsociado__c FROM AV_NotifyMe__c ';
        avQuery += ' WHERE LastModifiedDate >= LAST_N_MONTHS:2 ';
        avQuery += ' AND AV_Employee__r.AV_UsuarioAsociado__c IN '+ AV_AppUtilities.setToStringIn(setUserIds);
		
		if(String.isNotBlank(limitBatch)){
			avQuery += ' LIMIT ' + Integer.valueOf(limitBatch);
		}

		AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);
		return Database.getQueryLocator(avQuery);
	}

	/**
	 * Update account OwnerId
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Account> param with the list of Accounts
	 */
	public void execute(Database.BatchableContext bc, List<AV_NotifyMe__c> scope){
		// Procesar cada batch de registros

		String methodName = 'execute';
		try{
			AV_LogDebug.printLogDebug(methodName, 'Data to check: ' + scope.size());
            recordsProcessed = scope.size();
            List<AV_NotifyMe__c> listDataToUpdate = new List<AV_NotifyMe__c>();
			for(AV_NotifyMe__c data : scope) {
                if (data.AV_Employee__r!=null && data.AV_Employee__r.AV_UsuarioAsociado__c!=null 
                    	&& data.OwnerId != data.AV_Employee__r.AV_UsuarioAsociado__c){
                	data.OwnerId = data.AV_Employee__r.AV_UsuarioAsociado__c;
                    listDataToUpdate.add(data);
                }
			}
            AV_LogDebug.printLogDebug(methodName, 'Data to update: ' + listDataToUpdate.size());
            recordsProcessed = listDataToUpdate.size();
			List<Database.SaveResult> listUpdateResult = Database.update(listDataToUpdate, false);
            displayErrors(listUpdateResult);

		}catch(System.Exception e){
			AV_LogDebug.printException(methodName, e);
		}
	}


    private void displayErrors(List<Database.SaveResult> listUpdateResult){
        String methodName = 'displayErrors';
        for (Database.SaveResult sr : listUpdateResult) {
            if (!sr.isSuccess()) {
                // Operation failed, so get all errors
                for(Database.Error err : sr.getErrors()) {
                    AV_LogDebug.printLogError(methodName, '****************ERR status: ' + err.getStatusCode() + ': ' + err.getMessage());
                    AV_LogDebug.printLogError(methodName, '****************ERR fields: ' + err.getFields());
                }
            }
        }
    }


	/**
	 * Executes the scheduled Apex job
	 *
	 * @param sc	SchedulableContext param that contains the job ID
	 */
	/*public void execute(SchedulableContext sc) {
		Database.executeBatch(new AV_ProccessAccountsOwnersBatch(AV_limit,AV_userId));
	}*/

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