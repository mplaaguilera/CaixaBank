public class AM_Email_GestionAdjuntos {
    public static void gestionAdjuntos(Messaging.InboundEmail email, Case caso, String myPlainText, String emailDestino) {

        //Adjuntos del email se convierten en Files asociados al caso
        List<Id> listaContentVersionIdEmail = New List<Id>();

        String nuevoHtmlBody = email.htmlBody;
        if (!String.isBlank(nuevoHtmlBody) && nuevoHtmlBody.length() > 32000) {
            nuevoHtmlBody = nuevoHtmlBody.left(32000);
        } 

        if (email.textAttachments != null) {
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S';
                cv.PathOnClient = tAttachment.fileName;
                cv.Origin = 'H';
                cv.Title = tAttachment.fileName;
                cv.VersionData = Blob.valueOf(tAttachment.body);
                insert cv;

                listaContentVersionIdEmail.add(cv.Id);
                ContentVersion cVers = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
                ContentDocumentLink cl = new ContentDocumentLink(LinkedEntityId = caso.Id, ContentDocumentId = cVers.ContentDocumentId, ShareType = 'I');
                insert cl;
               
                
                
            }
        }

        if (email.binaryAttachments != null) {
            List<ContentVersion> listaContentVersion = new List<ContentVersion>();
            Map<String, String> mapaImagenes = new Map<String, String>();
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S';
                cv.PathOnClient = bAttachment.fileName;
                cv.Origin = 'H';
                cv.Title = bAttachment.fileName;
                cv.VersionData = bAttachment.body;

                //Se almacena el identificador de la imagen para poder realizar un reemplazo posterior
                if (bAttachment.headers != null) {
                    for (Integer i = 0; i < bAttachment.headers.size(); i++) {

                        if (bAttachment.headers[i].name == 'Content-ID') {
                            String headerValue = bAttachment.headers[i].value;
                            headerValue = headerValue.replaceAll('<', '').replaceAll('>', '');
                            cv.ExternalDocumentInfo1=headerValue;
                        }
                    }
                }

                listaContentVersion.add(cv);
            }
            insert listaContentVersion;

            nuevoHtmlBody = prepararImagenesInline(email, listaContentVersion);
            
            //Recuperar ContentDocumentId de los registros Content Version insertados
            List<Id> listaContentVersionId = new List<Id>();
            for (ContentVersion cver : listaContentVersion) {
                listaContentVersionId.add(cver.Id);
                listaContentVersionIdEmail.add(cver.Id);
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
            }
            insert listaContentDocumentLink;
        }

        //Creamos el mail entrante y lo asociamos al caso
        EmailMessage crearEmailMessage = crearEmailMessage(email, emailDestino, caso.Id, caso.ContactId, myPlainText, nuevoHtmlBody);

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
    }

    public static String prepararImagenesInline(Messaging.InboundEmail email, List<ContentVersion> listaContentVersion) {

        //Para imágenes, se modifica el tag <image> para que apunte al nuevo registro de ContentVersion:
        String nuevoHtmlBody = email.htmlBody;
        if (!String.isBlank(nuevoHtmlBody) && nuevoHtmlBody.length() > 32000) {
            nuevoHtmlBody = nuevoHtmlBody.left(32000);
        }

        
        
        /* SE DESHABILITA TRATAMIENTO DE IMAGENES INLINE HASTA TENER SOLUCIÓN BASE64*/

    /*        for (Messaging.Inboundemail.BinaryAttachment binaryAttachment : email.binaryAttachments) {
            if (binaryAttachment.headers != null) {
                for (Integer i = 0; i < binaryAttachment.headers.size(); i++) {
                    if (binaryAttachment.headers[i].value != null) {
                        String headerValue = binaryAttachment.headers[i].value;
                        if (headerValue.startsWith('ii') || headerValue.startsWith('< image') || headerValue.startsWith('image')|| headerValue.startsWith('<img')) {
                            //Se busca el registro de Content Document correspondiente a la imagen
                            headerValue = headerValue.replaceAll('<', '').replaceAll('>', '');
                            for (ContentVersion cv : listaContentVersion) {
                                if (cv.Title == binaryAttachment.fileName) {
                                    //Se actualiza el HTMLBody
                                    //Ejemplo de URL: https://caixabankcc--devcops--c.documentforce.com/sfc/servlet.shepherd/version/download/0681X000001Fg9kQAC
                                    nuevoHtmlBody = nuevoHtmlBody.replaceAll('cid:' + headerValue.substringBetween('.', '.'), '/sfc/servlet.shepherd/version/download/' + cv.Id);
                                }
                            }
                        }
                    }
                }
            }
        }*/
        
        for (ContentVersion cv : listaContentVersion) {
            if (cv.ExternalDocumentInfo1 !=null){
                //Se actualiza el HTMLBody
                //Ejemplo de URL: https://caixabankcc--devcops--c.documentforce.com/sfc/servlet.shepherd/version/download/0681X000001Fg9kQAC
                try {
                    nuevoHtmlBody = nuevoHtmlBody.replaceAll('cid:' + cv.ExternalDocumentInfo1, '/sfc/servlet.shepherd/version/download/' + cv.Id);
                } catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
            }
        }        
        return nuevoHtmlBody;
    }

    public static EmailMessage crearEmailMessage(Messaging.InboundEmail email, String toAddress, Id idCaso, Id contactId, String body, String nuevoHtmlBody) {
       
        //Cuando entra un email (el cliente/colaborador) ha contestado, creamos una tarea para registrar la entrada de este email
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        Task tarea = new Task();
        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task');
        tarea.Type = 'Correo - Entrada';
        tarea.TaskSubtype = 'Email';
        tarea.Subject = email.subject;
        tarea.ActivityDate = System.today();
        tarea.Status = 'Completed';
        tarea.Description = body.left(32000);
        tarea.WhatId = idCaso;
        tarea.WhoId = contactId;
        insert tarea;

        //Creamos un EmailMessage para guardar el correo que acaban de enviar y asociarlo al caso 
        EmailMessage correo = new EmailMessage();
        correo.Subject = email.Subject;
        correo.Status = '1';
        if (email.ccAddresses != null) {
            correo.CcAddress = String.join(email.ccAddresses, ',');
        }
        correo.FromAddress = email.fromAddress;
        correo.FromName = email.fromName;
        correo.Headers = JSON.serialize(email.headers);
        if(String.isBlank(nuevoHtmlBody)){
            String cuerpo = email.htmlBody;           
            if(cuerpo != null){
               
       			correo.HtmlBody = cuerpo.left(32000);
            }else{
                correo.textBody = body.left(32000);
            }              
        }else{
           
            correo.HtmlBody = nuevoHtmlBody.left(32000);                            
        }
        correo.Incoming = true;
        correo.MessageDate = DateTime.now();
        correo.ParentId = idCaso;
        if (!Test.isRunningTest()) {                    
            correo.ToAddress = string.join(email.toAddresses,',');
        } else {
            correo.ToAddress = toAddress;
        }
      
        insert correo;
      
        return correo;
    }
}