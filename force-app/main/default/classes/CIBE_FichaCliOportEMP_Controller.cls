/**********************************************************************************************************************
 Name:      CIBE_FichaCliOportEMP_Controller
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for cibe_FichaCliOportEMP LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION  USER_STORY				AUTHOR				DATE            Description
	1.0      Initial				Bea		    	22/03/2023      Init version

***********************************************************************************************************************/

public with sharing class CIBE_FichaCliOportEMP_Controller {

    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> opportunities (String recordId) {
        
        List<Opportunity> opp = new List<Opportunity>();
        if(Opportunity.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.Opportunity.fields.Id.isAccessible()
            && Schema.SObjectType.Opportunity.fields.Name.isAccessible() 
            && Schema.SObjectType.Opportunity.fields.CIBE_AmountDivisa__c.isAccessible()
            && Schema.SObjectType.Opportunity.fields.CIBE_Divisa__c.isAccessible()
            && Schema.SObjectType.Opportunity.fields.CIBE_BalanceDivisa__c.isAccessible()
            && Schema.SObjectType.Opportunity.fields.CIBE_ComisionesDivisa__c.isAccessible()
            && Schema.SObjectType.Opportunity.fields.StageName.isAccessible()
            && Schema.SObjectType.Opportunity.fields.AV_PF__c.isAccessible()
            && Schema.SObjectType.Opportunity.fields.OwnerId.isAccessible()
            && Schema.SObjectType.Opportunity.fields.CIBE_DiasUltimaGestion__c.isAccessible()
            && Schema.SObjectType.Opportunity.fields.CloseDate.isAccessible()) {
                
            opp = [SELECT Id, Name, CIBE_AmountDivisa__c, CIBE_Divisa__c, StageName, AV_PF__r.Name, AV_PF__r.Id, Owner.Name, OwnerId, CIBE_DiasUltimaGestion__c, CloseDate
                    FROM Opportunity WHERE StageName IN ('Potencial', 'CIBE_Pendiente_Firma', 'En curso') AND RecordType.DeveloperName LIKE 'CIBE_%' AND AccountId = :recordId AND AV_ToDelete__c = false ORDER BY CloseDate ASC];
            
        }
        Map<String,String> pickListValuesMap = new Map<String,String>();
		for( Schema.PicklistEntry pickListVal : Opportunity.stagename.getDescribe().getPicklistValues()){
            pickListValuesMap.put(pickListVal.getValue(),pickListVal.getLabel());
		}
        List<Wrapper> listReturn = new List<Wrapper>();
        for(Opportunity opportunity : opp) {
            listReturn.add(
                new Wrapper(
                    opportunity.Id,
                    opportunity.Name,
                    opportunity.CIBE_AmountDivisa__c,
                    opportunity.CIBE_Divisa__c,
                    pickListValuesMap.containsKey(opportunity.StageName) ? pickListValuesMap.get(opportunity.StageName) :opportunity.StageName,
                    opportunity.AV_PF__r.Name,
                    opportunity.AV_PF__r.Id,
                    opportunity.Owner.Name,
                    opportunity.OwnerId,
                    opportunity.CIBE_DiasUltimaGestion__c,
                    opportunity.CloseDate
                    
                ));
        }
        
        return listReturn;
    }


    public class Wrapper{
        @AuraEnabled 
        public String idOpportunity {get;set;}

        @AuraEnabled 
        public String nameOportunity {get;set;}

        @AuraEnabled 
        public Decimal importe {get;set;}

        @AuraEnabled 
        public String divisa {get;set;}

        @AuraEnabled 
        public String etapa {get;set;}

        @AuraEnabled 
        public String nameProduct {get;set;}

        @AuraEnabled 
        public String idProduct {get;set;}

        @AuraEnabled 
        public String nameOwner {get;set;}

        @AuraEnabled 
        public String idOwner {get;set;}

        @AuraEnabled 
        public Decimal diasUltGestion {get;set;}

        @AuraEnabled 
        public Date fechaCierre {get;set;}
        
        public Wrapper(String idOpportunity, String nameOportunity, Decimal importe, String divisa, String etapa, String nameProduct, String idProduct, String nameOwner, String idOwner, Decimal diasUltGestion, Date fechaCierre ) {
            
            this.idOpportunity= '/'+ idOpportunity;
            this.nameOportunity = nameOportunity;
            this.importe = importe;
            this.divisa = divisa;
            this.etapa = etapa;
            this.nameProduct = nameProduct;
            this.idProduct = '/'+ idProduct;
            this.nameOwner = nameOwner;
            this.idOwner = '/'+ idOwner;
            this.diasUltGestion = diasUltGestion;
            this.fechaCierre = fechaCierre;

        }
    }

}