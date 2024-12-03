/**********************************************************************************************************************
 Name:	  cibe_secondNewOpportunity_CIB_Controller_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para dar cobertura a la clase cibe_secondNewOpportunity_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US372929		Alicia		   	    23/01/2023		  	Init version
***********************************************************************************************************************/
@isTest
public with sharing class cibe_secondNewOpportunity_CIB_Ctr_Test {

    /**
	 * 
	 */
	@isTest
	public static void getAppDefinition_Test() {
        List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVACIB};
        User usuario = CIBE_TestHelper.loginUser(null, null, null,listPermissionsSet);

        System.runAs(usuario){
            AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition WHERE DeveloperName = 'CIBE_MisClientesCIB' LIMIT 1];        
            UserAppInfo app = new UserAppInfo(AppDefinitionId = appDefinition.DurableId, UserId = UserInfo.getUserId(), FormFactor = 'Small');
            insert app;
                String appUser = cibe_secondNewOpportunity_CIB_Controller.getAppDefinition();
            System.assert(String.isNotBlank(appUser));
        }
    }
    
    @isTest
	public static void getExitoPicklist_Test() {
        List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVACIB};
        User usuario = CIBE_TestHelper.loginUser(null, null, null,listPermissionsSet);
        
        System.runAs(usuario){
            List<cibe_secondNewOpportunity_CIB_Controller.OptionsField> listValues= new List<cibe_secondNewOpportunity_CIB_Controller.OptionsField>();
            listValues=cibe_secondNewOpportunity_CIB_Controller.getExitoPicklist();
            System.assert(!listValues.isEmpty());
        }
    }
}