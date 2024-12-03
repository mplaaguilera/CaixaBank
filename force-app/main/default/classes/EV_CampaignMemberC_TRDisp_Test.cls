/**********************************************************************************************************************
 Name:   EV_CampaignMemberC_TRDisp_Test
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Test para Dispatcher de los trigger de EV_CampaignMemberC__c
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION     USER_STORY          AUTHOR              DATE                Description
	1.0			US584499			Mamen Arias			20/04/2023			Initi Version.
***********************************************************************************************************************/
@isTest
public with sharing class EV_CampaignMemberC_TRDisp_Test {
	private static testMethod void testUpdateCaseMethod() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
		List<EV_CampaignMemberC__c> campaignMemberList = new List<EV_CampaignMemberC__c>();
		EV_CampaignMemberC__c testCampaignMember = new EV_CampaignMemberC__c();

		System.runAs(newUser){
			testCampaignMember = EV_TestHelper.createCampaignMemberCustomContactEmpresa(false, true);
			campaignMemberList.add(testCampaignMember);
			for(EV_CampaignMemberC__c mem : campaignMemberList){
				mem.EV_Empresa__c = true;
			} 
			testCampaignMember.EV_Empresa__c=true;
		}

		Test.startTest();
		System.runAs(newUser){
			update campaignMemberList;
		}
		Test.stopTest();

		System.assertEquals(true, testCampaignMember.EV_Empresa__c);
	}
}