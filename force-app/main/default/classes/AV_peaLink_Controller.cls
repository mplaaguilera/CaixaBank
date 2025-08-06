/**********************************************************************************************************************
Name:	  AV_LinkArgumentario_Controller
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC av_peaLink
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Init    		Gonzalo Ávila    	10/07/2024		Init version
***********************************************************************************************************************/
public with sharing class AV_peaLink_Controller {
    public class LabelURL {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String url;
    }

    @AuraEnabled(cacheable=true)
    public static List<LabelURL> getURLs(String setting) {
        Map<Id, CIBE_Section__mdt> mapSection = new Map<Id, CIBE_Section__mdt>([SELECT Id, Label, CIBE_Collapse__c, CIBE_Collumns__c, CIBE_Title__c, CIBE_Order__c FROM CIBE_Section__mdt where CIBE_Active__c=true and CIBE_Setting__c=:setting WITH SECURITY_ENFORCED ORDER BY CIBE_Order__c ASC]);    
        List<CIBE_Section_Link__mdt> listSectionsLinks = [SELECT id, Label, CIBE_Link_Reference__c, CIBE_Section_Reference__c FROM CIBE_Section_Link__mdt where CIBE_Section_Reference__c IN :mapSection.keySet() and CIBE_Link_Reference__r.CIBE_Active__c = true WITH SECURITY_ENFORCED];
        List<LabelURL> listlabelurls = new List<LabelURL>();
        Set<Id> listSections = new Set<Id>();

        for(CIBE_Section_Link__mdt sectionLink : listSectionsLinks) {
            listSections.add(sectionLink.CIBE_Link_Reference__c);
        }

        Map<Id, CIBE_Link__mdt> links = new Map<Id, CIBE_Link__mdt>([SELECT id, CIBE_Order__c, CIBE_Parameters__c, CIBE_Title__c, CIBE_URL__c, CIBE_URL_Long__c  FROM CIBE_Link__mdt where Id IN :listSections and CIBE_Active__c = true WITH SECURITY_ENFORCED ORDER BY CIBE_Order__c ASC]);

        for (CIBE_Link__mdt link : links.values()) {
            LabelURL labelurl = new LabelURL();
            if (link.CIBE_URL_Long__c != null) {
                labelurl.url = link.CIBE_URL_Long__c;
            } else if (link.CIBE_URL__c != null) {
                labelurl.url = link.CIBE_URL__c;
            }
            labelurl.label = link.CIBE_Title__c;
            listlabelurls.add(labelurl);
        }
        
        return listlabelurls;
    }

    @AuraEnabled
    public static String getCurrentPEA(String recordId) {
        List<AV_Simulador__c> enlace = [SELECT Id, AV_PEA__c, AV_URL_PEA__c FROM AV_Simulador__c WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
        if (!enlace.isEmpty()) {
            return enlace[0].AV_PEA__c;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static void updateSimulador(String recordId, String selectedUrl) {
        AV_Simulador__c enlace = [SELECT Id, AV_PEA__c FROM AV_Simulador__c WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
        enlace.AV_PEA__c = selectedUrl;
        update enlace;
    }
}