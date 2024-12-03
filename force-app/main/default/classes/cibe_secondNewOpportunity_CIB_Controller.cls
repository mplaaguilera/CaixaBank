/**********************************************************************************************************************
Name:	  cibe_secondNewOpportunity_CIB_Controller
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for cibe_second_New_Opportunity
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			    	        Alicia         	    23/01/2023		Init version
***********************************************************************************************************************/
public with sharing class cibe_secondNewOpportunity_CIB_Controller {

    public class OptionsField {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
    }
    
    @AuraEnabled(cacheable=true) 
    public static List<OptionsField> getExitoPicklist() {
        List<OptionsField> selectOptions = new List<OptionsField>();
        Schema.DescribeFieldResult objFieldDescribe = Opportunity.CIBE_ProbabilidadExito__c.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            OptionsField opField= new OptionsField();
            opField.value=objPickList.getValue();
            opField.label=objPickList.getLabel();
            selectOptions.add(opField);
        }
        return selectOptions;
    }
    
    @AuraEnabled(cacheable=true) 
	public static String getAppDefinition() {
        UserAppInfo userAppInfo = [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1];
        AppDefinition appDefinition = [SELECT DurableId, Label,DeveloperName FROM AppDefinition Where DurableId = :userAppInfo.AppDefinitionId LIMIT 1];
        return appDefinition.DeveloperName;
    }
}