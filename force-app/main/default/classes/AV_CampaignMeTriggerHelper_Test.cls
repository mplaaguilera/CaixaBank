/**********************************************************************************************************************
 Name:	  AV_CampaignMemberTriggerHelper_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test de AV_CampaignMemberTriggerHelper
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			App FSC            	Sandra Gómez		30/03/2022			Init version

***********************************************************************************************************************/
@isTest
public class AV_CampaignMeTriggerHelper_Test {

	@TestSetup
	static void setup() {
		User us=AV_TestHelper.createUser('','U0123456789');
		Contact co=AV_TestHelper.createEmployee(null,us);
		AV_TestHelper.createCampaignMemberContact();
	}
	
	@isTest 
	private static void validateBankTeller() {
		Test.startTest();
		User us = [Select Id from User where AV_ExternalID__c = 'U0123456789' limit 1];
        AV_TestHelper.insertPermissionSet(us.Id, 'AV_BankTeller');
		CampaignMember cm = [Select id from CampaignMember limit 1];
		Database.DeleteResult deleteresul;
		System.RunAs(us) {
			deleteresul = Database.delete(cm, false);
		}
		Test.stopTest();
		System.assertEquals(deleteresul.isSuccess(), false);
	}
}