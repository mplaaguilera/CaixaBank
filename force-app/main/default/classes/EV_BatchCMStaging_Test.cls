/**********************************************************************************************************************
 Name:	  EV_BatchCMStaging_Test
 Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Clase para batch de EV_BatchCMStaging_Test
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		                	  Daniel Rodriguez    30/09/2022			Add class test
	1.1		      US511092    	  Daniel Rodriguez    08/01/2024			Add method executeBatchErrorTest3
***********************************************************************************************************************/

@isTest
public with sharing class EV_BatchCMStaging_Test {

	@isTest (SeeAllData=false)
	public static void executeBatchTest() {
		List<EV_CampaingMemeberStaging__c> listcms = new List<EV_CampaingMemeberStaging__c>();
		CampaignMember cm = EV_TestHelper.createCampaignMemberContact(true, false);
		listcms.add(EV_TestHelper.createCMStaging(cm));
		listcms.add(EV_TestHelper.createCMStaging(cm));
		Test.startTest();
		EV_BatchCMStaging bcms = new EV_BatchCMStaging();
		Id batchId = Database.executeBatch(bcms);
		Test.stopTest();
		System.assertEquals(batchId != null, true, 'true');

	}
	
	@isTest (SeeAllData=false)
	public static void executeBatchTest2() {
		List<EV_CampaingMemeberStaging__c> listcms = new List<EV_CampaingMemeberStaging__c>();
		CampaignMember cm = EV_TestHelper.createCampaignMemberContact(true, false);
	   	//Survey sur = [Select id from Survey limit 1];
		//SurveyInvitation  invitation = new SurveyInvitation (EV_Campaign__c = cm.CampaignId);
		Campaign campm = [Select id from Campaign where id = :cm.CampaignId];
		listcms.add(EV_TestHelper.createCMStaging(cm));
		Test.startTest();
		EV_BatchCMStaging bcms = new EV_BatchCMStaging();
		Id batchId = Database.executeBatch(bcms);
		Test.stopTest();
		System.assertEquals(batchId != null, true, 'true');

	}
	@isTest 
	public static void executeBatchErrorTest3() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Id batchId = null;

		System.runAs(newUser){
			List<EV_CampaingMemeberStaging__c> listcms = new List<EV_CampaingMemeberStaging__c>();
			CampaignMember cm = EV_TestHelper.createCampaignMemberContact(true, false);
			Campaign camp = [SELECT Id, Recordtype.name, EV_LimiteRegistrosVirtuales__c FROM Campaign LIMIT 1];
			camp.EV_LimiteRegistrosVirtuales__c = 1;
			update camp;
			Campaign campm = [SELECT Id FROM Campaign WHERE Id = :cm.CampaignId];
				EV_CampaingMemeberStaging__c cms = new EV_CampaingMemeberStaging__c(
				EV_ExternalId__c = cm.EV_ExternalId__c,
				EV_CampaignMemberId__c = cm.id,
				EV_ContadorCheckInVirtual__c = 1,
				EV_Origen__c = 'Push',
				EV_Numperso__c ='123456789',
				EV_Canal__c = 'I',
				EV_Status__c = 'Reprocess' 
			);
			insert cms;
		}

		Test.startTest();
		System.runAs(newUser){
			String jobId = System.schedule('Test Job', '0 0 0 ? * * *', new EV_BatchCMStaging());
			EV_BatchCMStaging bcms = new EV_BatchCMStaging();
			batchId = Database.executeBatch(bcms);
		}
		Test.stopTest();
		System.assertEquals(batchId != null, true, 'true');
	}
}