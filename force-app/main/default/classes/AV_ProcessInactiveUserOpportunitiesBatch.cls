/**********************************************************************************************************************
 Name:	  AV_ProcessInactiveUserOpportunitiesBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para cambiar el ownerId de un gestor inactivo al Asesor de Ventas.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR					DATE				Description
	1.0			US306420		Sandra Gómez		    16/12/2021			Init version
	1.1         US306420		Sandra Gómez        	21/01/2022			Fix
	1.2			AV_Query IT		Daniel Rodríguez	    3/02/2022			Change AV_Query to SOQL for User and Account
	1.3         US592987		Ángel Medina			30/05/2023			Changed AV_Query to SOQL queries

***********************************************************************************************************************/
global with sharing class AV_ProcessInactiveUserOpportunitiesBatch implements Database.Batchable<sObject>, Database.Stateful {
	global Integer recordsProcessed = 0;
	global String limitBatch;
	global Set<String> setUserIds;

	private static AV_AppUtilities.SearchRT rtAlertaComercial 	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPALERTACOM_RT);
	private static AV_AppUtilities.SearchRT rtIniciativa 		= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
    private static AV_AppUtilities.SearchRT rtPropuesta 		= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPPROPUESTA_RT);
    private static AV_AppUtilities.SearchRT rtSugerencia 		= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPSUGERENCIA_RT);
	private static Set<Id> setRtAll 		= getAllRT();
	
	global AV_ProcessInactiveUserOpportunitiesBatch(String limitQuery, Set<String> userId) {
		limitBatch = limitQuery;
		setUserIds = new Set<String>();
		setUserIds.addAll(userId);
	}

	global AV_ProcessInactiveUserOpportunitiesBatch() {}
	
	/**
	 * Get a list of Opportunities to process the owners
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		String methodName = 'start';
		AV_LogDebug.printLogDebug(methodName, 'Batch limit: ' + limitBatch);
		AV_LogDebug.printLogDebug(methodName, 'List users ids: ' + setUserIds);
		
			String avQuery = 'SELECT Id, OwnerId, AV_Gestor__r.AV_UsuarioAsociado__c FROM Opportunity WHERE RecordTypeId IN :setRtAll AND OwnerId IN ' + AV_AppUtilities.setToStringIn(setUserIds);

		
		if(String.isNotBlank(limitBatch)){
			avQuery += ' LIMIT ' + Integer.valueOf(limitBatch);
		}
		
		AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);
		return Database.getQueryLocator(avQuery);

	}

	/**
	 * Update account OwnerId
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Account> param with the list of Accounts
	 */
	global void execute(Database.BatchableContext bc, List<Opportunity> scope){
		// Procesar cada batch de registros
		String methodName = 'execute';
		try{
			AV_LogDebug.printLogDebug(methodName, 'Data to check: ' + scope.size());
			recordsProcessed = scope.size();
			User userGcf = [Select Id From User Where Profile.Name = 'API Only' and Alias = 'AV-TF9' limit 1];
			
			List<Opportunity> listDataToUpdate = new List<Opportunity>();
			for(Opportunity data : scope) {
				data.OwnerId = userGcf.Id;
				listDataToUpdate.add(data);
			}
			getTareaOppAsociada(listDataToUpdate,userGcf.Id);
			AV_LogDebug.printLogDebug(methodName, 'Data to update opp: ' + listDataToUpdate.size());
			recordsProcessed = listDataToUpdate.size();
			//Database.update(listDataToUpdate, false);
			List<Database.SaveResult> updateResults = Database.update(listDataToUpdate, false);
			AV_AppUtilities.displayErrors(methodName, updateResults);
		}catch(System.Exception e){
			AV_LogDebug.printException(methodName, e);
		}
	}

	/**
	 * Executes the scheduled Apex job
	 *
	 * @param sc	SchedulableContext param that contains the job ID
	 */
	/*global void execute(SchedulableContext sc) {
		Database.executeBatch(new AV_ProccessAccountsOwnersBatch(limitBatch, setUserIds));
	}*/

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
		CBK_BatchJob.executeBatch('AV_ProcessInactiveUserNotifyMeBatch', 200 ,params);
	}

	/**
	 * Cambiar OwnerId a todas las tarea-Oportunidad asociadas a las oportunidades.
	 * @param listOpp -> lista de Oportunidades que se van a cambiar de OwnerId
	 * @param iduserGcf -> Id de Asesor de Ventas
	 */
	private static void getTareaOppAsociada(List<Opportunity> listOpp, String iduserGcf){
		List<AV_CustomActivityOpportunity__c> listTareaOportunidadProcess = new List<AV_CustomActivityOpportunity__c>();
		String methodName = 'execute';
		try{
			listTareaOportunidadProcess = [SELECT Id, AV_ExternalID__c,OwnerId FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c IN :listOpp];
			
			if(listTareaOportunidadProcess != null && !listTareaOportunidadProcess.isEmpty()){
				List<AV_CustomActivityOpportunity__c> listTareaOportunidadToUpdate = new List<AV_CustomActivityOpportunity__c>();
				for(AV_CustomActivityOpportunity__c data : listTareaOportunidadProcess) {
					if (data.OwnerId != iduserGcf) {
						data.OwnerId = iduserGcf;
						listTareaOportunidadToUpdate.add(data);
					}
				}
				if (!listTareaOportunidadToUpdate.isEmpty()) {
					AV_LogDebug.printLogDebug(methodName,'Data for change ownerid of AV_CustomActivityOpportunity__c: ' + listTareaOportunidadToUpdate.size());
					Database.update(listTareaOportunidadToUpdate, false);
				}
			}
		}catch(System.Exception e){
			AV_LogDebug.printException(methodName, e);
		}		
	}

	/**
	 * @description		 	Get all the ID's of the RT
	 */
    public static Set<Id> getAllRT(){
        Set<AV_AppUtilities.SearchRT> setLabelsRt = new Set<AV_AppUtilities.SearchRT>{rtAlertaComercial, rtIniciativa, rtPropuesta, rtSugerencia};
		return AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
    }
}