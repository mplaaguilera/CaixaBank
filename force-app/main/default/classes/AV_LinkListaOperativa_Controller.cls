/**********************************************************************************************************************
Name:	  AV_LinkListaOperativa_Controller
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC av_LinkListaOperativa
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Init    		Gonzalo Ávila    	07/03/2024		Init version
1.1         Fix             Sandra Gómez        03/05/2024      Change AV_ListaOperativa_Name to AV_ListaOperativa_Boton
***********************************************************************************************************************/
public with sharing class AV_LinkListaOperativa_Controller {
    public class LinkData{
        @AuraEnabled
        public String url{get;set;}
        @AuraEnabled
        public String label{get;set;}
    }

    public class RType {
        String recordType;
        Map<String, String> params;
        Map<String, String> staticParams;
    }
    public class Obj {
        public String sObj;
        List<RType> recordTypes;
    } 


    @AuraEnabled(cacheable=true)
    public static List<LinkData> getLinks(String filterObject, String customerId, String parentId) {

        String empContacto = [SELECT AV_ExternalID__c FROM USER WHERE Id = :UserInfo.getUserId()  WITH SECURITY_ENFORCED LIMIT 1].AV_ExternalID__c;
        empContacto = String.isNotBlank(empContacto) ? empContacto.removeStart('U01') : '';

        sObject obj = Database.query('SELECT Id, RecordTypeId, RecordType.Name, RecordType.DeveloperName FROM ' + String.escapeSingleQuotes(filterObject) + ' WHERE Id = :customerId LIMIT 1');
        RecordType rtName = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Id =: ((String)obj.get('RecordTypeId')) WITH SECURITY_ENFORCED LIMIT 1];

        Set<Id> idOperativa = new Set<Id>();

        List<CIBE_Section_Link__mdt> LinkListOp = [SELECT CIBE_Link_Reference__c FROM CIBE_Section_Link__mdt WHERE DeveloperName = 'AV_ListaOperativa_Boton' WITH SECURITY_ENFORCED];

        for (CIBE_Section_Link__mdt link : LinkListOp) {
            idOperativa.add(link.CIBE_Link_Reference__c);
        }

        Map<Id, CIBE_Link__mdt> mapLinks =new Map<Id, CIBE_Link__mdt>([SELECT id, CIBE_Order__c, CIBE_Parameters__c,  CIBE_Title__c,CIBE_URL__c, CIBE_URL_Long__c  FROM CIBE_Link__mdt where Id=:idOperativa and CIBE_Active__c = true WITH SECURITY_ENFORCED ORDER BY CIBE_Order__c ASC]);
        Id linkData = LinkListOp[0].CIBE_Link_Reference__c;

        List<String> translationLinkNames = new List<String>();
        for(CIBE_Link__mdt link : mapLinks.values()) {
            translationLinkNames.add(String.isNotBlank(link.CIBE_Title__c) ? link.CIBE_Title__c : null);
        }

        Map<String, String> linkTranslations = CIBE_TranslationUtilities.getInstance().addTranslationNames(translationLinkNames).queryTranslations().getTranslations();

        List<LinkData> links = new List<LinkData>();
        LinkData lkData= new LinkData();
        String tipoURL = String.isBlank(mapLinks.get(linkData).CIBE_URL_Long__c) ? mapLinks.get(linkData).CIBE_URL__c: mapLinks.get(linkData).CIBE_URL_Long__c;
        lkData.url = generateURL(tipoURL, mapLinks.get(linkData).CIBE_Parameters__c,customerId, rtName);
        lkData.label = linkTranslations.containsKey(mapLinks.get(linkData).CIBE_Title__c) && String.isNotBlank(linkTranslations.get(mapLinks.get(linkData).CIBE_Title__c)) ? linkTranslations.get(mapLinks.get(linkData).CIBE_Title__c) : mapLinks.get(linkData).CIBE_Title__c; 

        links.add(lkData);
        return links;
    }

    private static String generateURL(String url, String parameters, String filterId, RecordType rtName){
        String methodName = 'generateURL';
        Obj wrapper = (Obj) System.JSON.deserialize(parameters, Obj.class);
        AV_LogDebug.printLogDebug(methodName, 'Parameters: ' + parameters);
        Map<String, String> mapParams =  new Map<String, String>();
        for(RType rt : wrapper.recordTypes) {
            if(String.isBlank(rt.recordType) || (String.isNotBlank(rt.recordType) && rt.recordType.equals(rtName.developername))){
                if(rt.params != null){
                    for(String key : rt.params.keySet()) {
                        mapParams.put(key, rt.params.get(key));
                    }
                }
            }
        }

        AV_LogDebug.printLogDebug(methodName, 'mapParams: ' + mapParams);        
        SObject result = null;
        
        String soqlQuery = 'SELECT Id, AV_NumPerso__c, CC_Numero_Documento__c, Name FROM Account WHERE Id =: filterId';
        result = Database.query(soqlQuery);
        for(String key : mapParams.keySet()){
            if(url.contains('{'+key+'}') && (String)result.get(mapParams.get(key))!=null){
                url = url.replace('{'+key+'}', (String)result.get(mapParams.get(key)));
            }
        }
        url = url.replaceAll('nombre%3D', 'nombreCliente=');
        url = url.replaceAll( '\\s+', '+');
        return url;
    }
    
}