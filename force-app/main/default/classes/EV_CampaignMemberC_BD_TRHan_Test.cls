/**********************************************************************************************************************
 Name:	  EV_CampaignMemberC_BD_TRHan_Test
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Test para Trigger de CampaignMember BeforeDelete
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US584499	    Mamen Arias	        20/04/2023			Init version
***********************************************************************************************************************/
@isTest
public class EV_CampaignMemberC_BD_TRHan_Test {
    
    @isTest
	public static void executeCampaignMemberBDTrigger() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();
        EV_CampaignMemberHistory__c campH = new EV_CampaignMemberHistory__c();
		
        System.runAs(newUser){
			campMember = EV_TestHelper.createCampaignMemberCustomContact(false, true);
		}

		Test.startTest();
		System.runAs(newUser){
			delete campMember;
            campH = [SELECT Id, EV_CampaignMember_Id__c FROM EV_CampaignMemberHistory__c where EV_CampaignMember_Id__c = :campMember.Id];
		}
		Test.stopTest();

        System.assertEquals(campH.EV_CampaignMember_Id__c, campMember.Id);
    }
}