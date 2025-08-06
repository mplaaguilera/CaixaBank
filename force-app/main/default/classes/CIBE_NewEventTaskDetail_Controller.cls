/**********************************************************************************************************************
Name:      CIBE_NewEventController
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora para el componente CIBE_NewEvent, cibe_NewEventReportDetail, cibe_newEventTab
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION         USER_STORY       AUTHOR                  DATE                Description
    1.0             US774293        Bea, Ali                16/01/2024           Init version 
***********************************************************************************************************************/

public without sharing class  CIBE_NewEventTaskDetail_Controller {

    private static List<String> taskRt = new List<String> {CIBE_AppConstants.TASK_ALERTACOMERCIAL_EMP_RT, CIBE_AppConstants.TASK_ONBOARDING_EMP_RT, CIBE_AppConstants.TASK_PRIORIZADOS_EMP_RT, 
                                                            CIBE_AppConstants.TASK_OTROS_EMP_RT,CIBE_AppConstants.TASK_AVISOS_EMP_RT, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_EMP_RT };

    private static List<String> taskStatus = new List<String> {CIBE_AppConstants.TASK_STATUS_PENDIENTE, CIBE_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL};

    @AuraEnabled
    // public static List<TaskWrapper> getAccountTask(String accountId){
    public static List<TaskWrapper> getAccountTask(List<String> lstAccounts){
        List<TaskWrapper> response = new List<TaskWrapper>();
        String currentUserId = UserInfo.getUserId();
        
        List<Task> taskList = [SELECT Id, RecordTypeId, WhatId, Subject, ActivityDate, TOLABEL(Status), OwnerId, LastModifiedDate, Description, 
                                            AV_Task__c, AV_Tipo__c,AV_ToDelete__c, AV_Origen__c, AV_OrigenApp__c, AV_OrigenAct__c, Account.Name
                                    FROM Task 
                                    WHERE WhatId IN: lstAccounts 
                                    AND RecordType.DeveloperName IN :taskRt 
                                    AND Status IN :taskStatus 
                                    AND AV_ToDelete__c = FALSE
                                    ORDER BY ActivityDate ASC];
            
        Set<String> taskIds = new Set<String>();
        for(Task task: taskList){
            taskIds.add(task.Id);
        }
        
        TaskWrapper wrap;
    
        for(Task task: taskList){
            if(task.OwnerId == currentUserId ){
                wrap = parseWrapper(task, true, null);
            }else{
                wrap = parseWrapper(task, false, null);
            }
            response.add(wrap);
        }
        return response;
    }

    /*
    Description: Clase que devuelve un wrapper de tareas ordenado por cliente del Grupo comercial.
    */
    @AuraEnabled
    public static List<TaskAccWrapper> getAccountTaskGC(List<TaskWrapper> listAccountTask){
        List<TaskAccWrapper> response = new List<TaskAccWrapper> ();
        Map<String,List<TaskWrapper>> mapTaskWr = new Map<String,List<TaskWrapper>> ();

        for(TaskWrapper tsk: listAccountTask){
            if(tsk.nomCliente!=null){
                if(!mapTaskWr.containsKey(tsk.nomCliente)){
                    mapTaskWr.put(tsk.nomCliente, new List<TaskWrapper>());
                }
                mapTaskWr.get(tsk.nomCliente).add(tsk);
            }
        }

        for(String tsk: mapTaskWr.KeySet()){
            TaskAccWrapper wrapAccTask = new TaskAccWrapper();
                // wrapAccTask.cliente = tsk+' ('+mapTaskWr.get(tsk).size()+')';
                wrapAccTask.cliente = tsk;
                wrapAccTask.twList = mapTaskWr.get(tsk);
                response.add(wrapAccTask);
        }

        return response;

    }

    @AuraEnabled
    public static List<AggregateResult> geCountRelated(String eventId){
        Event evt = [SELECT AV_Task__c, AccountId FROM Event WHERE Id = :eventId LIMIT 1];

        List<AggregateResult> relatedCount = [SELECT COUNT(Id) total FROM CIBE_RelaccionadoCita__c
                                                WHERE CIBE_CitaRelaccionada__c = : evt.AV_Task__c];
        
        return relatedCount;
    }


    @AuraEnabled
    public static List<TaskWrapper> geTaskFromEvent(String eventId){
        List<TaskWrapper> response = new List<TaskWrapper>();
        
        Event evt = [SELECT AV_Task__c, AccountId FROM Event WHERE Id = :eventId LIMIT 1];

        List<CIBE_RelaccionadoCita__c> relCitaList = [SELECT Id, CIBE_CitaRelaccionada__c, CIBE_TareaRelaccionada__c, CIBE_IsMain__c 
                                                            FROM CIBE_RelaccionadoCita__c 
                                                            WHERE CIBE_CitaRelaccionada__c = : evt.AV_Task__c ORDER BY CIBE_IsMain__c desc];

        Map<String, CIBE_RelaccionadoCita__c> vinculedTaskMap = new Map<String, CIBE_RelaccionadoCita__c>();
        for(CIBE_RelaccionadoCita__c relCita: relCitaList){
            vinculedTaskMap.put(relCita.CIBE_TareaRelaccionada__c, relCita);
        }
        
        String currentUserId = UserInfo.getUserId();
        List<Task> taskListRelated = [SELECT Id, RecordTypeId, WhatId, Subject, ActivityDate, TOLABEL(Status), OwnerId, LastModifiedDate, Description, 
                                            AV_Task__c, AV_Tipo__c,AV_ToDelete__c, AV_Origen__c, AV_OrigenApp__c, AV_OrigenAct__c,Account.Name
                                    FROM Task 
                                    WHERE RecordType.DeveloperName IN :taskRt
                                    AND AV_Task__c in :vinculedTaskMap.KeySet()
                                    ORDER BY ActivityDate ASC];

        List<Task> taskListNotRelated = [SELECT Id, RecordTypeId, WhatId, Subject, ActivityDate, TOLABEL(Status), OwnerId, LastModifiedDate, Description, 
                                            AV_Task__c, AV_Tipo__c,AV_ToDelete__c, AV_Origen__c, AV_OrigenApp__c, AV_OrigenAct__c,Account.Name
                                    FROM Task 
                                    WHERE WhatId = :evt.accountId 
                                    AND RecordType.DeveloperName IN :taskRt 
                                    AND Status IN :taskStatus 
                                    AND AV_ToDelete__c = FALSE
                                    AND AV_Task__c not in :vinculedTaskMap.KeySet()
                                    ORDER BY ActivityDate ASC];        
        
        TaskWrapper wrap;

            for(Task relatedTsk: taskListRelated){
                if(relatedTsk.OwnerId == currentUserId){
                    wrap = parseWrapper(relatedTsk, true, vinculedTaskMap.get(relatedTsk.AV_Task__c));
                }else{
                    wrap = parseWrapper(relatedTsk, true,  vinculedTaskMap.get(relatedTsk.AV_Task__c));
                }
                
                response.add(wrap);

            }
        
            for(Task unRelatedTsk: taskListNotRelated){
                if(unRelatedTsk.OwnerId == currentUserId){
                    wrap = parseWrapper(unRelatedTsk, true, null);
                }else{
                    wrap = parseWrapper(unRelatedTsk, false, null);
                }
                
                response.add(wrap);
            }

            response.sort(); 

        return response;
    }

    
    @AuraEnabled
    public static List<TaskAccWrapper> getAccountTaskGCFromEvent(String eventId, List<String> lstAccounts){
        List<TaskAccWrapper> responseTAW = new List<TaskAccWrapper> ();
        List<TaskWrapper> response = new List<TaskWrapper> ();
        List<Task> taskListRelated = new List<Task> ();
        Event evt = [SELECT AV_Task__c, AccountId FROM Event WHERE Id = :eventId LIMIT 1];

        List<CIBE_RelaccionadoCita__c> relCitaList = [SELECT Id, CIBE_CitaRelaccionada__c, CIBE_TareaRelaccionada__c, CIBE_IsMain__c 
                                                            FROM CIBE_RelaccionadoCita__c 
                                                            WHERE CIBE_CitaRelaccionada__c = : evt.AV_Task__c ORDER BY CIBE_IsMain__c desc];

        Map<String, CIBE_RelaccionadoCita__c> vinculedTaskMap = new Map<String, CIBE_RelaccionadoCita__c>();
        for(CIBE_RelaccionadoCita__c relCita: relCitaList){
            if(relCita.CIBE_TareaRelaccionada__c!=null){
                vinculedTaskMap.put(relCita.CIBE_TareaRelaccionada__c, relCita);
            }
        }

        String currentUserId = UserInfo.getUserId();
        if(vinculedTaskMap!=null && !vinculedTaskMap.isEmpty()){
            taskListRelated = [SELECT Id, RecordTypeId, WhatId, Subject, ActivityDate, TOLABEL(Status), OwnerId, LastModifiedDate, Description, 
                                AV_Task__c, AV_Tipo__c,AV_ToDelete__c, AV_Origen__c, AV_OrigenApp__c, AV_OrigenAct__c, Account.Name
                                FROM Task 
                                WHERE RecordType.DeveloperName IN :taskRt
                                AND AV_Task__c in :vinculedTaskMap.KeySet()
                                AND AV_ToDelete__c = FALSE
                                ORDER BY ActivityDate ASC];
        }

        List<Task> taskListNotRelated = [SELECT Id, RecordTypeId, WhatId, Subject, ActivityDate, TOLABEL(Status), OwnerId, LastModifiedDate, Description, 
                                            AV_Task__c, AV_Tipo__c,AV_ToDelete__c, AV_Origen__c, AV_OrigenApp__c, AV_OrigenAct__c,Account.Name
                                        FROM Task 
                                        WHERE WhatId IN :lstAccounts 
                                        AND RecordType.DeveloperName IN :taskRt 
                                        AND Status IN :taskStatus 
                                        AND AV_ToDelete__c = FALSE
                                        AND AV_Task__c not in :vinculedTaskMap.KeySet()
                                        ORDER BY ActivityDate ASC];        
        
        TaskWrapper wrap;
            for(Task relatedTsk: taskListRelated){
                if(relatedTsk.OwnerId == currentUserId){
                    wrap = parseWrapper(relatedTsk, true, vinculedTaskMap.get(relatedTsk.AV_Task__c));
                }else{
                    wrap = parseWrapper(relatedTsk, true,  vinculedTaskMap.get(relatedTsk.AV_Task__c));
                }
                
                response.add(wrap);
            }
        
            for(Task unRelatedTsk: taskListNotRelated){
                if(unRelatedTsk.OwnerId == currentUserId){
                    wrap = parseWrapper(unRelatedTsk, true, null);
                }else{
                    wrap = parseWrapper(unRelatedTsk, false, null);
                }
                
                response.add(wrap);
            }

            response.sort(); 
            responseTAW = getAccountTaskGC(response);
        return responseTAW;
    }

    @AuraEnabled
    public static void vinculateTask (String recordId, String taskId){
        List<Event> evt = [SELECT AV_Task__c, AccountId FROM Event WHERE Id = :recordId LIMIT 1];
        if (evt != null && !evt.isEmpty()) {
            Task tsk = [SELECT AV_Task__c, AccountId FROM Task WHERE Id = :taskId LIMIT 1];
            List<CIBE_RelaccionadoCita__c> relCitaList = [Select id, CIBE_CitaRelaccionada__c, CIBE_TareaRelaccionada__c, CIBE_IsMain__c 
                                                                        FROM CIBE_RelaccionadoCita__c 
                                                                        WHERE CIBE_CitaRelaccionada__c = : evt[0].AV_Task__c];
            CIBE_RelaccionadoCita__c relCitaToInsert = new CIBE_RelaccionadoCita__c();                                                           
            if(relCitaList.isEmpty()){
                relCitaToInsert = new CIBE_RelaccionadoCita__c(CIBE_CitaRelaccionada__c = evt[0].AV_Task__c, CIBE_TareaRelaccionada__c = tsk.AV_Task__c, CIBE_IsMain__c = true);
            }else{
                relCitaToInsert = new CIBE_RelaccionadoCita__c(CIBE_CitaRelaccionada__c = evt[0].AV_Task__c, CIBE_TareaRelaccionada__c = tsk.AV_Task__c);
            }
            insert relCitaToInsert; 
        }
    }

    @AuraEnabled
    public static void disVinculateTask (String recordId, String taskId){
        List<Event> evt = [SELECT AV_Task__c, AccountId FROM Event WHERE Id = :recordId LIMIT 1];
        if (evt != null && !evt.isEmpty()) {
            Task tsk = [SELECT AV_Task__c, AccountId FROM Task WHERE Id = :taskId LIMIT 1];
            List<CIBE_RelaccionadoCita__c> relCitaList = [Select id, CIBE_CitaRelaccionada__c, CIBE_TareaRelaccionada__c, CIBE_IsMain__c 
                                                                        FROM CIBE_RelaccionadoCita__c 
                                                                        WHERE CIBE_CitaRelaccionada__c = :evt[0].AV_Task__c ORDER BY CIBE_IsMain__c DESC];
            CIBE_RelaccionadoCita__c relCitaToDelete ;
            CIBE_RelaccionadoCita__c relCitaToUpdateMain ;
            Boolean isMain = false;
            for(CIBE_RelaccionadoCita__c relCita: relCitaList){
                if(relCita.CIBE_TareaRelaccionada__c == tsk.AV_Task__c && relCita.CIBE_IsMain__c){
                    relCitaToDelete     = new CIBE_RelaccionadoCita__c(Id = relCita.Id);
                    isMain  = true;
                }else if(relCita.CIBE_TareaRelaccionada__c == tsk.AV_Task__c && relCita.CIBE_IsMain__c == false){
                    relCitaToDelete     = new CIBE_RelaccionadoCita__c(Id = relCita.Id);
                }else if(isMain){
                    relCitaToUpdateMain = new CIBE_RelaccionadoCita__c(Id = relCita.Id, CIBE_IsMain__c = true);
                    break;
                }
            }
            if(relCitaToDelete != null){
                Database.delete(relCitaToDelete,true);
            }
            if(relCitaToUpdateMain != null){
                Database.update(relCitaToUpdateMain,true);
            }  
        }  
    }

    @AuraEnabled
    public static void makePrincipal(String recordId, String taskId){
        Event evt = [SELECT AV_Task__c, AccountId FROM Event WHERE Id = :recordId LIMIT 1];
        Task tsk = [SELECT AV_Task__c, AccountId FROM Task WHERE Id = :taskId LIMIT 1];

        List<CIBE_RelaccionadoCita__c> vinculedTasks = [Select id, CIBE_CitaRelaccionada__c, CIBE_TareaRelaccionada__c, CIBE_IsMain__c  
                                                                    FROM CIBE_RelaccionadoCita__c 
                                                                    WHERE CIBE_CitaRelaccionada__c = : evt.AV_Task__c ORDER BY  CIBE_IsMain__c DESC];

        List<CIBE_RelaccionadoCita__c> relCitaToUpdateList = new List<CIBE_RelaccionadoCita__c>();
        for(CIBE_RelaccionadoCita__c relCita: vinculedTasks){
            if(relCita.CIBE_TareaRelaccionada__c == tsk.AV_Task__c && relCita.CIBE_IsMain__c  == false){
                relCitaToUpdateList.add(new CIBE_RelaccionadoCita__c(Id = relCita.Id, CIBE_IsMain__c = true));
            }else if(relCita.CIBE_IsMain__c == true){
                relCitaToUpdateList.add(new CIBE_RelaccionadoCita__c(Id = relCita.Id, CIBE_IsMain__c = false));
            }
        }

		if(!relCitaToUpdateList.isEmpty()){
            update relCitaToUpdateList;
        }
    }

    @AuraEnabled
    public static void updateChecked (String recordId){
        Task tskToUpdate = new Task(Id = recordId, Status = 'Gestionada positiva');

		update tskToUpdate;    
    }


    @AuraEnabled
    public static void updateCanceled (String recordId){
        Task tskToUpdate = new Task(Id = recordId, Status = 'Gestionada negativa');

		update tskToUpdate;    
    }

    @AuraEnabled
    public static void updateComment (String recordId, String comentarioToSend){
        Task tskToUpdate = new Task(Id = recordId, Description = comentarioToSend);

		update tskToUpdate;    
    }    
    public static TaskWrapper parseWrapper (Task task, Boolean isEditable, CIBE_RelaccionadoCita__c relCita){
        TaskWrapper wrap = new TaskWrapper();
        wrap.id  						= task.Id;
        wrap.rt 						= task.RecordTypeId;
        wrap.accountId  				= task.WhatId;
        wrap.subject 				    = task.Subject;
        wrap.activityDate			    = task.ActivityDate;
        wrap.status 					= task.Status;
        wrap.owner 				        = task.OwnerId;
        wrap.comments                   = task.Description;
        wrap.commentsLastModifieddate 	= task.LastModifiedDate;
        wrap.isVinculated               = relCita != null ? true : false;
        wrap.isPrincipal                = relCita != null ? relCita.CIBE_IsMain__c : false;
        wrap.isEditable                 = isEditable;
        wrap.headerId                   = task.AV_Task__c;
        wrap.checked                    = false;
        wrap.closedLost                 = false;
        wrap.relaccionadoCitaId         = relCita != null ? relCita.Id : null;
        wrap.nomCliente  				= task.Account.name;

        if(task.Status == 'Gestionada positiva'){
            wrap.checked                    = true;
        }else if(task.Status == 'Gestionada negativa'){
            wrap.closedLost                 = true;
        }


        return wrap;
    }
    
    public class TaskWrapper implements Comparable{
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String rt {get;set;}
        @AuraEnabled public String accountId {get;set;}
        @AuraEnabled public String subject {get;set;}
        @AuraEnabled public Date activityDate {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String owner {get;set;}
        @AuraEnabled public String comments {get;set;}
        @AuraEnabled public DateTime commentsLastModifieddate {get;set;}
        @AuraEnabled public Boolean isVinculated {get;set;}
        @AuraEnabled public Boolean isPrincipal {get;set;}
        @AuraEnabled public Boolean isEditable {get;set;}

        @AuraEnabled public Boolean checked {get;set;}
        @AuraEnabled public Boolean closedLost {get;set;}
        @AuraEnabled public String relaccionadoCitaId {get;set;}
        @AuraEnabled public String nomCliente {get;set;}


        @AuraEnabled public String headerId {get;set;}

        public Integer compareTo(Object compareTo) {
                
            TaskWrapper compareToWrap = (TaskWrapper)compareTo;
            
            Integer returnValue = 0;
            if (compareToWrap.isPrincipal) {
                returnValue = 1;
            } else{
                returnValue = -1;
            }       
            return returnValue;       
        }

    }

    public class TaskAccWrapper {
        @AuraEnabled public String cliente {get;set;}
        @AuraEnabled public List<TaskWrapper> twList {get;set;}
    }

    @AuraEnabled
    public static String insertTask(List<Task> record, String recordId){

        String response = 'OK';
        Id iniciativaRt = AV_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK ,CIBE_AppConstants.TASK_OTROS_EMP_RT).Id;
        List<Task> tasksToInsert = new List<Task>();
        CIBE_RelaccionadoCita__c relCitaToInsert = new CIBE_RelaccionadoCita__c();

        if(!record.isEmpty()){
            for(Task rec: record){
                Task tarea = new Task ();
                tarea.Subject = rec.subject!=null?rec.subject:record[0].subject; 
                tarea.ActivityDate = rec.activityDate !=null ? rec.activityDate : record[0].activityDate; 
                tarea.Status = rec.status != null ? rec.status : record[0].status; 
                tarea.WhatId = rec.WhatId;
                tarea.recordTypeId = iniciativaRt;
                tarea.OwnerId = UserInfo.getUserId();

                tasksToInsert.add(tarea);				
            }
        }

        List<Database.SaveResult> srList = Database.insert(tasksToInsert, false);
        boolean hasError = false;
        List<Object> objs = new List<Object>();
        Map<String, String> msjs = new Map<String, String>();
        for (Integer i = 0; i < tasksToInsert.size(); i++) {
            Database.SaveResult sr = srList[i];
            if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                msjs.put(tasksToInsert[i].Id + '_' + tasksToInsert[i].Subject, ((String)sr.getErrors()[0].getMessage()));
                objs.add(tasksToInsert[i]);
                hasError = true;
                response = 'NOK';
            }
        }
        if(hasError) {
            CBK_Log.error(msjs, objs);
        }

        if(response == 'OK'){
            Task tsk = [SELECT Id, AV_Task__c FROM Task WHERE Id = :tasksToInsert[0].Id];

            if(recordId != null && tsk != null){
                Event evento = [SELECT Id, AV_Task__c FROM Event WHERE Id = :recordId];
                if(evento != null){
                    List<CIBE_RelaccionadoCita__c> relCitaList = [Select id, CIBE_CitaRelaccionada__c, CIBE_TareaRelaccionada__c, CIBE_IsMain__c 
                    FROM CIBE_RelaccionadoCita__c 
                    WHERE CIBE_CitaRelaccionada__c = : evento.AV_Task__c];
                    if(relCitaList.isEmpty()){
                        relCitaToInsert = new CIBE_RelaccionadoCita__c(CIBE_CitaRelaccionada__c = evento.AV_Task__c, CIBE_TareaRelaccionada__c = tsk.AV_Task__c, CIBE_IsMain__c = true);
                    }else{
                        relCitaToInsert = new CIBE_RelaccionadoCita__c(CIBE_CitaRelaccionada__c = evento.AV_Task__c, CIBE_TareaRelaccionada__c = tsk.AV_Task__c);
                    }
                }
            }

            if(relCitaToInsert != null){
                Database.SaveResult srList2 = Database.insert(relCitaToInsert, false);

                boolean hasError2 = false;
                List<Object> objs2 = new List<Object>();
                Map<String, String> msjs2 = new Map<String, String>();
                Database.SaveResult sr2 = srList2;
                if(!sr2.isSuccess() && !sr2.getErrors().isEmpty()) {
                    msjs2.put(relCitaToInsert.Id + '_' + relCitaToInsert.CIBE_CitaRelaccionada__c, ((String)sr2.getErrors()[0].getMessage()));
                    objs2.add(relCitaToInsert);
                    hasError2 = true;
                    response = 'NOK';
                }
                if(hasError2) {
                    CBK_Log.error(msjs2, objs2);
                }
            }    
        }
        return response;
            
    }



    @AuraEnabled(cacheable = true)
    public static List<Event> getEvent(String recordId){
        List<Event> evento = new List<Event>();
        if(recordId != null ){
            evento = [SELECT Id, AV_Task__c, ActivityDate, AccountId FROM Event WHERE Id = :recordId];
        }

        return evento;
    }

}