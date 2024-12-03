/**********************************************************************************************************************
 Name:	  AV_Opportunity_AU_TRHan
 Copyright © 2020  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Opportunity AfterUpdate
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Sandra Gomez		15/10/2020			Init version
    1.1			App FSC			David Rufo			09/12/2020			Include a general check of the Record Types
    2.0         US155069        Eric Vázquez        29/01/2021          Add removeDuplicityTask for opp
	2.1			US498642		Vladislav Lityagin	19/01/2023			Include check of th Record Type Call Me and call createTaskCalMe
 	2.2         DE80526         Elisabeth R.        14/08/2023          Delete createTaskCallMe method
    2.3         Fix             Sandra Gómez        17/08/2023          Deleted code comment and problem copado
    2.4         US686939        Oscar Moreno        24/08/2023          Added updateCommentsHistory method
    2.5			US546892		Sandra Gómez		18/09/2023			add mapToByPass in method updateTaskWithOpp and sendDataToGCF
    2.6	        Fix		        Sandra Gómez		07/10/2023		    Change method setFieldsFromOppTask add parameter mapByPass
***********************************************************************************************************************/
public with sharing class AV_Opportunity_AU_TRHan extends CC_TriggerHandlerBase {
	
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Opportunity>)tp.newList, (Map<Id, Opportunity>)tp.newMap, (List<Opportunity>) tp.oldList, (Map<Id, Opportunity>) tp.oldMap);
	}
	
	private void process(List<Opportunity> listNewObj, Map<Id, Opportunity> mapNewObj, List<Opportunity> listOldObj, Map<Id, Opportunity> mapOldObj) {
		//General check the Record type's for intouch project
        List<Opportunity> listData = AV_OpportunityTriggerHelper.checkGeneralRT(listNewObj);
        List<Opportunity> listDataCM = AV_OpportunityTriggerHelper.checkCallMeRT(listNewObj);
        // Lógica de negocio a ejecutar
        if (listData!=null && !listData.isEmpty()){
            AV_OpportunityTriggerHelper.setFieldsFromOppTask(listData, mapOldObj, mapToByPass);
            AV_OpportunityTriggerHelper.telephoneContracting(listData, mapOldObj);
            AV_OpportunityTriggerHelper.updateTaskWithOpp(listData, mapOldObj, mapToByPass);
            AV_OpportunityTriggerHelper.sendDataToGCF(listData, 'AU', mapToByPass);
            AV_OpportunityTriggerHelper.updateCommentsHistory(listData,mapOldObj);
        }
	}
}