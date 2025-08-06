/**********************************************************************************************************************
 Name:      CIBE_GCFichaCli_Controller
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for cibe_GCFichaCli LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------
	VERSION  USER_STORY				AUTHOR				DATE            Description
	1.0      DE80894				Bea		    	    22/08/2023      Init version

***********************************************************************************************************************/

public with sharing class CIBE_GCFichaCli_Controller {

    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> gruposComerciales (String recordId) {
        
        List<FinServ__AccountAccountRelation__c> accountGroupList = new List<FinServ__AccountAccountRelation__c>();
        if(FinServ__AccountAccountRelation__c.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.FinServ__RelatedAccount__c.isAccessible()
            && Schema.SObjectType.Account.fields.Name.isAccessible()) {
                accountGroupList = [SELECT FinServ__RelatedAccount__c,  FinServ__RelatedAccount__r.Name, FinServ__Account__c, FinServ__Account__r.Name  FROM FinServ__AccountAccountRelation__c 
                WHERE RecordType.DeveloperName = 'CIBE_GrupoComercial' AND FinServ__RelatedAccount__c = :recordId AND AV_ToDelete__c = false AND
                FinServ__Role__r.Name= 'Parent'
                ];
        }

        List<Wrapper> listReturn = new List<Wrapper>();
        for(FinServ__AccountAccountRelation__c acc : accountGroupList) {
            listReturn.add(
                new Wrapper(
                    acc.FinServ__Account__c,
                    acc.FinServ__Account__r.Name    
                ));
        }
        
        return listReturn;
    }


    public class Wrapper{
        @AuraEnabled 
        public String idGC {get;set;}

        @AuraEnabled 
        public String nameGC {get;set;}

        
        public Wrapper(String idGC, String nameGC) {
            
            this.idGC= '/'+ idGC;
            this.nameGC = nameGC;

        }
    }

}