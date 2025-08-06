/***************************************************************** 
 * Name: SPV_LCMP_TareaOperativas
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Controlador del componente spv_TareaOperativas
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            --------         CS             05/07/2024   Creación
*****************************************************************/
public with sharing class SPV_LCMP_TareaOperativas {
    private static Set<String> objetos = new Set<String>{'SAC_Accion__c', 'CC_Grupo_Colaborador__c'};

    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEACCION = mapRTsObjects.get('SAC_Accion__c').get('SPV_Acciones').getRecordTypeId();
    private static final Id RECTYMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SPV_MaestroDeTareas').getRecordTypeId();
    private static final Id RECTYGRUPOTAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();

    /*****************************************************************
     * Proposito: Clase wrapper para recoger los valores de las plantillas
     * ***************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --------         CS             11/07/24     Creación
    *****************************************************************/
    public class TemplateWrapper{

        @AuraEnabled public String idTemplate{get; set;}
        @AuraEnabled public String nameTemplate{get; set;}
        @AuraEnabled public String subjectTemplate{get; set;}
        @AuraEnabled public String htmlValueTemplate{get; set;}
        @AuraEnabled public String paraTemplate{get; set;}
        
        public TemplateWrapper(String idTemplate, String nameTemplate, String subjectTemplate, String htmlValueTemplate, String paraTemplate){
            this.idTemplate = idTemplate;
            this.nameTemplate = nameTemplate;
            this.subjectTemplate = subjectTemplate;
            this.htmlValueTemplate = htmlValueTemplate;
            this.paraTemplate = paraTemplate;
        }
    }

    static public SAC_Accion__c recuperarTarea(Id tareaId){
       
        SAC_Accion__c tarea = new SAC_Accion__c();    
        tarea = [SELECT id, Name, OwnerId, CreatedById, SAC_EquipoResponsable__c,SAC_Estado__c, SAC_FechaVencimientoProrroga__c, SAC_Comentarios2__c,
                            SAC_Prorroga__c, SAC_FechaVencimientoInicial__c, SAC_ProrrogaCounter__c, SAC_Reclamacion__c, SAC_Pretension__c, SAC_Oficina__c,
                            SAC_Reclamacion__r.OwnerId, SAC_Pretension__r.OwnerId, SAC_MotivoDevolucion__c, SAC_ImpResueltoNotaria__c, SAC_EstadoNotaria__c, 
                            SAC_EstadoGestoria__c, SAC_ImpResueltoGestoria__c, SAC_EstadoRegistro__c, SAC_ImpResueltoRegistros__c, SAC_EstadoTasacion__c, 
                            SAC_ImpResueltoTasacion__c, SAC_NumeroContrato__c, SAC_NCuentaAbono__c, SAC_Comentarios__c, SAC_ImporteResuelto__c, SAC_ImporteAbonar__c,
                            SAC_MaestroAccionesReclamacion__r.SAC_tipo_formulario__c, SAC_ImpResueltoInteresesLegales__c, SAC_MaestroAccionesReclamacion__r.Name,
                            SAC_Oficina__r.CC_Email__c, SAC_IndexedThreadId__c, SAC_Antecedentes_Revisados__c, SAC_Reclamacion__r.SEG_Grupo__c, SAC_Reclamacion__r.SAC_PretensionPrincipal__r.SEG_Grupo__c,
                            SAC_Pretension__r.SEG_Grupo__c, SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c, SAC_EquipoResponsable__r.SAC_Email__c, SAC_EquipoResponsable__r.SAC_Email2__c, SAC_EquipoResponsable__r.SAC_Email3__c, SPV_FechaReenvio__c, 
                            SPV_FechaSolicitudAnulacion__c, SPV_MotivoAnulacion__c, SPV_CheckAnulacionSolicitada__c, SPV_FechaAnulacion__c
                    FROM SAC_Accion__c 
                    WHERE id = :tareaId LIMIT 1]; 
        return tarea; 
    }

    /*****************************************************************
     * Proposito: Buscar si el usuario que ejecuta la acción pertenece al grupo gestor 
     *             de la reclamación o al grupo letrado de la pretensión
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --------         CS             15/07/24     Creación
    *****************************************************************/
    public static Boolean usuarioPerteneceGrupoCaso(SAC_Accion__c tarea, Id idUser){
        Boolean esGrupoCaso = false;
        List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
        colabContact = [SELECT id,CC_Grupo_Colaborador__c,CC_Usuario__c 
                                FROM CC_Grupo_Colaborador_Contact__c //Buscar si el usuario que ejecuta la acción pertenece al grupo gestor de la reclamación o al grupo letrado de la pretensión
                                WHERE (CC_Grupo_Colaborador__c=:tarea.SAC_Reclamacion__r.SEG_Grupo__c OR CC_Grupo_Colaborador__c=:tarea.SAC_Pretension__r.SEG_Grupo__c)
                                AND CC_Usuario__c=:idUser];
                    
        if(!colabContact.isEmpty()){esGrupoCaso = true;}

        return esGrupoCaso;
    }

    /*****************************************************************
     * Proposito: Comprobar si el usuario pertenece a COPS o a AJ
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --------         CS             15/07/24     Creación
    *****************************************************************/
    public static Boolean perteneceCOPSAJ(Id idUser){
        Boolean pertenece = false;

        List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
            colabContact = [SELECT id    //Buscar si el usuario pertenece a COPS o a AJ
                            FROM CC_Grupo_Colaborador_Contact__c 
                            WHERE CC_Usuario__c=:idUser
                            AND CC_Grupo_Colaborador__r.RecordTypeId = :RECTYGRUPOTAREAS
                            AND (CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'SPV_COPS' OR CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'SPV_AJ')];

         if(!colabContact.isEmpty()){pertenece = true;}                   
       
         return pertenece;
    }

    /*****************************************************************
     * Proposito: Buscar si el usuario que ejecuta la acción pertenece al mismo grupo al que pertenece la tarea
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --------         CS             15/07/24     Creación
    *****************************************************************/
    public static Boolean usuarioPerteneceGrupoTarea(SAC_Accion__c tarea, Id idUser){
        Boolean esElMismoGrupo = false;

        List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
        colabContact = [SELECT id,CC_Grupo_Colaborador__c,CC_Usuario__c 
                                FROM CC_Grupo_Colaborador_Contact__c //Buscar si el usuario que ejecuta la acción pertenece al mismo grupo al que pertenece la tarea
                                WHERE CC_Grupo_Colaborador__r.RecordTypeId = :RECTYGRUPOTAREAS
                                AND CC_Grupo_Colaborador__c=:tarea.SAC_EquipoResponsable__c 
                                AND CC_Usuario__c=:idUser];


        if(!colabContact.isEmpty()){
            esElMismoGrupo = true;
        }
        else {
            List<Contact> empleadoOficina= new List<Contact>();
            empleadoOficina = [SELECT AccountId FROM contact WHERE AV_UsuarioAsociado__c =: idUser ];

            if(!empleadoOficina.isEmpty())
            {
                esElMismoGrupo = (tarea.SAC_Oficina__c != null && empleadoOficina[0].AccountId == tarea.SAC_Oficina__c);
            }
        }

        return esElMismoGrupo;
    }

    /*****************************************************************
     * Proposito: Tomar en propiedad la tarea. Solo puede tomarse en propiedad si
     * el usuario pertenece a el grupo de la tarea.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --------         CS             05/07/2024   Creación
    *****************************************************************/
    @AuraEnabled
    public static void tomarPropiedadTarea(String tareaId, String usuarioActualId) {
        String mensajeError = '';
        try {
            //Asignar id accion
            SAC_Accion__c accion = recuperarTarea(tareaId);
            Id idUsuario = UserInfo.getUserId();

            if (usuarioPerteneceGrupoTarea(accion, idUsuario) || usuarioPerteneceGrupoCaso(accion, idUsuario) || perteneceCOPSAJ(idUsuario)) {
                accion.OwnerId = usuarioActualId;
                accion.SAC_Estado__c = 'SAC_EnGestion';
                SPV_DatabaseDML.updateDML(accion, true);
            } else {
                mensajeError = 'No tienes permisos para tomar en propiedad la tarea';
                throw new AuraHandledException(mensajeError);
            }
        } catch (Exception e) {
            if (String.isNotBlank(mensajeError)) { e.setMessage(mensajeError); }
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    static public void devolverTarea(Id tareaId){
        String mensajeError = '';
        try {
            //Asignar id accion
            SAC_Accion__c tarea = recuperarTarea(tareaId);
            Id idUsuario = UserInfo.getUserId();
            
		    List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];

            if(!cola.isEmpty() && (tarea.ownerId == idUsuario || perteneceCOPSAJ(idUsuario) || usuarioPerteneceGrupoTarea(tarea, idUsuario))){ 
                tarea.OwnerId = cola[0].id;
                tarea.SAC_Estado__c='SAC_PendienteAsignar';
                SPV_DatabaseDML.updateDML(tarea, true);

                SPV_HandlerWithoutSharingMethods.insertarAccionShare(tarea);
            }
        } catch (Exception e) { if (String.isNotBlank(mensajeError)) { e.setMessage(mensajeError); }
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*****************************************************************
     * Proposito: Devolver la tarea al gestor de la reclamación (si se ha creado desde la reclamación)
     * o al letrado de la pretensión (si se ha creado desde la pretensión)
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --------         CS             11/07/24     Creación
    *****************************************************************/
    @AuraEnabled
    static public void devolverTareaGestorLetrado(Id tareaId, String motivoDevolucion){
        String mensajeError = '';
        SAC_Accion__c tarea = recuperarTarea(tareaId);
        Id idUsuario = UserInfo.getUserId();

        //Comprobar si el usuario actual es administrador del grupo de tareas.
        List<CC_Grupo_Colaborador_Contact__c> listaColabContacts = [SELECT Id FROM CC_Grupo_Colaborador_Contact__c 
                                                                    WHERE CC_Grupo_Colaborador__c = : tarea.SAC_EquipoResponsable__c 
                                                                    AND CC_Usuario__c = :idUsuario
                                                                    AND SAC_Administrador__c = true];
        Boolean esAdmin = listaColabContacts.isEmpty() ? false : true;

        if (tarea.OwnerId == idUsuario || usuarioPerteneceGrupoCaso(tarea, idUsuario) || perteneceCOPSAJ(idUsuario) || esAdmin) {
            //Si el campo SAC_Pretension__c no está vacío, siginifca que hay que devolver la tarea al letrado de la pretensión.
            // if (String.isNotBlank(tarea.SAC_Pretension__c)) {
            //     tarea.ownerId = tarea.SAC_Pretension__r.OwnerId;
            // } else {
            //     tarea.ownerId = tarea.SAC_Reclamacion__r.OwnerId;
            // }

            //El estado de la tarea pasa a ser devuelta y se le añade el motivo de devolución
            tarea.SAC_Estado__c = 'SAC_Devuelta';
            //Si el motivo está en blanco, lo relleno con el nuevo valor
            if (String.isBlank(tarea.SAC_MotivoDevolucion__c)) {
                tarea.SAC_MotivoDevolucion__c = CBK_UtilsDate.nowSYS().addHours(2) + ' ' + motivoDevolucion;
            } else { //De lo contrario, se concatena con el anterior valor
                tarea.SAC_MotivoDevolucion__c = tarea.SAC_MotivoDevolucion__c + '\n' + CBK_UtilsDate.nowSYS().addHours(2) + ' ' + motivoDevolucion;
            }
            
            try {
                SPV_DatabaseDML.updateDML(tarea, true);
            } catch (Exception e) {throw new AuraHandledException(e.getMessage());}    
        } else {
            mensajeError = 'No tienes permisos para devolver la tarea';
            throw new AuraHandledException(mensajeError);
        }
    }

    @AuraEnabled
    public static void enviarTarea(Id tareaId){
        //String emailsInvalidos = '';

        //Recuperar cola
        Group pendiente = [SELECT id, DeveloperName FROM Group WHERE DeveloperName =: 'SPV_PendienteAsignar' LIMIT 1];

        //Recuperar tarea
        SAC_Accion__c tarea = recuperarTarea(tareaId);
        Id idUsuario = UserInfo.getUserId();

        //Validaciones tareas
        /*list<SAC_Accion__c> ltarea = new list<SAC_Accion__c>();
        ltarea.add(tarea);
        if(tarea.SAC_MaestroAccionesReclamacion__r?.SAC_tipo_formulario__c == 'Importe' || 
        tarea.SAC_MaestroAccionesReclamacion__r?.SAC_tipo_formulario__c == 'Importes hipotecarios') {
            string errorValidacion = SAC_Validaciones.validarEscaladoEnvioTarea(ltarea, tarea.SAC_Reclamacion__c, 'Tarea');
            if(errorValidacion != '') {
                throw new AuraHandledException(errorValidacion);
            }
        }*/

        Case reclamacion = [SELECT id, OwnerId FROM Case WHERE id =: tarea.SAC_Reclamacion__c LIMIT 1];
        List<Case> pretensiones = [SELECT OwnerId FROM Case WHERE SAC_Reclamacion__c =: reclamacion.Id];
        Set<Id> ids = new Set<Id>();
        for(Case pretension : pretensiones){
            ids.add(pretension.OwnerId);
        }

        if (idUsuario == reclamacion.OwnerId || ids.contains(idUsuario) || idUsuario == tarea.OwnerId || usuarioPerteneceGrupoCaso(tarea, idUsuario) || perteneceCOPSAJ(idUsuario)) {
            //Envío de tarea
            //Si el estado está en devuelta, hay que enviarla al owner que la devolvió (siempre que pertenezca al grupo resolutor ya que podrían haberlo cambiado) y rellenamos el campor de reenvio de la tarea
            if (tarea.SAC_Estado__c == 'SAC_Devuelta') {
                //Rellenar el campo de reenvio de la tarea
                if (String.isBlank(tarea.SPV_FechaReenvio__c)) {
                    tarea.SPV_FechaReenvio__c = ''+ CBK_UtilsDate.nowSYS().addHours(2);
                } else { //De lo contrario, se concatena con el anterior valor
                    tarea.SPV_FechaReenvio__c = tarea.SPV_FechaReenvio__c + '\n' + CBK_UtilsDate.nowSYS().addHours(2);
                }
                //Recuperar antiguos owners
                List<SAC_Accion__History> listaAccionHistory = [SELECT id,OldValue, NewValue, Field, CreatedDate  FROM SAC_Accion__History WHERE ParentId = :tareaId AND Field = 'Owner' AND DataType = 'EntityId' ORDER BY CreatedDate desc];
                //Si la query nos devuelve datos, la recorremos
                if (!listaAccionHistory.isEmpty() || Test.isRunningTest()) {
                    String nuevoOwner;
                    Boolean encontrado = false;
                    for (SAC_Accion__History accionHistory : listaAccionHistory) {
                        //Si el owner anterior no es la cola pendiente de asignar, es el que buscamos
                        if (accionHistory.OldValue != pendiente.Id) {
                            nuevoOwner = String.valueOf(accionHistory.OldValue);
                            encontrado = true;
                            break;
                        }
                    }
                    //Si ha encontrado al anterior user y este pertenece al grupo responsable, la tarea pasa a en gestión y el owner será el que hemos encontrado
                    if (encontrado && comprobarUserEsDelGrupo(nuevoOwner, tarea.SAC_EquipoResponsable__c)) {
                        tarea.SAC_Estado__c = 'SAC_EnGestion';
                        tarea.OwnerId = nuevoOwner;
                    } else { //De lo contrario, se pondrá a en pendiente de asignar tanto el estado como el owner
                        tarea.SAC_Estado__c = 'SAC_PendienteAsignar';
                        tarea.OwnerId = pendiente.Id;
                    }
                } else { //Si la query no nos ha devuelto datos, se pondrá a en pendiente de asignar tanto el estado como el owner
                    tarea.SAC_Estado__c = 'SAC_PendienteAsignar';
                    tarea.OwnerId = pendiente.Id;
                }
            } else { //Si el estado no es devuelta, se pondrá a en pendiente de asignar tanto el estado como el owner
                tarea.SAC_Estado__c = 'SAC_PendienteAsignar';
                tarea.OwnerId = pendiente.Id;
            }

            SPV_DatabaseDML.updateDML(tarea, true);

            // Recuperar las tareas 'SPV_GENERALOFICINAS' para preparar el envio de correo electronico a la oficina
            if(tarea.SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c == 'SPV_GENERALOFICINAS'){
                correoTareaOficina(tarea);
            }
            
        }
    }

     /*****************************************************************
     * Proposito: Comprueba si el usuario introducido forma parte del grupo introducido.
     * Si forma parte, devuelve true. De lo contrario, devuelve false.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             08/07/24     Creación
    *****************************************************************/
    public static Boolean comprobarUserEsDelGrupo(String usuarioId, String grupoId) {
        List<CC_Grupo_Colaborador_Contact__c> listaColabContact = [SELECT Id FROM CC_Grupo_Colaborador_Contact__c 
                                                                    WHERE CC_Usuario__c = :usuarioId
                                                                    AND CC_Grupo_Colaborador__c = :grupoId];

        return !listaColabContact.isEmpty() ? true : false;
    }

    /**************************************************************************
     * Proposito: Recuperar los adjuntos de la tarea y enviar el correo
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --------         CS             11/07/24      Creación 
    **************************************************************************/
    public static void correoTareaOficina(SAC_Accion__c tarea) {
        if(String.isBlank(tarea.SAC_Oficina__c)){
            throw new AuraHandledException('Para enviar la tarea necesita una oficina informada.');
        }

        //Recuperamos el para, el correo de la oficina
        String para = ''; 
        if(String.isNotBlank(tarea.SAC_Oficina__r.CC_Email__c)) {
            para = tarea.SAC_Oficina__r.CC_Email__c;    
        }else{throw new AuraHandledException('Para enviar la tarea necesita que la oficina tenga un email informado.');}

        if(String.isBlank(tarea.SAC_Comentarios__c)){throw new AuraHandledException('Para enviar la tarea debe detallar un comentario.');}

        //Recuperamos la plantilla
        if(!Schema.sObjectType.EmailTemplate.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar las plantillas' ); }
        List<EmailTemplate> listaTemplate = [SELECT Id, Name, Subject, HtmlValue, RelatedEntityType FROM EmailTemplate WHERE DeveloperName = 'SPV_TareaOficina'];

        if (!listaTemplate.isEmpty()) {
            String whoId = UserInfo.getUserId();
            Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(listatemplate[0].Id, whoId, tarea.Id);                      
            TemplateWrapper plantilla = new TemplateWrapper(listaTemplate[0].Id, listaTemplate[0].Name, renderStored.getSubject(), renderStored.getHtmlBody(), '');

            // Metodo para recuperar los adjuntos y enviar el mail
            if (String.isNotBlank(para) && plantilla != null) {
                recuperarAdjuntos(tarea.Id, para, plantilla);
            }
        } else {throw new AuraHandledException('No se ha encontrado una plantilla para el envío automático del email a la oficina.');}
    }

    /**************************************************************************
     * Proposito: Recuperar los adjuntos de la tarea y enviar el correo
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --------         CS             11/07/24      Creación 
    **************************************************************************/
    public static void recuperarAdjuntos(Id idTarea, String para, TemplateWrapper plantillaEmail){

        List<ContentVersion> adjuntos = recuperaAdjuntos(idTarea); 

        Set<Id> idContentDocument = new Set<Id>();

        for(ContentVersion cv : adjuntos){
            if(cv.SAC_Oculto__c == false){  // No recuperamos los adjuntos ocultos (SAC_Oculto__c = true), ya que estos no debemos mandarlos.
                idContentDocument.add(cv.ContentDocumentId);
            }
        }

        List<ContentDocument> documentos = new List<ContentDocument>();
        if(!idContentDocument.isEmpty()){
            if(!Schema.sObjectType.ContentDocument.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar el ContentDocument.' ); }
            documentos = [SELECT Id FROM ContentDocument WHERE id IN: idContentDocument]; 
        }

        Set<Id> idAdjuntos = new Set<Id>();
        for(ContentDocument doc : documentos){
            idAdjuntos.add(doc.Id);
        }

        SPV_LCMP_GestionEmails.enviarEmail(idTarea, para, '', '', plantillaEmail.htmlValueTemplate, plantillaEmail.subjectTemplate, JSON.serialize(idAdjuntos), null);
    }

    /**************************************************************************
     * Proposito: Recuperar los adjuntos de la tarea
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --------         CS             11/07/24      Creación 
    **************************************************************************/
    public static ContentVersion[] recuperaAdjuntos(String id){

        Map<Id, Boolean> contentOculto = new Map<Id, Boolean>();
        List<Id> idsDocumentLink = new List<Id>();

        try {
        List<ContentDocumentLink> cdL = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =: id AND ContentDocument.FileType != 'SNOTE'];  
        

            for(ContentDocumentLink recordCdL : cdL){

                idsDocumentLink.add(recordCdL.ContentDocumentId);
            }

            List<ContentVersion> cv = [SELECT Id, ContentDocumentId, Title, SAC_Oculto__c, CreatedDate, SAC_TipoAdjunto__c, SAC_TipoAdjunto__r.Name, SAC_Bloque__c FROM ContentVersion WHERE ContentDocumentId IN: idsDocumentLink ORDER BY CreatedDate ASC];

            for(ContentVersion recordCv : cv){
                contentOculto.put(recordCv.id, recordCv.SAC_Oculto__c);
            }

            ContentVersion[] resultado =  new List<ContentVersion>();
            for(ContentDocumentLink record : cdL){

                if(contentOculto.get(record.id) != null){

                    resultado.add(new ContentVersion (ContentDocumentId=record.ContentDocumentId, Title=record.ContentDocument.Title, SAC_Oculto__c=contentOculto.get(record.id)));

                }else{resultado.add(new ContentVersion (ContentDocumentId=record.ContentDocumentId, Title=record.ContentDocument.Title, SAC_Oculto__c=false));}
            }

            return cv;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void prorrogarTarea(String tareaId, String fechaProrroga) {
        String mensajeError = '';
        SAC_Accion__c tarea = recuperarTarea(tareaId);
        Id idUsuario = UserInfo.getUserId();

        if (tarea.SAC_FechaVencimientoProrroga__c < Date.today()) {
            mensajeError = 'No se puede prorrogar la tarea si ya ha pasado la fecha de vencimiento';
            throw new AuraHandledException(mensajeError);
        }

        if (perteneceCOPSAJ(idUsuario) || usuarioPerteneceGrupoTarea(tarea, idUsuario)) {
            Date fechaProrrogaDate = Date.valueOf(fechaProrroga);
            tarea.SAC_FechaVencimientoProrroga__c = fechaProrrogaDate;
            SPV_DatabaseDML.updateDML(tarea, true);
        }else {
            mensajeError = 'No tienes permisos para prorrogar la tarea';
            throw new AuraHandledException(mensajeError);
        }
    }

    @AuraEnabled
    public static void descartarTarea(String tareaId, String comentarios) {
        finalizarTareaGlobal(tareaId, 'SAC_Descartada', comentarios);
    }

    @AuraEnabled
    public static void finalizarIncompleta(String tareaId, String comentarios) {
        finalizarTareaGlobal(tareaId, 'SAC_FinalizadaIncompleta', comentarios);
    }

    @AuraEnabled
    public static void finalizarTarea(String tareaId, String comentarios) {
        finalizarTareaGlobal(tareaId, 'SAC_Finalizada', comentarios);
    }

    public static void finalizarTareaGlobal(String tareaId, String estadoTarea, String comentarios) {
        //Recuperar tarea
        SAC_Accion__c tarea = recuperarTarea(tareaId);
        Id idUsuario = UserInfo.getUserId();

        //Toma en propiedad la tarea en caso que deba hacerlo
        if(tarea.SAC_Estado__c == 'SAC_PendienteEnviar' || tarea.SAC_Estado__c == 'SAC_PendienteAsignar' || tarea.SAC_Estado__c == 'SAC_Devuelta'){
            tomarPropiedadTarea(tareaId, idUsuario);
        }

        //Si el estado es descartada, se rellena el campo SAC_MotivoDescarte__c (si no estan vacios los comentarios)
        SAC_Accion__c tareaFinalizar = new SAC_Accion__c();
        tareaFinalizar.Id = tareaId;
        tareaFinalizar.SAC_Estado__c = estadoTarea;
        tareaFinalizar.SPV_CheckAnulacionSolicitada__c = false;
        if (estadoTarea == 'SAC_Descartada' && String.isNotBlank(comentarios)) {
            tareaFinalizar.SAC_MotivoDescarte__c = comentarios;
        } else if (String.isNotBlank(comentarios)) {
            tareaFinalizar.SAC_Comentarios2__c = (String.isNotBlank(tarea.SAC_Comentarios2__c)) ? tarea.SAC_Comentarios2__c + comentarios : comentarios;
        }

        SPV_DatabaseDML.updateDML(tareaFinalizar, true);
    }

    /*
    Pone la tarea en estado Pendiente asignar (enviada) y es el trigger el que se encarga de enviar la tarea a GGH
    cuando detecta el cambio de estado y si la tarea es de GGH
    */
    @AuraEnabled
    public static void enviarTareaGGH(Id tareaId){

        SAC_Accion__C tarea = new SAC_Accion__C(Id = tareaId, SAC_Estado__c = 'SAC_PendienteAsignar');
        try {
            SPV_DatabaseDML.updateDML(tarea, true);
        } catch (Exception e) { 
            String errorMsg = e.getMessage();
            String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
            if (String.isNotBlank(pureErrorMsg)) {
                pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-4));
                throw new AuraHandledException(pureErrorMsg);
            } else {
                throw new AuraHandledException(e.getMessage());
            }
        }        
    }

    @AuraEnabled
    public static void finalizarTareaGGH(Id tareaId){
        SAC_Accion__C tarea = new SAC_Accion__C(Id = tareaId, SAC_Estado__c = 'SAC_Finalizada');
        SPV_DatabaseDML.updateDML(tarea, true);
    }

    @AuraEnabled
    public static void notificarTareaResolutor(Id tareaId, String comentarios){

        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
        SAC_Accion__c tarea = recuperarTarea(tareaId);

        List<String> listaEmails = new List<String>();
        if(String.isNotBlank(tarea.SAC_EquipoResponsable__r.SAC_Email__c)){
            listaEmails.add(tarea.SAC_EquipoResponsable__r.SAC_Email__c);
        }
        if(String.isNotBlank(tarea.SAC_EquipoResponsable__r.SAC_Email2__c)){
            listaEmails.add(tarea.SAC_EquipoResponsable__r.SAC_Email2__c);
        }
        if(String.isNotBlank(tarea.SAC_EquipoResponsable__r.SAC_Email3__c)){
            listaEmails.add(tarea.SAC_EquipoResponsable__r.SAC_Email3__c);
        }


        //Preparar una alerta
        SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(tarea.SAC_Reclamacion__c,
                                                            'SPV_016',
                                                            'Notificación de la Acción ' + tarea.Name + '. ' + comentarios,
                                                            tarea.OwnerId,
                                                            '',
                                                            tarea.Id,
                                                            '');
                                                            wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + tarea.Id;
                                                            wrapAlerta.listaEmailsGrupo = listaEmails;
                                                            wrapAlerta.idGrupoColaborador = tarea.SAC_EquipoResponsable__c;
                                                            wrapAlerta.proyecto = 'SPV';
        //Añadirla a la lista para posteriormente llamar al método
        listaWrapperAlerta.add(wrapAlerta);

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }
    }
    /**************************************************************************
     * Proposito: Solicitar la anulación de una tarea.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --------         Carlos Gómez   19/05/25      Creación 
    **************************************************************************/
    @AuraEnabled
    public static void solicitarAnulacion(Id tareaId, String motivo){
        //Recuperar tarea
        SAC_Accion__c tarea = recuperarTarea(tareaId);
        Id idUsuario = UserInfo.getUserId();

        Case reclamacion = [SELECT id, OwnerId FROM Case WHERE id =: tarea.SAC_Reclamacion__c LIMIT 1];
        List<Case> pretensiones = [SELECT OwnerId FROM Case WHERE SAC_Reclamacion__c =: reclamacion.Id];
        Set<Id> ids = new Set<Id>();
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();

        for(Case pretension : pretensiones){
            ids.add(pretension.OwnerId);
        }

        if (idUsuario == reclamacion.OwnerId || ids.contains(idUsuario) || usuarioPerteneceGrupoCaso(tarea, idUsuario) || perteneceCOPSAJ(idUsuario)) {
            //Si el motivo está en blanco, lo relleno con el nuevo valor
            tarea.SPV_CheckAnulacionSolicitada__c = true;
            tarea.SPV_MotivoAnulacion__c = motivo;
            tarea.SPV_FechaSolicitudAnulacion__c = CBK_UtilsDate.nowSYS();
            SPV_DatabaseDML.updateDML(tarea, true);
            //Preparar una alerta
            SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(tarea.SAC_Reclamacion__c,
                                                                'SPV_026',
                                                                'Solicitud de anulación de la Tarea ' + tarea.Name + '. ' + motivo,
                                                                tarea.OwnerId,
                                                                '',
                                                                tarea.Id,
                                                                '');
            wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + tarea.Id;
            wrapAlerta.proyecto = 'SPV';
            listaWrapperAlerta.add(wrapAlerta);
            SAC_Alertas.generarAlertas(listaWrapperAlerta);

        } else {
            String mensajeError = 'No tienes permisos para solicitar la anulacion de la tarea';
            throw new AuraHandledException(mensajeError);
        }
    }

    /**************************************************************************
     * Proposito: Cancelar la solicitud de anulación de una tarea.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --------         Carlos Gómez   19/05/25      Creación 
    **************************************************************************/

    @AuraEnabled
    public static void cancelarSolicitud(Id tareaId){
        //Recuperar tarea
        SAC_Accion__c tarea = recuperarTarea(tareaId);
        Id idUsuario = UserInfo.getUserId();

        Case reclamacion = [SELECT id, OwnerId FROM Case WHERE id =: tarea.SAC_Reclamacion__c LIMIT 1];
        List<Case> pretensiones = [SELECT OwnerId FROM Case WHERE SAC_Reclamacion__c =: reclamacion.Id];
        Set<Id> ids = new Set<Id>();
        for(Case pretension : pretensiones){
            ids.add(pretension.OwnerId);
        }

        if (tarea.SPV_CheckAnulacionSolicitada__c == true && (idUsuario == reclamacion.OwnerId || ids.contains(idUsuario) ||  perteneceCOPSAJ(idUsuario) || usuarioPerteneceGrupoCaso(tarea, idUsuario))) {
            tarea.SPV_CheckAnulacionSolicitada__c = false;
            tarea.SPV_FechaSolicitudAnulacion__c = null;
            tarea.SPV_MotivoAnulacion__c = '';
            SPV_DatabaseDML.updateDML(tarea, true);
        } else {
            String mensajeError = 'No tienes permisos para cancelar la anulacion de la tarea';
            throw new AuraHandledException(mensajeError);
        }
    }

            /**************************************************************************
     * Proposito: Aceptar la solicitud de anulación de una tarea.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --------         Carlos Gómez   19/05/25      Creación 
    **************************************************************************/

    @AuraEnabled
    public static void aceptarSolicitudAnulacion(Id tareaId){
        //Recuperar tarea
        SAC_Accion__c tarea = recuperarTarea(tareaId);
        Id idUsuario = UserInfo.getUserId();

        if (tarea.SPV_CheckAnulacionSolicitada__c == true && (tarea.OwnerId == idUsuario)) {
            tarea.SPV_CheckAnulacionSolicitada__c = false;
            tarea.SPV_FechaAnulacion__c = CBK_UtilsDate.nowSYS();
            tarea.SAC_Estado__c = 'SPV_Anulada';
            SPV_DatabaseDML.updateDML(tarea, true);
        } else {
            String mensajeError = 'No tienes permisos para aceptar la anulación, tienes que ser el propietario de la tarea';
            throw new AuraHandledException(mensajeError);
        }
    }
}