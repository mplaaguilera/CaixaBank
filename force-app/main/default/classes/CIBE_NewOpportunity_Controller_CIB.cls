/**********************************************************************************************************************
Name:	  CIBE_NewOpportunity_Controller_CIB
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for new opportunity and reporting LWCs
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US500486		Alicia		   		20/01/2021	    Init version
    2.0         US521590        Jose Maria          14/02/2023      Familia y producto relacionados
    3.0         US619216        Luis Martínez       14/07/2023      Se recuperan los campos de Opportunity respecto al Product2 seleccionado
    4.0         US682142        ALi                 25/07/2023      Añadido el update de Linea
***********************************************************************************************************************/
public with sharing class CIBE_NewOpportunity_Controller_CIB {
	private final static Integer MAX_LIMIT 		= 49900;


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
  
    @AuraEnabled(cacheable=true) //pasamos obj y campo con lo que crea estructura (label y value de la picklist)
	public static List<Map<String, String>> getStatusValues(String objectName, String fieldName) {
        
        List<AV_PicklistListValuesByRecordType__mdt> picklistValues = [SELECT id, AV_ListSalesProcess__c FROM AV_PicklistListValuesByRecordType__mdt WHERE AV_RecordTypeLabel__c='CIBE New Component' AND AV_ObjectLabel__c =:objectName];
    
		List<String> pickValues = new List<String>();
		pickValues = picklistValues[0].AV_ListSalesProcess__c.split(';');
		List<Map<String, String>> listPicklist = new List<Map<String, String>>();
		// Get the describe for the object
		DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
		// Get the field dynamically
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

	private final static Id RTSUBPRODUCTO = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('CIBE_Producto').getRecordTypeId();
    private final static Id RTFAMILIA = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('CIBE_Familia').getRecordTypeId();

    @AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> search(String searchTerm, String familia) {
		String methodName = 'search';
		String avQuery;
        List<SObject> listResult = new  List<SObject>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
            if(String.isNotBlank(searchTerm)) {
                searchTerm += '*';
                if(String.isNotBlank(familia)) {
                    avQuery='FIND {'+searchTerm+'} IN ALL FIELDS RETURNING Product2 (Id, Name, CIBE_Familia__c WHERE RecordTypeId = :RTSUBPRODUCTO AND CIBE_Familia__c = :familia)';
                }else{
                    avQuery='FIND {'+searchTerm+'} IN ALL FIELDS RETURNING Product2 (Id, Name, CIBE_Familia__c WHERE RecordTypeId = :RTSUBPRODUCTO AND CIBE_Familia__c != null)';
                }
                AV_LogDebug.printLogDebug(methodName, 'avQuery: ' + avQuery);
                searchResults = search.query(avQuery);
            } else {
                if(
                Product2.SObjectType.getDescribe().isAccessible() &&
                Schema.SObjectType.Product2.fields.Name.isAccessible() &&
                Schema.SObjectType.Product2.fields.CIBE_Familia__c.isAccessible()
                ) {
                    if(String.isNotBlank(familia)) {
                        listResult = [SELECT Id, Name, CIBE_Familia__c FROM Product2 WHERE RecordTypeId = :RTSUBPRODUCTO AND CIBE_Familia__c =: familia];
                    }else{
                        listResult = [SELECT Id, Name, CIBE_Familia__c FROM Product2 WHERE RecordTypeId = :RTSUBPRODUCTO AND CIBE_Familia__c !=null];
                    }
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
	public static List<AV_LookupSearchResult> searchFamily(String searchTerm, String producto) {
        List<Product2> productSelected =  new List<Product2>();
        if(String.isNotBlank(producto)) {
            if(
                Product2.SObjectType.getDescribe().isAccessible() &&
                Schema.SObjectType.Product2.fields.CIBE_Familia__c.isAccessible()
            ) {
                productSelected = [SELECT Id,  CIBE_Familia__c FROM Product2 WHERE Id = :producto];
            }
        }
		String methodName = 'searchFamily';
		String avQuery;
        List<SObject> listResult = new List<SObject>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
        
        if(String.isNotBlank(searchTerm)) {
            searchTerm += '*';
            if(String.isNotBlank(producto)) {
                avQuery='FIND {'+searchTerm+'} IN ALL FIELDS RETURNING Product2 (Id, Name, CIBE_Familia__c WHERE RecordTypeId = :RTFAMILIA AND Id =: productSelected[0].CIBE_Familia__c)';
            }else{
                avQuery='FIND {'+searchTerm+'} IN ALL FIELDS RETURNING Product2 (Id, Name, CIBE_Familia__c WHERE RecordTypeId = :RTFAMILIA)';
            }
            AV_LogDebug.printLogDebug(methodName, 'avQuery: ' + avQuery);
            searchResults = search.query(avQuery);
        } else {
            if(
                Product2.SObjectType.getDescribe().isAccessible() &&
                Schema.SObjectType.Product2.fields.Name.isAccessible() &&
                Schema.SObjectType.Product2.fields.CIBE_Familia__c.isAccessible()
            ) {
                if(String.isNotBlank(producto)) {
                    listResult = [SELECT Id, Name, CIBE_Familia__c FROM Product2 WHERE RecordTypeId = :RTFAMILIA AND Id =: productSelected[0].CIBE_Familia__c];
                }else{
                    listResult = [SELECT Id, Name, CIBE_Familia__c FROM Product2 WHERE RecordTypeId = :RTFAMILIA];
                }
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
	public static String selectFamily(String producto) {
        List<Product2> productSelected =  new List<Product2>();
        if(String.isNotBlank(producto) && producto!=null) {
            if(
                Product2.SObjectType.getDescribe().isAccessible() &&
                Schema.SObjectType.Product2.fields.CIBE_Familia__c.isAccessible()
            ) {
                productSelected = [SELECT Id,  CIBE_Familia__c FROM Product2 WHERE Id = :producto];
            }
        }
		return productSelected[0].CIBE_Familia__c;
    }

    @AuraEnabled(cacheable=true)
	public static List <String> getOpportunityFields(String productoName) {
		List<String> lstCamposOppo = new List<String>();
        if(!String.IsBlank(productoName) && productoName.startsWith('01t')){
            List<Product2> lstProduct = [SELECT id, name, CIBE_CamposOppProduct__c FROM Product2 WHERE Id =:productoName];
            if(!lstProduct.isEmpty() && lstProduct[0].CIBE_CamposOppProduct__c != null){
                lstCamposOppo = lstProduct[0].CIBE_CamposOppProduct__c.split(';');
            }
        }else if(!String.IsBlank(productoName) && !productoName.startsWith('01t')){
            List<Product2> lstProduct = [SELECT id, name, CIBE_CamposOppProduct__c FROM Product2 WHERE Name =:productoName];
            if(!lstProduct.isEmpty() && lstProduct[0].CIBE_CamposOppProduct__c != null){
                lstCamposOppo = lstProduct[0].CIBE_CamposOppProduct__c.split(';');
            }
        }
		return lstCamposOppo;
	}

    @AuraEnabled(cacheable=true)
	public static String getCliente() {
        List<Account> sinCliente =  new List<Account>();
        List <String> lstRt = new List <String>{CIBE_AppConstants.ACCOUNT_CLIENTE_RT};

        String cliente = CIBE_AppConstants.ACC_SINCLIENTE;
            if(Account.SObjectType.getDescribe().isAccessible()) {
                sinCliente = [SELECT Id FROM Account WHERE Name = :cliente AND AV_InterlocName__c = :cliente AND RecordType.DeveloperName IN:lstRT];
                if(!sinCliente.isEmpty()){
                    return sinCliente[0].Id;
                }
            }
        return null;
    }


    @AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchCliente(String searchTerm) {
		String methodName = 'search';
		String avQuery;
        List<SObject> listResult = new  List<SObject>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
        List <String> lstRt = new List <String>{CIBE_AppConstants.ACCOUNT_CLIENTE_RT};
        String cliente = CIBE_AppConstants.ACC_SINCLIENTE;
        List<Account> sinCliente =  new List<Account>();

            if(String.isNotBlank(searchTerm)) {
                searchTerm += '*';
                avQuery='FIND {'+searchTerm+'} IN ALL FIELDS RETURNING Account (Id, Name WHERE RecordType.DeveloperName IN :lstRt )';
                searchResults = search.query(avQuery);
            }else{
                sinCliente = [SELECT Id, Name FROM Account WHERE Name = :cliente AND RecordType.DeveloperName IN:lstRt ];
                searchResults.add(sinCliente);
            }      
        List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();

        if(searchResults != null && !searchResults.isEmpty()) {
            Account[] listAccount = (List<Account>) searchResults[0];
            for (Account r : listAccount) {
                results.add(
                    new AV_LookupSearchResult(
                        r.Id,
                        'account',
                        'standard:account',
                        r.Name,
                        '')
                );
            }
        }
		return results;
	}
}