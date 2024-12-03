public with sharing class OS_EmailService implements Messaging.InboundEmailHandler {

    public class WrapperValoresEmail {
        public Messaging.InboundEmail emailQueue {get;set;}
        public Messaging.InboundEnvelope envelopeQueue {get;set;}
        public Map<String, Integer> reintentosMap {get;set;}
    }


    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Map<String, Integer> mapaReintentos = new Map<String, Integer>();
        Messaging.InboundEmailResult resultado = new Messaging.InboundEmailResult();
        resultado = procesarCorreoEntrante(email, envelope, mapaReintentos);
        return resultado;
    }

    public Messaging.InboundEmailResult procesarCorreoEntrante(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope, Map<String, Integer> reintentos) {

        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        result.success=false;
        String messageId =null;
        String parentMessageId = null;

        try{
            if (!Test.isRunningTest()) {CBK_log.auditemail(email,envelope);}

            
            String body = '';

            if (String.isNotBlank(email.plainTextBody)) {
                body = email.plainTextBody.left(131072);
            } else if (String.isNotBlank(email.htmlBody)) {
                body = email.htmlBody.stripHtmlTags().left(131072);
            }

            //Miramos cual es el canal de procedencia del toaddress del correo entrante
            List<OS_Correo__mdt> correoDependencia = [SELECT OS_Email__c, OS_Cola_Procedencia__c, OS_Canal_Procedencia__c, OS_Correo__c, OS_Recordtype_Caso_Defecto__c
                                                        FROM OS_Correo__mdt WHERE OS_Email__c = :envelope.toAddress LIMIT 1];

            List<SEG_Buzon__mdt> buzonesSEG = SEG_Buzon__mdt.getAll().values();
            List<String> direccionesSEG = new List<String>();
            for (SEG_Buzon__mdt buzon : buzonesSEG) {
                direccionesSEG.add(buzon.SEG_Correo_de_procedencia__c);
            }
            Boolean segMailRelated =false;

            for (String address : direccionesSEG){ 
                if((email.toAddresses!=null && !email.toAddresses.isEmpty() && email.toAddresses.contains(address)) || (email.ccAddresses!=null && !email.ccAddresses.isEmpty() && email.ccAddresses.contains(address))) {
                    segMailRelated = true;       
                }
            }
            

            List<Group> colasTotalesCOPS = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE DeveloperName LIKE 'OS_%'];
            List<Group> colas = new List<Group>();
            String procedenciaEntrante = '';
            String colaEntrante = '';
            String recordTypeCasoDefecto = '';
            if (!correoDependencia.isEmpty()) {
                procedenciaEntrante = correoDependencia[0].OS_Canal_Procedencia__c;
                for(Group colasCOPS: colasTotalesCOPS) {
                    if(colasCOPS.Type == 'Queue' && colasCOPS.DeveloperName == correoDependencia[0].OS_Cola_Procedencia__c) {
                        colas.add(colasCOPS);
                    }
                }
                if (!colas.isEmpty()) {
                    colaEntrante = colas[0].Id;
                }
                if(correoDependencia[0].OS_Recordtype_Caso_Defecto__c != null) {
                    recordTypeCasoDefecto = correoDependencia[0].OS_Recordtype_Caso_Defecto__c;
                }
            }

            //Recuperamos todas las semillas del email entrante
            Set<String> referenciaSet = OS_Metodos_EmailServices.referenciaCorreoSet(email);

            //Todas las tareas relacionadas con las referencias encontradas
            List<Task> tareasOrigenList = new List<Task>();
            //Listado de casos con una tarea relacionada con la semilla
            List<Case> casoOrigenList = new List<Case>();
            
            //Tarea relacionada con la referencia 
            List<Task> tareaOrigen = new List<Task>();
            //Caso relacionado con la tarea
            List<Case> casoOrigen = new List<Case>();

            //Auxiliares
            Set<Id> casesTareaIdSet = new Set<Id>();
            Map<String, Task> refeTareaMap = new Map<String, Task>();   
            Map<Id, Case> idCaseMap = new Map<Id, Case>();
            Map<String, String> mapaProcTel = new Map<String, String>();

            //Si hay referencias buscamos la tarea y el caso
            if(!referenciaSet.isEmpty() && referenciaSet != null) {
                //Buscamos todas las tareas relacionadas con las referencias encontradas
                tareasOrigenList = [SELECT WhatId, Type, CC_Referencia_Correo_Saliente__c FROM Task WHERE CC_Referencia_Correo_Saliente__c = :referenciaSet
                                        AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task') AND WhatId != null];
                                                                
                for(Task tarea: tareasOrigenList){
                    casesTareaIdSet.add(tarea.WhatId);
                    refeTareaMap.put(tarea.CC_Referencia_Correo_Saliente__c, tarea);
                } 

                if(!casesTareaIdSet.isEmpty() && casesTareaIdSet != null) {
                    //Buscamos el listado de casos con una tarea relacionada con la semilla
                    casoOrigenList = [SELECT Id, CC_Canal_Procedencia__c, Origin, OwnerId, OS_GrupoTrabajo__c, Status, Subject, CC_Autoasignado_Coordinador__c, 
                                        OS_Alerta_Fecha__c, ContactId, CC_Cola_Procedencia__c, RecordTypeId, CC_Numero_Documento__c, CC_Idioma__c, AccountId
                                        FROM Case WHERE Id=:casesTareaIdSet];

                    

                    

                    if(!casoOrigenList.isEmpty()) {
                        Boolean origenPhone = false;
                        for(Case caso: casoOrigenList){
                            idCaseMap.put(caso.Id, caso);
                            if(caso.Origin == 'Phone'){
                                origenPhone = true;
                            }
                        }
                        if(origenPhone){

                            for(CC_Lista_Valores__c valor : [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c 
                                                                WHERE CC_Activa__c = true 
                                                                AND CC_Lista__r.Name = 'COPS: Relación Canal de procedencia teléfono y Canal de procedencia buzón']){
                                mapaProcTel.put(valor.Name, valor.CC_Valor__c);  
                            }
                        }

                        //Para las referencias por orden de entrada
                        for(String refe: referenciaSet){
                            //Buscamos la tarea relacionada con la referencia
                            if(refeTareaMap.containsKey(refe)){
                                Task tarea = refeTareaMap.get(refe);
                                //Buscamos el caso relacionado con la tarea
                                if(idCaseMap.containsKey(tarea.WhatId)){
                                    Case caso = idCaseMap.get(tarea.WhatId);
                                    //Si el origen del caso es email, el canal de procedencia tendrá que coincidir --- si no coincide el canal de procedencia, se buscará el caso relacionado con la siguiente referencia
                                    if(caso.Origin == 'Email'){
                                        if(caso.CC_Canal_Procedencia__c == procedenciaEntrante){
                                            tareaOrigen.add(tarea);
                                            casoOrigen.add(caso);
                                            break;
                                        }
                                    }
                                    //Si el caso es de origen teléfono, buscamos en la lista de valores la equivalencia para validar el buzón de entrada.
                                    else if(caso.Origin == 'Phone'){
                                        if(mapaProcTel.containsKey(caso.CC_Canal_Procedencia__c)){
                                            if(mapaProcTel.get(caso.CC_Canal_Procedencia__c) == procedenciaEntrante){
                                                tareaOrigen.add(tarea);
                                                casoOrigen.add(caso);
                                                break;
                                            }

                                        }
                                    }
                                    //Si el origen del caso no es email, cogemos la tarea y caso encontrados
                                    else{
                                        tareaOrigen.add(tarea);
                                        casoOrigen.add(caso);
                                        break;
                                    }
                                }
                            } 
                        }
                    } 
                }
            }
           
            //Si se ha encontrado una tarea y un caso relacionado, se vincula a este el email entrante
            if (!tareaOrigen.isEmpty() && !casoOrigen.isEmpty()) {
                if(segMailRelated){
                    casoOrigen[0].SEG_Id_Related_Mail__c = email.messageId;
                }
                //Si el owner es un usuario, validamos que esté activo
                if(String.valueOf(casoOrigen[0].OwnerId).startsWith('005')) {
                    Boolean usuarioActivo = OS_Metodos_EmailServices.usuarioActivo(casoOrigen[0]);
                    if (usuarioActivo == false){
                        OS_Metodos_EmailServices.asignarColaUsuarioInactivo(casoOrigen[0], colaEntrante, colasTotalesCOPS);
                    }
                }
                if (tareaOrigen[0].Type == 'Traslado Colaborador') {
                    //Respuesta entrante de grupo colaborador
                    EmailMessage emailmessage = OS_Metodos_EmailServices.respuestaTrasladoColaborador(email, tareaOrigen[0].WhatId, body, envelope.toAddress, colasTotalesCOPS, casoOrigen[0]);
                    messageId = emailmessage.id;
                    parentMessageId = emailmessage.ParentId;
                } else if (tareaOrigen[0].Type == 'Solicitud Información') {
                    //Respuesta entrante de solicitud de información de cliente
                    EmailMessage emailmessage = OS_Metodos_EmailServices.respuestaSolicitudInfo(email, tareaOrigen[0].WhatId, body, envelope.toAddress, colasTotalesCOPS, casoOrigen[0]);
                    messageId = emailmessage.id;
                    parentMessageId = emailmessage.ParentId;
                } else if (tareaOrigen[0].Type == 'Remitir Colaborador') {
                    //Respuesta entrante de remisión del caso a grupo colaborador
                    EmailMessage emailmessage = OS_Metodos_EmailServices.respuestaRemitirColaborador(email, tareaOrigen[0].WhatId, body, envelope.toAddress, colasTotalesCOPS, casoOrigen[0]);
                    messageId = emailmessage.id;
                    parentMessageId = emailmessage.ParentId;
                } else if (tareaOrigen[0].Type == 'Responder a cliente') {
                    //Respuesta entrante de respuesta de cliente
                    EmailMessage emailmessage = OS_Metodos_EmailServices.respuestaCliente(email, tareaOrigen[0].WhatId, body, envelope.toAddress, colasTotalesCOPS, casoOrigen[0]);
                    messageId = emailmessage.id;
                    parentMessageId = emailmessage.ParentId;
                } else if (tareaOrigen[0].Type == 'Acuse de recibo') {
                    //Respuesta entrante de respuesta de cliente
                    EmailMessage emailmessage = OS_Metodos_EmailServices.respuestaCliente(email, tareaOrigen[0].WhatId, body, envelope.toAddress, colasTotalesCOPS, casoOrigen[0]);
                    messageId = emailmessage.id;
                    parentMessageId = emailmessage.ParentId;
                } else {
                    //En caso de ninguna de las anteriores, se adjunta el email al caso para no perderlo
                    EmailMessage emailmessage = OS_Metodos_EmailServices.adjuntarEmailAlCaso(email, tareaOrigen[0].WhatId, body, envelope.toAddress, casoOrigen[0]);
                    messageId = emailmessage.id;
                    parentMessageId = emailmessage.ParentId;
                }
            } 
            else {
                //El correo ha llegado sin referencia o ésta no apunta a ninguna tarea o la procedencia del caso no coincide con la procedencia de email entrante --> Se crea nuevo caso
                //Determinar CR
                List<Id> reglaClaisificacionId = determinarCR(email.fromAddress, correoDependencia, email.toAddresses, email.ccAddresses, email.Subject, body);

                List<SEG_Regladeclasificacion__c> reglaClasificacionRapida = new List<SEG_Regladeclasificacion__c>();
                List<SEG_ClasificacionRapida__c> clasificacionRapida = new List<SEG_ClasificacionRapida__c>();

                if (reglaClaisificacionId.size() > 0) {
                    boolean crFound = false;
                    List<SEG_Multivalor__c> lstMvTotales = [SELECT SEG_TipodeValor__c, SEG_Reglas_Clasificacion__c FROM SEG_Multivalor__c WHERE SEG_Reglas_Clasificacion__c IN :reglaClaisificacionId ORDER BY SEG_Reglas_Clasificacion__r.OS_OrdenEjecucion__c];
                    List<SEG_Regladeclasificacion__c> lstRegClas = [SELECT SEG_ClasificacionRapida__c, OS_Logica_Multivalor__c FROM SEG_Regladeclasificacion__c WHERE Id IN :reglaClaisificacionId ORDER BY OS_OrdenEjecucion__c];

                    for (SEG_Regladeclasificacion__c rc : lstRegClas) {
                        //Lógica multivalor AND o NULL
                        if (rc.OS_Logica_Multivalor__c != 'OR' && !crFound) {
                            Integer countMvTotales = 0;
                            Integer countMvFound = 0;
                            //Contar multivalores por cada regla de clasificación
                            for (SEG_Multivalor__c mv : lstMvTotales) {
                                if (mv.SEG_Reglas_Clasificacion__c == rc.Id && mv.SEG_TipodeValor__c != 'Asunto a excluir' && mv.SEG_TipodeValor__c != 'Cuerpo a excluir') {
                                    countMvTotales++;
                                }
                            }
                            //Contar multivalores que cumplen por cada regla
                            for (Id rcId : reglaClaisificacionId) {
                                if (rcId == rc.Id) {
                                    countMvFound++;
                                }
                            }
                            //Comprobar si se cumplen todos los multivalores de la regla
                            if (countMvFound == countMvTotales) {
                                reglaClasificacionRapida.add(rc);
                                crFound = true;
                            }
                        } else if (rc.OS_Logica_Multivalor__c == 'OR' && !crFound) {
                            reglaClasificacionRapida.add(rc);
                            crFound = true;
                        }
                    }

                    if (reglaClasificacionRapida.size() > 0) {
                        clasificacionRapida = [SELECT SEG_Canaldeentrada__c, SEG_Tematica__c, SEG_Producto__c, SEG_Motivo__c, SEG_Prioridad__c,
                                                OS_Solucion__c, OS_Causa__c, OS_EstadoCaso__c, OS_GrupoTrabajo__c, OS_GrupoTrabajo__r.OS_GrupoTrabajo__c
                                                FROM SEG_ClasificacionRapida__c WHERE Id = :reglaClasificacionRapida[0].SEG_ClasificacionRapida__c];
                    }
                }

                if (!clasificacionRapida.isEmpty() && clasificacionRapida[0].OS_GrupoTrabajo__c != null) {
                    List<Group> colas2 = new List<Group>();
                    for(Group colasCOPS: colasTotalesCOPS) {
                        if(colasCOPS.Type == 'Queue' && colasCOPS.Name == clasificacionRapida[0].OS_GrupoTrabajo__r.OS_GrupoTrabajo__c) {
                            colas2.add(colasCOPS);
                        }
                    }
                    if (!colas2.isEmpty()) {
                        colaEntrante = colas2[0].Id;
                    }
                }

                //Identificación del cliente si hay una sola cuenta y contacto con el email remitente
                Boolean recordTypeEmpleado = false;
                Id accountId = null;
                Id contactId = null;
                String tipocliente = '';
                
                //Si el campo recordTypeCasoDefecto (correoDependencia[0].OS_Recordtype_Caso_Defecto__c) está informado, se buscarán solo los contactos de ese tipo
                if(recordTypeCasoDefecto != '') {
                    if(recordTypeCasoDefecto == 'OS_Empleado') { tipocliente = 'empleado';
                    }
                    else if(recordTypeCasoDefecto == 'OS_Cliente') { tipocliente = 'cliente';
                    }
                }

                Map<Account, List<Contact>> mapaCuentasContactos = OS_Identificacion_Auto.identificarCliente('Email', email.fromAddress, tipocliente);

                //El formato del resultado de la identificación automática es <Account, List<Contact>>
                if (mapaCuentasContactos.size() == 1 && mapaCuentasContactos.values()[0].size() == 1) {
                    Contact contactoIdentificado = mapaCuentasContactos.values()[0][0];
                    accountId = contactoIdentificado.AccountId;
                    contactId = contactoIdentificado.Id;
                }
                //Si la lista no está vacía se comprueba si contiene empleados o clientes.
                if (mapaCuentasContactos != null && !mapaCuentasContactos.isEmpty()) {
                    recordTypeEmpleado = mapaCuentasContactos.values()[0][0].RecordType.DeveloperName == 'CC_Empleado' 
                                        || mapaCuentasContactos.values()[0][0].RecordType.DeveloperName == 'OS_Buzon_Contact';
                } 

                Case caso = new Case();
                //Si el campo recordTypeCasoDefecto (correoDependencia[0].OS_Recordtype_Caso_Defecto__c) está informado, se asignará un recordtype por defecto independientemente del resto de condiciones
                if(recordTypeCasoDefecto != '') {
                    caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', recordTypeCasoDefecto);
                }
                else if(recordTypeEmpleado) { caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Empleado');
                } 
                else { caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
                }

                if(segMailRelated){

                    caso.SEG_Id_Related_Mail__c = email.messageId;
                }
                caso.Origin = 'Email';
                caso.Subject = email.Subject.left(255);
                caso.Description = body.left(32000);
                caso.AccountId = accountId;
                caso.ContactId = contactId;
                caso.OwnerId = colaEntrante;
                caso.CC_MailTelfNotif__c = email.fromAddress.length() > 80 ? '' : email.fromAddress;
                caso.OS_Remitente_Inicial__c = email.fromAddress.length() > 80 ? '' : email.fromAddress;
                caso.CC_Tipo_Cliente__c = null;

                if (!clasificacionRapida.isEmpty()) {
                    caso.OS_GrupoTrabajo__c = clasificacionRapida[0].OS_GrupoTrabajo__r.OS_GrupoTrabajo__c;
                    caso.Status = clasificacionRapida[0].OS_EstadoCaso__c;//Aquí
                    caso.Priority = clasificacionRapida[0].SEG_Prioridad__c;
                    caso.CC_MCC_Tematica__c = clasificacionRapida[0].SEG_Tematica__c;
                    caso.CC_MCC_ProdServ__c = clasificacionRapida[0].SEG_Producto__c;
                    caso.CC_MCC_Motivo__c = clasificacionRapida[0].SEG_Motivo__c;
                    caso.CC_MCC_Solucion__c = clasificacionRapida[0].OS_Solucion__c;
                    caso.CC_MCC_Causa__c = clasificacionRapida[0].OS_Causa__c;
                    caso.OS_ReglaUtilizada__c = reglaClasificacionRapida[0].id;
                    caso.OS_ViaClasificacion__c = 'Regla Clasificación';
                }
                List<CC_Lista_Valores__c> clasificacionesListaValores = [SELECT Id, Name, CC_Valor__c, CC_Lista__r.Name, CC_Activa__c FROM CC_Lista_Valores__c
                                                                            WHERE ((CC_Lista__r.Name = 'COPS: Clasificaciones por defecto para Buzones' OR CC_Lista__r.Name = 'COPS: Relación Tipo de Contacto y Canal de Procedencia') 
                                                                                    AND Name = :procedenciaEntrante) 
                                                                            OR 
                                                                            (CC_Lista__r.Name = 'COPS: Acuse de recibo por Buzones' AND CC_Activa__c = TRUE)];
                if (!correoDependencia.isEmpty()) {
                    caso.CC_Canal_Procedencia__c = correoDependencia[0].OS_Canal_Procedencia__c;
                    if (caso.OS_ReglaUtilizada__c == null) {
                        List<CC_Lista_Valores__c> clasificacionesAutomaticas = new List<CC_Lista_Valores__c>();
                        List<CC_Lista_Valores__c> clasificacionContacto = new List<CC_Lista_Valores__c>();

                        for(CC_Lista_Valores__c valorClasificacion: clasificacionesListaValores) {
                            if(valorClasificacion.CC_Lista__r.Name == 'COPS: Clasificaciones por defecto para Buzones' && valorClasificacion.Name == procedenciaEntrante) {
                                clasificacionesAutomaticas.add(valorClasificacion);
                            }
                            if(valorClasificacion.CC_Lista__r.Name == 'COPS: Relación Tipo de Contacto y Canal de Procedencia' && valorClasificacion.Name == procedenciaEntrante) {
                                clasificacionContacto.add(valorClasificacion);
                            }
                        }
                        if (!clasificacionesAutomaticas.isEmpty()) {
                            //Clasificación automática definida para el proceso de buzones
                            Id idMotivo = clasificacionesAutomaticas[0].CC_Valor__c;
                            List<CC_MCC__c> motivos = [SELECT CC_Tematica__c, CC_Producto_Servicio__c FROM CC_MCC__c WHERE Id = :idMotivo];
                            if (!motivos.isEmpty()) {
                                if (motivos[0].CC_Producto_Servicio__c != null) {
                                    //La clasificación indicada existe
                                    Id idProducto = motivos[0].CC_Producto_Servicio__c;
                                    caso.CC_MCC_Tematica__c = [SELECT CC_Tematica__c FROM CC_MCC__C WHERE Id = :idProducto].CC_Tematica__c;
                                    caso.CC_MCC_ProdServ__c = idProducto;
                                    caso.CC_MCC_Motivo__c = idMotivo;
                                } else if (motivos[0].CC_Tematica__c != null) {
                                    Id idTematica = motivos[0].CC_Tematica__c;
                                    caso.CC_MCC_ProdServ__c = motivos[0].id;
                                    caso.CC_MCC_Tematica__C = idTematica;
                                } else {
                                    caso.CC_MCC_Tematica__c= motivos[0].id;
                                }
                                caso.OS_ViaClasificacion__c = 'Por defecto';
                            }
                        }
                        if (!clasificacionContacto.isEmpty()) {
                            caso.CC_Tipo_Contacto__c = clasificacionContacto[0].CC_Valor__c;
                        }
                    }
                }

                
                //Aquí hay que meter el try-catch para controlar el UNABLE_TO_LOCK_ROW
                insert caso;
                
                if(caso.SEG_Id_Related_Mail__c != null && caso.Id != null){
                    SEG_Settings__c delay = SEG_Settings__c.getValues('SEG_DelaySEGCOPS');//.getAll().values();
                    Integer tiempo = delay != null ? Integer.valueOf(delay.SEG_Delay__c) : 1;
                    DateTime dt = DateTime.now();
                    Long dateInMilliseconds = dt.getTime();

                    AsyncOptions options = new AsyncOptions();
                    options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                    .addId(caso.Id)
                    .addString(String.valueOf(dateInMilliseconds))
                    .build();
                    options.MinimumQueueableDelayInMinutes = Integer.valueOf(tiempo);
    
                    
                    try {
                        ID jobID = System.enqueueJob(new SEG_CasosSEG_COPSrelacionados(email.messageId, email.htmlBody, email.subject), options);
                          
                    } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);  }
                }
                
                
                if ((caso.CC_Canal_Procedencia__c == 'Buzón UAFE' || caso.CC_Canal_Procedencia__c == 'Buzón UAFE Express') && caso.OS_ViaClasificacion__c != 'Regla Clasificación') {
                    //al no encontrar clasificación rapida en SF llamamos a Cognitive
                    OS_cognitiveCR.getCRCognitive(caso.Id);
                }

                String nuevoHtmlBody = email.htmlBody;
                if (String.isNotBlank(nuevoHtmlBody) && nuevoHtmlBody.length() > 131072) {
                    nuevoHtmlBody = nuevoHtmlBody.left(131072);
                }

                //Gestion adjuntos
                Map<String, Object> mapaGestionAdjuntos = OS_Metodos_EmailServices.gestionAdjuntos(email, caso, nuevoHtmlBody);
                nuevoHtmlBody = (String)mapaGestionAdjuntos.get('nuevoHtmlBody');
                Set<Id> listaContentVersionId = (Set<Id>)mapaGestionAdjuntos.get('listaContentVersionId');
                //Creamos el mail entrante y lo asociamos al caso
                EmailMessage crearEmailMessage = crearEmailMessage(email, envelope.toAddress, caso.Id, null, body, nuevoHtmlBody);
                //Crear content document link
                OS_Metodos_EmailServices.crearContentDocumentLink(listaContentVersionId, crearEmailMessage, caso);  
                
                //Acuse activo para este buzón
                Boolean isAcuse = false;
                List<CC_Lista_Valores__c> buzonesActivos = new List<CC_Lista_Valores__c>();
                for(CC_Lista_Valores__c valorClasificacion: clasificacionesListaValores) {
                    if(valorClasificacion.CC_Lista__r.Name == 'COPS: Acuse de recibo por Buzones' && valorClasificacion.Name == caso.CC_Canal_Procedencia__c && valorClasificacion.CC_Activa__c == true) {
                        buzonesActivos.add(valorClasificacion);
                        
                    }
                    
                }
                if (buzonesActivos.size() > 0) {
                    isAcuse = true;
                }
                //DETECTAR IDIOMA POR COGNITIVE Y ENVIAR ACUSE DE RECIBO
                List<Id> casoId = new List<Id>{caso.Id};
                OS_Detector_Idioma.setIdiomaCaso(casoId, email.fromAddress, correoDependencia[0].OS_Correo__c, correoDependencia[0].OS_Canal_Procedencia__c, email.htmlBody, isAcuse);
                result.success = true;
            }

            CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
            wResult.Status = (result.success) ? 'OK' : 'KO';
            wResult.Detail = (result.success) ? 'Envio correcto' : 'Error procesando el correo';
            wResult.CaseId = parentMessageId;
            wResult.EmailMessageId = messageId;
            CBK_Log.auditemailResult(wResult, email);

            return result;
        }
        catch (Exception e){
			System.debug('Error + ' + e);
            if(e.getMessage().contains('UNABLE_TO_LOCK_ROW')){
                if(!reintentos.isEmpty() && reintentos.containsKey(email.messageId) && reintentos.get(email.messageId) != null){
                    reintentos.put(String.valueof(email.messageId), reintentos.get(email.messageId) + 1);
                }else{
                        reintentos.put(String.valueof(email.messageId), 0);
                }

                WrapperValoresEmail parametrosJob = new WrapperValoresEmail();
                parametrosJob.emailQueue = email;
                parametrosJob.envelopeQueue = envelope;
                parametrosJob.reintentosMap = reintentos;
                

                AsyncOptions options = new AsyncOptions();
                options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                .addId(UserInfo.getUserId())
                .addString('EmailId')
                .build();
                try {
                    ID jobID = System.enqueueJob(new OS_EmailService_Queueable(parametrosJob), options);    
                } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);  }
            }

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

    public static EmailMessage crearEmailMessage(Messaging.InboundEmail email, String toAddress, Id idCaso, Id contactId, String body, String nuevoHtmlBody) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        result.success = false;
        Task tarea = new Task();
        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        tarea.Type = 'Correo - Entrada';
        tarea.TaskSubtype = 'Email';
        tarea.Subject = email.subject.left(255);
        tarea.ActivityDate = System.today();
        tarea.Status = 'Completed';
        tarea.Description = body.left(32000);
        tarea.WhatId = idCaso;
        tarea.WhoId = contactId;
        insert tarea;

        Datetime parsedDatetime;

        String subjectAcortado = '';
        //US829509: Correos - Limitación caracteres asunto
        if(email.subject.length() > 3000){
            subjectAcortado = email.subject.left(3000);
        }else{
            subjectAcortado = email.subject;
        }
        
        if(email.headers != null){  
            for(Messaging.InboundEmail.Header header : email.headers){
            
                if(header.Name.equalsIgnoreCase('Date')){
                try {
                    if(header.value != null){
                        parsedDatetime = parseoDatetime(header.value);
                    }
                    CBK_log.debug('Parseo temporal OS_EmailService correcto - Subject : ' + subjectAcortado + ' MessageDate: ' + parsedDatetime + ' DateTime.Now(): ' + DateTime.now());
                } catch (Exception e) {
                    parsedDatetime = null;
                    CBK_log.debug('Parseo temporal OS_EmailService incorrecto - Subject : ' + subjectAcortado + ' header.value: ' + header?.value);
                }
                }
            } 
        }

        EmailMessage correo = new EmailMessage();
        correo.Subject = email.Subject;
        correo.Status = '1';
        if (email.ccAddresses != null) {
            correo.CcAddress = String.join(email.ccAddresses, ',');
        }
        correo.FromAddress = email.fromAddress;
        correo.FromName = email.fromName;

        //Configuracion del FWK Headers EmailMessage
        CBK_InboundEmailUtils.PriorityHeaderPetition petition = new CBK_InboundEmailUtils.PriorityHeaderPetition();
        petition.app = 'OS';
        petition.header = email.headers;
        petition.limitCharacters = 31999;

        CBK_InboundEmailUtils.PriorityHeaderResult headerResult = CBK_InboundEmailUtils.getPriorityHeader(petition);

        if(headerResult.priorityHeaders != null){
            correo.Headers = JSON.serialize(headerResult.priorityHeaders);
            if (headerResult.secondPriorityHeaders != null){
                correo.CBK_Second_Priority_Headers__c = JSON.serialize(headerResult.secondPriorityHeaders);
            }
        }

        //Trazabilidad EmailService petición CoE
        correo.MessageIdentifier = email.messageId;
        correo.CBK_sfdcMessageId__c = email.messageId?.left(255);           
        correo.ThreadIdentifier = email.inReplyTo; 
        

        if (String.isNotBlank(nuevoHtmlBody)) {
            correo.HtmlBody = nuevoHtmlBody.left(131072);
        } else if (String.isNotBlank(email.HtmlBody)) {
            correo.HtmlBody = email.HtmlBody.left(131072);
        } else {
            correo.TextBody = body.left(131072);
        }

        correo.Incoming = true;
        correo.MessageDate = parsedDatetime;
        correo.ParentId = idCaso;
        result.success = true;
        
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


    public static String prepararImagenesInline(Messaging.InboundEmail email, List<ContentVersion> listaContentVersion) {
        //Para imágenes, se modifica el tag <image> para que apunte al nuevo registro de ContentVersion:
        String nuevoHtmlBody = '';
        if (String.isNotBlank(email.htmlBody)) {
            nuevoHtmlBody = email.htmlBody.left(131072);
            for (ContentVersion cv : listaContentVersion) {
                if (cv.ExternalDocumentInfo1 != null) {
                    //Se actualiza el HTMLBody
                    //Ejemplo de URL: https://caixabankcc--devcops--c.documentforce.com/sfc/servlet.shepherd/version/download/0681X000001Fg9kQAC
                    try {
                        nuevoHtmlBody = nuevoHtmlBody.replaceAll('cid:' + cv.ExternalDocumentInfo1, '/sfc/servlet.shepherd/version/download/' + cv.Id);
                    } catch (DmlException e) {
                        System.debug('DmlException: ' + e.getMessage());
                        CBK_Log.error(e);
                    }
                }
            }
        }

        /*
        SE DESHABILITA TRATAMIENTO DE IMAGENES INLINE HASTA TENER SOLUCIÓN BASE64
        for (Messaging.Inboundemail.BinaryAttachment binaryAttachment : email.binaryAttachments) {
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
        }
        */
        return nuevoHtmlBody;
    }

    private static List<Id> determinarCR(String fromAddress, List<OS_Correo__mdt> correoDependencia, List<String> toAddresses, List<String> ccAddresses, String subject, String body) {
        //en base a los datos del correo  se busca la regla de clasificación pertinente
        String destinatarioCCUC = '';
        String destinatarioUC = '';
        String remitenteUC = fromAddress.toUpperCase();
        String asuntoUC = subject.toUpperCase();
        String cuerpoUC = body.toUpperCase();
        Map<Id, Id> clasificacionRapidaMap = new Map<Id, Id>();
        List<Id> clasificacionRapida = new List<Id>();

        if (toAddresses != null) {
            String rDestinatario = String.join(toAddresses, ',');
            destinatarioUC = rDestinatario.toUpperCase();
        }

        if (ccAddresses != null) {
            String resultCC = String.join(ccAddresses, ',');
            destinatarioCCUC = resultCC.toUpperCase();
        }

        //V2: Con MAP de Regla de clasificación y lista de multivalor
        Map<Id, Id> reglasClasificacionIds = new Map<Id, Id>();

        Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorDestinatariosCCIncluir = new Map<Id, Map<String, SEG_Multivalor__c>>();
        Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorDestinatariosCCOIncluir = new Map<Id, Map<String, SEG_Multivalor__c>>();
        Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorDestinatariosIncluir = new Map<Id, Map<String, SEG_Multivalor__c>>();
        Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorRemitentesIncluir = new Map<Id, Map<String, SEG_Multivalor__c>>();
        Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorAsuntosIncluir = new Map<Id, Map<String, SEG_Multivalor__c>>();
        Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorCuerposIncluir = new Map<Id, Map<String, SEG_Multivalor__c>>();
        Map<Id, Map<String, SEG_Multivalor__c>> maplistOfMultivalorExcluir = new Map<Id, Map<String, SEG_Multivalor__c>>();

        //Filtrar reglas de clasificación por agrupación buzones
        String procedenciaEntrante = correoDependencia[0].OS_Canal_Procedencia__c;

        for (SEG_Multivalor__c obj : [SELECT SEG_Reglas_Clasificacion__c, SEG_TipodeValor__c, SEG_Valor__c, SEG_ReglaInactiva__c FROM SEG_Multivalor__c
                                        WHERE SEG_ReglaInactiva__c = FALSE AND SEG_CRInactiva__c = FALSE AND SEG_Reglas_Clasificacion__r.OS_AgrupacionBuzon__c = :procedenciaEntrante
                                        AND SEG_Reglas_Clasificacion__r.CBK_Negocio__c = 'Cops' ORDER BY SEG_Reglas_Clasificacion__r.OS_OrdenEjecucion__c]) {

            if (obj.SEG_TipodeValor__c == 'Destinatario CC' && String.isNotBlank(obj.SEG_Valor__c)) {
                reglasClasificacionIds.put(obj.SEG_Reglas_Clasificacion__c, obj.SEG_Reglas_Clasificacion__c);

                if (maplistOfMultivalorDestinatariosCCIncluir.size() == 0 || (!maplistOfMultivalorDestinatariosCCIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c))) {
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c>();
                    listMV.put(obj.SEG_Valor__c, obj);
                    maplistOfMultivalorDestinatariosCCIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
                } else if (maplistOfMultivalorDestinatariosCCIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c)) {
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c>();
                    listMV = maplistOfMultivalorDestinatariosCCIncluir.get(obj.SEG_Reglas_Clasificacion__c);
                    listMV.put(obj.SEG_Valor__c, obj);
                    maplistOfMultivalorDestinatariosCCIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
                }

            } else if (obj.SEG_TipodeValor__c == 'Destinatario CCO') {
                reglasClasificacionIds.put(obj.SEG_Reglas_Clasificacion__c, obj.SEG_Reglas_Clasificacion__c);

                if (maplistOfMultivalorDestinatariosCCOIncluir.size() == 0 || (!maplistOfMultivalorDestinatariosCCOIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c))) {
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c>();
                    listMV.put(obj.SEG_Valor__c, obj);
                    maplistOfMultivalorDestinatariosCCOIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
                } else if (maplistOfMultivalorDestinatariosCCOIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c)) {
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c>();
                    listMV = maplistOfMultivalorDestinatariosCCOIncluir.get(obj.SEG_Reglas_Clasificacion__c);
                    listMV.put(obj.SEG_Valor__c, obj);
                    maplistOfMultivalorDestinatariosCCOIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
                }

            } else if (obj.SEG_TipodeValor__c == 'Destinatario' && String.isNotBlank(obj.SEG_Valor__c)) {
                reglasClasificacionIds.put(obj.SEG_Reglas_Clasificacion__c, obj.SEG_Reglas_Clasificacion__c);

                if (maplistOfMultivalorDestinatariosIncluir.size() == 0 || (!maplistOfMultivalorDestinatariosIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c))) {
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c>();
                    listMV.put(obj.SEG_Valor__c, obj);
                    maplistOfMultivalorDestinatariosIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
                } else if (maplistOfMultivalorDestinatariosIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c)) {
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c>();
                    listMV = maplistOfMultivalorDestinatariosIncluir.get(obj.SEG_Reglas_Clasificacion__c);
                    listMV.put(obj.SEG_Valor__c, obj);
                    maplistOfMultivalorDestinatariosIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
                }
            
            } else if (obj.SEG_TipodeValor__c == 'Remitente' && String.isNotBlank(obj.SEG_Valor__c)) {
                reglasClasificacionIds.put(obj.SEG_Reglas_Clasificacion__c, obj.SEG_Reglas_Clasificacion__c);

                if (maplistOfMultivalorRemitentesIncluir.size() == 0 || (!maplistOfMultivalorRemitentesIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c))) {
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c>();
                    listMV.put(obj.SEG_Valor__c, obj);
                    maplistOfMultivalorRemitentesIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
                } else if (maplistOfMultivalorRemitentesIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c)) {
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c>();
                    listMV = maplistOfMultivalorRemitentesIncluir.get(obj.SEG_Reglas_Clasificacion__c);
                    listMV.put(obj.SEG_Valor__c, obj);
                    maplistOfMultivalorRemitentesIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
                }

            } else if (obj.SEG_TipodeValor__c == 'Asunto' && String.isNotBlank(obj.SEG_Valor__c)) {
                
                reglasClasificacionIds.put(obj.SEG_Reglas_Clasificacion__c, obj.SEG_Reglas_Clasificacion__c);

                if (maplistOfMultivalorAsuntosIncluir.size() == 0 || (!maplistOfMultivalorAsuntosIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c))) {
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c>();
                    listMV.put(obj.SEG_Valor__c, obj);
                    maplistOfMultivalorAsuntosIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
                } else if (maplistOfMultivalorAsuntosIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c)) {
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c>();
                    listMV = maplistOfMultivalorAsuntosIncluir.get(obj.SEG_Reglas_Clasificacion__c);
                    listMV.put(obj.SEG_Valor__c, obj);
                    maplistOfMultivalorAsuntosIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
                }

            } else if (obj.SEG_TipodeValor__c == 'Cuerpo' && String.isNotBlank(obj.SEG_Valor__c)) {
                reglasClasificacionIds.put(obj.SEG_Reglas_Clasificacion__c, obj.SEG_Reglas_Clasificacion__c);

                if (maplistOfMultivalorCuerposIncluir.size() == 0 || (!maplistOfMultivalorCuerposIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c))) {
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c>();
                    listMV.put(obj.SEG_Valor__c, obj);
                    maplistOfMultivalorCuerposIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
                } else if (maplistOfMultivalorCuerposIncluir.containsKey(obj.SEG_Reglas_Clasificacion__c)) {
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c>();
                    listMV = maplistOfMultivalorCuerposIncluir.get(obj.SEG_Reglas_Clasificacion__c);
                    listMV.put(obj.SEG_Valor__c, obj);
                    maplistOfMultivalorCuerposIncluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
                }

            } else {
                //exclusiones
                if (maplistOfMultivalorExcluir.size() == 0 || (!maplistOfMultivalorExcluir.containsKey(obj.SEG_Reglas_Clasificacion__c))) {
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c>();
                    listMV.put(obj.SEG_Valor__c, obj);
                    maplistOfMultivalorExcluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
                } else if (maplistOfMultivalorExcluir.containsKey(obj.SEG_Reglas_Clasificacion__c)) {
                    Map<String, SEG_Multivalor__c> listMV = new Map<String, SEG_Multivalor__c>();
                    listMV = maplistOfMultivalorExcluir.get(obj.SEG_Reglas_Clasificacion__c);
                    listMV.put(obj.SEG_Valor__c, obj);
                    maplistOfMultivalorExcluir.put(obj.SEG_Reglas_Clasificacion__c, listMV);
                }
            }
        }

        //V2: Comparamos los Asuntos Cuerpos Remitentes y Destinatarios
        for (Id target : reglasClasificacionIds.values()) {
            //por cada iteración instanciamos Listas de Remitentes, Asuntos y Cuerpos
            Map<String, SEG_Multivalor__c> listDestinatariosCC = new Map<String, SEG_Multivalor__c>();
            Map<String, SEG_Multivalor__c> listDestinatariosCCO = new Map<String, SEG_Multivalor__c>();
            Map<String, SEG_Multivalor__c> listDestinatarios = new Map<String, SEG_Multivalor__c>();
            Map<String, SEG_Multivalor__c> listRemitentes = new Map<String, SEG_Multivalor__c>();
            Map<String, SEG_Multivalor__c> listAsuntos = new Map<String, SEG_Multivalor__c>();
            Map<String, SEG_Multivalor__c> listCuerpos = new Map<String, SEG_Multivalor__c>();
            Map<String, SEG_Multivalor__c> listExclusiones = new Map<String, SEG_Multivalor__c>();

            if (maplistOfMultivalorDestinatariosCCIncluir.containsKey(target)) {
                listDestinatariosCC = maplistOfMultivalorDestinatariosCCIncluir.get(target);
            }
            if (maplistOfMultivalorDestinatariosCCOIncluir.containsKey(target)) {
                listDestinatariosCCO = maplistOfMultivalorDestinatariosCCOIncluir.get(target);
            }
            if (maplistOfMultivalorDestinatariosIncluir.containsKey(target)) {
                listDestinatarios = maplistOfMultivalorDestinatariosIncluir.get(target);
            }
            if (maplistOfMultivalorRemitentesIncluir.containsKey(target)) {
                listRemitentes = maplistOfMultivalorRemitentesIncluir.get(target);
            }
            if (maplistOfMultivalorAsuntosIncluir.containsKey(target)) {
                listAsuntos = maplistOfMultivalorAsuntosIncluir.get(target);
            }
            if (maplistOfMultivalorCuerposIncluir.containsKey(target)) {
                listCuerpos = maplistOfMultivalorCuerposIncluir.get(target);
            }
            if (maplistOfMultivalorExcluir.containsKey(target)) {
                listExclusiones = maplistOfMultivalorExcluir.get(target);
            }

            //TODO: FALTA EL *
            //posibles valores--> 0: no configurado | 1:configurado y encontrado | 2.configurado y no encontrado
            Integer remitenteFound = 0;
            Integer destinatarioFound = 0;
            Integer destinatarioCCFound = 0;
            Integer destinatarioCCOFound = 0;
            Integer asuntoFound = 0;
            Integer cuerpoFound = 0;
            Integer exclusion = 0;
            Integer exclusionCuerpo = 0;
            Integer exclusionAsunto = 0;
            Integer count = 0;

            for (String valor : listDestinatariosCC.keySet()) {
                destinatarioCCFound = 2;
                if (destinatarioCCUC.contains(valor.toUpperCase()) || destinatarioCCUC == '*') {
                    count++;
                    destinatarioCCFound = 1;
                    //break;
                }
            }

            for (String valor : listDestinatariosCCO.keySet()) {
                //Comprueba si el buzón al que ha llegado el correo estaba en CCO (no estaba en To ni en CC)
                destinatarioCCOFound = 2;
                if (!destinatarioUC.contains(correoDependencia[0].OS_Correo__c.toUpperCase())
                && !destinatarioCCUC.contains(correoDependencia[0].OS_Correo__c.toUpperCase())) {
                    count ++;
                    destinatarioCCOFound = 1;
                    //break;
                }
            }

            for (String valor : listDestinatarios.keySet()) {
                destinatarioFound = 2;
                if (destinatarioUC.contains(valor.toUpperCase()) || destinatarioUC == '*') {
                    count++;
                    destinatarioFound = 1;
                    //break;
                }
            }

            for (String valor : listRemitentes.keySet()) {
                //remitenteFound = 2;
                if (remitenteUC.contains(valor.toUpperCase()) || remitenteUC == '*') {
                    count++;
                    remitenteFound = 1;
                    //break;
                }
            }

            for (String valor : listAsuntos.keySet()) {
                asuntoFound = 2;
                if (asuntoUC.contains(valor.toUpperCase()) || asuntoUC == '*') {
                    count++;
                    asuntoFound = 1;
                    //break;
                }
            }

            for (String valor : listCuerpos.keySet()) {
                cuerpoFound = 2;
                if (cuerpoUC.contains(valor.toUpperCase()) || cuerpoUC == '*') {
                    count++;
                    cuerpoFound = 1;
                    //break;
                }
            }

            for (String valor : listExclusiones.keySet()) {
                exclusion = 2;
                if (asuntoUC.contains(valor.toUpperCase())) {
                    exclusionAsunto = 1;
                    exclusion = 1;
                    //break;
                }
                if (cuerpoUC.contains(valor.toUpperCase())) {
                    exclusionCuerpo = 1;
                    exclusion = 1;
                    //break;
                }
            }

            if (exclusion != 1) {
                for (Integer i = 0; i < count; i++) {
                    clasificacionRapida.add(target);
                }
            }
        }
        
        return clasificacionRapida;
    }

    public static Datetime parseoDatetime(String fechaEmail){

        Map<String, Integer> monthMap = new Map<String, Integer>{
            'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4,
            'May' => 5, 'Jun' => 6, 'Jul' => 7, 'Aug' => 8,
            'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12
        };
        
        List<String> parts = fechaEmail.split(' ');
        
        Integer year = Integer.valueOf(parts[3]);
        Integer month = monthMap.get(parts[2]);
        Integer day = Integer.valueOf(parts[1]);
		Integer gmtEmail = Integer.valueOf(fechaEmail.right(4).left(2));
       
        List<String> timeParts = parts[4].split(':');
        Integer hour = Integer.valueOf(timeParts[0]);
        Integer minute = Integer.valueOf(timeParts[1]);
        Integer second = Integer.valueOf(timeParts[2]);
        
        Datetime parsedDatetime = Datetime.newInstanceGMT(year, month, day, hour, minute, second);
        Integer horaSumar = 0;
		if(fechaEmail.contains('+')){
            horaSumar = horaSumar - gmtEmail;
		} else {
			horaSumar = horaSumar + gmtEmail;
		}
        parsedDatetime = parsedDatetime.addHours(horaSumar);
        return parsedDatetime;
    }
}