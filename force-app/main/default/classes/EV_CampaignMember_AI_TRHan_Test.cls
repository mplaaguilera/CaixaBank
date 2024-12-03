/**********************************************************************************************************************
 Name:	  EV_CampaignMember_AI_TRHan_Test
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase de Test para Trigger de CampaignMember BeforeUpdate
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App Eventos	    Jorge Centella	    29/10/2020			Init version
	1.1			FIX				Mamen Arias			02/02/2024			Add seeAllData=true on method executeCampaignMemberAITriggerLead for ConnectApi Error.
***********************************************************************************************************************/
@isTest
public class EV_CampaignMember_AI_TRHan_Test {
    
	@isTest
	public static void executeCampaignMemberAITrigger() {
		Test.startTest();

		CampaignMember campMember = EV_TestHelper.createCampaignMemberContact(false, true);
		System.assertEquals(campMember.EV_ExternalID__c != null, campMember.EV_ExternalID__c != null, 'El external ID es incorrecto');
		
		Test.stopTest();
	}

	@isTest (seeAllData=true)
	public static void executeCampaignMemberAITriggerLead() {
		Test.startTest();
		
		Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
		CampaignMember campMember = EV_TestHelper.createCampaignMemberLead(false, true);
		System.assertEquals(campMember.EV_ExternalID__c != null, campMember.EV_ExternalID__c != null, 'El external ID es incorrecto');
		
		Test.stopTest();
	}
}