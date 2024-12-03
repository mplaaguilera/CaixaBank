public with sharing class CC_CaixabankTalks_EmailService implements Messaging.InboundEmailHandler {
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        EmailMessage crearEmailMessage = new EmailMessage();
        try {
            CBK_log.auditemail(email);
            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
            String sTipoNif = '';
            String body = '';
            if (String.isNotBlank(email.plainTextBody)) {
                body = email.plainTextBody.left(131072);
            } else if (String.isNotBlank(email.htmlBody)) {
                body = email.htmlBody.stripHtmlTags().left(131072);
            } 
            
            String emailOrigen= email.fromAddress;
            String emailDestino= envelope.toAddress;
            
            
            //Miramos si el correo entrante tiene una semilla que coincide con alguna actividad de un caso ya existente
            String referencia = CC_Metodos_EmailServices.referenciaCorreo(email);
            if (referencia != null){
                List<Task> tareaOrigen = [SELECT Id, WhatId, Type FROM Task WHERE CC_Referencia_Correo_Saliente__c = :referencia AND
                (RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task')) LIMIT 1];
                if (!tareaOrigen.isEmpty()) {
                    if (tareaOrigen[0].Type == 'Traslado Colaborador') {
                        //Respuesta entrante de grupo colaborador
                        CC_Metodos_EmailServices.respuestaTrasladoColaborador(email, tareaOrigen[0].WhatId, body, emailDestino);
                    } else if (tareaOrigen[0].Type == 'Solicitud Información') {
                        //Respuesta entrante de solicitud de información de cliente
                        CC_Metodos_EmailServices.respuestaSolicitudInfo(email, tareaOrigen[0].WhatId, body, emailDestino);
                    } else if (tareaOrigen[0].Type == 'Remitir Colaborador') {
                        //Respuesta entrante de remisión del caso a grupo colaborador
                        CC_Metodos_EmailServices.respuestaRemitirColaborador(email, tareaOrigen[0].WhatId, body, emailDestino);
                    }else if (tareaOrigen[0].Type == 'Responder a cliente') {
                        //Respuesta entrante de respuesta de cliente
                        CC_Metodos_EmailServices.respuestaCliente(email, tareaOrigen[0].WhatId, body, emailDestino);
                    }
                }
            } else {
                //El correo ha llegado sin referencia o ésta no apunta a ninguna tarea o la procedencia del caso no coincide con la procedencia de email entrante --> Se crea nuevo caso
                
                
                Case caso = new Case();
                caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
                caso.Origin = 'Email';
                caso.CC_Canal_Procedencia__c = 'CaixaBank Talks';
                caso.CC_Canal_Resolucion__c = 'CaixaBank Talks';
                caso.Subject = email.Subject;
                caso.Description = body.left(32000); 
                
                caso.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_Entrada_Caixabank_Talks' LIMIT 1].Id;  
                caso.CC_MailTelfNotif__c = email.fromAddress;
                caso.CC_Tipo_Cliente__c = null;
                caso.Status = 'Activo';
                caso.CC_Idioma__c = 'es';
                
                
                //Identificación del cliente si hay una sola cuenta y contacto con el email remitente
                Id accountId = null;
                Id contactId = null;
                
                Id recordTypeContacto  = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                List<Contact> contacto = [SELECT id, FirstName, AccountId FROM Contact where Email = :emailOrigen AND RecordTypeId = :recordTypeContacto AND CC_Inactivo__c = false];
                if(!contacto.isEmpty()){
                    accountId = contacto[0].AccountId;
                    contactId = contacto[0].Id;
                }
                
                caso.AccountId = accountId;
                caso.ContactId = contactId;
                insert caso;
                
                //Adjuntos
                List<Id> listaContentVersionIdEmail = new List<Id>();            
                
                String nuevoHtmlBody = email.htmlBody;
                if (!String.isBlank(nuevoHtmlBody) && nuevoHtmlBody.length() > 131072) {
                    nuevoHtmlBody = nuevoHtmlBody.left(131072);
                }
                
                crearEmailMessage = crearEmailMessage(email, envelope.toAddress, caso.id, null, body, nuevoHtmlBody);
                
                if (email.textAttachments != null) { 
                    //Insertar registros Content Version
                    List<ContentVersion> listaContentVersion = new List<ContentVersion>();
                    for (Messaging.Inboundemail.TextAttachment textAttachment : email.textAttachments) {
                        ContentVersion cv = new ContentVersion();
                        cv.ContentLocation = 'S';
                        cv.PathOnClient = textAttachment.fileName;
                        cv.Origin = 'H';
                        cv.Title = textAttachment.fileName;
                        cv.VersionData = Blob.valueOf(textAttachment.body);
                        listaContentVersion.add(cv);
                    }
                    insert listaContentVersion;
                    
                    //Recuperar ContentDocumentId de los registros Content Version insertados
                    List<Id> listaContentVersionId = new List<Id>();
                    for (ContentVersion cv : listaContentVersion) {
                        listaContentVersionId.add(cv.Id);
                        listaContentVersionIdEmail.add(cv.Id);
                    }
                    listaContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :listaContentVersionId];
                    
                    //Insertar registros ContentDocumentLink
                    List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
                    for (ContentVersion cv : listaContentVersion) {
                        ContentDocumentLink cdLink = new ContentDocumentLink();
                        cdLink.LinkedEntityId = caso.Id;
                        cdLink.ContentDocumentId = cv.ContentDocumentId;
                        cdLink.ShareType = 'I';
                        listaContentDocumentLink.add(cdLink);
                        //Insertar registros ContentDocumentLink asociados al email
                        /*ContentDocumentLink cdLinkEmail = new ContentDocumentLink();
                        cdLinkEmail.LinkedEntityId = crearEmailMessage.Id;
                        cdLinkEmail.ContentDocumentId = cv.ContentDocumentId;
                        cdLinkEmail.ShareType = 'V';
                        listaContentDocumentLink.add(cdLinkEmail);*/
                    }
                    insert listaContentDocumentLink;
                }
                
                if (email.binaryAttachments != null) {
                    //Insertar registros Content Version
                    List<ContentVersion> listaContentVersion = new List<ContentVersion>();
                    Map<String, String> mapaImagenes = new Map<String, String>();
                    for (Messaging.Inboundemail.BinaryAttachment binaryAttachment : email.binaryAttachments) {
                        ContentVersion cv = new ContentVersion();
                        cv.ContentLocation = 'S';
                        cv.PathOnClient = binaryAttachment.fileName;
                        cv.Origin = 'H';
                        cv.Title = binaryAttachment.fileName;
                        cv.VersionData = binaryAttachment.body;
                        
                        //Se almacena el identificador de la imagen para poder realizar un reemplazo posterior
                        if (binaryAttachment.headers != null) {
                            for (Integer i = 0; i < binaryAttachment.headers.size(); i++) {
                                
                                if (binaryAttachment.headers[i].name == 'Content-Id') {
                                    String headerValue = binaryAttachment.headers[i].value;
                                    headerValue = headerValue.replaceAll('<', '').replaceAll('>', '');
                                    cv.ExternalDocumentInfo1=headerValue;
                                }
                            }
                        }
                        listaContentVersion.add(cv);
                    }
                    insert listaContentVersion;
                    
                    
                    //Recuperar ContentDocumentId de los registros Content Version insertados
                    List<Id> listaContentVersionId = new List<Id>();
                    for (ContentVersion cv : listaContentVersion) {
                        listaContentVersionId.add(cv.Id);
                        listaContentVersionIdEmail.add(cv.Id);
                    }
                    listaContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :listaContentVersionId];
                    
                    //Insertar registros ContentDocumentLink
                    List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
                    for (ContentVersion cv : listaContentVersion) {
                        ContentDocumentLink cdLink = new ContentDocumentLink();
                        cdLink.LinkedEntityId = caso.Id;
                        cdLink.ContentDocumentId = cv.ContentDocumentId;
                        cdLink.ShareType = 'I';
                        listaContentDocumentLink.add(cdLink);
                        //Insertar registros ContentDocumentLink asociados al email
                        /*ContentDocumentLink cdLinkEmail = new ContentDocumentLink();
                        cdLinkEmail.LinkedEntityId = crearEmailMessage.Id;
                        cdLinkEmail.ContentDocumentId = cv.ContentDocumentId;
                        cdLinkEmail.ShareType = 'V';
                        listaContentDocumentLink.add(cdLinkEmail);*/
                    }
                    insert listaContentDocumentLink;
                }
                //EmailMessage crearEmailMessage = crearEmailMessage(email, envelope.toAddress, caso.id, null, body, nuevoHtmlBody);
                
                //Insertar registros ContentDocumentLink asociados al email
                List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
                list<ContentVersion> listaContentVersionEmail = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :listaContentVersionIdEmail];
                for (ContentVersion cv : listaContentVersionEmail) {
                    ContentDocumentLink cdLink = new ContentDocumentLink();
                    cdLink.LinkedEntityId = crearEmailMessage.Id;
                    cdLink.ContentDocumentId = cv.ContentDocumentId;
                    cdLink.ShareType = 'V';
                    listaContentDocumentLink.add(cdLink);
                }
                insert listaContentDocumentLink; 
                
                result.success = true;            
            }
            
            CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
            wResult.Status = 'OK';
            wResult.Detail = 'Envio correcto';
            wResult.CaseId = crearEmailMessage.RelatedToId;
            wResult.EmailMessageId = crearEmailMessage.Id;
            CBK_Log.auditemailResult(wResult, email);
            return result;
            
        } catch (Exception e) {
            CBK_Log.error(e, 'Error en el envio de email', email);
            CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
            wResult.Status = 'KO';
            wResult.Detail = e.getMessage()?.left(255);
            wResult.CaseId = crearEmailMessage.RelatedToId;
            wResult.EmailMessageId = crearEmailMessage.Id;
            CBK_Log.auditemailResult(wResult, email);            
            return null;
        }
    }
    
    public static EmailMessage crearEmailMessage(Messaging.InboundEmail email, String toAddress, Id idCaso, Id contactId, String body, String nuevoHtmlBody) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        Task tarea = new Task();
        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        tarea.Type = 'Correo - Entrada';
        tarea.TaskSubtype = 'Email';
        tarea.Subject = email.subject;
        tarea.ActivityDate = System.today();
        tarea.Status = 'Completed';
        tarea.Description = body.left(32000);
        tarea.WhatId = idCaso;
        tarea.WhoId = contactId;
        insert tarea;
        
        EmailMessage correo = new EmailMessage();
        correo.Subject = email.Subject;
        correo.Status = '1';
        if (email.ccAddresses != null) {
            correo.CcAddress = String.join(email.ccAddresses, ',');
        }
        correo.FromAddress = email.fromAddress;
        correo.FromName = email.fromName;
        correo.Headers = JSON.serialize(email.headers);
        
        if (String.isNotBlank(nuevoHtmlBody)) {
            correo.HtmlBody = nuevoHtmlBody.left(131072);    
        } else if (String.isNotBlank(email.HtmlBody)) {
            correo.HtmlBody = email.HtmlBody.left(131072);
        } else {
            correo.TextBody = body.left(131072);   
        }
        correo.Incoming = true;
        correo.MessageDate = DateTime.now();
        correo.ParentId = idCaso;
        if (!Test.isRunningTest()) {                    
            correo.ToAddress = string.join(email.toAddresses,',');
        } else {
            correo.ToAddress = toAddress;
        }
        correo.MessageIdentifier = email.messageId;
        correo.CBK_sfdcMessageId__c = email.messageId?.left(255);
        correo.ThreadIdentifier = email.inReplyTo;
        insert correo;
        return correo;
    }    
}