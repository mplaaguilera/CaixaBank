/**********************************************************************************************************************
Name:	  AV_TabManagementEvent_Controller
Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC av_CloseEventAndOppTab
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE			Description
	1.0			US200724   			Víctor Santiago	    12/08/2021		Init version
	1.1			FIX Performance   	David Rufo	    	20/10/2021		Fix performance in the method "doPendingTasksExist"
    1.2			Fix PMD Errors	    Daniel Rodriguez	 05/10/2023		Add WITH SECURITY_ENFORCED in queries

***********************************************************************************************************************/
public with sharing class AV_TabManagementEvent_Controller {

    /**
     * @description     Updates the event by closing it and adding the comment.
     * @param id        Id of the event about to be closed
     * @param comment   Comment added when the event was managed
     */
    @AuraEnabled
    public static String updateEvent(String id, String comment) {
        String methodName = 'updateEvent';
        String result = 'OK';
        try {
            Event event = [Select Id, CSBD_Evento_Estado__c, Description from Event where Id = :id  WITH SECURITY_ENFORCED limit 1];
            event.CSBD_Evento_Estado__c = 'Gestionada Positiva'; // Cerrado
            event.Description = comment;
            Database.SaveResult sr = Database.update(event, false);
            if(!sr.isSuccess()) {	    
                for(Database.Error err : sr.getErrors()) {
                    AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
                    result = err.getMessage();
                }
            }
        } catch (Exception e) {
            AV_LogDebug.printException(methodName, e);
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    /**
     * @description     Retrieves the description and type of the event
     * @param id        Id of the event about to be closed
     */
    @AuraEnabled
	public static EventWrapper getEventData(String id) {
        String methodName = 'getEventData';
        EventWrapper evtWrapper = new EventWrapper();
        
        try {
            Event event = [Select Id, Description, AV_Tipo__c from Event where Id = :id WITH SECURITY_ENFORCED limit 1];
            evtWrapper.comment = event.Description;
            evtWrapper.tipo = event.AV_Tipo__c;
        } catch (Exception e) {
            AV_LogDebug.printException(methodName, e);
            if (!Test.isRunningTest()) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        return evtWrapper;
    }

    public class EventWrapper {
        @AuraEnabled
        public String comment {get;set;}

        @AuraEnabled
        public String tipo {get;set;}
    }

    /**
     * @description     Returns whether this client has pending tasks or not
     * @param id        Id of the event about to be closed
     */
    @AuraEnabled
    public static Boolean doPendingTasksExist(String id) {
        String methodName = 'doPendingTasksExist';
        Boolean isPendingTask = false;
        try {
            Event eventAccount = [Select AccountId from Event where Id = :id WITH SECURITY_ENFORCED limit 1];
            if (eventAccount!=null && String.isNotBlank(eventAccount.AccountId)){
                List<Task> listTask = [Select Id, Subject, AV_Origen__c, ActivityDate from Task where RecordType.DeveloperName = 'AV_MorosidadNormativa' and AccountId = :eventAccount.AccountId and (Status = :AV_AppConstants.TASK_STATUS_PENDIENTE or Status = :AV_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL) WITH SECURITY_ENFORCED order by ActivityDate ASC];
                AV_LogDebug.printLogDebug(methodName, 'listTask: ' + listTask);
                if (!listTask.isEmpty()) {
                    isPendingTask = true;
                }
            }
        } catch (Exception e) {
            AV_LogDebug.printException(methodName, e);
            if (!Test.isRunningTest()) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        return isPendingTask;
    }
}