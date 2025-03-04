global with sharing class CC_CAU_Bankia_EmailService implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        EmailMessage crearEmailMessage = new EmailMessage();
        try {
            CBK_log.auditemail(email);
            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
            String myPlainText= '';
            
            Contact vContact = new Contact();
            if (string.isNotBlank(email.plainTextBody)) {
                myPlainText = email.plainTextBody;
            } else if (string.isNotBlank(email.htmlBody)) {
                myPlainText = email.htmlBody.stripHtmlTags();
            } 
            myPlainText=myPlainText.left(131072);
            String myPlainTextOrig = myPlainText;
            myPlainText=ajusteMensaje(myPlainText);
            
            Map<String,Map<String,String>> oMapTipificacion = new Map<String,Map<String,String>>();
            String idProblema = '';
            String codProblema = '';
            String descripCodProblema = '';
            String sintomaMensaje = '';
            String descripIncidencia = '';
            String usuarioCaixa = '';
            
            String emailOrigen= email.fromAddress;
            String emailDestino= env.toAddress;
            
            //List<CC_Grupo_Colaborador__c> ListGrupoOficina =  new List<CC_Grupo_Colaborador__c>();
            
            //Miramos si el correo entrante tiene una semilla que coincide con alguna actividad de un caso ya existente
            String referencia = CC_Metodos_EmailServices.referenciaCorreo(email);
            
            if (referencia != null){
                List<Task> tareaOrigen = [SELECT Id, WhatId, Type FROM Task WHERE CC_Referencia_Correo_Saliente__c = :referencia 
                AND (RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task')) LIMIT 1];
                
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
                map<String,String> parseo = new map<String,String>();
                // New Task object to be created
                Case newCase = new Case();
                try {
                    parseo = parseoEmail(myPlainText);
                    
                    idProblema = (parseo.get('idProblema') != null) ? parseo.get('idProblema').trim().removeStart(':').removeEnd(']').trim() : '';
                    codProblema = (parseo.get('codProblema') != null) ? parseo.get('codProblema').trim().removeStart(':').removeEnd(']').trim() : '';
                    descripCodProblema =  (parseo.get('descripCodProblema') != null) ? parseo.get('descripCodProblema').trim().removeStart(':').trim() : '';
                    sintomaMensaje =  (parseo.get('sintomaMensaje') != null) ? parseo.get('sintomaMensaje').trim().removeStart(':').removeEnd(']').trim() : '';
                    descripIncidencia =  (parseo.get('descripIncidencia') != null) ? parseo.get('descripIncidencia').trim().removeStart(':').removeEnd(']').trim() : '';
                    usuarioCaixa =  (parseo.get('usuarioCaixa') != null) ? parseo.get('usuarioCaixa').trim().removeStart(':').removeEnd(']').trim() : '';
                    
                    String bankiaRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
                    newCase.RecordTypeId = bankiaRecordTypeId;
                    
                    
                    String emailSubject = email.Subject;
                    if (emailSubject.length() > 255) {
                        emailSubject = emailSubject.left(255); 
                    }
                    newCase.Subject = emailSubject;
                    newCase.Origin = 'Email';
                    newCase.CC_Idioma__c = 'es';
                    newCase.CC_MailTelfNotif__c = emailOrigen;
                    newCase.SuppliedEmail = emailOrigen;
                    newCase.CC_SuppliedIdioma__c = 'es';
                    
                    //Si se identifica el email como de CAU Bankia
                    if (!idProblema.equals('') && !usuarioCaixa.equals(''))
                    {
                        //Almacenamos el código del problema pasado por CAU Bankia
                        //newCase.CC_Id_CAU_Bankia__c = idProblema;
                        
                        //Búqueda de contacto por U01
                        if (usuarioCaixa!='') {
                            List<Contact> contactList = [SELECT Id, Name, Email,AccountId FROM Contact WHERE CC_Matricula__c = :usuarioCaixa ORDER BY CREATEDDATE DESC];
                            
                            if (!contactList.isEmpty())
                            {
                                vContact = contactList[0];
                            }
                        }
                        
                        if (vContact != null)
                        {
                            newCase.AccountId = vContact.AccountId;
                            newCase.ContactId = vContact.id;
                            newCase.SuppliedName = vContact.Name;
                        }
                        
                        //Completamos los datos del caso
                        //Creamos la descripción del caso: sintomaMensaje - descripIncidencia
                        
                        
                        String caseDescription = (sintomaMensaje != null && descripIncidencia != null) ? (sintomaMensaje + ' - ' + descripIncidencia) : ((descripIncidencia != null) ? descripIncidencia : '');
                        
                        
                        
                        if (caseDescription.length() > 32000) {
                            caseDescription = caseDescription.left(32000); 
                        }
                        newCase.Description = caseDescription;
                        newCase.CC_Detalles_Consulta__c = caseDescription;
                        newCase.CC_Canal_Procedencia__c = 'HDT CSI';
                        newCase.CC_Tipo_Contacto__c = 'Avería';
                        newCase.CC_SuppliedUser__c = usuarioCaixa;
                        
                        //Asignamos a la cola específica para el CAU Bankia
                        try {
                            Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_Cola_correos_entrantes_CSI_Bankia' LIMIT 1];
                            newCase.OwnerId=cola.Id;
                        } catch (QueryException e) {
                            System.debug('Falta Cola: ' + e);
                        }
                    }
                    else 
                    {
                        String caseDescription = myPlainText;
                        if (myPlainText.length() > 32000) {
                            caseDescription = myPlainText.left(32000); 
                        }
                        newCase.Description = caseDescription;
                        
                        //Asignamos a la cola específica para las respuesta de Bankia
                        try {
                            Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_Cola_Respuesta_CSI_Bankia' LIMIT 1];
                            newCase.OwnerId=cola.Id;
                        } catch (QueryException e) {
                            System.debug('Falta Cola: ' + e);
                        }
                    }                    
                    insert newCase;
                    
                    CC_Metodos_EmailServices.crearAttachment(newCase.Id,  email.textAttachments, email.binaryAttachments);
                    
                    if (vContact != null){
                        crearEmailMessage = crearEmailMessage(email,emailDestino,newCase.id,vContact.id,myPlainTextOrig);
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
            /*
            String caseDescription = myPlainText;
            if (myPlainText.length() > 32000) {
                caseDescription = myPlainText.left(32000); 
            }
            */
            
            String caseHtmlBody = email.htmlBody;
            if (String.isNotBlank(caseHtmlBody) && email.htmlBody.length() > 131072) {
                caseHtmlBody = email.htmlBody.left(131072); 
            }
            
            
            Task createTask = new Task(
            Type='Correo no identificado'
            ,TaskSubtype   = 'Email'
            ,Subject      = 'Correo entrante Bankia' 
            ,ActivityDate = System.today()
            ,Status = 'Completed'
            ,Description = myPlainText.left(32000)
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
            createEmail.HtmlBody = caseHtmlBody;
            createEmail.TextBody = myPlainText.left(131072);
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
    
    public map<String,String> parseoEmail(string vtext){
        map<String,String> resultado = new map<String,String>();
        integer i =-1;
        String item ='';
        String valor ='';
        list<String> parse = new list<String>();
        for (String linea : vtext.split('\n')) {
            i=linea.indexof(':');
            if (i>0){
                parse=linea.split(':', 2);
                item=parse[0].trim();
                valor=parse[1].trim();
                valor = valor.replaceAll('\u00A0', '');
                valor = valor.replaceAll('------------------------------------------------------------------', '');
                resultado.put(item,valor);
            } else {
                if (item!=''){
                    valor=valor + '\n' + linea.trim();
                    resultado.put(item,valor);
                }
            }
        }
        return resultado;
    }
    
    //Ajuste por perdida de saltos de carro perdidos
    public string ajusteMensaje(string vtextin){      
        String vtextout = vtextin;
        
        vtextout=vtextout.unescapeHtml4() ;      
        vtextout=vtextout.replace('[Id. problema', '\r\nidProblema');
        vtextout=vtextout.replace('[Fecha/Hora inicio', '\r\nfechaHoraInicio');
        vtextout=vtextout.replace('[Relacionado con', '\r\nrelacionado');
        vtextout=vtextout.replace('[Prioridad', '\r\nprioridad');
        vtextout=vtextout.replace('[Gravedad', '\r\ngravedad');
        vtextout=vtextout.replace('[Fecha/Hora limite de cierre', '\r\nfechaHoraLimiteCierre');
        vtextout=vtextout.replace('[Entidad', '\r\nentidad');
        vtextout=vtextout.replace('[Oficina', '\r\noficina');
        vtextout=vtextout.replace('[Tfno. oficina', '\r\ntfnoOficina');
        vtextout=vtextout.replace('[Direccion oficina', '\r\ndireccionOficina');
        vtextout=vtextout.replace('[Cod. Postal', '\r\ncodPostal');
        vtextout=vtextout.replace('[Ciudad', '\r\nciudad');
        vtextout=vtextout.replace('[Provincia', '\r\nprovincia');
        vtextout=vtextout.replace('[Pers. contacto', '\r\npersContacto');
        vtextout=vtextout.replace('[Tfno. contacto', '\r\ntfnoContacto');
        vtextout=vtextout.replace('[Movil', '\r\ntfnoMovil');
        vtextout=vtextout.replace('[Usuario Caixa', '\r\nusuarioCaixa');
        vtextout=vtextout.replace('[Oficina Caixa', '\r\noficinaCaixa');
        vtextout=vtextout.replace('[Dispositivo', '\r\ndispositivo');
        vtextout=vtextout.replace('[Producto', '\r\nproducto');
        vtextout=vtextout.replace('[Puesto', '\r\npuesto');
        vtextout=vtextout.replace('[Num. Serie', '\r\nnumSerie');
        vtextout=vtextout.replace('[Ubicación dispositivo', '\r\nubicacionDispositivo');
        vtextout=vtextout.replace('[Cod. Problema', '\r\ncodProblema');
        vtextout=vtextout.replace('[Descrip. Cod. Problema', '\r\ndescripCodProblema');
        vtextout=vtextout.replace('Sintoma/Mensaje', '\r\nsintomaMensaje');
        vtextout=vtextout.replace('[Descrip. Incidencia', '\r\ndescripIncidencia');
        vtextout=vtextout.replace('[Tipo de caso', '\r\ntipoCaso');
        vtextout=vtextout.replace('[Categoría', '\r\ncategoria');
        vtextout=vtextout.replace('[Area problema', '\r\nareaProblema');
        vtextout=vtextout.replace('[Detalle problema', '\r\ndetalleProblema');
        vtextout=vtextout.replace('[Automatico]', '\r\nautomatico');
        
        return vtextout;        
    }
}