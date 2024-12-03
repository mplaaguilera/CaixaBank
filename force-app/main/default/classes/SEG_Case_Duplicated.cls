public class SEG_Case_Duplicated implements Queueable {
	private Set<Id> casesIds { get; set; }

	public SEG_Case_Duplicated(Set<Id> casesIds) {
		this.casesIds = casesIds;
	}
	public void execute(QueueableContext context) {

		Integer hours = Integer.valueOf(HoursDuplicatedCase__c.getOrgDefaults() ?.Hours__c);
		if (hours == null) {
			hours = 24;
		}

		DateTime dateToSearch = System.now().addHours(hours * (- 1));

		Map<Id, EmailMessage> mapEmailsInserted = new Map<Id, EmailMessage> ([SELECT Id, TextBody, HasAttachment,
		                                                                     CreatedDate, FromAddress, ToAddress, Subject, ParentId, SEG_BotonPulsado__c
		                                                                     FROM EmailMessage WHERE ParentId IN :casesIds]);
		List<String> listadoFrom = new List<String>();
		List<String> listadoTo = new List<String>();
		for(EmailMessage mensaje : mapEmailsInserted.values()){
			listadoFrom.add(mensaje.FromAddress);
			listadoTo.add(mensaje.toAddress);
		}
																			 //TODO: QUITAR HTMLBODY y añadir isincoming == true
		Map<Id, EmailMessage> mapEmailsToAnalyze = new Map<Id, EmailMessage> ([SELECT Id, TextBody, HasAttachment,
		                                                                      CreatedDate, FromAddress, ToAddress, Subject, ParentId
		                                                                      FROM EmailMessage WHERE CreatedDate > :dateToSearch
																			  AND fromAddress IN: listadoFrom AND toAddress IN: listadoTo
		                                                                      AND (Parent.RecordType.DeveloperName = 'SEG_Cliente' 
																			  OR Parent.RecordType.DeveloperName = 'SEG_Seguimiento')
																			  AND ParentId NOT IN: casesIds AND incoming = true ORDER BY CreatedDate DESC]);

		if (mapEmailsInserted.size() > 0 && mapEmailsToAnalyze.size() > 0)
		{
			Set<Id> emailIds = new Set<Id> ();
			emailIds.addAll(mapEmailsInserted.keySet());
			emailIds.addAll(mapEmailsToAnalyze.keySet());

			Map<Id, List<String>> mapObjectIdAttachmentsSize = getAttachmentsSizeFromObjectIds(emailIds);

			Map<Id, Set<Id>> mapCaseDuplicated = new Map<Id, Set<Id>> ();
			List<Id> lstEmailIds;
			Id caseIdDuplicated;
			Id caseId;
			for (EmailMessage email : mapEmailsInserted.values()) {
				caseId = email.ParentId;
				lstEmailIds = lookupForDuplicate(email, mapEmailsToAnalyze.values(), mapObjectIdAttachmentsSize);
				for (Id emailId : lstEmailIds) {
					caseIdDuplicated = mapEmailsToAnalyze.get(emailId).ParentId;
					if (mapCaseDuplicated.containsKey(caseId)) {
						mapCaseDuplicated.get(caseId).add(caseIdDuplicated);
					} else {
						mapCaseDuplicated.put(caseId, new Set<Id> { caseIdDuplicated });
					}
				}
			}

			SEG_Duplicate_Case__c duplicateCase;
			List<SEG_Duplicate_Case__c> lstDuplicateCases = new List<SEG_Duplicate_Case__c> ();
			for (Id idCase : mapCaseDuplicated.keySet()) {
				for (Id caseDuplicated : mapCaseDuplicated.get(idCase)) {
					duplicateCase = new SEG_Duplicate_Case__c();
					duplicateCase.SEG_Case__c = idCase;
					duplicateCase.SEG_Case_Duplicated__c = caseDuplicated;
					lstDuplicateCases.add(duplicateCase);
					duplicateCase = new SEG_Duplicate_Case__c();
					duplicateCase.SEG_Case__c = caseDuplicated;
					duplicateCase.SEG_Case_Duplicated__c = idCase;
					lstDuplicateCases.add(duplicateCase);
				}
			}
			if (lstDuplicateCases.size() > 0) {
					
				insert lstDuplicateCases;
			}
		}
	}

	private List<Id> lookupForDuplicate(EmailMessage email, List<EmailMessage> lstEmailsToAnalyze, Map<Id, List<String>> mapObjectIdAttachmentsSize) {

		List<Id> lstEmailsId = new List<Id> ();
		List<String> attachmentsSize;
		List<String> attachmentsSizeAnalize;
		for (EmailMessage emailAnalizye : lstEmailsToAnalyze) {
			attachmentsSize = mapObjectIdAttachmentsSize.get(email.Id);
			attachmentsSizeAnalize = mapObjectIdAttachmentsSize.get(emailAnalizye.Id);
			emailAnalizye.Subject = emailAnalizye.Subject == null ? '' : parseSubject(emailAnalizye.Subject);
			email.Subject = email.Subject == null ? '' : email.Subject;
			email.TextBody = email.TextBody == null ? '' : email.TextBody;
			emailAnalizye.TextBody = emailAnalizye.TextBody == null ? '' : emailAnalizye.TextBody;

			if  ((emailAnalizye.Subject.contains(email.Subject)
			    && (emailAnalizye.TextBody.contains(email.TextBody))
			    /*&& attachmentsSize == attachmentsSizeAnalize) || (attachmentsSize!=null && attachmentsSize == attachmentsSizeAnalize*/))
			{
				lstEmailsId.add(emailAnalizye.Id);
			}
		}
		return lstEmailsId;
	}

	private string parseSubject(String subject) {
		Set<String> stringWords = new Set<String> { 'RV: ', 'RE: ' };
		for (string wordRepl : stringWords) {
			subject = subject.replaceAll(wordRepl, '');
		}
		return subject;
	}
	private Map<Id, List<String>> getAttachmentsSizeFromObjectIds(Set<Id> objectsIds) {

		Map<Id, List<String>> mapObjectIdAttachmentsSize = new Map<Id, List<String>> ();
		List<ContentDocumentLink> lstContentDocum = [SELECT Id, ContentDocumentId, LinkedEntityId
		                                             FROM ContentDocumentLink WHERE LinkedEntityId IN :objectsIds];

		Map<Id, Id> mapDocumIdObjectId = new Map<Id, Id> ();
		for (ContentDocumentLink cdl : lstContentDocum) {
			mapDocumIdObjectId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
		}
		Set<Id> setDocumentId = mapDocumIdObjectId.KeySet();
		List<ContentVersion> lstContentVersion = [SELECT Id, Title, ContentSize, ContentDocumentId
		                                          FROM ContentVersion WHERE ContentDocumentId IN :setDocumentId];

		Id objectId;
		for (ContentVersion file : lstContentVersion) {
			objectId = mapDocumIdObjectId.get(file.ContentDocumentId);
			if (mapObjectIdAttachmentsSize.containsKey(objectId)) {
				mapObjectIdAttachmentsSize.get(objectId).add(file.Title + String.valueOf(file.ContentSize));
			}
			else {
				mapObjectIdAttachmentsSize.put(objectId, new List<String> { file.Title + String.valueOf(file.ContentSize) });
			}
		}
		return mapObjectIdAttachmentsSize;
	}
	
}