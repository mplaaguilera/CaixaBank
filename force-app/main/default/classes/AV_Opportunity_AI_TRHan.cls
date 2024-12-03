/**********************************************************************************************************************
 Name:	  AV_Opportunity_AI_TRHan
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase para Trigger de Opportunity AfterInsert
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Carolina Alonso		02/06/2020			Init version
	1.1			App FSC			David Rufo			09/12/2020			Include a general check of the Record Types
    1.2         Fix             Elisabeth R.        14/08/2023          Delete createTaskCallMe method
	1.3         US686939        Oscar Moreno        24/08/2023          Added createCommentsHistory method
	1.4			US546892		Sandra Gómez		18/09/2023			add mapToByPass in method insertTaskWithOpp and sendDataToGCF
***********************************************************************************************************************/
public class AV_Opportunity_AI_TRHan extends CC_TriggerHandlerBase {
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Opportunity>)tp.newList, (Map<Id, Opportunity>)tp.newMap, (List<Opportunity>) tp.oldList, (Map<Id, Opportunity>) tp.oldMap);
	}
	
	private void process(List<Opportunity> listNewObj, Map<Id, Opportunity> mapNewObj, List<Opportunity> listOldObj, Map<Id, Opportunity> mapOldObj) {
		//General check the Record type's for intouch project
        List<Opportunity> listData = AV_OpportunityTriggerHelper.checkGeneralRT(listNewObj);
		List<Opportunity> listDataCM = AV_OpportunityTriggerHelper.checkCallMeRT(listNewObj);
        // Lógica de negocio a ejecutar
		if (listData!=null && !listData.isEmpty()){
            AV_OpportunityTriggerHelper.createTask(listData);
            AV_OpportunityTriggerHelper.insertTaskWithOpp(listData, mapToByPass);
			AV_OpportunityTriggerHelper.sendDataToGCF(listData, 'AI', mapToByPass);
			AV_OpportunityTriggerHelper.createCommentsHistory(listData);
        }
	}
}