/**********************************************************************************************************************
Name:      CIBE_ConfidencialidadController
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller del componente cibe_ConfidencialidadActivity
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY 				AUTHOR              DATE                Description
    1.0            US379969    		        Alex Campos         05/07/2022          Init version
***********************************************************************************************************************/
public with sharing class CIBE_ConfidencialidadActivityController {
    
    @AuraEnabled(cacheable=true)
    public static Activity getRecord(String recordId) {
        Activity result = new Activity();
        result.id = recordId;
        if(String.isNotBlank(recordId) && Event.SObjectType.getDescribe().isAccessible()) {
            if(recordId.startsWith('00U')) {
                for(Event ev : [SELECT Id, CIBE_Confidential__c, RecordType.DeveloperName FROM Event WHERE Id = :recordId]) {
                    result.confidential = ev.CIBE_Confidential__c;
                    result.rtDeveloperName = ev.RecordType.DeveloperName;
                }
            } else if(recordId.startsWith('00T') && Task.SObjectType.getDescribe().isAccessible()) {
                for(Task tsk : [SELECT Id, CIBE_Confidential__c, RecordType.DeveloperName FROM Task WHERE Id = :recordId]) {
                    result.confidential = tsk.CIBE_Confidential__c;
                    result.rtDeveloperName = tsk.RecordType.DeveloperName;
                }
            }
        }
        return result;
    }

    @AuraEnabled
    public static void saveRecord(String recordId, Boolean confidential) {
        List<SObject> toUpdate = new List<SObject>();
        if(String.isNotBlank(recordId)) {
            if(recordId.startsWith('00U') && Event.SObjectType.getDescribe().isAccessible()) {
                for(Event ev : [SELECT Id, CIBE_Confidential__c FROM Event WHERE Id = :recordId]) {
                    ev.CIBE_Confidential__c = confidential;
                    toUpdate.add(ev);
                }
            } else if(recordId.startsWith('00T') && Task.SObjectType.getDescribe().isAccessible()) {
                for(Task tsk : [SELECT Id, CIBE_Confidential__c FROM Task WHERE Id = :recordId]) {
                    tsk.CIBE_Confidential__c = confidential;
                    toUpdate.add(tsk);
                }
            }
        }

        if(!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    @AuraEnabled
    public static void createNotification(String recordId) {
        List<CustomNotificationType> notificationTypes = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'CIBE_confidentialActivity'];

        if(recordId.startsWith('00U') && Event.SObjectType.getDescribe().isAccessible()) {
            List<Event> evnt = [SELECT Id, Subject, StartDateTime FROM Event WHERE  Id = :recordId];
            if(!evnt.isEmpty() && !notificationTypes.isEmpty()) {
                List<EventRelation> attendes = new List<EventRelation>();
                if(EventRelation.SObjectType.getDescribe().isAccessible()) {
                    attendes = [SELECT Id, EventId, RelationId, IsInvitee FROM EventRelation WHERE EventId = :recordId AND IsInvitee = true];
                }

                Set<String> contactIds = new Set<String>();
                for(EventRelation attende : attendes) {
                    contactIds.add(attende.RelationId);
                }

                List<Contact> esContacto = new List<Contact>();
                if(EventRelation.SObjectType.getDescribe().isAccessible()) {
                    esContacto = [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE Id IN :contactIds];
                }

                Set<String> userIds = new Set<String>();
                for(Contact c : esContacto) {
                    if(String.isNotBlank(c.AV_UsuarioAsociado__c)) {
                        userIds.add(c.AV_UsuarioAsociado__c);
                    }
                }
                
                for(EventRelation attende : attendes) {
                    if(String.isNotBlank(attende.RelationId) && ((String)attende.RelationId).startsWith('005')) {
                        userIds.add(attende.RelationId);
                    }
                }

                List<User> users = new List<User>();
                if(User.SObjectType.getDescribe().isAccessible()) {
                    users = [SELECT Id, LanguageLocaleKey FROM User WHERE Id IN :userIds];
                }

                Map<String, Set<String>> languages = new Map<String, Set<String>>();
                for(User u : users) {
                    if(String.isNotBlank(u.LanguageLocaleKey)) {
                        if(!languages.containsKey(u.LanguageLocaleKey)) {
                            languages.put(u.LanguageLocaleKey, new Set<String>());
                        }
                        languages.get(u.LanguageLocaleKey).add(u.Id);
                    }
                }

                if(!languages.isEmpty()) {
                    for(String language : languages.keySet()) {
                        String msj = Label.get(null, 'CIBE_ActivityMessageConfidential', language);
                        msj = msj.replace('[replace1]', evnt.get(0).Subject);
                        msj = msj.replace('[replace2]', evnt.get(0).StartDateTime.format('dd-MM-yyyy'));
    
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        notification.setTitle(Label.get(null, 'CIBE_ConfidentialEvent', language));
                        notification.setBody(msj);
                        notification.setNotificationTypeId(notificationTypes.get(0).Id);
                        notification.setTargetId(evnt.get(0).Id);
                        notification.send(languages.get(language));
                    }
                }
            }
        }

        // }else if(recordId.startsWith('00T')) {
        //     List<Task> tsk = [SELECT Id, Subject FROM Task WHERE  Id = :recordId];
        //     if(!tsk.isEmpty() && !notificationTypes.isEmpty()){
        //         List<TaskRelation > attendes = [SELECT Id, TaskId, RelationId  FROM TaskRelation WHERE TaskId = :recordId];
        //         Set<String> contacts = new Set<String>();
        //         Set<String> userIdsTask = new Set<String>();
        //         for(TaskRelation attende : attendes) {
        //             contacts.add(attende.RelationId);
        //         }
        //         List<Contact> users = [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE Id IN :contacts];
        //         for(Contact usuarioAsociado : users) {
        //             if(usuarioAsociado.AV_UsuarioAsociado__c != null){
        //                 userIdsTask.add(usuarioAsociado.AV_UsuarioAsociado__c);
        //             }
        //         }

        //         Messaging.CustomNotification notification = new Messaging.CustomNotification();
        //         Datetime myDT = System.today();
        //         String today = myDT.format('dd-MM-yyyy');


        //         notification.setTitle(Label.CIBE_ConfidentialTask);
        //         notification.setBody( Label.CIBE_ActivityTaskMessageConfidential + ' ' + tsk.get(0).Subject + ' ' +  Label.CIBE_ActivityMessageConfidential2 + ' ' + today + ' ' +  Label.CIBE_ActivityMessageConfidential3);

        //         notification.setNotificationTypeId(notificationTypes.get(0).Id);
        //         notification.setTargetId(tsk.get(0).Id);

        //         if(!attendes.isEmpty() && userIdsTask != null) {
        //             notification.send(userIdsTask);
        //         }
        //     }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isOwner(String recordId){

        if(Event.SObjectType.getDescribe().isAccessible()){
            String ownerId = [SELECT OwnerId FROM Event WHERE Id = :recordId].OwnerId;
            return OwnerId != UserInfo.getUserId();
        }

        return true;   
    }

    @AuraEnabled(cacheable=true)
    public static List<Event> getFields(String recordId) {
        List<Event> ev;
        if(String.isNotBlank(recordId) && Event.SObjectType.getDescribe().isAccessible()) {
            if(recordId.startsWith('00U')) {
                ev = [SELECT Id, CIBE_Confidential__c, AV_Task__r.CIBE_ConfidentialEventAccess__c FROM Event WHERE Id = :recordId];
        }
        }

        return ev;
    }

    public class Activity {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public Boolean confidential {get;set;}
        @AuraEnabled public String rtDeveloperName {get;set;}

    }

}