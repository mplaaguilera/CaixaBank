/**********************************************************************************************************************
 Name:	  AV_RegularizeHeaderCustomActivity
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para regularizar las Tareas que no tengan cabecera-tarea asociada
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY	  AUTHOR		   	DATE			Description
   1.0			App FSC		  Carolina Alonso   02/09/2020		Init version
   1.1			App FSC		  Carolina Alonso   28/09/2020		Delete order by in query
   1.2			Hotfix		  Carolina Alonso   07/10/2020		Fix problem with the huge amount or records
   1.3			Hotfix		  Carolina Alonso   13/10/2020		Add RT Check
   1.4			Hotfix		  Jashanpreet		16/10/2020		add AV_BatchProcessRegularizeHCA_Date__c
   1.5			App FSC		  Sandra Gómez		01/12/2020		Improve the limit query: dynamic limit query
   1.6			Fix bug		  David Rufo		09/03/2021		The date field is not filling in all the cases
   1.6			Fix		 	  David Rufo		31/05/2021		Update query to user Query FWK
   1.7        	US592987	  Ángel Medina		30/05/2023		Changed AV_Query to SOQL queries
   
***********************************************************************************************************************/
global class AV_RegularizeHeaderCustomActivity implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
   
	global Integer recordsProcessed = 0;
	global static final String BATCHNAME = 'AV_RegularizeHeaderCustomActivity';
	 
    
	/**
	 * Update the list of the task to regularize the object cabecera-tarea
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		String methodName = 'start';

		Set<String> setRt = new Set<String>{AV_AppConstants.TASKINICIATIVA_RT, AV_AppConstants.TASKALERTACOM_RT,
			AV_AppConstants.TASKAVISOS_RT, AV_AppConstants.TASKCONTACTGCF_RT,
			AV_AppConstants.TASKEXPCLIENT_RT, AV_AppConstants.TASKONBOARDING_RT,
			AV_AppConstants.TASKPRIORIZADOR_RT};
			   
		Set<String> setStatus = new Set<String>{AV_AppConstants.TASK_STATUS_PENDIENTE, AV_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL,
			AV_AppConstants.GESTIONADO_POSITIVO_ESTADO, AV_AppConstants.GESTIONADO_NEGATIVA_ESTADO,
			AV_AppConstants.NO_GESTIONADA, AV_AppConstants.GESTIONADO_NO_LOCALIZADO};
			 
		String avQuery = 'SELECT Id, AV_ExternalID__c, AV_Task__c, Subject, RecordTypeId, RecordType.DeveloperName FROM Task WHERE RecordType.DeveloperName IN ' + AV_AppUtilities.setToStringIn(setRt) + ' AND Status IN ' + AV_AppUtilities.setToStringIn(setStatus) + ' AND AV_Task__c = null AND CreatedDate = LAST_N_DAYS:15 ';

		String batchLimit = AV_SchedulerBatches.getLimit(BATCHNAME);
		if(String.isNotBlank(batchLimit)){
			avQuery += ' LIMIT ' + Integer.valueOf(batchLimit);
		}

		AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);
		return Database.getQueryLocator(avQuery);
	}

	/**
	 * Upsert the selected list of Task
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param listEvents List<Task> param with the list of Task to upsert
	 */
	global void execute(Database.BatchableContext bc, List<Task> listTask){
		// Procesar cada batch de registros
		String methodName = 'execute';
		try{
			recordsProcessed= listTask.size();
			AV_LogDebug.printLogDebug(methodName,'Data that does not have an associated AV_HeaderCustomActivity__c (TASKs): ' + listTask.size());
			List<Task> listTaskToUpdate = getListTaskToUpdate(listTask);
			if (listTaskToUpdate!=null && !listTaskToUpdate.isEmpty()){
				try{
					AV_LogDebug.printLogDebug(methodName, 'upsert Tasks: ' + listTaskToUpdate.size());
					Database.upsert(listTaskToUpdate, false);
				}catch(Exception e){
					AV_LogDebug.printException(methodName, e);
				}
			}
			
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
		Database.executeBatch(new AV_RegularizeHeaderCustomActivity());
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
	
	/**
	 * Obtener todas las cabeceras-tareas asociadas a las Tareas.
	 * @param listTareas -> lista de Tareas que no tiene cabecera-tarea asociada.
	 * @return	Mapa de cabecera-tarea con su external Id
	 */
	private static Map<String,Id> getMapCabeceraTareaAsociada(List<Task> listTask){
		Set<String> listExternalId = new Set<String>();
		for(Task tarea : listTask){
			listExternalId.add(tarea.AV_ExternalID__c);
		}
		List<AV_HeaderCustomActivity__c> listCabeceraTarea = new List<AV_HeaderCustomActivity__c>();
		if(listExternalId != null){
			listCabeceraTarea = [SELECT Id, AV_ExternalID__c FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c IN :listExternalId];
		}
		Map<String,Id> mapCabeceraTarea = new Map<String,Id>();
		for(AV_HeaderCustomActivity__c cabeceraTarea : listCabeceraTarea){
			mapCabeceraTarea.put(cabeceraTarea.AV_ExternalID__c, cabeceraTarea.Id);
		}

		return mapCabeceraTarea;
	}

	/**
	 * Obtener la lista de Tareas para actualizar.
	 * @param listTareas -> lista de Tareas que no tiene cabecera-tarea asociada.
	 * @return	List of Task to update
	 */
	private static List<Task> getListTaskToUpdate(List<Task> listTask){
        String methodName = 'getListTaskToUpdate';
        List<Task> listTaskToUpdate = new List<Task>();
        List<AV_HeaderCustomActivity__c> listHeaderTask = new List<AV_HeaderCustomActivity__c>();
        
		//Obtengo todas las cabecera-tareas asociadas a la lista de Tareas
		Map<String,Id> mapCabeceraTarea = getMapCabeceraTareaAsociada(listTask);
		
		for(Task tarea : listTask){
            String recordTypeDeveloperName = tarea.RecordType.DeveloperName;
            if(recordTypeDeveloperName.startsWithIgnoreCase('AV_') && tarea.AV_Task__c==null){
				//Si existe una cabecera-tarea con ese ExternalId se lo asocio
                if(mapCabeceraTarea != null && mapCabeceraTarea.containsKey(tarea.AV_ExternalID__c)){
					tarea.AV_Task__c = mapCabeceraTarea.get(tarea.AV_ExternalID__c);
					listTaskToUpdate.add(tarea);
				}
                //sino se crea la cabecera-tarea
                else{
					AV_HeaderCustomActivity__c headerCustomAct = new AV_HeaderCustomActivity__c();
					if(String.isNotBlank(tarea.Subject) && tarea.Subject.length() < 80){
						headerCustomAct.Name = tarea.Subject;
					} else {
						headerCustomAct.Name = tarea.AV_ExternalID__c;
					}
					headerCustomAct.AV_ExternalID__c = tarea.AV_ExternalID__c;
                    headerCustomAct.IDTask__c = tarea.Id;
					listHeaderTask.add(headerCustomAct);
				}
            }
		}

		//Insert data && update the field "AV_Task__c"
		if (listHeaderTask!=null && !listHeaderTask.isEmpty()){
			try{
				AV_LogDebug.printLogDebug(methodName, 'insert listHeaderTask: ' + listHeaderTask.size());
				Database.insert(listHeaderTask, false);
			}catch(Exception e){
				AV_LogDebug.printException(methodName + ' - listHeaderTask', e);
			}
			try{
				//Map where the key is the external ID
				Map<String, AV_HeaderCustomActivity__c> mapHeaderTask = new Map<String, AV_HeaderCustomActivity__c>();
				for(AV_HeaderCustomActivity__c auxHeaderTask : listHeaderTask){
					mapHeaderTask.put(auxHeaderTask.AV_ExternalID__c, auxHeaderTask);
				}
				//Update field "AV_Task__c"
				for(Task tarea : listTask){
					AV_HeaderCustomActivity__c auxHeaderTask = mapHeaderTask.get(tarea.AV_ExternalID__c);
					if (auxHeaderTask!=null){
                        tarea.AV_Task__c = auxHeaderTask.Id;
						listTaskToUpdate.add(tarea);
					}
				}
			}catch(Exception e){
				AV_LogDebug.printException(methodName + ' - listTaskToUpdate', e);
			}
		}

		return listTaskToUpdate;
	}
}