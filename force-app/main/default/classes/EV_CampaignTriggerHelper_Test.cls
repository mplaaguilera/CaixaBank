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
***********************************************************************************************************************/
@isTest
public with sharing class EV_CampaignTriggerHelper_Test {
    @TestSetup
	static void makeData(){
        
        List<EV_MappingCriterioPO__mdt> listMC = [SELECT Id, Label, EV_FieldName__c FROM EV_MappingCriterioPO__mdt];
        Map<String, EV_MappingCriterioPO__mdt> mapMC = new Map<String, EV_MappingCriterioPO__mdt>();
        for(EV_MappingCriterioPO__mdt mc: listMC){
            mapMC.put(mc.label, mc);
        }
        List<EV_VariablePublicoOjetivo__c> varPOTest = EV_TestHelper.createVariablePublicoObjetivo(mapMC);
		Account centroCaixa = EV_TestHelper.createCaixaCenter();
		Contact contacto = EV_TestHelper.createEmployee(centroCaixa);
		Campaign campParentTest = EV_TestHelper.createParentCampaignVirtual();
        List<EV_CriterioPublicoObjetivo__c> poTestParent = EV_TestHelper.createPublicObjetivo(campParentTest.Id, varPOTest);
		Campaign campTest = EV_TestHelper.createChildCampaignVirtual(centroCaixa, campParentTest);
		campTest.EV_CentroOrganizador__c = centroCaixa.Id; 
        update campTest;
		User user = EV_TestHelper.createUser('EV_Eventos');
		contacto.AV_UsuarioAsociado__c = user.Id;
        update contacto;
        List<EV_CriterioPublicoObjetivo__c> poTest = EV_TestHelper.createPublicObjetivo(campTest.Id, varPOTest);
		EV_CriterioPublicoObjetivo__c cpo = new EV_CriterioPublicoObjetivo__c();
	}

    @isTest
	public static void newFlowACTest() {
	
        Account centroCaixa = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'CC_CentroCaixaBank' Limit 1];
        Campaign campTest = EV_TestHelper.createChildCampaignVirtual(centroCaixa, null);
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
        System.runAs(user)
        {
        List<Campaign> listCampaign = [SELECT Id, EV_URLChatVirtual__c, Status, EV_URLImagenVideo__c FROM Campaign WHERE EV_ExternalID__c = '1234567890' LIMIT 1];
        List<EV_TraduccionDeEvento__c> listTraduct = [SELECT Id from EV_TraduccionDeEvento__c WHERE EV_Evento__c = :listCampaign[0].Id];
        Test.startTest();
        listCampaign[0].Status = '009';
        update listCampaign;
        Test.stopTest();
        System.assertEquals('009', listCampaign[0].Status);
        }
	}

	@isTest
	public static void validateEventToTranslationsTest() {
		Account centroCaixa = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'CC_CentroCaixaBank' Limit 1];
        Campaign campTest = EV_TestHelper.createChildCampaignVirtual(centroCaixa, null);
		
        List<Campaign> listCampaign = [SELECT Id, EV_URLChatVirtual__c, Status, EV_URLImagenVideo__c, EV_URLDelEventoVirtual__c FROM Campaign WHERE EV_ExternalId__c = '1234567890' LIMIT 1];
		
		List<EV_TraduccionDeEvento__c> listTraduct = [SELECT Id from EV_TraduccionDeEvento__c WHERE EV_Evento__c = :listCampaign[0].Id];
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
        System.runAs(user)
        {
		
        Test.startTest();
        listCampaign[0].Status = '009';
        update listCampaign;
        Test.stopTest();
		System.assertEquals('009', listCampaign[0].Status);
        }
	}

	@isTest
	public static void validateShareCampaing() {
		Account centroCaixa = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'CC_CentroCaixaBank' Limit 1];
        Campaign campTest = EV_TestHelper.createChildCampaignVirtual(centroCaixa, null);
		List<Campaign> listCampaign = [SELECT Id, EV_CentroAdminstrador__c, EV_CentroPromotor__c, EV_CentroOrganizador__c FROM Campaign WHERE EV_ExternalId__c = '1234567890' ];
		
		CampaignShare cs = [Select Id, CampaignId, UserOrGroupId, CampaignAccessLevel from CampaignShare where CampaignId in :listCampaign];
		User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
        System.runAs(user)
        {
		Test.startTest();
		
		EV_CampaignTriggerHelper.shareCampaign(listCampaign, null);
		Test.stopTest();
		System.assertEquals('All', cs.CampaignAccessLevel);
        }
	}

	@isTest
	public static void validateCalculoSharing() {
		User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
        
        System.runAs(user)
        {

		Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoVirtual').getRecordTypeId();
        Campaign  camp = [Select id, Status, EV_CentroOrganizador__c,EV_HoraInicio__c,EV_Notification__c, Recordtype.name from Campaign where RecordtypeId = :rtEvento];
		Test.startTest();
        EV_CampaignTriggerHelper.calculoSharing(new List<String>{camp.id});
		
		Test.stopTest();
		System.assertEquals('009', camp.Status);
		}
	}

	@isTest
	public static void validateFillCarteraParent() {
		Campaign campParentTest = EV_TestHelper.createParentCampaignVirtual();
		
		Campaign campTest = EV_TestHelper.createChildCampaignVirtual(null,campParentTest);
		User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
		
		System.runAs(user)
        {
			Test.startTest();
			Campaign camp = [SELECT Id, ParentId, EV_Cartera__c FROM Campaign WHERE EV_ExternalId__c = '1234567890'];
			List<Campaign> listNews = new List<Campaign>();
			listNews.add(camp);
			
			
			EV_CampaignTriggerHelper.fillCarteraParent(listNews);
			Test.stopTest();
			System.assertEquals('BPA', camp.EV_Cartera__c);
		}
	}

	@isTest
	public static void validateChangeStatusInvitacionesEnviadas(){
     	Campaign campTest = EV_TestHelper.createChildCampaignVirtual();
		Campaign camp =  [SELECT Id, Status, RecordTypeId, EV_FechaHoraFin__c, EV_DiaHora_evento__c, EV_ExternalId__c  FROM Campaign  WHERE Id =: campTest.Id];
        List<Campaign> upC = new List<Campaign>();
        Campaign camp2 =  [SELECT Id, Status, RecordTypeId, EV_FechaHoraFin__c, EV_DiaHora_evento__c, EV_ExternalId__c  FROM Campaign  WHERE EV_CentroOrganizador__c != null];
        User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
        Map<Id, Campaign> oldMapCampaign = new Map<Id, Campaign>();
        oldMapCampaign.put(campTest.Id, campTest);
        System.runAs(user)
        {
			Test.startTest();
            camp.Status = '003';
            camp2.Status = '003';
            upC.add(camp);
            upC.add(camp2);
            update upC;
          
            List<Campaign> listNews = new List<Campaign>();
            listNews.add(camp);
            Test.stopTest();
            System.assertEquals('003', camp.Status);
        }
	}


	@isTest
	public static void validateChangeStatusEnCurso(){

		Campaign campTest = EV_TestHelper.createChildCampaignVirtual();
        List<Campaign> upC = new List<Campaign>();
		Campaign camp =  [SELECT Id, Status, RecordTypeId, EV_FechaHoraFin__c, EV_DiaHora_evento__c, EV_ExternalId__c  FROM Campaign  WHERE Id =: campTest.Id];
        Campaign camp2 =  [SELECT Id, Status, RecordTypeId, EV_FechaHoraFin__c, EV_DiaHora_evento__c, EV_ExternalId__c  FROM Campaign  WHERE EV_CentroOrganizador__c != null];
		User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
		System.runAs(user)
        {
			Test.startTest();
			camp.Status = '012';
            camp2.Status = '012';
            upC.add(camp);
            upC.add(camp2);
            update upC;
            upC.clear();
            camp2.Status = '003';
            upC.add(camp2);
            update upC;
			Test.stopTest();
			System.assertEquals('012', camp.Status);
		}
	}

	@isTest
	public static void validateChangeStatusFinalizado(){

		Campaign campTest = EV_TestHelper.createChildCampaignVirtual();
		Campaign camp =  [SELECT Id, Status, RecordTypeId, EV_FechaHoraFin__c, EV_DiaHora_evento__c, EV_ExternalId__c  FROM Campaign  WHERE Id =: campTest.Id];
        List<Campaign> upC = new List<Campaign>();
        Campaign camp2 =  [SELECT Id, Status, RecordTypeId, EV_FechaHoraFin__c, EV_DiaHora_evento__c, EV_ExternalId__c  FROM Campaign  WHERE EV_CentroOrganizador__c != null];
		User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
		System.runAs(user)
        {
			Test.startTest();
			camp.Status = '004';
            camp2.Status = '004';
            upC.add(camp);
            upC.add(camp2);
			Test.stopTest();
			System.assertEquals('004', camp.Status);
		}
	}

	@isTest
	public static void validateChangeCartera(){
		Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoVirtual').getRecordTypeId();
        Campaign camp = [Select id, Status, EV_Cartera__c,EV_HoraInicio__c,EV_Notification__c, Recordtype.name from Campaign where RecordtypeId = :rtEvento];
		User user = [SELECT Id, FirstName, LastName FROM User LIMIT 1];
        
        System.runAs(user)
        {
		Test.startTest();
        camp.EV_Cartera__c = 'BPE';
        update camp;
		
		Test.stopTest();
        System.assertEquals('BPE', camp.EV_Cartera__c);
		}
	}

    @isTest
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
                header2TestResp.put('callout:EV_PROAdobeCampaign',new EV_AdobeCampaignInscripcion_Mock());
            } else {
                header2TestResp.put('callout:EV_PREAdobeCampaign',new EV_AdobeCampaignInscripcion_Mock());
            }
            
			HttpCalloutMock multiCalloutMock = new EV_multipleRequestConexionMock_Test(header2TestResp);
			Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            campMember =  EV_TestHelper.createCampaignMemberCustomLead(false,true);
        }
		Test.startTest();
		System.runAs(newUser){
            campMemberSearch = [Select id from Ev_CampaignMemberC__c where id =: campMember.id];
            campMemberSearch.EV_Status__c = 'Registro confirmado';
            update campMemberSearch;
            camp =  [SELECT Id, Status, RecordTypeId, EV_FechaHoraFin__c, EV_DiaHora_evento__c, EV_ExternalId__c  FROM Campaign  WHERE EV_NewArchitecture__c = true];
			camp.Status = '005';
            update camp;
		}
        Test.stopTest();
        System.assertEquals('005', camp.Status);
	}

}