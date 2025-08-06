public with sharing class HDT_EmailService_Utils {

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
        EmailMessage emailMessage = HDT_EmailMessage.crearEmailMessage(email, emailDestino, caso.Id, caso.ContactId, htmlBody);

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

        HDT_Activity.crearlstTareas(new List<Task>{HDT_Activity.crearTarea('HDT_Task', camposTarea)});
    
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


    public static Map<String, Object> gestionAdjuntosNew(Messaging.InboundEmail correo, Case caso, String nuevoHtmlBody) {
        Map<String, Object> mapaGestionAdjuntos = new Map<String, Object>();
        Set<Id> listaContentVersionId = new Set<Id>();
        if (correo.textAttachments != null) {
            //Insertar registros Content Version
            List<ContentVersion> listaContentVersion = new List<ContentVersion>();
            for (Messaging.Inboundemail.TextAttachment textAttachment : correo.textAttachments) {
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
            for (ContentVersion cv : listaContentVersion) {
                listaContentVersionId.add(cv.Id);
            }
        }
        if (correo.binaryAttachments != null) {
            List<ContentVersion> listaContentVersion = new List<ContentVersion>();
            Map<String, String> mapaImagenes = new Map<String, String>();
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : correo.binaryAttachments) {
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

            nuevoHtmlBody = OS_EmailService.prepararImagenesInline(correo, listaContentVersion);
            //Recuperar ContentDocumentId de los registros Content Version insertados
            for (ContentVersion cver : listaContentVersion) {
                listaContentVersionId.add(cver.Id);
            }
        } 
        mapaGestionAdjuntos.put('nuevoHtmlBody', nuevoHtmlBody);
        mapaGestionAdjuntos.put('listaContentVersionId', listaContentVersionId);
        
        return mapaGestionAdjuntos;
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

    public static EmailMessage respuestaTrasladoColaborador(Messaging.InboundEmail email, Id whatIdTarea, String emailDestino) {
        Case caso = [SELECT Status, ContactId, IsClosed FROM Case WHERE Id = :whatIdTarea WITH SECURITY_ENFORCED];

        gestionAdjuntos(email, caso, emailDestino);

        caso.CC_Fecha_Ultima_Interaccion__c = System.now();
        caso.CC_Ultima_Interaccion__c = 'Respuesta de colaborador';
        if (caso.IsClosed) {
            caso = HDT_Case.reapertura(caso.Id, 'Reapertura automática por respuesta de correo', false, true);
        } else if (caso.Status == 'Pendiente Colaborador' ) {
            caso.Status = 'Activo';
            //Cierre de la actividad de traslado a colaborador
            HDT_Activity.finalizarActividadCaso(whatIdTarea, 'Traslado Colaborador', null, null);
        }
        update caso;

        // Modificado por Moises Cano - 11-12-2023 para añadir el registro del envio de emails

            String nuevoHtmlBody = email.htmlBody;
            if (!String.isBlank(nuevoHtmlBody) && nuevoHtmlBody.length() > 131072) {
                nuevoHtmlBody = nuevoHtmlBody.left(131072);
            }
            
            //Gestion adjuntos
            Map<String, Object> mapaGestionAdjuntos = gestionAdjuntosNew(email, caso, nuevoHtmlBody);
            nuevoHtmlBody = (String)mapaGestionAdjuntos.get('nuevoHtmlBody');
            Set<Id> listaContentVersionId = (Set<Id>)mapaGestionAdjuntos.get('listaContentVersionId');
            
            //Creamos el mail entrante y lo asociamos al caso
            EmailMessage crearEmailMessage = HDT_EmailService.crearEmailMessage(email, emailDestino, caso.Id, caso.ContactId, nuevoHtmlBody);     
            //Crear content document link
            crearContentDocumentLink(listaContentVersionId, crearEmailMessage, caso);   
            
            //Cierre de la actividad de envío del traslado a grupo colaborador
            CC_Activity.finalizarActividadCaso(whatIdTarea, 'Traslado Colaborador', null, null);

            return crearEmailMessage;

        // Fin
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





    public static EmailMessage respuestaRemitirColaborador(Messaging.InboundEmail email, Id whatIdTarea, String emailDestino) {
        Case caso = [SELECT IsClosed,ClosedDate, Status, ContactId FROM Case WHERE Id = :whatIdTarea WITH SECURITY_ENFORCED];
        if (caso.Status == 'Pendiente Colaborador') {
            
            caso.Status = 'Activo';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();
            update caso;
        }

        String nuevoHtmlBody = email.htmlBody;
        if (!String.isBlank(nuevoHtmlBody) && nuevoHtmlBody.length() > 131072) {
            nuevoHtmlBody = nuevoHtmlBody.left(131072);
        }

        //Gestion adjuntos
        Map<String, Object> mapaGestionAdjuntos = gestionAdjuntosNew(email, caso, nuevoHtmlBody);
        nuevoHtmlBody = (String)mapaGestionAdjuntos.get('nuevoHtmlBody');
        Set<Id> listaContentVersionId = (Set<Id>)mapaGestionAdjuntos.get('listaContentVersionId');
        //Creamos el mail entrante y lo asociamos al caso
        EmailMessage crearEmailMessage = HDT_EmailService.crearEmailMessage(email, emailDestino, caso.Id, caso.ContactId, nuevoHtmlBody);     
        //Crear content document link
        crearContentDocumentLink(listaContentVersionId, crearEmailMessage, caso);
        //gestionAdjuntos(email, caso, emailDestino);

        //Cierre de la actividad de envío del traslado a grupo colaborador
        HDT_Activity.finalizarActividadCaso(whatIdTarea, 'Remitir Colaborador', null, null);

        return crearEmailMessage;
    }

    public static EmailMessage respuestaSolicitudInfo(Messaging.InboundEmail email, Id whatIdTarea, String myPlainText, String emailDestino) {
        
        //Encontramos caso según whatId de la tarea
        Case caso = [SELECT CC_Idioma__c,ContactEmail,IsClosed,ClosedDate,Id, Status, CC_Canal_Procedencia__c, ContactId, CC_Autoasignado_Coordinador__c, CC_Cola_Procedencia__c, CC_Situacion_Caso__c
                        FROM Case WHERE Id = :whatIdTarea];
        
        //Actualizar caso según estado actual
        if (caso.Status == 'Pendiente Cliente' || caso.Status == 'Pendiente Colaborador' || caso.Status == 'Pendiente Interno') { 
            caso.Status = 'Activo';
            caso.OS_Aviso_Propietario__c = true; //para el aviso de nuevos correos.
            caso.CC_Ultima_Interaccion__c = 'Respuesta de solicitud de información';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();

            //Añadimos desde trigger AM_EmailMessage_AI_TRHan.respuestaSolicitudInfo
            caso.CC_Situacion_Caso__c = 'Respuesta cliente';

                //Si la propiedad del caso no está fijada a un coordinador, se devuelve el caso a la cola para
                //que lo pueda atender cualquier agente, no solo el propietario previo a la solicitud
            
            update caso;

        } else if (caso.Status == 'Cerrado') {
            
            if (validarReaperturaCaso(caso)){
                // Aqui tenemos que enviar un email de vuelta a la persona indicandole que no se puede reabrir el caso.
                envioCorreoNoReaperturaCaso(caso);
            }else {
                //Para solicitudes info se reabre el caso aunque se hubiera cerrado
                caso = HDT_Case.reapertura(caso.Id, 'Reapertura automática por respuesta de correo', false, false);
            }
        }

        //Gestión adjuntos
        //AM_Email_GestionAdjuntos.gestionAdjuntos(email, caso, myPlainText, emailDestino);
        gestionAdjuntos(email, caso, emailDestino);

        //Cierre de la actividad de envío del traslado a grupo colaborador
        HDT_Activity.finalizarActividadCaso(whatIdTarea, 'Solicitud Información', null, null);

        String nuevoHtmlBody = email.htmlBody;
        if (!String.isBlank(nuevoHtmlBody) && nuevoHtmlBody.length() > 131072) {
            nuevoHtmlBody = nuevoHtmlBody.left(131072);
        }

        //Gestion adjuntos
        Map<String, Object> mapaGestionAdjuntos = gestionAdjuntosNew(email, caso, emailDestino);
        nuevoHtmlBody = (String)mapaGestionAdjuntos.get('nuevoHtmlBody');
        Set<Id> listaContentVersionId = (Set<Id>)mapaGestionAdjuntos.get('listaContentVersionId');
        //Creamos el mail entrante y lo asociamos al caso
        EmailMessage crearEmailMessage = HDT_EmailService.crearEmailMessage(email, emailDestino, caso.Id, caso.ContactId, nuevoHtmlBody);     
        //Crear content document link
        crearContentDocumentLink(listaContentVersionId, crearEmailMessage, caso);
        return crearEmailMessage;

    }

    public static EmailMessage respuestaGenerica(Messaging.InboundEmail email, Id whatIdTarea, String emailDestino, Task tareaOrigen) {
        //Encontramos caso según whatId de la tareaskf
        Case caso = [SELECT ContactId, Status,CC_Canal_Procedencia__c,IsClosed,ClosedDate,CC_Idioma__c,ContactEmail FROM Case WHERE Id = :whatIdTarea WITH SECURITY_ENFORCED];
    
        //Nueva Funcionalidad pedida
        // No permitir la reapertura del caso si tiene más de 3 dias desde el cierre.
        
        if (caso.Status == 'Cerrado' || caso.Status == 'Rechazado') {
            if (validarReaperturaCaso(caso)){
               
                // Aqui tenemos que enviar un email de vuelta a la persona indicandole que no se puede reabrir el caso.
                envioCorreoNoReaperturaCaso(caso);
            }else {
    
                 //Para solicitudes info se reabre el caso aunque se hubiera cerrado
                caso = HDT_Case.reapertura(caso.Id, 'Reapertura automática por respuesta de correo', false, false);
            }
        }

        String nuevoHtmlBody = email.htmlBody;
            if (!String.isBlank(nuevoHtmlBody) && nuevoHtmlBody.length() > 131072) {
                nuevoHtmlBody = nuevoHtmlBody.left(131072);
            }
        //Gestion adjuntos
        Map<String, Object> mapaGestionAdjuntos = gestionAdjuntosNew(email, caso, nuevoHtmlBody);
        nuevoHtmlBody = (String)mapaGestionAdjuntos.get('nuevoHtmlBody');
        Set<Id> listaContentVersionId = (Set<Id>)mapaGestionAdjuntos.get('listaContentVersionId');

        //Creamos el mail entrante y lo asociamos al caso
        EmailMessage crearEmailMessage = HDT_EmailService.crearEmailMessage(email, emailDestino, caso.Id, caso.ContactId, nuevoHtmlBody);     
        //Crear content document link
        crearContentDocumentLink(listaContentVersionId, crearEmailMessage, caso);   

         //Gestión adjuntos
         //gestionAdjuntos(email, caso, emailDestino);
         //Cierre de la actividad
         HDT_Activity.finalizarActividadesCaso(new List<Task>{tareaOrigen}, null);

         return crearEmailMessage;
    }

    @TestVisible
    public static Boolean validarReaperturaCaso(Case casoRecibido) {
        
        if (casoRecibido != null && casoRecibido.IsClosed && HDT_CaseTriggerHelper.hanPasadoTresDiasDesdeCierre(casoRecibido)) {
            return true;
        }else {
            return false;
        }
    }

    //Envío de correo Acuse de Recibo
    @TestVisible
    public static void envioCorreoNoReaperturaCaso(Case casoRecibido){
        
        List <Case> casosAcuseRecibo = new List <Case>();
        List <Id> contactCasoId = new List <Id>();

        //Id rtTareaHDT = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
        Id rtTareaHDT = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();

        String apiNamePlantillas = 'HDT_Respuesta_Reapertura_Caso_Empleado_%';

        contactCasoId.add(casoRecibido.ContactId);

        //Recogemos las plantillas de correo ordenadas alfabeticamente (0: Catalan, 1: Castellano)
        List <EmailTemplate> plantillas = [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName LIKE : apiNamePlantillas ORDER BY DeveloperName];

        //Recogemos el Custom Setting para obtener las direcciones de correo de respuesta (Configuracion_1 : Castellano, Configuracion_2 : Catalan)
        HDT_Parametros__c emailRespuesta = [SELECT Id, HDT_Configuracion_1__c, HDT_Configuracion_2__c,HDT_Configuracion_3__c FROM HDT_Parametros__c WHERE Name = 'HDT_Email_Respuesta_Empleados_New'];

        //Recogemos los Ids del remitente ordenadas alfabeticamente por la direccion (0: Catalan, 1 Castellano,, 3 Inglés) en el caso de que existan los 3
        List <OrgWideEmailAddress> remitentesId = [SELECT Id FROM OrgWideEmailAddress WHERE Address IN (: emailrespuesta.HDT_Configuracion_1__c, : emailrespuesta.HDT_Configuracion_2__c, : emailrespuesta.HDT_Configuracion_3__c) ORDER BY Address];

        List <Task> taskList = [SELECT Id FROM Task WHERE RecordTypeId = :rtTareaHDT AND WhatId = :casoRecibido.Id AND WhoId IN : contactCasoId];

        //List <Task> taskList = [SELECT Id FROM Task WHERE RecordTypeId = :rtTareaHDT AND Type = 'Respuesta Reapertura Fallida' AND WhatId = :casoRecibido.Id AND WhoId IN : contactCasoId];

        //Preparamos el Email para ser enviado al empleado

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        /*
        if(remitentesId.size() == 2){
            if(casoRecibido.CC_Idioma__c == 'ca'){
                mail.setTemplateId(plantillas[0].Id);
                mail.setOrgWideEmailAddressId(remitentesId[0].Id);
            }else{
                mail.setTemplateId(plantillas[1].Id);
                mail.setOrgWideEmailAddressId(remitentesId[1].Id);
            }
        }else{
            if(casoRecibido.CC_Idioma__c == 'ca'){
                mail.setTemplateId(plantillas[0].Id);
                mail.setOrgWideEmailAddressId(remitentesId[0].Id);
            }else{
                mail.setTemplateId(plantillas[1].Id);
                mail.setOrgWideEmailAddressId(remitentesId[0].Id);
            }
        }*/

    
        if(remitentesId.size() == 3){ // Si hay al menos 3 remitentes
            if(casoRecibido.CC_Idioma__c == 'ca'){
                mail.setTemplateId(plantillas[0].Id);
                mail.setOrgWideEmailAddressId(remitentesId[0].Id);
            } else if(casoRecibido.CC_Idioma__c == 'en'){
                mail.setTemplateId(plantillas[1].Id);
                mail.setOrgWideEmailAddressId(remitentesId[1].Id);
            } else {
                mail.setTemplateId(plantillas[2].Id);
                mail.setOrgWideEmailAddressId(remitentesId[2].Id);
            }
        } else if(remitentesId.size() == 2){ // Si hay 2 remitentes
            if(casoRecibido.CC_Idioma__c == 'ca'){
                mail.setTemplateId(plantillas[0].Id);
                mail.setOrgWideEmailAddressId(remitentesId[0].Id);
            }else if(casoRecibido.CC_Idioma__c == 'en'){
                mail.setTemplateId(plantillas[1].Id);
                mail.setOrgWideEmailAddressId(remitentesId[0].Id);
            }else{
                mail.setTemplateId(plantillas[2].Id);
                mail.setOrgWideEmailAddressId(remitentesId[0].Id);
            }
        } else {
            if(casoRecibido.CC_Idioma__c == 'ca'){
                mail.setTemplateId(plantillas[0].Id);
                mail.setOrgWideEmailAddressId(remitentesId[0].Id);
            }else if(casoRecibido.CC_Idioma__c == 'en'){
                mail.setTemplateId(plantillas[1].Id);
                mail.setOrgWideEmailAddressId(remitentesId[0].Id);
            }else{
                mail.setTemplateId(plantillas[2].Id);
                mail.setOrgWideEmailAddressId(remitentesId[0].Id);
            }
        }

        mail.setSaveAsActivity(true);
        mail.setWhatId(casoRecibido.Id);
        mail.setTargetObjectId(casoRecibido.ContactId);
        mail.setTreatTargetObjectAsRecipient(false);
        String[] toAddresses = new String[] {casoRecibido.ContactEmail};
        mail.setToAddresses(toAddresses);
        allmsg.add(mail);

        try {
            // Enviar el correo electrónico y manejar errores si los hay
            Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg, false);
        } catch (Exception e) {
            CBK_Log.error(e);
        }
        
        // Crear Tarea de que se ha enviado una respuesta al empleado diciendo que no se puede Reactivar Caso
        Task task = new Task();
        task.ActivityDate = System.today();
        task.Subject = 'Acuse de recibo';
        task.Type = 'Respuesta Reapertura Fallida';
        task.Status = 'Completed';
        task.WhatId = casoRecibido.Id;
        task.WhoId = casoRecibido.ContactId;
        HDT_Activity.crearActividad(task);
    }

}