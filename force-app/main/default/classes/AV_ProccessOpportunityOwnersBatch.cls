/**********************************************************************************************************************
 Name:	  AV_ProccessOpportunityOwnersBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para cambiar el ownerId de las Oportunidades.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Jashanpreet Singh	07/10/2020			Init version
	1.1			US164515		Sandra Gómez		28/01/2021			Remodel Batch

	1.2			App FSC			David Rufo			11/02/2020			Improve batch for execution list users
	1.3			US254531		Sandra Gómez		18/08/2021			add query LastModifiedDate
	1.4			USXXXXXX		Sandra Gómez		22/11/2021			add FWK Batches
	1.5         US592987	    Ángel Medina		30/05/2023		    Changed AV_Query to SOQL queries


***********************************************************************************************************************/
global class AV_ProccessOpportunityOwnersBatch implements Database.Batchable<sObject>, Database.Stateful {

	global Integer recordsProcessed = 0;

	global String limitBatch;
	global Set<String> setUserIds;
    
    global AV_ProccessOpportunityOwnersBatch(String limitQuery, Set<String> userId) {
		limitBatch = limitQuery;
		setUserIds = new Set<String>();
        setUserIds.addAll(userId);
    }
	
	global AV_ProccessOpportunityOwnersBatch() {}
	
	/**
	 * Get a list of Opportunities to process the owners

	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	global Database.QueryLocator start(Database.BatchableContext bc) {

		String methodName = 'start';
		AV_LogDebug.printLogDebug(methodName, 'Batch limit: ' + limitBatch);
        AV_LogDebug.printLogDebug(methodName, 'List users ids: ' + setUserIds);

		String avQuery = 'SELECT Id, OwnerId, AV_Gestor__r.AV_UsuarioAsociado__c FROM Opportunity ';
		avQuery += ' WHERE LastModifiedDate >= LAST_N_MONTHS:2 ';
		avQuery += ' AND AV_Gestor__r.AV_UsuarioAsociado__c IN ' + AV_AppUtilities.setToStringIn(setUserIds);
    
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
	global void execute(Database.BatchableContext bc, List<Opportunity> scope){
		// Procesar cada batch de registros

		String methodName = 'execute';
		try{
			AV_LogDebug.printLogDebug(methodName, 'Data to check: ' + scope.size());
            recordsProcessed = scope.size();
            List<Opportunity> listDataToUpdate = new List<Opportunity>();
			for(Opportunity data : scope) {
                if (data.OwnerId != data.AV_Gestor__r.AV_UsuarioAsociado__c){
                	data.OwnerId = data.AV_Gestor__r.AV_UsuarioAsociado__c;
                	listDataToUpdate.add(data);
                }
			}
            AV_LogDebug.printLogDebug(methodName, 'Data to update: ' + listDataToUpdate.size());
            recordsProcessed = listDataToUpdate.size();
			Database.update(listDataToUpdate, false);

		}catch(System.Exception e){
			AV_LogDebug.printException(methodName, e);
		}
	}

	/**
	 * Executes the scheduled Apex job
	 *
	 * @param sc	SchedulableContext param that contains the job ID
	 */
	/*global void execute(SchedulableContext sc) {

		Database.executeBatch(new AV_ProccessAccountsOwnersBatch(limitBatch, setUserIds));

	}*/

	/**
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	global void finish(Database.BatchableContext bc){
		String methodName='finish';
		AV_LogDebug.printLogDebug(methodName, 'Record Processes: ' + recordsProcessed);


		map<String,Object> params = new map<String,Object>();
		params.put('limitBatch',limitBatch);
		params.put('setUserIds',setUserIds);
		//String paramStr = JSON.serialize(params);  
		CBK_BatchJob.executeBatch('AV_ProccessNotifymeOwnersBatch', 200 ,params);

		//AV_ProccessNotifymeOwnersBatch taskBatch = new AV_ProccessNotifymeOwnersBatch(limitBatch, setUserIds);
		//Database.executeBatch(taskBatch);

	}
}