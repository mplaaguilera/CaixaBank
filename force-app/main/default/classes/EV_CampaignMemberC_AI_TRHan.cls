/**********************************************************************************************************************
 Name:	  EV_CampaignMemberC_AI_TRHan
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de CampaignMember AfterInsert
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		  	US584499			Mamen Arias			20/04/2023			Init version
	1.2			US635282			Daniel Rodriguez 	13/06/2023			Insert method updateRollup
	1.3 		US635293			Carolina Lopez		21/06/2023			Insert method SendSingleEmail
	1.4							  	Daniel Rodriguez 	17/10/2023			Call to AC if you have custom permission EV_CallTooAC
	1.5			CStatistics			Mamen Arias			12/03/2024			Insert method updateRollupLeadsContacts
***********************************************************************************************************************/
public with sharing class EV_CampaignMemberC_AI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EV_CampaignMemberC__c>)tp.newList, (Map<Id, EV_CampaignMemberC__c>)tp.newMap, (List<EV_CampaignMemberC__c>)tp.oldList, (Map<Id, EV_CampaignMemberC__c>)tp.oldMap);
	}
	
	private void process(List<EV_CampaignMemberC__c> listNewObj, Map<Id, EV_CampaignMemberC__c> mapNewObj, List<EV_CampaignMemberC__c> listOldObj, Map<Id, EV_CampaignMemberC__c> mapOldObj) {
		EV_LogDebug.printLogDebug('EV_CampaignMemberC_AI_TRHan ',String.valueof(listNewObj));
        Boolean hasCustomPermission = FeatureManagement.checkPermission('EV_NotCallToAC');
        if(!hasCustomPermission || Test.isRunningTest()){
			EV_CampaignMemberCTriggerHelper.inscripcionNRT(mapNewObj);
        }
        EV_CampaignMemberCTriggerHelper.updateRollup(mapNewObj,null);
        EV_CampaignMemberCTriggerHelper.updateRollupLeadsContacts(mapNewObj,null);
        EV_CampaignMemberCTriggerHelper.sendSingleEmail(listNewObj);
	}
}