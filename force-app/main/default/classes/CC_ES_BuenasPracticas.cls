public with sharing class CC_ES_BuenasPracticas implements Messaging.InboundEmailHandler {    
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        EmailMessage crearEmailMessage = new EmailMessage();
        try {
            CBK_log.auditemail(email);
            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();        
            String body = '';
            if(String.isNotBlank(email.plainTextBody)) {
                body = email.plainTextBody.left(131072);
            } else if(String.isNotBlank(email.htmlBody)) {
                body = email.htmlBody.stripHtmlTags().left(131072);
            } 
            String emailDestino = envelope.toAddress;
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
                caso.Subject = email.Subject;
                caso.Description = body.left(32000); 
                caso.CC_Tipo_Cliente__c = null;
                caso.Status = 'Activo';
                caso.CC_Canal_Procedencia__c = 'Código de Buenas Prácticas';
                caso.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName  = 'CC_Inbound_Email_AC' LIMIT 1].Id;
                
                insert caso;
                result.success = true;
                
                List<Id> listaContentVersionIdEmail = new List<Id>();
                crearEmailMessage = crearEmailMessage(email, emailDestino, caso.id, null, body);
                
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
                        ContentDocumentLink cdLinkEmail = new ContentDocumentLink();
                        cdLinkEmail.LinkedEntityId = crearEmailMessage.Id;
                        cdLinkEmail.ContentDocumentId = cv.ContentDocumentId;
                        cdLinkEmail.ShareType = 'V';
                        listaContentDocumentLink.add(cdLinkEmail);
                    }
                    insert listaContentDocumentLink;
                }
                //Save any Binary Attachment
                if (email.binaryAttachments != null){
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
                        ContentDocumentLink cdLinkEmail = new ContentDocumentLink();
                        cdLinkEmail.LinkedEntityId = crearEmailMessage.Id;
                        cdLinkEmail.ContentDocumentId = cv.ContentDocumentId;
                        cdLinkEmail.ShareType = 'V';
                        listaContentDocumentLink.add(cdLinkEmail);
                    }
                    insert listaContentDocumentLink;            
                }
                //EmailMessage crearEmailMessage = crearEmailMessage(email, emailDestino, caso.id, null, body);//Contacto.id
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
    
    public static EmailMessage crearEmailMessage(Messaging.inboundEmail email, String emailDestino, Id caseId,Id contactId, String myPlainText){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        EmailMessage createEmail = new EmailMessage();
        try {
            //Si supera el tamaño del campo hay que recortar para que no falle
            String caseDescription = myPlainText;
            if (myPlainText.length() > 32000) {
                caseDescription = myPlainText.left(32000); 
            }
            
            
            Task createTask = new Task(
            Type = 'Automática'
            ,TaskSubtype = 'Email'
            ,Subject = 'Correo entrante Código de Buenas Prácticas' 
            ,ActivityDate = System.today()
            ,Status = 'Completed'
            ,Description = caseDescription
            ,WhatId = caseId
            ,WhoId = contactId
            );
            //insert createTask;
            CC_Activity.crearActividad(createTask);
            
            String emailSubject = email.Subject;
            if (emailSubject.length() > 3000) {
                emailSubject = emailSubject.left(3000); 
            }
            createEmail.Subject  = emailSubject; 
            createEmail.Status = '1';
            if (email.ccAddresses!=null) {
                createEmail.CcAddress = string.join(email.ccAddresses,','); 
            }
            createEmail.FromAddress = email.fromAddress;
            createEmail.FromName = email.fromName;
            createEmail.Headers = JSON.serialize( email.headers );
            createEmail.TextBody = myPlainText;
            //createEmail.HtmlBody = email.htmlBody;
            createEmail.Incoming = true;
            createEmail.MessageDate = DateTime.now();
            createEmail.ParentId = caseId;                    
            createEmail.ToAddress = emailDestino;
            createEmail.MessageIdentifier = email.messageId;
            createEmail.CBK_sfdcMessageId__c = email.messageId?.left(255);
            createEmail.ThreadIdentifier = email.inReplyTo;
            insert createEmail; 
        } catch (DmlException ex) {
            System.StatusCode i = ex.getDmlType(0);
            system.debug('ex: '+ex);
            CBK_Log.debug('Error tipo ' + i);
        }
        return createEmail;
    }
}