public with sharing class OS_EmailMessage_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EmailMessage>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
	}

    private static List<EmailMessage> filtrarEmailMessageCaso(List<EmailMessage> correos) {
        List<EmailMessage> correosCops = new List<EmailMessage>();
        for (EmailMessage correo : correos) {
            if (String.valueOf(correo.ParentId?.getSobjectType()) == 'Case') {
                correosCops.add(correo);
            } 
            else if (String.valueOf(correo.RelatedToId?.getSobjectType()) == 'Case') {
                correosCops.add(correo);
            }
        }
        return correosCops;
    }

    private void process(List<EmailMessage> listNewObj, Map<Id, EmailMessage> mapNewObj) {
        
        //List<EmailMessage> newList = filtrarEmailMessageNoOS(listNewObj);
        List<EmailMessage> newList = filtrarEmailMessageCaso(listNewObj);
        validarBuzonSalida(newList);
        //Se comprueba si el correo contiene algún fichero adjunto con un formato no permitido y, en tal caso, se impide su envío.
        comprobarAnexosPermitidos(newList, mapNewObj);
        logicaEntradaCorreo(newList);
        limitarAdjuntos(newList);

       
	}
    private static void logicaEntradaCorreo(List<EmailMessage> newList) {
        List<Id> idsCasos = new List<Id>();
        List<String> referencias = new List<String>();
        Map<Id, String> mapaTipoTareaDelCorreo = new Map<Id, String>();
        //Se acumulan las inserciones/actualizaciones en las siguientes listas para ejecutarlas al final
        List<Case> casos = new List<Case>();
        List<Task> actividadesTraslado = new List<Task>();

        //Hasta que se inserten las actividades de traslado no se pueden informar los Ids en las de
        //correo, así que se guardan las relaciones en este mapa y se informan los Ids al final
        Map<Id, Integer> relacionActividades = new Map<Id, Integer>();
        
        for (EmailMessage correo : newList) {
            String referencia = CC_EmailMessage.referenciaCorreo(correo);
            if (referencia != null && correo.Incoming) {
                idsCasos.add(correo.ParentId);
                referencias.add(referencia);
            }
        }

        if (!referencias.isEmpty()){
            List<Task> tareasOrigen = [SELECT Type, WhatId FROM Task WHERE WhatId IN :idsCasos AND CC_Referencia_Correo_Saliente__c IN :referencias];
            for (Task tarea : tareasOrigen) {
                mapaTipoTareaDelCorreo.put(tarea.WhatId, tarea.Type);
            }
        }

        //En función de la operativa y de si el correo es saliente o entrante, se ejecutan acciones diferentes
        for (EmailMessage correo : newList) {
            
            if (!correo.OS_Email_Fusionado__c && correo.Status != '5') { //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft

                //List<Case> casoCorreo = [SELECT OS_Cerrado_Operativa__c, Status, OwnerId FROM Case WHERE Id = :correo.ParentId];

                if (!correo.Incoming) {
                    //Correo SALIENTE
                    if (correo.CC_Procedencia__c == 'Traslado Colaborador') {
                        //Correo saliente de traslado del caso a grupo colaborador
                        envioTrasladoColaborador(correo, casos, actividadesTraslado);
                        relacionActividades.put(correo.ActivityId, actividadesTraslado.size() - 1);
                    } else if (correo.CC_Procedencia__c == 'Solicitud Información') {
                        //Correo saliente de solicitud de información a cliente
                        envioSolicitudInfo(correo, casos, actividadesTraslado);
                        relacionActividades.put(correo.ActivityId, actividadesTraslado.size() - 1);
                    } else if (correo.CC_Procedencia__c == 'Remitir Colaborador') {
                        //Correo saliente de remisión del caso a grupo colaborador
                        envioRemitirColaborador(correo, casos, actividadesTraslado);
                        relacionActividades.put(correo.ActivityId, actividadesTraslado.size() - 1);
                    } else if (correo.CC_Procedencia__c == 'Responder Cliente') {
                        envioResponderCliente(correo, casos, actividadesTraslado);
                        relacionActividades.put(correo.ActivityId, actividadesTraslado.size() - 1);
                    }
                } else {
                    //Correo ENTRANTE                
                    //if (!casoCorreo.isEmpty()) {
                        //for (Case c : casoCorreo) { //Solo entrará una vez
                            //Si se ha encontrado la referencia se realizan acciones en función de la operativa del correo origen
                            if (mapaTipoTareaDelCorreo.get(correo.parentId) != null) {
                                if (mapaTipoTareaDelCorreo.get(correo.parentId) == 'Traslado Colaborador') {
                                    //Respuesta entrante de grupo colaborador
                                    respuestaTrasladoColaborador(correo, casos);
                                } else if (mapaTipoTareaDelCorreo.get(correo.parentId) == 'Solicitud Información') {
                                    //Respuesta entrante de solicitud de información de cliente
                                    respuestaSolicitudInfo(correo, casos);
                                } else if (mapaTipoTareaDelCorreo.get(correo.parentId) == 'Remitir Colaborador') {
                                    //Respuesta entrante de remisión del caso a grupo colaborador
                                    respuestaRemitirColaborador(correo, casos);
                                }else if (mapaTipoTareaDelCorreo.get(correo.parentId) == 'Responder a cliente') {
                                    //Respuesta entrante de respuesta de cliente
                                    respuestaCliente(correo, casos);
                                }
                            }
                        //}
                    //}
                }
            } //Fin "for (EmailMessage correo : newList)"
            
        }

        //Ejecución de las actualizaciones de caso
        update casos;

        //Ejecución de las inserciones de las nuevas actividades de traslado
        insert actividadesTraslado;

        List<Id> idActividesCorreo = new List<Id>();
        for (EmailMessage correo : newList) {
            //Actualización de las actividades existentes de correo para relacionarlas con las de traslado
            idActividesCorreo.add(correo.ActivityId);
        }
    }

    private static void envioTrasladoColaborador(EmailMessage correo, List<Case> casos, List<Task> actividadesTraslado) {
        //Cambio de estado del caso
        Case caso = [SELECT CC_Ultima_Interaccion__c, CC_Fecha_Ultima_Interaccion__c, CC_Referencia_Correo_Saliente__c, CC_Cambio_Estado_Pendiente_Externo__c, Status, Origin,
                    CC_Fecha_1a_Respuesta_Twitter__c, CC_Fecha_Respuesta_Stores__c, CC_Tipo_Gestion__c FROM Case WHERE Id = :correo.ParentId];

        caso.Status = 'Pendiente Colaborador';
        caso.CC_Ultima_Interaccion__c = 'Nuevo';
        caso.CC_Fecha_Ultima_Interaccion__c = System.now();
        caso.CC_Fecha_Traslado_Colaborador__c = Datetime.valueOf(System.now());
        
        //Nueva actividad de tipo "Trasladar Colaborador"
        Task actividadTraslado = new Task();
        actividadTraslado.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        actividadTraslado.Type = 'Traslado Colaborador';
        actividadTraslado.Subject = 'Traslado Colaborador';
        actividadTraslado.WhatId = correo.ParentId;
        actividadTraslado.Status = 'Open';
        actividadTraslado.Description = correo.TextBody.left(32000);
        actividadTraslado.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
        actividadTraslado.CC_Grupo_Colaborador_Id__c = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = :correo.CC_Grupo_Colab__c LIMIT 1].Id;
        CC_Activity.informarFechaVencimientoSLA('Grupo colaborador', correo.CC_Grupo_Colab__c, actividadTraslado);
        CC_Configuracion_Reclamaciones_Auto.informarFechasReclamacionesAuto(actividadTraslado);
        actividadTraslado.CC_Correo_Asociado_Id__c = correo.Id;
        actividadTraslado.ActivityDate = System.today();
        actividadTraslado.AV_Purpose__c = caso.CC_Tipo_Gestion__c;
        actividadesTraslado.add(actividadTraslado);

        caso.CC_Grupo_Colaborador__c = correo.CC_Grupo_Colab__c;
        caso.CC_Referencia_Correo_Saliente__c = ''; //Se vacía la referencia de correo saliente del caso para evitar que se reuse por error
        //caso.CBK_Traslado_Remitido__c = null;
        caso.CC_Tipo_Gestion__c = null;
        casos.add(caso);
    }

    private static void respuestaTrasladoColaborador(EmailMessage correo, List<Case> casos) {
        //Cambio de estado del caso
        Case caso = [SELECT Status, Subject, CC_Canal_Procedencia__c, Origin, CC_Autoasignado_Coordinador__c, CC_Cola_Procedencia__c, CC_En_Tercer_Nivel__c, CC_Grupo_3N__c
                        FROM Case WHERE Id = :correo.ParentId];

        if (caso.Status == 'Pendiente Colaborador') {
            caso.CC_Ultima_Interaccion__c = 'Respuesta de colaborador';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();
            caso.CC_Situacion_Caso__c = 'Respuesta colaborador';
            if (caso.CC_Cola_Procedencia__c != null) {
                //Se devuelve el caso a la cola de procedencia y se pasa a Activo
                caso.OwnerId = [SELECT Id FROM Group WHERE DeveloperName = :caso.CC_Cola_Procedencia__c].Id;
                caso.Status = 'Activo';
                
            } else {
                //Se pasa el caso a Activo
                caso.Status = 'Activo';
            }

            casos.add(caso);

            //Cierre de la actividad de envío del traslado a grupo colaborador
            CC_Activity.finalizarActividadCaso(correo.ParentId, 'Traslado Colaborador', null, null);
        }
    }

    private static void envioResponderCliente(EmailMessage correo, List<Case> casos, List<Task> actividadesTraslado) {
        Case caso = [SELECT CC_Ultima_Interaccion__c, CC_Fecha_Ultima_Interaccion__c, CC_Referencia_Correo_Saliente__c, Status, OS_Cerrado_Operativa__c, OS_Email_Seleccionado__c, CC_Tipo_Gestion__c FROM Case WHERE Id = :correo.ParentId];

        Task actividadTraslado = new Task();
        actividadTraslado.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        actividadTraslado.Type = 'Responder a cliente';
        actividadTraslado.Subject = 'Responder a cliente';
        actividadTraslado.WhatId = correo.ParentId;
        actividadTraslado.Subject = correo.Subject;
        actividadTraslado.Description = correo.TextBody.left(32000);
        actividadTraslado.Status = 'Completed';
        actividadTraslado.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
        actividadTraslado.CC_Correo_Asociado_Id__c = correo.Id;
        actividadTraslado.ActivityDate = System.today();
        actividadTraslado.AV_Purpose__c = caso.CC_Tipo_Gestion__c;
        actividadesTraslado.add(actividadTraslado);

        caso.CC_Referencia_Correo_Saliente__c = '';
        caso.CC_Ultima_Interaccion__c = 'Nuevo';
        caso.CC_Fecha_Ultima_Interaccion__c = System.now();
        caso.CC_Tipo_Gestion__c = null;
        
        if (caso.OS_Cerrado_Operativa__c) {
            caso = OS_Case.responderCerrar(caso);
        }
        caso.OS_Email_Seleccionado__c = null;
        casos.add(caso);
    }

    private static void envioRemitirColaborador(EmailMessage correo, List<Case> casos, List<Task> actividadesTraslado) {
        Case caso = [SELECT CC_Referencia_Correo_Saliente__c, CC_Ultima_Interaccion__c, CC_Fecha_Ultima_Interaccion__c, OS_Cerrado_Operativa__c, Status, CC_Tipo_Gestion__c FROM Case WHERE Id = :correo.ParentId];

        Task actividadTraslado = new Task();
        actividadTraslado.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        actividadTraslado.Type = 'Remitir Colaborador';
        actividadTraslado.Subject = 'Remitir Colaborador';
        actividadTraslado.WhatId = correo.ParentId;
        actividadTraslado.Subject = correo.CC_Procedencia__c;
        actividadTraslado.CC_Grupo_Colaborador_Id__c = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = :correo.CC_Grupo_Colab__c LIMIT 1].Id;
        actividadTraslado.Description = correo.TextBody.left(32000);
        actividadTraslado.Status = 'Completed';
        actividadTraslado.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
        actividadTraslado.CC_Correo_Asociado_Id__c = correo.Id;
        actividadTraslado.ActivityDate = System.today();
        actividadTraslado.AV_Purpose__c = caso.CC_Tipo_Gestion__c;
        actividadesTraslado.add(actividadTraslado);

        caso.CC_Referencia_Correo_Saliente__c = '';
        caso.CC_Ultima_Interaccion__c = 'Nuevo';
        caso.CC_Fecha_Ultima_Interaccion__c = System.now();
        caso.CC_Tipo_Gestion__c = null;
        if (caso.OS_Cerrado_Operativa__c) {
            caso = OS_Case.responderCerrar(caso);
        }
        //caso.CBK_Traslado_Remitido__c = null;
        casos.add(caso);
    }

    private static void respuestaRemitirColaborador(EmailMessage correo, List<Case> casos) {

        //Cambio de estado del caso
        Case caso = [SELECT Status FROM Case WHERE Id = :correo.ParentId];
        if (caso.Status == 'Pendiente Colaborador' || caso.Status == 'Cerrado') {
            caso.Status = 'Activo';
            casos.add(caso);

            //Cierre de la actividad de envío del traslado a grupo colaborador
            CC_Activity.finalizarActividadCaso(correo.ParentId, 'Remitir Colaborador', null, null);
        }
    }

    private static void envioSolicitudInfo(EmailMessage correo, List<Case> casos, List<Task> actividadesTraslado) {
        //Recuperamos el plazo que tendrá cliente/empleado para responder al mail de Sol. Inf. para asignarlo al caso y tarea
        //Posteriormente habrá un PB que cerrará el caso y enviará un mail en el momento que cumpla el plazo
        Datetime fechaFinPlazo = null;
        
        //Cambio de estado del caso
        Case caso = [SELECT CC_Fecha_Ultima_Interaccion__c, CC_Ultima_Interaccion__c, CC_Referencia_Correo_Saliente__c, Status, RecordType.DeveloperName, CC_Tipo_Gestion__c FROM Case WHERE Id = :correo.ParentId];
        /*if (caso.RecordType.DeveloperName.startsWith('CC')) {
            fechaFinPlazo = CC_Cierre_Automatico_Methods.CC_Cierre_Automatico_SolicitudInformacion(correo.ParentId);
        }*/
        caso.Status = 'Pendiente Cliente';
        caso.CC_Fecha_Cierre_SolInf__c = fechaFinPlazo;
        caso.CC_Ultima_Interaccion__c = 'Nuevo';
        caso.CC_Fecha_Ultima_Interaccion__c = System.now();
        caso.CC_Fecha_Solicitud_Informacion__c = System.today();

        //Nueva actividad de tipo "Solicitud Información"
        Task actividadTraslado = new Task();
        actividadTraslado.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        actividadTraslado.Type = 'Solicitud Información';
        actividadTraslado.Subject = 'Solicitud Información';
        actividadTraslado.WhatId = correo.ParentId;
        actividadTraslado.CC_Fecha_FinPlazo_SolInf__c = fechaFinPlazo;
        actividadTraslado.Status = 'Open';
        actividadTraslado.Description = correo.TextBody.left(32000);
        actividadTraslado.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
        actividadTraslado.ActivityDate = System.today();
        actividadTraslado.AV_Purpose__c = caso.CC_Tipo_Gestion__c;
        actividadesTraslado.add(actividadTraslado);
        
        caso.CC_Referencia_Correo_Saliente__c = ''; //Se vacía la referencia de correo saliente del caso para evitar que se reuse por error
        caso.CC_Tipo_Gestion__c = null;
        casos.add(caso);
    }

    private static void respuestaSolicitudInfo(EmailMessage correo, List<Case> casos) {
        Case caso = [SELECT RecordType.DeveloperName, Status, CC_Canal_Procedencia__c, CC_Autoasignado_Coordinador__c, CC_Cola_Procedencia__c
                        FROM Case WHERE Id = :correo.ParentId];
        if (caso.Status == 'Pendiente Cliente') {
            caso.Status = 'Activo';
            caso.CC_Ultima_Interaccion__c = 'Respuesta de solicitud de información';
            caso.CC_Fecha_Ultima_Interaccion__c = System.now();
            caso.CC_Situacion_Caso__c = 'Respuesta cliente';

            //Si la propiedad del caso no está fijada a un coordinador, se devuelve el caso a la cola para
            //que lo pueda atender cualquier agente, no solo el propietario previo a la solicitud
            if (!caso.CC_Autoasignado_Coordinador__c && caso.CC_Cola_Procedencia__c != null) {
                caso.OwnerId = [SELECT Id FROM Group WHERE DeveloperName = :caso.CC_Cola_Procedencia__c].Id;
            }

            casos.add(caso);

            //Cierre de la actividad de envío del traslado a grupo colaborador
            CC_Activity.finalizarActividadCaso(correo.ParentId, 'Solicitud Información', null, null);
        
        } else if (caso.Status == 'Cerrado') {
   
            //Para solicitudes info se reabre el caso aunque se hubiera cerrado
            OS_Case.reapertura(caso.Id);
        }        
    }
    
    public static void respuestaCliente(EmailMessage correo, List<Case> casos) {
        //Cuando un cliente responde a un email enviado desde la operativa reponder a cliente se envía un email automático

        Case caso = [SELECT RecordType.DeveloperName, Status, CC_Numero_Documento__c, CC_Idioma__c, AccountId, ContactId,
                        CC_Canal_Procedencia__c, CC_Autoasignado_Coordinador__c, CC_Cola_Procedencia__c
                        FROM Case WHERE Id = :correo.ParentId];
        
        List<CC_Queue_Procedencia__mdt> queues = [SELECT CC_Queue__c, CC_Canal_Procedencia__c FROM CC_Queue_Procedencia__mdt
                                                    WHERE CC_Canal_Procedencia__c = :caso.CC_Canal_Procedencia__c];
        
        if (!queues.isEmpty()) {
            Group cola = [SELECT Id FROM Group WHERE TYPE = 'Queue' AND DeveloperName = :queues[0].CC_Queue__c LIMIT 1];
            caso.OwnerId = cola.Id;
        } else {
            Group cola = [SELECT Id FROM Group WHERE TYPE = 'Queue' AND DeveloperName = 'CC_Inbound_Email_AC' LIMIT 1];
            caso.OwnerId = cola.Id;
        }
        
        String htmlBody;
        if (caso.CC_Idioma__c == 'en') {
            htmlBody = [SELECT DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_Respuesta_Automatica_Cliente_en' LIMIT 1].HtmlValue;
        } else if (caso.CC_Idioma__c == 'ca') {
            htmlBody = [SELECT DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_Respuesta_Automatica_Cliente_ca' LIMIT 1].HtmlValue;
        } else {
            htmlBody = [SELECT DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CC_Respuesta_Automatica_Cliente_es' LIMIT 1].HtmlValue;
        }
    }

    private void comprobarAnexosPermitidos(List<EmailMessage> listNewObj, Map<Id, EmailMessage> mapNewObj) {
        
        if (!listNewObj.isEmpty()) {
            // Se recopilan los correos salientes que contienen anexo
            List<Id> correosSalientes = new List<Id>();
            for (EmailMessage correo : listNewObj) {
                if (!correo.Incoming) {
                    correosSalientes.add(correo.Id);
                }
            }
            if (!correosSalientes.isEmpty()) {
                //Se obtienen las extensiones permitidas para un anexo
                List<String> extensionesPermitidas = new List<String>();
                for (CC_ConfiguracionAnexoPermitido__mdt extensionPermitida : [SELECT CC_Extension__c FROM CC_ConfiguracionAnexoPermitido__mdt]) {
                    extensionesPermitidas.add(extensionPermitida.CC_Extension__c);
                }
                // Se comprueban las extensiones de los anexos y se impide el envío del correo en caso de que contenga algún anexo con extensión no permitida.
                for (ContentDocumentLink contentDocumentLink : [SELECT LinkedEntityId FROM ContentDocumentLink
                                                                WHERE ContentDocument.FileExtension NOT IN :extensionesPermitidas
                                                                AND LinkedEntityId IN :correosSalientes]) {           
                    EmailMessage correoSalienteConAnexoProhibido = mapNewObj.get(contentDocumentLink.LinkedEntityId);
                    correoSalienteConAnexoProhibido.addError('El correo tiene un adjunto con una extensión no petmitida.'); 
                }
            }
        }
    }

    public static void limitarAdjuntos(List<EmailMessage> listNewObj){
        if (!listNewObj.isEmpty()) {
            List<EmailMessage> correosSalientesAnexo = new List<EmailMessage>();
            List<Id> correosSalientes = new List<Id>();
            // Se recopilan los correos salientes que contienen anexo
            for (EmailMessage correo : listNewObj) {
                if (!correo.Incoming && correo.HasAttachment && !correo.OS_AdjuntoLink__c) {
                    correosSalientesAnexo.add(correo);
                    correosSalientes.add(correo.Id);
                }
            }
            
            if(!correosSalientesAnexo.isEmpty()){
                Set<Id> contentDocLinkId = new Set<Id>();
                Decimal limiteMB = [SELECT Id, OS_Limite_Adjuntos_MB__c FROM OS_Limite_Adjuntos__c WHERE Name = 'OS_Limit_Adjuntos' LIMIT 1].OS_Limite_Adjuntos_MB__c;
                List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId, LinkedEntity.Id FROM ContentDocumentLink WHERE LinkedEntity.Id IN :correosSalientes];

                for(ContentDocumentLink contentDoc : contentDocumentLinks){
                    contentDocLinkId.add(contentDoc.ContentDocumentId);
                }

                Map<Id, ContentDocument> mapacontentDoc = new Map<Id, ContentDocument> ([SELECT Id, ContentSize FROM ContentDocument WHERE Id IN :contentDocLinkId]);
                Map<Id, List<Id>> mapaEmailContentDocId = new Map<Id, List<Id>>();
                String error = '';

                for(ContentDocumentLink contentDocLink : contentDocumentLinks){
                    if(mapaEmailContentDocId.containsKey(contentDocLink.LinkedEntity.Id)){
                        mapaEmailContentDocId.get(contentDocLink.LinkedEntity.Id).add(contentDocLink.ContentDocumentId);
                    }
                    else {
                        mapaEmailContentDocId.put(contentDocLink.LinkedEntity.Id, new List<Id> {contentDocLink.ContentDocumentId});
                    }
                }
                for(EmailMessage email : correosSalientesAnexo){
                    if(mapaEmailContentDocId.containsKey(email.Id)){
                        Decimal sumSize = 0;
                        for(Id docContent : mapaEmailContentDocId.get(email.Id)){
                            if(mapacontentDoc.containsKey(docContent)){
                                sumSize += mapacontentDoc.get(docContent).ContentSize / 1000000;//Para pasar de bytes a MB
                            }

                            if(sumSize > limiteMB){
                                error = 'Los archivos adjuntos superan la capacidad de ' + limiteMB + ' MB y serán enviados como vínculos html. Para poder enviar el correo con los';
                                error += ' adjuntos transformados en vínculos hay que marcar previamente ‘Permitir trasformar adjuntos a link html’ en el borrador de este correo.';
                                email.addError(error);
                            }
                            
                        }
                    }
                }

            }
            
        }
    }

    private static void validarBuzonSalida(List<EmailMessage> listNewObj) {

        Set<Id> correosSalientes = new Set<Id>();
        for(EmailMessage correo : listNewObj) {
            if(!correo.Incoming) {
                correosSalientes.add(correo.Id);
            }
        }
        if(!correosSalientes.isEmpty()) {
            User[] usuario = [SELECT Id, Profile.Name, Department FROM User WHERE Id=:UserInfo.getUserId() AND Profile.Name LIKE 'OS_%' AND Department != null];

            //El usuario es COPS
            if(!usuario.isEmpty()){
                String[] departamentosUsuario = usuario[0].Department.split('/');
                Set<String> buzonesValidosUsuario = new Set<String>();
            
                for (CC_Buzones_Por_Defecto__mdt buzonDefecto: [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE OS_Departamento__c =: departamentosUsuario]){
                    buzonesValidosUsuario.add(buzonDefecto.CC_Direccion_Correo__c);
                }
                for (EmailMessage correo : listNewObj){
                    //correo saliente
                    if(!correo.Incoming && String.isNotEmpty(correo.FromAddress)){
                        //valido departamento
                        if(!buzonesValidosUsuario.contains(correo.FromAddress)){
                            correo.addError('El buzón de salida indicado no está asignado a su área de trabajo.');
                        }
                    }
                }
            }
            //El usuario no es COPS, o es COPS y no tiene el departamento informado
            else {
                //Se obtiene de CC_Buzones_Por_Defecto__mdt la lista de buzones de salida válidos
                List<String> buzonesSalidaValidos = new List<String>();
                for (CC_Buzones_Por_Defecto__mdt buzonPorDefecto : [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt]) {
                    buzonesSalidaValidos.add(buzonPorDefecto.CC_Direccion_Correo__c);
                }
                //Si el correo saliente tiene un buzón de salida que no está en la lista, se muestra un error
                for (EmailMessage correo : listNewObj) {
                    if (!correo.Incoming && String.isNotEmpty(correo.FromAddress) && !buzonesSalidaValidos.contains(correo.FromAddress)) {
                        correo.addError('El buzón de salida indicado no es apto para el envío de correos.', false);
                    }
                }
            }
        }
    }
}