/**********************************************************************************************************************
Name:	  AV_ActivadeLeadOppController_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_ActivadeLeadOppController"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY			AUTHOR				DATE			Description
    1.0			Test Class		Vladislav Lityagin		27/05/2022		Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_ActivadeLeadOppController_Test {
    
	@TestSetup
	static void setup(){
		User usrTestApiOnly = AV_TestHelper.createUser('AV_Usuario_CaixaBank');

        Lead l1 = AV_TestHelper.createLead();

        AV_LeadOpportunity__c leadOpp = AV_TestHelper.createLeadOpportunity(l1);
	}
    	

	/**
	 * Execute the Trigger class (AV_LeadOpportunity_BI_TRHan && AV_LeadOpportunity_BU_TRHan) and check the OwnerId
	 */
	@isTest
	private static void executeUpdateLeadOpportunityStatus() {
		Test.startTest();
        User u = [SELECT Id from User LIMIT 1];
		AV_LeadOpportunity__c loOld = [SELECT Id, Name, AV_StatusLeadOpp__c, AV_Status__c from AV_LeadOpportunity__c LIMIT 1];
        
        System.runAs(u){
            AV_ActivadeLeadOppController.updateStatus(loOld.Id);
            Database.update(loOld);
            AV_ActivadeLeadOppController.updateStatus(loOld.Id);
            AV_ActivadeLeadOppController.updateStatus('xxx');
        }
        
        AV_LeadOpportunity__c lo = [SELECT Id, Name, AV_StatusLeadOpp__c, AV_Status__c from AV_LeadOpportunity__c LIMIT 1];
        System.assertEquals('Activo', lo.AV_Status__c);
		Test.stopTest();
	}
    
}