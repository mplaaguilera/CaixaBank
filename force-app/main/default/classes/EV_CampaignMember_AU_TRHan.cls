/**********************************************************************************************************************
 Name:	  EV_CampaignMember_AU_TRHan
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase EV_CampaignMember_AU_TRHan para Trigger de Event AfterUpdate.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		  Eventos - 73889	  Jorge Centella	   	29/01/2021			Init version
	1.1							  Daniel Rodriguez 		06/02/2023			Remove method inscripcionCliente,inscripcionNRT to EV_CampaignMemberTriggerHelper
	1.2							  Daniel Rodriguez 		17/10/2023			Call to AC if you have custom permission EV_CallTooAC
***********************************************************************************************************************/

public with sharing class EV_CampaignMember_AU_TRHan extends CC_TriggerHandlerBase {
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CampaignMember>)tp.newList, (Map<Id, CampaignMember>)tp.newMap, (List<CampaignMember>)tp.oldList, (Map<Id, CampaignMember>)tp.oldMap);
	}
	
	private void process(List<CampaignMember> listNewObj, Map<Id, CampaignMember> mapNewObj, List<CampaignMember> listOldObj, Map<Id, CampaignMember> mapOldObj) {
		EV_LogDebug.printLogDebug('EV_CampaignMember_AU_TRHan ',String.valueof(listNewObj) + ' '+ String.valueof(mapOldObj));
        Boolean hasCustomPermission = FeatureManagement.checkPermission('EV_NotCallToAC');
        if(!hasCustomPermission || Test.isRunningTest()){
			EV_CampaignMemberTriggerHelper.inscripcionCliente(mapNewObj,mapOldObj);
        }
		//EV_CampaignMemberTriggerHelper.eventSurvey(listNewObj);
	} 

	
}