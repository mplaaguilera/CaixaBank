/**********************************************************************************************************************
 Name:	  AV_GestorReassignmentEventsQueueable
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Queueable para actulizar Events que vienen de las clase AV_GestorReassignmentFuture
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			Init version        Sandra Gómez		04/04/2022			Init version
	1.1			Fix					Gonzalo Ávila		27/09/2023			Fix CBK_Log Error
    1.3         FIX28080841     Oscar Moreno        28/08/2024          Fix error The Global modifier should be avoided.
	
***********************************************************************************************************************/
public with sharing class AV_GestorReassignmentEventsQueueable implements Queueable{
	public Integer recordsProcessed = 0;
	public static final String BATCHNAME = 'AV_GestorReassignmentEventsQueueable';
    @testVisible private static Boolean doChainJob = !Test.isRunningTest();
	
	public List<Event> lista = new List<Event>();
	public AV_GestorReassignmentEventsQueueable(List<Event> objList) {
		this.lista = objList;
	}

	public void execute(System.QueueableContext qc){
		String methodName = 'executeEvent';
		Integer maxSize = (Integer) AV_LimitBook__c.getOrgDefaults().AV_LimitReassignment__c;
		List<Event> aux = new List<Event>();
		List<Event> listaRe = new List<Event>();
		if(lista != null && !lista.isEmpty()){
            AV_LogDebug.printLogDebug(methodName, 'Eventos que se actualizan: '+maxSize+'/'+lista.size());
			for (Event ev:lista) {
				if(maxSize == aux.size()) {
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
				List<String> listErrorsReassignment = new List<String>();
				List<String> listSuccessReassignment = new List<String>();
				Integer i = 0;
				for (Database.SaveResult sr : updateResults) {
					if (sr.isSuccess()) {
						successIds.add(sr.getId());
						listSuccessReassignment.add('methodName: ' + methodName + ' -> Id: ' + sr.getId());
					}
					if (sr.getErrors()!=null) {
						for(Database.Error err : sr.getErrors()) {
							ListErrorsReassignment.add('methodName: ' + methodName + 'Error: ' + err.getMessage() +' -> Id: ' + aux.get(i).Id);
							i++; 
						}
					}
				}
				if(!ListErrorsReassignment.isEmpty()) {
                    CBK_log.error('Metodo: '+methodName+' ListErrorsReassignment: '+ListErrorsReassignment,ListErrorsReassignment);
                }

				if(!listSuccessReassignment.isEmpty()) {
                    CBK_log.debug('Metodo: '+methodName+' listSuccessReassignment: '+listSuccessReassignment,listSuccessReassignment,LoggingLevel.DEBUG);
                }


                if (doChainJob) {
					if(listaRe != null && !listaRe.isEmpty()){
						System.enqueueJob(new AV_GestorReassignmentEventsQueueable(listaRe));
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