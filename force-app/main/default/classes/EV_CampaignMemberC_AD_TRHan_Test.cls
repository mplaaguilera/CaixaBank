/**********************************************************************************************************************
 Name:	  EV_CampaignMemberC_AD_TRHan_Test
 Copyright © 2024  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Test para Trigger de CampaignMemberC AfterDelete
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			CStatistics	    Mamen Arias 	    13/04/2024			Init version
***********************************************************************************************************************/
@isTest
public with sharing class EV_CampaignMemberC_AD_TRHan_Test {
	@isTest
	public static void executeCampaignMemberADTrigger() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();
        EV_CampaignMemberHistory__c campH = new EV_CampaignMemberHistory__c();

		Test.startTest();
		System.runAs(newUser){
			campMember = EV_TestHelper.createCampaignMemberCustomContact(false, true);
            delete campMember;
            campH = [SELECT Id, EV_CampaignMember_Id__c FROM EV_CampaignMemberHistory__c WHERE EV_CampaignMember_Id__c = :campMember.Id];
		}
		Test.stopTest();

		System.assertEquals(campH.EV_CampaignMember_Id__c, campMember.Id, 'El CM no se ha eliminado correctamente');
	}
}