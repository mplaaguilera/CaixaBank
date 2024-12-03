/**********************************************************************************************************************
 Name:	  EV_CampaignMemberCTriggerHelper_Test
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
* @description  Clase de test para el TriggerHelper de CampaignMember
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR								DATE				Description
	1.0			US584499            Mamen Arias         				20/04/2023          Init Version
	1.1			US586998			Daniel Rodriguez					07/06/2023			Add method contadorCheckIn_Test
	1.2			US635293			Carolina Lopez/Humberto Vilchez	    23/06/2023			Add method executeCampaignMemberSendEmail
    1.3			US661500			Carolina Lopez	   				    25/07/2023			Modify method executeCampaignMemberSendEmail to include new field EV_TechSummit__c and remove RT TechSummit
    1.4			US680535			Humberto Vilchez   				    01/08/2023			Modify method executeCampaignMemberSendEmail for fix test error WS, add SeeAllData = true in linkUniqueSurveyGenerationAsistio_Tes, linkUniqueSurveyGenerationAsistioNew_Test methods
	1.5         US680535            Carolina Lopez                      18/08/2023			Add method executeCampaignMemberSendEmailFisico	
	1.6			US657362			Mamen Arias							01/09/2023			Modify method contadorCheckIn_Test with active Survey		
	1.7			US738796			Carolina Lopez						19/10/2023			Include CC_InterfaceSettings__mdt in methods executeCampaignMemberBUTriggerGenerarQR, testEventSurvey, executeCampaignMemberSendEmail, executeCampaignMemberSendEmailFisico and contadoresTest	
	1.8			US785364            Daniel Rodriguez    				21/12/2023 			Modify methods to new callout Adobe Campaign
	1.9			TechSummit			Carolina Lopez						22/05/2024			Modify methods executeCampaignMemberSendEmail, executeCampaignMemberSendEmailFisico.
	2.0			TechSummit			Carolina Lopez						05/06/2024			Modify logic of methods executeCampaignMemberSendEmail, executeCampaignMemberSendEmailFisico.
***********************************************************************************************************************/
@isTest
public with sharing class EV_CampaignMemberCTriggerHelper_Test {

	@isTest
	private static void memberCampaignWithoutAccountTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();

		Test.startTest();
		
		System.runAs(newUser){
			campMember = EV_TestHelper.createCampaignMemberCustomContact(false, true);
			campMember.EV_Empresa__c = true;
			Database.update(campMember);
		}
		
		Test.stopTest();

		System.assertEquals(true, campMember.EV_Empresa__c, 'UPDATE OK');
	}

	@isTest (SeeAllData=true)
	public static void executeCampaignMemberBUTriggerGenerarQR() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();

		Test.startTest(); 

		System.runAs(newUser){
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
			campMember = EV_TestHelper.createCampaignMemberCustomContact(false, true);

			campMember.EV_Status__c ='Invitación enviada';
			update campMember;
			
			Survey surv = [SELECT Id FROM Survey WHERE ActiveVersionId != null LIMIT 1];
			Campaign camp = new Campaign(Id=campMember.EV_CampaignId__c, EV_Encuesta__c=surv.Id);
			update camp;
			
			campMember.EV_ContadorCheckInVirtual__c = 1;
			campMember.EV_Status__c ='Registro Confirmado';
			update campMember;
		}

		Test.stopTest();

		System.assertEquals('Registro Confirmado', campMember.EV_Status__c, 'Se ha confirmado el registro');
	}
	
	@isTest (SeeAllData=true)
	public static void testEventSurvey(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();

		System.runAs(newUser){
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
			
			campMember =  EV_TestHelper.createCampaignMemberCustomLead(true,false);
			Survey surv = [SELECT Id FROM Survey WHERE ActiveVersionId != null LIMIT 1];        
			Campaign camp = new Campaign(Id=campMember.EV_CampaignId__c, EV_Encuesta__c=surv.Id);
			update camp;
		}

		Test.startTest();
		System.runAs(newUser){
			Account acc = EV_TestHelper.createEmpresa();
            
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
            
			EV_CampaignMemberC__c campMem = new EV_CampaignMemberC__c();
			campMem.EV_AccountId__c =acc.Id;
			campMem.EV_CampaignId__c = campMember.EV_CampaignId__c;
			campMem.EV_ExternalId__c = '123456789';
			campMem.EV_Status__c = 'Pendiente';
			insert campMem;

			Lead l = [SELECT Id, EV_Account__c FROM Lead WHERE Id = :campMember.EV_LeadId__c ];
			l.EV_Account__c = acc.Id;
			update l;

			campMember.EV_Status__c = 'Asistió';
			update campMember;
		}
		Test.stopTest();
		
		System.assertEquals('Asistió', campMember.EV_Status__c, 'Ha asistido al evento');
	}

	@isTest (SeeAllData=true)
	public static void linkUniqueSurveyGenerationAsistioTest() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();

		Test.startTest();
		System.runAs(newUser){
			campMember = EV_TestHelper.createCampaignMemberCustomContact(false, true);
			Survey surv = [SELECT Id FROM Survey WHERE ActiveVersionId != null LIMIT 1];
            Campaign camp = [SELECT Id, EV_Encuesta__c FROM Campaign WHERE Id = :campMember.EV_CampaignId__c LIMIT 1];
            camp.EV_Encuesta__c = surv.Id;
			update camp;
			campMember.EV_Status__c ='Asistió';
			update campMember;

			campMember = [SELECT Id, EV_URLEncuesta__c, EV_InvitacionEncuesta__c FROM EV_CampaignMemberC__c WHERE Id = :campMember.Id LIMIT 1];
		}
		Test.stopTest();

		System.assertEquals(String.isNotBlank(campMember.EV_URLEncuesta__c), true, 'LINK de encuesta');
	}

	@isTest (SeeAllData=true)
	public static void linkUniqueSurveyGenerationAsistioNewTest() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();
 
		Test.startTest();

		System.runAs(newUser){
			campMember = EV_TestHelper.createCampaignMemberCustomContactFisicaSurvey('Asistió');
			campMember = [SELECT Id, EV_InvitacionEncuesta__c FROM EV_CampaignMemberC__c WHERE Id = :campMember.Id LIMIT 1];
		}

		Test.stopTest();

		System.assertEquals(String.isNotBlank(campMember.EV_InvitacionEncuesta__c), true, 'Invitación enviada');
	}
    
    @isTest
	public static void deleteCM() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
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

        System.assertEquals(campH.EV_CampaignMember_Id__c, campMember.Id, 'DELETE OK');
    }
    
     @isTest (SeeAllData=true)
	public static void inscriptionNRTCliente() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();

		Test.startTest();
		System.runAs(newUser){
			Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));
			campMember = EV_TestHelper.createCampaignMemberCustomContact(false, true);
			campMember.EV_Status__c='Registro confirmado';
			campMember.EV_EmailDeCampana__c = 'prueba@prueba.com';
			update campMember;		
		}
		Test.stopTest();

		System.assertEquals(campMember.EV_ExternalID__c != null, campMember.EV_ExternalID__c != null, 'El external ID es incorrecto');
	}
    
    @isTest (SeeAllData=true)
	public static void contadorCheckInTest() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();

		Test.startTest();
		System.runAs(newUser){
			campMember = EV_TestHelper.createCampaignMemberCustomContact(false, true);
			Survey surv = [SELECT Id FROM Survey WHERE ActiveVersionId != null LIMIT 1];
            Campaign camp = [SELECT Id, EV_Encuesta__c FROM Campaign WHERE Id = :campMember.EV_CampaignId__c LIMIT 1];
            camp.EV_Encuesta__c = surv.Id;
			update camp;
			campMember = [SELECT Id,EV_ExternalId__c, Recordtype.name FROM EV_CampaignMemberC__c WHERE Id = :campMember.Id LIMIT 1];
            EV_CampaingMemeberStaging__c cmpC = new EV_CampaingMemeberStaging__c(
            EV_ExternalId__c = campMember.EV_ExternalID__c,
            EV_ContadorCheckInVirtual__c= 1,
		    EV_Origen__c = 'Newsletter',
			EV_Canal__c = 'I');
            insert cmpC;
		}
		Test.stopTest();

		System.assertEquals(String.isNotBlank(campMember.EV_ExternalId__c), true, 'OK');
	}

    @isTest(SeeAllData=true)
    public static void executeCampaignMemberSendEmail() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Lead interlocutor = new Lead();
		Campaign campTechSumm = new Campaign();
		EV_CampaignMemberC__c campMember  = new EV_CampaignMemberC__c();
		System.runAs(newUser){  
            interlocutor = EV_TestHelper.createLeadAuxTechSummit('Tech Summit Virtual');
            campTechSumm = EV_TestHelper.createCampaignTechSummit(true, false);
			campMember = EV_TestHelper.createCampaignMemberLeadCampaignTechSummit(interlocutor.Id, campTechSumm.Id, 'Registro Confirmado');

		}
        System.runAs(newUser){  
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
            EV_CampaignMemberC__c campMemToCheck = [SELECT id FROM EV_CampaignMemberC__c WHERE EV_LeadId__c =: interlocutor.Id];
            System.assertEquals(campMemToCheck.Id, campMember.Id, 'Envío de email');
            Test.stopTest();
        }
    }

	@isTest(SeeAllData=true)
    public static void executeCampaignMemberSendEmailFisico() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Lead interlocutor = new Lead();
		Campaign campTechSumm = new Campaign();
		EV_CampaignMemberC__c campMember  = new EV_CampaignMemberC__c();
		System.runAs(newUser){ 
			interlocutor = EV_TestHelper.createLeadAuxTechSummit('Tech Summit Fisico');
            campTechSumm = EV_TestHelper.createCampaignTechSummit(false, true);
			campMember = EV_TestHelper.createCampaignMemberLeadCampaignTechSummit(interlocutor.Id, campTechSumm.Id, 'Registro Confirmado');
		}
        System.runAs(newUser){  
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
            EV_CampaignMemberC__c campMemToCheck = [SELECT id FROM EV_CampaignMemberC__c WHERE EV_LeadId__c =: interlocutor.Id];
            System.assertEquals(campMemToCheck.Id, campMember.Id, 'Envío de email evento fisico');
            Test.stopTest();
        }
    }
    
    @isTest (SeeAllData=true)
		public static void contadoresTest() {
            User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
            EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();
            Campaign camp = new Campaign();
 
    
            Test.startTest();
            System.runAs(newUser){
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
                campMember = EV_TestHelper.createCampaignMemberCustomContact(false, true);
            
                camp = [SELECT Id, Status, EV_TotalInscritosC__c FROM Campaign WHERE Id = :campMember.EV_CampaignId__c LIMIT 1];
                
                campMember = [SELECT Id, EV_ExternalId__c, EV_Status__c FROM EV_CampaignMemberC__c WHERE Id = :campMember.Id LIMIT 1];
                campMember.EV_Status__c = 'Registro Confirmado';
                update campMember;
                
                EV_CampaignMemberC__c campMember2 = new EV_CampaignMemberC__c();
                campMember2 = EV_TestHelper.createCampaignMemberCustomContact(true, false);
                campMember2.EV_CampaignId__c = camp.Id;
                campMember2.EV_Status__c = 'Registro Confirmado';
                update campMember2;
                
                camp.EV_TotalInscritosC__c = 2;
                update camp;
            }
            Test.stopTest();
                
            System.assertEquals(2, camp.EV_TotalInscritosC__c, 'Total inscritos');
        }
}