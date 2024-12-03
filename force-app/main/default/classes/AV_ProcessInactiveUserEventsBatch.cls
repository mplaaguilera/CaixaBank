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
	1.4			Deuda técnica	Sandra Gómez		29/02/2024			Fix Time Out
***********************************************************************************************************************/
public class  AV_ProcessInactiveUserEventsBatch implements Database.Batchable<sObject>, Database.Stateful {

	public Integer recordsProcessed = 0;
	public String limitBatch;
	public Set<String> setUserIds;

	private static AV_AppUtilities.SearchRT rtEventoCliente 	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTCLIENTE_RT);
	private static AV_AppUtilities.SearchRT rtEventoGestor		= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTGESTOR_RT);
	private static Set<Id> setRtAll 		= getAllRT();
	
	public AV_ProcessInactiveUserEventsBatch(String limitQuery, Set<String> userId) {
		limitBatch = limitQuery;
		setUserIds = new Set<String>();
		setUserIds.addAll(userId);
	}

	public AV_ProcessInactiveUserEventsBatch() {}
	
	/**
	 * Get a list of Events to process the owners
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String methodName = 'start';
		AV_LogDebug.printLogDebug(methodName, 'Batch limit: ' + limitBatch);
		AV_LogDebug.printLogDebug(methodName, 'List users ids: ' + setUserIds);
		String avQuery = 'SELECT Id, OwnerId, RecordType.DeveloperName, ActivityDate, AV_ExternalID__c, AV_Task__c FROM Event  WHERE RecordTypeId IN :setRtAll  AND OwnerId IN ' + AV_AppUtilities.setToStringIn(setUserIds);
		if(String.isNotBlank(limitBatch)){
			avQuery += ' LIMIT ' + Integer.valueOf(limitBatch);
		}
		AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);
		return Database.getQueryLocator(avQuery);
	}

	/**
	 * Updates OwnerId of EventosConCliente that are closed, as well as the owner of its headers and tareas-opp.
	 * Deletes them if they're EventosGestorA or any kind of event that remains open.
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Event> param with the list of Events
	 */
	public void execute(Database.BatchableContext bc, List<Event> scope){
		String methodName = 'execute';
		try{
			AV_LogDebug.printLogDebug(methodName,'Data to check: ' + scope.size());
			recordsProcessed = scope.size();
			List<Event> listDataToUpdate = new List<Event>();
			List<Event> listDataToDelete = new List<Event>();
			List<AV_HeaderCustomActivity__c> headersToUpdate = new List<AV_HeaderCustomActivity__c>();
			List<AV_HeaderCustomActivity__c> headersToDelete = new List<AV_HeaderCustomActivity__c>();
			List<String> headerIdsToDelete = new List<String>();
			List<String> headerIdsToUpdate = new List<String>();
			List<String> headerIdsToUpdateDelete = new List<String>();
			List<AV_CustomActivityOpportunity__c> tareaOpsToUpdate = new List<AV_CustomActivityOpportunity__c>();
			List<AV_CustomActivityOpportunity__c> tareaOpsToDelete = new List<AV_CustomActivityOpportunity__c>();
			User userGcf = [Select Id From User Where Profile.Name = :AV_AppConstants.AV_PROFILE_APIONLY and Alias = :AV_AppConstants.AV_ALIAS_AVTF9 and IsActive = true limit 1];
			for (Event data : scope) {
				if (rtEventoGestor.equals(data.RecordType.DeveloperName) || data.ActivityDate >= System.today()) { // To be deleted
					listDataToDelete.add(data);
					if (AV_AppConstants.EVENTCLIENTE_RT.equals(data.RecordType.DeveloperName) && data.AV_ExternalID__c != null) {
						AV_HeaderCustomActivity__c hca = new AV_HeaderCustomActivity__c();
						hca.Id = data.AV_Task__c;
						headersToDelete.add(hca);
						headerIdsToDelete.add(data.AV_Task__c);
						headerIdsToUpdateDelete.add(data.AV_Task__c);
					}
				} else { // To be updated
					data.OwnerId = userGcf.Id;
					listDataToUpdate.add(data);
					if (data.AV_ExternalID__c != null && data.AV_Task__c != null) {
						AV_HeaderCustomActivity__c hca = new AV_HeaderCustomActivity__c();
						hca.Id = data.AV_Task__c;
						hca.OwnerId = userGcf.Id;
						headersToUpdate.add(hca);
						headerIdsToUpdate.add(data.AV_Task__c);
						headerIdsToUpdateDelete.add(data.AV_Task__c);
					}
				}
			}
			if (headerIdsToUpdateDelete != null && !headerIdsToUpdateDelete.isEmpty()) {
				List<AV_CustomActivityOpportunity__c> listTaskOpp = [SELECT Id, AV_Task__c, OwnerId FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c IN :headerIdsToUpdateDelete];
				if (listTaskOpp != null && !listTaskOpp.isEmpty()) {
					for (AV_CustomActivityOpportunity__c cao : listTaskOpp) {
						if (headerIdsToDelete.contains(cao.AV_Task__c)) {
							tareaOpsToDelete.add(cao);
						} else if (headerIdsToUpdate.contains(cao.AV_Task__c)) {
							cao.OwnerId = userGcf.Id;
							tareaOpsToUpdate.add(cao);
						}
					}
				}
			}
			if (!tareaOpsToUpdate.isEmpty()) { // Update tarea-oportunidad
				AV_LogDebug.printLogDebug(methodName,'Tareas-Oportunidad for update: ' + tareaOpsToUpdate.size());
				Database.update(tareaOpsToUpdate, false);
			}
			if(!listDataToUpdate.isEmpty()) { // Update Events
				AV_LogDebug.printLogDebug(methodName,'Events for update: ' + listDataToUpdate.size());
				recordsProcessed = listDataToUpdate.size();
				Database.update(listDataToUpdate, false);
			}
			if(!headersToUpdate.isEmpty()) { // Update Cabecera tarea
				AV_LogDebug.printLogDebug(methodName,'Headers for update: ' + headersToUpdate.size());
				Database.update(headersToUpdate, false);
			}
			if (!tareaOpsToDelete.isEmpty()) { // Delete tarea oportunidad
				AV_LogDebug.printLogDebug(methodName,'Tareas-Oportunidad for delete: ' + tareaOpsToDelete.size());
				Database.delete(tareaOpsToDelete, false);
			}
			if(!listDataToDelete.isEmpty()) { // Delete Events
				AV_LogDebug.printLogDebug(methodName,'Events for update: ' + listDataToDelete.size());
				Database.delete(listDataToDelete, false);
			}
			if(!headersToDelete.isEmpty()) { // Delete Cabecera tarea
				AV_LogDebug.printLogDebug(methodName,'Headers for update: ' + headersToDelete.size());
				Database.delete(headersToDelete, false);
			}
		} catch(System.Exception e) {
			AV_LogDebug.printException(methodName, e);
		}
	}

	/**
	 * Print the results of the batch process
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	public void finish(Database.BatchableContext bc){
		String methodName='finish';
		AV_LogDebug.printLogDebug(methodName, 'Record Processes: ' + recordsProcessed);

		map<String,Object> params = new map<String,Object>();
		params.put('limitBatch',limitBatch);
		params.put('setUserIds',setUserIds);
		CBK_BatchJob.executeBatch('AV_ProcessInactiveUserOpportunitiesBatch', 200, params);
	}

	/**
	 * @description		 	Get all the ID's of the RT
	 */
	public static Set<Id> getAllRT(){
		Set<AV_AppUtilities.SearchRT> setLabelsRt = new Set<AV_AppUtilities.SearchRT>{rtEventoCliente, rtEventoGestor};
		return AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
	}
}