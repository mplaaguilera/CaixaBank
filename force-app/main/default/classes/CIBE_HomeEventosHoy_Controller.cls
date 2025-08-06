/**********************************************************************************************************************
 Name:      CIBE_HomeEventosHoy_Controller
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for cibe_HomeEventosHoy LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION  USER_STORY				AUTHOR				DATE            Description
	1.0      Initial				Bea		    	17/04/2023      Init version

***********************************************************************************************************************/

public with sharing class CIBE_HomeEventosHoy_Controller {

    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> eventsToday () {
        
        List<Wrapper> listReturn = new List<Wrapper>();
        if(Event.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.Event.fields.Id.isAccessible()
           // && Schema.SObjectType.Event.fields.Account.Name.isAccessible() 
            && Schema.SObjectType.Event.fields.Subject.isAccessible()
            && Schema.SObjectType.Event.fields.AV_Tipo__c.isAccessible()
            && Schema.SObjectType.Event.fields.ActivityDateTime.isAccessible()
            && Schema.SObjectType.Event.fields.CSBD_Evento_Estado__c.isAccessible()
            && Schema.SObjectType.Event.fields.AV_VisibleByLoggedUser__c.isAccessible()) {
                

                Map<String,String> pickListValuesMap = new Map<String,String>();
                for( Schema.PicklistEntry pickListVal : Event.AV_Tipo__c.getDescribe().getPicklistValues()){
                    pickListValuesMap.put(pickListVal.getValue(),pickListVal.getLabel());
                }

                for(Event event : [SELECT Id, Account.Name, Subject, AV_Tipo__c, ActivityDateTime, toLabel(CSBD_Evento_Estado__c) 
                                    FROM Event 
                                    WHERE RecordType.DeveloperName in ('CIBE_EventoCliente' , 'CIBE_EventoClienteCIB') and ActivityDate = TODAY AND OwnerId =: userinfo.getUserId()
                                    ORDER BY ActivityDateTime ASC ]) {
                    listReturn.add(
                        new Wrapper(
                            event.AccountId,
                            event.Account.Name,
                            event.Id,
                            event.Subject,
                            pickListValuesMap.containsKey(event.AV_Tipo__c) ? pickListValuesMap.get(event.AV_Tipo__c) :event.AV_Tipo__c,
                            event.ActivityDateTime,
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
        public DateTime horaFechaVencimiento {get;set;}

        @AuraEnabled 
        public String estado {get;set;}

        public Wrapper(String idAccount, String AccountName, String idEvent, String asunto, String tipo, DateTime horaFechaVencimiento, String estado) {
            
            this.idAccount= '/'+ idAccount;
            this.AccountName = AccountName;
            this.idEvent = '/'+ idEvent;
            this.asunto = asunto;
            this.tipo = tipo;
            this.horaFechaVencimiento = horaFechaVencimiento;
            this.estado = estado;

        }
    }

}