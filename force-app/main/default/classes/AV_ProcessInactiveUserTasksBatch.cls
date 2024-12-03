/**********************************************************************************************************************
 Name:	  AV_ProcessInactiveUserTasksBatch
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para cambiar el ownerId de las tareas de un usuario inactivo
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US306420		Víctor Santiago     16/12/2021			Init version
    1.1         US306420		Sandra Gómez        21/01/2022			Fix
    1.2		    AV_Query IT		Daniel Rodríguez	3/02/2022			Change AV_Query to SOQL for User and Account
    1.3         US592987		Ángel Medina		30/05/2023			Changed AV_Query to SOQL queries
***********************************************************************************************************************/
global class  AV_ProcessInactiveUserTasksBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    global Integer recordsProcessed = 0;
	global String limitBatch;
	global Set<String> setUserIds;

    private static AV_AppUtilities.SearchRT rtTareaIniciativa	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
	private static AV_AppUtilities.SearchRT rtTareaAlertaComencial	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKALERTACOM_RT);
    private static AV_AppUtilities.SearchRT rtTareaAvisos	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKAVISOS_RT);
    private static AV_AppUtilities.SearchRT rtTareaContactoGCF	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKCONTACTGCF_RT);
    private static AV_AppUtilities.SearchRT rtTareaExpCliente	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKEXPCLIENT_RT);
    private static AV_AppUtilities.SearchRT rtTareaOnboarding	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKONBOARDING_RT);
    private static AV_AppUtilities.SearchRT rtTareaPriorizador	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKPRIORIZADOR_RT);
    private static AV_AppUtilities.SearchRT rtTareaCPendiente	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKCPENDIENTE_RT);
    private static Set<Id> setRtAll 		= getAllRT();
    
    global AV_ProcessInactiveUserTasksBatch(String limitQuery, Set<String> userId) {
		limitBatch = limitQuery;
		setUserIds = new Set<String>();
        setUserIds.addAll(userId);
    }

    global AV_ProcessInactiveUserTasksBatch() {}
	
	/**
	 * Get a list of Tasks to process the owners
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	global Database.QueryLocator start(Database.BatchableContext bc) {
        String methodName = 'start';
		AV_LogDebug.printLogDebug(methodName, 'Batch limit: ' + limitBatch);
        AV_LogDebug.printLogDebug(methodName, 'List users ids: ' + setUserIds);
        Set<String> status = new Set<String>{AV_AppConstants.TASK_STATUS_PENDIENTE, AV_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL};
        
        String avQuery = 'SELECT Id, AV_CodigoGestorAsignado__c, OwnerId, AV_ExternalID__c FROM Task ';
        avQuery += ' WHERE RecordTypeId IN :setRtAll ';
        avQuery += ' AND Status IN ' + AV_AppUtilities.setToStringIn(status);
        avQuery += ' AND OwnerId IN ' + AV_AppUtilities.setToStringIn(setUserIds);
		
		if(String.isNotBlank(limitBatch)){
            avQuery += ' LIMIT ' + Integer.valueOf(limitBatch);
		}
		
        AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);
		return Database.getQueryLocator(avQuery);
	}

	/**
	 * Update Task OwnerId
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Task> param with the list of Tasks
	 */
	global void execute(Database.BatchableContext bc, List<Task> scope) {
        // Procesar cada batch de registros
		String methodName = 'execute';
        try {
            AV_LogDebug.printLogDebug(methodName,'Data to check: ' + scope.size());
            recordsProcessed = scope.size();
            List<Task> listDataToUpdate = new List<Task>();
            List<AV_CustomActivityOpportunity__c> listTareaOppUpdate = new List<AV_CustomActivityOpportunity__c>();
            User userGcf = [Select Id From User Where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
            
            for (Task data : scope) {
                data.OwnerId = userGcf.Id;
                listDataToUpdate.add(data);
            }
            List<AV_HeaderCustomActivity__c> headers = getCabeceraTareaAsociada(scope);
            if(!headers.isEmpty()) {
                for (AV_HeaderCustomActivity__c h : headers) {
                    h.OwnerId = userGcf.Id;
                }
                List<AV_CustomActivityOpportunity__c> tareaOps = getTareaOppAsociada(headers);
                if(!tareaOps.isEmpty()) {
                    for (AV_CustomActivityOpportunity__c to : tareaOps) {
                        if (to.OwnerId != userGcf.Id) {
                            to.OwnerId = userGcf.Id;
                            listTareaOppUpdate.add(to);
                        }
                    }
                }
            }

            if (!listTareaOppUpdate.isEmpty()) {
                AV_LogDebug.printLogDebug(methodName,'Tareas-Oportunidad for update: ' + listTareaOppUpdate.size());
                Database.update(listTareaOppUpdate, false);
            }
            if (!listDataToUpdate.isEmpty()) {
                AV_LogDebug.printLogDebug(methodName,'Tasks for update: ' + listDataToUpdate.size());
                recordsProcessed = listDataToUpdate.size();
                Database.update(listDataToUpdate, false);
            }
            if (!headers.isEmpty()) {
                AV_LogDebug.printLogDebug(methodName,'Headers for update: ' + headers.size());
                Database.update(headers, false);
            }
        } catch (System.Exception e) {
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
		params.put('limitBatch', limitBatch);
		params.put('setUserIds', setUserIds);
		CBK_BatchJob.executeBatch('AV_ProcessInactiveUserEventsBatch', 200, params);
    }

    /**
	 * Obtener todas las cabeceras-tareas asociadas a las tareas que se van a actualizar.
	 * @param listTareas -> lista de Tareas que se van a eliminar
	 * @return	Lista de cabecera-tarea a eliminar
	 */
	private static List<AV_HeaderCustomActivity__c> getCabeceraTareaAsociada(List<Task> listTareas) {
        Set<String> tasksExtIds = new Set<String>();
        for (Task t : listTareas) {
            if (t.AV_ExternalID__c != null) {
                tasksExtIds.add(t.AV_ExternalID__c);
            }
        }
        List<AV_HeaderCustomActivity__c> headers = [SELECT AV_ExternalID__c, OwnerId FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c IN :tasksExtIds];
        return headers;
    }

    /**
	 * Obtener todas las tareas-oportunidad asociadas a las cabeceras-tarea que se van a actualizar.
	 * @param listTareas -> lista de tarea-oportunidad
	 */
	private static List<AV_CustomActivityOpportunity__c> getTareaOppAsociada(List<AV_HeaderCustomActivity__c> listCabeceraTarea) {
        Set<String> headersIds = new Set<String>();
        List<AV_CustomActivityOpportunity__c> listTareasOportunidad = new List<AV_CustomActivityOpportunity__c>();
        for (AV_HeaderCustomActivity__c h : listCabeceraTarea) {
            headersIds.add(h.Id);
        }
        listTareasOportunidad = [SELECT Id, AV_ExternalID__c,OwnerId FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c IN :headersIds];
        return listTareasOportunidad;	
	}

    /**
	 * @description		 	Get all the ID's of the RT
	 */
	public static Set<Id> getAllRT(){
		Set<AV_AppUtilities.SearchRT> setLabelsRt = new Set<AV_AppUtilities.SearchRT>{rtTareaIniciativa, rtTareaAlertaComencial,rtTareaAvisos,rtTareaContactoGCF,rtTareaCPendiente,rtTareaExpCliente,rtTareaOnboarding,rtTareaPriorizador};
		return AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
	}

}