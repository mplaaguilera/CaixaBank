/**********************************************************************************************************************
 Name:	  CIBE_ProccessNotifymeOwnersBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para cambiar el ownerId de las AV_NotifyMe__c.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US639303		Bea				    28/01/2021			Init version
	
***********************************************************************************************************************/
public class CIBE_ProccessNotifymeOwnersBatch implements Database.Batchable<sObject>, Database.Stateful{
	
    public Integer recordsProcessed = 0;
	public String limitBatch;
	public Set<String> setUserIds;
    
    public CIBE_ProccessNotifymeOwnersBatch(String limitQuery, Set<String> userId) {
		limitBatch = '100';
		setUserIds = new Set<String>();
        setUserIds.addAll(userId);
    }
	/*Se declara un constructor vacío y sin parámetros y con un System.Debug dentro para que no salte un error de constructor vacío.
	  Es necesario para que ejecute el Framework de batch porque busca en CBK_BatchJob el constructor vacío y allí rellena los parámetros*/
	  public CIBE_ProccessNotifymeOwnersBatch() {
		System.debug('Constructor sin parametros de CIBE_ProccessNotifymeOwnersBatch');
	}
	
	/**
	 * Get a list of AV_Notifyme__c for process owners

	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {

		String methodName = 'start';
		String cibeQuery = 'SELECT Id, OwnerId, AV_Employee__r.AV_UsuarioAsociado__c FROM AV_NotifyMe__c ';
        cibeQuery += ' WHERE LastModifiedDate >= LAST_N_MONTHS:2 ';
        cibeQuery += ' AND AV_Employee__r.AV_UsuarioAsociado__c IN '+ AV_AppUtilities.setToStringIn(setUserIds);
		cibeQuery += ' LIMIT ' + Integer.valueOf(limitBatch);
		
		return Database.getQueryLocator(cibeQuery);
	}

	/**
	 * Update account OwnerId
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<AV_NotifyMe__c> param with the list of AV_NotifyMe
	 */
	public void execute(Database.BatchableContext bc, List<AV_NotifyMe__c> scope){
		// Procesar cada batch de registros

		String methodName = 'execute';
		try{
            recordsProcessed = scope.size();
            List<AV_NotifyMe__c> listDataToUpdate = new List<AV_NotifyMe__c>();
			for(AV_NotifyMe__c data : scope) {
                if (data.AV_Employee__r!=null && data.AV_Employee__r.AV_UsuarioAsociado__c!=null 
                    && data.OwnerId != data.AV_Employee__r.AV_UsuarioAsociado__c){
                	data.OwnerId = data.AV_Employee__r.AV_UsuarioAsociado__c;
                    listDataToUpdate.add(data);
                }
			}
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