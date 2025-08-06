public with sharing class CC_Oficina_Feedback_EmailService implements Messaging.InboundEmailHandler {
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
            
            String idioma='';
            String emailOrigen= email.fromAddress;
            String emailDestino= envelope.toAddress;
            String vLastName = emailOrigen;
            String vFirstName = '';
            String vName = '';
            String vPhone = '';
            String vNif ='';
            
            //Miramos si el correo entrante tiene una semilla que coincide con alguna actividad de un caso ya existente
            String referencia = CC_Metodos_EmailServices.referenciaCorreo(email);
            if (referencia != null) {
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
                CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
                caso.Origin = 'Email';
                caso.Subject = email.Subject;
                caso.Description = body.left(32000);
                caso.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_Formulario_Terminal_Financiero' LIMIT 1].Id;
                caso.CC_MailTelfNotif__c = email.fromAddress;
                caso.CC_Tipo_Cliente__c = null;
                caso.CC_Canal_Procedencia__c = 'Oficina Feedback';
                caso.Status = 'Activo';
                caso.CC_Idioma__c = 'es';
                
                String campoEmail = '';
                //String campoIDFAQ;

                String campoUrlFAQ; 
                List<CC_FAQ__c> faq = new List<CC_FAQ__c>();
                
                if (body.contains('Dinos que error has encontrado')) {
                    campoEmail = body.substringBetween('E-mail Empleado:', '\n').deleteWhitespace();
                } else if (body.contains('quin error has trobat a la FAQ')) {
                    caso.CC_Idioma__c = 'ca';
                    campoEmail = body.substringBetween('E-mail Empleat:', '\n').deleteWhitespace();
                }
           
                //campoIDFAQ = body.substringBetween('ID FAQ:', '\n').deleteWhitespace();
                List <CC_Settings__c> urlFAQ = [SELECT Name, CC_Configuracion_1__c FROM CC_Settings__c WHERE Name = 'CC_UrlFAQ' AND CC_Activa__c = true LIMIT 1];
                if(!urlFAQ.isEmpty()){
                    campoUrlFAQ = urlFAQ[0].CC_Configuracion_1__c + body.substringBetween('ID FAQ:', '\n').deleteWhitespace();
                } else{
                    CBK_Log.debug('No se ha encontrado la URL');
                }
                //Identificación del cliente si hay una sola cuenta y contacto con el email remitente
                Id accountId = null;
                Id contactId = null;
                Id recordTypeContacto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
                List<Contact> contacto = [SELECT id, FirstName, AccountId FROM Contact where Email = :campoEmail AND RecordTypeId = :recordTypeContacto AND CC_Inactivo__c = FALSE];
                if(!contacto.isEmpty()) {
                    accountId = contacto[0].AccountId;
                    contactId = contacto[0].Id;
                }
               /*
                if(campoIDFAQ != '') {
                    faq = [SELECT Id FROM CC_FAQ__c WHERE CC_FAQ_Ident__c = :campoIDFAQ AND CC_Activo__c = TRUE LIMIT 1];
                } else {
                    CBK_Log.ResultWrapper noFAQ = new CBK_Log.ResultWrapper();
                    noFAQ.Status = 'KO';
                    noFAQ.Detail = 'Falta FAQ en formulario';
                    noFAQ.CaseId = crearEmailMessage.RelatedToId;
                    noFAQ.EmailMessageId = crearEmailMessage.Id;
                    CBK_Log.auditemailResult(noFAQ, email);
                }*/
                Boolean crearCaseExtension = false;
                /*
                if (!faq.isEmpty()) {
                    //caso.CC_FAQ__c = faq[0].Id;                   
                    caseExtension.CC_FAQ__c = faq[0].Id;                    
                    insert caseExtension;
                    caso.CBK_Case_Extension_Id__c = caseExtension.Id;                                    
                    
                } else {
                    CBK_Log.ResultWrapper noFAQ = new CBK_Log.ResultWrapper();
                    noFAQ.Status = 'KO';
                    noFAQ.Detail = 'No encuentra FAQ';
                    noFAQ.CaseId = crearEmailMessage.RelatedToId;
                    noFAQ.EmailMessageId = crearEmailMessage.Id;
                    CBK_Log.auditemailResult(noFAQ, email);
                }*/

                caso.AccountId = accountId;
                caso.ContactId = contactId;
                caso.CC_Oficina__c = accountId;
                caso.CC_URL_FAQ__c  = campoUrlFAQ;
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
                
                String numeroCaso = [SELECT CaseNumber FROM Case WHERE Id = :caso.Id LIMIT 1 ].CaseNumber;
                //Envío de respuesta automatica Oficina Feedback
                respuestaAutomaticaOficinaFeedback(campoEmail, caso.CC_Idioma__c, numeroCaso, String.valueOf(caso.Id), email.toAddresses);
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
    
    @future
    public static void respuestaAutomaticaOficinaFeedback(String email, String idioma, String numeroCaso, String idCaso, List<String> buzonSalida) {
        String query = 'SELECT Id, HtmlValue, Subject, DeveloperName FROM EmailTemplate WHERE Developername = ';
        if (idioma == 'ca') {
            query+= '\'CC_Feedback_Reportar_Problema_FAQ_CAT\'';
        } else {
            query+= '\'CC_Feedback_Reportar_Problema_FAQ_CAS\'';
        }
        List<EmailTemplate> listaPlantillas = Database.query(query);
        EmailTemplate plantilla = listaPlantillas.get(0);
        String textoCuerpo = plantilla.HtmlValue;
        
        Task tareaEnvioAutomatico =  new Task();
        tareaEnvioAutomatico.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        tareaEnvioAutomatico.WhatId = idCaso;
        tareaEnvioAutomatico.Type = 'Responder a cliente';
        tareaEnvioAutomatico.Subject = 'Respuesta automatica Oficina Feedback';
        tareaEnvioAutomatico.Status = 'Completed';
        tareaEnvioAutomatico.ActivityDate = System.today();
        tareaEnvioAutomatico.Description = 'Respuesta automatica Oficina Feedback';
        insert tareaEnvioAutomatico;
        
        List<Messaging.SingleEmailMessage> correosInsertar = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
        CC_Settings__c values = CC_Settings__c.getValues('CC_EmailAtencionEmpleadosCaixa');

        //correo.setOrgWideEmailAddressId([SELECT Id, displayname, Address FROM OrgWideEmailAddress WHERE displayname = 'Correo Pruebas CC' LIMIT 1].Id);
        //correo.setOrgWideEmailAddressId([SELECT Id, displayname, Address FROM OrgWideEmailAddress WHERE displayname = 'Atención Empleados CaixaBank' LIMIT 1].Id);
        correo.setOrgWideEmailAddressId([SELECT Id, displayname, Address FROM OrgWideEmailAddress WHERE displayname = :values.CC_Configuracion_1__c LIMIT 1].Id);
        correo.setToAddresses(new List<String>{email});
        correo.setTreatBodiesAsTemplate(true);
        correo.setSubject(plantilla.Subject);
        correo.setHtmlBody(textoCuerpo);
        correo.setTreatTargetObjectAsRecipient(false);
        correo.setWhatId(idCaso);
        correo.setSaveAsActivity(true);
        correosInsertar.add(correo);
        
        List<Messaging.SendEmailResult> resultadoEnvio = Messaging.sendEmail(correosInsertar);
        for (Messaging.SendEmailResult result : resultadoEnvio) {
            if (!result.success) {
                CBK_Log.debug('No se pudo enviar el correo: ' + result.errors[0].message);
            } 
        }
    }
}