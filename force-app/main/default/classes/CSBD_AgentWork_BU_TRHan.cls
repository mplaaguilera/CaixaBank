public with sharing class CSBD_AgentWork_BU_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<AgentWork>) tp.newList, (Map<Id, AgentWork>) tp.newMap, (List<AgentWork>) tp.oldList, (Map<Id, AgentWork>) tp.oldMap);
	}

	private void process(List<AgentWork> listNewObj, Map<Id, AgentWork> mapNewObj, List<AgentWork> listOldObj, Map<Id, AgentWork> mapOldObj) {
        restringirTransferenciaOportunidades(listNewObj, mapOldObj);
    }

    private static void restringirTransferenciaOportunidades(List<AgentWork> agentWorks, Map<Id, AgentWork> mapOldObj) {
        Id idServiceChannel = [SELECT Id
                                FROM ServiceChannel
                                WHERE DeveloperName = 'CSBD_Gestor_Oportunidad_Service_Channel']?.Id;
        for (AgentWork agentWork : agentWorks) {
            AgentWork oldAgentWork = mapOldObj.get(agentWork.Id);
            if (oldAgentWork?.Status != 'Transferred'
            && agentWork.Status == 'Transferred'
            && agentWork.ServiceChannelId == idServiceChannel) {
                agentWork.addError('La oportunidad no puede ser transferida.');
            }
        }
    }
}