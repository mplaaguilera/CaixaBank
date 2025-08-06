/**********************************************************************************************************************
 Name:      CIBE_HomeOppPendFirma7DiasEMP_Contr
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for cibe_HomeOppPendFirma7DiasEMP LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
------------------------------------------------------------------------------------------------------------------------
	VERSION  USER_STORY				AUTHOR				DATE            Description
	1.0      Initial				Ali, María		    27/02/2024      Init version

***********************************************************************************************************************/

public with sharing class CIBE_HomeOppPendFirma7DiasEMP_Contr {

    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> homeOppPendFirma7Dias() {
        
        List<Opportunity> opp = new List<Opportunity>();
        if(Schema.SObjectType.Opportunity.isAccessible()) {
            opp = [SELECT Id, Account.Name, Name, CIBE_AmountDivisa__c, StageName, AV_PF__r.Name, AV_Origen__c, CloseDate
            FROM Opportunity WHERE StageName IN ('CIBE_Pendiente_Firma') AND RecordType.DeveloperName LIKE '%EMP' AND AV_ToDelete__c = false AND OwnerId = :userinfo.getUserId() AND (CloseDate = NEXT_N_DAYS:7 OR CloseDate = TODAY )
            ORDER BY CloseDate ASC];
            
        }
        Map<String,String> pickListValuesMap = new Map<String,String>();
		for( Schema.PicklistEntry pickListVal : Opportunity.stagename.getDescribe().getPicklistValues()){
            pickListValuesMap.put(pickListVal.getValue(),pickListVal.getLabel());
		}
        List<Wrapper> listReturn = new List<Wrapper>();
        String importe;
        Integer importeInt;
        for(Opportunity opportunity : opp) {
            if(opportunity.CIBE_AmountDivisa__c != null){
                importeInt = Integer.valueOf(opportunity.CIBE_AmountDivisa__c.round(RoundingMode.HALF_UP));
            }
            else{
                importeInt = 0;
            }
            listReturn.add(
                new Wrapper(
                    opportunity.AccountId,
                    opportunity.Account.Name,
                    opportunity.Id,
                    opportunity.Name,
                    importe = String.valueOf(importeInt.format()),
                    pickListValuesMap.containsKey(opportunity.StageName) ? pickListValuesMap.get(opportunity.StageName) :opportunity.StageName,
                    String.isNotBlank(opportunity.AV_PF__r.Name) ? opportunity.AV_PF__r.Name : '',
                    opportunity.AV_Origen__c,
                    opportunity.CloseDate
                    
                ));
        }
        return listReturn;
    }


    public class Wrapper{

        @AuraEnabled 
        public String idAccount {get;set;}

        @AuraEnabled 
        public String AccountName {get;set;}

        @AuraEnabled 
        public String idOpportunity {get;set;}

        @AuraEnabled 
        public String nameOportunity {get;set;}

        @AuraEnabled 
        public String importe {get;set;}

        @AuraEnabled 
        public String etapa {get;set;}

        @AuraEnabled 
        public String nameProduct {get;set;}

        @AuraEnabled 
        public String origen {get;set;}

        @AuraEnabled 
        public Date fechaCierre {get;set;}
        
        public Wrapper(String idAccount, String AccountName, String idOpportunity, String nameOportunity, String importe, String etapa, String nameProduct, String origen, Date fechaCierre ) {
            
            this.idAccount= '/'+ idAccount;
            this.AccountName = AccountName;
            this.idOpportunity= '/'+ idOpportunity;
            this.nameOportunity = nameOportunity;
            this.importe = importe;
            this.etapa = etapa;
            this.nameProduct = nameProduct;
            this.origen = origen;
            this.fechaCierre = fechaCierre;

        }
    }

}