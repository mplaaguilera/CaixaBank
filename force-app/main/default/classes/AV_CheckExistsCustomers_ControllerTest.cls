/**********************************************************************************************************************
Name:	  AV_CheckExistsCustomers_ControllerTest
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_CheckExistsCustomers_ControllerTest"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY			AUTHOR				DATE			Description
    1.0			Test Class		Vladislav Lityagin		14/07/2022		Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_CheckExistsCustomers_ControllerTest {
    
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
	private static void executeGetCustomers() {
		Test.startTest();
        User u = [SELECT Id from User LIMIT 1];
		Lead l = [SELECT Id from Lead LIMIT 1];
        
        System.runAs(u){
			AV_CheckExistsCustomers_Controller.CustomerList cl = AV_CheckExistsCustomers_Controller.getCustomers(l.Id);
			System.assertEquals(0,cl.recordList.size(),'executeGetCustomers');
        }
		Test.stopTest();
	}
    
}