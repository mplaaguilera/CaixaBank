/**********************************************************************************************************************
 Name:	  AV_DeleteRecordsCarteraGestorBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch de borrado de Cartera Gestor cuando el campo To Delete está marcado
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			App FSC				Maria Telleria		23/04/2020			Init version
	2.0			App FSC				Esperanza Conde		24/07/2020			Include LastModifiedDate = LAST_N_DAYS:7 in the query
	2.1			App FSC				Carolina Alonso		26/10/2020			Delete OrderBy in the query and Include RT
	2.2			App FSC				Sandra Gómez		04/11/2020			Modify method finish
	2.3			App FSC				Sandra Gómez		02/12/2020			Improve the limit query: dynamic limit query
	2.4			App FSC				Esperanza Conde		18/12/2020			Include false in Delete method.
	2.5			App FSC				Sandra Gómez		01/02/2021			Include enqueueJob
	2.6			Hotfix IOP Enero	Carolina Alonso		02/02/2021			Delete LastModifiedDate in the query
	2.7			FIX					David Rufo			31/05/2021			Use the Query FWK
	2.8			FIX					David Rufo			22/06/2021			Use the number of days via Custom Metadata
	2.9		    AV_Query IT	        Daniel Rodríguez    03/03/2022	        Change AV_Query to SOQL for User, Account, Contact
	3.0         FIX28080841     Oscar Moreno        28/08/2024          Fix error The Global modifier should be avoided.

***********************************************************************************************************************/
public class AV_DeleteRecordsCarteraGestorBatch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
	
	public Integer recordsProcessed = 0;
	public static final String BATCHNAME = 'AV_DeleteCarteraGestor';
	
    /*private AV_Query avQuery;
	
    public AV_DeleteRecordsCarteraGestorBatch(){
        avQuery = setQuery();
    }

    public AV_DeleteRecordsCarteraGestorBatch(AV_Query avQuery){
        this.avQuery = avQuery;
    }
    
    private AV_Query setQuery(){
        Set<String> setRt = new Set<String>{'AV_CarteraGestor'};

        Integer numDays = AV_SchedulerBatches.getNumDays(BATCHNAME);
        AV_Query avQuery = new AV_Query('AV_BookManagementMember__c')
                                    .selectFields('Id, AV_ToDelete__c')
                                    .addConditionEq('AV_ToDelete__c', true)
            						.addConditionEq('SystemModstamp', AV_Query.LAST_N_DAYS(numDays))
                                    .addConditionIn('RecordType.DeveloperName', setRt);

		String batchLimit = AV_SchedulerBatches.getLimit(BATCHNAME);
		if(String.isNotBlank(batchLimit)){
			avQuery.setLimit(Integer.valueOf(batchLimit));
		}
            
        return avQuery;
    }*/
    
	/**
	 * Delete the selected list of Cartera-Gestor where the field AV_ToDelete__c is checked.
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String methodName = 'start';

		String avQuery = '';
		List<String> newsetRt = new List<String>();
		Set<String> setRt = new Set<String>{'AV_CarteraGestor'};

		for(String rt : setRt){
			newSetRt.add('\''+rt+'\'');
		}

		Integer numDays = AV_SchedulerBatches.getNumDays(BATCHNAME);
		
		String limitBatch = AV_SchedulerBatches.getLimit(BATCHNAME);
		system.debug('@@newsetrt '+ newsetRt);
		if(String.isNotBlank(limitBatch)){
			avQuery = 'Select Id, AV_ToDelete__c FROM AV_BookManagementMember__c where AV_ToDelete__c = true and SystemModstamp = LAST_N_DAYS:'+numDays+' and RecordType.DeveloperName in '+newSetRt+' limit '+ Integer.valueOf(limitBatch)+' ';
		}else{
			avQuery = 'Select Id, AV_ToDelete__c FROM AV_BookManagementMember__c where AV_ToDelete__c = true and SystemModstamp = LAST_N_DAYS:'+numDays+' and RecordType.DeveloperName in '+newSetRt+' ';
		}
		//Enqueue the next delete batch
		AV_LogDebug.printLogDebug(methodName, 'Next delete job: \'AV_DeleteRecordsCarteraBatchQueueable\'');
		System.enqueueJob(new AV_DeleteRecordsCarteraBatchQueueable());

		AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);
        return Database.getQueryLocator(avQuery);

        /*if(avQuery==null){
            avQuery = setQuery();
        }
        AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery.toQueryString());
        
          //Enqueue the next delete batch
		  AV_LogDebug.printLogDebug(methodName, 'Next delete job: \'AV_DeleteRecordsCarteraBatchQueueable\'');
		  System.enqueueJob(new AV_DeleteRecordsCarteraBatchQueueable());
		
		return avQuery.getQueryLocator();*/
	}
		
	/**
	 * Delete the selected list of 	AV_BookManagementMember__c
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<AV_BookManagementMember__c> param with the list of AV_BookManagementMember__c to delete
	 */
	public void execute(Database.BatchableContext bc, List<AV_BookManagementMember__c> scope){
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
		Database.executeBatch(new AV_DeleteRecordsCarteraGestorBatch());
	}

	/**
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	public void finish(Database.BatchableContext bc){
		String methodName='finish';
		AV_LogDebug.printLogDebug(methodName, 'Record Processes: ' + recordsProcessed);
		//Database.executeBatch(new AV_DeleteRecordsCarteraBatch ());
	}	
}