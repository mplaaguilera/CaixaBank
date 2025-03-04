public class CBK_EmailMessageTriggerHelper {
	public static list<SObject> filterEmailsHandlers(CC_TriggerParameters tp, string handlerClass, String vEventType) {

		Map<String, String> mhandlerClassName = getMapAssociatedHandlers(handlerClass, vEventType);
		string vEmails = mhandlerClassName.get(handlerClass);

		set<string> sEmailsCheck = new set<string> ();
		List<String> lstEmails = new List<String> ();
		List<SObject> lstSO = new List<SObject> ();

		if (string.isNotBlank(vEmails) && vEmails.indexOf(';') >= 0) {
			lstEmails = vEmails.split(';');
		} else if (string.isNotBlank(vEmails)) {
			lstEmails.add(vEmails);
		}

		if (lstEmails != null && lstEmails.size() > 0) {
			for (string sEmails : lstEmails) {
				sEmailsCheck.add(sEmails);
			}
		}

		String vExpr = '(^.*@*.apex.*.salesforce.com)';
		string vExpr2 = '(^.*@)';
		List<string> strToadd = new List<string> ();
		for (SObject so : tp.newList) {
			string vkey = string.valueOf(so.get('FromAddress'));
			Boolean vIncom = Boolean.valueOf(so.get('Incoming'));

			if (!vIncom && String.isNotBlank(vkey) && sEmailsCheck.contains(vkey)) {
				lstSO.add(so);
			} else if (vIncom) {
				vkey = string.valueOf(so.get('ToAddress'));
				if (String.isNotBlank(vkey) && vkey.indexOf(';') >= 0)
				{
					strToadd = vkey.split(';');
					for (string str : strToadd)
					{
						if (sEmailsCheck.contains(str)) {
							lstSO.add(so);
						}
					}
				} else if (String.isNotBlank(vkey)) {
					string vEmLong = searchEmailbyExpre(vExpr, vkey);

					if (string.isNotBlank(vEmLong)) {
						string vEmShort = searchEmailbyExpre(vExpr2, vkey);
						if (sEmailsCheck.contains(vEmShort)) {
							lstSO.add(so);
						}
					} else if (sEmailsCheck.contains(vkey)) {
						lstSO.add(so);
					}
				}
			}
		}
		CBK_log.debug(vEventType + 'Filtrado de Emails Handlers - newList:' + lstSO, LoggingLevel.INFO);
		return lstSO;
	}

	public static Map<String, String> getMapAssociatedHandlers(String className, String triggerEvent) {

		Map<String, String> mHandlerClassNames = new Map<string, String> ();

		List<CBK_TriggerHandlerAssociation__mdt> triggerHandlerAssociations = [SELECT CBK_HandlerClassName__c, CBK_ValidationHandlerEmail__c, CBK_ValidationHandlerEmail__r.Emails__c FROM CBK_TriggerHandlerAssociation__mdt WHERE CBK_HandlerClassName__c = :className AND CBK_TriggerEvent__c = :triggerEvent];

		for (CBK_TriggerHandlerAssociation__mdt triggerHandlerAssociation : triggerHandlerAssociations) {
			mHandlerClassNames.put(triggerHandlerAssociation.CBK_HandlerClassName__c, triggerHandlerAssociation.CBK_ValidationHandlerEmail__r.Emails__c);
		}
		return mHandlerClassNames;
	}

	public static string searchEmailbyExpre(String vExpr, String vText) {

		Pattern p = Pattern.compile(vExpr);
		Matcher pm = p.matcher(vText);
		string vEmail = pm.find() ? pm.group() : '';

		return vEmail;
	}

	public static void checkEmailAndDomain(CC_TriggerParameters tp) {

		Map<String, CBK_EmailMessage_Check__mdt> mcs = CBK_EmailMessage_Check__mdt.getAll();
		Set<string> sEmails = new Set<String> ();
		Set<string> sDomains = new Set<String> ();
		Map<String, String> whiteListsMap = new Map<String, String> ();



		for (CBK_EmailMessage_Check__mdt lst : mcs.values()) {
			if (lst.Type__c == 'Email' && lst.Active__c) {
				sEmails.add(lst.Email_Domain__c);
			} else if (lst.Active__c || Test.isRunningTest()) {
				sDomains.add(lst.Email_Domain__c);
				if (lst.CBK_EmailMessage_Check_Whitelist__c != null) {
					CBK_EmailMessage_Check_Whitelist__mdt mcs2 = CBK_EmailMessage_Check_Whitelist__mdt.getInstance(lst.CBK_EmailMessage_Check_Whitelist__c);
					if(mcs2.Active__c){
					whiteListsMap.put(lst.Email_Domain__c, mcs2.Emails__c);
				}
			}			
		}
		}

		List<string> lstStrEmail = new List<string> ();
		List<string> lstStrEmailCc = new List<string> ();
		String vkey;
		String vkey2;

		for (SObject so : tp.newList) {

			if (!Boolean.valueOf(so.get('Incoming'))) {
				vkey = string.valueOf(so.get('ToAddress'));
				vkey2 = string.valueOf(so.get('CcAddress'));

				lstStrEmail = string.isNotBlank(vkey) ? vkey.split(';') : new List<string> ();
				lstStrEmailCc = string.isNotBlank(vkey2) ? vkey2.split(';') : new List<string> ();

				// ToAddress
				for (string str : lstStrEmail)
				{
					if (sEmails.contains(str)) {
						so.addError('Email restringido para el envío de correos: ' + str);
					}
					else if (sDomains.contains(str.substringAfter('@'))) {
						if (whiteListsMap.containsKey(str.substringAfter('@'))) {
							String concatEmail = whiteListsMap.get(str.substringAfter('@'));
							List<String> strEm = concatEmail.split(';');
							if (!strEm.contains(str)) {
								so.addError('Email restringido para el envío de correos: ' + str);
							}
						}
						else {
							so.addError('Dominio restringido para el envío de correos: ' + str);
						}

					}
				}

				// CcAddress
				for (string str : lstStrEmailCc)
				{
					if (sEmails.contains(str)) {
						so.addError('Email restringido para el envío de correos: ' + str);
					}
					else if (sDomains.contains(str.substringAfter('@'))) {
						if (whiteListsMap.containsKey(str.substringAfter('@'))) {
							String concatEmail = whiteListsMap.get(str.substringAfter('@'));
							List<String> strEm = concatEmail.split(';');
							if (!strEm.contains(str)) {
								so.addError('Email restringido para el envío de correos: ' + str);
							}
						}
						else {
							so.addError('Dominio restringido para el envío de correos: ' + str);
						}

					}
				}
			}
		}
	}

	public static List<EmailMessage> outboundEmailsFilter(List<EmailMessage> emails) {
		List<EmailMessage> outboundEmails = new List<EmailMessage>();
		if(emails != null && !emails.isEmpty()) {
			for(EmailMessage email : emails) {
				if(!email.Incoming) {
					outboundEmails.add(email);
				}
			}
		}
		return outboundEmails;
    }

	public static void checkFileExtensions(List<EmailMessage> outboundEmails, Map<Id, EmailMessage> mapNewObj) {
		if(outboundEmails == null || outboundEmails.isEmpty() || mapNewObj == null || mapNewObj.isEmpty()) {
			return;
		}
		
		List<String> allowedExtensions = new List<String>();
		for (CC_ConfiguracionAnexoPermitido__mdt allowedExtension : [SELECT CC_Extension__c FROM CC_ConfiguracionAnexoPermitido__mdt]) {
			if(String.isNotBlank(allowedExtension.CC_Extension__c)) {
				allowedExtensions.add(allowedExtension.CC_Extension__c);
			}
		}

		List<Id> outboundEmailIds = new List<Id>();
		for (EmailMessage email : outboundEmails) {
			outboundEmailIds.add(email.Id);
		}

		if (!outboundEmailIds.isEmpty() && !allowedExtensions.isEmpty()) {
			for (ContentDocumentLink contentDocumentLink : [SELECT LinkedEntityId
															FROM ContentDocumentLink
															WHERE 	ContentDocument.FileExtension NOT IN :allowedExtensions 
																	AND LinkedEntityId IN :outboundEmailIds]) {
				if(mapNewObj.containsKey(contentDocumentLink.LinkedEntityId)) {
					EmailMessage email = mapNewObj.get(contentDocumentLink.LinkedEntityId);
					email.addError(Label.CBK_InvalidAttachmentExtension);
				}
			}
		}
    }
}