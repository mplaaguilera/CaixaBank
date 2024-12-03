/**********************************************************************************************************************
 Name:	  CIBE_Opportunity_AI_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Opportunity BeforeDelete funcionalidad para CIBE 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Alicia 				26/01/2023			Init version

***********************************************************************************************************************/
public class CIBE_Opportunity_AI_TRHan extends CC_TriggerHandlerBase {
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Opportunity>)tp.newList, (Map<Id, Opportunity>)tp.newMap, (List<Opportunity>) tp.oldList, (Map<Id, Opportunity>) tp.oldMap);
	}
	
	private void process(List<Opportunity> listNewObj, Map<Id, Opportunity> mapNewObj, List<Opportunity> listOldObj, Map<Id, Opportunity> mapOldObj) {
        List<Opportunity> listData = CIBE_OpportunityTriggerHelper.checkGeneralRT(listNewObj);
        
        if (listData!=null && !listData.isEmpty()){
			CIBE_OpportunityTriggerHelper.addRelationshipManager(listData);
            CIBE_OpportunityTriggerHelper.insertTaskWithOpp(listData);
			CIBE_OpportunityTriggerHelper.insertOppTM(listData);
        }
	}
}