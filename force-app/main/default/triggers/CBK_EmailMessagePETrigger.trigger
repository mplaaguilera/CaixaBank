trigger CBK_EmailMessagePETrigger on CBK_EmailMessage__e (after insert) {

    CBK_log.debug('Entra CBK_EmailMessagePETrigger', LoggingLevel.INFO);
    Id idRecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CBK_Log__c', 'Emails_erroneos');
    String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
    List <CBK_Log__c> logList = new List<CBK_Log__c>();
    List <EmailMessage> lstEmail = new List<EmailMessage>();
    List <CBK_EmailMessage__e> lstemailETrigger = Trigger.new;
    List<Id> logsIds = new List<Id>();

    for (CBK_EmailMessage__e event : lstemailETrigger) {
        CBK_Log__c evLog = New CBK_Log__c();
        evLog.RecordTypeId = idRecordType;
        evLog.state__c = 'Error';
        evLog.createdBy__c = event.CreatedById;
        evLog.project__c = event.Project__c;
        evLog.Log_Message__c =  event.Log_Message__c;
        evLog.Apex_Stack_Trace__c =  event.Exception__c;
        evLog.Subject__c = event.Subject__c;
        evLog.FromAddress__c = event.FromAddress__c;
        evLog.ToAddress__c = event.ToAddress__c;
        evLog.CcAddress__c = event.CcAddress__c;
        logList.add(evLog);
    }

    Database.SaveResult[] srList2 = Database.insert(logList,false);

    // Iterate through each returned result
    for (Database.SaveResult sr : srList2) {
        if (sr.isSuccess()) {
            CBK_log.debug('Successfully inserted log. CBK_Log__c ID: ' + sr.getId(), LoggingLevel.INFO);
            logsIds.add(sr.getId());

        }
        else {               
            for(Database.Error err : sr.getErrors()) {
                CBK_log.debug('The following error has occurred.', LoggingLevel.ERROR);                    
                CBK_log.debug(err.getStatusCode() + ': ' + err.getMessage(), LoggingLevel.ERROR);
                CBK_log.debug('CBK_Log__c fields that affected this error: ' + err.getFields(), LoggingLevel.ERROR);
            }
        }
    }

    for (CBK_EmailMessage__e event : lstemailETrigger) {
        // Creates email message from fields
        EmailMessage vemail = new EmailMessage();
        vemail.Incoming = true;
        vemail.Subject = event.Subject__c;
        vemail.TextBody = event.TextBody__c;
        vemail.HtmlBody = event.HtmlBody__c;
        vemail.FromAddress = event.FromAddress__c;
        vemail.ToAddress = event.ToAddress__c;
        vemail.CcAddress = event.CcAddress__c;
        vemail.Headers = event.Headers__c;
        vemail.CBK_IgnoreTrigger__c = true;
		lstEmail.add(vemail);
    }

    for (Integer i = 0; i < lstEmail.size(); i++) {
        lstEmail[i].RelatedToId = logsIds[i];
    }

    // Insert without triggers (CBK_IgnoreTrigger__c = true)
    Database.SaveResult[] srList = Database.insert(lstEmail,false);

    // Iterate through each returned result
    for (Database.SaveResult sr : srList) {
        if (sr.isSuccess()) {
            CBK_log.debug('Successfully inserted email. EmailMessage ID: ' + sr.getId(), LoggingLevel.INFO);
        }
        else {               
            for(Database.Error err : sr.getErrors()) {
                CBK_log.debug('The following error has occurred.', LoggingLevel.ERROR);                    
                CBK_log.debug(err.getStatusCode() + ': ' + err.getMessage(), LoggingLevel.ERROR);
                CBK_log.debug('EmailMessage fields that affected this error: ' + err.getFields(), LoggingLevel.ERROR);
            }
        }
    }
    

}