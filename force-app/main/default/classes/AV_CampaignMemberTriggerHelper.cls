/**********************************************************************************************************************
 Name:	  AV_CampaignMemberTriggerHelper
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Trigger sobre el objeto CampaignMember
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			App FSC            	Sandra Gómez		30/03/2022			Init version

***********************************************************************************************************************/
public with sharing class AV_CampaignMemberTriggerHelper {
	/**
	 * @description		 Validate CampaignMember to delete when User PS Bank Teller 
	 * @param  listOlds  list of old Opportunity records
	 */
	public static void validateBankTeller(List<CampaignMember> listOlds){
		List<CampaignMember> listToProcess = new List<CampaignMember>();
		for (CampaignMember cm : listOlds){
			if (cm.Id!=null){
				listToProcess.add(cm);
			}
		}
		if(!listToProcess.isEmpty()){
			if(FeatureManagement.checkPermission('AV_BankTeller_Custom')) {
				for(CampaignMember cm : listToProcess){
					cm.addError(Label.AV_ErrorDeleteCampaignMember);
				}
			}
		}
	}
}