/**********************************************************************************************************************
 Name:	  CIBE_GestorReassignmentFuture
 Copyright © 2020  CaixaBank
------------------------------------------------------------------------------------------------------------------------
Proposito: Clase Queueable para actulizar Events que vienen de las clase AV_GestorReassignmentFuture
------------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				  DATE				Description
	1.0			App FSC			Mikel Lezama          07/11/2021	    Init version
***********************************************************************************************************************/
global with sharing class CIBE_GestorReassignmentEventsQueueable implements Queueable {

	global Integer recordsProcessed = 0;
	global static final String BATCHNAME = 'CIBE_GestorReassignmentEventsQueueable';
	final Integer MAX_QUEUE_SIZE = (Integer) AV_LimitBook__c.getOrgDefaults().AV_LimitReassignment__c;
    @testVisible private static Boolean doChainJob = !Test.isRunningTest();
	
	global List<Event> lista = new List<Event>();
	public CIBE_GestorReassignmentEventsQueueable(List<Event> objList) {
		this.lista = objList;
	}

	global void execute(System.QueueableContext qc){
		String methodName = 'executeEvent';
		//AV_LogDebug.printLogDebug(methodName, 'Eventos que se actualizan: '+MAX_QUEUE_SIZE+'/'+lista.size());
		List<Event> aux = new List<Event>();
		List<Event> listaRe = new List<Event>();
		if(lista != null && !lista.isEmpty()){
			for (Event ev:lista) {
				if(MAX_QUEUE_SIZE == aux.size()) {
					listaRe.add(ev);
				} else {
					aux.add(ev);
				}
			}
			if (!aux.isEmpty()) {
				AV_LogDebug.printLogDebug(methodName, 'Eventos a actualizar: '+aux.size()+'/'+lista.size());
				// Hay que guardar los fallos con el FWK de Login
				List<Database.SaveResult> updateResults = Database.update(aux, false);
				List<Id> successIds = new List<Id>();
				Integer i = 0;
				for (Database.SaveResult sr : updateResults) {
					if (sr.isSuccess()) {
						successIds.add(sr.getId());
						CBK_Log.debug(methodName, 'Update Opportunity: ' + sr.getId());
					}
					if (sr.getErrors()!=null) {
						for(Database.Error err : sr.getErrors()) {
							CBK_Log.debug(methodName, 'Error: ' + err.getMessage() + ' -> Id: ' + aux.get(i).Id);
							i++; 
						}
					}
				}
                if (doChainJob) {
					if(listaRe != null && !listaRe.isEmpty()){
						System.enqueueJob(new CIBE_GestorReassignmentEventsQueueable(listaRe));
					} else {
						AV_LogDebug.printLogDebug(methodName, 'Finalizada la recarterización');
					}
                }
			}
		} else {
			AV_LogDebug.printLogDebug(methodName, 'Finalizada la recarterización');
		}  
	}
}