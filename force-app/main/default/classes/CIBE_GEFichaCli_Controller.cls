/**********************************************************************************************************************
 Name:      CIBE_GEFichaCli_Controller
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for cibe_GEFichaCli LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION  USER_STORY				AUTHOR				DATE            Description
	1.0      DE80894				Bea		    	    23/08/2023      Init version

***********************************************************************************************************************/

public with sharing class CIBE_GEFichaCli_Controller {

    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> gruposEconomicos (String recordId) {
        
        List<FinServ__AccountAccountRelation__c> accountGroupList = new List<FinServ__AccountAccountRelation__c>();
        if(FinServ__AccountAccountRelation__c.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.FinServ__RelatedAccount__c.isAccessible()
            && Schema.SObjectType.Account.fields.Name.isAccessible()) {
                accountGroupList = [SELECT FinServ__RelatedAccount__c,  FinServ__RelatedAccount__r.Name  FROM FinServ__AccountAccountRelation__c WHERE RecordType.Developername = 'CIBE_GrupoEconomico' AND CIBE_TipoGrupo__c = '120' AND FinServ__Account__c = :recordId AND FinServ__RelatedAccount__r.AV_ToDelete__c = false];
        }

        List<Wrapper> listReturn = new List<Wrapper>();
        for(FinServ__AccountAccountRelation__c acc : accountGroupList) {
            listReturn.add(
                new Wrapper(
                    acc.FinServ__RelatedAccount__c,
                    acc.FinServ__RelatedAccount__r.Name    
                ));
        }
        
        return listReturn;
    }


    public class Wrapper{
        @AuraEnabled 
        public String idGE {get;set;}

        @AuraEnabled 
        public String nameGE {get;set;}

        
        public Wrapper(String idGE, String nameGE) {
            
            this.idGE= '/'+ idGE;
            this.nameGE = nameGE;

        }
    }

}