/**********************************************************************************************************************
 Name:	  EV_CampaignMember_BU_TRHan
 Copyright © 2020  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Campaign BeforeUpdate
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
    1.0                           Daniel Rodriguez      03/02/2023          Remove method actualizarContadorCheckInVirtual,processCampaignMemberForQR, generarQR to EV_CampaignMemberTriggerHelper. Modify method fillNameFromCampaignMember

***********************************************************************************************************************/
public with sharing class EV_CampaignMember_BU_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CampaignMember>)tp.newList, (Map<Id, CampaignMember>)tp.newMap, (List<CampaignMember>)tp.oldList, (Map<Id, CampaignMember>)tp.oldMap);
    }
    
    private void process(List<CampaignMember> listNewObj, Map<Id, CampaignMember> mapNewObj, List<CampaignMember> listOldObj, Map<Id, CampaignMember> mapOldObj) {
        EV_LogDebug.printLogDebug('EV_CampaignMember_BU_TRHan ',String.valueof(listNewObj) + ' '+ String.valueof(mapOldObj));
        EV_CampaignMemberTriggerHelper.actualizarContadorCheckInVirtual(listNewObj, mapOldObj);
        EV_CampaignMemberTriggerHelper.processCampaignMemberForQR(listNewObj, mapOldObj);
        EV_CampaignMemberTriggerHelper.fillNameFromCampaignMember(listNewObj);
        EV_CampaignMemberTriggerHelper.eventSurvey(listNewObj, mapOldObj, false);
        EV_CampaignMemberTriggerHelper.linkUniqueSurveyGeneration(listNewObj, mapOldObj);
    }   
}