public with sharing class CIBE_TaskReport_Controller {
    public class TaskWrapper{
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled 
        public String tipo {get;set;}
        @AuraEnabled
        public String accountId {get;set;}
        @AuraEnabled
        public String accountName {get;set;}
        @AuraEnabled
        public String accountRt {get;set;}
        @AuraEnabled
        public Boolean contactIntouch {get;set;}
        @AuraEnabled
        public String headerId {get;set;}
        @AuraEnabled
        public String subjectTask {get;set;}
        @AuraEnabled
        public String statusTask {get;set;}
        @AuraEnabled
        public Date activityDateTask {get;set;}
        @AuraEnabled
        public String priorityTask {get;set;}
        @AuraEnabled
        public String recordType {get;set;}
        @AuraEnabled
        public String descripcion {get;set;}
        @AuraEnabled
        public DateTime reminder {get;set;}
        @AuraEnabled
        public String contacto {get;set;}
        @AuraEnabled
        public List<OpportunityWrapper> lstOppVin {get;set;}
    }
    public class OpportunityWrapper{
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled 
        public String name {get;set;}
        @AuraEnabled 
        public Date closeDate {get;set;
        }@AuraEnabled 
        public String status {get;set;}
        @AuraEnabled 
        public String accountId {get;set;}
        @AuraEnabled 
        public String owner {get;set;}
        @AuraEnabled 
        public Date proximaGestion {get;set;}
        @AuraEnabled 
        public String comments {get;set;}
        @AuraEnabled 
        public Boolean oppLinked {get;set;}
    }
/**
     * @description     Retrieves the description and type of the task
     * @param id        Id of the task about to be closed
     */
    @AuraEnabled
    public static TaskWrapper getTaskData(String id){
        String methodName = 'getTaskData';
        TaskWrapper taskWrapper = new TaskWrapper();
        try {
            Task ta = [SELECT Id, RecordType.DeveloperName, Description,ReminderDateTime,Subject, AV_Tipo__c, AccountId, ActivityDate, toLabel(Priority), toLabel(Status), Account.Name, Account.RecordType.DeveloperName, AV_Task__c, whoId FROM Task WHERE Id = :id LIMIT 1];
            taskWrapper.id = ta.Id;
            taskWrapper.tipo = ta.AV_Tipo__c;
            taskWrapper.accountId = ta.AccountId;
            taskWrapper.accountName = ta.Account.Name;
            taskWrapper.accountRt = ta.Account.RecordType.DeveloperName;
            taskWrapper.headerId = ta.AV_Task__c;
            taskWrapper.subjectTask = ta.Subject;
            taskWrapper.statusTask = ta.Status;
            taskWrapper.activityDateTask = ta.ActivityDate;
            taskWrapper.priorityTask = ta.Priority;
            taskWrapper.recordType = ta.RecordType.DeveloperName;
            taskWrapper.descripcion = ta.Description;
            taskWrapper.reminder = ta.ReminderDateTime;
            taskWrapper.contacto = ta.whoId;
            taskWrapper.lstOppVin = new List<OpportunityWrapper>();

            System.debug('#lmg# ta.AV_Task__c'+ta.AV_Task__c);
            if(ta.AV_Task__c!=null){
                List <AV_CustomActivityOpportunity__c> lstCusActOpp = [SELECT Id, AV_Opportunity__c,AV_Opportunity__r.CloseDate, AV_Opportunity__r.StageName, 
                                                                        AV_Opportunity__r.OwnerId, AV_Opportunity__r.AV_FechaProximoRecordatorio__c,
                                                                        AV_Opportunity__r.AV_Comentarios__c, AV_Task__c,  AV_IsMain__c, AV_Opportunity__r.Name
                                                                        FROM AV_CustomActivityOpportunity__c WHERE  AV_Task__c =:ta.AV_Task__c];
                System.debug('#lmg# lstCusActOpp'+lstCusActOpp);
                if(! lstCusActOpp.isEmpty()){

                    for (AV_CustomActivityOpportunity__c cao : lstCusActOpp) {
                        System.debug('#lmg# cao'+cao);
                        if(cao!= null && cao.AV_Opportunity__c != null){
                            OpportunityWrapper oppWrap = new OpportunityWrapper();
                            oppWrap.id = cao.AV_Opportunity__c;
                            oppWrap.name = cao.AV_Opportunity__r.Name;
                            oppWrap.closeDate = cao.AV_Opportunity__r.CloseDate;
                            oppWrap.status = cao.AV_Opportunity__r.StageName;
                            oppWrap.accountId = ta.AccountId;
                            oppWrap.owner = cao.AV_Opportunity__r.OwnerId;
                            oppWrap.proximaGestion = cao.AV_Opportunity__r.AV_FechaProximoRecordatorio__c;
                            oppWrap.comments = cao.AV_Opportunity__r.AV_Comentarios__c;
                            oppWrap.oppLinked = true;
                            taskWrapper.lstOppVin.add(oppWrap);
                            System.debug('#lmg# cao'+cao);
                        }
                    }
                }
            }
            System.debug('#lmg#  taskWrapper.lstOppVin'+ taskWrapper);

            List<Contact> co = [SELECT AV_EmpleadoIntouch__c  FROM Contact WHERE AV_UsuarioAsociado__c = :UserInfo.getUserId() LIMIT 1];
            System.debug('#lmg#  co'+ co);

            if (co != null && !co.isEmpty()) {
                taskWrapper.contactIntouch = co[0].AV_EmpleadoIntouch__c;
            }
        } catch (Exception e) {
            AV_LogDebug.printException(methodName, e);
            throw new AuraHandledException(e.getMessage());
        }
        return taskWrapper;
    }
    /**
     * @description     Retrieves the description and type of the task
     * @param id        Id of the task about to be closed
     */
    @AuraEnabled
    public static String updateCurrentTask(Id idTask, String statusTask){

        if(idTask!=null && !String.isBlank(statusTask)){
            Task tareaActualizada = new Task();
            tareaActualizada.id = idTask;
            //tareaActualizada.CSBD_Evento_Estado__c = statusTask;
            tareaActualizada.Status = statusTask;

            update tareaActualizada;
            return 'Tarea Actualizada';
        }
        return 'KO';

    }

}