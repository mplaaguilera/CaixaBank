global class CBK_EmailMessageBatch implements Database.Batchable<sObject>, Database.Stateful{
    global Integer allRecordsProcessed = 0;
    global Integer allRecordsProcessedOK = 0;
    global Integer allRecordsProcessedKO = 0;
    global CBK_EmailMessageBatch() {

    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        allRecordsProcessed = 0;
        allRecordsProcessedOK = 0;
        allRecordsProcessedKO = 0;
        CBK_Log.debug('Start - Batch Reproceso Correo', logginglevel.INFO);
        return Database.getQueryLocator([SELECT Id, CBK_EmailMessageId__c, CBK_Status__c, CBK_ErrorDescription__c FROM CBK_EmailMessageResend__c WHERE CBK_Status__c = 'Pendiente']);
    }
    global void execute(Database.BatchableContext bc, List<CBK_EmailMessageResend__c> scope){
        if (scope.isEmpty()) {
            return;
        }
        allRecordsProcessed += scope.size();
        Set<String> valFromAddress = new Set<String>();
        List<String> setContDocId = new List<String>();
        Map<string,string> mapOwa = new Map<string,string>();
        Map<string,string> mapDocIdEmail = new Map<string,string>();
        Map<string,List<string>> mapEmailLstDocId = new Map<string,List<string>>();
        Map<string,CBK_EmailMessageResend__c> mapidentifierReen = new Map<string,CBK_EmailMessageResend__c>();

        for (CBK_EmailMessageResend__c datoProceso : scope){
            mapidentifierReen.put(datoProceso.CBK_EmailMessageId__c, datoProceso);
        }
        
        // Recuperar los EmailMessage.
        List<EmailMessage> listadoEmails = [SELECT Id,MessageIdentifier, ToAddress, CcAddress, BccAddress, Subject, HtmlBody,TextBody, ParentId, RelatedToId, ValidatedFromAddress, contentDocumentIds 
                                            FROM EmailMessage WHERE MessageIdentifier IN :mapidentifierReen.keyset()];

        for (EmailMessage em : listadoEmails){
            valFromAddress.add(em.ValidatedFromAddress);
            setContDocId.addAll(em.contentDocumentIds);
            
            for (String docId : setContDocId){
				if (!mapDocIdEmail.containsKey(docId)){
                	mapDocIdEmail.put(docId, em.Id);
				}
            }
        }

        // Procesar el ValidatedFromAddress para recuperar las OWA.
        List<OrgWideEmailAddress> lstOwa = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address in :valFromAddress];
        for (OrgWideEmailAddress owa : lstOwa){
            mapOwa.put(owa.Address, owa.Id);
        }

        // Recuperar los ContentVersionId vinculados al Email, para vincularlos como adjuntos del nuevo correo.
        List<ContentVersion> lstAttach = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId in :setContDocId];
        for (ContentVersion cntVer : lstAttach){
            if (mapDocIdEmail.containsKey(cntVer.ContentDocumentId)){
                String emailId = mapDocIdEmail.get(cntVer.ContentDocumentId);
                if (mapEmailLstDocId.containsKey(emailId)){
                    mapEmailLstDocId.get(emailId).add(cntVer.Id);
                }else{
                    mapEmailLstDocId.put(emailId, new List<String>{cntVer.Id});
                }
            }
        }

        try{
            Map<string,string> errorLimites = new Map<string,string>();
            List<String> mensajeReenviado = new List<String>();
            List<Messaging.SingleEmailMessage> listadoCorreosEnviar = new List<Messaging.SingleEmailMessage>();
            CBK_Config__mdt config = CBK_Config__mdt.getInstance('EmailMessageResend');
            for (EmailMessage emailReprocesar : listadoEmails){
                List<String> lstToAddress = emailReprocesar.ToAddress != null ? emailReprocesar.ToAddress.split(';') : new List<String>();
                List<String> lstCcAddress = emailReprocesar.CcAddress != null ? emailReprocesar.CcAddress.split(';') : new List<String>();
                List<String> lsttBccAddress = emailReprocesar.BccAddress != null ? emailReprocesar.BccAddress.split(';') : new List<String>();
                if(lstToAddress != null && lstToAddress.size() > 100){
                    allRecordsProcessedKO++;
                    errorLimites.put(emailReprocesar.MessageIdentifier, 'Más de 100 destinatarios en el ToAddress');
                    CBK_Log.error(emailReprocesar.Id + ' Más de 100 destinatarios en el ToAddress: ' + lstToAddress);
                }else if(lstCcAddress != null && lstCcAddress.size() > 25){
                    allRecordsProcessedKO++;
                    errorLimites.put(emailReprocesar.MessageIdentifier, 'Más de 25 destinatarios en el CcAddress');
                    CBK_Log.error(emailReprocesar.Id + ' - Más de 25 destinatarios en el CcAddress: ' + lstCcAddress);
                }else if(lsttBccAddress != null && lsttBccAddress.size() > 25){
                    allRecordsProcessedKO++;
                    errorLimites.put(emailReprocesar.MessageIdentifier, 'Más de 25 destinatarios en el BccAddress');
                    CBK_Log.error(emailReprocesar.Id + ' - Más de 25 destinatarios en el BccAddress: ' + lsttBccAddress);
                }else{
                    Messaging.SingleEmailMessage mensajeEnviar = new Messaging.SingleEmailMessage();
                    mensajeEnviar.setToAddresses(lstToAddress); 
                    mensajeEnviar.setCcAddresses(lstCcAddress); 
                    mensajeEnviar.setBccAddresses(lsttBccAddress);
                    mensajeEnviar.setOrgWideEmailAddressId(mapOwa.get(emailReprocesar.ValidatedFromAddress));
                    mensajeEnviar.setUseSignature(false); 
                    mensajeEnviar.setBccSender(false); 
                    mensajeEnviar.setSaveAsActivity(true); 
                    mensajeEnviar.setSubject(emailReprocesar.Subject);

                    if (String.isNotBlank(emailReprocesar.HtmlBody)){
                        mensajeEnviar.setHtmlBody(emailReprocesar.HtmlBody);
                    }else{
                        mensajeEnviar.setPlainTextBody(emailReprocesar.TextBody);
                    }
                    
                    if (config.CBK_Active__c){
                        mensajeEnviar.setWhatId(mapidentifierReen.get(emailReprocesar.MessageIdentifier).Id);
                    }else{
                        mensajeEnviar.setWhatId(emailReprocesar.RelatedToId);
                    } 

                    mensajeEnviar.setEntityAttachments(mapEmailLstDocId.get(emailReprocesar.Id)); 
                    listadoCorreosEnviar.add(mensajeEnviar);
                    mensajeReenviado.add(emailReprocesar.MessageIdentifier);
                }
            }
            Set<String> udpIdsOK = new Set<String>();
            List<CBK_EmailMessageResend__c> listaUpdateReprocess = new List<CBK_EmailMessageResend__c>();
            CBK_EmailMessageResend__c newResult;
            if(errorLimites.keySet().size() > 0){
                for(String key : errorLimites.keySet()){
                    newResult = new CBK_EmailMessageResend__c();
                    newResult.Id = mapidentifierReen.get(key).Id;
                    newResult.CBK_Status__c = 'Error';
                    newResult.CBK_ErrorDescription__c = errorLimites.get(key);
                    listaUpdateReprocess.add(newResult);
                }
            }

            CBK_Log.debug('listadoCorreosEnviar.size(): ' + listadoCorreosEnviar.size());
            if (listadoCorreosEnviar.size() > 0){
                List<Messaging.SendEmailResult> envioCorreos = Messaging.sendEmail(listadoCorreosEnviar, false);
                Integer i = 0;
                for (Messaging.SendEmailResult correoEnviado : envioCorreos){
                    newResult = new CBK_EmailMessageResend__c();
                    newResult.Id = mapidentifierReen.get(mensajeReenviado.get(i)).Id;

                    if (!correoEnviado.isSuccess()){
                        newResult.CBK_Status__c = 'Error';
                        newResult.CBK_ErrorDescription__c = 'Error en el Reenvio';
                        allRecordsProcessedKO++;
                        CBK_Log.error('Send Email result: ' + correoEnviado.isSuccess() + ' - ' + correoEnviado.getErrors());
                    }else{
                        newResult.CBK_Status__c = 'Procesado';
                        allRecordsProcessedOK++;
                    }
                    i++;
                    listaUpdateReprocess.add(newResult);
                }
            }
            if (listaUpdateReprocess.size() > 0){
                CBK_Log.debug('Lista update: ' + listaUpdateReprocess);
                update listaUpdateReprocess;
            }

        }catch(Exception ex){
            CBK_Log.error(ex, 'Catch Error Reproceso correos: ' + ex.getMessage());
        }
    }    
    global void finish(Database.BatchableContext bc){
        CBK_Log.debug('Email a Reprocesar: ' + allRecordsProcessed + ' / Reprocesados: ' + allRecordsProcessedOK + ' / Error Reproceso: ' + allRecordsProcessedKO);
	}
}