/**********************************************************************************************************************
Name:	  Cibe_ProductFieldsOpportunity_Controller
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller of Cibe_ProductFieldsOpportunity
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US496487	    Jose Maria Perez 	20/01/2023		Init version

***********************************************************************************************************************/
public with sharing class Cibe_ProductFieldsOpportunity_Controller {


    //Estructura de datos que se devuelve al componente en formato de dos columnas de campos
    public class ProductFieldsNewOpp{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String name{get;set;} 
        @AuraEnabled
        public String type{get;set;}   
        @AuraEnabled
        public Boolean required{get;set;}
    }

    @AuraEnabled(cacheable=true) 
    public static List<ProductFieldsNewOpp> getProductFieldsNewOppo(String idProduct) {
        List<ProductFieldsNewOpp> listFieldsReturn = new List<ProductFieldsNewOpp>();
        List<Product2> listProducts =  new List<Product2>();
        if(Product2.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.Product2.fields.Name.isAccessible()) {
            listProducts = [SELECT Id, Name FROM Product2 WHERE Id = :idProduct LIMIT 1]; 
        }

        if(!listProducts.isEmpty()) {
            List<CIBE_ProductoFieldsNewOppo__mdt> listProductFields =   [SELECT Id, CIBE_Required__c, CIBE_ProductName__c, CIBE_FlowVariableName__c, CIBE_FieldName__c, CIBE_Type__c, CIBE_Label__c, CIBE_Order__c FROM CIBE_ProductoFieldsNewOppo__mdt WHERE CIBE_ProductName__c = :listProducts.get(0).Name ORDER BY CIBE_Order__c ASC];
            List<CIBE_ProductoFieldsNewOppo__mdt> defaultFields =       [SELECT Id, CIBE_Required__c, CIBE_ProductName__c, CIBE_FlowVariableName__c, CIBE_FieldName__c, CIBE_Type__c, CIBE_Label__c, CIBE_Order__c FROM CIBE_ProductoFieldsNewOppo__mdt WHERE CIBE_ProductName__c = 'default' ORDER BY CIBE_Order__c ASC];
            
            List<String> translationsFields = new List<String>();
            for(CIBE_ProductoFieldsNewOppo__mdt productField: listProductFields){
                translationsFields.add(productField.CIBE_Label__c);
            }
            for(CIBE_ProductoFieldsNewOppo__mdt productField: defaultFields){
                translationsFields.add(productField.CIBE_Label__c);
            }

            Map<String, String> translations = CIBE_TranslationUtilities.getInstance().addTranslationNames(translationsFields).queryTranslations().getTranslations();

            
            if(!listProductFields.isEmpty()) {
                for(CIBE_ProductoFieldsNewOppo__mdt productField : listProductFields) {
                    ProductFieldsNewOpp fielfToReturn = new ProductFieldsNewOpp();
                    fielfToReturn.label =  translations.get(productField.CIBE_Label__c);
                    fielfToReturn.name =  productField.CIBE_FlowVariableName__c;
                    fielfToReturn.type =  productField.CIBE_Type__c;
                    fielfToReturn.required =  productField.CIBE_Required__c;
                    listFieldsReturn.add(fielfToReturn);
                }
            } else {
                for(CIBE_ProductoFieldsNewOppo__mdt productField : defaultFields) {
                    ProductFieldsNewOpp fielfToReturn = new ProductFieldsNewOpp();
                    fielfToReturn.label =  translations.get(productField.CIBE_Label__c);
                    fielfToReturn.name =  productField.CIBE_FlowVariableName__c;
                    fielfToReturn.type =  productField.CIBE_Type__c;
                    fielfToReturn.required =  productField.CIBE_Required__c;
                    listFieldsReturn.add(fielfToReturn);
                }
            } 
        }
        return listFieldsReturn;
    }

}