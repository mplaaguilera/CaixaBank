global with sharing class CC_PromoCaixa_Clientes_EmailService implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env) {
        EmailMessage crearEmailMessage = new EmailMessage();
        try {
            CBK_log.auditemail(email);
            // Create an InboundEmailResult object for returning the result of the 
            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
            String myPlainText = '';
            String sTipoNif = '';
            if (string.isNotBlank(email.plainTextBody)) {
                myPlainText = email.plainTextBody;
            } else if (string.isNotBlank(email.htmlBody)) {
                myPlainText = email.htmlBody.stripHtmlTags();
            } 
            myPlainText=myPlainText.left(131072);
            String myPlainTextOrig = myPlainText;
            
            String idioma='';
            String emailOrigen= email.fromAddress;
            String emailDestino= env.toAddress;
            
            //Miramos si el correo entrante tiene una semilla que coincide con alguna actividad de un caso ya existente
            String referencia = CC_Metodos_EmailServices.referenciaCorreo(email);
            if (referencia != null){
                List<Task> tareaOrigen = [SELECT Id, WhatId, Type FROM Task WHERE CC_Referencia_Correo_Saliente__c = :referencia 
                AND (RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task'))  LIMIT 1];
                if (!tareaOrigen.isEmpty()) {
                    if (tareaOrigen[0].Type == 'Traslado Colaborador') {
                        //Respuesta entrante de grupo colaborador
                        CC_Metodos_EmailServices.respuestaTrasladoColaborador(email, tareaOrigen[0].WhatId, myPlainText, emailDestino);
                    } else if (tareaOrigen[0].Type == 'Solicitud Información') {
                        //Respuesta entrante de solicitud de información de cliente
                        CC_Metodos_EmailServices.respuestaSolicitudInfo(email, tareaOrigen[0].WhatId, myPlainText, emailDestino);
                    } else if (tareaOrigen[0].Type == 'Remitir Colaborador') {
                        //Respuesta entrante de remisión del caso a grupo colaborador
                        CC_Metodos_EmailServices.respuestaRemitirColaborador(email, tareaOrigen[0].WhatId, myPlainText, emailDestino);
                    }else if (tareaOrigen[0].Type == 'Responder a cliente') {
                        //Respuesta entrante de respuesta de cliente
                        CC_Metodos_EmailServices.respuestaCliente(email, tareaOrigen[0].WhatId, myPlainText, emailDestino);
                    }
                }
            } else {
                
                  for ( CC_Portal_accionistas__mdt maillst:[Select Email__c ,Portal__c,Idioma__c from CC_Portal_accionistas__mdt  LIMIT 100]) {
                    if ((maillst.Email__c==emailOrigen) && (maillst.Portal__c)){             
                        idioma=maillst.Idioma__c;
                    } else if (emailDestino.contains(maillst.Email__c)) {
                        idioma=maillst.Idioma__c;
                    }
                }
                
                // New Task object to be created
                Case newCase = new Case();
                
                try {
                    Id recordTypeContacto  = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                    List<Contact> contacto = [SELECT id, FirstName, AccountId FROM Contact where Email = :emailOrigen AND (RecordTypeId = :recordTypeContacto OR RecordTypeId = null)  ];
                    Id recordTypePA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
                    List<Account> oCuentaMail = [SELECT id FROM Account where CC_Email__c = :emailOrigen AND RecordTypeId = :recordTypePA  ];
                    if(!oCuentaMail.isEmpty()){
                        newCase.AccountId = oCuentaMail[0].Id;
                    }else if(!contacto.isEmpty()){
                        newCase.AccountId = contacto[0].AccountId;
                        newCase.contactId = contacto[0].Id;
                    }
                    String nif = encontrarNif(myPlainText);
                    sTipoNif = CC_MetodosUtiles.validarCIFNIF(nif);
                    if(!String.isBlank(nif)){
                        if (sTipoNif == 'CIF') {
                            contacto = new List<Contact>();
                            contacto= [SELECT id, FirstName, AccountId FROM Contact where CC_Numero_Documento__c = :nif AND RecordTypeId = :recordTypeContacto  ];
                            if(!contacto.isEmpty()){
                                newCase.AccountId = contacto[0].AccountId;
                                newCase.contactId = contacto[0].Id;
                            }
                        } else {
                            List<Account> oCuentaNif = [SELECT id FROM Account where CC_Numero_Documento__c = :nif AND RecordTypeId = :recordTypePA  ];
                            if(!oCuentaNif.isEmpty()){
                                newCase.AccountId = oCuentaNif[0].Id;
                            }
                        }
                    }
                    newCase.Description =  myPlainText.left(32000);
                    String emailSubject = email.Subject;
                    
                    emailSubject = emailSubject.left(255); 
                    
                    newCase.Subject = emailSubject;
                    newCase.Origin ='Email';
                    newCase.CC_Detalles_Consulta__c= myPlainText;
                    newCase.CC_Tipo_Contacto__c='Consulta';
                    newCase.CC_Canal_Operativo__c='Sin Canal';
                    newCase.CC_Idioma__c = idioma;
                    newCase.CC_En_Tercer_Nivel__c = true;
                    newCase.CC_Canal_Procedencia__c = 'Soporte Clientes CompraEstrella';
                    newCase.CC_MailTelfNotif__c = emailOrigen;
                    newCase.CC_Grupo_3N__c = 'Facilitea_Clientes';
                    //newCase.CC_AcuseRecibo__c = '1';
                    //newCase.CC_Fecha_Activo_Formulario__c = CC_SLA_Utils.calculo_Fecha_Activo('Accionistas');
                    try {
                        Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND developername='CC_Inbound_Email_PromoCaixa_Clientes'  LIMIT 1];
                        newCase.OwnerId=cola.Id;
                    } catch (QueryException e) {
                        System.debug('Falta Cola: ' + e);
                    }
                    
                    if (!Schema.sObjectType.Case.fields.Subject.isCreateable()) {
                        CBK_log.debug('Faltan permisos de inserción sobre el objeto Case.');
                    }
                    
                    insert newCase;
                    
                    // Save attachments, if any
                    List<Id> listaContentVersionIdEmail = new List<Id>();
                    crearEmailMessage = crearEmailMessage(email,emailDestino,newCase.id,null,myPlainTextOrig);
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
                        
                        if (!Schema.sObjectType.ContentVersion.fields.ContentLocation.isCreateable()) {
                            CBK_log.debug('Faltan permisos de inserción sobre el objeto ContentVersion.');
                        }
                        
                        insert listaContentVersion;
                        
                        //Recuperar ContentDocumentId de los registros Content Version insertados
                        List<Id> listaContentVersionId = new List<Id>();
                        for (ContentVersion cv : listaContentVersion) {
                            listaContentVersionId.add(cv.Id);
                            listaContentVersionIdEmail.add(cv.Id);
                        }
                        listaContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :listaContentVersionId  ];
                        
                        //Insertar registros ContentDocumentLink
                        List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
                        for (ContentVersion cv : listaContentVersion) {
                            ContentDocumentLink cdLink = new ContentDocumentLink();
                            cdLink.LinkedEntityId = newCase.Id;
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
                        
                        if (!Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable()) {
                            CBK_log.debug('Faltan permisos de inserción sobre el objeto ContentDocumentLink.');
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
                        listaContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :listaContentVersionId  ];
                        
                        //Insertar registros ContentDocumentLink
                        List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
                        for (ContentVersion cv : listaContentVersion) {
                            ContentDocumentLink cdLink = new ContentDocumentLink();
                            cdLink.LinkedEntityId = newCase.Id;
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
                    
                    //EmailMessage crearEmailMessage = crearEmailMessage(email,emailDestino,newCase.id,null,myPlainTextOrig);
                } catch (QueryException e) {
                    System.debug('Query Issue: ' + e);
                }
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
    public static String encontrarNIF (String text){
        String nif='';
        
        String expresionRegularDni = '[0-9]{8}[A-Z]{1}';
        String expresionRegularCif = '[ABCDEFGHJKLMNPQRSUVW]{1}[0-9]{7}[0-9A-J]{1}';
        String expresionRegularNie = '[XYZ]{1}[0-9]{7,8}[A-Z]{1}';
        Matcher matcherDNI = Pattern.compile(expresionRegularDni).matcher(text);
        Matcher matcherCIF = Pattern.compile(expresionRegularCif).matcher(text);
        Matcher matcherNIE = Pattern.compile(expresionRegularNie).matcher(text);
        if(matcherDNI.find()){
            nif = matcherDNI.group(0);
        } else if(matcherCIF.find()){
            nif = matcherCIF.group(0);
        } else if(matcherNIE.find()){
            nif = matcherNIE.group(0);
        }
        
        return nif;
    }
    
    public static EmailMessage crearEmailMessage(Messaging.inboundEmail email, String emailDestino, Id caseId,Id contactId, String myPlainText){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        EmailMessage createEmail = new EmailMessage();
        try {
            Task createTask = new Task(
            Type = 'Automática'
            ,TaskSubtype   = 'Email'
            ,Subject      = 'Correo entrante Facilitea' 
            ,ActivityDate = System.today()
            ,Status = 'Completed'
            ,Description = myPlainText.left(32000)
            ,WhatId = caseId
            ,WhoId = contactId
            );
            //insert createTask;
            CC_Activity.crearActividad(createTask);
            String emailSubject = email.Subject;
            
            emailSubject = emailSubject.left(3000); 
            
            createEmail.Subject  = emailSubject;
            createEmail.Status = '1';
            if (email.ccAddresses!=null) {
                createEmail.CcAddress = string.join(email.ccAddresses,','); 
            }
            createEmail.FromAddress = email.fromAddress;
            createEmail.FromName = email.fromName;
            createEmail.Headers = JSON.serialize( email.headers );
            //createEmail.HtmlBody = email.htmlBody;
            createEmail.ToAddress = emailDestino;
            createEmail.TextBody = myPlainText;
            createEmail.Incoming = true;
            createEmail.MessageDate = DateTime.now();
            createEmail.ParentId = caseId;
            createEmail.MessageIdentifier = email.messageId;
            createEmail.CBK_sfdcMessageId__c = email.messageId?.left(255);
            createEmail.ThreadIdentifier = email.inReplyTo;
            if (!Schema.sObjectType.EmailMessage.fields.ToAddress.isCreateable()) {
                CBK_log.debug('Faltan permisos de inserción sobre el objeto EmailMessage.');
            }
            insert createEmail; 
           } catch (QueryException e) {
            System.debug('Query Issue: ' + e);
        }
        return createEmail;
    }
    
}