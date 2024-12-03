public with sharing class CC_activityTimeline_Controller {

	@AuraEnabled
	public static List<CC_activityTimeline_Model> getActivityTimeline(String recordId, String tipo, String origen) {

		List<CC_activityTimeline_Model> retorno = new List<CC_activityTimeline_Model>();

		Id registroId = Id.valueOf(recordId);
		Map<Id, Case> casos;
		if (origen == 'Contact') {
			casos = new Map<Id, Case>([SELECT CaseNumber FROM Case WHERE ContactId = :registroId]);
		} else if (origen == 'Account') {
			casos = new Map<Id, Case>([SELECT CaseNumber FROM Case WHERE AccountId = :registroId]);
		} else if (origen == 'Case') {
			casos = new Map<Id, Case>([SELECT CaseNumber FROM Case WHERE Id = :registroId]);
		}

		if (tipo == 'All') {
			addMails(retorno, casos);
			addCases(retorno, registroId);
			addChats(retorno, registroId);
			addPosts(retorno, casos);
			//addTasks(retorno, registroId, casos);
		} else if (tipo == 'Social') {
			addPosts(retorno, casos);
		} else if (tipo == 'Task') {
			addTasks(retorno, registroId, casos, origen);
		}
		retorno.sort();
		return retorno;
	}

	private static void addTasks(List<CC_activityTimeline_Model> retorno, Id registroId, Map<Id, Case> casos, String origen) {
		Map<Id, Task> tareas;
		if (origen == 'Contact') {
			tareas = new Map<Id, Task>([SELECT TaskSubtype, CreatedById, CreatedBy.Name, Status, Who.Name, Subject, Description, CreatedDate, WhatId
										FROM Task WHERE TaskSubtype != 'Email' AND (WhatId IN :casos.keySet() OR WhoId = :registroId) LIMIT 30]);
		} else if (origen == 'Account') {
			tareas = new Map<Id, Task>([SELECT TaskSubtype, CreatedById, CreatedBy.Name, Status, Who.Name, Subject, Description, CreatedDate, WhatId
										FROM Task WHERE TaskSubtype != 'Email' AND WhatId IN :casos.keySet() LIMIT 30]);
			tareas.putAll(new Map<Id, Task>([SELECT TaskSubtype, CreatedById, CreatedBy.Name, Status, Who.Name, Subject, Description, CreatedDate, WhatId
												FROM Task WHERE TaskSubtype != 'Email' AND WhoId IN (SELECT Id FROM Contact WHERE AccountId = :registroId)
												AND Id NOT IN :tareas.keySet() LIMIT 30]));
		} else if (origen == 'Case') {
			tareas = new Map<Id, Task>([SELECT TaskSubtype, CreatedById, CreatedBy.Name, Status, Who.Name, Subject, Description, CreatedDate, WhatId
										FROM Task WHERE TaskSubtype != 'Email' AND WhatId = :registroId LIMIT 30]);
		}
		for (Task tarea : tareas.values()) {
			CC_activityTimeline_Model taskItem = new CC_activityTimeline_Model();
			taskItem.RecordId = tarea.Id;
			taskItem.ActivityTimelineType = tarea.TaskSubtype;
			taskItem.Subject = tarea.Subject;
			taskItem.Detail = tarea.Description;
			taskItem.ActualDate = tarea.CreatedDate;
			taskItem.ShortDate = tarea.CreatedDate.format('dd/MM/yyyy HH:mm');
			taskItem.Recipients = tarea.Who.Name;
			taskItem.AssignedId = tarea.CreatedById;
			taskItem.Assigned = tarea.CreatedBy.Name;
			taskItem.CaseNumber = casos.get(tarea.WhatId).CaseNumber;
			taskItem.CaseId = tarea.WhatId;
			taskItem.Entrante = true;
			taskItem.Complete = tarea.Status == 'Complete';
			retorno.add(taskItem);
		}
	}

	private static void addMails(List<CC_activityTimeline_Model> retorno, Map<Id, Case> casos) {
		for (EmailMessage t : [SELECT Status, CreatedById, CreatedBy.Name, Subject, TextBody, CreatedDate, ParentId, Parent.CaseNumber, Incoming, FromAddress, ToAddress, HtmlBody
								FROM EmailMessage WHERE ParentId IN :casos.keySet() LIMIT 30]) {
			CC_activityTimeline_Model taskItem = new CC_activityTimeline_Model();
			taskItem.RecordId = t.Id;
			taskItem.ActivityTimelineType = 'Email';
			taskItem.Subject = t.Subject;
			taskItem.Detail = t.HTMLBody != null ? t.HtmlBody : t.TextBody;
			taskItem.ActualDate = t.CreatedDate;
			taskItem.ShortDate = t.CreatedDate.format('dd/MM/yyyy HH:mm');
			taskItem.senders = t.FromAddress;
			taskItem.Recipients = t.ToAddress;
			taskItem.AssignedId = t.CreatedById;
			taskItem.Assigned = t.CreatedBy.Name;
			taskItem.CaseNumber = t.Parent.CaseNumber;
			taskItem.CaseId = t.ParentId;
			taskItem.Entrante = t.Incoming;
			taskItem.Complete = t.Status == 'Complete';
			retorno.add(taskItem);
		}
	}

	private static void addCases(List<CC_activityTimeline_Model> retorno, Id registroId) {
		for (Case t : [SELECT CreatedById, CreatedBy.Name, Subject, Description, CreatedDate, CaseNumber
						FROM Case WHERE AccountId = :registroId OR ContactId = :registroId LIMIT 30]) {
			CC_activityTimeline_Model taskItem = new CC_activityTimeline_Model();
			taskItem.RecordId = t.Id;
			taskItem.ActivityTimelineType = 'Case'; //t.Origin';
			taskItem.Subject = t.Subject;
			taskItem.Detail = t.Description;
			taskItem.ActualDate = t.CreatedDate;
			taskItem.ShortDate = t.CreatedDate.format('dd/MM/yyyy HH:mm');
			taskItem.Recipients = ''; //t.Who.Name;
			taskItem.Referencia = t.CaseNumber;
			taskItem.AssignedId = t.CreatedById;
			taskItem.Assigned = t.CreatedBy.Name;
			taskItem.CaseNumber = t.CaseNumber;
			taskItem.CaseId = t.Id;
			taskItem.Entrante = false;
			retorno.add(taskItem);
		}
	}

	private static void addChats(List<CC_activityTimeline_Model> retorno, Id registroId) {
		for (LiveChatTranscript t : [SELECT CreatedById, CreatedBy.Name, Contact.Name, CC_Tipo__c, CC_Subject__c, CreatedDate, Case.CaseNumber, CaseId, Body
										FROM LiveChatTranscript WHERE AccountId = :registroId OR ContactId = :registroId LIMIT 30]) {
			CC_activityTimeline_Model taskItem = new CC_activityTimeline_Model();
			taskItem.RecordId = t.Id;
			taskItem.ActivityTimelineType = 'Chat-' + t.CC_Tipo__c;
			taskItem.Subject = t.CC_Subject__c;
			taskItem.Detail = t.Body;
			taskItem.ActualDate = t.CreatedDate;
			taskItem.ShortDate = t.CreatedDate.format('dd/MM/yyyy HH:mm');
			taskItem.Recipients = t.Contact.Name;
			taskItem.AssignedId = t.CreatedById;
			taskItem.Assigned = t.CreatedBy.Name;
			taskItem.Complete = true;
			taskItem.CaseNumber = t.Case.CaseNumber;
			taskItem.CaseId = t.CaseId;
			taskItem.Entrante = true;
			retorno.add(taskItem);
		}
	}

	private static void addPosts(List<CC_activityTimeline_Model> retorno, Map<Id, Case> casos) {
		for (SocialPost t : [SELECT CreatedById, CreatedBy.Name, Handle, Content, CreatedDate, Name, Provider, ParentId, IsOutbound
								FROM SocialPost WHERE ParentId IN :casos.keySet() LIMIT 30]) {
			CC_activityTimeline_Model taskItem = new CC_activityTimeline_Model();
			taskItem.RecordId = t.Id;
			taskItem.ActivityTimelineType = t.Provider;
			taskItem.Subject = t.Name;
			taskItem.Detail = t.Content;
			taskItem.ActualDate = t.CreatedDate;
			taskItem.ShortDate = t.CreatedDate.format('dd/MM/yyyy HH:mm');
			taskItem.Recipients = t.Handle;
			taskItem.AssignedId = t.CreatedById;
			taskItem.Assigned = t.CreatedBy.Name;
			taskItem.Complete = true;
			taskItem.CaseNumber = casos.get(t.ParentId).CaseNumber;
			taskItem.CaseId = t.ParentId;
			taskItem.Entrante = !t.IsOutbound;
			retorno.add(taskItem);
		}
	}
}