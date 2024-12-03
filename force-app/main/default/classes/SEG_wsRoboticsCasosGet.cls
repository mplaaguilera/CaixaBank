global with sharing class SEG_wsRoboticsCasosGet {

    /**
     * Clase OUTPUT para el método GET. 
     */
    global class SEG_WS_NewCase_GetOutput {
        global String resultado {get;set;}
        global String codigo {get;set;}
        global String mensaje {get;set;}
        global SEG_WS_CaseData datosCaso {get;set;}
        global List<SEG_WS_CaseFiles> listaFicheros {get;set;}
    }

    global class SEG_WS_CaseData {
        global String casoId {get;set;}
        global String numeroCaso {get;set;}
        global String estado {get;set;}
        global String organizacion {get;set;}
        global String zona {get;set;}
        global String grupoTrabajo {get;set;}
        global String propietario {get;set;}
        global String propietarioId {get;set;}
        global String propietarioNombre {get;set;}
        //global Datetime fechaApertura {get;set;}
        //global Datetime fechaCierre {get;set;}
        global String fechaApertura {get;set;}
        global String fechaCierre {get;set;}
        global String clasificacionRapida {get;set;}
        global String cif {get;set;}
        global String nombreEmpresa {get;set;}
        global String nombreContacto {get;set;}
        global String canalEntrada {get;set;}
        global String titulo {get;set;}
        global Integer numeroOperaciones {get;set;}
        global Integer numeroOperacionesCSO {get;set;}
        global Integer numeroOperacionesBO {get;set;}
        global String centroCSO {get;set;}
        global String centroBO {get;set;}
        global String centroBONombre {get;set;}
        global String prioridad {get;set;}
        global String idioma {get;set;}
        global String observaciones {get;set;}
        global String cuerpoPrimerMail {get;set;}

        // Datos grupo económico.
        global String grupoEmpresa {get;set;}
        global String grupoEmpresaCIF {get;set;}
        global String grupoEmpresaNumPer {get;set;}
    }

    global class SEG_WS_CaseFiles {
        global String documentoId {get;set;}
        global String versionId {get;set;}
        global String nombre {get;set;}
        global String extension {get;set;}
        global List<SEG_WS_Actividades> listaActividades {get;set;}
        global List<SEG_WS_Chatter> listaPostChatter {get;set;}
    }

    global class SEG_WS_Actividades {
        global String tipo {get;set;}
        //global Datetime fecha {get;set;}
        global String fecha {get;set;}
    }

    global class SEG_WS_Chatter {
        global String postId {get;set;}
        global String fecha {get;set;}
    }

    public static Map<String,String> validarDatosEntradaGET (String casoId)
    {
        Map<String,String> resultadoValidacion = new Map<String,String>();

        if (String.isBlank(casoId))
        {
            resultadoValidacion.put('codigo','0000');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje','No se han informado los datos obligatorios para la consulta');
            return resultadoValidacion;
        }

        // Si llegamos hasta aquí, la validación es correcta para realizar la consulta.
        resultadoValidacion.put('resultado','OK');
        resultadoValidacion.put('codigo','0000');

        return resultadoValidacion;
    }

    public static SEG_WS_NewCase_GetOutput recuperarDatosCaso (String casoId, String primerCorreo, String ficheros, String extensiones)
    {
        SEG_WS_NewCase_GetOutput retornoWS = new SEG_WS_NewCase_GetOutput();
        retornoWS.codigo = '0000';
        retornoWS.resultado = 'OK';
        retornoWS.mensaje = '';

        try {

            Boolean bCaso = false;
            List<Case> casoRecuperado = [SELECT Id, CaseNumber, SEG_Organizacion__c, SEG_Zona__c, SEG_Grupo__c, SEG_Grupo__r.Name, OwnerId, Owner.Name, CreatedDate, ClosedDate,
                                        SEG_ClasificacionRapida__c, SEG_ClasificacionRapida__r.Name, AccountId, Account.RecordType.DeveloperName, Account.CC_Numero_Documento__c,
                                        Account.CC_Numero_Oficina__c, Account.Name, ContactId, Contact.Name, Origin, Subject, SEG_N_operaciones_del_caso__c,
                                        SEG_N_operaciones_CSO__c, SEG_N_operaciones_BO__c, Priority, SEG_Idioma__c, SEG_Observaciones__c, Status,
                                        Account.SEG_CentroSegmento__c, Account.SEG_CentroSegmento__r.Name, Account.SEG_CentroSegmento__r.CC_Numero_Oficina__c,
                                        Account.SEG_GrupoEmpresaId__c, Account.SEG_GrupoEmpresaId__r.Name, Account.SEG_GrupoEmpresaId__r.CC_Numero_Documento__c, Account.SEG_GrupoEmpresaNumPer__c,
                                        Account.SEG_Prioridad_Carterizacion_Segmentos__c, Account.AV_OficinaPrincipal__c, Account.AV_OficinaPrincipal__r.CC_Numero_Oficina__c, Account.AV_OficinaPrincipal__r.Name,
                                        Account.SEG_Oficina_Gestora_Segmentos__c, Account.SEG_Oficina_Gestora_Segmentos__r.CC_Numero_Oficina__c, Account.SEG_Oficina_Gestora_Segmentos__r.Name 
                                        FROM Case
                                        WHERE Id = :casoId
                                        AND RecordType.DeveloperName IN ('SEG_Cliente', 'SEG_Seguimiento')];
            if (!casoRecuperado.isEmpty())
            {
                // Convertir fechas al formato esperado.
                String fechaAperturatxt = (casoRecuperado[0].CreatedDate != null) ? casoRecuperado[0].CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX') : null;
                String fechaCierretxt = (casoRecuperado[0].ClosedDate != null) ? casoRecuperado[0].ClosedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX') : null;

                // Gestión de la priorización de segmentos.
                Boolean priorizacionSegmentos = (casoRecuperado[0].Account?.SEG_Prioridad_Carterizacion_Segmentos__c != null) ? casoRecuperado[0].Account?.SEG_Prioridad_Carterizacion_Segmentos__c : false;
                String oficinaGestoraAux = (priorizacionSegmentos == true) ? casoRecuperado[0].Account?.SEG_Oficina_Gestora_Segmentos__r?.CC_Numero_Oficina__c : casoRecuperado[0].Account?.AV_OficinaPrincipal__r?.CC_Numero_Oficina__c;
                String oficinaGestoraNombreAux = (priorizacionSegmentos == true) ? casoRecuperado[0].Account?.SEG_Oficina_Gestora_Segmentos__r?.Name : casoRecuperado[0].Account?.AV_OficinaPrincipal__r?.Name;

                bCaso = true;
                SEG_WS_CaseData datosCaso = new SEG_WS_CaseData();
                datosCaso.casoId = casoRecuperado[0].Id;
                datosCaso.numeroCaso = casoRecuperado[0].CaseNumber;
                datosCaso.organizacion = casoRecuperado[0].SEG_Organizacion__c;
                datosCaso.zona = casoRecuperado[0].SEG_Zona__c;
                datosCaso.grupoTrabajo = casoRecuperado[0].SEG_Grupo__r?.Name;
                datosCaso.fechaApertura = fechaAperturatxt; //casoRecuperado[0].CreatedDate;
                datosCaso.fechaCierre = fechaCierretxt; //casoRecuperado[0].ClosedDate;
                datosCaso.clasificacionRapida = casoRecuperado[0].SEG_ClasificacionRapida__r?.Name;
                datosCaso.cif = (casoRecuperado[0].Account?.RecordType.DeveloperName == 'CC_CentroCaixaBank') ? casoRecuperado[0].Account?.CC_Numero_Oficina__c : casoRecuperado[0].Account?.CC_Numero_Documento__c;
                datosCaso.nombreEmpresa = casoRecuperado[0].Account?.Name;
                datosCaso.grupoEmpresa = casoRecuperado[0].Account?.SEG_GrupoEmpresaId__r?.Name;
                datosCaso.grupoEmpresaCIF = casoRecuperado[0].Account?.SEG_GrupoEmpresaId__r?.CC_Numero_Documento__c;
                datosCaso.grupoEmpresaNumPer = casoRecuperado[0].Account?.SEG_GrupoEmpresaNumPer__c;
                datosCaso.nombreContacto = casoRecuperado[0].Contact?.Name;
                datosCaso.canalEntrada = casoRecuperado[0].Origin;
                datosCaso.titulo = casoRecuperado[0].Subject;
                datosCaso.numeroOperaciones = casoRecuperado[0].SEG_N_operaciones_del_caso__c?.intValue();
                datosCaso.numeroOperacionesCSO = casoRecuperado[0].SEG_N_operaciones_CSO__c?.intValue();
                datosCaso.numeroOperacionesBO = casoRecuperado[0].SEG_N_operaciones_BO__c?.intValue();
                datosCaso.centroBO = (casoRecuperado[0].Account?.RecordType.DeveloperName == 'CC_CentroCaixaBank') ? '' : oficinaGestoraAux; //casoRecuperado[0].Account?.SEG_CentroSegmento__r?.CC_Numero_Oficina__c;
                datosCaso.centroBONombre = (casoRecuperado[0].Account?.RecordType.DeveloperName == 'CC_CentroCaixaBank') ? '' : oficinaGestoraNombreAux; //casoRecuperado[0].Account?.SEG_CentroSegmento__r?.Name;
                datosCaso.prioridad = casoRecuperado[0].Priority;
                datosCaso.idioma = casoRecuperado[0].SEG_Idioma__c;
                datosCaso.observaciones = casoRecuperado[0].SEG_Observaciones__c;
                datosCaso.cuerpoPrimerMail = '';
                datosCaso.estado = casoRecuperado[0].Status;

                // Recuperar datos del Owner del caso.
                String centroUser = '';
                String numeroEmpleadoUser = '';
                List<User> usuarioCaso = [SELECT Id, SEG_Centro__c, EmployeeNumber FROM User WHERE Id = :casoRecuperado[0].OwnerId];
                if (!usuarioCaso.isEmpty())
                {
                    centroUser = usuarioCaso[0].SEG_Centro__c;
                    numeroEmpleadoUser = usuarioCaso[0].EmployeeNumber;
                }

                datosCaso.propietarioId = casoRecuperado[0].OwnerId;
                datosCaso.propietario = numeroEmpleadoUser;
                datosCaso.centroCSO = centroUser;
                datosCaso.propietarioNombre = casoRecuperado[0].Owner.Name;

                /*String tipoOwner = SEG_wsRoboticsCasosComunes.obtenerTipoObjeto (datosCaso.propietario);
                String nombrePropietario = '';
                if (tipoOwner == 'User')
                {
                    List<User> usuario = [SELECT Id, SEG_Centro__c, EmployeeNumber FROM User WHERE Id = :datosCaso.propietario];
                    if (!usuario.isEmpty())
                    {
                        nombrePropietario = usuario[0].EmployeeNumber;
                    }
                }

                if (String.isBlank(nombrePropietario))
                {
                    nombrePropietario = casoRecuperado[0].Owner.Name;
                }
                datosCaso.propietario = nombrePropietario;*/

                retornoWS.datosCaso = datosCaso;
            }

            // Recuperar los ficheros anexados al caso.
            if (bCaso && ficheros == 'true')
            {
                List<String> listaExtensiones = new List<String>();
                if (String.isNotBlank(extensiones))
                {
                    listaExtensiones = extensiones.toLowerCase().split(',');
                }

                Map<String,SEG_WS_CaseFiles> documentoVersion = new Map<String,SEG_WS_CaseFiles>();
                Map<String,SEG_WS_CaseFiles> documentoVersionFeeds = new Map<String,SEG_WS_CaseFiles>();
                Map<String,SEG_WS_CaseFiles> contentDocumentFeeds = new Map<String,SEG_WS_CaseFiles>();
                List<ContentDocumentLink> ficherosAnexos = [SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension
                                                            FROM ContentDocumentLink WHERE LinkedEntityId = :casoId];
                for (ContentDocumentLink fichero : ficherosAnexos)
                {
                    if (listaExtensiones.isEmpty() || listaExtensiones.contains(fichero.ContentDocument.FileExtension))
                    {
                        SEG_WS_CaseFiles anexo = new SEG_WS_CaseFiles();
                        anexo.nombre = fichero.ContentDocument.Title;
                        anexo.extension = fichero.ContentDocument.FileExtension;
                        anexo.documentoId = fichero.ContentDocumentId;
                        documentoVersion.put(fichero.ContentDocumentId, anexo);
                    }
                }

                // Listado de versionData para buscar los posts asociados.
                List<Id> listaVersionesDocsIds = new List<Id>();
                
                // Recuperar los Ids de versiones para poder recuperar los binarios con la API estándar.
                if (!documentoVersion.isEmpty())
                {
                    List<ContentVersion> listaVersiones = [SELECT Id, ContentDocumentId
                                                            FROM ContentVersion
                                                            WHERE ContentDocumentId IN :documentoVersion.keySet()
                                                            AND IsLatest = true];
                    for (ContentVersion versionDocumento : listaVersiones)
                    {
                        SEG_WS_CaseFiles fichero = documentoVersion.get(versionDocumento.ContentDocumentId);
                        if (fichero != null)
                        {
                            fichero.versionId = versionDocumento.Id;
                            documentoVersion.put(versionDocumento.ContentDocumentId, fichero);

                            listaVersionesDocsIds.add(versionDocumento.ContentDocumentId);
                            documentoVersionFeeds.put(versionDocumento.Id, fichero);
                            contentDocumentFeeds.put(versionDocumento.ContentDocumentId, fichero);
                        }
                    }

                    // Buscar las tareas vinculadas a los ficheros.
                    Map<ID,List<ID>> mapaTareasDocumento = new Map<ID,List<ID>>();
                    for (ContentDocumentLink linkFichero : [SELECT Id, LinkedEntityId, ContentDocumentId
                                                            FROM ContentDocumentLink
                                                            WHERE ContentDocumentId IN :documentoVersion.keySet()])
                    {
                        if (SEG_wsRoboticsCasosComunes.obtenerTipoObjeto(linkFichero.LinkedEntityId) == 'Task')
                        {
                            List<ID> listaDocumentos = (mapaTareasDocumento.get(linkFichero.LinkedEntityId) !=  null) ? mapaTareasDocumento.get(linkFichero.LinkedEntityId) : new List<ID>();
                            listaDocumentos.add(linkFichero.ContentDocumentId);
                            mapaTareasDocumento.put(linkFichero.LinkedEntityId, listaDocumentos);
                        }
                    }

                    // Tratar solo las tareas encontradas vinculadas al caso que se está consultando.
                    Map<ID,Task> mapaTareasCaso = new Map<ID, Task>();
                    for (Task tareaCaso : [SELECT Id, Type, CreatedDate
                                            FROM Task
                                            WHERE WhatId = :casoId AND Id IN :mapaTareasDocumento.keySet()
                                            ORDER BY CreatedDate ASC])
                    {
                        // Por cada tarea, tratar sus ficheros vinculados.
                        for (ID documentoTarea : mapaTareasDocumento.get(tareaCaso.Id))
                        {
                            SEG_WS_CaseFiles documentoCaso = documentoVersion.get(documentoTarea);
                            if (documentoCaso.listaActividades == null)
                            {
                                documentoCaso.listaActividades = new List<SEG_WS_Actividades>();
                            }
                            
                            // Convertir la fecha al formato esperado.
                            String fechaTarea = (tareaCaso.CreatedDate != null) ? tareaCaso.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX') : null;
                            
                            // Crear el registro de actividad asociado al fichero.
                            SEG_WS_Actividades actividadCaso = new SEG_WS_Actividades();
                            actividadCaso.tipo = tareaCaso.Type;
                            actividadCaso.fecha = fechaTarea; //tareaCaso.CreatedDate;
                            documentoCaso.listaActividades.add(actividadCaso); 
                        }                       
                    }

                    // Obtener todos los feeds del caso
                    List<Id> feedsCaso = new List<Id>();
                    for (CaseFeed feedCaso : [SELECT Id, ParentId, Type
                                                FROM CaseFeed
                                                WHERE ParentId = :casoId AND Type IN ('TextPost','ContentPost')])
                    {
                        feedsCaso.add(feedCaso.Id);
                    }

                    // Buscar los FeedItems a los que está asociado los ficheros.
                    Set<String> listadoDocumentosFeedsSearch = new Set<String>();
                    listadoDocumentosFeedsSearch.addAll(documentoVersionFeeds.keySet());
                    listadoDocumentosFeedsSearch.addAll(contentDocumentFeeds.keySet());

                    Map<ID,List<ID>> feedItemsFicheros = new Map<ID,List<ID>>();
                    for (FeedAttachment ficheroChatter : [SELECT Id, RecordId, FeedEntityId
                                                            FROM FeedAttachment
                                                            WHERE RecordId IN :listadoDocumentosFeedsSearch AND FeedEntityId IN :feedsCaso])
                    {
                        List<ID> listaDocumentosFeed = (feedItemsFicheros.get(ficheroChatter.FeedEntityId) !=  null) ? feedItemsFicheros.get(ficheroChatter.FeedEntityId) : new List<ID>();
                        listaDocumentosFeed.add(ficheroChatter.RecordId);
                        feedItemsFicheros.put(ficheroChatter.FeedEntityId, listaDocumentosFeed);
                    }

                    // Buscar los feedItems que están asociados al caso.
                    for (FeedItem feedCaso : [SELECT Id, ParentId, CreatedDate
                                                FROM FeedItem
                                                WHERE Id IN :feedItemsFicheros.keySet()
                                                AND ParentId = :casoId
                                                ORDER BY CreatedDate ASC])
                    {                       
                        // Por cada feedItem, tratar sus ficheros vinculados.
                        for (ID documentoFeed : feedItemsFicheros.get(feedCaso.Id))
                        {
                            SEG_WS_CaseFiles documentoCaso = documentoVersionFeeds.get(documentoFeed);
                            documentoCaso = (documentoCaso != null) ? documentoCaso : contentDocumentFeeds.get(documentoFeed);

                            if (documentoCaso.listaPostChatter == null)
                            {
                                documentoCaso.listaPostChatter = new List<SEG_WS_Chatter>();
                            }
                            
                            // Convertir la fecha al formato esperado.
                            String fechaPost = (feedCaso.CreatedDate != null) ? feedCaso.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX') : null;
                            
                            // Crear el registro de actividad asociado al fichero.
                            SEG_WS_Chatter feedFileChatter = new SEG_WS_Chatter();
                            feedFileChatter.postId = feedCaso.Id;
                            feedFileChatter.fecha = fechaPost;
                            documentoCaso.listaPostChatter.add(feedFileChatter); 
                        }
                    }

                    // Preparar retorno.
                    retornoWS.listaFicheros = documentoVersion.values();
                }
            }

            // Recuperar el primer correo recibido del caso.
            if (bCaso && primerCorreo == 'true')
            {
                List<EmailMessage> listaCorreos = [SELECT Id, TextBody, MessageDate, Incoming
                                                    FROM EmailMessage
                                                    WHERE Incoming = true
                                                    AND ParentId = :casoId
                                                    ORDER BY MessageDate ASC
                                                    LIMIT 1];
                if (!listaCorreos.isEmpty())
                {
                    retornoWS.datosCaso.cuerpoPrimerMail = listaCorreos[0].TextBody;
                }
            }

        } catch (Exception e) {
            retornoWS.codigo = '9999';
            retornoWS.resultado = 'NOK';
            retornoWS.mensaje = 'Error al recuperar los datos. Detalle: ' + e.getMessage();
            CBK_Log.error(e);
        }

        return retornoWS;
    }
}