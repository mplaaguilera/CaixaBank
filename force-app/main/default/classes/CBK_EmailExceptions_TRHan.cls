public class CBK_EmailExceptions_TRHan {
	// Control email errors and create a CBK_Log__c to save content of email, project and exception details
	public void handledException(Exception e, CC_TriggerParameters tp, String handlerClassType) {

        CBK_Config__mdt mc = CBK_Config__mdt.getInstance('EmailExeptionHandler');
        Boolean checkActive = Test.isRunningTest() ? true : mc.CBK_Active__c;
        if(checkActive){
            List<CBK_EmailMessage__e> peLogList = new List<CBK_EmailMessage__e>();
            List<EmailMessage> emList = (List<EmailMessage>) tp.newList;
            for (EmailMessage em : emList) {
                if(em.Incoming){
                    CBK_EmailMessage__e peLog = new CBK_EmailMessage__e();
                    peLog.Project__c = CBK_BatchJob_Helper.findProjectName(handlerClassType)?.left(30);
                    peLog.Log_Message__c = e.getMessage()?.left(2000);
                    peLog.Exception__c = e.getStackTraceString()?.left(2000);
                    peLog.Subject__c = em.Subject?.left(3000);
                    peLog.TextBody__c = em.TextBody?.left(32000);
                    peLog.HtmlBody__c = em.HtmlBody?.left(32000);
                    peLog.FromAddress__c = em.FromAddress?.left(255);
                    peLog.ToAddress__c = em.ToAddress?.left(4000);
                    peLog.CcAddress__c = em.CcAddress?.left(4000);
                    peLog.Headers__c = em.Headers?.left(32000);
                    peLogList.add(peLog);
                }
            }
            if (peLogList.size() > 0) {
                List<Database.SaveResult> results = EventBus.publish(peLogList);

                // Inspect publishing result for each event
                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                        CBK_log.debug('CBK_EmailExceptions_TRHan: Successfully published event.', LoggingLevel.INFO);
                    } else {
                        for(Database.Error err : sr.getErrors()) {
                            CBK_log.debug('CBK_EmailExceptions_TRHan: Error returned: ' +
                                        err.getStatusCode() +
                                        ' - ' +
                                        err.getMessage(), LoggingLevel.ERROR);
                        }
                    }       
                }
            }
        }
	}

    // Control email service errors and create a CBK_Log__c to save content of email, project and exception details
    public static void handledEmailServiceException(Exception e, Messaging.InboundEmail email) {

        CBK_Config__mdt mc = CBK_Config__mdt.getInstance('EmailExeptionHandler');
        Boolean checkActive = Test.isRunningTest() ? true : mc.CBK_Active__c;
        if (checkActive){
            List<EmailServicesAddress> emailSAList = [SELECT Id, IsActive, LocalPart, EmailDomainName, DeveloperName
                                                  FROM EmailServicesAddress
                                                  WHERE LocalPart != 'emailtosalesforce' AND IsActive = true];
        
            String emailHeaderToAddress = '';
            if (email.headers != null && email.headers.size() > 0) {
                emailHeaderToAddress = CBK_EmailMessage_Parent_TRHan.getToAddresHeader(JSON.serialize(email.headers));
            }
            
            String project = '';
            if (String.isNotBlank(emailHeaderToAddress)) {
                for (EmailServicesAddress emailSA : emailSAList) {
                    if (emailHeaderToAddress.contains(emailSA.EmailDomainName)) {
                        project = emailSA.DeveloperName;
                    }
                }
            }

            CBK_EmailMessage__e peLog = new CBK_EmailMessage__e();
            peLog.Project__c = project?.left(30);
            peLog.Log_Message__c = e.getMessage()?.left(2000);
            peLog.Exception__c = e.getStackTraceString()?.left(2000);
            peLog.Subject__c = email.subject?.left(3000);
            peLog.TextBody__c = email.plainTextBody?.left(32000);
            peLog.HtmlBody__c = email.htmlBody?.left(32000);
            peLog.FromAddress__c = email.fromAddress?.left(255);
            if (email.toAddresses != null && email.toAddresses.size() > 0) {
                peLog.ToAddress__c = String.join(email.toAddresses,';')?.left(4000); 
            }
            if (email.ccAddresses != null && email.ccAddresses.size() > 0) {
                peLog.CcAddress__c = String.join(email.ccAddresses,';')?.left(4000);
            }
            if (email.headers != null && email.headers.size() > 0) {
                peLog.Headers__c = JSON.serialize(email.headers)?.left(32000);
            }

            Database.SaveResult result = EventBus.publish(peLog);

            if (result.isSuccess()) {
                CBK_log.debug('CBK_EmailExceptions_TRHan: Successfully published event.', LoggingLevel.INFO);
            } else {
                for(Database.Error err : result.getErrors()) {
                    CBK_log.debug('CBK_EmailExceptions_TRHan: Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage(), LoggingLevel.ERROR);
                }
            }
        }
    
	}
}