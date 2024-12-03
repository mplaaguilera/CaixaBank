/**********************************************************************************************************************
 Name:	  AV_OpportunityStatusBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para cambiar el estado de las Oportunidades en estado recomendada, en gestión, insistir o en 
espera de cliente y con fecha vencimiento, CUANDO llegue la fecha de vencimiento el estado
cambiará  a vencida 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Esperanza Conde		19/10/2020			Init version
  	1.1			App FSC		  	Sandra Gómez		02/12/2020			Improve the limit query: dynamic limit query
	1.2			FIX				David Rufo			18/05/2021			Improve query execution
	1.3			FIX				David Rufo			31/05/2021			Query changed because has problems in PROD
	1.4			Org Health		Carolina Alonso		17/03/2022			Add condition to retrieve only registers with CloseDate in the last 15 days
	1.5			Fix				Sandra Gómez		22/03/2022			Add AV_AppUtilities.setToStringIn
	1.6			US384943		Víctor Santiago		27/05/2022			Query optimized
	1.7			US534659		Vladislav Lityagin	22/02/2022			Added new RT CallMe and rest of RTs
	1.8			US582623		Luis Fernández		10/05/2023			Modified batch query 
***********************************************************************************************************************/
global class AV_OpportunityStatusBatch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
	
	global Integer recordsProcessed = 0;
    private static final String STATUS_DEFEAT 	= 'Vencido';
	global static final String BATCHNAME = 'AV_OpportunityStatusBatch';
    private String avQuery;
	
    public AV_OpportunityStatusBatch(){
        avQuery = setQuery();
    }

    public AV_OpportunityStatusBatch(String avQuery){
        this.avQuery = avQuery;
    }
    
    private String setQuery(){
        Set<String> setStage = new Set<String>{AV_AppConstants.OPP_STATUS_POTENCIAL, AV_AppConstants.OPP_STATUS_ENGESTION};
		String iniciativaId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT).Id;
		String alertaId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPALERTACOM_RT).Id;
        String callMeId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPLLAMADA_RT).Id;
        String propuestaId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPPROPUESTA_RT).Id;
        String sugerenciaId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPSUGERENCIA_RT).Id;
		String rts = AV_AppUtilities.setToStringIn(new Set<String>{iniciativaId,alertaId,callmeId,propuestaId,sugerenciaId});
        User adobeUser = [
			SELECT Id
			FROM User
			WHERE Alias = 'adob'
			LIMIT 1
		];

		
        String limitBatch = AV_SchedulerBatches.getLimit(BATCHNAME);
        Integer numDays = AV_SchedulerBatches.getNumDays(BATCHNAME);
        String listStage = AV_AppUtilities.setToStringIn(setStage);
		String query = 'SELECT Id, StageName, RecordType.DeveloperName FROM Opportunity WHERE CloseDate = LAST_N_DAYS:' + numDays + ' AND CloseDate < TODAY ';
		// String query = 'SELECT Id, StageName, RecordType.DeveloperName FROM Opportunity WHERE CloseDate = LAST_N_DAYS:' + numDays + ' AND CloseDate < TODAY AND StageName IN ' + listStage;
		if (String.isNotBlank(adobeUser.Id)) {
			query += ' AND StageName IN ' + listStage + ' AND (RecordTypeId = \'' + iniciativaId + '\' OR RecordTypeId = \'' + callMeId + '\' OR (RecordTypeId = \'' + alertaId + '\' AND CreatedById = \'' + adobeUser.Id + '\'))';
			// query += ' AND (RecordTypeId = \'' + iniciativaId + '\' OR RecordTypeId = \'' + callMeId + '\' OR (RecordTypeId = \'' + alertaId + '\' AND CreatedById = \'' + adobeUser.Id + '\'))';
		} else {
			// query += ' AND (RecordTypeId = \'' + iniciativaId + '\' OR RecordTypeId = \'' + callMeId + '\')';
			query += ' AND RecordTypeId IN '+rts+' AND StageName = \'' + AV_AppConstants.OPP_STATUS_ENGESTION +'\'';
		}
		if (String.isNotBlank(limitBatch)) {
            query += ' LIMIT ' + Integer.valueOf(limitBatch);
		}
        return query;
    }
    
	/**
	 * Create a list of Opportunities that due date less than today and status equal manage or wait.
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
	}

	/**
	 * Update the Status of selected Task
	 *
	 * @param bc		Database.BatchableContext param that contains the batch job ID
	 * @param listTask 	List<Task> param with the list of Task to update.
	 */
	global void execute(Database.BatchableContext bc, List<Opportunity> listOpp){
		// Procesar cada batch de registros
		String methodName = 'execute';
		try{
			recordsProcessed = listOpp.size();
			AV_LogDebug.printLogDebug(methodName,'Data does not have a final state with a due date earlier than today: ' + listOpp.size());
			List<Opportunity> listOppToUpdate = new List<Opportunity>();
			for(Opportunity opp : listOpp){
				String recordTypeDeveloperName = opp.RecordType.DeveloperName;
				opp.StageName = STATUS_DEFEAT;
				listOppToUpdate.add(opp);
			}
			
			//Update Opportunities
			if(listOppToUpdate!=null && !listOppToUpdate.isEmpty()){
				AV_LogDebug.printLogDebug(methodName,'Records updated: ' + listOppToUpdate.size());
                List<Database.SaveResult> listUpdateResult = Database.update(listOppToUpdate, false);
				AV_AppUtilities.displayErrors(methodName, listUpdateResult);
			}
		}catch(System.Exception e){
			AV_LogDebug.printLogDebug(methodName, 'Error: ' +e);
		}
	}	

	/**
	 * Executes the scheduled Apex job
	 *
	 * @param sc	SchedulableContext param that contains the job ID
	 */
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new AV_OpportunityStatusBatch());
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