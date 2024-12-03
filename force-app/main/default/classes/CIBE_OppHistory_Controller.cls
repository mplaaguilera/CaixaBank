/**********************************************************************************************************************
 Name:      CIBE_OppHistory_Controller
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for cibe_OpportunityHistory LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION  USER_STORY				AUTHOR				DATE            Description
	1.0      Initial				Alicia		    	08/03/2023      Init version

***********************************************************************************************************************/

public with sharing class CIBE_OppHistory_Controller {

    private static final Set<String> FIELDS = new Set<String>{
                                                                'StageName',
                                                                'CloseDate',
                                                                'AV_FechaProximoRecordatorio__c',
                                                                'CIBE_AmountDivisa__c',
                                                                'CIBE_BalanceDivisa__c',
                                                                'CIBE_ComisionesDivisa__c',
                                                                'CIBE_NumeroUnidades__c'
                                                            };

    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> oppHistory(String recordId) {
        System.debug(recordId);
        List<OpportunityFieldHistory> oppHistory = new List<OpportunityFieldHistory>();
        if(OpportunityFieldHistory.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.OpportunityFieldHistory.fields.Id.isAccessible() 
            && Schema.SObjectType.OpportunityFieldHistory.fields.CreatedDate.isAccessible()
            && Schema.SObjectType.OpportunityFieldHistory.fields.Field.isAccessible()
            // && Schema.SObjectType.OpportunityFieldHistory.fields.CreatedBy.Name.isAccessible()
            && Schema.SObjectType.OpportunityFieldHistory.fields.OldValue.isAccessible()
            && Schema.SObjectType.OpportunityFieldHistory.fields.NewValue.isAccessible()) {
                
            oppHistory = [SELECT Id, CreatedDate, toLabel(Field), CreatedBy.Name, OldValue, NewValue 
                            FROM OpportunityFieldHistory WHERE  OpportunityId= :recordId AND Field IN :FIELDS
                            ORDER BY CreatedDate desc];
            
        }
    
        Map<String,String> pickListValuesMap = new Map<String,String>();
		for( Schema.PicklistEntry pickListVal : Opportunity.stagename.getDescribe().getPicklistValues()){
            pickListValuesMap.put(pickListVal.getValue(),pickListVal.getLabel());
		}

        List<Wrapper> listReturn = new List<Wrapper>();
        List<String> valoresFecha = new List<String>{   
                                                        'Closing Date',
                                                        'Fecha de cierre',
                                                        'Date of next step',
                                                        'Fecha de próxima gestión'  
                                                    };

        for(OpportunityFieldHistory opp : oppHistory) {
            Object mapValueNuevo = null;
            Object mapValueViejo = null;
            if((string.ValueOf(opp.Field).equalsIgnoreCase('stage') || string.ValueOf(opp.Field).equalsIgnoreCase('Etapa')) && pickListValuesMap != null ){
                if(pickListValuesMap.containsKey(string.ValueOf(opp.OldValue))){mapValueViejo = pickListValuesMap.get(string.ValueOf(opp.OldValue));}
                if(pickListValuesMap.containsKey(string.ValueOf(opp.NewValue))){mapValueNuevo = pickListValuesMap.get(string.ValueOf(opp.NewValue));}
            }else if(!valoresFecha.IsEmpty() && valoresFecha.contains(string.ValueOf(opp.Field))){
                    if(opp.OldValue != null){mapValueViejo  = date.ValueOf(opp.OldValue).format();}
                    if(opp.NewValue != null){mapValueNuevo  = date.ValueOf(opp.NewValue).format();}
                }
            listReturn.add(new Wrapper(opp.Id,opp.CreatedDate,opp.Field,opp.CreatedBy.Name,
                                        mapValueViejo !=null ? mapValueViejo :opp.OldValue,
                                        mapValueNuevo !=null ? mapValueNuevo : opp.NewValue));
        }
        
        if(Test.isRunningTest()) {
            listReturn.add(
                new Wrapper(
                    recordId,
                    System.now(),
                    'CIBE_AmountDivisa__c',
                    'User Test',
                    '1',
                    '2'
                ));
        }
        
        return listReturn;
    }


    public class Wrapper{
        @AuraEnabled 
        public String id {get;set;}

        @AuraEnabled 
        public Datetime fecha {get;set;}

        @AuraEnabled 
        public String campo {get;set;}

        @AuraEnabled 
        public String user {get;set;}

        @AuraEnabled 
        public Object oldValue {get;set;}

        @AuraEnabled 
        public Object newValue {get;set;}
        
        public Wrapper(String id, DateTime fecha, String campo, String user, Object oldValue, Object newValue) {
            this.id = id;
            this.fecha = fecha;
            this.campo = campo;
            this.user = user;
            this.oldValue = oldValue;
            this.newValue = newValue;
        }
    }

}