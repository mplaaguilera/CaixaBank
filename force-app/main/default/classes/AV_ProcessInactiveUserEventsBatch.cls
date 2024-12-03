/**********************************************************************************************************************
 Name:	  AV_ProcessInactiveUserEventsBatch
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para cambiar el ownerId de los eventos de un usuario inactivo
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US306420		Víctor Santiago     16/12/2021			Init version
	1.1         US306420		Sandra Gómez        21/01/2022			Fix
	1.2		    AV_Query IT		Daniel Rodríguez	3/02/2022			Change AV_Query to SOQL for User and Account
	1.3 		US592987		Ángel Medina		30/05/2023			Changed AV_Query to SOQL queries

***********************************************************************************************************************/
global class  AV_ProcessInactiveUserEventsBatch implements Database.Batchable<sObject>, Database.Stateful {

	global Integer recordsProcessed = 0;
	global String limitBatch;
	global Set<String> setUserIds;

	private static AV_AppUtilities.SearchRT rtEventoCliente 	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTCLIENTE_RT);
	private static AV_AppUtilities.SearchRT rtEventoGestor		= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTGESTOR_RT);
	private static Set<Id> setRtAll 		= getAllRT();
	
	global AV_ProcessInactiveUserEventsBatch(String limitQuery, Set<String> userId) {
		limitBatch = limitQuery;
		setUserIds = new Set<String>();
		setUserIds.addAll(userId);
	}

	global AV_ProcessInactiveUserEventsBatch() {}
	
	/**
	 * Get a list of Events to process the owners

	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	global Database.QueryLocator start(Database.BatchableContext bc) {

		String methodName = 'start';
		AV_LogDebug.printLogDebug(methodName, 'Batch limit: ' + limitBatch);
		AV_LogDebug.printLogDebug(methodName, 'List users ids: ' + setUserIds);

		String avQuery = 'SELECT Id, OwnerId, RecordType.DeveloperName, ActivityDate, AV_ExternalID__c FROM Event  WHERE RecordTypeId IN :setRtAll  AND OwnerId IN ' + AV_AppUtilities.setToStringIn(setUserIds);
		if(String.isNotBlank(limitBatch)){
			avQuery += ' LIMIT ' + Integer.valueOf(limitBatch);
		}
		
		AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);
		return Database.getQueryLocator(avQuery);

	
	}

	/**
	 * Updates OwnerId of EventosConCliente that are closed, as well as the owner of its headers and tareas-opp.
	 * Deletes them if they're EventosGestorA or any kind of event that remains open.
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Event> param with the list of Events
	 */
	global void execute(Database.BatchableContext bc, List<Event> scope){
		// Procesar cada batch de registros

		String methodName = 'execute';
		try{
			AV_LogDebug.printLogDebug(methodName,'Data to check: ' + scope.size());
			recordsProcessed = scope.size();
			List<Event> listDataToUpdate = new List<Event>();
			List<Event> listDataToDelete = new List<Event>();
			Map<String, AV_HeaderCustomActivity__c> headersMap = new Map<String, AV_HeaderCustomActivity__c>();
			List<AV_HeaderCustomActivity__c> headersToUpdate = new List<AV_HeaderCustomActivity__c>();
			List<AV_HeaderCustomActivity__c> headersToDelete = new List<AV_HeaderCustomActivity__c>();
			Map<String, List<AV_CustomActivityOpportunity__c>> tareasOpsMap = new Map<String, List<AV_CustomActivityOpportunity__c>>();
			List<AV_CustomActivityOpportunity__c> tareaOpsToUpdate = new List<AV_CustomActivityOpportunity__c>();
			List<AV_CustomActivityOpportunity__c> tareaOpsToDelete = new List<AV_CustomActivityOpportunity__c>();
			User userGcf = [Select Id From User Where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
			List<AV_HeaderCustomActivity__c> headers = getCabeceraTareaAsociada(scope);
			if (!headers.isEmpty()) {
				for (AV_HeaderCustomActivity__c h : headers) {
					headersMap.put(h.AV_ExternalID__c, h);
				}
				List<AV_CustomActivityOpportunity__c> tareasOps = getTareaOppAsociada(headers);
				if (!tareasOps.isEmpty()) {
					for (AV_CustomActivityOpportunity__c to : tareasOps) {
						if(!tareasOpsMap.containsKey(to.AV_Task__c)) {
							tareasOpsMap.put(to.AV_Task__c, new List<AV_CustomActivityOpportunity__c>{to});
						} else {
							tareasOpsMap.get(to.AV_Task__c).add(to);
						}
					}
				}
			}
			
			for (Event data : scope) {
				// To be deleted
				if (rtEventoGestor.equals(data.RecordType.DeveloperName) || data.ActivityDate >= System.today()) {
					// Events
					listDataToDelete.add(data);
					if ('AV_EventosConCliente'.equals(data.RecordType.DeveloperName) && data.AV_ExternalID__c != null) {
						// Headers
						headersToDelete.add(headersMap.get(data.AV_ExternalID__c));
						// Tareas-Oportunidad
						if (!tareasOpsMap.get(headersMap.get(data.AV_ExternalID__c).Id).isEmpty()) {
							for (AV_CustomActivityOpportunity__c taopp : tareasOpsMap.get(headersMap.get(data.AV_ExternalID__c).Id)) {
								tareaOpsToDelete.add(taopp);
							}
						}
					}
				} else {
					// To be updated
					// Events
					data.OwnerId = userGcf.Id;
					listDataToUpdate.add(data);
					if (data.AV_ExternalID__c != null && headersMap.get(data.AV_ExternalID__c) != null) {
						// Headers
						headersMap.get(data.AV_ExternalID__c).OwnerId = userGcf.Id;
						headersToUpdate.add(headersMap.get(data.AV_ExternalID__c));
						// Tareas-Oportunidad
						if (tareasOpsMap.get(headersMap.get(data.AV_ExternalID__c).Id) != null) {
							for (AV_CustomActivityOpportunity__c taopp : tareasOpsMap.get(headersMap.get(data.AV_ExternalID__c).Id)) {
								taopp.OwnerId = userGcf.Id;
								tareaOpsToUpdate.add(taopp);
							}
						}
					}
				}
			} 
			// Update tarea oportunidad
			if (!tareaOpsToUpdate.isEmpty()) {
				AV_LogDebug.printLogDebug(methodName,'Tareas-Oportunidad for update: ' + tareaOpsToUpdate.size());
				Database.update(tareaOpsToUpdate, false);
			}
			// Update Events
			if(!listDataToUpdate.isEmpty()) {
				AV_LogDebug.printLogDebug(methodName,'Events for update: ' + listDataToUpdate.size());
				recordsProcessed = listDataToUpdate.size();
				Database.update(listDataToUpdate, false);
			}
			// Update Cabecera tarea
			if(!headersToUpdate.isEmpty()) {
				AV_LogDebug.printLogDebug(methodName,'Headers for update: ' + headersToUpdate.size());
				Database.update(headersToUpdate, false);
			}
			// Delete tarea oportunidad
			if (!tareaOpsToDelete.isEmpty()) {
				AV_LogDebug.printLogDebug(methodName,'Tareas-Oportunidad for delete: ' + tareaOpsToDelete.size());
				Database.delete(tareaOpsToDelete, false);
			}
			// Delete Events
			if(!listDataToDelete.isEmpty()) {
				AV_LogDebug.printLogDebug(methodName,'Events for update: ' + listDataToDelete.size());
				Database.delete(listDataToDelete, false);
			}
			// Delete Cabecera tarea
			if(!headersToDelete.isEmpty()) {
				AV_LogDebug.printLogDebug(methodName,'Headers for update: ' + headersToDelete.size());
				Database.delete(headersToDelete, false);
			}
		} catch(System.Exception e) {
			AV_LogDebug.printException(methodName, e);
		}
	}

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
		CBK_BatchJob.executeBatch('AV_ProcessInactiveUserOpportunitiesBatch', 200, params);
	}

	/**
	 * Gets the headers related to the events being passed
	 * @param listEventos -> event list
	 * @return	header list
	 */
	private static List<AV_HeaderCustomActivity__c> getCabeceraTareaAsociada(List<Event> listEventos) {
		Set<String> evtsExtIds = new Set<String>();
		for (Event e : listEventos) {
			if (e.AV_ExternalID__c != null) {
				evtsExtIds.add(e.AV_ExternalID__c);
			}
		}
		List<AV_HeaderCustomActivity__c> headers = [SELECT Id, AV_ExternalID__c, OwnerId FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c IN :evtsExtIds];
		return headers;
	}

	/**
	 * Gets the Tareas-Oportunidad related to the headers being passed
	 * @param listCabeceraTarea -> headers list
	 * @return tarea-oportunidad list
	 */
	private static List<AV_CustomActivityOpportunity__c> getTareaOppAsociada(List<AV_HeaderCustomActivity__c> listCabeceraTarea) {
		Set<String> headersIds = new Set<String>();
		List<AV_CustomActivityOpportunity__c> listTareasOportunidad = new List<AV_CustomActivityOpportunity__c>();
		for (AV_HeaderCustomActivity__c h : listCabeceraTarea) {
			headersIds.add(h.Id);
		}
		listTareasOportunidad = [SELECT Id, AV_Task__c, OwnerId FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c IN :headersIds];
		return listTareasOportunidad;	
	}

	/**
	 * @description		 	Get all the ID's of the RT
	 */
	public static Set<Id> getAllRT(){
		Set<AV_AppUtilities.SearchRT> setLabelsRt = new Set<AV_AppUtilities.SearchRT>{rtEventoCliente, rtEventoGestor};
		return AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
	}
}