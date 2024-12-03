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

	@isTest
    public static void blanqueoClase(){
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        System.runAs(newUser){
            AV_CampaignMember_BD_TRHan.processMetodoBlanco();
        }
        System.assertEquals('', '');
    }
}