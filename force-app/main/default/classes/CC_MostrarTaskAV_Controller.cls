public with sharing class CC_MostrarTaskAV_Controller {

public class modelTimeLine {
    @AuraEnabled
    public Id RecordId {get;set;}

    @AuraEnabled
    public String Subject {get;set;}

    @AuraEnabled
    public String Detail {get;set;}

    @AuraEnabled
    public String ShortDate {get;set;}

    @AuraEnabled
    public String Assigned {get;set;}

    @AuraEnabled
    public String AssignedId {get;set;}

    public DateTime ActualDate {get;set;}

    @AuraEnabled
    public String CaseId {get;set;}
    
    @AuraEnabled
    public String Estado {get;set;}

    @AuraEnabled
    public String Relacionado {get;set;}
}

    @AuraEnabled(cacheable=true)
    public static List<modelTimeLine> getTaskAV(Id recordId) {
        List<modelTimeLine> retorno = new List<modelTimeLine>();
        List<Task> tareas = [SELECT Id, Subject, CreatedDate, OwnerId, Owner.Name, TaskSubtype, CreatedById, CreatedBy.Name, toLabel(Status), Who.Name, Description, WhatId, ActivityDate FROM Task WHERE AV_Case__c = :recordId AND Type = 'Tarea gestor' ORDER BY CreatedDate DESC LIMIT 50];
        if(!tareas.isEmpty()) {
            for (Task t : tareas) {
                modelTimeLine taskItem = new modelTimeLine();
                taskItem.RecordId = t.Id;
                taskItem.Subject = t.Subject;
                taskItem.Detail = t.Description;
                taskItem.ActualDate = t.CreatedDate;
                taskItem.ShortDate = String.valueOf(t.ActivityDate);
                taskItem.Relacionado = t.Who.Name;
                taskItem.AssignedId = t.OwnerId;
                taskItem.Assigned = t.Owner.Name;
                taskItem.CaseId = t.WhatId;
                taskItem.Estado = t.Status;
                retorno.add(taskItem);
            }
		}
        return retorno.isEmpty() ? null : retorno;
    }
}