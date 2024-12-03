/**********************************************************************************************************************
 Name:	  AV_DeleteRecordsAccountBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch de borrado de Cuentas cuando el campo To Delete está marcado
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			App FSC				Maria Telleria		23/04/2020			Init version
	2.0			App FSC				Esperanza Conde		24/07/2020			Include LastModifiedDate = LAST_N_DAYS:7 in the query
	2.1			App FSC				Carolina Alonso		26/10/2020			Delete OrderBy in the query and Include RT
	2.4			App FSC				Sandra Gómez		02/12/2020			Improve the limit query: dynamic limit query
	2.5			App FSC				Esperanza Conde		18/12/2020			Include false in Delete method.
	2.6			Hotfix IOP Enero	Carolina Alonso		02/02/2021			Delete LastModifiedDate in the query
	2.7			FIX					David Rufo			31/05/2021			Use the Query FWK
	2.8			FIX					David Rufo			22/06/2021			Use the number of days via Custom Metadata
	2.9		    AV_Query IT	        Daniel Rodríguez	04/02/2022	        Change AV_Query to SOQL for User and Account

***********************************************************************************************************************/
global class AV_DeleteRecordsAccountBatch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {

	global Integer recordsProcessed = 0;
	global static final String BATCHNAME = 'AV_DeleteAccounts';
    
    private String avQuery;
	
    public AV_DeleteRecordsAccountBatch(){
        avQuery = setQuery();
    }

    public AV_DeleteRecordsAccountBatch(String avQuery){
        this.avQuery = avQuery;
    }
    
    private String setQuery(){
		Set<String> setRt = new Set<String>{AV_AppConstants.ACCOUNT_PA_RT,AV_AppConstants.ACCOUNT_ENT_RT};
        List<String> listRTs = AV_AppUtilities.getListFromSet(setRt);
        Integer numDays = AV_SchedulerBatches.getNumDays(BATCHNAME);
		String batchLimit = AV_SchedulerBatches.getLimit(BATCHNAME);
        /*AV_Query avQuery = new AV_Query('Account')
                                    .selectFields('Id, AV_ToDelete__c')
                                    .addConditionEq('AV_ToDelete__c', true)
            						.addConditionEq('SystemModstamp', AV_Query.LAST_N_DAYS(numDays))
                                    .addConditionIn('RecordType.DeveloperName', setRt);
		
		if(String.isNotBlank(batchLimit)){
			avQuery.setLimit(Integer.valueOf(batchLimit));
		}*/
        
		if(String.isNotBlank(batchLimit)){
			avQuery = 'Select Id, AV_ToDelete__c From Account Where SystemModstamp = LAST_N_DAYS:'+ numDays+ ' and RecordType.DeveloperName in ' +listRTs+' and AV_ToDelete__c = true limit '+ batchLimit+' ';
		}else{
			avQuery = 'Select Id, AV_ToDelete__c From Account Where SystemModstamp = LAST_N_DAYS:'+ numDays+ ' and RecordType.DeveloperName in ' +listRTs+' and AV_ToDelete__c = true';
		}
            
        return avQuery;
    }
    
	/**
	 * Delete the selected list of Accounts
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		String methodName = 'start';
        if(avQuery==null){
            avQuery = setQuery();
        }
		
		AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);
        return Database.getQueryLocator(avQuery);

		//return avQuery.getQueryLocator();
	}
		
	/**
	 * Delete the selected list of Accounts where the field AV_ToDelete__c is checked.
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Account> param with the list of Accounts to delete
	 */
	global void execute(Database.BatchableContext bc, List<Account> scope){
		// Procesar cada batch de registros
		String methodName = 'execute';
		try{
			recordsProcessed = scope.size();
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
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new AV_DeleteRecordsAccountBatch());
	}
		

	/**
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	global void finish(Database.BatchableContext bc){
		String methodName='finish';
		AV_LogDebug.printLogDebug(methodName, 'Record Processes: ' + recordsProcessed);
	}	
}