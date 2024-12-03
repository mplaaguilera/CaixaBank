/**********************************************************************************************************************
 Name:	  EV_CMCustomController_Test
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test para EV_CMCustomController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR								DATE				Description
	1.0			US474068            Daniel Rodriguez       				10/11/2023          Init Version
    1.1         FIX                 Carolina Lopez                      05/02/2024          Modify getCampaignMembersRCTest with seeAllData > ConnectApi Error.
***********************************************************************************************************************/


@isTest
public with sharing class EV_CMCustomController_Test {

    @isTest
    static void getCampaignMembersPITest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
        List<EV_CampaignMemberC__c> lstCMC = new List<EV_CampaignMemberC__c>();
        List<String> strCMC = new List<String>();
		Test.startTest();
		System.runAs(newUser){
            EV_CampaignMemberC__c campMember = EV_TestHelper.createCampaignMemberCustomContact(false, true);
            lstCMC = EV_CMCustomController.getCampaignMembers('1','1', campMember.EV_CampaignId__c, 'Pendiente');
            for(EV_CampaignMemberC__c cm : lstCMC){
                strCMC.add(cm.id);
            }
            EV_CMCustomController.updateCampaignMemberStatus(strCMC, 'Pendiente');
        Test.stopTest();
        }
        System.assertEquals(1, lstCMC.size(), 'KO');
    }

    @isTest(SeeAllData=true)
    public static void getCampaignMembersAsistioTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
        List<String> strCMC = new List<String>();
        List<EV_CampaignMemberC__c> lstCMC = new List<EV_CampaignMemberC__c>();
		Test.startTest();
		System.runAs(newUser){
            EV_CampaignMemberC__c campMember = EV_TestHelper.createCampaignMemberCustomContactFisicaSurvey('Registro confirmado');
            Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
			header2TestResp.put('https://qrpass-qrpass.tst.icp-1.internet.cloud.lacaixa.es/qrpass/NEMzNzU4MTg1QjM2MzcxQTAxMzYwQ0MzQTYxMjU5QzM3N0Y2OTMzMjZFREExQUYwQ0IyQzE0Q0M3ODMwNUVBOQ==',new EV_ConexionQR_Mock(200));
			CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('EV_QRPKPASS');
			header2TestResp.put(String.valueOf(dataInterface.CC_EndPoint__c),new EV_ConexionQR_Mock(200));
        	if (DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) {
                header2TestResp.put('callout:EV_AdobeCampaignPRO',new EV_AdobeCampaignInscripcion_Mock());
            } else {
                header2TestResp.put('callout:EV_AdobeCampaignPRE',new EV_AdobeCampaignInscripcion_Mock());
            }
			HttpCalloutMock multiCalloutMock = new EV_multipleRequestConexionMock_Test(header2TestResp);
			Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            lstCMC = EV_CMCustomController.getCampaignMembers('1','1', campMember.EV_CampaignId__c, 'Asistió');
            for(EV_CampaignMemberC__c cm : lstCMC){
                strCMC.add(cm.id);
            }
            EV_CMCustomController.updateCampaignMemberStatus(strCMC, 'Asistió');
            Test.stopTest();
        }
        System.assertEquals(1, lstCMC.size(), 'KO');
    }

    @isTest(SeeAllData=true)
    public static void getCampaignMembersRCTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        List<String> strCMC = new List<String>();
        List<EV_CampaignMemberC__c> lstCMC = new List<EV_CampaignMemberC__c>();
		System.runAs(newUser){
             EV_CampaignMemberC__c campMember = EV_TestHelper.createCampaignMemberCustomContact(false, true);
            Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
			header2TestResp.put('https://qrpass-qrpass.tst.icp-1.internet.cloud.lacaixa.es/qrpass/NEMzNzU4MTg1QjM2MzcxQTAxMzYwQ0MzQTYxMjU5QzM3N0Y2OTMzMjZFREExQUYwQ0IyQzE0Q0M3ODMwNUVBOQ==',new EV_ConexionQR_Mock(200));
			CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('EV_QRPKPASS');
			header2TestResp.put(String.valueOf(dataInterface.CC_EndPoint__c),new EV_ConexionQR_Mock(200));
        	if (DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) {
                header2TestResp.put('callout:EV_AdobeCampaignPRO',new EV_AdobeCampaignInscripcion_Mock());
            } else {
                header2TestResp.put('callout:EV_AdobeCampaignPRE',new EV_AdobeCampaignInscripcion_Mock());
            }
			HttpCalloutMock multiCalloutMock = new EV_multipleRequestConexionMock_Test(header2TestResp);
			Test.setMock(HttpCalloutMock.class, multiCalloutMock);
		    Test.startTest();
            lstCMC = EV_CMCustomController.getCampaignMembers('1','1', campMember.EV_CampaignId__c, 'Registro confirmado');
            for(EV_CampaignMemberC__c cm : lstCMC){
                strCMC.add(cm.id);
            }
            EV_CMCustomController.updateCampaignMemberStatus(strCMC, 'Registro confirmado');
            Test.stopTest();
        }
        System.assertEquals(1, lstCMC.size(), 'KO');
    }
}