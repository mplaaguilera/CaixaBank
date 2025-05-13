public with sharing class CSBD_EmailService implements Messaging.InboundEmailHandler {

    public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env) {

        String messageId =null;
        String parentMessageId = null;

        try{
            if (!Test.isRunningTest()) {CBK_log.auditemail(email,env);}

            Messaging.InboundEmailResult resultado = new Messaging.InboundEmailResult();
            resultado.success = true;

            Task tareaReferencia = null;
            Opportunity oportunidadReferencia = null;
            
            //Preparar versión en texto plano del cuerpo del correo
            String cuerpoTextoPlano = String.isNotBlank(email.plainTextBody) ? email.plainTextBody : email.htmlBody.stripHtmlTags();
            cuerpoTextoPlano = cuerpoTextoPlano.left(131052);

            //Búsqueda de la oportunidad origen a partir de la referencia del correo
            String referenciaCorreo = cuerpoTextoPlano.substringBetween('#@', '#');
            if (String.isNotBlank(referenciaCorreo)) {
                //El correo es una respuesta
                List<Task> tareasReferencia = [SELECT WhatId, CSBD_Email_Pendiente_Cliente__c FROM Task
                                                WHERE What.Type = 'Opportunity' AND TaskSubtype = 'Email'
                                                AND CC_Referencia_Correo_Saliente__c = :referenciaCorreo LIMIT 1];
                if (!tareasReferencia.isEmpty()) {
                    tareaReferencia = tareasReferencia[0];
                    List<Opportunity> oportunidadesReferencia = [SELECT CSBD_Estado__c, IsClosed, CSBD_Contact__c, CSBD_Referencia_Correo_Saliente__c
                                                                    FROM Opportunity WHERE Id = :tareaReferencia.WhatId];
                    if (!oportunidadesReferencia.isEmpty()) {
                        //Se ha localizado la oportunidad origen
                        oportunidadReferencia = oportunidadesReferencia[0];
                    }
                }
            }
            
            //Creación del EmailMessage
            String nuevoHtmlBody = guardarFiles(oportunidadReferencia, email);
            
            EmailMessage correo = new EmailMessage();
            correo.Headers = JSON.serialize(email.headers);
            correo.Incoming = true;
            correo.CC_Aplicacion__c = 'CSBD';
            correo.MessageDate = Datetime.now();
            correo.Status = '1'; //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
            correo.RelatedToId = oportunidadReferencia != null ? oportunidadReferencia.Id : null;
            correo.CSBD_Oportunidad_Id__c = oportunidadReferencia != null ? oportunidadReferencia.Id : null;
            correo.FromAddress = email.fromAddress;
            correo.FromName = email.fromName;
            correo.Subject  = email.subject;
            correo.HtmlBody = nuevoHtmlBody;
            correo.TextBody = email.plainTextBody;
            if (email.toAddresses != null) {
                correo.ToAddress = String.join(email.toAddresses, ', ');
            }
            if (email.ccAddresses != null) {
                correo.CcAddress = String.join(email.ccAddresses, ', ');
            }
            insert correo;
            
            //Inserción id de email message
            messageId = correo.Id;
            parentMessageId = correo.RelatedToId;

            guardarAttachments(correo.Id, email);

            if (oportunidadReferencia != null) {
                if (oportunidadReferencia.CSBD_Estado__c == 'Pendiente Cliente') {
                    //Se comprueba si el correo entrante es una respuesta al correo que estaba pendiente cliente
                    if ([SELECT Count() FROM Task WHERE WhatId = :oportunidadReferencia.Id
                            AND CSBD_Email_Pendiente_Cliente__c = :tareaReferencia.CSBD_Email_Pendiente_Cliente__c
                            AND Type = 'Pendiente Cliente' AND Status = 'Open'] > 0) {
                        //Restaurar el estado "Activa" de la oportunidad si era "Pendiente Cliente"
                        CSBD_Opportunity.oportunidadFinPendienteCliente(oportunidadReferencia.Id);
                    }
                } else if (oportunidadReferencia?.IsClosed) {
                    //Restaurar el estado "Activa" de la oportunidad si se había cerrado
                    CSBD_Opportunity.reactivarOportunidad(oportunidadReferencia.Id);
                }
            }

            CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
            wResult.Status = 'OK';
            wResult.Detail = 'Envio correcto';
            wResult.CaseId = parentMessageId;
            wResult.EmailMessageId = messageId;
            CBK_Log.auditemailResult(wResult, email);

            return resultado;
        } 
        catch (Exception e){

            CBK_Log.error(e, 'Error en el envio de email', email);

            //Trazabilidad Emailservice y emailmessage COE
            CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
            wResult.Status = 'KO';
            wResult.Detail = e.getMessage()?.left(255);
            wResult.CaseId = parentMessageId;
            wResult.EmailMessageId = messageId;
            CBK_Log.auditemailResult(wResult, email);
            
            return null;
        }
    }

    private static void guardarAttachments(Id idEmailMessage, Messaging.InboundEmail email) {
        List<Attachment> attachments = new List<Attachment>();
        if (email.binaryAttachments != null) {
            for (Messaging.InboundEmail.BinaryAttachment binaryAttachment : email.binaryAttachments) {
                Attachment nuevoAdjuntoBinario = new Attachment();
                nuevoAdjuntoBinario.Name = binaryAttachment.fileName;
                nuevoAdjuntoBinario.Body = binaryAttachment.body;
                nuevoAdjuntoBinario.ParentId = idEmailMessage;
                attachments.add(nuevoAdjuntoBinario);
            }
        }
        if (email.textAttachments != null) {
            for (Messaging.InboundEmail.TextAttachment textAttachment : email.textAttachments) {
                Attachment nuevoAdjuntoTexto = new Attachment();
                nuevoAdjuntoTexto.Name = textAttachment.fileName;
                nuevoAdjuntoTexto.Body = Blob.valueOf(textAttachment?.body);
                nuevoAdjuntoTexto.ParentId = idEmailMessage;
                attachments.add(nuevoAdjuntoTexto);
            }
        }
        insert attachments;
    } 

    private static String guardarFiles(Opportunity oportunidad, Messaging.InboundEmail email) {
        List<Id> listaContentVersionIdEmail = new List<Id>();
        String nuevoHtmlBody = email.htmlBody;
        if (String.isNotBlank(nuevoHtmlBody) && nuevoHtmlBody.length() > 131052) {
            nuevoHtmlBody = nuevoHtmlBody.left(131052);
        }

        if (email.textAttachments != null) {
            //Insertar registros Content Version
            List<ContentVersion> listaContentVersion = new List<ContentVersion>();
            for (Messaging.InboundEmail.TextAttachment textAttachment : email.textAttachments) {
                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S';
                cv.PathOnClient = textAttachment.fileName;
                cv.Origin = 'H';
                cv.Title = textAttachment.fileName;
                cv.VersionData = Blob.valueOf(textAttachment?.body);
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

            if (oportunidad != null) {
                //Vinculación de los files con la oportunidad mediante ContentDocumentLink
                List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
                for (ContentVersion cv : listaContentVersion) {
                    ContentDocumentLink cdLink = new ContentDocumentLink();
                    cdLink.LinkedEntityId = oportunidad.Id;
                    cdLink.ContentDocumentId = cv.ContentDocumentId;
                    cdLink.ShareType = 'I';
                    listaContentDocumentLink.add(cdLink);
                }
                insert listaContentDocumentLink;
            }
        }

        if (email.binaryAttachments != null) {
            //Insertar registros Content Version
            List<ContentVersion> listaContentVersion = new List<ContentVersion>();
            Map<String, String> mapaImagenes = new Map<String, String>();
            for (Messaging.InboundEmail.BinaryAttachment binaryAttachment : email.binaryAttachments) {
                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S';
                cv.PathOnClient = binaryAttachment.fileName;
                cv.Origin = 'H';
                cv.Title = binaryAttachment.fileName;
                cv.VersionData = binaryAttachment?.body;

                //Se almacena el identificador de la imagen para poder realizar un reemplazo posterior
                
                if (binaryAttachment.headers != null && !binaryAttachment.headers.isEmpty()) {
                    for (Integer i = 0; i < binaryAttachment.headers.size(); i++) {
                        if (binaryAttachment.headers[i].name == 'Content-Id') {
                            String headerValue = binaryAttachment.headers[i].value;
                            headerValue = headerValue.replaceAll('<', '').replaceAll('>', '');
                            cv.ExternalDocumentInfo1 = headerValue;
                        }
                    }
                }
                listaContentVersion.add(cv);
            }
            insert listaContentVersion;

            nuevoHtmlBody = prepararImagenesInline(email, listaContentVersion);

            //Recuperar ContentDocumentId de los registros Content Version insertados
            List<Id> listaContentVersionId = new List<Id>();
            for (ContentVersion cv : listaContentVersion) {
                listaContentVersionId.add(cv.Id);
                listaContentVersionIdEmail.add(cv.Id);
            }
            listaContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :listaContentVersionId];

            //Insertar registros ContentDocumentLink
            if (oportunidad != null) { 
                List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
                for (ContentVersion cv : listaContentVersion) {
                    ContentDocumentLink cdLink = new ContentDocumentLink();
                    cdLink.LinkedEntityId = oportunidad.Id;
                    cdLink.ContentDocumentId = cv.ContentDocumentId;
                    cdLink.ShareType = 'I';
                    listaContentDocumentLink.add(cdLink);
                }
                insert listaContentDocumentLink;
            }
        }
        return nuevoHtmlBody;
    }

    private static String prepararImagenesInline(Messaging.InboundEmail email, List<ContentVersion> listaContentVersion) {
        //Para imágenes, se modifica el tag <image> para que apunte al registro de ContentVersion
        String nuevoHtmlBody = email.htmlBody;
        if (String.isNotBlank(nuevoHtmlBody) && nuevoHtmlBody.length() > 131052) {
			nuevoHtmlBody = nuevoHtmlBody.left(131052);
        }

		for (ContentVersion cv : listaContentVersion) {
            if (cv.ExternalDocumentInfo1 != null) {
                try {
                    //Se actualiza el HtmlBody
                    nuevoHtmlBody = nuevoHtmlBody.replaceAll('cid:' + cv.ExternalDocumentInfo1, '/sfc/servlet.shepherd/version/download/' + cv.Id);
                } catch (Exception e) {
                    CBK_Log.error(e);
                }
            }
        }
        return nuevoHtmlBody;
    }
}