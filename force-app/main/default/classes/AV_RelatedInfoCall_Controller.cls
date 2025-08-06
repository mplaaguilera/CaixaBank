/**********************************************************************************************************************
Name:	  AV_RelatedInfoCall_Controller
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC av_relatedInfoCall
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR			    DATE			Description
    1.0			Test Class		Ali / Bea		    19/06/2024		Init version
***********************************************************************************************************************/
public with sharing class AV_RelatedInfoCall_Controller {

    @AuraEnabled(cacheable=true)
    public static List<Wrapper> getFields(Id recordId) {

		// Consulta de actividades relacionadas (tareas y eventos)
		List<Task> relatedTasks = [ SELECT Id, Subject, Status, WhatId, WhoId, CC_Llamada_Id__c, Description
									FROM Task
									WHERE CC_Llamada_Id__c = :recordId
		];
		
		List<Event> relatedEvents = [ SELECT Id, Subject, StartDateTime, EndDateTime, WhatId, WhoId, CC_Llamada_Id__c, Description
									FROM Event
									WHERE CC_Llamada_Id__c = :recordId ORDER BY CreatedDate DESC LIMIT 1
		];

		List<Wrapper> result = new List<Wrapper>();
		if(!relatedTasks.isEmpty() && relatedTasks != null){
			for (Task task : relatedTasks) {
				Wrapper wrap = new Wrapper();
					wrap.id = task.Id;
					wrap.name = 'Tarea';
					wrap.subject = task.Subject;
					wrap.comentario = task.Description;
					result.add(wrap);	
			}
		}
		if(!relatedEvents.isEmpty() && relatedEvents != null){
			for (Event evt : relatedEvents) {
				Wrapper wrap = new Wrapper();
					wrap.id = evt.Id;
					wrap.name = 'Evento';
					wrap.subject = evt.Subject;
					wrap.comentario = evt.Description;
					result.add(wrap);
			}
		}
		return result;
	}

	@AuraEnabled(cacheable=true)
	public static String getActivityUrl(String activityId, String name) {
        PageReference activityPage = new PageReference('/lightning/r/' + name +'/' + activityId + '/view');
        return activityPage.getUrl();
    }
	
	public class Wrapper {
		@AuraEnabled 
		public String id;
		@AuraEnabled 
		public String name;
		@AuraEnabled 
		public String subject;
		@AuraEnabled 
		public String comentario;
	}

}