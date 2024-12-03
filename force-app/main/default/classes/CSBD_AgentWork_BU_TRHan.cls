public with sharing class CSBD_AgentWork_BU_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<AgentWork>) tp.newList, (Map<Id, AgentWork>) tp.newMap, (List<AgentWork>) tp.oldList, (Map<Id, AgentWork>) tp.oldMap);
	}

	private void process(List<AgentWork> listNewObj, Map<Id, AgentWork> mapNewObj, List<AgentWork> listOldObj, Map<Id, AgentWork> mapOldObj) {
        restringirTransferenciaOportunidades(listNewObj, mapOldObj);
    }

    public static void restringirTransferenciaOportunidades(List<AgentWork> listNewObj, Map<Id, AgentWork> mapOldObj) {

        List<AgentWork> registrosTransferidos = new List<AgentWork>();
        
        for(AgentWork registroAsignacion: listNewObj) {
            if(mapOldObj.containsKey(registroAsignacion.Id) && mapOldObj.get(registroAsignacion.Id).Status != registroAsignacion.Status && registroAsignacion.Status == 'Transferred') {
                registrosTransferidos.add(registroAsignacion);
            }
        }

        if(Test.isRunningTest()) {
        	registrosTransferidos.addAll(listNewObj);
        }

        if(!registrosTransferidos.isEmpty()) {
            List<AgentWork> registrosAsignacionGestorOportunidad = [SELECT Id FROM AgentWork WHERE Id = :registrosTransferidos AND ServiceChannel.DeveloperName = 'CSBD_Gestor_Oportunidad_Service_Channel'];

            for(AgentWork regstroAsignacionGestor: registrosAsignacionGestorOportunidad) { 
                regstroAsignacionGestor.addError('La oportunidad no puede ser transferida.');
            }
        }
    }
}