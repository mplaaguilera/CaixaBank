/**********************************************************************************************************************
 Name:	  EV_CampaignMember_AU_TRHan_Test
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase de Test para Trigger de CampaignMember AfterUpdate
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App Eventos	    Jorge Centella	    29/10/2020			Init version

***********************************************************************************************************************/
@isTest
public class EV_CampaignMember_AU_TRHan_Test {

    @isTest
	public static void executeCampaignMemberAUTrigger() {
		Test.startTest();

		CampaignMember campMember = EV_TestHelper.createCampaignMemberContact(false, true);
		System.assertEquals(campMember.EV_ExternalID__c != null, campMember.EV_ExternalID__c != null, 'El external ID es incorrecto');
		
		Test.stopTest();
    }
    
    @isTest
	public static void executeCampaignMemberAUTriggerInscripcion() {
		Test.startTest();

        Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
        CampaignMember campMember = EV_TestHelper.createCampaignMemberContact(false, true);

        campMember.status='Registro confirmado';
        update campMember;

		System.assertEquals(campMember.EV_ExternalID__c != null, campMember.EV_ExternalID__c != null, 'El external ID es incorrecto');
		
		Test.stopTest();
    }
    
    @isTest
	public static void executeCampaignMemberAUTriggerInscripcionEmailCampana() {
		Test.startTest();

        Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
        CampaignMember campMember = EV_TestHelper.createCampaignMemberContact(false, true);

        campMember.status='Registro confirmado';
        campMember.EV_EmailDeCampana__c = 'prueba@prueba.com';
        update campMember;

		System.assertEquals(campMember.EV_ExternalID__c != null, campMember.EV_ExternalID__c != null, 'El external ID es incorrecto');
		
		Test.stopTest();
	}

}