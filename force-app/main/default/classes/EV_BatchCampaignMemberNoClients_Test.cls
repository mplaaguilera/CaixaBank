/**********************************************************************************************************************
 Name:	  EV_BatchCampaignMemberNoClients_Test
 Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Clase Test para batch de ocultamiento de leads
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		                	  	Mamen Arias    		22/11/2022			Add method callBatchCampaignMemberAccionista_Test for test CampaignMember from 'Lead Accionista'

***********************************************************************************************************************/
@isTest
public with sharing class EV_BatchCampaignMemberNoClients_Test {
	@TestSetup
	static void makeData(){
		CampaignMember campMember = EV_TestHelper.createCampaignMemberLead();
		CampaignMember campMemberAcc = EV_TestHelper.createCampaignMemberLeadAccionista();
		Campaign camp = [SELECT Id, StartDate, Status FROM Campaign WHERE EV_ExternalId__c = '234567890'];
		camp.StartDate = Date.today()-3;
		update camp;

		Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
		header2TestResp.put('https://qrpass-qrpass.tst.icp-1.internet.cloud.lacaixa.es/qrpass/NEMzNzU4MTg1QjM2MzcxQTAxMzYwQ0MzQTYxMjU5QzM3N0Y2OTMzMjZFREExQUYwQ0IyQzE0Q0M3ODMwNUVBOQ==',new EV_ConexionQR_Mock(200));

        if (DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) {
            header2TestResp.put('callout:API_GWT_PRO/servicing/registers',new EV_ConexionQR_Mock(200));
            header2TestResp.put('callout:EV_PROAdobeCampaign',new EV_AdobeCampaignInscripcion_Mock());
        } else {
            header2TestResp.put('callout:API_GWT_PRO/servicing/registers',new EV_ConexionQR_Mock(200));
            header2TestResp.put('callout:EV_PREAdobeCampaign',new EV_AdobeCampaignInscripcion_Mock());
        }

		HttpCalloutMock multiCalloutMock = new EV_multipleRequestConexionMock_Test(header2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);
	}

	@isTest
	private static void callBatchCampaignMemberNoClientsTest(){
		//Set<String> setFieldsCampaign = new Set<String>{'Id, StartDate, Status'};
		Campaign camp = [SELECT Id, StartDate, Status FROM Campaign WHERE RecordType.DeveloperName = 'EV_EventoVirtual'];
		camp.Status = '005';
		camp.StartDate = camp.StartDate.addDays(-31);
		update camp;
	   // Set<String> setFieldsCampaignMember = new Set<String>{'Id, LeadId, Lead.Email, CampaignId, EV_ConsentmientoGeneral__c, Campaign.StartDate'};
		List<CampaignMember> listCampaignMember = [SELECT Id, LeadId, Lead.Email, CampaignId, EV_ConsentmientoGeneral__c, Campaign.StartDate FROM CampaignMember where Campaign.StartDate =:camp.StartDate];
	   // List<CampaignMember> listcm = new AV_Query('CampaignMember').selectFields(setFieldsCampaignMember).addConditionEq('Campaign.StartDate', camp.StartDate).setLimit(1).run();
		Test.startTest();
		EV_BatchCampaignMemberNoClients a = new EV_BatchCampaignMemberNoClients();
		Database.executeBatch(a);
		
		Test.stopTest();
		
		Campaign camp2 = [SELECT Id, StartDate, Status FROM Campaign WHERE RecordType.DeveloperName = 'EV_EventoVirtual'];
		system.assertEquals(camp2.Status, '005', 'OK');
	}

	@isTest
	private static void callBatchCampaignMemberAccionistaTest(){
		Campaign camp = [SELECT Id, StartDate, Status FROM Campaign WHERE RecordType.DeveloperName = 'EV_Eventos_Accionistas'];
		camp.Status = '005';
		camp.StartDate = camp.StartDate.addYears(-5);
		update camp;

		List<CampaignMember> listCampaignMember = [SELECT Id, LeadId, Lead.Email, CampaignId, EV_ConsentmientoGeneral__c, Campaign.StartDate FROM CampaignMember where Campaign.StartDate =:camp.StartDate];

		Test.startTest();
		EV_BatchCampaignMemberNoClients a = new EV_BatchCampaignMemberNoClients();
		Database.executeBatch(a);
		Test.stopTest();
		
		Campaign camp2 = [SELECT Id, StartDate, Status FROM Campaign WHERE RecordType.DeveloperName = 'EV_Eventos_Accionistas'];
		system.assertEquals(camp2.Status, '005', 'OK');
	}
}