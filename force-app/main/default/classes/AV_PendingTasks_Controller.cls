/**********************************************************************************************************************
 Name:	  AV_PendingTasks_Controller
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: av_PendingTasks controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US206851			Sandra Gómez		24/05/2021			Init version
	1.1			US200724			Víctor Santiago		19/08/2021			Added task-event filter to getAvisosTasks
	1.2 		av_Query_FIX		Luis Fernández 		12/07/2022			Changed every AV_Query to SOQL
	1.3			Fix PMD Errors      Daniel Rodriguez    05/10/2023			Add WITH SECURITY_ENFORCED in queries 

	
***********************************************************************************************************************/
public with sharing class AV_PendingTasks_Controller {
    /**
	 * Retrieve the task of client info related with RT Avisos
	 * @param recordId	-> Id of the task
	 * @return
	 */
	@AuraEnabled
	public static List<TaskAvisos> getAvisosTasks(String recordId) {
		String accId;
		List<TaskAvisos> listTaskAvisos=new List<TaskAvisos>();
		Task taskAccount = [SELECT AccountId FROM Task WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
		if (taskAccount == null) {
			Event eventAccount = [SELECT AccountId FROM Event WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
			accId = eventAccount.AccountId;
		} else {
			accId = taskAccount.AccountId;
		}
		if(accId != null){
            List<Task> listTask = [SELECT Id,Subject,AV_Origen__C,ActivityDate FROM Task WHERE RecordType.DeveloperName = 'AV_MorosidadNormativa'
                        AND AccountId = :accId AND ActivityDate != NULL AND (Status = 'Open' OR Status = 'Pendiente no localizado') WITH SECURITY_ENFORCED ORDER BY ActivityDate ASC];
                if (!listTask.isEmpty()) {
                    for (Task ta: listTask) {
                        String fecha=ta.ActivityDate.format();
                        Date dateToday = Date.today();
                        Date fechave=ta.ActivityDate.addDays(7);
                        if (!(fechave<dateToday)) {
                            listTaskAvisos.add(new TaskAvisos(ta.Id,ta.Subject,ta.AV_Origen__c,fecha));
                        }
                    }
                    return listTaskAvisos;
                }
		}
		return null;
	}

	public class TaskAvisos {
		@AuraEnabled
		public String idRecord;
		@AuraEnabled
		public String subject;
		@AuraEnabled
		public String origenAv;
		@AuraEnabled
		public String activityDate;
		// Constructor
		public TaskAvisos(String id, String asunto, String origen, String fecha) {
			idRecord = id;
			subject = asunto;
			origenAv = origen;
			activityDate = fecha;
		}
	}

	/**
	 * Update the task of client related with RT Avisos
	 * @param jsonString	-> jsonString of list task
	 * @return
	 */
	@AuraEnabled
	public static String updateTasksAviso(String jsonString) {
		date fecha= Date.today();
		Map<String,TaskAviso> mapTaskPending= new Map<String,TaskAviso>();
		List<String> listId= new List<String>();
		List<AV_ManagementHistory__c> listHistory=new List<AV_ManagementHistory__c>();
		List<TaskAviso> listTaskPending = (List<TaskAviso>)Json.deserialize(jsonString,List<TaskAviso>.class);
		for(TaskAviso ta: listTaskPending) {
			mapTaskPending.put(ta.id,ta);
			listId.add(ta.id);
		}
		List<Task> listTarea = [SELECT Id,Status,Description FROM Task WHERE Id IN :listId WITH SECURITY_ENFORCED];
		if (!listTarea.isEmpty()) {
			for (Task tarea: listTarea) {
				tarea.Status=mapTaskPending.get(tarea.Id).estado;
				if (String.isNotBlank(mapTaskPending.get(tarea.Id).comentario)) {
					tarea.Description = String.isNotBlank(tarea.Description) ? tarea.Description  + '\n' + fecha.format() + ' - ' + mapTaskPending.get(tarea.Id).comentario : fecha.format() + ' - ' + mapTaskPending.get(tarea.Id).comentario;
					listHistory.add(new AV_ManagementHistory__c(
						AV_ActivityId__c= tarea.Id,
						AV_Date__c= fecha,
						AV_Comment__c= mapTaskPending.get(tarea.Id).comentario,
						AV_Status__c= mapTaskPending.get(tarea.Id).estado
					));
				} else {
					listHistory.add(new AV_ManagementHistory__c(
						AV_ActivityId__c= tarea.Id,
						AV_Date__c= fecha,
						AV_Status__c= mapTaskPending.get(tarea.Id).estado
					));
				}
			}
			List<Database.SaveResult> sr = Database.update(listTarea, false);
			if(!sr[0].isSuccess()) {	    
				for(Database.Error err : sr[0].getErrors()) {
					AV_LogDebug.printLogDebug('updateTask', 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
					return err.getMessage();
				}
			} else {
				List<Database.SaveResult> sr2 = Database.insert(listHistory, false);
				if(!sr2[0].isSuccess()) {	    
					for(Database.Error err : sr2[0].getErrors()) {
						AV_LogDebug.printLogDebug('updateTask', 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
						return err.getMessage();
					}
				}else {
					return 'OK';
				}
				return 'KO';
			}
		}
		return 'KO';
	}

	public class TaskAviso{
		@AuraEnabled
		public String id;
		@AuraEnabled
		public String comentario;
		@AuraEnabled
		public String estado;
	}
}