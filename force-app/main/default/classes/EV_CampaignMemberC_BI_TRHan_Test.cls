/**********************************************************************************************************************
 Name:	  EV_CampaignMemberC_BI_TRHan_Test
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Test para Trigger de CampaignMember BeforeInsert
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US584499	    Mamen Arias	        20/04/2023			Init version
***********************************************************************************************************************/
@isTest
public class EV_CampaignMemberC_BI_TRHan_Test {

    @isTest
	public static void executeCampaignMemberBITrigger() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();
		
		Test.startTest();
		System.runAs(newUser){
			campMember = EV_TestHelper.createCampaignMemberCustomContact(false, true);
		}
		Test.stopTest();

		System.assertEquals(campMember.Id != null, true);		
    }
}