public with sharing class CC_Formulario_Consultas_Operativas implements Messaging.InboundEmailHandler {
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
                String rtEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
                //El correo ha llegado sin referencia o ésta no apunta a ninguna tarea o la procedencia del caso no coincide con la procedencia de email entrante --> Se crea nuevo caso
                Case caso = new Case();
                caso.RecordTypeId = rtEmpleado;
                caso.Origin = 'Email';
                caso.Subject = email.Subject;
                caso.Description = body.left(32000); 
                caso.CC_Tipo_Cliente__c = null;
                caso.Status = 'Activo';
                caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
                
                String campoEmail = '';
                String campoTematica = '';
                String campoDetalleConsulta = '';
                String campoMatricula = '';
                String campoIdCognitivo = '';
                boolean idiomaEs = true;
                
                if (body.contains('Nombre empleado')) {
                    
                    caso.CC_Idioma__c = 'es';
                    campoIdCognitivo = body.substringBetween('Cognitive id:', '\n').deleteWhitespace();
                    campoMatricula = body.substringBetween('U01:', '\n').deleteWhitespace();
                    campoEmail = body.substringBetween('Email empleado:', '\n').deleteWhitespace();
                    campoTematica = body.substringBetween('Selecciona la temática:', '\n').trim();
                    campoDetalleConsulta = body.substringBetween('Detalla tu consulta:', '\n').trim();
                    
                } else if (body.contains('Nom empleat')) {
                    
                    idiomaEs = false;
                    caso.CC_Idioma__c = 'ca';
                    campoIdCognitivo = body.substringBetween('Cognitive id:', '\n').deleteWhitespace();
                    campoMatricula = body.substringBetween('U01:', '\n').deleteWhitespace();
                    campoEmail = body.substringBetween('Email empleat:', '\n').deleteWhitespace();
                    campoTematica = body.substringBetween('Selecciona la temàtica:', '\n').trim();
                    campoDetalleConsulta = body.substringAfter('Detalla la teva consulta:').trim();
                }
                
                caso.CC_Detalles_Consulta__c = campoDetalleConsulta;

                List<Case> casoCognitivo;
                if (!String.isEmpty(campoIdCognitivo)) {
                    casoCognitivo = [SELECT Id FROM Case WHERE CC_Id_Cognitivo__c = :campoIdCognitivo AND RecordTypeId = :rtEmpleado AND CreatedDate = LAST_N_DAYS:1 AND Origin = 'Chat' ORDER BY CreatedDate DESC LIMIT 1];
                    if (!casoCognitivo.isEmpty()) {
                        caso.CC_CasoRelacionado__c = casoCognitivo[0].Id;
                    }
                }
                //caso.CC_Id_Cognitivo__c = campoIdCognitivo;
                
                //Comprobamos el Custom Setting para identificar los datos del caso y los asignamos
                Map<String,CC_Parametrizaciones_Consultas_Operativa__c> obtenidos = obtenerParametros();
                String cola = obtenidos.get(campoTematica).CC_Cola__c;
                
                caso.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName  = :cola LIMIT 1].Id; 
                caso.CC_Canal_Resolucion__c = obtenidos.get(campoTematica).CC_Canal_resolucion__c;
                
                
                //Identificación del cliente si hay una sola cuenta y contacto con el email remitente
                Id accountId = null;
                Id contactId = null;
                
                Id recordTypeContacto  = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
                List<Contact> contacto = [SELECT id, FirstName, AccountId FROM Contact WHERE CC_Matricula__c = :campoMatricula AND RecordTypeId = :recordTypeContacto AND CC_Inactivo__c = false];
                if(!contacto.isEmpty()){
                    accountId = contacto[0].AccountId;
                    contactId = contacto[0].Id;
                }
                caso.CC_MailTelfNotif__c = campoEmail;
                
                caso.AccountId = accountId;
                caso.ContactId = contactId;
                caso.CC_Oficina__c = accountId;
                caso.CC_Oficina_Afectada_Lookup__c = accountId; 
                insert caso;

                if (!casoCognitivo.isEmpty()) {
                    casoCognitivo[0].CC_CasoRelacionado__c = caso.Id;
                    upsert casoCognitivo;
                }
                
                result.success = true;
                
                if (!contacto.isEmpty()){
                    emailAutomaticoConsultaOperativa (idiomaEs, caso.Id, contactId, campoEmail);
                }
                
                List<Id> listaContentVersionIdEmail = new List<Id>();
                String nuevoHtmlBody = email.htmlBody;
                if (!String.isBlank(nuevoHtmlBody) && nuevoHtmlBody.length() > 131072) {
                    nuevoHtmlBody = nuevoHtmlBody.left(131072);
                }
                crearEmailMessage = crearEmailMessage(email,emailDestino ,caso.id,null,body, nuevoHtmlBody);
                
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
    
    public static Map<String,CC_Parametrizaciones_Consultas_Operativa__c> obtenerParametros (){
        Map<String,CC_Parametrizaciones_Consultas_Operativa__c> mapaPrametrizaciones = new  Map<String,CC_Parametrizaciones_Consultas_Operativa__c>();
        List<CC_Parametrizaciones_Consultas_Operativa__c> colasConsultas = CC_Parametrizaciones_Consultas_Operativa__c.getall().values();
        if (!colasConsultas.isEmpty()) {
            for (CC_Parametrizaciones_Consultas_Operativa__c parametrizacion : colasConsultas) {
                mapaPrametrizaciones.put(parametrizacion.CC_Tematica__c, parametrizacion);
                mapaPrametrizaciones.put(parametrizacion.CC_Tematica_CAT__c, parametrizacion);
            }
        }
        return mapaPrametrizaciones;
    }
    
    private void emailAutomaticoConsultaOperativa (boolean idiomaEs, Id casoId, Id contactId, String correoContact){
        EmailTemplate plantilla = new EmailTemplate ();
        String idioma = '';
        
        if (idiomaEs){
            plantilla = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_ConsultasOperativasCanalFormulario_Entrada_CAS' LIMIT 1];
            idioma = 'Castellano';
        }
        else{
            plantilla = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_ConsultasOperativasCanalFormulario_Entrada_CAT' LIMIT 1];
            idioma = 'Català';
            
        }
        
        
        //recuperamos del caso la dirección de correo
        List<CC_Buzones_Por_Defecto__mdt> buzonDefault = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
        WHERE CC_Canal_Procedencia__c = 'Formulario Consultas Operativas' AND CC_Idioma__c = :idioma AND CC_Activo__c = true];
        
        if (buzonDefault.isEmpty()){
            buzonDefault  = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
            WHERE DeveloperName = 'CC_Buzon_Defecto_Empleados' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true];
        }
        
        if (!buzonDefault.isEmpty()){
            List<OrgWideEmailAddress> owa = new List<OrgWideEmailAddress>();
            /*if (Test.isRunningTest()) { 
                owa = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName like 'Atención%' LIMIT 1];            
            } else {*/
                owa = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :buzonDefault[0].CC_Direccion_Correo__c];
                //}
                if (!owa.isEmpty()){
                    List<Messaging.SingleEmailMessage> correosInsertar = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
                    correo.setOrgWideEmailAddressId(owa[0].Id);
                    correo.setToAddresses(new List<String>{correoContact});
                    correo.setTreatBodiesAsTemplate(true);
                    correo.setSubject(plantilla.Subject);
                    correo.setHtmlBody(plantilla.HtmlValue);
                    correo.setTreatTargetObjectAsRecipient(false);
                    correo.setWhatId(casoId);
                    correo.setSaveAsActivity(true);
                    correosInsertar.add(correo);
                    
                    
                    List<Messaging.SendEmailResult> resultadoEnvio = Messaging.sendEmail(correosInsertar);
                    for (Messaging.SendEmailResult result : resultadoEnvio) {
                        if (!result.success) {
                            System.debug('No se pudo enviar el correo: ' + result.errors[0].message);
                        } 
                    }
                }
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