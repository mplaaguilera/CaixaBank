public with sharing class OS_Metodos_EmailServices {

    public static String referenciaCorreo(Messaging.InboundEmail correo) {
          //Devuelve la primera referencia encontrada
          //La referencia se envía entre estos los literales '#@' y '#' en los correos salientes.ApexPages
          String referencia = null;
          if (correo.plainTextBody != null) {
              referencia = correo.plainTextBody.substringBetween('#@', '#');
          }
          //En ocasiones el campo TextBody (sin formato) viene vacío, se busca en el campo HtmlBody
          if (referencia == null && correo.HtmlBody != null) {
              referencia = correo.HtmlBody.substringBetween('#@', '#');
          }
          return referencia;
    }
    public static Set<String> referenciaCorreoSet(Messaging.InboundEmail correo) {
        //Devuelve todas las referencias encontradas en el cuerpo del correo por orden de localización
        //La referencia se envía entre estos los literales '#@' y '#' en los correos salientes.ApexPages
        Set<String> referenciaSet = new Set<String>();

        if (correo.plainTextBody != null) {
            Pattern p = Pattern.compile('\\#@[a-zA-Z0-9]{33}\\#');
            Matcher m = p.matcher(correo.plainTextBody.left(64000));
            while (m.find()) {
                referenciaSet.add(m.group(0).substringBetween('#@', '#'));
            }
        }
        //En ocasiones el campo TextBody (sin formato) viene vacío, se busca en el campo HtmlBody
        if (referenciaSet.isEmpty() && correo.HtmlBody != null) {
            Pattern p = Pattern.compile('\\#@[a-zA-Z0-9]{33}\\#');
            Matcher m = p.matcher(correo.HtmlBody.left(64000));
            while (m.find()) {
                referenciaSet.add(m.group(0).substringBetween('#@', '#'));
            }
        }
        return referenciaSet;
    }
      
    public static EmailMessage respuestaTrasladoColaborador(Messaging.InboundEmail correo, Id whatIdTarea, String myPlainText, String emailDestino, List<Group> colasTotalesCOPS, Case caso) {
        //Cambio de estado del caso
        if (caso.Status == 'Pendiente Colaborador' || caso.Status == 'Pendiente Alerta' || caso.Status == 'Cerrado' || caso.Status == 'Rechazado') {
            caso.CC_Ultima_Interaccion__c = 'Respuesta de colaborador';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();
            caso.Status = 'Activo';
            caso.OS_Aviso_Propietario__c = true; //para el aviso de nuevos correos.

            if (caso.OS_Alerta_Fecha__c != null) {
                OS_Activity.borrarEvento(caso.Id, caso.OS_Alerta_Fecha__c);
            }
            //Para los casos del buzón Buzón Servicio Firma  el propietario se devuelve a la Cola.
            if (caso.CC_Cola_Procedencia__c != null && caso.CC_Canal_Procedencia__c == 'Buzón Servicio Firma') {
                Id colaId = calcularColaCaso(caso.CC_Cola_Procedencia__c, colasTotalesCOPS);
                if(colaId != null) {
                    caso.OwnerId = colaId;
                }
            }
        update caso;
        }    
        
        String nuevoHtmlBody = correo.htmlBody;
        if (!String.isBlank(nuevoHtmlBody) && nuevoHtmlBody.length() > 131072) {
            nuevoHtmlBody = nuevoHtmlBody.left(131072);
        }
        
        //Gestion adjuntos
        Map<String, Object> mapaGestionAdjuntos = gestionAdjuntos(correo, caso, nuevoHtmlBody);
        nuevoHtmlBody = (String)mapaGestionAdjuntos.get('nuevoHtmlBody');
        Set<Id> listaContentVersionId = (Set<Id>)mapaGestionAdjuntos.get('listaContentVersionId');
        //Creamos el mail entrante y lo asociamos al caso
        EmailMessage crearEmailMessage = OS_EmailService.crearEmailMessage(correo, emailDestino, caso.Id, caso.ContactId, myPlainText, nuevoHtmlBody);     
        //Crear content document link
        crearContentDocumentLink(listaContentVersionId, crearEmailMessage, caso);   
        
        //Cierre de la actividad de envío del traslado a grupo colaborador
        CC_Activity.finalizarActividadCaso(whatIdTarea, 'Traslado Colaborador', null, null);

        return crearEmailMessage;
        
    }
      
    public static EmailMessage respuestaRemitirColaborador(Messaging.InboundEmail correo, Id whatIdTarea, String myPlainText, String emailDestino, List<Group> colasTotalesCOPS, Case caso) {
        if (caso.Status == 'Pendiente Colaborador'|| caso.Status == 'Pendiente Alerta' || caso.Status == 'Cerrado' || caso.Status == 'Rechazado') {
            caso.CC_Ultima_Interaccion__c = 'Respuesta de colaborador';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();
            caso.Status = 'Activo';
            if (caso.OS_Alerta_Fecha__c != null) {
                OS_Activity.borrarEvento(caso.Id, caso.OS_Alerta_Fecha__c);
            }
            //Para los casos del buzón Buzón Servicio Firma  el propietario se devuelve a la Cola.
            if (caso.CC_Cola_Procedencia__c != null && caso.CC_Canal_Procedencia__c == 'Buzón Servicio Firma') {
                Id colaId = calcularColaCaso(caso.CC_Cola_Procedencia__c, colasTotalesCOPS);
                if(colaId != null) {
                    caso.OwnerId = colaId;
                }
            }
            update caso;
        }
        
        String nuevoHtmlBody = correo.htmlBody;
        if (!String.isBlank(nuevoHtmlBody) && nuevoHtmlBody.length() > 131072) {
            nuevoHtmlBody = nuevoHtmlBody.left(131072);
        }
        
        //Gestion adjuntos
        Map<String, Object> mapaGestionAdjuntos = gestionAdjuntos(correo, caso, nuevoHtmlBody);
        nuevoHtmlBody = (String)mapaGestionAdjuntos.get('nuevoHtmlBody');
        Set<Id> listaContentVersionId = (Set<Id>)mapaGestionAdjuntos.get('listaContentVersionId');
        //Creamos el mail entrante y lo asociamos al caso
        EmailMessage crearEmailMessage = OS_EmailService.crearEmailMessage(correo, emailDestino, caso.Id, caso.ContactId, myPlainText, nuevoHtmlBody);     
        //Crear content document link
        crearContentDocumentLink(listaContentVersionId, crearEmailMessage, caso);
        
        //Cierre de la actividad de envío del traslado a grupo colaborador
        CC_Activity.finalizarActividadCaso(whatIdTarea, 'Remitir Colaborador', null, null);

        return crearEmailMessage;
    }
      
    public static EmailMessage respuestaSolicitudInfo(Messaging.InboundEmail correo, Id whatIdTarea, String myPlainText, String emailDestino, List<Group> colasTotalesCOPS, Case caso) {
        Boolean updateCaso = false;

        if(caso.Status != 'Activo') {
            //Para los casos del buzón Buzón Servicio Firma  el propietario se devuelve a la Cola.
            if (caso.CC_Cola_Procedencia__c != null && caso.CC_Canal_Procedencia__c == 'Buzón Servicio Firma') {
                Id colaId = calcularColaCaso(caso.CC_Cola_Procedencia__c, colasTotalesCOPS);
                if(colaId != null) {
                    caso.OwnerId = colaId;
                    updateCaso = true;
                }
            }
        }
        if (caso.Status == 'Pendiente Cliente'|| caso.Status == 'Pendiente Alerta') { 
            caso.Status = 'Activo';
            caso.OS_Aviso_Propietario__c = true; //para el aviso de nuevos correos.
            caso.CC_Ultima_Interaccion__c = 'Respuesta de solicitud de información';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();
            if (caso.OS_Alerta_Fecha__c != null) {
                OS_Activity.borrarEvento(caso.Id, caso.OS_Alerta_Fecha__c);
            }
            updateCaso = true;
        } 
        else if (caso.Status == 'Cerrado') {
            //Para solicitudes info se reabre el caso aunque se hubiera cerrado
            OS_Case.reapertura(caso.Id);
        }
        if(updateCaso) {
            update caso;
        }

        String nuevoHtmlBody = correo.htmlBody;
        if (!String.isBlank(nuevoHtmlBody) && nuevoHtmlBody.length() > 131072) {
            nuevoHtmlBody = nuevoHtmlBody.left(131072);
        }

        //Cierre de la actividad de envío del traslado a grupo colaborador
        CC_Activity.finalizarActividadCaso(whatIdTarea, 'Solicitud Información', null, null);

        //Gestion adjuntos
        Map<String, Object> mapaGestionAdjuntos = gestionAdjuntos(correo, caso, nuevoHtmlBody);
        nuevoHtmlBody = (String)mapaGestionAdjuntos.get('nuevoHtmlBody');
        Set<Id> listaContentVersionId = (Set<Id>)mapaGestionAdjuntos.get('listaContentVersionId');
        //Creamos el mail entrante y lo asociamos al caso
        EmailMessage crearEmailMessage = OS_EmailService.crearEmailMessage(correo, emailDestino, caso.Id, caso.ContactId, myPlainText, nuevoHtmlBody);     
        //Crear content document link
        crearContentDocumentLink(listaContentVersionId, crearEmailMessage, caso);

        return crearEmailMessage;
    }
      
    public static EmailMessage respuestaCliente(Messaging.InboundEmail correo, Id whatIdTarea, String myPlainText, String emailDestino, List<Group> colasTotalesCOPS, Case caso) {
        //Cuando un cliente responde a un email enviado desde la operativa reponder a cliente se envía un email automático
        if(caso.Status != 'Activo') {
            //Para los casos del buzón Buzón Servicio Firma  el propietario se devuelve a la Cola.
            if (caso.CC_Cola_Procedencia__c != null && caso.CC_Canal_Procedencia__c == 'Buzón Servicio Firma') {
                Id colaId = calcularColaCaso(caso.CC_Cola_Procedencia__c, colasTotalesCOPS);
                if(colaId != null) {
                    caso.OwnerId = colaId;
                }
            }
        }
        if (caso.Status == 'Pendiente Alerta') {
            caso.Status = 'Activo';
            if (caso.OS_Alerta_Fecha__c != null) {
                OS_Activity.borrarEvento(caso.Id, caso.OS_Alerta_Fecha__c);
            }
        }
        caso.OS_Aviso_Propietario__c = true;
        caso.CC_Ultima_Interaccion__c = 'Respuesta de cliente';
        caso.CC_Fecha_Ultima_Interaccion__c = System.now();
        update caso;
        
        //Estado
        if (caso.Status == 'Cerrado') {
            //Para respuestas de cliente se reabre el caso aunque se hubiera cerrado
            OS_Case.reapertura(caso.Id);
        }
        
        String nuevoHtmlBody = correo.htmlBody;
        if (!String.isBlank(nuevoHtmlBody) && nuevoHtmlBody.length() > 131072) {
            nuevoHtmlBody = nuevoHtmlBody.left(131072);
        } 
        
        //Gestion adjuntos
        Map<String, Object> mapaGestionAdjuntos = gestionAdjuntos(correo, caso, nuevoHtmlBody);
        nuevoHtmlBody = (String)mapaGestionAdjuntos.get('nuevoHtmlBody');
        Set<Id> listaContentVersionId = (Set<Id>)mapaGestionAdjuntos.get('listaContentVersionId');
        //Creamos el mail entrante y lo asociamos al caso
        EmailMessage crearEmailMessage = OS_EmailService.crearEmailMessage(correo, emailDestino, caso.Id, caso.ContactId, myPlainText, nuevoHtmlBody);     
        //Crear content document link
        crearContentDocumentLink(listaContentVersionId, crearEmailMessage, caso);

        return crearEmailMessage;
    }
  
    public static EmailMessage adjuntarEmailAlCaso(Messaging.InboundEmail correo, Id whatIdTarea, String myPlainText, String emailDestino, Case caso) {
        String nuevoHtmlBody = correo.htmlBody;
        if (!String.isBlank(nuevoHtmlBody) && nuevoHtmlBody.length() > 131072) {
            nuevoHtmlBody = nuevoHtmlBody.left(131072);
        }
        //Gestion adjuntos
        Map<String, Object> mapaGestionAdjuntos = gestionAdjuntos(correo, caso, nuevoHtmlBody);
        nuevoHtmlBody = (String)mapaGestionAdjuntos.get('nuevoHtmlBody');
        Set<Id> listaContentVersionId = (Set<Id>)mapaGestionAdjuntos.get('listaContentVersionId');
        //Creamos el mail entrante y lo asociamos al caso
        EmailMessage crearEmailMessage = OS_EmailService.crearEmailMessage(correo, emailDestino, caso.Id, caso.ContactId, myPlainText, nuevoHtmlBody);     
        //Crear content document link
        crearContentDocumentLink(listaContentVersionId, crearEmailMessage, caso);
        
        return crearEmailMessage;
    }

    public static Id calcularColaCaso(String colaProcedencia, List<Group> colasTotalesCOPS) {
        Id colaId = null;
        for(Group cola: colasTotalesCOPS) {
            if(cola.Type == 'Queue' && cola.DeveloperName == colaProcedencia) {
                colaId = cola.Id;
            }
        }
        return colaId;
    }

    public static boolean usuarioActivo(Case casoOrigen) {
        Boolean usuarioActivo = false;
        List <User> usuario = [SELECT Id, isActive FROM User WHERE Id = :casoOrigen.OwnerId AND isActive = true LIMIT 1]; //lista
        if(!usuario.isEmpty()) {
            usuarioActivo = true;
        }
        return usuarioActivo;
    }

    public static void asignarColaUsuarioInactivo(Case caso, String colaEntrante, List<Group> colasTotalesCOPS) {
        if (!String.isBlank(caso.OS_GrupoTrabajo__c)){
            //Los nombres del grupo de trabajo pueden diferir: p. ej. Name = Comercio Exterior / OS_GrupoTrabajo__c = Buzón Comercio Exterior
            List <Group> grupoDeTrabajo = new List <Group>();
            for(Group colasCOPS: colasTotalesCOPS) {
                if(colasCOPS.Type == 'Regular' && colasCOPS.Name.contains(caso.OS_GrupoTrabajo__c)) {
                    grupoDeTrabajo.add(colasCOPS);
                }
            }
            if (!grupoDeTrabajo.isEmpty()) {
                Group nuevoOwnerCaso;
                for(Group colasCOPS: colasTotalesCOPS) {
                    if(colasCOPS.Type == 'Queue' && colasCOPS.DeveloperName == grupoDeTrabajo[0].DeveloperName) {
                        nuevoOwnerCaso = colasCOPS;
                    }
                }
                if(nuevoOwnerCaso != null) {
                    caso.OwnerId = nuevoOwnerCaso.Id;
                }
            } 
            else {
                caso.OwnerId = colaEntrante;
            }
            
        } else{
            caso.OwnerId = colaEntrante;
        }
        update caso;
    }
  
    public static Map<String, Object> gestionAdjuntos(Messaging.InboundEmail correo, Case caso, String nuevoHtmlBody) {
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