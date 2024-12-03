/**********************************************************************************************************************
 Name:	  EV_CampaignMemberC_BU_TRHan_Test
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Test para Trigger de CampaignMember BeforeUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US584499	    Mamen Arias	        20/04/2023			Init version
	1.1			FIX				Mamen Arias			02/02/2024			Add seeAllData=true on method executeCampaignMemberBUTriggerGenerarQR for ConnectApi Error.
***********************************************************************************************************************/
@isTest
public class EV_CampaignMemberC_BU_TRHan_Test {
	
	@isTest (SeeAllData=true)
	public static void executeCampaignMemberBUTrigger() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');

		Test.startTest();

		System.runAs(newUser){
			Survey surv = [SELECT Id FROM Survey WHERE ActiveVersionId != null LIMIT 1];
			EV_CampaignMemberC__c campMember = EV_TestHelper.createCampaignMemberCustomContact(false, true);
			Campaign cm = [SELECT Id, EV_Encuesta__c FROM Campaign WHERE EV_ExternalId__c = '234567890'];
			cm.EV_Encuesta__c = surv.Id;
			Database.update(cm);
			campMember.EV_ContadorCheckInVirtual__c = 1;
			Database.update(campMember);
			System.assertEquals(1, campMember.EV_ContadorCheckInVirtual__c, 'El contador es incorrecto');
		}
		
		Test.stopTest();
	}
	
	@isTest (seeAllData=true)
	public static void executeCampaignMemberBUTriggerGenerarQR() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();
		
		System.runAs(newUser){
			campMember = EV_TestHelper.createCampaignMemberCustomContact(false, true);
			campMember.EV_Status__c = 'Invitación enviada';
			update campMember;
		}

		Test.startTest();
		
		System.runAs(newUser){
			Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
			campMember.EV_Status__c ='Registro Confirmado';
			update campMember;
			System.assertEquals('Registro Confirmado', campMember.EV_Status__c, 'El estado es incorrecto');
		}

		Test.stopTest();
	}
}