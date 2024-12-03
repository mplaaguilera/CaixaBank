/**********************************************************************************************************************
 Name:	  AV_Lead_BU_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Lead BeforeUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	                            	AUTHOR		   			DATE				Description
	1.0			US-371544 Estados Lead y LeadOpp	    Vladislav Lityagin	   	12/05/2022		    	Init version
***********************************************************************************************************************/
public class AV_Lead_BU_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Lead>)tp.newList, (Map<Id, Lead>)tp.newMap, (List<Lead>) tp.oldList, (Map<Id, Lead>) tp.oldMap);
	}
    
    private void process(List<Lead> listNewObj, Map<Id, Lead> mapNewObj, List<Lead> listOldObj, Map<Id, Lead> mapOldObj) {
        List<Lead> listDataPPHH = AV_LeadTriggerHelper.checkMortgagePlatformRT(listNewObj);
		Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
		AV_LeadTriggerHelper.updateLeadStatus(listDataPPHH, mapOldObj);
        //AV_LeadTriggerHelper.resetBypass(listDataPPHH, mapOldObj);
        AV_LeadTriggerHelper.checkDueDate(listDataPPHH, mapOldObj);
		if(!hasCustomPermission && !System.isBatch()){
			AV_LeadTriggerHelper.checkStatus(listDataPPHH, mapOldObj);
		}
	}

}