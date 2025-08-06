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
    1.1      US917497				Lucía		    	07/05/2024      Update oppHistory

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

    private static final Set<String> FIELDSEMP = new Set<String>{
        'StageName',
        'CloseDate',
        'AV_FechaProximoRecordatorio__c',
        'CIBE_AmountDivisa__c',
        'CIBE_BalanceDivisa__c',
        'CIBE_ComisionesDivisa__c',
        'CIBE_NumeroUnidades__c',
        'AV_Entidad__c',
        'AV_FechaVencimiento__c',
        'AV_Gestor__c',
        'Amount', 
        'Name'
    };


    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> oppHistory(String recordId) {


        List<OpportunityFieldHistory> oppHistory = new List<OpportunityFieldHistory>();
        if(OpportunityFieldHistory.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.OpportunityFieldHistory.fields.Id.isAccessible() 
            && Schema.SObjectType.OpportunityFieldHistory.fields.CreatedDate.isAccessible()
            && Schema.SObjectType.OpportunityFieldHistory.fields.Field.isAccessible()
            && Schema.SObjectType.OpportunityFieldHistory.fields.OldValue.isAccessible()
            && Schema.SObjectType.OpportunityFieldHistory.fields.NewValue.isAccessible()) {
                
            oppHistory = [SELECT Id, CreatedDate, toLabel(Field), CreatedBy.Name, OldValue, NewValue 
                            FROM OpportunityFieldHistory WHERE  OpportunityId= :recordId AND Field IN :FIELDS
                            ORDER BY CreatedDate desc];
            
        }

        List<OpportunityFieldHistory> oppH;
        if(Test.isRunningTest()) {
            oppH = new List<OpportunityFieldHistory>{}; //OldValue, NewValue not writeable
            oppHistory.add(new OpportunityFieldHistory(OpportunityId=recordId, Field='CIBE_AmountDivisa__c'));
            oppHistory.add(new OpportunityFieldHistory(OpportunityId=recordId, Field='Stage'));

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
                                                        'Fecha de próxima gestión',
                                                        'Due Date on Other Entity',
                                                        'Fecha vencimiento en otra entidad'
                                                    };

        if(!oppHistory.isEmpty()){


            for(OpportunityFieldHistory opp : oppHistory) {
                Wrapper oppWrapp = new Wrapper();
                Object mapValueNuevo = null;
                Object mapValueViejo = null;
                if((string.ValueOf(opp.Field).equalsIgnoreCase('stage') || string.ValueOf(opp.Field).equalsIgnoreCase('Etapa')) &&  pickListValuesMap != null ){
                    if(pickListValuesMap.containsKey(string.ValueOf(opp.OldValue))){mapValueViejo = pickListValuesMap.get(string.ValueOf(opp.OldValue));}
                    if(pickListValuesMap.containsKey(string.ValueOf(opp.NewValue))){mapValueNuevo = pickListValuesMap.get(string.ValueOf(opp.NewValue));}
                }else if(!valoresFecha.IsEmpty() && valoresFecha.contains(string.ValueOf(opp.Field))){
                        if(opp.OldValue != null){mapValueViejo  = date.ValueOf(opp.OldValue).format();}
                        if(opp.NewValue != null){mapValueNuevo  = date.ValueOf(opp.NewValue).format();}
                }
                oppWrapp.id = opp.Id;
                oppWrapp.fecha = opp.CreatedDate;
                oppWrapp.campo = opp.Field;
                oppWrapp.user = opp.CreatedBy.Name;
                oppWrapp.oldValue = mapValueViejo !=null ? mapValueViejo :opp.OldValue;
                oppWrapp.newValue = mapValueNuevo !=null ? mapValueNuevo : opp.NewValue;
                listReturn.add(oppWrapp);
            }
        }
        
        return listReturn;
    }

    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> oppHistoryRole(String recordId, Integer offSet) {
        String role = [SELECT Id, UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()].UserRole.Name;
        List<Wrapper> listReturn = new List<Wrapper>();

        if(role == 'EMP'){
            listReturn = oppHistoryEMP(recordId, offSet);
        }
        else{
            listReturn = oppHistory(recordId);
        }
        return listReturn;
    }


    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> oppHistoryEMP(String recordId, Integer offSet) {

        List<OpportunityFieldHistory> oppHistory = new List<OpportunityFieldHistory>();
        if(OpportunityFieldHistory.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.OpportunityFieldHistory.fields.Id.isAccessible() 
            && Schema.SObjectType.OpportunityFieldHistory.fields.CreatedDate.isAccessible()
            && Schema.SObjectType.OpportunityFieldHistory.fields.Field.isAccessible()
            && Schema.SObjectType.OpportunityFieldHistory.fields.OldValue.isAccessible()
            && Schema.SObjectType.OpportunityFieldHistory.fields.NewValue.isAccessible()) {
                
            oppHistory = [SELECT Id, CreatedDate, TOLABEL(Field), CreatedBy.Name, OldValue, NewValue , DataType
                            FROM OpportunityFieldHistory WHERE  OpportunityId= :recordId AND Field IN :FIELDSEMP
                            ORDER BY CreatedDate desc LIMIT 10 OFFSET :offSet ];
            
        }

        List<OpportunityFieldHistory> oppH;
        if(Test.isRunningTest()) {
            oppH = new List<OpportunityFieldHistory>{}; //OldValue, NewValue not writeable
            oppHistory.add(new OpportunityFieldHistory(OpportunityId=recordId, Field='Stage'));
            oppHistory.add(new OpportunityFieldHistory(OpportunityId=recordId, Field='Comentario'));
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
                                                        'Fecha de próxima gestión',
                                                        'Due Date on Other Entity',
                                                        'Fecha vencimiento en otra entidad'
                                                    };

        if(!oppHistory.isEmpty()){
            for(OpportunityFieldHistory opp : oppHistory) {
                
                Wrapper oppWrapp = new Wrapper();

                Object mapValueNuevo = null;
                Object mapValueViejo = null;
                if((string.ValueOf(opp.Field).equalsIgnoreCase('stage') || string.ValueOf(opp.Field).equalsIgnoreCase('Etapa')) && pickListValuesMap != null ){
                    if(pickListValuesMap.containsKey(string.ValueOf(opp.OldValue))){mapValueViejo = pickListValuesMap.get(string.ValueOf(opp.OldValue));}
                    if(pickListValuesMap.containsKey(string.ValueOf(opp.NewValue))){mapValueNuevo = pickListValuesMap.get(string.ValueOf(opp.NewValue));}
                }else if(!valoresFecha.IsEmpty() && valoresFecha.contains(string.ValueOf(opp.Field))){
                    if(opp.OldValue != null){mapValueViejo  = date.ValueOf(opp.OldValue).format();}
                    if(opp.NewValue != null){mapValueNuevo  = date.ValueOf(opp.NewValue).format();}
                }

                if(opp.Field == 'Assigned Employee' || opp.Field == 'Empleado/a Asignado'){
                    String aux = (String) opp.NewValue;
                    if(aux != null && !aux.startsWith('003')){
                        oppWrapp.id = opp.Id;
                        oppWrapp.fecha = opp.CreatedDate;
                        oppWrapp.campo = opp.Field;
                        oppWrapp.user = opp.CreatedBy.Name;
                        oppWrapp.oldValue = mapValueViejo !=null ? mapValueViejo :opp.OldValue;
                        oppWrapp.newValue = mapValueNuevo !=null ? mapValueNuevo : opp.NewValue;
                        listReturn.add(oppWrapp);
                    }
                    
                   
                }else{
                    oppWrapp.id = opp.Id;
                    oppWrapp.fecha = opp.CreatedDate;
                    if(opp.DataType == 'Currency' && (opp.Field == 'Amount' || opp.Field == 'Importe')){
                        oppWrapp.campo = 'Importe €';
                    }else{
                        oppWrapp.campo = opp.Field;
                    }
                    oppWrapp.user = opp.CreatedBy.Name;
                    if((opp.Field == 'Amount' || opp.Field == 'Importe') ||
                    (opp.Field == 'Impacto en balance' || opp.Field == 'Impact on balance sheet') ||
                    (opp.Field == 'Impacto en com. upfront / firma' || opp.Field == 'Impact on upfront com.') || 
                    (opp.Field == 'Nº Unidades' || opp.Field == 'Units Number') ||
                    (opp.Field == 'Amount' || opp.Field == 'Importe')){

                        Decimal aux = Double.valueOf(opp.NewValue);
                        Decimal auxOld = Double.valueOf(opp.OldValue);
                        if(aux != null ){
                                oppWrapp.NewValue =  Decimal.valueOf(aux.round(RoundingMode.HALF_UP)).format();
                        }
                        if(auxOld != null){
                            oppWrapp.oldValue =  Decimal.valueOf(auxOld.round(RoundingMode.HALF_UP)).format();
                        }
                        
                    }else{
                        oppWrapp.oldValue = mapValueViejo !=null ? mapValueViejo :opp.OldValue;
                        oppWrapp.newValue = mapValueNuevo !=null ? mapValueNuevo : opp.NewValue;
                    }
                    listReturn.add(oppWrapp);
                }
                
            }
        }
        
        return listReturn;
    }



    public class Wrapper{
        @AuraEnabled 
        public String id;

        @AuraEnabled 
        public Datetime fecha;

        @AuraEnabled 
        public String campo;

        @AuraEnabled 
        public String user;

        @AuraEnabled 
        public Object oldValue;

        @AuraEnabled 
        public Object newValue;
    }

}