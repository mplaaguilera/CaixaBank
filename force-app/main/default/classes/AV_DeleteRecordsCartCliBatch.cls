/**********************************************************************************************************************
 Name:	  AV_DeleteRecordsCartCliBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch de borrado de Cartera Cliente cuando el campo To Delete está marcado
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			App FSC				Maria Telleria		23/04/2020			Init version
	2.0			App FSC				Esperanza Conde		24/07/2020			Include LastModifiedDate = LAST_N_DAYS:7 in the query
	2.1			App FSC				Carolina Alonso		26/10/2020			Delete OrderBy in the query and Include RT
	2.3			App FSC				Sandra Gómez		04/11/2020			Modify method finish
	2.4			App FSC				Sandra Gómez		02/12/2020			Improve the limit query: dynamic limit query
	2.5			App FSC				Esperanza Conde		18/12/2020			Include false in Delete method.
	2.6			App FSC				Sandra Gómez		01/02/2021			Include enqueueJob
	2.7			Hotfix IOP Enero	Carolina Alonso		02/02/2021			Delete LastModifiedDate in the query
	2.8			FIX					David Rufo			31/05/2021			Use the Query FWK
	2.9			FIX					David Rufo			22/06/2021			Use the number of days via Custom Metadata
	3.0		    AV_Query IT	        Daniel Rodríguez    09/02/2022	        Change AV_Query to SOQL for User, Account, Contact
    3.1		    FIX11070844	        Oscar Moreno		   22/07/2024			Fix error The Global modifier should be avoided.
***********************************************************************************************************************/
public class AV_DeleteRecordsCartCliBatch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
	
	public Integer recordsProcessed = 0;
	public static final String BATCHNAME = 'AV_DeleteCarteraCliente';

    /*private AV_Query avQuery;
	
    public AV_DeleteRecordsCartCliBatch(){
        avQuery = setQuery();
    }

    public AV_DeleteRecordsCartCliBatch(AV_Query avQuery){
        this.avQuery = avQuery;
    }
    
    private AV_Query setQuery(){
        Set<String> setRt = new Set<String>{'AV_CarteraCliente'};

        Integer numDays = AV_SchedulerBatches.getNumDays(BATCHNAME);
        AV_Query avQuery = new AV_Query('AV_BookMember__c')
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
	 * Delete the selected list of Cartera-Cliente where the field AV_ToDelete__c is checked.
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String methodName = 'start';
		String avQuery = '';
		List<String> newsetRt = new List<String>();
		Set<String> setRt = new Set<String>{'AV_CarteraCliente'};
		String limitBatch = AV_SchedulerBatches.getLimit(BATCHNAME);
		Integer numDays = AV_SchedulerBatches.getNumDays(BATCHNAME);

		for(String rt : setRt){
			newSetRt.add('\''+rt+'\'');
		}

		if(String.isNotBlank(limitBatch)){
			avQuery = 'Select Id, AV_ToDelete__c FROM AV_BookMember__c where AV_ToDelete__c = true and SystemModstamp = LAST_N_DAYS:'+numDays+' and RecordType.DeveloperName in '+newsetRt+' limit '+ Integer.valueOf(limitBatch)+' ';
		}else{
			avQuery = 'Select Id, AV_ToDelete__c FROM AV_BookMember__c where AV_ToDelete__c = true and SystemModstamp = LAST_N_DAYS:'+numDays+' and RecordType.DeveloperName in '+newsetRt+' ';

		}

		AV_LogDebug.printLogDebug(methodName, 'Next delete job: \'AV_DeleteRecordsCartGesBatchQueueable\'');
		System.enqueueJob(new AV_DeleteRecordsCartGesBatchQueueable());
		
		AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);
        return Database.getQueryLocator(avQuery);

        /*if(avQuery==null){
            avQuery = setQuery();
        }
        AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery.toQueryString());
        
          //Enqueue the next delete batch
		  AV_LogDebug.printLogDebug(methodName, 'Next delete job: \'AV_DeleteRecordsCartGesBatchQueueable\'');
		  System.enqueueJob(new AV_DeleteRecordsCartGesBatchQueueable());
		
		return avQuery.getQueryLocator();*/
	}
		
	/**
	 * Delete the selected list of 	AV_BookMember__c
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<AV_BookMember__c> param with the list of Book Members to delete
	 */
	public void execute(Database.BatchableContext bc, List<AV_BookMember__c> scope){
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
		Database.executeBatch(new AV_DeleteRecordsCartCliBatch());
	}

	/**
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	public void finish(Database.BatchableContext bc){
		String methodName='finish';
		AV_LogDebug.printLogDebug(methodName, 'Record Processes: ' + recordsProcessed);
		//Database.executeBatch(new AV_DeleteRecordsCarteraGestorBatch ());
	}	
}