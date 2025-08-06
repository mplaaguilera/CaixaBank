/**********************************************************************************************************************
 Name:	  EV_CampaignMemberC_AU_TRHan
 Copyright © 2023  CaixaBank
=======================================================================================================================
Proposito: Clase para Trigger de CampaignMember AfterUpdate.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		  	US584499	  		Mamen Arias	   		20/04/2023			Init version
	1.1			US635282			Daniel Rodriguez 	13/06/2023			Insert method updateRollup
	1.2							  	Daniel Rodriguez 	17/10/2023			Call to AC if you have custom permission EV_CallTooAC
***********************************************************************************************************************/
public with sharing class EV_CampaignMemberC_AU_TRHan extends CC_TriggerHandlerBase {
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EV_CampaignMemberC__c>)tp.newList, (Map<Id, EV_CampaignMemberC__c>)tp.newMap, (List<EV_CampaignMemberC__c>)tp.oldList, (Map<Id, EV_CampaignMemberC__c>)tp.oldMap);
	}
	
	private void process(List<EV_CampaignMemberC__c> listNewObj, Map<Id, EV_CampaignMemberC__c> mapNewObj, List<EV_CampaignMemberC__c> listOldObj, Map<Id, EV_CampaignMemberC__c> mapOldObj) {
		EV_LogDebug.printLogDebug('EV_CampaignMemberC_AU_TRHan ',String.valueof(listNewObj) + ' '+ String.valueof(mapOldObj));
        Boolean hasCustomPermission = FeatureManagement.checkPermission('EV_NotCallToAC');
        if(!hasCustomPermission || Test.isRunningTest()){
			EV_CampaignMemberCTriggerHelper.inscripcionCliente(mapNewObj,mapOldObj);
        }
		EV_CampaignMemberCTriggerHelper.updateRollup(mapNewObj,mapOldObj);
	}
}