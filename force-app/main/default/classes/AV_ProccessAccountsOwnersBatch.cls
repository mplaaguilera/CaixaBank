/**********************************************************************************************************************
 Name:	  AV_ProccessAccountsOwnersBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para cambiar el ownerId de Ficha Cliente al Gestor.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR					DATE				Description
	1.0			App FSC			Jashanpreet Singh		07/10/2020			Init version
	1.1			App FSC			David Rufo				11/02/2020			Improve batch for execution list users
	1.2			US254531		Sandra Gómez			18/08/2021			add query LastModifiedDate
	1.3			USXXXXXX		Sandra Gómez			22/11/2021			add FWK Batches
	1.4		    AV_Query IT	   Daniel Rodríguez	   04/02/2022	    Change AV_Query to SOQL for User and Account
	1.5         FIX28080841     Oscar Moreno            28/08/2024          Fix error The Global modifier should be avoided.
   
***********************************************************************************************************************/
public class AV_ProccessAccountsOwnersBatch implements Database.Batchable<sObject>,Database.Stateful{

	public Integer recordsProcessed = 0;
	public String limitBatch;
	public Set<String> setUserIds;
	
	public AV_ProccessAccountsOwnersBatch(String limitQuery, Set<String> userId) {
		limitBatch = limitQuery;
		setUserIds = new Set<String>();
		setUserIds.addAll(userId);
	}
	
	public AV_ProccessAccountsOwnersBatch(){}

	/**
	 * Get a list of Accounts where EAPGestor is different of the OwnerId
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String methodName = 'start';
		AV_LogDebug.printLogDebug(methodName, 'Batch limit: ' + limitBatch);
		AV_LogDebug.printLogDebug(methodName, 'List users ids: ' + setUserIds);
		String avQuery = '';
		String listUserIds = AV_AppUtilities.setToStringIn(setUserIds);
		if(String.isNotBlank(limitBatch)){
			avQuery = 'Select Id, AV_BatchProccessOwners__c, OwnerId, AV_EAPGestor__r.AV_UsuarioAsociado__c From Account Where LastModifiedDate >= LAST_N_MONTHS:2 and AV_EAPGestor__r.AV_UsuarioAsociado__c in ' +listUserIds + ' limit '+ Integer.valueOf(limitBatch)+' ';
		}else{
			avQuery = 'Select Id, AV_BatchProccessOwners__c, OwnerId, AV_EAPGestor__r.AV_UsuarioAsociado__c From Account Where LastModifiedDate >= LAST_N_MONTHS:2 and AV_EAPGestor__r.AV_UsuarioAsociado__c in ' +listUserIds+' ';
		}

		AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);
        return Database.getQueryLocator(avQuery);
		
		/*AV_Query avQuery = new AV_Query('Account')
							.selectFields('Id, AV_BatchProccessOwners__c, OwnerId, AV_EAPGestor__r.AV_UsuarioAsociado__c')
							.addConditionGe('LastModifiedDate',AV_Query.LAST_N_MONTHS(2))
							.addConditionIn('AV_EAPGestor__r.AV_UsuarioAsociado__c', setUserIds);
		AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);
		return avQuery.getQueryLocator();*/
	}

	/**
	 * Update account OwnerId
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Account> param with the list of Accounts
	 */
	public void execute(Database.BatchableContext bc, List<Account> scope){
		// Procesar cada batch de registros
		String methodName = 'execute';
		try{
			AV_LogDebug.printLogDebug(methodName, 'Data to check: ' + scope.size());
			recordsProcessed = scope.size();
			List<Account> listDataToUpdate = new List<Account>();
			for(Account data : scope) {
				if (data.OwnerId != data.AV_EAPGestor__r.AV_UsuarioAsociado__c){
					data.OwnerId = data.AV_EAPGestor__r.AV_UsuarioAsociado__c;
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
		Database.executeBatch(new AV_ProccessAccountsOwnersBatch(limitBatch, userIdBatch));
	}*/

	/**
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	public void finish(Database.BatchableContext bc){
		String methodName='finish';
		AV_LogDebug.printLogDebug(methodName, 'Record Processes: ' + recordsProcessed);

		map<String,Object> params = new map<String,Object>();
		params.put('limitBatch',limitBatch);
		params.put('setUserIds',setUserIds);
		CBK_BatchJob.executeBatch('AV_ProccessTasksOwnersBatch', 200 ,params); 
		
		//AV_ProccessTasksOwnersBatch taskBatch = new AV_ProccessTasksOwnersBatch(limitBatch, setUserIds);
		//Database.executeBatch(taskBatch);
	}
	
}