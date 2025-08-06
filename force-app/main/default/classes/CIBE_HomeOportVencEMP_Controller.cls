/**********************************************************************************************************************
 Name:      CIBE_HomeOportVencEMP_Controller
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for cibe_HomeOportVencidasEMP LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION  USER_STORY				AUTHOR				DATE            Description
	1.0      Initial				Bea		    	    13/11/2023      Init version

***********************************************************************************************************************/

public with sharing class CIBE_HomeOportVencEMP_Controller {

    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> homeOppVencidas() {
        
        List<Opportunity> opp = new List<Opportunity>();
        if(Opportunity.SObjectType.getDescribe().isAccessible()) {
            opp = [SELECT Id, AccountId, Account.Name, Name, CIBE_AmountDivisa__c, AV_PF__r.Name, AV_Origen__c, CloseDate
            FROM Opportunity WHERE StageName IN ('CIBE_Vencido') AND RecordType.DeveloperName LIKE '%EMP' AND AV_ToDelete__c = false AND OwnerId = :userinfo.getUserId()
            ORDER BY CloseDate ASC ];
            
        }
        Map<String,String> pickListValuesMap = new Map<String,String>();
		for( Schema.PicklistEntry pickListVal : Opportunity.stagename.getDescribe().getPicklistValues()){
            pickListValuesMap.put(pickListVal.getValue(),pickListVal.getLabel());
		}
        List<Wrapper> listReturn = new List<Wrapper>();
        String importe;
        Integer importeInt = 0;
        for(Opportunity opportunity : opp) {
            if(opportunity.CIBE_AmountDivisa__c != null){
                System.debug('---antes de cambiarle el valor: ' + importeInt);
                System.debug('--- entra en el if');
                importeInt = Integer.valueOf(opportunity.CIBE_AmountDivisa__c.round(RoundingMode.HALF_UP));
                System.debug('---despues de cambiarle el valor dentro del if: ' + importeInt);
            }
            else{
                importeInt = 0;
            }
            System.debug('---importeInt despues del if: ' + importeInt);
            listReturn.add(
                new Wrapper(
                    opportunity.AccountId,
                    opportunity.Account.Name,
                    opportunity.Id,
                    opportunity.Name,
                    importe = String.valueOf(importeInt.format()),
                    String.isNotBlank(opportunity.AV_PF__r.Name) ? opportunity.AV_PF__r.Name : '',
                    opportunity.AV_Origen__c,
                    opportunity.CloseDate
                    
                ));
        }
        System.debug('--- antes de listReturn: ' + importeInt);
        System.debug('@listReturn' + listReturn);
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
        public String nameProduct {get;set;}

        @AuraEnabled 
        public String origen {get;set;}

        @AuraEnabled 
        public Date fechaCierre {get;set;}
        
        public Wrapper(String idAccount, String AccountName, String idOpportunity, String nameOportunity, String importe, String nameProduct, String origen, Date fechaCierre ) {
            
            this.idAccount= '/'+ idAccount;
            this.AccountName = AccountName;
            this.idOpportunity= '/'+ idOpportunity;
            this.nameOportunity = nameOportunity;
            this.importe = importe;
            this.nameProduct = nameProduct;
            this.origen = origen;
            this.fechaCierre = fechaCierre;

        }
    }

}