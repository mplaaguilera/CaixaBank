/**********************************************************************************************************************
 Name:      CIBE_HomeTareas7Dias_Controller
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for cibe_HomeTareas7Dias LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION  USER_STORY				AUTHOR				DATE            Description
	1.0      Initial				Bea		    	13/04/2023      Init version

***********************************************************************************************************************/

public with sharing class CIBE_HomeTareas7Dias_Controller {

    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> tasks () {
        List<Wrapper> listReturn = new List<Wrapper>();

        if(Task.SObjectType.getDescribe().isAccessible()) {
                
            Map<String,String> pickListValuesMap = new Map<String,String>();
            for( Schema.PicklistEntry pickListVal : Task.Status.getDescribe().getPicklistValues()){
                pickListValuesMap.put(pickListVal.getValue(),pickListVal.getLabel());
            }
            List<String> pickListOrigen = new List<String>();
            pickListOrigen.add('');
            for( Schema.PicklistEntry pickListVal : Task.AV_OrigenApp__c.getDescribe().getPicklistValues()){
                if(!pickListVal.getValue().equalsIgnoreCase('AV_SalesforceTaskOpp')){
                    pickListOrigen.add(pickListVal.getValue());
                }
            }
            for(Task task : [SELECT Id, Account.Name, AV_Origen__c, Subject, Status, ActivityDate FROM Task 
                            WHERE (ActivityDate >= LAST_N_DAYS:7 AND ActivityDate < TODAY) AND RecordType.DeveloperName LIKE '%EMP' AND 
                            Status in ('Open', 'No gestionada') AND AV_OrigenApp__c IN :pickListOrigen AND AV_VisibleByLoggedUser__c = true AND AV_ToDelete__c = false
                            AND OwnerId =: userinfo.getUserId() 
                            ORDER BY ActivityDate DESC]) {
                listReturn.add(
                    new Wrapper(
                        task.AccountId,
                        task.Account.Name,
                        task.AV_Origen__c,
                        task.Id,
                        task.Subject,
                        pickListValuesMap.containsKey(task.Status) ? pickListValuesMap.get(task.Status) :task.Status,
                        task.ActivityDate
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
        public String origen {get;set;}

        @AuraEnabled 
        public String idTask {get;set;}

        @AuraEnabled 
        public String asunto {get;set;}

        @AuraEnabled 
        public String estado {get;set;}

        @AuraEnabled 
        public Date fechaVencimiento {get;set;}

       
        
        public Wrapper(String idAccount, String AccountName, String origen, String idTask, String asunto, String estado , Date fechaVencimiento) {
            
            this.idAccount= '/'+ idAccount;
            this.AccountName = AccountName;
            this.origen = origen;
            this.idTask = '/'+ idTask;
            this.asunto = asunto;
            this.estado = estado;
            this.fechaVencimiento = fechaVencimiento;

        }
    }

}