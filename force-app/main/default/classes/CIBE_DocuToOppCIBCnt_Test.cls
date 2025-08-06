/**********************************************************************************************************************
Name:      CIBE_DocuToOppCIBCnt_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase CIBE_DocumentsToOpportunityCIBCnt
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION        USER_STORY		AUTHOR              DATE                Description
	1.0            Init             Sandra Gómez        13/08/2024          Init version
	1.1            Init             Lucía        		22/08/2024          Modification of methods

***********************************************************************************************************************/
@isTest
public with sharing class CIBE_DocuToOppCIBCnt_Test {
	@TestSetup
	static void setup() {
		CIBE_TestInitialSetup.setupInitialDataCIB();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];

		System.runAs(usrSetup) {
			Account cliente = CIBE_TestHelper.createCustomer();
			Account centroCaixa = CIBE_TestHelper.createCaixaCenter();
			RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
				Opportunity opp = new Opportunity();
				opp.OwnerId = usuario.Id;
				opp.AccountId = cliente.Id;
				opp.Name = 'Alerta Comercial T1';
				opp.StageName = 'En gestión/insistir';
				opp.RecordTypeId = rt.Id;
				opp.CloseDate = System.today() + 5;
				opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
			insert opp;

			Opportunity opp2 = new Opportunity();
				opp2.OwnerId = usuario.Id;
				opp2.AccountId = cliente.Id;
				opp2.Name = 'Alerta Comercial T2';
				opp2.StageName = 'En gestión/insistir';
				opp2.RecordTypeId = rt.Id;
				opp2.CloseDate = System.today() + 5;
				opp2.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial 2';
			insert opp2;

			ContentVersion contentVersion = new ContentVersion(
			Title = 'a picture',
			PathOnClient = 'Pic.jpg',
			VersionData = Blob.valueOf('Test Content'),
			IsMajorVersion = true);
			insert contentVersion;

			List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

			//create ContentDocumentLink record
			ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.LinkedEntityId = opp.Id;
			cdl.ContentDocumentId = documents[0].Id;
			cdl.ShareType = 'V';
			cdl.Visibility = 'AllUsers';
			insert cdl;

			Id recordId = [select id, DeveloperName  from RecordType where SobjectType = 'CBK_Log__c' and  DeveloperName  = 'Apex_Log'].Id;

			CBK_Log__c log = New CBK_Log__c();
        	log.Apex_Class__c = documents[0].Id;
			log.Transaction_ID__c = usuario.Id;
			log.state__c = 'Pendiente';
			log.RecordTypeId = recordId;
			insert log;

		}

	}

	@isTest
	public static void validateGetDocuments() {
		User us = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		List<ContentDocument> listCD = new List<ContentDocument>();
		System.runAs(us) {
			Test.startTest();
			listCD = CIBE_DocumentsToOpportunityCIBCnt.getDocuments();
			Test.stopTest();
		}
		System.assertEquals(1, listCD.size());
	}

	@isTest
	public static void validateGetOpportunities() {
		User us = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		List<Opportunity> listOpp = new List<Opportunity>();
		List<Opportunity> listOpp2 = new List<Opportunity>();
		System.runAs(us) {
			Test.startTest();
			listOpp = CIBE_DocumentsToOpportunityCIBCnt.getOpportunities('Name',null);
			listOpp2 = CIBE_DocumentsToOpportunityCIBCnt.getOpportunities(null,'Alerta Comercial');
			Test.stopTest();
		}
		System.assertEquals(listOpp.size(), 2);
		System.assertEquals(listOpp2.size(), 2);
	}

	@isTest
	public static void validateUpdateState() {
		User us = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
		List<String> documentIds = new List<String>();
		String result;
		String logState;

		System.runAs(usrSetup){
			List<ContentDocument> cds = [Select Id from ContentDocument limit 1];
			for (ContentDocument cd : cds) {
				documentIds.add(cd.Id);
			}
		}

		System.runAs(us) {
			Test.startTest();
			result = CIBE_DocumentsToOpportunityCIBCnt.updateState(documentIds);
			logState = [SELECT Id, state__c FROM CBK_Log__c WHERE RecordType.Developername='Apex_Log'  AND Apex_Class__c IN :documentIds].state__c;
			Test.stopTest();
		}
		System.assertEquals(result, '');
		System.assertEquals(logState, 'Descartado');
	}

	@isTest
	public static void validateVincDocusOpp() {
		User us = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
		List<String> documentIds = new List<String>();
		String logState;
		System.runAs(usrSetup){
			List<ContentDocument> cds = [Select Id from ContentDocument limit 1];

			for (ContentDocument cd : cds) {
				documentIds.add(cd.Id);
			}
		}
		String opportunityId = [Select Id from Opportunity where name = 'Alerta Comercial T2' limit 1].Id;
		String result;
		System.runAs(us) {
			Test.startTest();
			result = CIBE_DocumentsToOpportunityCIBCnt.vincDocusOpp(documentIds,opportunityId);
			logState = [SELECT Id, state__c FROM CBK_Log__c WHERE RecordType.Developername='Apex_Log'  AND Apex_Class__c IN :documentIds].state__c;
			Test.stopTest();
		}
		System.assertEquals(result, '');
		System.assertEquals(logState, 'Completado');
	}
}