/**********************************************************************************************************************
Name: AV_CheckOnOff_Queueable
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Propósito: Convertir los procesos DML de check on/off en queueable
-----------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------
VERSION  USER_STORY       AUTHOR           DATE          Description
1.0      US365180         Víctor Santiago  12/04/2022    Init version

***********************************************************************************************************************/
global class AV_CheckOnOff_Queueable implements Queueable, Database.AllowsCallouts {
    
    global static final String BATCHNAME = 'AV_CheckOnOff_Queueable';
    private static final String SUFFIX_EXTERNALID = 'Opp-';
    
    
    public class CheckOnOffData  {
        @AuraEnabled
        public List<Id> deleteTareaOpp;
        @AuraEnabled
        public List<Id> deleteHeaderTsk;
        @AuraEnabled
        public List<Id> deleteTask;
        @AuraEnabled
        public List<Task> tasksToUpdate;
        @AuraEnabled
        public List<Task> tasksToCreate;
        @AuraEnabled
        public Map<String, Task> mapTask;
        @AuraEnabled
        public List<Opportunity> listUsedOpp;
        @AuraEnabled
        public List<Opportunity> oppsToUpdate;
        @AuraEnabled
        public  Datetime dateExternalId;
    }
    
    List<Id> deleteTareaOpp = new List<Id>();
    List<Id> deleteHeaderTsk = new List<Id>();
    List<Id> deleteTask = new List<Id>();
    List<Task> tasksToUpdate = new List<Task>();
    List<Task> tasksToCreate = new List<Task>();
    Map<String, Task> mapTask = new Map<String, Task>();
    List<Opportunity> listUsedOpp = new List<Opportunity>();
    List<Opportunity> oppsToUpdate = new List<Opportunity>();
    Datetime dateExternalId;

    public AV_CheckOnOff_Queueable(List<Opportunity> listOpp){
        this.oppsToUpdate = listOpp;
    } 

    public AV_CheckOnOff_Queueable(List<Task> listUpdateTask){
        this.tasksToUpdate = listUpdateTask;
    } 
    
    public AV_CheckOnOff_Queueable(List<Id> listDeleteTaskOpp,List<Id> listDeleteHeaderTsk,List<Id> listDeleteTask ){
        this.deleteTareaOpp = listDeleteTaskOpp;
        this.deleteHeaderTsk = listDeleteHeaderTsk;
        this.deleteTask = listDeleteTask;
    } 

    public AV_CheckOnOff_Queueable(List<Task> newTask,Map<String, Task> mapNewTask,List<Opportunity> usedOpp, datetime externalId){
         this.tasksToCreate = newTask;
         this.mapTask = mapNewTask;
         this.listUsedOpp = usedOpp;
         this.dateExternalId = externalId;
    }
    
    global void execute(System.QueueableContext qc) {
        System.debug('AV_CheckOnOff_Queueable ');
        System.debug(qc);
        if(this.deleteTareaOpp != null && !this.deleteTareaOpp.isEmpty()) {
            Database.delete(this.deleteTareaOpp, false);
            if (this.deleteTask != null && !this.deleteTask.isEmpty()) {
                Database.delete(this.deleteTask, false);
                if (this.deleteHeaderTsk != null && !this.deleteHeaderTsk.isEmpty()) {
                    Database.delete(this.deleteHeaderTsk, false);
                }
            }
        } else if (this.tasksToUpdate != null && !this.tasksToUpdate.isEmpty()) {
            Database.update(this.tasksToUpdate, false);
        } else if (this.tasksToCreate !=null && !this.tasksToCreate.isEmpty() && !this.mapTask.isEmpty() && !this.listUsedOpp.isEmpty() && dateExternalId != null) {
            createTaskCheckOnOff(this.tasksToCreate, this.mapTask, this.listUsedOpp, this.dateExternalId);
        } 
        if (this.oppsToUpdate != null && !this.oppsToUpdate.isEmpty()) {
            updateListOpp(json.serialize(this.oppsToUpdate));
            //updateListOpp(this.oppsToUpdate);
        }
    }
    
    public static void createTaskCheckOnOff(List<Task> listTask, Map<String, Task> mapTask, List<Opportunity> listUsedOpp, Datetime dateExternalId) {
        //Insert task + task-opp
        if (listTask!=null && !listTask.isEmpty()){
            //Insert task
            Database.insert(listTask, false);
            // Datetime added because inside the queueable AV_OpportunityTriggerHelper.dateExternalId is not accessible
            String prefixSuffix = SUFFIX_EXTERNALID + '@' + dateExternalId;
            List<AV_CustomActivityOpportunity__c> newlistTaskAndOpp = 
                AV_OpportunityTriggerHelperAux.createTaskOppWhenCheck(mapTask.keySet(), listUsedOpp, prefixSuffix);
            //Insert task-opp
            if(newlistTaskAndOpp != null && !newlistTaskAndOpp.isEmpty()){
                Database.insert(newlistTaskAndOpp, false);
            }
            Map<String, AV_CustomActivityOpportunity__c> mapTaskOpp = new Map<String, AV_CustomActivityOpportunity__c>();
            for(AV_CustomActivityOpportunity__c cap : newlistTaskAndOpp){
                mapTaskOpp.put(cap.AV_Task__c, cap);
            }
            //Update header-task with the id of the Task
            List<AV_HeaderCustomActivity__c> listHeaderTask = [
                SELECT Id, AV_ExternalID__c, IDTask__c
                FROM AV_HeaderCustomActivity__c
                WHERE Id IN :mapTaskOpp.keySet()
            ];
            
            Map<String, AV_HeaderCustomActivity__c> mapHeaderTask = new Map<String, AV_HeaderCustomActivity__c>();
            for(AV_HeaderCustomActivity__c hca : listHeaderTask){
                mapHeaderTask.put(hca.AV_ExternalID__c, hca);
            }
            if(listHeaderTask != null && !listHeaderTask.isEmpty()){
                AV_OpportunityTriggerHelperAux.fillHeaderTask(listTask, mapHeaderTask);
            }
        }
    }
    
    @Future
    public static void updateListOpp(String jsonString) {
        system.debug(jsonString);
        List<Opportunity> updateList = (List<Opportunity>)Json.deserialize(jsonString,List<Opportunity>.class);
        for(Opportunity opp :updateList) {
            opp.AV_IncludeInPrioritizingCustomers__c = false;
            if(opp.AV_FechaProximoRecordatorio__c >= System.today()){
                opp.AV_FechaProximoRecordatorio__c = null;
            }
        }
        Database.update(updateList, false);
    }
}