public with sharing class CC_MostrarTaskAV_Controller {

public class modelTimeLine {
    @AuraEnabled
    public Id RecordId {get;set;}
    @AuraEnabled
    public String Subject {get;set;}
    @AuraEnabled
    public String ShortDate {get;set;}
    @AuraEnabled
    public String Assigned {get;set;}
    @AuraEnabled
    public String AssignedId {get;set;}
    @AuraEnabled
    public String Estado {get;set;}
}

    @AuraEnabled(cacheable=true)
    public static List<modelTimeLine> getTaskAV(Id recordId) {
        List<modelTimeLine> retorno = new List<modelTimeLine>();
        for (Task t : [SELECT Subject, OwnerId, Owner.Name, toLabel(Status), ActivityDate
                        FROM Task WHERE AV_Case__c = :recordId AND Type = 'Tarea gestor'
                        ORDER BY CreatedDate DESC LIMIT 50]) {
            modelTimeLine taskItem = new modelTimeLine();
            taskItem.RecordId = t.Id;
            taskItem.Subject = t.Subject;
            taskItem.ShortDate = String.valueOf(t.ActivityDate);
            taskItem.AssignedId = t.OwnerId;
            taskItem.Assigned = t.Owner.Name;
            taskItem.Estado = t.Status;
            retorno.add(taskItem);
        }
        return retorno;
    }
}