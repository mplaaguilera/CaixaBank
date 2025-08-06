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
	1.5	        New Scoring     Luis Fernández	    20/12/2023		 	Added new method calculateScoreOpp call
	1.6                         Oscar Moreno        12/01/2024          PS AV_OpportunitiesSearcherV2 control the access to insertTaskWithOpp method
	1.7         US796361        Oscar Moreno        20/03/2024          Add mapToByPass in createCommentsHistory
	1.8			DT08			Luis Fernández		23/04/2024			Added calculateScoreOpp called from AV_OpportunityTriggerHelperAux
	1.9         FIX IOP 7 Mayo  Elisabeth R.        06/052024           Changed createCommentsHistory method to AV_OpportunityTriggerHelperSharing class due to sharing settings of the CSBD user who is creating the opportunity with comments
	2.0        US913185         Oscar Moreno        04/06/2024           PS AV_CheckOnOff control the access to insertTaskWithOpp method
	3.0        PPM100130465     Oscar Moreno        05/07/2024          Replace PS_CHECKONOFF with PS_OLDHOMETASK
***********************************************************************************************************************/
public class AV_Opportunity_AI_TRHan extends AV_TriggerHandlerBase {
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Opportunity>)tp.newList, (Map<Id, Opportunity>)tp.newMap, (List<Opportunity>) tp.oldList, (Map<Id, Opportunity>) tp.oldMap);
	}
	
	private void process(List<Opportunity> listNewObj, Map<Id, Opportunity> mapNewObj, List<Opportunity> listOldObj, Map<Id, Opportunity> mapOldObj) {

		Boolean hasCustomPermission = FeatureManagement.checkPermission(AV_AppConstants.PS_OLDHOMETASK);
		//General check the Record type's for intouch project
        List<Opportunity> listData = AV_OpportunityTriggerHelper.checkGeneralRT(listNewObj);
		List<Opportunity> listDataCM = AV_OpportunityTriggerHelper.checkCallMeRT(listNewObj);
        // Lógica de negocio a ejecutar
		if (listData!=null && !listData.isEmpty()){
            AV_OpportunityTriggerHelper.createTask(listData);
            if(hasCustomPermission){
				AV_OpportunityTriggerHelper.insertTaskWithOpp(listData, mapToByPass);
			}
			AV_OpportunityTriggerHelper.sendDataToGCF(listData, 'AI', mapToByPass);
			AV_OpportunityTriggerHelperSharing.createCommentsHistory(listData,mapToByPass);
			AV_OpportunityTriggerHelperAux.calculateScoreOpp(listData,null,null,'AI');
        }
	}
}