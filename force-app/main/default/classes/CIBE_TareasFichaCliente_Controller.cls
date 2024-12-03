/**********************************************************************************************************************
 Name:      CIBE_TareasFichaCliente_Controller
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for cibe_TareasFichaCliente_Controller LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION  USER_STORY				AUTHOR				DATE            Description
	1.0      Initial				Bea		    	    21/04/2023      Init version

***********************************************************************************************************************/

public with sharing class CIBE_TareasFichaCliente_Controller {

    @AuraEnabled(cacheable = true) 
    public static List<Wrapper> tasksFichaCli(String recordId) {
        
        List<Task> tasks = new List<Task>();
        if(Task.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.Task.fields.Id.isAccessible()
            && Schema.SObjectType.Task.fields.Subject.isAccessible()
            && Schema.SObjectType.Task.fields.AV_Origen__c.isAccessible()
            && Schema.SObjectType.Task.fields.AV_Origen__c.isAccessible()
            && Schema.SObjectType.Task.fields.ActivityDate.isAccessible()
            && Schema.SObjectType.Task.fields.Status.isAccessible()
            && Schema.SObjectType.Task.fields.AV_ToDelete__c.isAccessible()) {
            
            tasks = [SELECT Id, AV_Origen__c, Subject, Status, ActivityDate, Owner.Name FROM Task WHERE RecordType.DeveloperName LIKE 'CIBE_%' AND (ActivityDate=LAST_N_DAYS:3 OR ActivityDate>=TODAY) AND Status IN ('Open','Pendiente no localizado') AND AccountId = :recordId AND AV_ToDelete__c = false];
        }
        System.debug('@@@Tasks');
        System.debug(tasks);
        Map<String,String> pickListValuesMap = new Map<String,String>();
		for( Schema.PicklistEntry pickListVal : Task.Status.getDescribe().getPicklistValues()){
            pickListValuesMap.put(pickListVal.getValue(),pickListVal.getLabel());
		}
        List<Wrapper> listReturn = new List<Wrapper>();
        for(Task task : tasks) {
            listReturn.add(
                new Wrapper(
                    task.AV_Origen__c,
                    task.Id,
                    task.Subject,
                    pickListValuesMap.containsKey(task.Status) ? pickListValuesMap.get(task.Status) :task.Status,
                    task.ActivityDate,
                    task.OwnerId,
                    task.Owner.Name
                ));
        }
        System.debug('@@@listReturn');
        System.debug(listReturn);
        return listReturn;
    }


    public class Wrapper{

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

        @AuraEnabled 
        public String ownerId {get;set;}

        @AuraEnabled 
        public String ownerName {get;set;}
        
        public Wrapper(String origen, String idTask, String asunto, String estado , Date fechaVencimiento, String ownerId, String ownerName) {
            
            this.origen = origen;
            this.idTask = '/'+ idTask;
            this.asunto = asunto;
            this.estado = estado;
            this.fechaVencimiento = fechaVencimiento;
            this.ownerId= '/'+ ownerId;
            this.ownerName = ownerName;
        }
    }

}