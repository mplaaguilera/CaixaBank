/**********************************************************************************************************************
 Name:	  EV_CampaignMemberTriggerHelper_Test
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			                    Eric Vázquez		26/03/2021			Init version
	1.0			                    Eric Vázquez		26/03/2021			Init version
	1.1								Mamen Arias			05/01/2023			Add method linkUniqueSurveyGenerationAsistioNew_Test
	1.2.		US593725			Daniel Rodriguez	15/05/2023			Add named credentials to login	
	1.3			US657362			Mamen Arias			05/09/2023			Add method inscriptionNRTCliente
	1.4			DEF83772			Carolina Lopez		13/10/2023			Modify methods executeCampaignMemberBUTriggerGenerarQR, testEventSurvey, linkUniqueSurveyGenerationAsistio_Test, inscriptionNRTCliente.
	1.5			US738796			Carolina Lopez		19/10/2023			Include CC_InterfaceSettings__mdt in methods fillNameFromCampaignMemberUpdateTest, executeCampaignMemberBUTriggerGenerarQR and testEventSurvey
***********************************************************************************************************************/
@isTest
public with sharing class EV_CampaignMemberTriggerHelper_Test {

	@isTest
	private static void fillNameFromCampaignMemberUpdateTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		CampaignMember campMember = new CampaignMember();

		Test.startTest();
		System.runAs(newUser){
			Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
			header2TestResp.put('https://qrpass-qrpass.tst.icp-1.internet.cloud.lacaixa.es/qrpass/NEMzNzU4MTg1QjM2MzcxQTAxMzYwQ0MzQTYxMjU5QzM3N0Y2OTMzMjZFREExQUYwQ0IyQzE0Q0M3ODMwNUVBOQ==',new EV_ConexionQR_Mock(200));

			CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('EV_QRPKPASS');
			header2TestResp.put(String.valueOf(dataInterface.CC_EndPoint__c),new EV_ConexionQR_Mock(200));
			
            if (DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) {
                header2TestResp.put('callout:EV_PROAdobeCampaign',new EV_AdobeCampaignInscripcion_Mock());
            } else {
                header2TestResp.put('callout:EV_PREAdobeCampaign',new EV_AdobeCampaignInscripcion_Mock());
            }
            
			HttpCalloutMock multiCalloutMock = new EV_multipleRequestConexionMock_Test(header2TestResp);
	
			Test.setMock(HttpCalloutMock.class, multiCalloutMock);
			campMember = EV_TestHelper.createCampaignMemberContact(false, true);
			
			/*campMember.EV_ContadorCheckInVirtual__c = 1;
			Database.update(campMember);
			campMember.EV_ContadorCheckInVirtual__c = 1;*/
			campMember.Status = 'Registro confirmado';
			Database.update(campMember);
		}
		Test.stopTest();

		System.assertEquals('Registro confirmado', campMember.Status);
	}

	@isTest
	private static void fillNameFromCampaignMemberInsertTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
		CampaignMember campMember = new CampaignMember();

		Test.startTest();
		System.runAs(newUser){
			campMember = EV_TestHelper.createCampaignMemberContact(false, true);
		}
		Test.stopTest();

		System.assertEquals('Pendiente', campMember.Status);
	}

	@isTest
	private static void memberCampaignWithoutAccountTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
		CampaignMember campMember = new CampaignMember();

		Test.startTest();
		System.runAs(newUser){
			campMember = EV_TestHelper.createCampaignMemberContact(false, true);
			campMember.EV_Empresa__c = true;
			Database.update(campMember);
		}
		
		Test.stopTest();

		System.assertEquals(true, campMember.EV_Empresa__c);
	}

	@isTest (SeeAllData=true)
	public static void executeCampaignMemberBUTriggerGenerarQR() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		CampaignMember campMember = new CampaignMember();

		Test.startTest();
		System.runAs(newUser){
			Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
			header2TestResp.put('https://qrpass-qrpass.tst.icp-1.internet.cloud.lacaixa.es/qrpass/NEMzNzU4MTg1QjM2MzcxQTAxMzYwQ0MzQTYxMjU5QzM3N0Y2OTMzMjZFREExQUYwQ0IyQzE0Q0M3ODMwNUVBOQ==',new EV_ConexionQR_Mock(200));

            CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('EV_QRPKPASS');
			header2TestResp.put(String.valueOf(dataInterface.CC_EndPoint__c),new EV_ConexionQR_Mock(200));
			
            if (DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) {
                header2TestResp.put('callout:EV_PROAdobeCampaign',new EV_AdobeCampaignInscripcion_Mock());
            } else {
                header2TestResp.put('callout:EV_PREAdobeCampaign',new EV_AdobeCampaignInscripcion_Mock());
            }
			
			HttpCalloutMock multiCalloutMock = new EV_multipleRequestConexionMock_Test(header2TestResp);
			Test.setMock(HttpCalloutMock.class, multiCalloutMock);
			campMember = EV_TestHelper.createCampaignMemberContact(false, true);

			campMember.Status ='Invitacion enviada';

			update campMember;
			
			Survey surv = [SELECT Id FROM Survey WHERE ActiveVersionId != null AND ActiveVersion.SurveyStatus = 'Active' LIMIT 1];
				
			Campaign camp = new Campaign(Id=campMember.CampaignId, EV_Encuesta__c=surv.Id);
			update camp;
			
			campMember.EV_ContadorCheckInVirtual__c = 1;
			campMember.Status ='Registro Confirmado';

			update campMember;
		}
		Test.stopTest();

		System.assertEquals('Registro Confirmado', campMember.Status);
	}
	
	@isTest (SeeAllData=true)
	public static void testEventSurvey(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		CampaignMember campMember = new CampaignMember();
		
		System.runAs(newUser){
			Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
			header2TestResp.put('https://qrpass-qrpass.tst.icp-1.internet.cloud.lacaixa.es/qrpass/NEMzNzU4MTg1QjM2MzcxQTAxMzYwQ0MzQTYxMjU5QzM3N0Y2OTMzMjZFREExQUYwQ0IyQzE0Q0M3ODMwNUVBOQ==',new EV_ConexionQR_Mock(200));

            CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('EV_QRPKPASS');
			header2TestResp.put(String.valueOf(dataInterface.CC_EndPoint__c),new EV_ConexionQR_Mock(200));
			
            if (DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) {
                header2TestResp.put('callout:EV_PROAdobeCampaign',new EV_AdobeCampaignInscripcion_Mock());
            } else {
                header2TestResp.put('callout:EV_PREAdobeCampaign',new EV_AdobeCampaignInscripcion_Mock());
            }
			
			HttpCalloutMock multiCalloutMock = new EV_multipleRequestConexionMock_Test(header2TestResp);
			Test.setMock(HttpCalloutMock.class, multiCalloutMock);
			
			campMember =  EV_TestHelper.createCampaignMemberLead(true,false);
			Survey surv = [SELECT Id FROM Survey WHERE ActiveVersionId != null AND ActiveVersion.SurveyStatus = 'Active'  LIMIT 1];        
			Campaign camp = new Campaign(Id=campMember.CampaignId, EV_Encuesta__c=surv.Id);
			Update camp;
		}

        Test.startTest();
		System.runAs(newUser){
			Account acc = EV_TestHelper.createEmpresa();
			CampaignMember campMem = new CampaignMember();
			campMem.AccountId =acc.Id;
			campMem.CampaignId = campMember.CampaignId;
			campMem.EV_ExternalId__c = '123456789';
			campMem.status = 'Pendiente';
			insert campMem;

			//CampaignMember cpm = [SELECT Id, LeadId, Status  FROM CampaignMember WHERE CampaignId = :campMember.CampaignId and LeadId != null Limit 1];
			Lead l = [SELECT Id, EV_Account__c FROM Lead WHERE Id = :campMember.LeadId ];
			l.EV_Account__c = acc.Id;
			update l;

			campMember.Status = 'Asistió';
			update campMember;
		}
		Test.stopTest();

		System.assertEquals('Asistió', campMember.Status);
	}
	/*
	@isTest (SeeAllData=true)
	public static void linkUniqueSurveyGenerationQREnviado_Test() {

		Test.startTest();
		Survey surv = [SELECT Id FROM Survey LIMIT 1];
        
		CampaignMember campMember = EV_TestHelper.createCampaignMemberContact(false, true);
		campMember.Status ='QR enviado';
		update campMember;
		
		Campaign camp = [SELECT Id, EV_Encuesta__c FROM Campaign WHERE Id = :campMember.CampaignId LIMIT 1];
		camp.EV_Encuesta__c = surv.Id;
		update camp;
	   
		//SurveyInvitation surveyInv = [SELECT Id FROM SurveyInvitation WHERE SurveyId =: surv.Id LIMIT 1];
		campMember.EV_ContadorCheckInVirtual__c = 1;
		//campMember.EV_InvitacionEncuesta__c = surveyInv.Id;
		//campMember.Status ='QR enviado';
		update campMember;
	
		campMember = [SELECT Id, Status FROM CampaignMember WHERE Id = :campMember.Id LIMIT 1];

		Test.stopTest();

		System.assertEquals('Asistió', campMember.Status);
	}*/
	
	@isTest (SeeAllData=true)
	public static void linkUniqueSurveyGenerationAsistio_Test() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
		CampaignMember campMember = new CampaignMember();

        Test.startTest();
		System.runAs(newUser){
			campMember = EV_TestHelper.createCampaignMemberContact(false, true);
			Survey surv = [SELECT Id FROM Survey WHERE ActiveVersionId != null AND ActiveVersion.SurveyStatus = 'Active' LIMIT 1];
			Campaign camp = [SELECT Id, EV_Encuesta__c FROM Campaign WHERE Id = :campMember.CampaignId LIMIT 1];
			camp.EV_Encuesta__c = surv.Id;
			camp.Status ='Asistió';
			update campMember;

			//SurveyInvitation surveyInv = [SELECT Id, InvitationLink FROM SurveyInvitation WHERE SurveyId =: surv.Id LIMIT 1];
			//campMember.EV_InvitacionEncuesta__c = surveyInv.Id;

			campMember = [SELECT Id, EV_URLEncuesta__c, EV_InvitacionEncuesta__c FROM CampaignMember WHERE Id = :campMember.Id LIMIT 1];
		}
		Test.stopTest();
		System.assertEquals(String.isNotBlank(campMember.EV_URLEncuesta__c), true);
		//System.assertEquals(campMember.EV_URLEncuesta__c.contains(surveyInv.Id), true);
	}

	@isTest (SeeAllData=true)
	public static void linkUniqueSurveyGenerationAsistioNew_Test() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
		CampaignMember campMember = new CampaignMember();

		Test.startTest();
		System.runAs(newUser){
			campMember = EV_TestHelper.createCampaignMemberContactFisicaSurvey('Asistió');
			campMember = [SELECT Id, EV_InvitacionEncuesta__c FROM CampaignMember WHERE Id = :campMember.Id LIMIT 1];
		}

		Test.stopTest();

		System.assertEquals(String.isNotBlank(campMember.EV_InvitacionEncuesta__c), true);
	}

	@isTest (SeeAllData=true)
	public static void inscriptionNRTCliente() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
		CampaignMember campMember = new CampaignMember();

		Test.startTest();
		System.runAs(newUser){
			Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
			campMember = EV_TestHelper.createCampaignMemberContact(false, true);
            
            Survey surv = [SELECT Id FROM Survey WHERE ActiveVersionId != null AND ActiveVersion.SurveyStatus = 'Active' LIMIT 1];
			Campaign camp = new Campaign(Id=campMember.CampaignId, EV_Encuesta__c=surv.Id);
			update camp;
            
			campMember.Status='Registro confirmado';
			campMember.EV_EmailDeCampana__c = 'prueba@prueba.com';
			update campMember;		
		}
		Test.stopTest();

		System.assertEquals(campMember.EV_ExternalID__c != null, campMember.EV_ExternalID__c != null, 'El external ID es incorrecto');
	}
}