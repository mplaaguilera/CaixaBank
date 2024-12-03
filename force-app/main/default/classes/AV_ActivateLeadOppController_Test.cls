/**********************************************************************************************************************
Name:	  AV_ActivateLeadOppController_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_ActivateLeadOppController"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY			AUTHOR				DATE			Description
    1.0			Test Class		Vladislav Lityagin		27/05/2022		Init version
    1.1			FIX				Patricia Villacañas		26/04/2023		Modified to set run as, assertions and user creation
    1.2         FIX             Laura Marrero           16/05/2023      Modified to set run as
***********************************************************************************************************************/
@isTest
public with sharing class AV_ActivateLeadOppController_Test {
    
	@TestSetup
	static void setup(){
         User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
            User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545400', 'AV_SistematicaComercial');
			userGestor.Alias = 'gest';
			userGestor.Email = 'gestor-test@test.com';
			userGestor.IsActive = true;
            insert userGestor;

        System.runAs(userGcf){
            Lead l1 = AV_TestHelper.createLead();
            AV_LeadOpportunity__c leadOpp = AV_TestHelper.createLeadOpportunity(l1);
            l1.OwnerId = userGestor.Id;
            update leadOpp;
        }
    }
    	

	@isTest
	private static void executeUpdateLeadOpportunityStatus() {
       	
        User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		AV_LeadOpportunity__c loOld = [SELECT Id, Name, AV_StatusLeadOpp__c, AV_Status__c from AV_LeadOpportunity__c LIMIT 1];
        
        Test.startTest();
        System.runAs(userGestor){
            AV_ActivateLeadOppController.updateStatus(loOld.Id);
            //Database.update(loOld);
            AV_ActivateLeadOppController.updateStatus('xxx');
            //executeUpdateStatus();
        }

        Test.stopTest();
        AV_LeadOpportunity__c lo = [SELECT Id, Name, AV_StatusLeadOpp__c, AV_Status__c from AV_LeadOpportunity__c LIMIT 1];
        System.assertEquals(AV_AppConstants.LEADOPP_STATUS_ACTIVO, lo.AV_Status__c);
	}
}