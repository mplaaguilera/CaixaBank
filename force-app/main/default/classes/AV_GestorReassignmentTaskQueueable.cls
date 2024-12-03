/**********************************************************************************************************************
 Name:	  AV_GestorReassignmentTaskQueueable
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Queueable para actulizar Tasks que vienen de las clase AV_GestorReassignmentFuture
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			Init version        Sandra Gómez		04/04/2022			Init version
	1.1			Fix					Gonzalo Ávila		27/09/2023			Fix CBK_Log Error
	1.2 		Fix					Gonzalo Ávila		16/07/2024			Change de position of i++ in execute
    1.3         FIX28080841         Oscar Moreno        28/08/2024          Fix error The Global modifier should be avoided.	

***********************************************************************************************************************/
public with sharing class AV_GestorReassignmentTaskQueueable implements Queueable {
	public Integer recordsProcessed = 0;
	public static final String BATCHNAME = 'AV_GestorReassignmentTaskQueueable';
	@testVisible private static Boolean doChainJob = !Test.isRunningTest();
	
	public List<Task> listaTask = new List<Task>();
	public List<Event> listaEvent= new List<Event>();
	public AV_GestorReassignmentTaskQueueable(List<Task> listTask, List<Event> listEvent) {
		this.listaTask = listTask;
		this.listaEvent = listEvent;
	}

	public void execute(System.QueueableContext qc){
		String methodName = 'executeTask';
		Integer maxSize = (Integer) AV_LimitBook__c.getOrgDefaults().AV_LimitReassignment__c;
		AV_LogDebug.printLogDebug(methodName, 'Tareas que se actualizan: '+maxSize+'/'+listaTask.size());
		List<Task> aux = new List<Task>();
		List<Task> listaTaskRe = new List<Task>();
		if(listaTask != null && !listaTask.isEmpty()){
			for (Task ta:listaTask) {
				if(maxSize == aux.size()) {
					listaTaskRe.add(ta);
				} else {
					aux.add(ta);
				}
			}
			if (!aux.isEmpty()) {
				AV_LogDebug.printLogDebug(methodName, 'Tareas a actualizar: '+aux.size()+'/'+listaTask.size());
				// Hay que guardar los fallos con el FWK de Login
				List<Database.SaveResult> updateResults = Database.update(aux, false);
				List<Id> successIds = new List<Id>();
				List<String> listErrorsReassignmentTask = new List<String>();
				List<String> listSuccessReassignmentTask = new List<String>();
				Integer i = 0;
				for (Database.SaveResult sr : updateResults) {
					if (sr.isSuccess()) {
						successIds.add(sr.getId());
						listSuccessReassignmentTask.add('methodName: ' + methodName + ' -> Id: ' + sr.getId());
					}
					if (sr.getErrors()!=null) {
						for(Database.Error err : sr.getErrors()) {
							listErrorsReassignmentTask.add('methodName: ' + methodName + 'Error: ' + err.getMessage() +' -> Id: ' + aux.get(i).Id);
						}
					}
					i++; 
				}

				if(!listSuccessReassignmentTask.isEmpty()) {
                    CBK_log.debug('Metodo: '+methodName+' listSuccessReassignmentTask: '+listSuccessReassignmentTask,listSuccessReassignmentTask,LoggingLevel.DEBUG);
                }

				if(!listErrorsReassignmentTask.isEmpty()) {
                    CBK_log.error('Metodo: '+methodName+' listErrorsReassignmentTask: '+listErrorsReassignmentTask,listErrorsReassignmentTask);
                }


                if (doChainJob) {
					if(listaTaskRe != null && !listaTaskRe.isEmpty()){
						System.enqueueJob(new AV_GestorReassignmentTaskQueueable(listaTaskRe,listaEvent));
					} else {
						AV_LogDebug.printLogDebug(methodName, 'Pasamos a Eventos tienen: '+listaEvent.size());
						System.enqueueJob(new AV_GestorReassignmentEventsQueueable(listaEvent));
					}
                }
			}
		}else{
			AV_LogDebug.printLogDebug(methodName, 'Pasamos a Eventos tienen: '+listaEvent.size());
            if (doChainJob) {
                System.enqueueJob(new AV_GestorReassignmentEventsQueueable(listaEvent));
            }
		}   
	}
}