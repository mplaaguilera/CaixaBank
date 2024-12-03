/**********************************************************************************************************************
Name:	  CIBE_NewOpportunity_Controller
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for CIBE_New_Opportunity
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			    	        Jose Maria       	20/06/2022		Init version
    2.0         US496487        Jose Maria          20/01/2023      División de funcionalidad en las otras clases del componente
    3.0         DE83223         Lucia               29/09/2023      Nuevo metodo search
    3.1         PPM100455545    Lucia               16/09/2024      Nuevo metodo getPaisPicklist

***********************************************************************************************************************/
public with sharing class CIBE_NewOpportunity_Controller {

    private final static Id RTAVPF = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('AV_PF').getRecordTypeId();


    public class OptionsField {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
    }

    @AuraEnabled(cacheable=true) 
    public static List<OptionsField> getSubProductoPicklist() {
        List<OptionsField> selectOptions = new List<OptionsField>();

        Schema.DescribeFieldResult objFieldDescribe = Opportunity.CIBE_Subproducto__c.getDescribe();
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
    public static List<OptionsField> getTipoOperacionPicklist() {
        List<OptionsField> selectOptions = new List<OptionsField>();

        Schema.DescribeFieldResult objFieldDescribe = Opportunity.CIBE_TipoOperacion__c.getDescribe();
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
	public static List<Map<String, String>> getStatusValues(String objectName, String fieldName) {

        List<AV_PicklistListValuesByRecordType__mdt> picklistValues = [SELECT id, AV_ListSalesProcess__c FROM AV_PicklistListValuesByRecordType__mdt WHERE AV_RecordTypeLabel__c='CIBE New Component' AND AV_ObjectLabel__c =:objectName];
      
		List<String> pickValues = new List<String>();
		pickValues = picklistValues[0].AV_ListSalesProcess__c.split(';');
		List<Map<String, String>> listPicklist = new List<Map<String, String>>();
		DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
		DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldName).getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		
		for(String val:pickValues){
			for(Schema.PicklistEntry pickListVal : ple){
				if (val == String.valueOf(pickListVal.getValue())) {
					listPicklist.add(new Map<String, String>{'label' => String.valueOf(pickListVal.getLabel()), 'value' => String.valueOf(pickListVal.getValue())});
				}
			}
		}
        
		return listPicklist;
	}

    @AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> search(String searchTerm) {
		String methodName = 'search';
		String avQuery;
        List<SObject> listResult = new  List<SObject>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
            if(String.isNotBlank(searchTerm)) {
                searchTerm += '*';

                    avQuery='FIND {'+searchTerm+'} IN ALL FIELDS RETURNING Product2 (Id, Name  WHERE RecordTypeId = :RTAVPF )';

                AV_LogDebug.printLogDebug(methodName, 'avQuery: ' + avQuery);
                searchResults = search.query(avQuery);
            } else {
                if(
                Product2.SObjectType.getDescribe().isAccessible() &&
                Schema.SObjectType.Product2.fields.Name.isAccessible() &&
                Schema.SObjectType.Product2.fields.CIBE_Familia__c.isAccessible()
                ) {
                   
                    listResult = [SELECT Id, Name  FROM Product2 WHERE RecordTypeId = :RTAVPF LIMIT 5];
                    
                }
                searchResults.add(listResult);
            }        
        List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        if(searchResults != null && !searchResults.isEmpty()) {
            SObject[] listProduct = (List<SObject>) searchResults[0];
            for (SObject p : listProduct) {
                results.add(
                    new AV_LookupSearchResult(
                        p.Id,
                        'Product2',
                        'standard:product',
                        p.get('Name').toString(),
                        '')
                );
            }
            results.sort();
        }
		return results;
	}


    @AuraEnabled(cacheable=true) 
    public static List<OptionsField> getPaisPicklist() {
        List<OptionsField> selectOptions = new List<OptionsField>();

        Schema.DescribeFieldResult objFieldDescribe = Opportunity.CIBE_PaisMulti__c.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();

        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            OptionsField opField= new OptionsField();
            opField.value=objPickList.getValue();
            opField.label=objPickList.getLabel();
            selectOptions.add(opField);
        }
        return selectOptions;
    }
    
   
}