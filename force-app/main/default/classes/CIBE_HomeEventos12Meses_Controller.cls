/**********************************************************************************************************************
 Name:      CIBE_HomeEventos12Meses_Controller
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for cibe_HomeEventos12Meses_Controller LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION  USER_STORY				AUTHOR				DATE            Description
	1.0      Initial				Bea		    	17/04/2023      Init version

***********************************************************************************************************************/

public with sharing class CIBE_HomeEventos12Meses_Controller {

    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> events12Months (Integer offSet) {
        List<Wrapper> listReturn = new List<Wrapper>();
        if(Event.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.Event.fields.Id.isAccessible()
            && Schema.SObjectType.Event.fields.Subject.isAccessible()
            && Schema.SObjectType.Event.fields.AV_Tipo__c.isAccessible()
            && Schema.SObjectType.Event.fields.ActivityDateTime.isAccessible()
            && Schema.SObjectType.Event.fields.ActivityDate.isAccessible()
            && Schema.SObjectType.Event.fields.StartDateTime.isAccessible()
            && Schema.SObjectType.Event.fields.CSBD_Evento_Estado__c.isAccessible()
            && Schema.SObjectType.Event.fields.AV_VisibleByLoggedUser__c.isAccessible()) {
                
                system.debug('offSet: '+offSet);
                offSet = offSet <= 2000 ? offSet : 0;
                system.debug('offSet: '+offSet);

                Map<String,String> pickListValuesMap = new Map<String,String>();
                for( Schema.PicklistEntry pickListVal : Event.AV_Tipo__c.getDescribe().getPicklistValues()){
                    pickListValuesMap.put(pickListVal.getValue(),pickListVal.getLabel());
                }

                for(Event event :  [SELECT Id, Account.Name, Subject, AV_Tipo__c, StartDateTime, toLabel(CSBD_Evento_Estado__c) 
                                    FROM Event 
                                    WHERE RecordType.DeveloperName in ('CIBE_EventoCliente') AND (ActivityDate = LAST_N_MONTHS:12 AND ActivityDate < TODAY ) 
                                    AND AV_VisibleByLoggedUser__c = true AND (CSBD_Evento_Estado__c = 'Pendiente' AND OwnerId =: userinfo.getUserId())
                                    ORDER BY ActivityDateTime ASC LIMIT 10 OFFSET :offSet]) {
                    listReturn.add(
                        new Wrapper(
                            event.AccountId,
                            event.Account.Name,
                            event.Id,
                            event.Subject,
                            pickListValuesMap.containsKey(event.AV_Tipo__c) ? pickListValuesMap.get(event.AV_Tipo__c) :event.AV_Tipo__c,
                            event.StartDateTime,
                            event.CSBD_Evento_Estado__c
                        ));
                }
        }
        
        return listReturn;
    }


    public class Wrapper{
    
        @AuraEnabled 
        public String idAccount {get;set;}

        @AuraEnabled 
        public String AccountName {get;set;}

        @AuraEnabled 
        public String idEvent {get;set;}

        @AuraEnabled 
        public String asunto {get;set;}

        @AuraEnabled 
        public String tipo {get;set;}
        
        @AuraEnabled 
        public DateTime fechaInicio {get;set;}

        @AuraEnabled 
        public String estado {get;set;}

        public Wrapper(String idAccount, String AccountName, String idEvent, String asunto, String tipo, DateTime fechaInicio, String estado) {
            
            this.idAccount= '/'+ idAccount;
            this.AccountName = AccountName;
            this.idEvent = '/'+ idEvent;
            this.asunto = asunto;
            this.tipo = tipo;
            this.fechaInicio = fechaInicio;
            this.estado = estado;

        }
    }

}