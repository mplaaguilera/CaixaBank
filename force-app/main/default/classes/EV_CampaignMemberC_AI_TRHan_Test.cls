/**********************************************************************************************************************
 Name:	  EV_CampaignMemberC_AI_TRHan_Test
 Copyright © 2023  CaixaBank
=======================================================================================================================
Proposito: Clase de Test para Trigger de CampaignMember AfterInsert
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US584499	    Mamen Arias 	    20/04/2023			Init version
***********************************************************************************************************************/
@isTest
public class EV_CampaignMemberC_AI_TRHan_Test {
	
	@isTest
	public static void executeCampaignMemberAITrigger() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();

		Test.startTest();
		System.runAs(newUser){
			campMember = EV_TestHelper.createCampaignMemberCustomContact(false, true);
		}
		Test.stopTest();

		System.assertEquals(campMember.EV_ExternalID__c != null, campMember.EV_ExternalID__c != null, 'El external ID es incorrecto');
	}

	@isTest
	public static void executeCampaignMemberAITriggerLead() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();

		Test.startTest();
		System.runAs(newUser){
			Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
			campMember = EV_TestHelper.createCampaignMemberCustomLead(false, true);
		}
		Test.stopTest();

		System.assertEquals(campMember.EV_ExternalID__c != null, campMember.EV_ExternalID__c != null, 'El external ID es incorrecto');
	}
}