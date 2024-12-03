/**********************************************************************************************************************
Name:	  AV_LinkNotifyMeController
Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC av_LinkNotifyMe
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY		AUTHOR				DATE			Description
    1.0			US190069    	Rubén Izquierdo 	18/03/2021		Init version
    1.1			US190069    	Rubén Izquierdo 	12/05/2021		Fix issue with URL Encode in B64
	1.2			US362726		José María Pérez	25/05/2022		New query links metadata
    1.3         FIX             Luis Fernández      11/07/2022      Changed AV_Query to SOQL queries
    1.4         Fix PMD Errors  Humberto Vilchez    23/10/2023      Add WITH SECURITY_ENFORCED to queries
***********************************************************************************************************************/
public with sharing class AV_LinkNotifyMeController {

    @AuraEnabled
    public static String getLink(String idNotificacion) {
        String methodName = 'getLinks';  

        AV_NotifyMe__c queryNotifyMe = [SELECT Id,AV_PEAURL__c, AV_PEAParams__c FROM AV_NotifyMe__c WHERE id = :idNotificacion WITH SECURITY_ENFORCED LIMIT 1];

        CIBE_Link__mdt queryLinksTF9 = [SELECT Id,CIBE_URL__c FROM CIBE_Link__mdt WHERE CIBE_Title__c = 'AV_URLBaseTF9' WITH SECURITY_ENFORCED LIMIT 1];
        //recoger valores campos     
        String peaUrl = queryNotifyMe.AV_PEAURL__c; 
        String peaParams = queryNotifyMe.AV_PEAParams__c;
        String link = queryLinksTF9.CIBE_URL__c + peaUrl + '&origen=salesforce&_vmcNewTab=true';

        //modificar parametros según lo que tenemos en el campo de base 64
        if(String.isNotBlank(peaUrl) && String.isNotBlank(peaParams)) {
            peaParams = EncodingUtil.base64Decode(peaParams).toString();
            peaParams = EncodingUtil.urlEncode(peaParams, 'UTF-8');
            link += '&params='+ peaParams;
        }else{
            AV_LogDebug.printLogError(methodName, 'Error: link empty');
            return 'KO';
        }

        return link; 
    }

}