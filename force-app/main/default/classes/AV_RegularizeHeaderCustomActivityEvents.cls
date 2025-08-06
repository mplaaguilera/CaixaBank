/**********************************************************************************************************************
 Name:	  AV_RegularizeHeaderCustomActivityEvents
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para regularizar los Eventos que no tengan cabecera-tarea asociada
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
   1.7			Fix 		  David Rufo		31/05/2021		Update query to user Query FWK
   1.8			US306420	  Víctor Santiago	30/12/2021		Added query limit and deleted Event Gestor RT
   1.9			Deuda Técnica Luis Fernández	14/03/2024		Optimización del código

   
***********************************************************************************************************************/
global class AV_RegularizeHeaderCustomActivityEvents implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
   
	global Integer recordsProcessed = 0;
	global static final String BATCHNAME = 'AV_RegularizeHeaderCustomActivityEvents';
	
    private String avQuery;
    // private AV_Query avQuery;
	
    public AV_RegularizeHeaderCustomActivityEvents(){
        avQuery = setQuery();
    }

    public AV_RegularizeHeaderCustomActivityEvents(String avQuery){
        this.avQuery = avQuery;
    }
    
    private String setQuery(){
    // private AV_Query setQuery(){
        Set<String> setRt = new Set<String>{AV_AppConstants.EVENTCLIENTE_RT};
        Integer numDays = AV_SchedulerBatches.getNumDays(BATCHNAME);
		String batchLimit = AV_SchedulerBatches.getLimit(BATCHNAME);
	
		String avQuery = 'SELECT Id, AV_ExternalID__c, AV_Task__c,Subject FROM EVENT WHERE RecordType.DeveloperName = \''+AV_AppConstants.EVENTCLIENTE_RT+'\' AND AV_Task__c = NULL AND SystemModstamp = LAST_N_DAYS:'+numDays;
		if(String.isNotBlank(batchLimit)){
			avQuery += ' LIMIT '+batchLimit;
		}
        return avQuery;
    }
    
    
	/**
	 * List of the events to regularize the cabecera-tarea
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
	 * Upsert the selected list of Events
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param listEvents List<Event> param with the list of Eventos to upsert
	 */
	global void execute(Database.BatchableContext bc, List<Event> listEvent){
		// Procesar cada batch de registros
		String methodName = 'execute';
			recordsProcessed= listEvent.size();
			AV_LogDebug.printLogDebug(methodName,'Data that does not have an associated AV_HeaderCustomActivity__c (EVENTs): ' + listEvent.size());
			List<Event> listEventsToUpdate = getListEventToUpdate(listEvent);
			if (listEventsToUpdate!=null && !listEventsToUpdate.isEmpty()){
					AV_LogDebug.printLogDebug('process', 'upsert Events: ' + listEventsToUpdate.size());

					List<Database.UpsertResult> srList = Database.upsert(listEventsToUpdate, false);

					for(Database.UpsertResult sr : srList){
						if(!sr.isSuccess()){
							for(Database.Error err : sr.getErrors()){

								AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getMessage()+'\n'+err.getStatusCode()+'\Following fields are affected: '+err.getFields());
							}

						}
					}
			}
			
	}	

	/**
	 * Executes the scheduled Apex job
	 *
	 * @param sc	SchedulableContext param that contains the job ID
	 */
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new AV_RegularizeHeaderCustomActivityEvents());
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
	 * Obtener todas las cabeceras-tareas asociadas a los Eventos.
	 * @param listEvent -> lista de Eventos que no tiene cabecera-tarea asociada.
	 * @return	Mapa de cabecera-tarea con su external Id
	 */
	private static Map<String,Id> getMapCabeceraTareaAsociada(List<Event> listEvent){
		Set<String> listExternalId = new Set<String>();
		for(Event evento : listEvent){
			listExternalId.add(evento.AV_ExternalID__c);
		}
		List<AV_HeaderCustomActivity__c> listCabeceraTarea = new List<AV_HeaderCustomActivity__c>();
		if(listExternalId != null){
			listCabeceraTarea = [SELECT Id,AV_ExternalID__c FROM AV_HeaderCustomActivity__c 
								WHERE AV_ExternalID__c IN :listExternalId];
		}
		Map<String,Id> mapCabeceraTarea = new Map<String,Id>();
		for(AV_HeaderCustomActivity__c cabeceraTarea : listCabeceraTarea){
			mapCabeceraTarea.put(cabeceraTarea.AV_ExternalID__c, cabeceraTarea.Id);
		}

		return mapCabeceraTarea;
	}

	/**
	 * Obtener la lista de Eventos para actualizar.
	 * @param listEvent -> lista de Eventos que no tiene cabecera-tarea asociada.
	 * @return	List of Events to update
	 */
	private static List<Event> getListEventToUpdate(List<Event> listEvent){
        String methodName = 'getListEventToUpdate';
		List<Event> listEventsToUpdate = new List<Event>();
		List<AV_HeaderCustomActivity__c> listHeaderTask = new List<AV_HeaderCustomActivity__c>();
        
		//Obtengo todas las cabecera-tareas asociadas a la lista de Eventos
		Map<String,Id> mapCabeceraTarea = getMapCabeceraTareaAsociada(listEvent);
		Map<String, AV_HeaderCustomActivity__c> mapHeaderTask = new Map<String, AV_HeaderCustomActivity__c>();
		
		for(Event evento : listEvent){
			//Si existe una cabecera-tarea con ese ExternalId se lo asocio
			if(evento.AV_Task__c==null){
				if(mapCabeceraTarea != null && mapCabeceraTarea.containsKey(evento.AV_ExternalID__c)){
					evento.AV_Task__c = mapCabeceraTarea.get(evento.AV_ExternalID__c);
					listEventsToUpdate.add(evento);
				} else{
					AV_HeaderCustomActivity__c headerCustomAct = new AV_HeaderCustomActivity__c();
					if(String.isNotBlank(evento.Subject) && evento.Subject.length() < 80){
						headerCustomAct.Name = evento.Subject;
					} else {
						headerCustomAct.Name = evento.AV_ExternalID__c;
					}
					headerCustomAct.AV_ExternalID__c = evento.AV_ExternalID__c;
                    headerCustomAct.IDTask__c = evento.Id;
					listHeaderTask.add(headerCustomAct);
					mapHeaderTask.put(headerCustomAct.AV_ExternalID__c, headerCustomAct);

				}
			}
		}

		//Insert data && update the field "AV_Task__c"
		if (listHeaderTask!=null && !listHeaderTask.isEmpty()){
				AV_LogDebug.printLogDebug(methodName, 'insert listHeaderTask: ' + listHeaderTask.size());
				List<Database.SaveResult> srList = Database.insert(listHeaderTask, false);
				for(Database.SaveResult sr : srList){
					if(!sr.isSuccess()){
						for(Database.Error err : sr.getErrors()){
							AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getMessage()+'\n'+err.getStatusCode()+'\Following fields are affected: '+err.getFields());
						}
					}
				}
				//Map where the key is the external ID
				//Update field "AV_Task__c"
				for(Event evento : listEvent){
					AV_HeaderCustomActivity__c auxHeaderTask = mapHeaderTask.get(evento.AV_ExternalID__c);
					if (auxHeaderTask!=null){
						evento.AV_Task__c = auxHeaderTask.Id;
						listEventsToUpdate.add(evento);
					}
				}
		}

		return listEventsToUpdate;
	}
}