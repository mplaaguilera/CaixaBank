public with sharing class GRR_EmailService_Utils {

    /**
	 * Lectura del email para encontrar código de referencia si ya existiera una correspondencia abierta.
	 * @param email  email enviado
	 */
    public static String referenciaCorreo(Messaging.InboundEmail email) {
        //La referencia se envía entre estos los literales '#@' y '#' en los correos salientes.ApexPages
        String referencia = null;
        if (email.plainTextBody != null) {
            referencia = email.plainTextBody.substringBetween('#@', '#');
        }
        //En ocasiones el campo TextBody (sin formato) viene vacío, se busca en el campo HtmlBody
        if (referencia == null && email.HtmlBody != null) {
            referencia = email.HtmlBody.substringBetween('#@', '#');
        }
        return referencia;
    }

    /**
	 * Crear los ficheros adjuntos.
	 * @param email  email enviado
     * @param caso  caso creado relacionado al email
     * @param body  texto
     * @param emailDestino  buzón de caixabank
	 */
    public static void gestionAdjuntos(Messaging.InboundEmail email, Case caso, String emailDestino) {

        String htmlBody = '';
        if (String.isNotBlank(email.htmlBody)) {
            htmlBody = email.htmlBody.left(32000);
        }

        //Adjuntos del email se convierten en Files asociados al caso
        List<Id> listaContentVersionIdEmail = new List<Id>();
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        List<ContentDocumentLink> lstConentDocument = new List<ContentDocumentLink>();
        Set<Id> setIdContent = new Set<Id>();

        if (email.textAttachments != null) {
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.ContentLocation = 'S';
                contentVersion.PathOnClient = tAttachment.fileName;
                contentVersion.Origin = 'H';
                contentVersion.Title = tAttachment.fileName;
                contentVersion.VersionData = Blob.valueOf(tAttachment.body);
                lstContentVersion.add(contentVersion);
                
            }
        }

        if(!lstContentVersion.isEmpty()){
            if (!Schema.sObjectType.ContentVersion.fields.Title.isCreateable()) {
                return;
            }
            Database.insert(lstContentVersion);
            

            for(ContentVersion contentVersion :lstContentVersion){
                setIdContent.add(contentVersion.Id);
                listaContentVersionIdEmail.add(contentVersion.Id);//Aquí
            }

            if(!setIdContent.isEmpty()){
                List<ContentVersion> listContent = [SELECT ContentDocumentId FROM ContentVersion WHERE Id in :setIdContent WITH SECURITY_ENFORCED];
                for(ContentVersion contentVer  : listContent){
                    ContentDocumentLink contentDocument = new ContentDocumentLink(LinkedEntityId = caso.Id, ContentDocumentId = contentVer.ContentDocumentId, ShareType = 'I');
                    lstConentDocument.add(contentDocument);
                }
            }
        }

        if (!lstConentDocument.isEmpty()){
            if (!Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable()) {
                return;
            }
            Database.insert(lstConentDocument);
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

            htmlBody = prepararImagenesInline(htmlBody, listaContentVersion);

            //Recuperar ContentDocumentId de los registros Content Version insertados
            List<Id> listaContentVersionId = new List<Id>();
            for (ContentVersion cver : listaContentVersion) {
                listaContentVersionId.add(cver.Id);
                listaContentVersionIdEmail.add(cver.Id);
            }
            listaContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :listaContentVersionId WITH SECURITY_ENFORCED];

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
        EmailMessage emailMessage = GRR_EmailMessage.crearEmailMessage(email, emailDestino, caso.Id, caso.ContactId, htmlBody);

        //Cuando entra un email (el cliente/colaborador) ha contestado, creamos una tarea para registrar la entrada de este email
        Map<String, Object> camposTarea = new Map<String, Object>();
        camposTarea.put('Type', 'Correo - Entrada');
        camposTarea.put('TaskSubtype', 'Email');
        camposTarea.put('Subject', email.subject);
        camposTarea.put('ActivityDate', System.today());
        camposTarea.put('Status', 'Completed');
        camposTarea.put('WhatId', caso.Id);
        camposTarea.put('WhoId', caso.ContactId);

        if (String.isNotBlank(email.plainTextBody)) {
            camposTarea.put('Description', email.plainTextBody.left(32000));
        } else if (String.isNotBlank(email.htmlBody)) {
            camposTarea.put('Description', email.htmlBody.stripHtmlTags().left(32000));
        }

        GRR_Activity.crearlstTareas(new List<Task>{GRR_Activity.crearTarea('GRR_Task', camposTarea)});

        //Insertar registros ContentDocumentLink asociados al email
        List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
        list<ContentVersion> listaContentVersionEmail = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :listaContentVersionIdEmail WITH SECURITY_ENFORCED];
        for (ContentVersion cv : listaContentVersionEmail) {
            ContentDocumentLink cdLink = new ContentDocumentLink();
            cdLink.LinkedEntityId = emailMessage.Id;
            cdLink.ContentDocumentId = cv.ContentDocumentId;
            cdLink.ShareType = 'V';
            listaContentDocumentLink.add(cdLink);
        }
        insert listaContentDocumentLink;
    }

    /**
	 * Lectura de las imagenes adjuntas.
	 * @param email  email enviado
     * @param listaContentVersion  archivo creado
	 */
    private static String prepararImagenesInline(String htmlBody, List<ContentVersion> listaContentVersion) {
        //Para imágenes, se modifica el tag <image> para que apunte al nuevo registro de ContentVersion:
        if (String.isNotBlank(htmlBody)) {
            for (ContentVersion cv : listaContentVersion) {
                if (cv.ExternalDocumentInfo1 !=null) {
                    //Se actualiza el HTMLBody
                    //Ejemplo de URL: https://caixabankcc--devcops--c.documentforce.com/sfc/servlet.shepherd/version/download/0681X000001Fg9kQAC
                    try {
                        htmlBody = htmlBody.replaceAll('cid:' + cv.ExternalDocumentInfo1, '/sfc/servlet.shepherd/version/download/' + cv.Id);
                    } catch(DmlException e) {
                        CBK_Log.error(e);
                    }
                }
            }
        }
        return htmlBody;
    }

    public static void respuestaTrasladoColaborador(Messaging.InboundEmail email, Id whatIdTarea, String emailDestino) {
        Case caso = [SELECT Status, ContactId, IsClosed FROM Case WHERE Id = :whatIdTarea WITH SECURITY_ENFORCED];

        if (caso.IsClosed) {
            caso = GRR_Case.reapertura(caso.Id, 'Reapertura automática por respuesta de correo', false, false);
        } else if (caso.Status == 'Pendiente Cliente' || caso.Status == 'Pendiente Colaborador') {
            caso.CC_Ultima_Interaccion__c = 'Respuesta de colaborador';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();
            caso.Status = 'Activo';
           
            update caso;
        }

        gestionAdjuntos(email, caso, emailDestino);

        //Cierre de la actividad de traslado a colaborador
        GRR_Activity.finalizarActividadCaso(whatIdTarea, 'Traslado Colaborador', null, null);
    }

    public static void respuestaRemitirColaborador(Messaging.InboundEmail email, Id whatIdTarea, String emailDestino) {
        Case caso = [SELECT Status, ContactId, IsClosed FROM Case WHERE Id = :whatIdTarea WITH SECURITY_ENFORCED];
        
        if (caso.IsClosed) {
            caso = GRR_Case.reapertura(caso.Id, 'Reapertura automática por respuesta de correo', false, false);
        } else if (caso.Status == 'Pendiente Cliente' || caso.Status == 'Pendiente Colaborador') {
            caso.Status = 'Activo';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();
            update caso;
        }

        gestionAdjuntos(email, caso, emailDestino);

        //Cierre de la actividad de envío del traslado a grupo colaborador
        GRR_Activity.finalizarActividadCaso(whatIdTarea, 'Remitir Colaborador', null, null);
    }

    public static void respuestaResponderCliente(Messaging.InboundEmail email, Id whatIdTarea, String emailDestino) {
        Case caso = [SELECT RecordTypeId, Status, CC_Numero_Documento__c, CC_Idioma__c, AccountId, ContactId, CC_Canal_Procedencia__c, IsClosed 
                        FROM Case WHERE Id = :whatIdTarea WITH SECURITY_ENFORCED];

        if (caso.IsClosed) {
            caso = GRR_Case.reapertura(caso.Id, 'Reapertura automática por respuesta de correo', false, false);
        } else if (caso.Status == 'Pendiente Cliente' || caso.Status == 'Pendiente Colaborador') {
            caso.CC_Ultima_Interaccion__c = 'Respuesta de cliente';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();
            caso.Status = 'Activo';

            update caso;
        }
        
        //Gestión adjuntos
        gestionAdjuntos(email, caso, emailDestino);

        GRR_Activity.finalizarActividadCaso(whatIdTarea, 'Responder a cliente', null, null);
    }

     public static void respuestaSolicitudInfo(Messaging.InboundEmail email, Id whatIdTarea, String emailDestino) {
        Case caso = [SELECT Id, Status, CC_Canal_Procedencia__c, ContactId, CC_Situacion_Caso__c, IsClosed
                        FROM Case WHERE Id = :whatIdTarea WITH SECURITY_ENFORCED];

        if (caso.IsClosed) {
            caso = GRR_Case.reapertura(caso.Id, 'Reapertura automática por respuesta de correo', false, false);
        } else if (caso.Status == 'Pendiente Cliente' || caso.Status == 'Pendiente Colaborador') {
            caso.Status = 'Activo';
            caso.CC_Ultima_Interaccion__c = 'Respuesta de solicitud de información';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();

            update caso;
        }

        //Gestión adjuntos
        gestionAdjuntos(email, caso, emailDestino);

        //Cierre de la actividad de Solicitud Información
        GRR_Activity.finalizarActividadCaso(whatIdTarea, 'Solicitud Información', null, null);
    }

    public static void respuestaGenerica(Messaging.InboundEmail email, Id whatIdTarea, String emailDestino, Task tareaOrigen) {
        //Encontramos caso según whatId de la tarea
        Case caso = [SELECT ContactId, Status, CC_Canal_Procedencia__c FROM Case WHERE Id = :whatIdTarea WITH SECURITY_ENFORCED];

        //Gestión adjuntos
        gestionAdjuntos(email, caso, emailDestino);

        //Cierre de la actividad
        GRR_Activity.finalizarActividadesCaso(new List<Task>{tareaOrigen}, null);
    }

}