/***************************************************************** 
 * Name: SAC_Alertas
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Clase para generar alertas. Las alertas a generar vienen definidas por el wrapper SAC_WrapperAlerta.
 * Busca en los custom metadata types (SAC_MaestroTipologiasAlertas__mdt) si las alertas a generar deben mandar notificación,
 * enviar un email, o crear un registro de alerta (objeto SAC_Alerta) y posteriormente realiza los procesos.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US418231         Carlos Solis   26/07/2022   Creación
 * 1.1            US494885         Alex Perez     28/12/2022   adaptación plantillas
 * 1.2            US555048         Carlos Solis   02/05/2023   Modificacion vincular email a alerta
*****************************************************************/
public without sharing class SAC_Alertas {

    private static Set<String> objetos = new Set<String>{'SAC_Alerta__c', 'SAC_MaestroTemas__c', 'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEALERTA =  mapRTsObjects.get('SAC_Alerta__c').get('SAC_Alerta').getRecordTypeId();
    private static final Id RECTYPEALERTASPV =  mapRTsObjects.get('SAC_Alerta__c').get('SPV_Alerta').getRecordTypeId();
    private static final Id RECORDTYPEBLACKLIST =  mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_BlackListEmails').getRecordTypeId();
    private static final Id RECORDTYPEBLACKLISTSPV =  mapRTsObjects.get('SAC_MaestroTemas__c').get('SPV_BlackListEmails').getRecordTypeId();
    private static final Id RECTYPERECLAMACION =  mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();

    private static set<string> orgWideAdd = new set<string>();
    private static map<string, EmailTemplate> mapaPlantillas = new map<string, EmailTemplate>();
    //para renderizar el body solo 1 vez. key = developerNameOTipoMetadata|IdObjeto
    private static map<string, string> mapaBodyRenderizado = new map <string, string>();

    public static void generarAlertas(List<SAC_WrapperAlerta> listaWrapperAlerta) {

        //Creación listas y mapas
        List<SAC_WrapperAlerta> listaParaNotificar = new List<SAC_WrapperAlerta>();
        List<SAC_WrapperAlerta> listaParaCrearAlerta = new List<SAC_WrapperAlerta>();
        List<SAC_WrapperAlerta> listaParaEnviarEmail = new List<SAC_WrapperAlerta>();
        Map<String, SAC_MaestroTipologiasAlertas__mdt> mapaTipoMaestro = new Map<String, SAC_MaestroTipologiasAlertas__mdt>();
        Map<Id, Group> mapaColas = new Map<Id, Group>();
        

        //Recuperar colas
        List<Group> listaColas = new List<Group>();
        //listaColas = SAC_HandlerWithoutSharingMethods.recuperarColasSAC();
        listacolas = [SELECT Id, DeveloperName, Name FROM Group WHERE Type = 'Queue' AND 
                    (DeveloperName = 'SAC_PendienteAsignar' OR DeveloperName = 'SAC_PteSupervisor'
                    OR DeveloperName = 'SPV_PendienteAsignar')];
        if(!listaColas.isEmpty()){
            for (Group grupoAux : listaColas) {
                if(grupoAux.DeveloperName == 'SAC_PendienteAsignar'){
                    mapaColas.put(grupoAux.Id, grupoAux);
                }else if(grupoAux.DeveloperName == 'SAC_PteSupervisor'){
                    mapaColas.put(grupoAux.Id, grupoAux);
                }else if(grupoAux.DeveloperName == 'SPV_PendienteAsignar'){
                    mapaColas.put(grupoAux.Id, grupoAux);
                }
            }
        }

        //Buscar en el maestro de alertas el tipo de alerta y recuperar los checks de requiere notificación, requiere alerta y requiere email
        mapaTipoMaestro = buscarMaestros(listaWrapperAlerta);

        //Crear listas con las alertas sobre las que hay que enviar notificación, crear registro alerta, o enviar email
        rellenarListas(listaWrapperAlerta, mapaTipoMaestro, listaParaNotificar, listaParaCrearAlerta, listaParaEnviarEmail);

        //Si requiere notificación=true, enviar alerta de campanita al usuario destinatario SAC_WrapperAlerta con el mensaje asociado (campo mensaje)
        if (!listaParaNotificar.isEmpty()) {
            alertaEnviarNotificaciones(listaParaNotificar, mapaTipoMaestro, mapaColas);
        }

        //Si requiere alerta=true, generar registro de alerta informando todos los campos recibidos.
        if (!listaParaCrearAlerta.isEmpty()) {
            registrarAlertas(listaParaCrearAlerta, mapaTipoMaestro, mapaColas);
        }

        //Si requiere email=true, generar email de alerta con el mensaje de alerta de campanita.
        if (!listaParaEnviarEmail.isEmpty() && !Test.isRunningTest()) {
            alertaEnviarEmails(listaParaEnviarEmail, mapaTipoMaestro, mapaColas);
        }
    }

    /*****************************************************************
     * Proposito: Recoger los registros del maestro de tareas (Custom metadata types) de los
     * tipos de alertas que necesitemos lanzar. Retorna un mapa con clave tipo de alerta y
     * valor registro del maestro
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US418231         Carlos Solis   27/07/22      Creación
     * 1.1            US494885         Alex Perez     14/12/22      versión plantillas 
    *****************************************************************/
    public static Map<String, SAC_MaestroTipologiasAlertas__mdt> buscarMaestros(List<SAC_WrapperAlerta> listaWrapperAlerta) {
        //Recoger tipos de alerta que vienen en el wrapper
        Map<String, SAC_MaestroTipologiasAlertas__mdt> mapaTipoMaestro = new Map<String, SAC_MaestroTipologiasAlertas__mdt>();
        List<String> listaTipos = new List<String>();
        set<string> listaPlantillas = new set<string>();
        for (SAC_WrapperAlerta wrapAlerta : listaWrapperAlerta) {
            listaTipos.add(wrapAlerta.tipoAlerta);
        }

        //Buscar registros en el maestro
        List<SAC_MaestroTipologiasAlertas__mdt> listaMaestros = [SELECT Id, SAC_Tipo__c, toLabel(SAC_Tipo__c) labelTipo, SAC_RequiereNotificacion__c, SAC_RequiereAlerta__c, SAC_RequiereEmail__c,
                                                                    SAC_OrgWideAddress__c, SAC_Plantilla__c, DeveloperName, SAC_Notifica_Colaboradores__c, SAC_Texto_Notificacion__c, SAC_Titulo_Notificacion__c,
                                                                    SAC_NotiPlantillaHTML__c
                                                                FROM SAC_MaestroTipologiasAlertas__mdt
                                                                WHERE SAC_Tipo__c IN :listaTipos];
         //metadata no soporta soql disjuntions
        listaMaestros.addAll([SELECT Id, SAC_Tipo__c, toLabel(SAC_Tipo__c) labelTipo, SAC_RequiereNotificacion__c, SAC_RequiereAlerta__c, SAC_RequiereEmail__c,
                                    SAC_OrgWideAddress__c, SAC_Plantilla__c, DeveloperName, SAC_Notifica_Colaboradores__c, SAC_Texto_Notificacion__c, SAC_Titulo_Notificacion__c,
                                    SAC_NotiPlantillaHTML__c
                                FROM SAC_MaestroTipologiasAlertas__mdt
                                WHERE  DeveloperName IN :listaTipos]);
        
        //Devolver mapa con clave tipo de maestro y valor registro de maestro
        if (!listaMaestros.isEmpty()) {
            for (SAC_MaestroTipologiasAlertas__mdt maestroAlerta : listaMaestros) {
                mapaTipoMaestro.put(maestroAlerta.DeveloperName, maestroAlerta);
                mapaTipoMaestro.put(maestroAlerta.SAC_Tipo__c, maestroAlerta);
                listaPlantillas.add(maestroAlerta.SAC_Plantilla__c);
                orgWideAdd.add(maestroAlerta.SAC_OrgWideAddress__c);
            }
        }

        if(!listaPlantillas.isEmpty()) {
            for(EmailTemplate plantilla : [SELECT Id, developerName, htmlValue, subject FROM EmailTemplate WHERE developerName = : listaPlantillas]) {
                mapaPlantillas.put(plantilla.developerName, plantilla);
            }
        }
        return mapaTipoMaestro;
    }

    /*****************************************************************
     * Proposito: Rellena las listas: listaParaNotificar, listaParaCrearAlerta y listaParaEnviarEmail.
     * Estas listas se usarán para determinar que alertas deben notificarse por campanita,que alertas deben
     * crear registro de alerta, o que alertas deben enviar email. Se compara cada alerta con el registro del
     * maestro del mismo tipo para saber que debe hacer.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US418231         Carlos Solis   27/07/22      Creación
    *****************************************************************/
    private static void rellenarListas(List<SAC_WrapperAlerta> listaWrapperAlerta, Map<String, SAC_MaestroTipologiasAlertas__mdt> mapaTipoMaestro, List<SAC_WrapperAlerta> listaParaNotificar, List<SAC_WrapperAlerta> listaParaCrearAlerta, List<SAC_WrapperAlerta> listaParaEnviarEmail) {
        for (SAC_WrapperAlerta wrapAlerta : listaWrapperAlerta) {
            if (mapaTipoMaestro.containsKey(wrapAlerta.tipoAlerta)) {
                //Rellenado de lista para notificar
                if (mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_RequiereNotificacion__c) {
                    listaParaNotificar.add(wrapAlerta);
                }
                //Rellenado de lista para crear alerta
                if (mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_RequiereAlerta__c) {
                    listaParaCrearAlerta.add(wrapAlerta);
                }
                //Rellenado de lista para enviar email
                if (mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_RequiereEmail__c) {
                    listaParaEnviarEmail.add(wrapAlerta);
                }
            }
        }
    }

    /*****************************************************************
     * Proposito: Envía una notificación por cada alerta de la lista.
     * El target de la notificación por ahora será siempre la reclamación padre a la que pertenece la alerta
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US418231         Carlos Solis   27/07/22      Creación
     * 1.1                             Alex Perez     22/12/22      adaptación configurable metadata
    *****************************************************************/
    private static void alertaEnviarNotificaciones(List<SAC_WrapperAlerta> listaParaNotificar, Map<String, SAC_MaestroTipologiasAlertas__mdt> mapaTipoMaestro, Map<Id, Group> mapaColas) {
        //Recorrer la lista de alertas a notificar y llamar al metodo que notifica
        list<string> todosLosMails = new list<string>();
        map<string, id> mapUsuariosporMail = new map<string, id>();
        for (SAC_WrapperAlerta wrapAlerta : listaParaNotificar) {
            todosLosMails.addAll(wrapAlerta.listaEmailsGrupo);
        }
        for(user usuario : [SELECT Id, email FROM User WHERE email IN : todosLosMails]){
            mapUsuariosporMail.put(usuario.email, usuario.Id);
        }
        for (SAC_WrapperAlerta wrapAlerta : listaParaNotificar) {
            string titulo;
            list<Id> colaboradores = new list<Id>();
            //El target de la notificación por ahora será siempre la reclamación padre a la que pertenece la alerta
            if(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_Notifica_Colaboradores__c 
            && String.isBlank(wrapAlerta.idUsuarioDestinatario) /*&& String.isNotBlank(wrapAlerta.idGrupoColaborador)*/ && !mapUsuariosporMail.isEmpty()) {
                for(string emailUser : wrapAlerta.listaEmailsGrupo){
                    colaboradores.add(mapUsuariosporMail.get(emailUser));
                }
            } else if(String.isNotBlank(wrapAlerta.idUsuarioDestinatario)) {
                colaboradores.add(wrapAlerta.idUsuarioDestinatario);
            }
            if ((String.isNotBlank(wrapAlerta.idUsuarioDestinatario) || !colaboradores.isEmpty()) && !mapaColas.containsKey(wrapAlerta.idUsuarioDestinatario)) {
                Id objetoId=obtenerElObjeto(wrapAlerta);
                if(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_NotiPlantillaHTML__c && String.isNotBlank(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_Plantilla__c)){

                    wrapAlerta.mensaje = renderizarHTML(UserInfo.getUserId(), objetoId, mapaPlantillas.get(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_Plantilla__c).htmlValue);
                    titulo = mapaPlantillas.get(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_Plantilla__c).subject;
                    //evitar renderizar el mismo body mas de 1 vez en las distintas alertas
                    mapaBodyRenderizado.put(wrapAlerta.tipoAlerta+'|'+objetoId,wrapAlerta.mensaje);
                    wrapAlerta.mensaje = wrapAlerta.mensaje.replaceAll('(\r?\n|<.[^>]*>)', '');
                } else {
                    if(String.isNotBlank(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_Texto_Notificacion__c)) {
                        wrapAlerta.mensaje = renderizarHTML(UserInfo.getUserId(), objetoId, mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_Texto_Notificacion__c);
                    }
                    if(String.isNotBlank(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_Titulo_Notificacion__c)) {
                        titulo = mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_Titulo_Notificacion__c;
                    } else {
                        titulo = String.valueOf(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).get('labelTipo'));
                    }
                }
               
                for(id colab : colaboradores) {
                    SAC_Notificacion.enviarNotificacion(colab, objetoId, titulo, wrapAlerta.mensaje);
                }
                
            }
        }
    }

    /*****************************************************************
     * Proposito: Crea un registro de SAC_Alerta por cada alerta que viene en la lista introducida
     * Estos registros se añaden a una lista para posteriormente insertarlas a la vez
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US418231         Carlos Solis   27/07/22      Creación
     * 1.1            US494885         Alex Perez     14/12/22      versión plantillas  
    *****************************************************************/
    private static void registrarAlertas(List<SAC_WrapperAlerta> listaParaCrearAlerta, Map<String, SAC_MaestroTipologiasAlertas__mdt> mapaTipoMaestro, Map<Id, Group> mapaColas) {
        List<SAC_Alerta__c> listaAlertasInsertar = new List<SAC_Alerta__c>();


        Map<SAC_WrapperAlerta, SAC_Alerta__c> mapaWrapAlertas = new Map<SAC_WrapperAlerta, SAC_Alerta__c>();


        //Traer las queues de SAC por si el usuario destinatario no fuera un user y fuera un group (esta query se ha sustituido por la busqueda de las colas que se efectúa en el método generarAlertas. Ahora se importa por parámetros)
        //Map<Id, Group> mapaColas = new Map<Id, Group>([SELECT Id, Name FROM Group WHERE Type = 'Queue' AND (DeveloperName = 'SAC_PendienteAsignar' OR DeveloperName = 'SAC_PteSupervisor')]);

        for (SAC_WrapperAlerta wrapAlerta : listaParaCrearAlerta) {
            SAC_Alerta__c nuevaAlerta = new SAC_Alerta__c();
            //Añadido 30/08/24. Si se informa el proyecto en el wrapper, debe ponerse el recordtype correspondiente. Si no se informa, se pone automaticamente el de SAC
            if (String.isBlank(wrapAlerta.proyecto) || wrapAlerta.proyecto == 'SAC') {
                nuevaAlerta.RecordTypeId = RECTYPEALERTA;    
            } else if (wrapAlerta.proyecto == 'SPV') {
                nuevaAlerta.RecordTypeId = RECTYPEALERTASPV;
            }
            
            nuevaAlerta.Name = String.valueOf(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).get('labelTipo'));
            string elObjeto;
            if (String.isNotBlank(wrapAlerta.idReclamacion)) {
                nuevaAlerta.SAC_Reclamacion__c = wrapAlerta.idReclamacion;    
            }
            //Rellena el usuario destinatario siempre que sea distinto a una cola, de lo contrario rellena el campo grupo
            if (String.isNotBlank(wrapAlerta.idUsuarioDestinatario) && !mapaColas.containsKey(wrapAlerta.idUsuarioDestinatario)) {
                nuevaAlerta.SAC_Usuario__c = wrapAlerta.idUsuarioDestinatario;
            } else if (String.isNotBlank(wrapAlerta.idUsuarioDestinatario) && mapaColas.containsKey(wrapAlerta.idUsuarioDestinatario)) {
                nuevaAlerta.SAC_Grupo__c = mapaColas.get(wrapAlerta.idUsuarioDestinatario).Name;
            }
            elObjeto = obtenerElObjeto(wrapAlerta);
            if (String.isNotBlank(wrapAlerta.idPretensionConsulta)) {
                nuevaAlerta.SAC_Pretension__c = wrapAlerta.idPretensionConsulta;
            }
            if (String.isNotBlank(wrapAlerta.idAccion)) {
                nuevaAlerta.SAC_Accion__c = wrapAlerta.idAccion;
            }
            if (String.isNotBlank(wrapAlerta.idInteraccion)) {
                nuevaAlerta.SAC_Interaccion__c = wrapAlerta.idInteraccion;   
            }
            if (String.isNotBlank(wrapAlerta.idGrupoColaborador)) {
                nuevaAlerta.SAC_GrupoColaborador__c = wrapAlerta.idGrupoColaborador;
            }
            if(string.isNotBlank(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_Plantilla__c)) {
                //evitar renderizar el mismo body mas de 1 vez en las distintas alertas
                if(mapaBodyRenderizado.containsKey(wrapAlerta.tipoAlerta+'|'+elObjeto)) {
                    wrapAlerta.mensaje = mapaBodyRenderizado.get(wrapAlerta.tipoAlerta+'|'+elObjeto);
                } else {
                    wrapAlerta.mensaje = renderizarHTML(UserInfo.getUserId(), elObjeto, mapaPlantillas.get(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_Plantilla__c).htmlValue);
                    mapaBodyRenderizado.put(wrapAlerta.tipoAlerta+'|'+elObjeto, wrapAlerta.mensaje);
                }
            }
            nuevaAlerta.SAC_MensajeAlerta__c = wrapAlerta.mensaje;

            listaAlertasInsertar.add(nuevaAlerta);

            //Mapa para montar ids
            mapaWrapAlertas.put(wrapAlerta, nuevaAlerta);
        }
        
        if (!listaAlertasInsertar.isEmpty()) {
            SAC_DatabaseDML.insertListDML(listaAlertasInsertar, true);
            //Database.insert(listaAlertasInsertar);
        }

        //Añadir la id de las alertas insertadas al wrapper de alertas
        for (SAC_WrapperAlerta wrapAlerta : mapaWrapAlertas.keySet()) {
            if (String.isNotBlank(mapaWrapAlertas.get(wrapAlerta).Id)) {
                wrapAlerta.idAlerta = mapaWrapAlertas.get(wrapAlerta).Id;
            }
        }
    }

    /*****************************************************************
     * Proposito: Recupera los emails de los usuarios y posteriormente envia un email a cada
     * usuario de la lista de alertas introducidas por parámetro
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US418231         Carlos Solis   28/07/22     Creación
     * 1.1            US494885         Alex Perez     14/12/22     versión plantillas 
     * 1.2            US723742         Raúl Santos    05/03/24     Modificación: añadir lógica envio emails blackList
     * 1.3              ---            Raúl Santos    02/10/24     Modificación: añadir lógica para el envio de alertas SPV
     * 1.4            US756377         Raúl Santos    11/11/24     Modificación: en las alertas de recordatorios de consultas se deben adjunten los documentos de la consulta (proyecto SAC)
    *****************************************************************/
    public static void alertaEnviarEmails(List<SAC_WrapperAlerta> listaParaEnviarEmail, Map<String, SAC_MaestroTipologiasAlertas__mdt> mapaTipoMaestro, Map<Id, Group> mapaColas) {
        //Recuperar los mails de los usuarios
        Map<String, User> mapaUsuarioEmail = recuperarMailsUsuarios(listaParaEnviarEmail);
        Map<Id, list<string>> emailsAgrupadosTarget = agruparEmailsTarget(listaParaEnviarEmail);
        //mapa de contactos que tienen mail coincidente
        map<string, Id> contactMap = new map<string, Id>();
        list<string> todosLosMails = new list<string>();
        Set<Id> idsConsulta = new Set<Id>();
        List<ContentVersion> listAdjuntos = new List<ContentVersion>();
        List<Id> lstIdCV = new List<Id>();
        Map<Id,Id> mapCDLIdRegistro = new Map<Id,Id>();
        //map<Id, string> map
        //Recuperar orgWideAdress para el remitente del correo
        //OrgWideEmailAddress orgwideaddress = new OrgWideEmailAddress();
        map<string, id> maporgwideaddress = new map<string, id>();
        //orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE displayname =  'SAC Noreply' LIMIT 1];
        for(OrgWideEmailAddress orgWA : [SELECT Id, Address, displayName FROM OrgWideEmailAddress WHERE displayname = : orgWideAdd OR displayname = 'Servicio Atención Cliente M2P' OR displayname = 'M2P Noreply']) {
            maporgwideaddress.put(orgWA.displayname, orgWA.id);
        }
        for(SAC_WrapperAlerta wrapAlerta : listaParaEnviarEmail) {
            todosLosMails.addAll(wrapAlerta.listaEmailsGrupo);

            //Si el wrapper es de una alerta de consulta de pendiente de respuesta (proyecto SAC)
            if(wrapAlerta.idInteraccion != null && wrapAlerta.tipoAlerta.contains('SAC_ConsultaPdteRespuesta') && wrapAlerta.proyecto != 'SPV'){
                idsConsulta.add(wrapAlerta.idInteraccion);
        }
        }

        //Si se trata de un recordatorio de consulta pte respuesta, debemos recuperar los documentos asociados a la consulta
        if(!idsConsulta.isEmpty()){
            Map<Id, Boolean> contentOculto = new Map<Id, Boolean>();
            List<Id> idsDocumentLink = new List<Id>();

            List<ContentDocumentLink> cdL = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId IN :idsConsulta AND ContentDocument.FileType != 'SNOTE'];  

            for(ContentDocumentLink recordCdL : cdL){
                idsDocumentLink.add(recordCdL.ContentDocumentId);
                mapCDLIdRegistro.put(recordCdL.ContentDocumentId, recordCdL.LinkedEntityId);
            }

            listAdjuntos = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: idsDocumentLink AND SAC_BloqueoTotalVisibilidad__c = false ORDER BY CreatedDate ASC];
        }


        for(Contact contacto : [SELECT Id, Email FROM Contact WHERE Email IN : todosLosMails]) {
            contactMap.put(contacto.Email, contacto.Id);
        }
        //contact para asignar aquellos mails que no formen parte de los contacts registrados en salesforce  //Para SPV?
        contact contRand = [SELECT Id FROM Contact WHERE Email = 'externos@sac.caixabank.com' LIMIT 1];

        //Recorrer la lista de alertas sobre las que mandar email y crear un Messaging.SingleEmailMessage por cada una
        //para posteriormente añadirlos a una lista de Messaging.SingleEmailMessage
        List<Messaging.SingleEmailMessage> listaSEM = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> listaSEMSPV = new List<Messaging.SingleEmailMessage>();
        //mapaObjetoId para posteriormente buscar los registros de EmailMessage
        Map<String, String> mapaObjetoId = new Map<String, String>();
        Boolean destinatarioEsCola = false;
        //US777526 Poner owa de m2p en caso de que la owa del metada sea caixabank sac y la reclamacion tenga el check m2p
        Map<Id, Case> mapaReclamaciones = recuperarCasosComprobarM2P(listaParaEnviarEmail);
        for (SAC_WrapperAlerta wrapAlerta : listaParaEnviarEmail) {
            lstIdCV.clear();
            
            //Si la lista de emails no está vacía, significa que hay que mandar los emails a las direcciones de esta lista
            string objetoId = obtenerElObjeto(wrapAlerta);
            //US777526 Recuperar la id de la reclamación que hay en la alerta para poder comprobar si es m2p
            String idRecla = obtenerIdReclamacion(wrapAlerta);
            mapaObjetoId.put(objetoId, objetoId);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            Id contactId;
            boolean porBody = false;
            //Que tenga en el whatId el id de la alerta. En caso de que haya una plantilla, se cambiará por el objeto correspondiente
            mail.setWhatId(wrapAlerta.idAlerta);
            // si la lista de EmailsGrupo viene vacía tiene que venir relleno el idUsuarioDestinatario
            if(wrapAlerta.listaEmailsGrupo.isEmpty()) {
                //mail.setTargetObjectId(wrapAlerta.idUsuarioDestinatario); //Se ha sustituido esta linea por la siguiente, para que si que deje registro de emailMessage
                List<String> listaToAdresses = new List<String>();
                if (mapaColas.containsKey(wrapAlerta.idUsuarioDestinatario)) {
                    destinatarioEsCola = true;
                }
                listaToAdresses.add(wrapAlerta.idUsuarioDestinatario);
                mail.toAddresses = listaToAdresses;
                mail.setTreatTargetObjectAsRecipient(true);
                //en caso de que target Object sea un user, no se puede generar actividad
                List<String> bodies = new List<String>();
                if(!string.isBlank(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_Plantilla__c)) {
                    if(mapaBodyRenderizado.containsKey(wrapAlerta.tipoAlerta+'|'+objetoId)) {
                        wrapAlerta.mensaje = mapaBodyRenderizado.get(wrapAlerta.tipoAlerta+'|'+objetoId);
                    } else {
                        wrapAlerta.mensaje = renderizarHTML(UserInfo.getUserId(), objetoId, mapaPlantillas.get(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_Plantilla__c).htmlValue);
                        mapaBodyRenderizado.put(wrapAlerta.tipoAlerta+'|'+objetoId, wrapAlerta.mensaje);
                    }
                }
                mail.setSaveAsActivity(true);
                //el mergeo normal de email templates no funciona si el target object es un user
                porBody = true;
            } else {
                if(!emailsAgrupadosTarget.containsKey(objetoId) || !contactMap.containsKey(emailsAgrupadosTarget.get(objetoId)[0])){ 
                    //si el mail no existe en nuestra contact, asociamos al contact externo
                    contactId = contRand.Id;
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setSaveAsActivity(true);
                } else {
                    //para mails que existen en la contact, asociamos el email al primer email de la lista(el prioritario) y el resto lo ponemos en el setToAddresses para que aparezcan en el "para"
                    contactId = contactMap.get(emailsAgrupadosTarget.get(objetoId)[0]);
                    emailsAgrupadosTarget.get(objetoId).remove(0);
                    mail.setTreatTargetObjectAsRecipient(true);
                    mail.setSaveAsActivity(true);
                }
                if(!wrapAlerta.listaEmailsGrupo.isEmpty()) {
                    //ponemos los mails en caso de que sea externo y el resto de mails que no son el prioritario en el interno
                    mail.setToAddresses(wrapAlerta.listaEmailsGrupo);
                }
            }   
            //si el email tiene configurada una plantilla en el metadato
            if(string.isNotBlank(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_Plantilla__c) && !porBody) {
                //Preparar el renderizado de la plantilla
                String idPlantillaEmail = mapaPlantillas.get(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_Plantilla__c).Id;
                String whoId = wrapAlerta.idUsuarioDestinatario;
                Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(idPlantillaEmail, contactId, objetoId);
                mail.setSubject(renderStored.getSubject());
                mail.setHtmlBody(renderStored.getHtmlBody());

                //Codigo sustituido por el anterior, para poder hacer el renderizado de la plantilla sin tener que poner un contact.
                //mail.setTemplateID(mapaPlantillas.get(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_Plantilla__c).Id);
                //user o contact
                //mail.setTargetObjectId(contactId);
                //consulta, pretension, accion
                mail.setWhatId(objetoId);
            //sin una plantilla configurada(el body viene en el wrapAlerta)
            } else {
                if(!string.isBlank(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_Plantilla__c)) {
                    mail.setSubject(mapaPlantillas.get(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_Plantilla__c).subject);
                } else {
                    mail.setSubject(String.valueOf(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).get('labelTipo')));
                }
                
                //Especificar el contenido del email (usamos el mensaje de la alerta)
                if(String.isBlank(wrapAlerta.enlaceParaEmail)){
                    mail.setHtmlBody(wrapAlerta.mensaje);
                }else{
                    mail.setHtmlBody(wrapAlerta.mensaje + '</br>' + 'Enlace al registro: ' + wrapAlerta.enlaceParaEmail);
                }
            }          
            
            //Añadir el correo No reply para el remitente cuando lo tengamos preparado
            mail.setOrgWideEmailAddressId(maporgwideaddress.get(mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_OrgWideAddress__c));
            //US777526 Poner owa de m2p en caso de que la owa del metada sea caixabank sac y la reclamacion tenga el check m2p
            if (mapaReclamaciones.containsKey(idRecla) && mapaReclamaciones.get(idRecla).SAC_M2P__c && mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_OrgWideAddress__c == 'CaixaBank SAC'
                && maporgwideaddress.containsKey('Servicio Atención Cliente M2P')) {
                mail.setOrgWideEmailAddressId(maporgwideaddress.get('Servicio Atención Cliente M2P'));
            }
            if (mapaReclamaciones.containsKey(idRecla) && mapaReclamaciones.get(idRecla).SAC_M2P__c && mapaTipoMaestro.get(wrapAlerta.tipoAlerta).SAC_OrgWideAddress__c == 'SAC Noreply'
                && maporgwideaddress.containsKey('M2P Noreply')) {
                mail.setOrgWideEmailAddressId(maporgwideaddress.get('M2P Noreply'));
            }

            //Si existen archivos adjuntos asociados a la consulta, les añadimos al mail a enviar
            if(wrapAlerta.idInteraccion != null && wrapAlerta.idInteraccion != '' && !listAdjuntos.isEmpty()){
                for(ContentVersion contentVersion : listAdjuntos){
                    if(idsConsulta.contains(wrapAlerta.idInteraccion) && mapCDLIdRegistro.get(contentVersion.ContentDocumentId) == wrapAlerta.idInteraccion){
                        lstIdCV.add(contentVersion.Id);
                    }
                }

                if(!lstIdCV.isEmpty()){
                    mail.setEntityAttachments(lstIdCV);
                }
            }

            //Añadir el Messaging.SingleEmailMessage a una lista para posteriormente enviarlo
            if (!destinatarioEsCola) {
                if(wrapAlerta.proyecto == 'SPV'){
                    listaSEMSPV.add(mail);  
                }else{
                    listaSEM.add(mail);   
                }
            }
        }

        // Recorremos la lista de emails a enviar y pasamos los valores a una nueva lista filtrada en la que no se incluyen los emails con un targetObjectId que equivalga a alguna de las queues (groups) SAC_PteSupervisor, SAC_PendienteAsignar o SPV_PendienteAsignar
        List<Messaging.SingleEmailMessage> listaSEMFiltrada = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> listaSEMFiltradaSPV = new List<Messaging.SingleEmailMessage>();
        if(!listaSEM.isEmpty()){
            listaSEMFiltrada = filtrarLista(listaSEM, mapaColas);
        }
        if(!listaSEMSPV.isEmpty()){
            listaSEMFiltradaSPV = filtrarLista(listaSEMSPV, mapaColas);
        }
        
        if(!listaSEMFiltrada.isEmpty()){
            enviarAndActualizarEM(listaSEMFiltrada, mapaUsuarioEmail, listaParaEnviarEmail, mapaTipoMaestro, mapaObjetoId, 'SAC');
        }    
        if(!listaSEMFiltradaSPV.isEmpty()){
            enviarAndActualizarEM(listaSEMFiltradaSPV, mapaUsuarioEmail, listaParaEnviarEmail, mapaTipoMaestro, mapaObjetoId, 'SPV');
        }
    }

    private static List<Messaging.SingleEmailMessage> filtrarLista(List<Messaging.SingleEmailMessage> listaEMSinFiltrar, Map<Id, Group> mapaColas) {

        List<Messaging.SingleEmailMessage> listaSEMFiltrada = new List<Messaging.SingleEmailMessage>();

        for(Messaging.SingleEmailMessage msglista : listaEMSinFiltrar){
            if(!mapaColas.containsKey(msglista.targetObjectId)){
                listaSEMFiltrada.add(msglista);
            }
        }

        return listaSEMFiltrada;
    }

    private static void enviarAndActualizarEM(List<Messaging.SingleEmailMessage> listaSEMFiltrada, Map<String, User> mapaUsuarioEmail, List<SAC_WrapperAlerta> listaParaEnviarEmail, Map<String, SAC_MaestroTipologiasAlertas__mdt> mapaTipoMaestro, Map<String, String> mapaObjetoId, String proyecto) {

        List<SAC_MaestroTemas__c> listEmailsNoValidos = new List<SAC_MaestroTemas__c>();

        //Recupero los emails no validos de envio (emails en la blackList)
        if(proyecto == 'SPV'){
            listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLISTSPV AND SAC_Activo__c = true];

        }else{
            listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];
        }
            //Le paso la listaEmailsNoValidos, la lista de EM a enviar, y un mapa con el id del usuario y su email. En este método se recupera de cada id del toAddress de la lista de EM a enviar
            //su email asociado (ayudandonos del mapa de mapUsuarioEmail). Y tras recuperar el email se comprueba si esta en la listEmailsNoValidos. Devolverá una lista filtrada con únicamente los
            //EM que se deben enviar (toAddress es una dirección válida, no está en la blackList)
            List<Messaging.SingleEmailMessage> listEMEnviar = SAC_Utils.comprobarEmailsBlackListIds(listEmailsNoValidos, mapaUsuarioEmail, listaSEMFiltrada);

            if(!listEMEnviar.isEmpty()){
                //Enviar los emails creados y filtrados en una sola llamada
                Messaging.sendEmail(listEMEnviar);

                //Comprobar listEMEnviar y listaParaEnviarEmail, para en caso de no haber enviado alertas por email no valido (blackList) quitar esa alerta de listaParaEnviarEmail
                //para así no intentar relacionar esa alerta con un EmailMessage que no existe (evitando que se relacione con otro sin ninguna relación)
                listaParaEnviarEmail = comprobarActualizarEMAlerta(listEMEnviar, listaParaEnviarEmail);
                
                //Actualizar EmailMessages con el lookup a su alerta correspondiente
                actualizarEMAlerta(listaParaEnviarEmail, mapaTipoMaestro, mapaObjetoId);
            }  
        }        

    /*****************************************************************
     * Proposito: Recupera los emails de los usuarios de la lista de wrapperAlerta introducida
     * y los devuelve en un mapa con key Id del User y valor User (con el campo email)
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US418231         Carlos Solis   28/07/22     Creación
    *****************************************************************/
    private static Map<String, User> recuperarMailsUsuarios(List<SAC_WrapperAlerta> listaParaEnviarEmail) {
        //Recoger ids usuarios para buscar sus emails
        Set<Id> setIdsUsuarios = new Set<Id>();
        Map<String, User> mapaUsuarioEmail = new Map<String, User>();

        for (SAC_WrapperAlerta wrapAlerta : listaParaEnviarEmail) {
            if (String.isNotBlank(wrapAlerta.idUsuarioDestinatario)) {
                setIdsUsuarios.add(wrapAlerta.idUsuarioDestinatario);    
            }
        }
        
        if (!setIdsUsuarios.isEmpty()) {
            List<User> listaUsuario = [SELECT Id, Email FROM User WHERE Id IN :setIdsUsuarios];

            if (!listaUsuario.isEmpty()) {
                for (User usuario : listaUsuario) {
                    
                    mapaUsuarioEmail.put(String.valueOf(usuario.Id), usuario);
                }
            }
        }
        
        return mapaUsuarioEmail;
    }

     /*****************************************************************
     * Proposito: Recuperar los mails y dividirlos por target ID para agruparlos en el envío
     * Esto hace que no se puedan personalizar a nivel de contact
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US494885         Alex Perez   12/12/2022    Creación
    *****************************************************************/
    private static Map<Id, list<string>> agruparEmailsTarget(List<SAC_WrapperAlerta> listaParaEnviarEmail) {
        //Recoger ids usuarios para buscar sus emails
        Set<Id> setIdsUsuarios = new Set<Id>();
        Map<Id, list<string>> mapaListaMails = new Map<Id, list<string>>();
        Id iObjeto = null; 

        for (SAC_WrapperAlerta wrapAlerta : listaParaEnviarEmail) {

            iObjeto = obtenerElObjeto(wrapAlerta);

            if(iObjeto != null && !wrapAlerta.listaEmailsGrupo.isEmpty()) {
                list<string> listaEmails;
                if(mapaListaMails.containsKey(iObjeto)) {
                    listaEmails = mapaListaMails.get(iObjeto);
                } else {
                    listaEmails = new list<string>();
                }
                listaEmails.addAll(wrapAlerta.listaEmailsGrupo);
                mapaListaMails.put(iObjeto, listaEmails);
            }
            
        }
        return mapaListaMails;
    }
    
    /*****************************************************************
     * Proposito: Obtiene el id de los 4 posibles objetos que afectan
     * a las alertas
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US494885         Alex Perez   12/12/2022    Creación
    *****************************************************************/
    private static Id obtenerElObjeto(SAC_WrapperAlerta wrapAlerta) {

        Id iObjeto;

        if(!string.isBlank(wrapAlerta.idInteraccion)){
            iObjeto = wrapAlerta.idInteraccion;
        } else if(!string.isBlank(wrapAlerta.idAccion)) {
            iObjeto = wrapAlerta.idAccion;
        } else if(!string.isBlank(wrapAlerta.idPretensionConsulta)) {
            iObjeto = wrapAlerta.idPretensionConsulta;
        } else {
            iObjeto = wrapAlerta.idReclamacion;
        }

        return iObjeto;

    }

    /*****************************************************************
     * Proposito: renderizar un body mergeando los campos del objeto
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US494885         Alex Perez   28/12/2022    Creación
    *****************************************************************/
    private static string renderizarHTML(Id usuario, Id objetoId, string body) {

        List<String> bodies = new List<String>();
        bodies.add(body); 
        List<Messaging.RenderEmailTemplateBodyResult> resList = Messaging.renderEmailTemplate(usuario, objetoId, bodies);
        return resList[0].getMergedBody();

    }

    private static void actualizarEMAlerta(List<SAC_WrapperAlerta> listaParaEnviarEmail, Map<String, SAC_MaestroTipologiasAlertas__mdt> mapaTipoMaestro, Map<String, String> mapaObjetoId) {
        //Recopilar valores de los wrapperAlerta para buscar los emailMessages correspondientes
        Set<String> setRelatedToId = new Set<String>();
        Set<String> setidAlertas = new Set<String>();

        for (SAC_WrapperAlerta wrapAlerta : listaParaEnviarEmail) {
            //RelatedToId cuando hay plantilla
            String objetoId = obtenerElObjeto(wrapAlerta);
            if (mapaObjetoId.containsKey(objetoId)) {
                setRelatedToId.add(objetoId);
            }
            //RelatedToId cuando se ha ligado a la alerta
            if (String.isNotBlank(wrapAlerta.idAlerta)) {
                setidAlertas.add(wrapAlerta.idAlerta);
            }
        }

        List<EmailMessage> lstEmailMessage = [SELECT id, EmailTemplateId, RelatedToId, Subject, SAC_Alerta__c FROM EmailMessage
                                              WHERE (RelatedToId IN :setRelatedToId OR RelatedToId IN :setidAlertas) AND Incoming = false AND SAC_Alerta__c = null
                                              ORDER BY createdDate DESC LIMIT :listaParaEnviarEmail.size()];

        //Actualizar registros emailMessage con su alerta
        List<EmailMessage> listaEMActualizar = new List<EmailMessage>();
        if (!lstEmailMessage.isEmpty()) {
            for (SAC_WrapperAlerta wrapAlerta : listaParaEnviarEmail) {
                String objetoId = obtenerElObjeto(wrapAlerta);
                for (EmailMessage em : lstEmailMessage) {
                    //Si han usado plantilla, el related to id es el objetoId de la alerta
                    if (String.isNotBlank(em.relatedtoId) && String.isNotBlank(objetoId) && em.relatedtoId == objetoId) {
                        em.SAC_Alerta__c = wrapAlerta.idAlerta;
                        listaEMActualizar.add(em);
                        //De lo contrario, lo buscamos por el relatedToId que coincide con la id de la alerta
                    } else if (String.isNotBlank(em.RelatedToId) && String.isNotBlank(wrapAlerta.idAlerta) && em.relatedToId == wrapAlerta.idAlerta) {
                        em.SAC_Alerta__c = wrapAlerta.idAlerta;
                        listaEMActualizar.add(em);
                    }
                }
            }
        }

        //Actualizar los EmailMessages
        if (!listaEMActualizar.isEmpty()) {
            SAC_DatabaseDML.updateListDML(listaEMActualizar, true);
            //Database.update(listaEMActualizar);
        }
    }


    /*****************************************************************
     * Proposito: comprobar listEMEnviar y listaParaEnviarEmail, para en caso de no haber enviado alertas por email no valido (blackList) quitar esa alerta de listaParaEnviarEmail
     *            para así no intentar relacionar esa alerta con un EmailMessage que no existe (evitando que se relacione con otro sin ninguna relación)
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US723742      Raúl Santos   05/03/2024       Creación
    *****************************************************************/
    private static List<SAC_WrapperAlerta> comprobarActualizarEMAlerta(List<Messaging.SingleEmailMessage> listEMEnviar, List<SAC_WrapperAlerta> listaParaEnviarEmail) {
        
        List<SAC_WrapperAlerta> listaParaEnviarEmailFiltrada = new List<SAC_WrapperAlerta>();
        Map<String, Messaging.SingleEmailMessage> mapaEmails = new Map<String, Messaging.SingleEmailMessage>();

        // Llenar el mapa con los elementos de listEMEnviar
        for (Messaging.SingleEmailMessage email : listEMEnviar) {
            String toAddress = email.getToAddresses()[0];
            mapaEmails.put(toAddress, email);
        }

        for (SAC_WrapperAlerta alerta : listaParaEnviarEmail) {
            Set<String> paraSet = new Set<String>();
        
            //Rellenamos el set con el id del usuario o los emails de la alerta
            if (String.isNotBlank(alerta.idUsuarioDestinatario) && alerta.listaEmailsGrupo.isEmpty()) {
                paraSet.add(alerta.idUsuarioDestinatario);
            } else {
                for (String email : alerta.listaEmailsGrupo) {
                    paraSet.add(email);
                }
            }
        
            //Recuperamos la claves del mapa
            Set<String> mapaEmailKeys = new Set<String>(mapaEmails.keySet());
        
            //Encuentramos los elementos comunes entre ambos conjuntos
            paraSet.retainAll(mapaEmailKeys);

            //Si el conjunto resultante no está vacío, significa que hay al menos un correo electrónico/id en común
            if (!paraSet.isEmpty()) {
                listaParaEnviarEmailFiltrada.add(alerta);
            }
        }

        return listaParaEnviarEmailFiltrada;
    }

    /*****************************************************************
     * Proposito: Recuperar las reclamaciones de cada alerta para comprobar si tienen informado el check SAC_M2P__c
     * para poder mandar el email de alerta desde el buzon de M2P en caso que el check sea true
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US777526         CS             22/05/2024   Creación
    *****************************************************************/
    public static Map<Id, Case> recuperarCasosComprobarM2P(List<SAC_WrapperAlerta> listaParaEnviarEmail) {
        Set<Id> setIdsReclamaciones = new Set<Id>();
        Map<Id, Case> mapaCasos = new Map<Id, Case>();
        List<Case> listaCasos = new List<Case>();
        for (SAC_WrapperAlerta wpAlerta : listaParaEnviarEmail) {
            if (String.isNotBlank(wpAlerta.idReclamacion)) {
                setIdsReclamaciones.add(wpAlerta.idReclamacion);
            }
        }

        //Recuperar reclamaciones de las alertas para comprobar su check SAC_M2P__c
        if (!setIdsReclamaciones.isEmpty()) {
            listaCasos = [SELECT Id, SAC_M2P__c FROM Case WHERE RecordTypeId = :RECTYPERECLAMACION AND Id IN :setIdsReclamaciones];
        }

        //Rellenar mapa a devolver
        if (!listaCasos.isEmpty()) {
            for (Case caso : listaCasos) {
                mapaCasos.put(caso.Id, caso);
            }
        }

        return mapaCasos;
    }

    /*****************************************************************
     * Proposito: Devuelve la id de la reclamación de la alerta
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US777526         CS             22/05/2024   Creación
    *****************************************************************/
    public static String obtenerIdReclamacion(SAC_WrapperAlerta wrapAlerta) {
        return String.isNotBlank(wrapAlerta.idReclamacion) ? wrapAlerta.idReclamacion : '';
    }
}