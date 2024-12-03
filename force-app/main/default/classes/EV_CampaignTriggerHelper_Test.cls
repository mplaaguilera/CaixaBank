/**********************************************************************************************************************
 Name:	  EV_CampaignTriggerHelper_Test
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			                    Eric Vázquez		26/03/2021			Init version
	1.1			                    Eric Vázquez		10/06/2021			fix validation
	1.2								Mamen Arias			23/01/2023			Add method validateChangeStatusApuntoDeEmpezarCambioFecha()
	1.3								Daniel Rodriguez	01/02/2023			Modify method validateChangeStatusApuntoDeEmpezarCambioFecha, validateCalculoSharing, makeData. Create method validateChangeCartera
	1.4			US555430			Daniel Rodriguez 	14/03/2023			Delete method validateChangeStatusApuntoDeEmpezarCambioFecha. Modify method validateChangeStatusInvitacionesEnviadas, validateChangeStatusFinalizado, validateChangeStatusEnCurso 
	1.6 		US587001			Daniel Rodriguez	23/05/2023			Modify makeData, delete traductTest of childcampaign and reorder
	1.7			US586998			Daniel Rodriguez	19/06/2023			Create method rollupChangeStatusTest 
	1.8			DE75856				Carolina Lopez		05/10/2023			Modify method makeData.
	1.9			US738796			Carolina Lopez		19/10/2023			Include CC_InterfaceSettings__mdt in method rollupChangeStatusTest
	1.10		FIX					Mamen Arias			26/01/2024			Fix all methods with runAs, modify method rollupChangeStatusTest with newArchitecture and seeAllData > ConnectApi. Remove testSetup
	1.11		US854993			Carolina Lopez		09/04/2024			Add methods visiblePortalInformationTest.
	1.12		TechSummit			Carolina Lopez		16/05/2024			Add method setTechSummitCampaignTest.
***********************************************************************************************************************/
@isTest
public with sharing class EV_CampaignTriggerHelper_Test {

	@isTest
	public static void newFlowACTest() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Account centroCaixa = new Account();
		Campaign campTest = new Campaign();
		System.runAs(newUser){
			centroCaixa = EV_TestHelper.createCaixaCenter();
			campTest = EV_TestHelper.createChildCampaignVirtual(centroCaixa, null);
			campTest.Status = '002';
			update campTest;
		}

		Test.startTest();
		System.runAs(newUser){
			campTest.Status = '009';
			update campTest;
		}
		Test.stopTest();
		System.assertEquals('009', campTest.Status, 'El estado no es correcto');
	}

	@isTest
	public static void visiblePortalInformationTest() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Campaign campTest = new Campaign();
		EV_PortalCaixaBankTalks__c updatePortal = new EV_PortalCaixaBankTalks__c();

		System.runAs(newUser){
			campTest = EV_TestHelper.createChildCampaignVirtualCMCustom();
			EV_PortalCaixaBankTalks__c portal = new EV_PortalCaixaBankTalks__c(EV_Posicionamiento__c = '001', EV_Orden__c= '1' , EV_Fechadespublicacion__c = Date.valueOf('2020-02-10'), EV_Evento__c = campTest.Id);
			insert portal;
		}
		Test.startTest();
			System.runAs(newUser){
				campTest.EV_Fechadespublicacion__c = Date.newInstance(2024, 4, 11);
				update campTest;

				updatePortal = [SELECT Id, EV_Orden__c, EV_Posicionamiento__c, EV_Fechadespublicacion__c FROM EV_PortalCaixaBankTalks__c WHERE EV_Evento__c = :campTest.Id LIMIT 1];	
			}
		Test.stopTest();
		System.assertEquals(updatePortal.EV_Fechadespublicacion__c, Date.valueOf('2024-04-11'));
	}

	@isTest
	public static void validateEventToTranslationsTest() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Account centroCaixa = new Account();
		Campaign campTest = new Campaign();
		Campaign campParentTest = new Campaign();

		System.runAs(newUser){
			centroCaixa = EV_TestHelper.createCaixaCenter();
			campParentTest = EV_TestHelper.createParentCampaignVirtual();
			campTest = EV_TestHelper.createChildCampaignVirtual(centroCaixa, campParentTest);
			campTest.Status = '002';
			campTest.EV_URLDelEventoVirtual__c = 'test';
			update campTest;
		}

		Test.startTest();
		System.runAs(newUser){
			List<EV_TraduccionDeEvento__c> listTraduct = [SELECT Id, EV_URLImagenEsperaStreaming__c FROM EV_TraduccionDeEvento__c WHERE EV_Evento__c = :campTest.Id];
			if (listTraduct != null && !listTraduct.isEmpty()){
				for (EV_TraduccionDeEvento__c trad: listTraduct){
					trad.EV_URLImagenEsperaStreaming__c = 'test';
				}
				update listTraduct;
			}
			campTest.Status = '009';
			update campTest;
		}
		Test.stopTest();
		System.assertEquals('009', campTest.Status, 'El estado no es correcto');
	}

	@isTest
	public static void validateShareCampaing() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Account centroCaixa = new Account();
		Campaign campTest = new Campaign();
		List<Campaign> listCampaign = new List<Campaign>();
		CampaignShare cs = new CampaignShare();

		System.runAs(newUser){
			centroCaixa = EV_TestHelper.createCaixaCenter();
			campTest = EV_TestHelper.createChildCampaignVirtual(centroCaixa, null);
		}
		
		Test.startTest();
		System.runAs(newUser){
			listCampaign = [SELECT Id, EV_CentroAdminstrador__c, EV_CentroPromotor__c, EV_CentroOrganizador__c FROM Campaign WHERE EV_ExternalId__c = '1234567890'];
			cs = [SELECT Id, CampaignId, UserOrGroupId, CampaignAccessLevel FROM CampaignShare WHERE CampaignId IN :listCampaign];
			EV_CampaignTriggerHelper.shareCampaign(listCampaign, null);
		}
		Test.stopTest();
		System.assertEquals('All', cs.CampaignAccessLevel, 'No tiene visibilidad All');
	}

	@isTest
	public static void validateCalculoSharing() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Campaign campTest = new Campaign();
		List<String> lista = new List<String>();
		System.runAs(newUser){
			campTest = EV_TestHelper.createChildCampaignVirtual();
		}

		Test.startTest();
		System.runAs(newUser){
			lista = EV_CampaignTriggerHelper.calculoSharing(new List<String>{campTest.Id});
		}
		Test.stopTest();
		System.assertEquals('(OK)', String.valueOf(lista), 'No es OK el calculoSharing');
	}

	@isTest
	public static void validateFillCarteraParent() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Campaign campParentTest = new Campaign();
		Campaign campTest = new Campaign();
		
		System.runAs(newUser){
			campParentTest = EV_TestHelper.createParentCampaignVirtual();
			campTest = EV_TestHelper.createChildCampaignVirtual(null,campParentTest);
		}

		Test.startTest();
		System.runAs(newUser){
			List<Campaign> listNews = new List<Campaign>();
			listNews.add(campTest);
			EV_CampaignTriggerHelper.fillCarteraParent(listNews);
		}
		Test.stopTest();
		System.assertEquals('BPA', campTest.EV_Cartera__c, 'La cartera no es BPA');
	}

	@isTest
	public static void validateChangeStatusInvitacionesEnviadas(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Account centroCaixa = new Account();
		Campaign campTest = new Campaign();
		Campaign campTest2 = new Campaign();
		List<Campaign> listUpdate = new List<Campaign>();
		Map<Id, Campaign> oldMapCampaign = new Map<Id, Campaign>();

		System.runAs(newUser){
			centroCaixa = EV_TestHelper.createCaixaCenter();
			campTest = EV_TestHelper.createChildCampaignVirtual();
			campTest2 = EV_TestHelper.createChildCampaignVirtual(centroCaixa,null);
			oldMapCampaign.put(campTest.Id, campTest);

		}
	
		Test.startTest();
		System.runAs(newUser){		
			campTest.Status = '003';
			campTest2.Status = '003';
			listUpdate.add(campTest);
			listUpdate.add(campTest2);
			update listUpdate;
		  
			List<Campaign> listNews = new List<Campaign>();
			listNews.add(campTest);
		}
		Test.stopTest();
		System.assertEquals('003', campTest.Status, 'El estado no es correcto');
	}


	@isTest
	public static void validateChangeStatusEnCurso(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Account centroCaixa = new Account();
		Campaign campTest = new Campaign();
		Campaign campTest2 = new Campaign();
		List<Campaign> listUpdate = new List<Campaign>();

		System.runAs(newUser){
			centroCaixa = EV_TestHelper.createCaixaCenter();
			campTest = EV_TestHelper.createChildCampaignVirtual();
			campTest2 = EV_TestHelper.createChildCampaignVirtual(centroCaixa,null);
		}

		Test.startTest();
		System.runAs(newUser){
			campTest.Status = '012';
			campTest2.Status = '012';
			listUpdate.add(campTest);
			listUpdate.add(campTest2);
			update listUpdate;
			listUpdate.clear();
			campTest2.Status = '003';
			listUpdate.add(campTest2);
			update listUpdate;
		}
		Test.stopTest();
		System.assertEquals('012', campTest.Status, 'El estado no es correcto');
	}

	@isTest
	public static void validateChangeStatusFinalizado(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Account centroCaixa = new Account();
		Campaign campTest = new Campaign();
		Campaign campTest2 = new Campaign();
		List<Campaign> listUpdate = new List<Campaign>();

		System.runAs(newUser){
			centroCaixa = EV_TestHelper.createCaixaCenter();
			campTest = EV_TestHelper.createChildCampaignVirtual();
			campTest2 = EV_TestHelper.createChildCampaignVirtual(centroCaixa,null);
		}

		Test.startTest();
		System.runAs(newUser){
			campTest.Status = '004';
			campTest2.Status = '004';
			listUpdate.add(campTest);
			listUpdate.add(campTest2);
			update listUpdate;
		}
		Test.stopTest();
		System.assertEquals('004', campTest.Status, 'El estado no es correcto');
	}

	@isTest
	public static void validateChangeStatusEventsFestivales(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Campaign campTest = new Campaign();

		System.runAs(newUser){
			Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(Label.EV_FestivalesYexperiencias).getRecordTypeId();
			campTest.Name = 'TestCampaign';
			campTest.RecordTypeId = rtEvento;
			campTest.EV_ExternalId__c = '123456789';
			campTest.StartDate = Date.today();
			campTest.EV_HoraInicio__c = Time.newInstance(16, 30, 00, 00);
			campTest.EV_HoraFin__c = Time.newInstance(19, 30, 00, 00);
			campTest.EV_Notification__c = '001';
			campTest.Status = '002';
			insert campTest;
			EV_TestHelper.createTraduccionesDeEvento(campTest.Id);
		}

		Test.startTest();
		System.runAs(newUser){
			try{
				campTest.Status = '009';
                update campTest;
            } catch (Exception e){
                Test.stopTest();
                System.assertEquals(e.getMessage().contains('Necesitas informar el espacio Festivales y otras experiencias de las traducciones'), true, 'El mensaje de error no es correcto');
            }
		}
	}

	@isTest
	public static void validateChangeCartera(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Campaign campTest = new Campaign();
		Campaign campParentTest = new Campaign();
		List<EV_MappingCriterioPO__mdt> listMC = new List<EV_MappingCriterioPO__mdt>();
		Map<String, EV_MappingCriterioPO__mdt> mapMC = new Map<String, EV_MappingCriterioPO__mdt>();
		List<EV_VariablePublicoOjetivo__c> varPOTest = new List<EV_VariablePublicoOjetivo__c>();
		List<EV_CriterioPublicoObjetivo__c> poTestParent = new List<EV_CriterioPublicoObjetivo__c>();
		List<EV_CriterioPublicoObjetivo__c> poTest = new List<EV_CriterioPublicoObjetivo__c>();

		System.runAs(newUser){
			mapMC = new Map<String, EV_MappingCriterioPO__mdt>();
			listMC = [SELECT Id, Label, EV_FieldName__c FROM EV_MappingCriterioPO__mdt];
			for(EV_MappingCriterioPO__mdt mc: listMC){
				mapMC.put(mc.label, mc);
			}
			varPOTest = EV_TestHelper.createVariablePublicoObjetivo(mapMC);
			campParentTest = EV_TestHelper.createParentCampaignVirtual();
			poTestParent = EV_TestHelper.createPublicObjetivo(campParentTest.Id, varPOTest);
			campTest = EV_TestHelper.createChildCampaignVirtual(null, campParentTest);
			poTest = EV_TestHelper.createPublicObjetivo(campTest.Id, varPOTest);
		}

		Test.startTest();
		System.runAs(newUser){
			campTest.EV_Cartera__c = 'BPE';
			update campTest;
		}
		Test.stopTest();
		System.assertEquals('BPE', campTest.EV_Cartera__c, 'La cartera no es correcta');
	}

	@isTest (seeAllData=true)
	public static void rollupChangeStatusTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		EV_CampaignMemberC__c campMember = new EV_CampaignMemberC__c();
		EV_CampaignMemberC__c campMemberSearch = new EV_CampaignMemberC__c();
		Campaign camp = new campaign();
		String idCampTest = '';
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
			campMember =  EV_TestHelper.createCampaignMemberCustomLead(false,true);
		}

		Test.startTest();
		System.runAs(newUser){
			campMemberSearch = [SELECT Id, EV_CampaignId__c, EV_Status__c FROM Ev_CampaignMemberC__c WHERE Id =: campMember.id];
			campMemberSearch.EV_Status__c = 'Registro confirmado';
			update campMemberSearch;
			camp =  [SELECT Id, Status, RecordTypeId, EV_FechaHoraFin__c, EV_DiaHora_evento__c, EV_ExternalId__c, EV_FlujoPruebas__c FROM Campaign WHERE ID =: campMemberSearch.EV_CampaignId__c LIMIT 1];
			camp.EV_FlujoPruebas__c = '003';
			camp.Status = '005';
			update camp;
		}
		Test.stopTest();
		System.assertEquals('005', camp.Status, 'El estado del evento no es correcto');
	}
	
	@isTest 
	public static void setTechSummitCampaignTest() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Campaign campTest = new Campaign();

		Test.startTest();
		System.runAs(newUser){
			campTest = EV_TestHelper.createChildCampaignVirtualCMCustomTechSummit();
		}
		Test.stopTest();
		System.assertEquals(campTest.EV_TechSummit__c == true, campTest.EV_TechSummit__c, 'No se ha cambiado a tipo TechSummit al generar el evento.');
	}
}