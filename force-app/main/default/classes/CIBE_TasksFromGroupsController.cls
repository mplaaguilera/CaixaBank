/**********************************************************************************************************************
Name:	  CIBE_TasksFromGroupsController
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
Historial
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0					        Alex Campos		08/05/2023		Init version

-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/
public with sharing class CIBE_TasksFromGroupsController {
    
    private static List<String> stages = new List<String>{'Open'};
    
    private static Set<Id> recordTypes = CIBE_AppUtilities.getRecordTypeIdsInSet(
        new Set<CIBE_AppUtilities.SearchRT>{
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT),
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_EMP_RT),
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ONBOARDING_CIB_RT),
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ONBOARDING_EMP_RT),
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_PRIORIZADOS_CIB_RT),
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_PRIORIZADOS_EMP_RT),
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_CIB_RT),
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT),
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_AVISOS_CIB_RT),
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_AVISOS_EMP_RT),
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_CIB_RT),
            new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_EMP_RT)
        });

    @AuraEnabled(cacheable = true) 
    public static List<TaskWrapper> getRecords(Integer offSet, List<String> recordIds) {
        List<Task> tasks = new List<Task>();
        if(!recordIds.isEmpty() && Task.SObjectType.getDescribe().isAccessible()) {
            tasks = [SELECT Id, 
                            Subject,
                            AccountId,
                            Account.Name,
                            toLabel(Status),
                            ActivityDate,
                            OwnerId,
                            Owner.Name,
                            RecordType.Name
                        FROM Task
                        WHERE RecordTypeId IN :recordTypes AND WhatId = :recordIds AND Status = :stages AND AV_ToDelete__c = FALSE
                        ORDER BY ActivityDate ASC LIMIT 10 OFFSET :offSet];
        }

        List<TaskWrapper> result = new List<TaskWrapper>();
        for(Task t : tasks) {
            TaskWrapper tw = new TaskWrapper();
            tw.id = t.Id;
            tw.idUrl = '/' + t.Id;
            tw.name = t.Subject;
            tw.accountId = t.AccountId;
            tw.accountIdUrl = '/' + t.AccountId;
            tw.accountName = t.Account.Name;
            tw.status = t.Status;
            tw.activityDate = t.ActivityDate;
            tw.owner = t.Owner.Name;
            tw.ownerIdUrl = '/' + t.OwnerId;
            tw.recordType = t.RecordType.Name;
            result.add(tw);
        }
        return result;
    }

    public class TaskWrapper {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String idUrl {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String accountId {get;set;}
        @AuraEnabled public String accountIdUrl {get;set;}
        @AuraEnabled public String accountName {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public Date activityDate {get;set;}
        @AuraEnabled public String owner {get;set;}
        @AuraEnabled public String ownerIdUrl {get;set;}
        @AuraEnabled public String recordType {get;set;}
    }

}