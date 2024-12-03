/**********************************************************************************************************************
 Name:	  AV_DeleteRecordsEventBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch de borrado de Eventos cuando el campo To Delete está marcado
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE			Description
	1.0			App FSC				Carolina Alonso		05/04/2020		Init version
	2.0			App FSC				Esperanza Conde		24/07/2020		Include LastModifiedDate = LAST_N_DAYS:7 in the query
	3.0			App FSC				Carolina Alonso		01/09/2020		Include logic to remove the associated records from AV_HeaderCustomActivity__c
	3.1			App FSC				Carolina Alonso		28/09/2020		Delete order by in query
	3.2			App FSC				Carolina Alonso		28/09/2020		Replace old RTs with new ones
	3.2			App FSC				Sandra Gómez		04/11/2020		Modify method finish
	3.3			App FSC				Sandra Gómez		02/12/2020		Improve the limit query: dynamic limit query
	3.4			App FSC				Esperanza Conde		18/12/2020		Include false in Delete method.
	3.5			App FSC				Sandra Gómez		01/02/2021		Include enqueueJob
	3.6			Hotfix IOP Enero	Carolina Alonso		02/02/2021		Delete LastModifiedDate in the query and delete old RT
	3.9			Fix					David Rufo			16/03/2021		Delete header-task before delete event
	4.0			FIX					David Rufo			31/05/2021		Use the Query FWK
	4.1			FIX					David Rufo			22/06/2021		Use the number of days via Custom Metadata
	4.2		    AV_Query IT	        Daniel Rodríguez    03/03/2022	        Change AV_Query to SOQL for User, Account, Contact

***********************************************************************************************************************/
global class AV_DeleteRecordsEventBatch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
	
	global Integer recordsProcessed = 0;
	global static final String BATCHNAME = 'AV_DeleteEvents';
	
    /*private AV_Query avQuery;
	
    public AV_DeleteRecordsEventBatch(){
        avQuery = setQuery();
    }

    public AV_DeleteRecordsEventBatch(AV_Query avQuery){
        this.avQuery = avQuery;
    }
    
    private AV_Query setQuery(){
        Set<String> setRt = new Set<String>{AV_AppConstants.EVENTCLIENTE_RT, AV_AppConstants.EVENTGESTOR_RT};
        
        Integer numDays = AV_SchedulerBatches.getNumDays(BATCHNAME);
        AV_Query avQuery = new AV_Query('Event')
                                    .selectFields('ID, AV_ToDelete__c, AV_Task__c, RecordTypeId')
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
	 * Delete the selected list of Events where the field AV_ToDelete__c is checked.
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		String methodName = 'start';
		String avQuery = '';
		List<String> newsetRt = new List<String>();
		Set<String> setRt = new Set<String>{AV_AppConstants.EVENTCLIENTE_RT, AV_AppConstants.EVENTGESTOR_RT};

		for(String rt : setRt){
			newSetRt.add('\''+rt+'\'');
		}

		Integer numDays = AV_SchedulerBatches.getNumDays(BATCHNAME);
		
		String limitBatch = AV_SchedulerBatches.getLimit(BATCHNAME);
		system.debug('@@newsetrt '+ newsetRt);
		if(String.isNotBlank(limitBatch)){
			avQuery = 'Select ID, AV_ToDelete__c, AV_Task__c, RecordTypeId FROM Event where AV_ToDelete__c = true and SystemModstamp = LAST_N_DAYS:'+numDays+' and RecordType.DeveloperName in '+newSetRt+' limit '+ Integer.valueOf(limitBatch)+' ';
		}else{
			avQuery = 'Select ID, AV_ToDelete__c, AV_Task__c, RecordTypeId FROM Event where AV_ToDelete__c = true and SystemModstamp = LAST_N_DAYS:'+numDays+' and RecordType.DeveloperName in '+newSetRt+' ';

		}
		//Enqueue the next delete batch
		AV_LogDebug.printLogDebug(methodName, 'Next delete job: \'AV_DeleteRecordsTaskOppBatchQueueable\'');
		System.enqueueJob(new AV_DeleteRecordsTaskOppBatchQueueable());

		AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);
        return Database.getQueryLocator(avQuery);


        /*if(avQuery==null){
            avQuery = setQuery();
        }
        AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery.toQueryString());
        
          //Enqueue the next delete batch
		  AV_LogDebug.printLogDebug(methodName, 'Next delete job: \'AV_DeleteRecordsTaskOppBatchQueueable\'');
		  System.enqueueJob(new AV_DeleteRecordsTaskOppBatchQueueable());
		
		return avQuery.getQueryLocator();*/
	}

	/**
	 * Delete the selected list of 	Activity
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param listEvents List<Event> param with the list of Eventos to delete
	 */
	global void execute(Database.BatchableContext bc, List<Event> scope){
		// Procesar cada batch de registros
		String methodName = 'execute';
		try{
            //Eliminar primero todas las cabecera-tarea y tarea-oportunidad asociados al evento
			List<String> listCabeceraTareaToDelete = getCabeceraTareaAsociada(scope);
			if(listCabeceraTareaToDelete != null && !listCabeceraTareaToDelete.isEmpty()){
				AV_LogDebug.printLogDebug(methodName,'Data for delete of AV_HeaderCustomActivity__c: ' + listCabeceraTareaToDelete.size());
				Database.delete(listCabeceraTareaToDelete,false);
			}	
		}catch(System.Exception e){
			AV_LogDebug.printException(methodName, e);
		}
        
        try{
            //Eliminar los eventos asociados
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
		Database.executeBatch(new AV_DeleteRecordsEventBatch());
	}

	/**
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	global void finish(Database.BatchableContext bc){
		String methodName='finish';
		AV_LogDebug.printLogDebug(methodName, 'Record Processes: ' + recordsProcessed);
		//Database.executeBatch(new AV_DeleteRecordsTaskOppBatch ());
	}
	
	/**
	 * Obtener todas las cabeceras-tareas asociadas a los Eventos que se van a eliminar.
	 * @param listTareas -> lista de Eventos que se van a eliminar
	 * @return	Lista de cabecera-tarea a eliminar
	 */
	private static List<String> getCabeceraTareaAsociada(List<Event> listEventos){
		List<String> listCabeceraTareaToDelete = new List<String>();
		
		//Obtenemos la lista de Cabecera-Tarea asociadas al Evento.
		for(Event evento: listEventos){
			//Comprobamos que el Evento tenga AV_Task__c.
			if(evento.AV_Task__c != null){
				listCabeceraTareaToDelete.add(evento.AV_Task__c);
			}
		}
		//Borramos todas las tarea-oportunidad asociadas a las cabecera-tarea que vamos a eliminar.
		if(listCabeceraTareaToDelete != null && !listCabeceraTareaToDelete.isEmpty()) {
			getTareaOppAsociada(listCabeceraTareaToDelete);
		}

		return listCabeceraTareaToDelete;
	}

	/**
	 * Eliminar todas las tarea-Oportunidad asociadas a las cabecera-tareas que se van a eliminar.
	 * @param listTareas -> lista de Cabecera-Tarea que se van a eliminar
	 */
	private static void getTareaOppAsociada(List<String> listCabeceraTarea){
		List<AV_CustomActivityOpportunity__c> listTareaOportunidadToDelete = new List<AV_CustomActivityOpportunity__c>();
		String methodName = 'getTareaOppAsociada';
		try{
			listTareaOportunidadToDelete = [Select Id, AV_ExternalID__c From AV_CustomActivityOpportunity__c Where AV_Task__c in :listCabeceraTarea];
			/*listTareaOportunidadToDelete = new AV_Query('AV_CustomActivityOpportunity__c')
				.selectFields('Id, AV_ExternalID__c')
				.addConditionIn('AV_Task__c', listCabeceraTarea)
				.run();*/
			
			if(listTareaOportunidadToDelete != null && !listTareaOportunidadToDelete.isEmpty()){
				AV_LogDebug.printLogDebug(methodName,'Data for delete of AV_CustomActivityOpportunity__c: ' + listTareaOportunidadToDelete.size());
				Database.delete(listTareaOportunidadToDelete);
			}
		}catch(System.Exception e){
			AV_LogDebug.printException(methodName, e);
		}		
	}
}