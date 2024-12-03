/**********************************************************************************************************************
 Name:	  CIBE_Opportunity_BD_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Opportunity BeforeDelete funcionalidad para CIBE 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Jose Maria 			07/06/2022			Init version
	1.1			US872914			Lucia	 			06/05/2024			Add deleteRelations

***********************************************************************************************************************/
public class CIBE_Opportunity_BD_TRHan extends CC_TriggerHandlerBase {
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Opportunity>)tp.newList, (Map<Id, Opportunity>)tp.newMap, (List<Opportunity>) tp.oldList, (Map<Id, Opportunity>) tp.oldMap);
	}
	
	private void process(List<Opportunity> listNewObj, Map<Id, Opportunity> mapNewObj, List<Opportunity> listOldObj, Map<Id, Opportunity> mapOldObj) {
		//General check the Record type's for intouch project
        List<Opportunity> listData = CIBE_OpportunityTriggerHelper.checkGeneralRT(listOldObj);
        
        if (listData!=null && !listData.isEmpty()){
			CIBE_OpportunityTriggerHelper.deleteRelations(listData);
			//CIBE_OpportunityTriggerHelper.validateDeleteOpportunity(listData);
			CIBE_OpportunityTriggerHelper.deleteRecordsRelatedWithOpportunity(listData);
			CIBE_OpportunityTriggerHelper.deleteCommentsHistory(listData);
			
        }
	}
}