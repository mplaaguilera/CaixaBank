/**********************************************************************************************************************
 Name:	  CIBE_NewOpportunity_Controller_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para dar cobertura a la clase cibe_secondNewOpportunity_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US372929		Jose Maria		   	05/07/2022		  	Init version
    2.0         US496487        Jose Maria          20/01/2023      	División de funcionalidad en las otras clases del componente		
***********************************************************************************************************************/
@isTest
public with sharing class cibe_secondNewOpportunity_Ctr_Test {

    /**
	 * 
	 */
	@isTest
	public static void cibe_secondNewOpportunity_ControllerTest() {
      	List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA};
      	User usuario = CIBE_TestHelper.loginUser(null, null, null,listPermissionsSet);
       
        System.runAs(usuario){
        	AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition WHERE DeveloperName = 'CIBE_MisClientesEMP' LIMIT 1];        
            UserAppInfo app = new UserAppInfo(AppDefinitionId = appDefinition.DurableId, UserId = UserInfo.getUserId(), FormFactor = 'Small');
            insert app;
               String appUser = cibe_secondNewOpportunity_Controller.getAppDefinition();
            System.assert(String.isNotBlank(appUser));
        
            List<cibe_secondNewOpportunity_Controller.OptionsField> listValues= new List<cibe_secondNewOpportunity_Controller.OptionsField>();
            listValues=cibe_secondNewOpportunity_Controller.getExitoPicklist();
            System.assert(!listValues.isEmpty());
         
        }
    }
}