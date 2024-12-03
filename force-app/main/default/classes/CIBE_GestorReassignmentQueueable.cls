/**********************************************************************************************************************
 Name:	  CIBE_GestorReassignmentFuture
 Copyright © 2020  CaixaBank
------------------------------------------------------------------------------------------------------------------------
Proposito: Clase Queueable para actulizar Opportunity que vienen de las clase AV_GestorReassignmentFuture
------------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				  DATE				Description
	1.0			App FSC			Mikel Lezama          07/11/2021	    Init version
***********************************************************************************************************************/
global with sharing class CIBE_GestorReassignmentQueueable implements Queueable {

	global Integer recordsProcessed = 0;
	global static final String BATCHNAME = 'CIBE_GestorReassignmentQueueable';
	final Integer MAX_QUEUE_SIZE = (Integer) AV_LimitBook__c.getOrgDefaults().AV_LimitReassignment__c;
    @testVisible private static Boolean doChainJob = !Test.isRunningTest();
	
	global List<Opportunity> listaOpp = new List<Opportunity>();
	global List<Task> listaTask = new List<Task>();
	global List<Event> listaEvent = new List<Event>();
	global String objName;
	
	public CIBE_GestorReassignmentQueueable(List<Opportunity> listOpp, List<Task> listTask, List<Event> listEvent) {
		this.listaOpp = listOpp;
		this.listaTask = listTask;
		this.listaEvent = listEvent;
	}

	global void execute(System.QueueableContext qc){
		String methodName = 'executeOpp';
		List<Opportunity> aux = new List<Opportunity>();
		List<Opportunity> listaOppRe = new List<Opportunity>();
		if(listaOpp != null && !listaOpp.isEmpty()){
			for (Opportunity opp:listaOpp) {
				if(MAX_QUEUE_SIZE == aux.size()) {
					listaOppRe.add(opp);
				} else {
					aux.add(opp);
				}
			}
			if (!aux.isEmpty()) {
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
			}
		}
        
        if(listaOppRe != null && !listaOppRe.isEmpty() && doChainJob){
            System.enqueueJob(new CIBE_GestorReassignmentQueueable(listaOppRe,listaTask,listaEvent));
        } else if(doChainJob) {
            System.enqueueJob(new CIBE_GestorReassignmentTaskQueueable(listaTask,listaEvent));
        }
	}
}