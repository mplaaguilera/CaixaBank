/**********************************************************************************************************************
 Name:	  EV_BatchCampaignMemberNoClients_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Test para batch de ocultamiento de leads
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		                	  	Mamen Arias    		22/11/2022			Add method callBatchCampaignMemberAccionista_Test for test CampaignMember from 'Lead Accionista'
	1.1			FIX					Carolina Lopez		02/02/2024			Add methods seeAllData > error ConnectApi and add RunAs.
	1.2			FIX					Carolina Lopez		11/04/2024			Add methods callBatchCampaignMemberCusNoClientsTest and callBatchCampaignMemberCusAccionistaTest.
***********************************************************************************************************************/
@isTest
public with sharing class EV_BatchCampaignMemberNoClients_Test {
	@isTest(SeeAllData=true)
	private static void callBatchCampaignMemberNoClientsTest(){
		User user = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Campaign camp = new Campaign();
        Campaign campana = new Campaign();
		System.runAs(user){
			EV_TestHelper.createCampaignMemberLead();
			campana = [SELECT Id, StartDate, Status FROM Campaign WHERE EV_ExternalId__c = '234567890' LIMIT 1];
			campana.StartDate = Date.today()-3;
			update campana;
		}
        Test.startTest();
		System.runAs(user){
			camp = [SELECT Id, StartDate, Status, EV_FlujoPruebas__c FROM Campaign WHERE Id =: campana.Id LIMIT 1];
			camp.Status = '005';
			camp.EV_FlujoPruebas__c = '002';
			camp.StartDate = camp.StartDate.addDays(-31);
			update camp;
			Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
			EV_BatchCampaignMemberNoClients a = new EV_BatchCampaignMemberNoClients();
			Database.executeBatch(a);
		}
        Test.stopTest();
        System.assertEquals(camp.Status, '005', 'OK');
	}

	@isTest(SeeAllData=true)
	private static void callBatchCampaignMemberAccionistaTest(){
		User user = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Campaign camp = new Campaign();
        Campaign campana = new Campaign();
		System.runAs(user){
			EV_TestHelper.createCampaignMemberLeadAccionista();
			campana = [SELECT Id, StartDate, Status FROM Campaign WHERE EV_ExternalId__c = '789132456' LIMIT 1];
			campana.StartDate = Date.today()-3;
			update campana;
		}
        Test.startTest();
		System.runAs(user){
			camp = [SELECT Id, StartDate, Status, EV_FlujoPruebas__c FROM Campaign WHERE Id =: campana.Id LIMIT 1];
			camp.Status = '005';
			camp.EV_FlujoPruebas__c = '002';
			camp.StartDate = camp.StartDate.addYears(-5);
			update camp;
			Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
			EV_BatchCampaignMemberNoClients a = new EV_BatchCampaignMemberNoClients();
			Database.executeBatch(a);
		}
			Test.stopTest();
        System.assertEquals(camp.Status, '005', 'OK');
	}

	@isTest(SeeAllData=true)
	private static void callBatchCampaignMemberCusNoClientsTest(){
		User user = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Campaign camp = new Campaign();
        Campaign campana = new Campaign();
		System.runAs(user){
			EV_TestHelper.createCampaignMemberCustomLead();
			campana = [SELECT Id, StartDate, Status FROM Campaign WHERE EV_ExternalId__c = '234567890' LIMIT 1];
			campana.StartDate = Date.today()-3;
			update campana;
		}
        Test.startTest();
		System.runAs(user){
			camp = [SELECT Id, StartDate, Status, EV_FlujoPruebas__c FROM Campaign WHERE Id =: campana.Id LIMIT 1];
			camp.Status = '005';
			camp.EV_FlujoPruebas__c = '002';
			camp.StartDate = camp.StartDate.addDays(-31);
			update camp;
			Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
			EV_BatchCampaignMemberNoClients a = new EV_BatchCampaignMemberNoClients();
			Database.executeBatch(a);
		}
        Test.stopTest();
        System.assertEquals(camp.Status, '005', 'OK');
	}

	@isTest(SeeAllData=true)
	private static void callBatchCampaignMemberCusAccionistaTest(){
		User user = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Campaign camp = new Campaign();
        Campaign campana = new Campaign();
		System.runAs(user){
			EV_TestHelper.createCampaignMemberCustomLeadAccionista();
			campana = [SELECT Id, StartDate, Status FROM Campaign WHERE EV_ExternalId__c = '789132456' LIMIT 1];
			campana.StartDate = Date.today()-3;
			update campana;
		}
        Test.startTest();
		System.runAs(user){
			camp = [SELECT Id, StartDate, Status, EV_FlujoPruebas__c FROM Campaign WHERE Id =: campana.Id LIMIT 1];
			camp.Status = '005';
			camp.EV_FlujoPruebas__c = '002';
			camp.StartDate = camp.StartDate.addYears(-5);
			update camp;
			Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
			EV_BatchCampaignMemberNoClients a = new EV_BatchCampaignMemberNoClients();
			Database.executeBatch(a);			
		}
        Test.stopTest();
        System.assertEquals(camp.Status, '005', 'OK');
	}
}