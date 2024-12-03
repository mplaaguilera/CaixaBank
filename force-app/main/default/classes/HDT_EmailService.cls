public with sharing class HDT_EmailService implements Messaging.InboundEmailHandler {
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        // Trazabilidad para registrar la entrada del correo.
        try{
            CBK_Log.auditemail(email,envelope);
        }catch (Exception e){
            // Método sobrecargado para registrar errores en con el objeto Messaging.InboundEmail.
            CBK_Log.error(e,'Error registrando entrada correo',email);
        }
 
        Messaging.InboundEmailResult resultEmailService = new Messaging.InboundEmailresult();
        resultEmailService.success = false;

        String messageId =null;
        String parentMessageId = null;

        try {

            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
            //Miramos si el correo entrante tiene una semilla que coincide con alguna actividad de un caso ya existente
            String referencia = HDT_EmailService_Utils.referenciaCorreo(email);
            string recordTipe = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
            String referenciaLimpia = '';
            referenciaLimpia = calculoReferenciaCorreo(email.htmlBody);
            
            List<Task> tareaOrigen = new List<Task>();
            if (String.isNotBlank(referencia)) {     
                //El correo es una respuesta a un correo saliente previo, se busca dicho correo
                tareaOrigen = [SELECT WhatId, Type FROM Task WHERE RecordTypeId = :recordTipe AND CC_Referencia_Correo_Saliente__c = :referenciaLimpia WITH SECURITY_ENFORCED LIMIT 1];
            }

            if (!tareaOrigen.isEmpty()) {
                if (tareaOrigen[0].Type == 'Traslado Colaborador') {     

                    //Respuesta entrante de grupo colaborador
                    EmailMessage emailmessage = HDT_EmailService_Utils.respuestaTrasladoColaborador(email, tareaOrigen[0].WhatId, envelope.toAddress);
                    messageId = emailmessage.id;
                    parentMessageId = emailmessage.ParentId;

                } else if (tareaOrigen[0].Type == 'Solicitud Información') {    

                    //Respuesta entrante de solicitud de información de cliente
                    EmailMessage emailmessage = HDT_EmailService_Utils.respuestaSolicitudInfo(email, tareaOrigen[0].WhatId, email.plainTextBody, envelope.toAddress);
                    messageId = emailmessage.id;
                    parentMessageId = emailmessage.ParentId;

                } else if (tareaOrigen[0].Type == 'Remitir Colaborador') {
                    //Respuesta entrante de remisión del caso a grupo colaborador
                    EmailMessage emailmessage = HDT_EmailService_Utils.respuestaRemitirColaborador(email, tareaOrigen[0].WhatId, envelope.toAddress);
                    messageId = emailmessage.id;
                    parentMessageId = emailmessage.ParentId;

                } else{
					//Respuesta genérica
                    EmailMessage emailmessage = HDT_EmailService_Utils.respuestaGenerica(email, tareaOrigen[0].WhatId, envelope.toAddress, tareaOrigen[0]);
                    messageId = emailmessage.id;
                    parentMessageId = emailmessage.ParentId;
                }
            } else {
                //El correo ha llegado sin referencia o ésta no apunta a ninguna tarea, se crea nuevo caso
                //Identificación del cliente si hay una sola cuenta y contacto con el email remitente
                Id accountId = null;
                Id contactId = null;

                Map<Account, List<Contact>> mapaCuentasContactos = HDT_Identificacion_Auto.identificarCliente('Email', email.fromAddress); // Duplicamos "OS_Identificacion_Auto" para CAM para incluir colaboradores
                //El formato del resultado de la identificación automática es <Account, List<Contact>>

                if (mapaCuentasContactos.size() == 1 && mapaCuentasContactos.values()[0].size() == 1) {
                    Contact contactoIdentificado = mapaCuentasContactos.values()[0][0];
                    accountId = contactoIdentificado.AccountId;
                    contactId = contactoIdentificado.Id;
                }

                String canalProcedencia = ''; 
                //String canalProcedencia = 'Oficina Feedback';   //Tenemos que preguntar si este es el canal de procedencia que se va a registrar

                //Creación de Caso
                Map<String, Object> campos = new Map<String, Object>();
                campos.put('Origin', 'Email - Revisar');
                campos.put('Subject', email.Subject);
                campos.put('Description', String.isNotBlank(email.plainTextBody) ? email.plainTextBody.left(32000) : email.htmlBody.stripHtmlTags().left(32000));
                campos.put('AccountId', accountId);
                campos.put('ContactId', contactId);
                campos.put('CC_MailTelfNotif__c', email.fromAddress);
                campos.put('CC_Canal_Procedencia__c', canalProcedencia);

                List<HDT_Correos_Buzones_Entrada__mdt> correoDependencia = [SELECT HDT_Email_Redireccion_Buzon__c, HDT_Cola_Procedencia__c, HDT_Canal_Procedencia__c, HDT_RecordType_DeveloperName_defecto__c
                                                                                FROM HDT_Correos_Buzones_Entrada__mdt WHERE HDT_Email_Redireccion_Buzon__c = :envelope.toAddress WITH SECURITY_ENFORCED LIMIT 1];
                if (!correoDependencia.isEmpty()) {
                    
                    canalProcedencia = correoDependencia[0].HDT_Canal_Procedencia__c;
                    List<Group> colas = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :correoDependencia[0].HDT_Cola_Procedencia__c WITH SECURITY_ENFORCED];
                    if (!colas.isEmpty()) {
                        
                        campos.put('OwnerId', colas[0].Id);
                    }
                }

                Case caso = HDT_Case.crearCaso('HDT_Empleado', campos);
                HDT_EmailService_Utils.gestionAdjuntos(email, caso, envelope.toAddress);
                result.success = true;
            }

            result.success = true;

            // Retornamos los valores del Email
            CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
            wResult.Status = 'OK';
            wResult.Detail = 'Envio correcto';
            wResult.CaseId = parentMessageId;
            wResult.EmailMessageId = messageId;
            CBK_Log.auditemailResult(wResult, email);

            return result;

        } catch (Exception e) {
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

    public static String calculoReferenciaCorreo (String cuerpoCorreo){
        
        String referencia = cuerpoCorreo.substringBetween('#@', '#');
        
        if(referencia != null && referencia != ''){
            referencia = (referencia).replaceAll('[^a-zA-Z0-9\\s+]', '');
        }      
        return referencia;

    }

    // Creado por Moises Cano para la recogida de los logs
    public static EmailMessage crearEmailMessage(Messaging.InboundEmail email, String toAddress, Id idCaso, Id contactId, String nuevoHtmlBody) {
    
            Task tarea = new Task();
            tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
            tarea.Type = 'Correo - Entrada';
            tarea.TaskSubtype = 'Email';
            tarea.Subject = email.subject.left(255);
            tarea.ActivityDate = System.today();
            tarea.Status = 'Completed';
            //tarea.Description = body.left(32000);
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
    
            //Trazabilidad Emailservice petición coe
            correo.MessageIdentifier = email.messageId;
            correo.CBK_sfdcMessageId__c = email.messageId?.left(255);
            correo.ThreadIdentifier = email.inReplyTo;
    
            if (String.isNotBlank(nuevoHtmlBody)) {
                correo.HtmlBody = nuevoHtmlBody.left(131072);
            } else if (String.isNotBlank(email.HtmlBody)) {
                correo.HtmlBody = email.HtmlBody.left(131072);
            } 
            
            correo.Incoming = true;
            correo.MessageDate = Datetime.now();
            correo.ParentId = idCaso;
    
            if (!Test.isRunningTest()) {
                if (email.toAddresses != null) { //Para solucionar el error del undisclosed recipients
                    correo.ToAddress = string.join(email.toAddresses, ',');
                }
            } else {
                correo.ToAddress = toAddress;
            }
            insert correo; 
            return correo;
    }
    // Fin
}