/**********************************************************************************************************************
 Name:	  CIBE_CallReportCountry
 Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
@description Controller class of Cibe_EventCallReportCountry
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				        DATE				Description
	1.0			PPM100361710	    Carolina Lopez		        19/08/2023  		Init version
***********************************************************************************************************************/
public with sharing class CIBE_CallReportCountry {
    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String fieldName) {
        Schema.SObjectType objectType = CBK_Activity_Extension__c.SObjectType;
        Schema.DescribeSObjectResult objDescribe = objectType.getDescribe();
        Schema.DescribeFieldResult fieldDescribe = objDescribe.fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
        List<String> values = new List<String>();
        for (Schema.PicklistEntry entry : picklistValues) {
            values.add(entry.getLabel());
        }
        return values;
    }

    @AuraEnabled
    public static CBK_Activity_Extension__c updateRecord(Id recordId, String newCountryValue, boolean shouldUpdate) {
        List<CBK_Activity_Extension__c> recordToUpdate = new List<CBK_Activity_Extension__c>();
        recordToUpdate = [SELECT Id, AV_ActivityId__c, CIBE_Country__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :recordId LIMIT 1];
        if (shouldUpdate) {
            if (recordToUpdate[0].CIBE_Country__c != newCountryValue) {
                recordToUpdate[0].CIBE_Country__c = newCountryValue;
            
                Database.SaveResult[] results = Database.update(new List<CBK_Activity_Extension__c> { recordToUpdate[0] }, false);
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()) {
                        CBK_Log.error('Error al actualizar el registro: ' + result.getErrors()[0].getMessage());
                    }
                }
            }
        }
        return recordToUpdate[0];
    }
}