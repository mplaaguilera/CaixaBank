global with sharing class CC_AC_EmailService implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        // Controlar que nos llega del correo desde el que remite Siebel para que haga todo esto
        // en caso contrario que vaya a la cola de correos entrantes, ver posible afectación o si les pasamos la dirección interna de SFDC.
        EmailMessage crearEmailMessage = new EmailMessage();
        try {
            CBK_log.auditemail(email);
            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();                        
            String myPlainText= '';
            
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
                List<Task> tareaOrigen = [SELECT Id, WhatId, Type FROM Task WHERE CC_Referencia_Correo_Saliente__c = :referencia AND
                (RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task')) LIMIT 1];
                if (!tareaOrigen.isEmpty()) {
                    //Controlar correo de Siebel
                    String emailSiebel = [SELECT Valor_Texto__c FROM CC_Parametros__mdt WHERE Nombre__c = 'Siebel_Email'].Valor_Texto__c;
                    if(!String.isEmpty(emailSiebel) && emailSiebel.equals(emailOrigen)){
                        Case caso = [SELECT Id, Status FROM Case WHERE Id = :tareaOrigen[0].WhatId];
                        if(caso.Status == 'Cerrado'){
                            caso.Status = 'Activo';
                            update caso;
                        }
                    }       
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
                for ( CC_Portal_accionistas__mdt maillst:[Select Email__c ,Portal__c,Idioma__c from CC_Portal_accionistas__mdt LIMIT 100]) {
                    if ((maillst.Email__c==emailOrigen) && (maillst.Portal__c)){               
                        idioma=maillst.Idioma__c;
                    } else if (emailDestino.contains(maillst.Email__c)) {
                        idioma=maillst.Idioma__c;
                    }
                }
                // New Task object to be created
                Case newCase = new Case();
                
                // Preparar el contacto intermedio.
                if (emailOrigen != null){
                    Integer iDelay = 1;
                    Integer iDelayAcuse = 1;
                    List<CC_ConfigNotifCliente__mdt> oConfigContInt;
                    List<CC_ConfigNotifCliente__mdt> oConfigAcuse;
                    if (!Test.isRunningTest()){
                        oConfigContInt = [SELECT Id, CC_DelayMinAcuse__c 
                        FROM CC_ConfigNotifCliente__mdt 
                        WHERE DeveloperName = 'CC_Contacto_Intermedio_AC_ES' AND CC_Proceso__c = 'CC_Contacto_Intermedio_AC' 
                        AND CC_Activa__c = true];
                        oConfigAcuse = [SELECT Id, CC_DelayMinAcuse__c 
                        FROM CC_ConfigNotifCliente__mdt 
                        WHERE DeveloperName = 'CC_AcuseRecibo' AND CC_Proceso__c = 'CC_AcuseRecibo' AND CC_Activa__c = true];
                    } else{
                        CC_ConfigNotifCliente__mdt oAux = new CC_ConfigNotifCliente__mdt();
                        oAux.CC_DelayMinAcuse__c = 0;
                        oConfigContInt = new List<CC_ConfigNotifCliente__mdt>();
                        oConfigAcuse = new List<CC_ConfigNotifCliente__mdt>();
                        oConfigContInt.add(oAux);
                        oConfigAcuse.add(oAux);
                    }
                    if (!oConfigContInt.isEmpty()){
                        if (oConfigContInt[0].CC_DelayMinAcuse__c != null){
                            iDelay = Integer.valueOf(oConfigContInt[0].CC_DelayMinAcuse__c);
                        }
                        if (oConfigAcuse[0].CC_DelayMinAcuse__c != null){
                            iDelayAcuse = Integer.valueOf(oConfigAcuse[0].CC_DelayMinAcuse__c);
                        }
                    }
                    //Delay Contacto Intermedio
                    datetime oDelay = datetime.now();
                    oDelay = oDelay.addMinutes(iDelay);
                    //newCase.CC_Cont_Interm_Delay__c = oDelay;//No queremos contacto intermedio, llegan de Siebel
                    //Delay Acuse
                    datetime oDelayAcuse = datetime.now();
                    oDelayAcuse = oDelayAcuse.addMinutes(iDelayAcuse);
                    //newCase.CC_AcuseDelay__c = oDelayAcuse;//No queremos acuse de recibo, llegan de Siebel
                }
                
                try {
                    newCase.Description = myPlainText.left(32000);
                    String emailSubject = email.Subject;
                    if (emailSubject.length() > 255) {
                        emailSubject = emailSubject.left(255); 
                    }
                    newCase.Subject = emailSubject;
                    newCase.Origin ='Email';
                    newCase.CC_Idioma__c = idioma;
                    newCase.CC_Canal_Procedencia__c = 'Atención al Cliente';
                    newCase.CC_MailTelfNotif__c = emailOrigen;
                    //newCase.CC_AcuseRecibo__c = '1';
                    newCase.CC_SuppliedApp__c = 'AC';
                    //newCase.CC_Fecha_Activo_Formulario__c = CC_SLA_Utils.calculo_Fecha_Activo('Accionistas');
                    try {
                        Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_Inbound_Email_AC' LIMIT 1];
                        newCase.OwnerId = cola.Id;
                    } catch (QueryException e) {
                        System.debug('Falta Cola: ' + e);
                    }
                    insert newCase;
                    
                    // Save attachments, if any
                    List<Id> listaContentVersionIdEmail = new List<Id>();
                    crearEmailMessage = crearEmailMessage(email,emailDestino ,newCase.id,null,myPlainTextOrig);//Contacto.id
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
                        
                        
                        //Crear content document link
                        //crearContentDocumentLink(listaContentVersionId, crearEmailMessage, newCase);   
                        
                        //Insertar registros ContentDocumentLink
                        List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
                        for (ContentVersion cv : listaContentVersion) {
                            //Insertar registros ContentDocumentLink para el caso
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
            Type = 'Correo no identificado'
            ,TaskSubtype = 'Email'
            ,Subject = 'Correo entrante AC' 
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
        } catch (QueryException e) {
            System.debug('Query Issue: ' + e);
        }
        return createEmail;
    }
    
    public static void crearContentDocumentLink(Set<Id> listaContentVersionId, EmailMessage crearEmailMessage, Case caso) {
        List<ContentVersion>listaContentVersionComun = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :listaContentVersionId];
        if(!listaContentVersionComun.isEmpty()) {
            List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
            for (ContentVersion cv : listaContentVersionComun) {
                //Insertar registros ContentDocumentLink para el caso
                ContentDocumentLink cdLinkCaso = new ContentDocumentLink();
                cdLinkCaso.LinkedEntityId = caso.Id;
                cdLinkCaso.ContentDocumentId = cv.ContentDocumentId;
                cdLinkCaso.ShareType = 'I';
                listaContentDocumentLink.add(cdLinkCaso);
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
    
}