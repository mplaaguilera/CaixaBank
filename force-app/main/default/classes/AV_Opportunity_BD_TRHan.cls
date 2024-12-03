/**********************************************************************************************************************
 Name:	  AV_Opportunity_BD_TRHan
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase para Trigger de Opportunity BeforeDelete
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US118509			Eric Vázquez		26/10/2020			Init version
	1.1			App FSC				David Rufo			09/12/2020			Include a general check of the Record Types
	1.2			US482011			Patricia Solano		29/03/2023			Added the method call deleteRecordsRelatedWithOpportunity
    1.3         US686939            Oscar Moreno        24/08/2023          Added deleteCommentsHistory method 
***********************************************************************************************************************/
public class AV_Opportunity_BD_TRHan extends CC_TriggerHandlerBase {
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Opportunity>)tp.newList, (Map<Id, Opportunity>)tp.newMap, (List<Opportunity>) tp.oldList, (Map<Id, Opportunity>) tp.oldMap);
	}
	
	private void process(List<Opportunity> listNewObj, Map<Id, Opportunity> mapNewObj, List<Opportunity> listOldObj, Map<Id, Opportunity> mapOldObj) {
		//General check the Record type's for intouch project
        List<Opportunity> listData = AV_OpportunityTriggerHelper.checkGeneralRT(listOldObj);
        
        if (listData!=null && !listData.isEmpty()){
        	AV_OpportunityTriggerHelper.validateDeleteOpportunity(listData);
			AV_OpportunityTriggerHelper.deleteRecordsRelatedWithOpportunity(listData);
			AV_OpportunityTriggerHelper.deleteCommentsHistory(listData);
        }
	}
}