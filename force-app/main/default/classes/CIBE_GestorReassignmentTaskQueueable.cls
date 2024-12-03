/**********************************************************************************************************************
 Name:	  CIBE_GestorReassignmentFuture
 Copyright © 2020  CaixaBank
------------------------------------------------------------------------------------------------------------------------
Proposito: Clase Queueable para actulizar Tasks que vienen de las clase AV_GestorReassignmentFuture
------------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				  DATE				Description
	1.0			App FSC			Mikel Lezama          07/11/2021	    Init version
***********************************************************************************************************************/
global with sharing class CIBE_GestorReassignmentTaskQueueable implements Queueable {

	global Integer recordsProcessed = 0;
	global static final String BATCHNAME = 'CIBE_GestorReassignmentTaskQueueable';
	final Integer MAX_QUEUE_SIZE = (Integer) AV_LimitBook__c.getOrgDefaults().AV_LimitReassignment__c;
	@testVisible private static Boolean doChainJob = !Test.isRunningTest();
	
	global List<Task> listaTask = new List<Task>();
	global List<Event> listaEvent= new List<Event>();
	public CIBE_GestorReassignmentTaskQueueable(List<Task> listTask, List<Event> listEvent) {
		this.listaTask = listTask;
		this.listaEvent = listEvent;
	}

	global void execute(System.QueueableContext qc){
		String methodName = 'executeTask';
        Integer size;
        if (!doChainJob){
            size = 0;
        }else {
            size = listaTask.size();
        }
        AV_LogDebug.printLogDebug(methodName, 'Límite de Tareas que se actualizan por ejecución: '+MAX_QUEUE_SIZE);
		AV_LogDebug.printLogDebug(methodName, 'Tareas que se actualizan: '+size);
		List<Task> aux = new List<Task>();
		List<Task> listaTaskRe = new List<Task>();
		if(listaTask != null && !listaTask.isEmpty()){
			for (Task ta:listaTask) {
				if(MAX_QUEUE_SIZE == aux.size()) {
					listaTaskRe.add(ta);
				} else {
					aux.add(ta);
				}
			}
			if (!aux.isEmpty()) {
				AV_LogDebug.printLogDebug(methodName, 'Tareas a actualizar: '+aux.size());
                AV_LogDebug.printLogDebug(methodName, 'Tareas totales a actualizar: '+listaTask.size());
				// Hay que guardar los fallos con el FWK de Login
				List<Database.SaveResult> updateResults = Database.update(aux, false);
				List<Id> successIds = new List<Id>();
				Integer i = 0;
				for (Database.SaveResult sr : updateResults) {
					if (sr.isSuccess()) {
						successIds.add(sr.getId());
						CBK_Log.debug(methodName, 'Update Task: ' + sr.getId());
					}
					if (sr.getErrors()!=null) {
						for(Database.Error err : sr.getErrors()) {
							CBK_Log.debug(methodName, 'Error: ' + err.getMessage() + ' -> Id: ' + aux.get(i).Id);
							i++; 
						}
					}
				}
                if (doChainJob) {
					if(listaTaskRe != null && !listaTaskRe.isEmpty()){
						System.enqueueJob(new CIBE_GestorReassignmentTaskQueueable(listaTaskRe,listaEvent));
					} else {
						AV_LogDebug.printLogDebug(methodName, 'Pasamos a Eventos tienen: '+listaEvent.size());
						System.enqueueJob(new CIBE_GestorReassignmentEventsQueueable(listaEvent));
					}
                }
			}
		}else{
            Integer size2;
            if (!doChainJob){
                size2 = 0;
            }else {
                size2 = listaEvent.size();
            }
			AV_LogDebug.printLogDebug(methodName, 'Pasamos a Eventos');
            AV_LogDebug.printLogDebug(methodName, 'Eventos tienen: '+size2);

            if (doChainJob) {
                System.enqueueJob(new CIBE_GestorReassignmentEventsQueueable(listaEvent));
            }
		}   
	}

}