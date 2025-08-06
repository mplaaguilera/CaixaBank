/**********************************************************************************************************************
 Name:	  EV_CampaignStatisticsController_Test
 Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test para el controlador EV_CampaignStatisticsController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			                    Carolina Lopez		06/03/2024			Init version
***********************************************************************************************************************/
@isTest
public with sharing class EV_CampaignStatisticsController_Test {
    @isTest
    private static void campaignStatisticsTest() {
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Campaign resultCampaign = new Campaign();
        Test.startTest();
        System.runAs(newUser){
            Campaign camp = EV_TestHelper.createChildCampaignVirtual();
            resultCampaign = EV_CampaignStatisticsController.getCampaignStatistics(camp.Id);
        }
        Test.stopTest();
        System.assertNotEquals(null, resultCampaign);
    }
}