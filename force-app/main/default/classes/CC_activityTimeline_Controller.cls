public with sharing class CC_activityTimeline_Controller {

	@AuraEnabled(cacheable=true)
	public static List<CC_activityTimeline_Model> getActivityTimeline(String recordId, String tipo, String origen) {

		List<CC_activityTimeline_Model> retorno = new List<CC_activityTimeline_Model>();

		Id registroId = Id.valueOf(recordId);
		Map<Id, Case> casos;
		if (origen == 'Contact') {
			casos = new Map<Id, Case>([SELECT CaseNumber FROM Case WHERE ContactId = :registroId]);
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
			addTasks(retorno, registroId, casos);
		}
		retorno.sort();
		return retorno;
	}

	private static void addTasks(List<CC_activityTimeline_Model> retorno, Id registroId, Map<Id, Case> casos) {
		for (Task t : [SELECT TaskSubtype, Owner.Name, Status, Who.Name, Subject, Description, CreatedDate, WhatId
						FROM Task WHERE (WhoId = :registroId OR WhatId IN :casos.keySet()) AND TaskSubtype != 'Email']) {
			CC_activityTimeline_Model taskItem = new CC_activityTimeline_Model();
			taskItem.RecordId = t.Id;
			taskItem.ActivityTimelineType = t.TaskSubtype;
			taskItem.Subject = t.Subject;
			taskItem.Detail = t.Description;
			taskItem.ActualDate = t.CreatedDate;
			taskItem.ShortDate = t.CreatedDate.format('dd/MM/yyyy HH:mm:ss');
			taskItem.Recipients = t.Who.Name;
			taskItem.Assigned = t.Owner.Name;
			taskItem.CaseNumber = casos.get(t.WhatId).CaseNumber;
			taskItem.CaseId = t.WhatId;
			taskItem.Entrante = true;
			taskItem.Complete = t.Status == 'Complete';
			retorno.add(taskItem);
		}
	}

	private static void addMails(List<CC_activityTimeline_Model> retorno, Map<Id, Case> casos) {
		for (EmailMessage t : [SELECT Status, CreatedBy.Name, Subject, TextBody, CreatedDate, ParentId, Parent.CaseNumber, Incoming, FromAddress, HtmlBody
								FROM EmailMessage WHERE ParentId IN :casos.keySet()]) {
			CC_activityTimeline_Model taskItem = new CC_activityTimeline_Model();
			taskItem.RecordId = t.Id;
			taskItem.ActivityTimelineType = 'Email';
			taskItem.Subject = t.Subject;
			taskItem.Detail = t.HTMLBody != null ? t.HtmlBody : t.TextBody;
			taskItem.ActualDate = t.CreatedDate;
			taskItem.ShortDate = t.CreatedDate.format('dd/MM/yyyy HH:mm:ss');
			taskItem.Recipients = t.FromAddress;
			taskItem.Assigned = t.CreatedBy.Name;
			taskItem.CaseNumber = t.Parent.CaseNumber;
			taskItem.CaseId = t.ParentId;
			taskItem.Entrante = t.Incoming;
			taskItem.Complete = t.Status == 'Complete';
			retorno.add(taskItem);
		}
	}

	private static void addCases(List<CC_activityTimeline_Model> retorno, Id registroId) {
		for (Case t : [SELECT Owner.Name, Subject, Description, CreatedDate, CaseNumber FROM Case WHERE ContactId = :registroId]) {
			CC_activityTimeline_Model taskItem = new CC_activityTimeline_Model();
			taskItem.RecordId = t.Id;
			taskItem.ActivityTimelineType = 'Case'; //t.Origin';
			taskItem.Subject = t.Subject;
			taskItem.Detail = t.Description;
			taskItem.ActualDate = t.CreatedDate;
			taskItem.ShortDate = t.CreatedDate.format('dd/MM/yyyy HH:mm:ss');
			taskItem.Recipients = ''; //t.Who.Name;
			taskItem.Referencia = t.CaseNumber;
			taskItem.Assigned = t.Owner.Name;
			taskItem.CaseNumber = t.CaseNumber;
			taskItem.CaseId = t.Id;
			taskItem.Entrante = true;
			retorno.add(taskItem);
		}
	}

	private static void addChats(List<CC_activityTimeline_Model> retorno, Id registroId) {
		for (LiveChatTranscript t : [SELECT Owner.Name, Contact.Name,CC_Tipo__c, CC_Subject__c, CreatedDate, Case.CaseNumber, CaseId
										FROM LiveChatTranscript WHERE ContactId = :registroId]) {
			CC_activityTimeline_Model taskItem = new CC_activityTimeline_Model();
			taskItem.RecordId = t.Id;
			taskItem.ActivityTimelineType = 'Chat-' + t.CC_Tipo__c;
			taskItem.Subject = t.CC_Subject__c;
			taskItem.Detail = t.CC_Subject__c;
			taskItem.ActualDate = t.CreatedDate;
			taskItem.ShortDate = t.CreatedDate.format('dd/MM/yyyy HH:mm:ss');
			taskItem.Recipients = t.Contact.Name;
			taskItem.Assigned = t.Owner.Name;
			taskItem.Complete = true;
			taskItem.CaseNumber = t.Case.CaseNumber;
			taskItem.CaseId = t.CaseId;
			taskItem.Entrante = true;
			retorno.add(taskItem);
		}
	}

	private static void addPosts(List<CC_activityTimeline_Model> retorno, Map<Id, Case> casos) {
		for (SocialPost t : [SELECT Owner.Name, Handle, Content, CreatedDate, Name, Provider, ParentId, IsOutbound
								FROM SocialPost WHERE ParentId IN :casos.keySet()]) {
			CC_activityTimeline_Model taskItem = new CC_activityTimeline_Model();
			taskItem.RecordId = t.Id;
			taskItem.ActivityTimelineType = t.Provider;
			taskItem.Subject = t.Name;
			taskItem.Detail = t.Content;
			taskItem.ActualDate = t.CreatedDate;
			taskItem.ShortDate = t.CreatedDate.format('dd/MM/yyyy HH:mm:ss');
			taskItem.Recipients = t.Handle;
			taskItem.Assigned = t.Owner.Name;
			taskItem.Complete = true;
			taskItem.CaseNumber = casos.get(t.ParentId).CaseNumber;
			taskItem.CaseId = t.ParentId;
			taskItem.Entrante = !t.IsOutbound;
			retorno.add(taskItem);
		}
	}
}