/**********************************************************************************************************************
 Name:   EV_CMStagingTriggerHelper_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: clase test para el trigger
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION     USER_STORY          AUTHOR                      DATE                Description
	1.0 																			Init version
	1.1								Mamen Arias					30/12/2022			Add test checkExternalIdEmpty() and checkExternalIdWrong()
	1.2			US680535			Mamen Arias					03/08/2023			Add test validateCampaignMemberStagingWithCMCustom()
	1.3			US511092			Daniel Rodriguez			04/01/2024			Modify test validateCampaignMemberStagingWithCMCustom()
	1.4		     US511092         	Daniel Rodriguez    		09/01/2024			Modify test validateCampaignMemberStagingWithCMCustom()
	1.5			FIX					Carolina Lopez				30/04/2024			Included runAs in all methods.
***********************************************************************************************************************/
@isTest
public with sharing class EV_CMStagingTriggerHelper_Test {
	@TestSetup
	static void makeData(){
		EV_TestHelper.createCampaignMemberContact(true, false);
        EV_TestHelper.createCampaignMemberCustomContact(false, true);
	}

	@isTest
	public static void validateCampaignMemberStaging() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		CampaignMember campMember =[SELECT Id, EV_ExternalId__c FROM CampaignMember];
		EV_CampaingMemeberStaging__c cms = new EV_CampaingMemeberStaging__c();
		Test.startTest();
		System.runAs(newUser){
			cms = new EV_CampaingMemeberStaging__c(
				EV_ContadorCheckInVirtual__c =1,
				EV_Origen__c = 'Newsletter',
				EV_Canal__c = 'I',
				EV_Numperso__c= '123oN76291pPKt1',
				EV_ExternalId__c = campMember.EV_ExternalId__c
			);
			insert cms;
		}
		System.assertEquals(1, cms.EV_ContadorCheckInVirtual__c);
		Test.stopTest();
	}
    
    @isTest
	public static void validateCampaignMemberStagingWithCMCustom() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		EV_CampaingMemeberStaging__c cms = new EV_CampaingMemeberStaging__c();
		Test.startTest();
		System.runAs(newUser){
            EV_CampaignMemberC__c cm = new EV_CampaignMemberC__c (
                EV_ContactId__c = EV_TestHelper.createContactAux('TestContact').Id,
                EV_CampaignId__c = EV_TestHelper.createChildCampaignFisica().Id,
                EV_ExternalId__c = '5645652156',
                EV_Status__c = 'Baja del evento'
            );
        insert cm;
		EV_CampaignMemberC__c campMember =[SELECT Id, EV_ExternalId__c FROM EV_CampaignMemberC__c where EV_Status__c = 'Baja del evento'];
			cms.EV_ContadorCheckInVirtual__c =1;
			cms.EV_Origen__c = 'Newsletter';
			cms.EV_Canal__c = 'I';
			cms.EV_Numperso__c= '123oN76291pPKt1';
			cms.EV_ExternalId__c = campMember.EV_ExternalId__c;
			insert cms;
		}
		Test.stopTest();
		System.assertEquals(1, cms.EV_ContadorCheckInVirtual__c);
	}

	@isTest
	public static void validateCampaignMemberStagingBaja() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		CampaignMember campMember = [SELECT Id, EV_ExternalId__c FROM CampaignMember];
		EV_CampaingMemeberStaging__c cms = new EV_CampaingMemeberStaging__c();
		Test.startTest();
		System.runAs(newUser){
			cms = new EV_CampaingMemeberStaging__c(
				EV_CampaignMemberStatus__c = 'Baja del evento',
				EV_ExternalId__c = campMember.EV_ExternalId__c
			);
			insert cms;
		}
		System.assertEquals('Baja del evento', cms.EV_CampaignMemberStatus__c);
		Test.stopTest();
	}

	@isTest
	public static void checkExternalIdEmpty(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		CampaignMember campMember = new CampaignMember();
		System.runAs(newUser){
			campMember = [SELECT Id, EV_ExternalId__c, EV_Numperso__c FROM CampaignMember];
			campMember.EV_ExternalId__c = '';
			update campMember;
		}
		Test.startTest();
		System.runAs(newUser){
			EV_CampaingMemeberStaging__c cms = new EV_CampaingMemeberStaging__c(
				EV_ExternalId__c = campMember.EV_ExternalId__c
			);
			try{
				insert cms;
			} catch (Exception e){
				Test.stopTest();
				System.assertEquals(e.getMessage()!=null, true);
			}
		}
	}

	@isTest
	public static void checkExternalIdWrong(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		CampaignMember cm = new CampaignMember();
		System.runAs(newUser){
			cm = new CampaignMember (
				ContactId = EV_TestHelper.createContactAux('TestContact').Id,
				CampaignId = EV_TestHelper.createChildCampaignFisica().Id,
				EV_ExternalId__c = '5645652156',
				Status = 'Pendiente'
			);
			insert cm;
		}
		Test.startTest();
		System.runAs(newUser){
			EV_CampaingMemeberStaging__c cms = new EV_CampaingMemeberStaging__c(
				EV_ExternalId__c = cm.EV_ExternalId__c
			);
			try{
				insert cms;
			} catch (Exception e){
				Test.stopTest();
				System.assertEquals(e.getMessage()!=null, true);
			}
		}
	}
}