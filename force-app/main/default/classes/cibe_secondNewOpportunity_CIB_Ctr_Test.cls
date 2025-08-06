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


    @TestSetup
    static void makeData(){
        CIBE_TestInitialSetup.setupInitialDataCIB();
    }

    /**
	 * 
	 */
	@isTest
	public static void getAppDefinitionTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usuario){
            AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition WHERE DeveloperName = 'CIBE_MisClientesCIB' LIMIT 1];        
            UserAppInfo app = new UserAppInfo(AppDefinitionId = appDefinition.DurableId, UserId = UserInfo.getUserId(), FormFactor = 'Small');
            insert app;
                String appUser = cibe_secondNewOpportunity_CIB_Controller.getAppDefinition();
            System.assert(String.isNotBlank(appUser));
        }
    }
    
    @isTest
	public static void getExitoPicklistTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        
        System.runAs(usuario){
            List<cibe_secondNewOpportunity_CIB_Controller.OptionsField> listValues= new List<cibe_secondNewOpportunity_CIB_Controller.OptionsField>();
            listValues=cibe_secondNewOpportunity_CIB_Controller.getExitoPicklist();
            System.assert(!listValues.isEmpty());
        }
    }


    @isTest
	public static void getPaisPicklistTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        
        System.runAs(usuario){
            List<cibe_secondNewOpportunity_CIB_Controller.OptionsField> listValues= new List<cibe_secondNewOpportunity_CIB_Controller.OptionsField>();
            listValues=cibe_secondNewOpportunity_CIB_Controller.getPaisPicklist();
            System.assert(!listValues.isEmpty());
        }
    }
}