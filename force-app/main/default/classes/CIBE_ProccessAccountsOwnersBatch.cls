/**********************************************************************************************************************
 Name:	  CIBE_ProccessAccountsOwnersBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para cambiar el ownerId de Ficha Cliente al Gestor.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR					DATE				Description
	1.0			US639303		Bea						21/07/2023			Init version


***********************************************************************************************************************/
public class CIBE_ProccessAccountsOwnersBatch implements Database.Batchable<sObject>,Database.Stateful{

	public Integer recordsProcessed = 0;
	public String limitBatch;
	public Set<String> setUserIds;
	
	public CIBE_ProccessAccountsOwnersBatch(String limitQuery, Set<String> userId) {
		limitBatch = '100';
		setUserIds = new Set<String>();
		setUserIds.addAll(userId);
	}
	/*Se declara un constructor vacío y sin parámetros y con un System.Debug dentro para que no salte un error de constructor vacío.
	  Es necesario para que ejecute el Framework de batch porque busca en CBK_BatchJob el constructor vacío y allí rellena los parámetros*/
	public CIBE_ProccessAccountsOwnersBatch() {
		System.debug('Constructor sin parametros de CIBE_ProccessAccountsOwnersBatch');
	}
	
	/**
	 * Get a list of Accounts WHERE EAPGestor is different of the OwnerId
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String methodName = 'start';
		String cibeQuery = '';
		String listUserIds = AV_AppUtilities.setToStringIn(setUserIds);
		cibeQuery = 'SELECT Id, OwnerId, AV_EAPGestor__r.AV_UsuarioAsociado__c FROM Account WHERE LastModifiedDate >= LAST_N_MONTHS:2 and AV_EAPGestor__r.AV_UsuarioAsociado__c in ' +listUserIds + ' limit '+ Integer.valueOf(limitBatch)+' ';

        return Database.getQueryLocator(cibeQuery);
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
			recordsProcessed = scope.size();
			
			List<Account> listDataToUpdate = new List<Account>();
			if (!scope.isEmpty()){
				for(Account data : scope) {
				
					if (data.OwnerId != data.AV_EAPGestor__r.AV_UsuarioAsociado__c){
						data.OwnerId = data.AV_EAPGestor__r.AV_UsuarioAsociado__c;
						listDataToUpdate.add(data);
					}
				}
				recordsProcessed = listDataToUpdate.size();
				List<Database.SaveResult> listUpdateResult = Database.update(listDataToUpdate, false);
				displayErrors(listUpdateResult);
			}

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

	/**
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	
	public void finish(Database.BatchableContext bc){

		String methodName='finish';
		map<String,Object> params = new map<String,Object>();
		params.put('limitBatch',limitBatch);
		params.put('setUserIds',setUserIds);
		CBK_BatchJob.executeBatch('CIBE_ProccessTasksOwnersBatch', 100 ,params); 
		
		// CIBE_ProccessTasksOwnersBatch taskBatch = new CIBE_ProccessTasksOwnersBatch(limitBatch, setUserIds);
		// Database.executeBatch(taskBatch);
	}
	
}