/**********************************************************************************************************************
Name:	  AV_LinkArgumentario_Controller
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC av_LinkArgumentario
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Init    		Gonzalo Ávila    	02/04/2024		Init version
***********************************************************************************************************************/
public with sharing class AV_LinkArgumentario_Controller {
    @AuraEnabled(cacheable = true)
    public static Product2 getProductData(String idOpp){
        List<Product2> productList = new List<Product2>();
        if(String.isNotBlank(idOpp)){
            List<Opportunity> oppList = [SELECT AV_PF__c FROM Opportunity WHERE Id=: idOpp WITH SECURITY_ENFORCED];
            String productId = oppList[0].AV_PF__c;

            productList = [SELECT Id, Name, AV_URLArgumentario__c FROM Product2 WHERE Id=: productId WITH SECURITY_ENFORCED];
        }
        return productList[0];
    }
}