/**********************************************************************************************************************
 Name:	  AV_GestorReassignmentQueueable
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Queueable para actulizar Opportunity que vienen de las clase AV_GestorReassignmentFuture
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			Init version        Sandra Gómez		04/04/2022			Init version
	
***********************************************************************************************************************/
public with sharing class AV_GestorReassignmentQueueable implements Queueable {

	public Integer recordsProcessed = 0;
	public static final String BATCHNAME = 'AV_GestorReassignmentQueueable';
    @testVisible private static Boolean doChainJob = !Test.isRunningTest();
	
	public List<Opportunity> listaOpp = new List<Opportunity>();
	public List<Task> listaTask = new List<Task>();
	public List<Event> listaEvent = new List<Event>();
	public String objName;
	
	public AV_GestorReassignmentQueueable(List<Opportunity> listOpp, List<Task> listTask, List<Event> listEvent) {
		this.listaOpp = listOpp;
		this.listaTask = listTask;
		this.listaEvent = listEvent;
	}

	public void execute(System.QueueableContext qc){
		String methodName = 'executeOpp';
		Integer maxSize = (Integer) AV_LimitBook__c.getOrgDefaults().AV_LimitReassignment__c;
		AV_LogDebug.printLogDebug(methodName, 'Opotunidades que se actualizan: '+maxSize+'/'+listaOpp?.size());
		List<Opportunity> aux = new List<Opportunity>();
		List<Opportunity> listaOppRe = new List<Opportunity>();
		if(listaOpp != null && !listaOpp.isEmpty()){
			for (Opportunity opp:listaOpp) {
				if(maxSize == aux.size()) {
					listaOppRe.add(opp);
				} else {
					aux.add(opp);
				}
			}
			if (!aux.isEmpty()) {
				// Hay que guardar los fallos con el FWK de Login
				List<Database.SaveResult> updateResults = Database.update(aux, false);

				boolean hasError = false;
				List<Object> objs = new List<Object>();
				Map<String, String> msjs = new Map<String, String>();
				for (Integer i = 0; i < aux.size(); i++) {
					Database.SaveResult sr = updateResults[i];
					if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
						msjs.put(aux[i].Id, ((String) sr.getErrors()[0].getMessage()));
						objs.add(aux[i]);
						hasError = true;
					}
				}

				if(hasError) {
					CBK_Log.error(msjs, objs);
				}
				
                if (doChainJob) {
					if(listaOppRe != null && !listaOppRe.isEmpty()){
						System.enqueueJob(new AV_GestorReassignmentQueueable(listaOppRe,listaTask,listaEvent));
					} else {
						AV_LogDebug.printLogDebug(methodName, 'Pasamos a Tareas tienen: '+listaTask?.size());
						System.enqueueJob(new AV_GestorReassignmentTaskQueueable(listaTask,listaEvent));
					}
                }
			}
		}else{
			AV_LogDebug.printLogDebug(methodName, 'Pasamos a Tareas tienen: '+listaTask?.size());
            if (doChainJob) {
                System.enqueueJob(new AV_GestorReassignmentTaskQueueable(listaTask,listaEvent));
            }
		}  
	}
}