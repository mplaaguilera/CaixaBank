/**********************************************************************************************************************
 Name:	  EV_CampaignMemberStaging_BI_TRHan
 Copyright © 2020  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Event BeforeInsert
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				    DATE				Description
	1.0		    Eventos     	    Jashanpreet Singh	   	06/11/2021			Init version

***********************************************************************************************************************/

public class EV_CampaignMemberStaging_BI_TRHan extends CC_TriggerHandlerBase {
    
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EV_CampaingMemeberStaging__c>)tp.newList, (Map<Id, EV_CampaingMemeberStaging__c>)tp.newMap, (List<EV_CampaingMemeberStaging__c>)tp.oldList, (Map<Id, EV_CampaingMemeberStaging__c>)tp.oldMap);
	}
    
    private void process(List<EV_CampaingMemeberStaging__c> listNewObj, Map<Id, EV_CampaingMemeberStaging__c> mapNewObj, List<EV_CampaingMemeberStaging__c> listOldObj, Map<Id, EV_CampaingMemeberStaging__c> mapOldObj) {
        EV_CMStagingTriggerHelper.syncCampaignMember(listNewObj,true);
    }

}