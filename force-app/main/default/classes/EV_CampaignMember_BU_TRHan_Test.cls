/**********************************************************************************************************************
 Name:	  EV_CampaignMember_BU_TRHan_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Test para Trigger de CampaignMember BeforeUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App Eventos	    Jorge Centella	    10/09/2020			Init version
	1.1			App Eventos	    Daniel Rodriguez	03/02/2023			Modify method executeCampaignMemberBUTrigger

***********************************************************************************************************************/
@isTest
public class EV_CampaignMember_BU_TRHan_Test {
    
	@isTest (SeeAllData=true)
	public static void executeCampaignMemberBUTrigger() {
		Test.startTest();
		Survey surv = [SELECT Id FROM Survey where 	ActiveVersionId != null LIMIT 1];
		CampaignMember campMember = EV_TestHelper.createCampaignMemberContact(false, true);
        Campaign cm = [SELECT id, EV_Encuesta__c FROM Campaign WHERE EV_ExternalId__c = '234567890'];
        cm.EV_Encuesta__c = surv.Id;
        Database.update(cm);
		campMember.EV_ContadorCheckInVirtual__c = 1;
		Database.update(campMember);
		System.assertEquals(1, campMember.EV_ContadorCheckInVirtual__c, 'El contador es incorrecto');

		campMember.EV_ContadorCheckInVirtual__c = 1;
		Database.update(campMember);

		campMember = [Select id, EV_ContadorCheckInVirtual__c from CampaignMember where id = :campMember.Id Limit 1];
		
		System.assertEquals(2, campMember.EV_ContadorCheckInVirtual__c, 'El contador es incorrecto');
		
		Test.stopTest();
	}
	@isTest
	public static void executeCampaignMemberBUTriggerGenerarQR() {
		
		
		CampaignMember campMember = EV_TestHelper.createCampaignMemberContact(false, true);

		campMember.Status ='Invitacion de registro enviada';

		update campMember;

		Test.startTest();
		
		Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));

		campMember.Status ='Registro Confirmado';

		update campMember;

		System.assertEquals('Registro Confirmado', campMember.Status, 'El estado es incorrecto');
		
		Test.stopTest();
	}
}