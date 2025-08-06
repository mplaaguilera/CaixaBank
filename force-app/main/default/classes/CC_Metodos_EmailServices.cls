public with sharing class CC_Metodos_EmailServices {
	public static String referenciaCorreo(Messaging.inboundEmail correo) {
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

    public static String referenciaCorreo(EmailMessage correo) {
        //La referencia se envía entre estos los literales '#@' y '#' en los correos salientes.ApexPages
        String referencia = null;
        if (correo.TextBody != null) {
            referencia = correo.TextBody.substringBetween('#@', '#');
        }
        //En ocasiones el campo TextBody (sin formato) viene vacío, se busca en el campo HtmlBody
        if (referencia == null && correo.HtmlBody != null) {
            referencia = correo.HtmlBody.substringBetween('#@', '#');
        }
        return referencia;
    }
    
    
    
    public static void respuestaTrasladoColaborador(Messaging.inboundEmail email, Id whatIdTarea, String myPlainText, String emailDestino) {
        //Cambio de estado del caso
        Case caso = [SELECT Id, Status, Subject, CC_Canal_Procedencia__c, Origin, CC_Autoasignado_Coordinador__c, CC_Cola_Procedencia__c, CC_En_Tercer_Nivel__c, Canal_del_Empleado__c,
                    CC_Grupo_3N__c, ContactId  FROM Case WHERE Id = :whatIdTarea LIMIT 1];
      
        if (caso.Status == 'Pendiente Colaborador') {
            caso.CC_Ultima_Interaccion__c = 'Respuesta de colaborador';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();

            //Si la propiedad del caso no está fijada a un coordinador, se devuelve el caso a la cola para
            //que lo pueda atender cualquier agente, no solo el propietario previo al traslado
            if (caso.CC_Cola_Procedencia__c != null && !caso.CC_Autoasignado_Coordinador__c) {
                //Vuelve a la cola origen
                if (caso.CC_En_Tercer_Nivel__c) {
                   caso.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = :caso.CC_Grupo_3N__c].Id; 
                   caso.Status = 'Pendiente Interno';
                } else {
                    caso.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :caso.CC_Cola_Procedencia__c].Id;
                    caso.Status = 'Activo';
                }
            } else {
            	if (caso.CC_En_Tercer_Nivel__c) {
                   caso.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = :caso.CC_Grupo_3N__c].Id; 
                   caso.Status = 'Pendiente Interno';
                }else{
                	caso.Status = 'Activo';    
                }                
            }

        
            //Controlamos cuando se hace la devolución y se pone Activo para report de FormWeb.
            if (caso.CC_Canal_Procedencia__c == 'Caixabank Talks' || caso.CC_Canal_Procedencia__c == 'Formulario web' || caso.CC_Canal_Procedencia__c == 'Soporte Clientes CompraEstrella' || caso.CC_Canal_Procedencia__c == 'Soporte Empleados CompraEstrella') {
                caso.CC_Fecha_Activo_Formulario__c = Datetime.valueOf(System.now());
            }
            
            //Controlamos cuando se hace la devolución y se pone Activo para report de Accionista.
            if (caso.CC_Canal_Procedencia__c == 'Accionista') {
                caso.CC_Fecha_Activo_Formulario__c = CC_SLA_Utils.calculo_Fecha_Activo('Accionista');
            }
            
            //Informamos la fecha de respuesta para el report de Stores
            //
            //
            //if (caso.Origin == 'Comentarios Stores') {
                caso.CC_Fecha_Respuesta_Colaborador__c = Datetime.valueOf(System.now());
            //}
			update caso;
            
            CC_Metodos_EmailServices.crearAttachment(caso.Id,  email.textAttachments, email.binaryAttachments);

            
            //Creamos el mail entrante y lo asociamos al caso
            if (caso.CC_Canal_Procedencia__c == 'Soporte Clientes CompraEstrella'){
                EmailMessage crearEmailMessage = CC_PromoCaixa_Clientes_EmailService.crearEmailMessage(email,emailDestino,caso.Id,caso.ContactId,myPlainText);
            } else if (caso.CC_Canal_Procedencia__c == 'Postventa CompraEstrella'){
                EmailMessage crearEmailMessage = CC_PromoCaixa_Clientes_EmailService.crearEmailMessage(email,emailDestino,caso.Id,caso.ContactId,myPlainText);
            } else if (caso.CC_Canal_Procedencia__c == 'Accionista'){
                EmailMessage crearEmailMessage = CC_Accionistas_EmailService.crearEmailMessage(email,emailDestino,caso.Id,caso.ContactId,myPlainText);
            } else if (caso.CC_Canal_Procedencia__c == 'Soporte Empleados CompraEstrella' || caso.CC_Canal_Procedencia__c == 'Emisiones PromoCaixa'){
                EmailMessage crearEmailMessage = CC_PromoCaixa_Empleados_EmailService.crearEmailMessage(email,emailDestino,caso.Id,caso.ContactId,myPlainText);
            } else if (caso.CC_Canal_Procedencia__c == 'Oficina Preventiva'){
                EmailMessage crearEmailMessage = CC_Preventiva_EmailService.crearEmailMessage(email,emailDestino,caso.Id,caso.ContactId,myPlainText);
            } else if (caso.CC_Canal_Procedencia__c == 'Atención al Cliente'){
                EmailMessage crearEmailMessage = CC_AC_EmailService.crearEmailMessage(email,emailDestino,caso.Id,caso.ContactId,myPlainText);
            } else if (caso.Canal_del_Empleado__c == 'CSI'){
                EmailMessage crearEmailMessage = CC_CAU_Bankia_EmailService.crearEmailMessage(email,emailDestino,caso.Id,caso.ContactId,myPlainText);
            } else if(caso.CC_Canal_Procedencia__c == 'Código de Buenas Prácticas'){
                EmailMessage crearEmailMessage = CC_ES_BuenasPracticas.crearEmailMessage(email,emailDestino,caso.Id,caso.ContactId,myPlainText);
            }
            //Cierre de la actividad de envío del traslado a grupo colaborador
            CC_Activity.finalizarActividadCaso(whatIdTarea, 'Traslado Colaborador', null, null);
        }
    }
    
    public static void respuestaRemitirColaborador(Messaging.inboundEmail correo, Id whatIdTarea, String myPlainText, String emailDestino) {

        
        //Cambio de estado del caso
                Case caso = [SELECT Id, ContactId, Status, CC_Canal_Procedencia__c, Canal_del_Empleado__c FROM Case WHERE Id = :whatIdTarea LIMIT 1];
        if (caso.Status == 'Pendiente Colaborador') {
            caso.Status = 'Activo';
            update caso;
		}

        CC_Metodos_EmailServices.crearAttachment(caso.Id,  correo.textAttachments, correo.binaryAttachments);
        
        //Creamos el mail entrante y lo asociamos al caso
        if (caso.CC_Canal_Procedencia__c == 'Soporte Clientes CompraEstrella'){            EmailMessage crearEmailMessage = CC_PromoCaixa_Clientes_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
        } else if (caso.CC_Canal_Procedencia__c == 'Accionista'){            EmailMessage crearEmailMessage = CC_Accionistas_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
        } else if (caso.CC_Canal_Procedencia__c == 'Soporte Empleados CompraEstrella' || caso.CC_Canal_Procedencia__c == 'Emisiones PromoCaixa'){            EmailMessage crearEmailMessage = CC_PromoCaixa_Empleados_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
        } else if (caso.CC_Canal_Procedencia__c == 'Oficina Preventiva'){            EmailMessage crearEmailMessage = CC_Preventiva_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
        } else if (caso.CC_Canal_Procedencia__c == 'Atención al Cliente'){        	EmailMessage crearEmailMessage = CC_AC_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
        } else if (caso.Canal_del_Empleado__c == 'CSI'){            EmailMessage crearEmailMessage = CC_CAU_Bankia_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
        } else if(caso.CC_Canal_Procedencia__c == 'Código de Buenas Prácticas'){            EmailMessage crearEmailMessage = CC_ES_BuenasPracticas.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
        }
        //Cierre de la actividad de envío del traslado a grupo colaborador
        CC_Activity.finalizarActividadCaso(whatIdTarea, 'Remitir Colaborador', null, null);
    }
    
    public static void respuestaSolicitudInfo(Messaging.inboundEmail correo, Id whatIdTarea, String myPlainText, String emailDestino) {

        Case caso = [SELECT Id, Status, CC_Canal_Procedencia__c, CC_Autoasignado_Coordinador__c, CC_Cola_Procedencia__c, ContactId, Canal_del_Empleado__c
                        FROM Case WHERE Id = :whatIdTarea LIMIT 1];
        if (caso.Status == 'Pendiente Cliente') { 
            caso.Status = 'Activo';
            caso.CC_Ultima_Interaccion__c = 'Respuesta de solicitud de información';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();

            //Si la propiedad del caso no está fijada a un coordinador, se devuelve el caso a la cola para
            //que lo pueda atender cualquier agente, no solo el propietario previo a la solicitud
            if (!caso.CC_Autoasignado_Coordinador__c && caso.CC_Cola_Procedencia__c != null) {
                caso.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :caso.CC_Cola_Procedencia__c].Id;
            }

            //Controlamos cuando se hace la devolución y se pone Activo para report de FormWeb.
            if (caso.CC_Canal_Procedencia__c == 'Caixabank Talks'  || caso.CC_Canal_Procedencia__c == 'Formulario web'  || caso.CC_Canal_Procedencia__c == 'Soporte Clientes CompraEstrella' || caso.CC_Canal_Procedencia__c == 'Soporte Empleados CompraEstrella') {
                caso.CC_Fecha_Activo_Formulario__c = Datetime.valueOf(System.now());
            }
            update caso;
			
            CC_Metodos_EmailServices.crearAttachment(caso.Id,  correo.textAttachments, correo.binaryAttachments);

            // Save attachments, if any
            // if (correo.textAttachments != null) {
            //     for (Messaging.Inboundemail.TextAttachment tAttachment : correo.textAttachments) {
            //         ContentVersion cv = new ContentVersion();
            //         cv.ContentLocation = 'S';
            //         cv.PathOnClient = tAttachment.fileName;
            //         cv.Origin = 'H';
            //         cv.Title = tAttachment.fileName;
            //         cv.VersionData = Blob.valueOf(tAttachment.body);
            //         insert cv;
                    
            //         ContentVersion cVers = [select ContentDocumentId from ContentVersion where Id =: cv.Id];
            //         ContentDocumentLink cl = new ContentDocumentLink(LinkedEntityId = caso.Id, ContentDocumentId = cVers.ContentDocumentId, ShareType = 'I');
            //         insert cl;
            //     }
            // }
            // //Save any Binary Attachment
            // if (correo.binaryAttachments != null){
            //     for(Messaging.Inboundemail.BinaryAttachment bAttachment : correo.binaryAttachments) {
            //         ContentVersion cv = new ContentVersion();
            //         cv.ContentLocation = 'S';
            //         cv.PathOnClient = bAttachment.fileName;
            //         cv.Origin = 'H';
            //         cv.Title = bAttachment.fileName;
            //         cv.VersionData = bAttachment.body;
            //         insert cv;
                    
            //         ContentVersion cVers = [select ContentDocumentId from ContentVersion where Id =: cv.Id];
            //         ContentDocumentLink cl = new ContentDocumentLink(LinkedEntityId = caso.Id, ContentDocumentId = cVers.ContentDocumentId, ShareType = 'I');
            //         insert cl;
            //     }
            // }

            //Creamos el mail entrante y lo asociamos al caso
            if (caso.CC_Canal_Procedencia__c == 'Soporte Clientes CompraEstrella'){
                EmailMessage crearEmailMessage = CC_PromoCaixa_Clientes_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
            } else if (caso.CC_Canal_Procedencia__c == 'Accionista'){
                EmailMessage crearEmailMessage = CC_Accionistas_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
            } else if (caso.CC_Canal_Procedencia__c == 'Soporte Empleados CompraEstrella' || caso.CC_Canal_Procedencia__c == 'Emisiones PromoCaixa'){
                EmailMessage crearEmailMessage = CC_PromoCaixa_Empleados_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
            } else if (caso.CC_Canal_Procedencia__c == 'Oficina Preventiva'){
                EmailMessage crearEmailMessage = CC_Preventiva_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
            } else if (caso.CC_Canal_Procedencia__c == 'Atención al Cliente'){
        		EmailMessage crearEmailMessage = CC_AC_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
        	} else if (caso.Canal_del_Empleado__c == 'CSI'){
                EmailMessage crearEmailMessage = CC_CAU_Bankia_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
            } else if(caso.CC_Canal_Procedencia__c == 'Código de Buenas Prácticas'){
                EmailMessage crearEmailMessage = CC_ES_BuenasPracticas.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
            }
            //Cierre de la actividad de envío del traslado a grupo colaborador
            CC_Activity.finalizarActividadCaso(whatIdTarea, 'Solicitud Información', null, null);
        
        } else if (caso.Status == 'Cerrado') {
            //Para solicitudes info se reabre el caso aunque se hubiera cerrado
            CC_Case.reapertura(caso.Id, myPlainText);
        }
    }

    // Método para adjuntar los attachments del correo en el caso
    public static void crearAttachment(Id idCaso, List<Messaging.Inboundemail.TextAttachment> textAttachments, List<Messaging.Inboundemail.BinaryAttachment> binaryAttachments){
        List<ContentVersion> listaContentVersions = new List<ContentVersion>();
        if (textAttachments != null) {
            for (Messaging.Inboundemail.TextAttachment tAttachment : textAttachments) {
                ContentVersion content = new ContentVersion();
                content.ContentLocation = 'S';
                content.PathOnClient = tAttachment.fileName;
                content.Origin = 'H';
                content.Title = tAttachment.fileName;
                content.VersionData = Blob.valueOf(tAttachment.body);
                listaContentVersions.add(content);
            }
        }
        if (binaryAttachments != null) {
            for(Messaging.Inboundemail.BinaryAttachment bAttachment : binaryAttachments) {
                ContentVersion content = new ContentVersion();
                content.ContentLocation = 'S';
                content.PathOnClient = bAttachment.fileName;
                content.Origin = 'H';
                content.Title = bAttachment.fileName;
                content.VersionData = bAttachment.body;
                listaContentVersions.add(content);
            }
        }
        insert listaContentVersions;
            
        if(!listaContentVersions.isEmpty()){
            //Recuperar ContentDocumentId de los registros Content Version insertados
            Set<Id> idsContentVersion = new Set<Id>();
            for (ContentVersion cv : listaContentVersions) {
                idsContentVersion.add(cv.Id);
            }
            List<ContentVersion> listaActualizadaContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :idsContentVersion];
            List<ContentDocumentLink> listaDocumentLink = new List<ContentDocumentLink>();
            
            for (ContentVersion conVers : listaActualizadaContentVersion) {
                ContentDocumentLink contentDocument = new ContentDocumentLink();
                contentDocument.LinkedEntityId = idCaso;
                contentDocument.ContentDocumentId = conVers.ContentDocumentId;
                contentDocument.ShareType = 'I';
                listaDocumentLink.add(contentDocument);	
            }
            insert listaDocumentLink;
        }
    }
    
    public static void respuestaCliente(Messaging.inboundEmail correo, Id whatIdTarea, String myPlainText, String emailDestino) {
        //Cuando un cliente responde a un email enviado desde la operativa reponder a cliente se envía un email automático
              
        Case caso = [SELECT Id, RecordTypeId, Status, CC_Numero_Documento__c, CC_Idioma__c, AccountId, ContactId, Contact.Email, CC_Canal_Procedencia__c, CC_Autoasignado_Coordinador__c, Canal_del_Empleado__c,
                     CC_Cola_Procedencia__c, ClosedDate, CC_En_Tercer_Nivel__c, CC_En_Segundo_Nivel__c, CC_Reapertura_Valida__c, CC_Fecha_Reapertura__c, CC_Referencia_Correo_Saliente__c, Origin FROM Case WHERE Id = :whatIdTarea LIMIT 1];
        Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        Id recordTypeCasoEmpl = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        Id recordTypeCasoCSIBankia = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_CSI_Bankia');
        
        if(caso.RecordTypeId == recordTypeCaso){
            List<CC_Queue_Procedencia__mdt> queues = [SELECT CC_Queue__c, CC_Canal_Procedencia__c FROM CC_Queue_Procedencia__mdt
                                                      WHERE CC_Canal_Procedencia__c = :caso.CC_Canal_Procedencia__c];        
            
            if(!queues.isEmpty()){
                Group cola = [SELECT Id FROM Group WHERE TYPE = 'Queue' AND DEVELOPERNAME = :queues[0].CC_Queue__c LIMIT 1];
                caso.OwnerId = cola.Id;          
            }/*else{
                Group cola = [SELECT Id FROM Group WHERE TYPE = 'Queue' AND DEVELOPERNAME = 'CC_Inbound_Email_AC' LIMIT 1];
                caso.OwnerId = cola.Id;
            }*/
            update caso;
            
            CC_Metodos_EmailServices.crearAttachment(caso.Id,  correo.textAttachments, correo.binaryAttachments);

            //Creamos el mail entrante y lo asociamos al caso
            if (caso.CC_Canal_Procedencia__c == 'Soporte Clientes CompraEstrella'){
                EmailMessage crearEmailMessage = CC_PromoCaixa_Clientes_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
            } else if (caso.CC_Canal_Procedencia__c == 'Accionista'){
                EmailMessage crearEmailMessage = CC_Accionistas_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
            } else if (caso.CC_Canal_Procedencia__c == 'Soporte Empleados CompraEstrella' || caso.CC_Canal_Procedencia__c == 'Emisiones PromoCaixa'){
                EmailMessage crearEmailMessage = CC_PromoCaixa_Empleados_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
            } else if (caso.CC_Canal_Procedencia__c == 'Oficina Preventiva'){
                EmailMessage crearEmailMessage = CC_Preventiva_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
            } else if (caso.CC_Canal_Procedencia__c == 'Atención al Cliente'){
        		EmailMessage crearEmailMessage = CC_AC_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
        	} else if(caso.CC_Canal_Procedencia__c == 'Código de Buenas Prácticas'){
                EmailMessage crearEmailMessage = CC_ES_BuenasPracticas.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
            }
            /*String htmlBody;
            if(caso.CC_Idioma__c == 'ca'){
                htmlBody = [SELECT Id, DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_Respuesta_Automatica_Cliente_en' LIMIT 1].HtmlValue;
            }else if(caso.CC_Idioma__c == 'en'){
                htmlBody = [SELECT Id, DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_Respuesta_Automatica_Cliente_ca' LIMIT 1].HtmlValue;
            }else{
                htmlBody = [SELECT Id, DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_Respuesta_Automatica_Cliente_es' LIMIT 1].HtmlValue;
            }
            
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();  
            List<OrgWideEmailAddress> owa = [select id, DisplayName, Address from OrgWideEmailAddress WHERE Address = :emailDestino LIMIT 1];  
            
            if (owa.isEmpty() && caso.CC_Canal_Procedencia__c == 'Accionista') {
                //hacer lista SELECT DEL METADATO CC_Valores__mdt y sacar Valor Valor SFDC y el campo lista tiene que ser accionistaslista
                List<CC_Valores__mdt> listaValoresCorreos = [SELECT CC_Valor_SFDC__c, CC_Valor__c, CC_Lista__c  FROM CC_Valores__mdt
                                                             WHERE CC_Lista__c = 'accionistaslista'];

                for (CC_Valores__mdt listaCorreo : listaValoresCorreos) {
                    //comprobar si emailDestiono = algun metadato de custom accionistas
                    if (listaCorreo.CC_Valor_SFDC__c == emailDestino || listaCorreo.CC_Valor__c == emailDestino) {
                        //en el caso de ser cierto assignar el owa.id de OrgWideEmailAddress en cuestion
                        owa = [select id, DisplayName, Address from OrgWideEmailAddress WHERE DisplayName = 'Accionistas CaixaBank' LIMIT 1];
                    }
                }
            //Comprobar que el canal de procedencia es de tipo promocaixa empleado
            }else if (owa.isEmpty() && caso.CC_Canal_Procedencia__c == 'Soporte Empleados CompraEstrella'){
                    List<CC_Valores__mdt> listaValoresCorreos = [SELECT CC_Valor_SFDC__c, CC_Valor__c, CC_Lista__c  FROM CC_Valores__mdt
                                                             WHERE CC_Lista__c = 'promocaixaEmpleados'];

                    for (CC_Valores__mdt listaCorreo : listaValoresCorreos) {
                        if (listaCorreo.CC_Valor_SFDC__c == emailDestino || listaCorreo.CC_Valor__c == emailDestino) {
                            owa = [select id, DisplayName, Address from OrgWideEmailAddress WHERE DisplayName = 'Atención Oficinas PromoCaixa' LIMIT 1];
                        }
                    }
            
            }else if (owa.isEmpty() && caso.CC_Canal_Procedencia__c == 'Soporte Clientes CompraEstrella'){
                    List<CC_Valores__mdt> listaValoresCorreos = [SELECT CC_Valor_SFDC__c, CC_Valor__c, CC_Lista__c  FROM CC_Valores__mdt
                                                             WHERE CC_Lista__c = 'promocaixaClientes'];

                    for (CC_Valores__mdt listaCorreo : listaValoresCorreos) {
                        if (listaCorreo.CC_Valor_SFDC__c == emailDestino || listaCorreo.CC_Valor__c == emailDestino) {
                            owa = [select id, DisplayName, Address from OrgWideEmailAddress WHERE DisplayName = 'Atención Clientes PromoCaixa' LIMIT 1];
                        }
                    }
            //Preventiva
            }else if (owa.isEmpty() && caso.CC_Canal_Procedencia__c == 'Oficina Preventiva'){
                    List<CC_Valores__mdt> listaValoresCorreos = [SELECT CC_Valor_SFDC__c, CC_Valor__c, CC_Lista__c  FROM CC_Valores__mdt
                                                             WHERE CC_Lista__c = 'preventivaLista'];

                    for (CC_Valores__mdt listaCorreo : listaValoresCorreos) {
                        if (listaCorreo.CC_Valor_SFDC__c == emailDestino || listaCorreo.CC_Valor__c == emailDestino) {
                            owa = [select id, DisplayName, Address from OrgWideEmailAddress WHERE DisplayName = 'Atención Clientes CaixaBank' LIMIT 1];
                        }
                    }
            //Atención al cliente
            }else if (owa.isEmpty() && caso.CC_Canal_Procedencia__c == 'Atención al Cliente'){
                    List<CC_Valores__mdt> listaValoresCorreos = [SELECT CC_Valor_SFDC__c, CC_Valor__c, CC_Lista__c  FROM CC_Valores__mdt
                                                             WHERE CC_Lista__c = 'atencionClienteLista'];

                    for (CC_Valores__mdt listaCorreo : listaValoresCorreos) {
                        if (listaCorreo.CC_Valor_SFDC__c == emailDestino || listaCorreo.CC_Valor__c == emailDestino) {
                            if(caso.CC_Idioma__c == 'ca'){
                                owa = [select id, DisplayName, Address from OrgWideEmailAddress WHERE DisplayName = 'Atenció Clients CaixaBank' LIMIT 1];
                            } else if(caso.CC_Idioma__c == 'en'){
                            	owa = [select id, DisplayName, Address from OrgWideEmailAddress WHERE DisplayName = 'Customer Support CaixaBank' LIMIT 1];
                            } else{
                            	owa = [select id, DisplayName, Address from OrgWideEmailAddress WHERE DisplayName = 'Atención Clientes CaixaBank' LIMIT 1];
                            }
                        }
                    }
            }
            

            //Generamos el email a enviar. Debe mantener el cuerpo del email anterior y agregar el cuerpo de la plantilla recuperada
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            //Falta que nos pasen la plantilla
            //email.setHtmlBody(htmlBody);
            email.setHtmlBody(htmlBody + '<br/>__________<br/><br/>' + correo.HtmlBody);
            //email.setReplyTo(correo.Id);
            email.setSaveAsActivity(true);
            email.setTreatBodiesAsTemplate(true);
            email.setWhatId(caso.Id);
            email.setTargetObjectId(caso.ContactId);
            email.setTreatTargetObjectAsRecipient(false);
            email.setOrgWideEmailAddressId(owa[0].Id);
            email.subject = correo.Subject;
            String[] toAddress = new String[]{};
                toAddress.add(correo.FromAddress);
            email.setToAddresses(toAddress);
            allmsg.add(email);
            
            //Enviamos todos los mensajes
            if (!allmsg.isEmpty()){
                Messaging.SendEmailResult [] r = Messaging.sendEmail(allmsg, false); 
                for (Messaging.SendEmailResult sr : r) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                   
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Fields that affected this error: ' + err.getFields());
                        }
                    }
                }                    
            }*/
        } else if(caso.RecordTypeId == recordTypeCasoEmpl) {
            if (caso.CC_Canal_Procedencia__c == 'Formulario Consultas Operativas' || caso.Origin == 'Phone' || caso.Origin == 'Chat') {
                if (caso.Status == 'Cerrado') {
                    CC_Encuesta_CCO.respuestaCorreo(correo, whatIdTarea, myPlainText, emailDestino);
                }
            } else {
                List<CC_Queue_Procedencia__mdt> queues = [SELECT CC_Queue__c, CC_Canal_Procedencia__c FROM CC_Queue_Procedencia__mdt
                                                        WHERE CC_Canal_Procedencia__c = :caso.CC_Canal_Procedencia__c];        
                
                if(!queues.isEmpty()){
                    Group cola = [SELECT Id FROM Group WHERE TYPE = 'Queue' AND DEVELOPERNAME = :queues[0].CC_Queue__c LIMIT 1];
                    caso.OwnerId = cola.Id;          
                }
                update caso;
                
                CC_Metodos_EmailServices.crearAttachment(caso.Id,  correo.textAttachments, correo.binaryAttachments);

                //Creamos el mail entrante y lo asociamos al caso
                if (caso.CC_Canal_Procedencia__c == 'Soporte Empleados CompraEstrella'){
                    EmailMessage crearEmailMessage = CC_PromoCaixa_Empleados_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
                }
            }
        } else if(caso.RecordTypeId == recordTypeCasoCSIBankia){
            List<CC_Queue_Procedencia__mdt> queues = [SELECT CC_Queue__c, CC_Canal_Procedencia__c FROM CC_Queue_Procedencia__mdt
                                                      WHERE CC_Canal_Procedencia__c = :caso.Canal_del_Empleado__c];        
            
            if(!queues.isEmpty()){
                Group cola = [SELECT Id FROM Group WHERE TYPE = 'Queue' AND DEVELOPERNAME = :queues[0].CC_Queue__c LIMIT 1];
                caso.OwnerId = cola.Id;          
            }
            update caso;
            
            CC_Metodos_EmailServices.crearAttachment(caso.Id,  correo.textAttachments, correo.binaryAttachments);

            //Creamos el mail entrante y lo asociamos al caso
            if (caso.Canal_del_Empleado__c == 'CSI'){
                EmailMessage crearEmailMessage = CC_CAU_Bankia_EmailService.crearEmailMessage(correo,emailDestino,caso.Id,caso.ContactId,myPlainText);
            } 
        }
    }
}