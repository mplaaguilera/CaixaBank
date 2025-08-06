public without sharing class SAC_NotificarTareasReclamacionVF {

    public List<SAC_Accion__C> listaAcciones{get;private set;}
    public String currentRecord{get; set;}
    public boolean mostrar {get; set;}
    public Id idUsuario {get; set;}
    public String mensaje {get; set;}
    public Boolean esCOPSOAJ {get; set;}
    public Boolean esAdmin {get; set;}
    public Boolean ownerRecPret {get; set;}
    public List<SAC_Accion__c> listaTareas = new List<SAC_Accion__c>();
    public List<SAC_Accion__c> listaTareasReclamacion = new List<SAC_Accion__c>();
    public Map<Id, Id> mapaGrupos = new Map<Id, Id>();
    static Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    static Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
    static Id recTypeReclamacionSPV = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();
    static Id recTypePretensionSPV = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Pretension').getRecordTypeId();
    static Id recTypeGrupoTareas = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoDeTareas').getRecordTypeId();
    static Id recTypeGrupoGestorSPV = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoGestor').getRecordTypeId();
    static Id recTypeTareasSPV = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SPV_Acciones').getRecordTypeId();
    static Id recTypeTareasMaestroSPV = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SPV_MaestroDeTareas').getRecordTypeId();

    List<Group> listaColas = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND (DeveloperName = 'SAC_PendienteAsignar' OR DeveloperName = 'SPV_PendienteAsignar')];

    public SAC_NotificarTareasReclamacionVF(ApexPages.StandardSetController stdSetController) {
        //Recuperamos los valores de la Visual Force Page
        listaAcciones = (List<SAC_Accion__C>) stdSetController.getSelected();
        currentRecord = ApexPages.currentPage().getParameters().get('id');
        esCOPSOAJ = false;
        esAdmin = false;
        ownerRecPret = false;

        if (listaAcciones.isempty() && String.isBlank(currentRecord)){ //Los dos en blanco, no se ha seleccionado nada
            mostrar = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Debes seleccionar al menos un registro.'));
        }else if (listaAcciones.isempty() && String.isNotBlank(currentRecord)) { //Se llama desde la pagina de la reclamación
            idUsuario = UserInfo.getUserId();
            comprobarPermisosEnReclamacion(false);
        } else if (!listaAcciones.isEmpty() && String.isBlank(currentRecord)) { //Se llama desde la listView 
            idUsuario = UserInfo.getUserId();
            comprobarPermisos();
        } else if (!listaAcciones.isempty() && String.isNotBlank(currentRecord)) { //Se llama desde la reclamación habiendo seleccionado tareas de la related list
            idUsuario = UserInfo.getUserId();
            comprobarPermisosEnReclamacion(true);
        }
    }

    /*****************************************************************
     * Proposito: Método para comprobar los permisos de quien puede usar el botón si
     * se ha pulsado desde la list view de acciones. Debe tener permisos si es usuario de COPS o AJ o,
     * en su defecto, si es administrador de un grupo.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Carlos Solis   13/05/22     Creación
    *****************************************************************/
    public void comprobarPermisos() {
        //Comprobar si es de COPS o AJ
        Boolean esCOPSAJ = SAC_TareasOperativas_Controller.perteneceCOPSAJ(idUsuario);
        List<CC_Grupo_Colaborador_Contact__c> listaColabContacts = new List<CC_Grupo_Colaborador_Contact__c>();

        //Si no es de COPS o AJ, comprobar si es administrador de algún grupo proveedor o de tareas
        if (!esCOPSAJ) {
            listaColabContacts = [SELECT Id, CC_Usuario__c, CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c 
            WHERE (CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoResponsableAccion' OR CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoProveedores' OR CC_Grupo_Colaborador__r.RecordTypeId = :recTypeGrupoTareas OR CC_Grupo_Colaborador__r.RecordTypeId = :recTypeGrupoGestorSPV)
            AND CC_Usuario__c = :idUsuario
            AND SAC_Administrador__c = true];

            //Si existe algún registro, sabemos que es administrador y lo indicamos en la variable esAdmin
            esAdmin = listaColabContacts.isEmpty() ? false : true;
        }
        if (!esCOPSAJ && !esAdmin) { //Si no es ni de cops aj ni administrador de un grupo, comprobar si es owner de la reclamación o de las pretensiones de la tarea
            if (!listaAcciones.isEmpty()) { 
                listaTareas = [SELECT id, Name, OwnerId, SAC_EquipoResponsable__c, SAC_Estado__c, SAC_Reclamacion__r.SEG_Grupo__c, 
                                SAC_Reclamacion__r.OwnerId, SAC_Reclamacion__r.SAC_PretensionPrincipal__r.OwnerId
                                FROM SAC_Accion__c
                                WHERE id = :listaAcciones];
                
                if (!listaTareas.isEmpty()) {
                    for (SAC_Accion__c tarea : listaTareas) {
                        if (tarea.SAC_Reclamacion__r.OwnerId == idUsuario || tarea.SAC_Reclamacion__r.SAC_PretensionPrincipal__r.OwnerId == idUsuario) {
                            ownerRecPret = true; //Si es owner de alguna de las reclamaciones o pretensiones, se indica en la variable
                        }
                    }
                }
            }
        }

        if (esCOPSAJ) {
            mostrar = true;
            esCOPSOAJ = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO ,listaAcciones.size() +' tareas seleccionadas. Se mandará notificación sobre las tareas enviadas y en estado no finalizado a los gestores de las tareas.'));
        } else if (esAdmin) {
            for (CC_Grupo_Colaborador_Contact__c colabContact : listaColabContacts) {
                mapaGrupos.put(colabContact.CC_Grupo_Colaborador__c, colabContact.CC_Grupo_Colaborador__c);
            }
            mostrar = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO ,'<h4>'+listaAcciones.size() +' tareas seleccionadas. </h4>'+
                                                                                'Se mandará notificación sobre las tareas enviadas y en estado no finalizado a los gestores de las tareas en las que:<br/>'+
                                                                                ' - Seas el gestor de la reclamación de la tarea o letrado de las pretensiones de la reclamación.<br/>'+
                                                                                ' - Seas administrador del grupo de la reclamación de la tarea.'));
        } else if (ownerRecPret) {
            mostrar = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO ,'<h4>'+listaAcciones.size() +' tareas seleccionadas. </h4>'+
                                                                                'Se mandará notificación sobre las tareas enviadas y en estado no finalizado a los gestores de las tareas en las que:<br/>'+
                                                                                ' - Seas el gestor de la reclamación de la tarea o letrado de las pretensiones de la reclamación.<br/>'));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No has seleccionado ninguna tarea sobre la que tengas permiso.'));
        }
    }

    /*****************************************************************
     * Proposito: Método para comprobar los permisos de quien puede usar el botón si
     * se ha pulsado desde related list de la reclamación. Debe tener permisos si es usuario de COPS o AJ,
     * si es el gestor de la reclamación o si es letrado de las pretensiones
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Carlos Solis   13/05/22     Creación
    *****************************************************************/
    public void comprobarPermisosEnReclamacion(Boolean checksSeleccionados) {
        //Comprobar si es de COPS o AJ
        Boolean tienePermiso = false;
        esCOPSOAJ = SAC_TareasOperativas_Controller.perteneceCOPSAJ(idUsuario);

        //Recuperar la reclamación y sus pretensiones
        List<Case> listaCasos = [SELECT Id, RecordTypeId, OwnerId FROM Case WHERE (RecordTypeId = :recTypeReclamacion OR RecordTypeId = :recTypePretension OR RecordTypeId = :recTypeReclamacionSPV OR RecordTypeId = :recTypePretensionSPV)
                                AND (Id = :currentRecord OR SAC_Reclamacion__c = :currentRecord)];


        //Si el owner es gestor o letrado de alguno de los casos de la familia, tiene permisos
        if (!listaCasos.isEmpty()) {
            for (Case caso : listaCasos) {
                if (idUsuario == caso.OwnerId) {
                    tienePermiso = true;
                }
            }
        }

        //Si es owner de alguno de los casos, o si es de COPS o AJ, se muestra el componente y su mensaje
        if (tienePermiso || esCOPSOAJ) {
            mostrar = true;
            esCOPSOAJ = true; //Pongo esta variable en true porque el funcionamiento es el mismo que si fuera cops o aj
            //El mensaje es distinto dependiendo de si ha seleccionado las tareas mediante checks o si ha dado al botón sin seleccionar nada (en ese caso va a todas)
            if (checksSeleccionados) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO ,listaAcciones.size() +' tareas seleccionadas. Se mandará notificación sobre las tareas enviadas y en estado no finalizado a los gestores de las tareas de la reclamación.'));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO ,'Se mandará notificación sobre las tareas enviadas y en estado no finalizado a los gestores de las tareas de la reclamación.'));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No tienes permisos para ejecutar esta acción'));
        }
    }
    
    /*****************************************************************
     * Proposito: Método que se llama desde el botón enviar en la visual force page.
     * Recoge el mensaje escrito en la visual force para mandarlo como notificación
     * a las tareas
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Carlos Solis   13/05/22     Creación
    *****************************************************************/
    public PageReference enviarNotificaciones() {
        //Recoger valor de la Visualforce
        String mensaje = apexpages.currentPage().getParameters().get('mensaje');

        //Recuperar las tareas seleccionadas dependiendo de si viene de la lista o de un record de reclamación
        if (!listaAcciones.isEmpty()) { //Aquí se ha llamado desde la listView (o desde la related list con los checkbox abiertos)
            listaTareas = [SELECT id, Name, OwnerId, SAC_EquipoResponsable__c, SAC_Estado__c, SAC_Reclamacion__r.SEG_Grupo__c, SAC_EquipoResponsable__r.SAC_Email__c,
                                SAC_Reclamacion__r.OwnerId, SAC_Reclamacion__r.SAC_PretensionPrincipal__r.OwnerId, RecordTypeId, SAC_EquipoResponsable__r.SAC_Email2__c, SAC_EquipoResponsable__r.SAC_Email3__c
                            FROM SAC_Accion__c
                            WHERE id = :listaAcciones];
        } else if (String.isNotBlank(currentRecord)) { //Aquí se ha llamado desde una reclamación (related list)
            listaTareasReclamacion = [SELECT id, Name, OwnerId, SAC_EquipoResponsable__c, SAC_Estado__c, SAC_Reclamacion__r.SEG_Grupo__c, SAC_EquipoResponsable__r.SAC_Email__c,
                                            SAC_Reclamacion__r.OwnerId, SAC_Reclamacion__r.SAC_PretensionPrincipal__r.OwnerId, RecordTypeId, SAC_EquipoResponsable__r.SAC_Email2__c, SAC_EquipoResponsable__r.SAC_Email3__c
                                        FROM SAC_Accion__c 
                                        WHERE SAC_Reclamacion__c = :currentRecord];
        }
        
        //Preparar envio notificaciones
        if (!listaAcciones.isEmpty() && String.isBlank(currentRecord)) { //Si se llama desde la listView
            prepararNotificaciones(listaTareas, mensaje);
            return new ApexPages.Action('{!List}').invoke(); //Volver a página listview
        } else if (listaAcciones.isempty() && String.isNotBlank(currentRecord)) { //Si se llama desde la related de la reclamación
            esCOPSOAJ = true; //Pongo esta variable en true porque en este caso, al ser llamado desde una reclamación, la funcionalidad es la misma que en la list view siendo de cops o aj
            prepararNotificaciones(listaTareasReclamacion, mensaje);
            PageReference pg = new PageReference('/'+currentRecord);
            pg.setRedirect(true);
            return pg; //Volver a el record en el que estaba
        } else if (!listaAcciones.isempty() && String.isNotBlank(currentRecord)) { //Si se llama desde la related de la reclamación seleccionando los checkbox
            prepararNotificaciones(listaTareas, mensaje);
            PageReference pg = new PageReference('/'+currentRecord);
            pg.setRedirect(true);
            return pg; //Volver a el record en el que estaba
        }

        return null;
    }

    /*****************************************************************
     * Proposito: Método que envia las notificaciones a las tareas.
     * Estas tareas pueden venir seleccionadas de una list view o automáticamente de
     * la related list de una reclamación. Si vienen de la related list de la reclamación,
     * envia notificación solo a las que esten enviadas y en estado no finalizado.
     * Si vienen de la list view de acciones y el usuario que lo ejecuta es de COPS o AJ,
     * envia notificación solo a las que esten enviadas y en estado no finalizado.
     * Si vienen de la list view de acciones y el usuario que lo ejecuta NO es de COPS o AJ pero es
     * admin de un grupo, las notificaciones se envian solo a las tareas que formen parte de una reclamación 
     * de su grupo (en el que es admin) y que esten enviadas y en estado no finalizado.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               Carlos Solis   13/05/22     Creación
    *****************************************************************/
    public void prepararNotificaciones(List<SAC_Accion__c> listaAcccionesNotificar, String mensaje) {
        Map<String, List<SAC_Accion__c>> mapaOwnerTarea = new Map<String, List<SAC_Accion__c>>();
        Map<String, List<SAC_Accion__c>> mapaGrupoTarea = new Map<String, List<SAC_Accion__c>>();
        Set<String> setIdsGrupos = new Set<String>();
        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
        Group colaSAC = new Group();
        Group colaSPV = new Group();

        for(Group cola : listaColas){
            if(cola.DeveloperName == 'SAC_PendienteAsignar'){
                colaSAC = cola;
            }else if(cola.DeveloperName == 'SPV_PendienteAsignar'){
                colaSPV = cola;
            }
        }

            for (SAC_Accion__c tarea : listaAcccionesNotificar) {
                if (esCOPSOAJ) { //Si es de AJ o COPS se notificarán a todas las tareas que esten enviadas y en estado no finalizado.
                    if (tarea.SAC_Estado__c == 'SAC_PendienteAsignar' || tarea.SAC_Estado__c == 'SAC_EnGestion' || tarea.SAC_Estado__c == 'SAC_StandBy') {
                        //Si el owner NO es la cola pendiente de asignar, se manda notificación a cada owner
                        if (String.isNotBlank(tarea.OwnerId) && (tarea.OwnerId != colaSAC.Id && tarea.OwnerId != colaSPV.Id)) {
                            if (mapaOwnerTarea.containsKey(tarea.OwnerId)) {
                                mapaOwnerTarea.get(tarea.OwnerId).add(tarea);
                            } else {
                                List<SAC_Accion__c> listaTarea = new List<SAC_Accion__c>();
                                listaTarea.add(tarea);
                                mapaOwnerTarea.put(tarea.OwnerId, listaTarea);
                            }
                        //Si el owner SI es la cola pendiente de asignar, se almacena en un mapa distinto para posteriormente buscar los administradores del grupo de la tarea
                        //y así notificarlos a ellos
                        } else if (String.isNotBlank(tarea.OwnerId) && (tarea.OwnerId == colaSAC.Id || tarea.OwnerId == colaSPV.Id)) {
                            setIdsGrupos.add(tarea.SAC_EquipoResponsable__c);
                            if (mapaGrupoTarea.containsKey(tarea.SAC_EquipoResponsable__c)) {
                                mapaGrupoTarea.get(tarea.SAC_EquipoResponsable__c).add(tarea);
                            } else {
                                List<SAC_Accion__c> listaTarea = new List<SAC_Accion__c>();
                                listaTarea.add(tarea);
                                mapaGrupoTarea.put(tarea.SAC_EquipoResponsable__c, listaTarea);
                            }
                        }
                    }
                } else if (esAdmin) { //Si el que ejecuta la acción es Admin de un grupo y no es de COPS o AJ, solo se notifica sobre las tareas que pertenecen a una reclamación de su grupo y que esten enviadas y en estado no finalizado
                                    //o las tareas en las que el sea gestor o letrado se su reclamación
                    if ((mapaGrupos.containsKey(tarea.SAC_Reclamacion__r.SEG_Grupo__c) || tarea.SAC_Reclamacion__r.OwnerId == idUsuario || tarea.SAC_Reclamacion__r.SAC_PretensionPrincipal__r.OwnerId == idUsuario)
                         && (tarea.SAC_Estado__c == 'SAC_PendienteAsignar' || tarea.SAC_Estado__c == 'SAC_EnGestion' || tarea.SAC_Estado__c == 'SAC_StandBy')) {
                        //Si el owner NO es la cola pendiente de asignar, se manda notificación a cada owner
                        if (String.isNotBlank(tarea.OwnerId) && (tarea.OwnerId != colaSAC.Id && tarea.OwnerId != colaSPV.Id)) {
                            if (mapaOwnerTarea.containsKey(tarea.OwnerId)) {
                                mapaOwnerTarea.get(tarea.OwnerId).add(tarea);
                            } else {
                                List<SAC_Accion__c> listaTarea = new List<SAC_Accion__c>();
                                listaTarea.add(tarea);
                                mapaOwnerTarea.put(tarea.OwnerId, listaTarea);
                            }
                        //Si el owner SI es la cola pendiente de asignar, se almacena en un mapa distinto para posteriormente buscar los administradores del grupo de la tarea
                        //y así notificarlos a ellos
                        } else if (String.isNotBlank(tarea.OwnerId) && (tarea.OwnerId == colaSAC.Id || tarea.OwnerId == colaSPV.Id)) {
                            setIdsGrupos.add(tarea.SAC_EquipoResponsable__c);
                            if (mapaGrupoTarea.containsKey(tarea.SAC_EquipoResponsable__c)) {
                                mapaGrupoTarea.get(tarea.SAC_EquipoResponsable__c).add(tarea);
                            } else {
                                List<SAC_Accion__c> listaTarea = new List<SAC_Accion__c>();
                                listaTarea.add(tarea);
                                mapaGrupoTarea.put(tarea.SAC_EquipoResponsable__c, listaTarea);
                            }
                        }
                    }
                } else if (ownerRecPret) { //Si es owner de reclamacion o pretension, notificar solo sobre las tareas que pertenecen a su reclamacion o reclamacion de su pretension
                    if ((tarea.SAC_Reclamacion__r.OwnerId == idUsuario || tarea.SAC_Reclamacion__r.SAC_PretensionPrincipal__r.OwnerId == idUsuario) && (tarea.SAC_Estado__c == 'SAC_PendienteAsignar' || tarea.SAC_Estado__c == 'SAC_EnGestion' || tarea.SAC_Estado__c == 'SAC_StandBy')) {
                        //Si el owner NO es la cola pendiente de asignar, se manda notificación a cada owner
                        if (String.isNotBlank(tarea.OwnerId) && (tarea.OwnerId != colaSAC.Id && tarea.OwnerId != colaSPV.Id)) {
                            if (mapaOwnerTarea.containsKey(tarea.OwnerId)) {
                                mapaOwnerTarea.get(tarea.OwnerId).add(tarea);
                            } else {
                                List<SAC_Accion__c> listaTarea = new List<SAC_Accion__c>();
                                listaTarea.add(tarea);
                                mapaOwnerTarea.put(tarea.OwnerId, listaTarea);
                            }
                        //Si el owner SI es la cola pendiente de asignar, se almacena en un mapa distinto para posteriormente buscar los administradores del grupo de la tarea
                        //y así notificarlos a ellos
                        } else if (String.isNotBlank(tarea.OwnerId) && (tarea.OwnerId == colaSAC.Id || tarea.OwnerId == colaSPV.Id)) {
                            setIdsGrupos.add(tarea.SAC_EquipoResponsable__c);
                            if (mapaGrupoTarea.containsKey(tarea.SAC_EquipoResponsable__c)) {
                                mapaGrupoTarea.get(tarea.SAC_EquipoResponsable__c).add(tarea);
                            } else {
                                List<SAC_Accion__c> listaTarea = new List<SAC_Accion__c>();
                                listaTarea.add(tarea);
                                mapaGrupoTarea.put(tarea.SAC_EquipoResponsable__c, listaTarea);
                            }
                        }
                    }
                }
            }

            //Con el mapa de tareas sin owner o en cola, compruebo si hay alguna asi y le busco los owners de cada grupo
            Map<String, List<SAC_Accion__c>> mapaAdminTarea = new Map<String, List<SAC_Accion__c>> ();
            if (!setIdsGrupos.isEmpty()) {
                List<CC_Grupo_Colaborador_Contact__c> listaColabContacts = [SELECT Id, CC_Usuario__c, CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c 
                                                                            WHERE (CC_Grupo_Colaborador__r.RecordType.DeveloperName = 'SAC_GrupoResponsableAccion' OR CC_Grupo_Colaborador__r.RecordTypeId = :recTypeGrupoTareas)
                                                                            AND CC_Grupo_Colaborador__c IN :setIdsGrupos
                                                                            AND SAC_Administrador__c = true];

                if (!listaColabContacts.isEmpty()) {
                    for (CC_Grupo_Colaborador_Contact__c colabContact : listaColabContacts) {
                        if (mapaGrupoTarea.containsKey(colabContact.CC_Grupo_Colaborador__c)) {
                            if (mapaAdminTarea.containsKey(colabContact.CC_Usuario__c)) {
                                mapaAdminTarea.get(colabContact.CC_Usuario__c).addAll(mapaGrupoTarea.get(colabContact.CC_Grupo_Colaborador__c));
                            } else {
                                mapaAdminTarea.put(colabContact.CC_Usuario__c, mapaGrupoTarea.get(colabContact.CC_Grupo_Colaborador__c));
                            }
                        }
                    }
                }
            }

            //Mapa para insertar la cada notificacion en el chatter de dicha tarea
            Map<Id, String> mapaTareaMensaje =  new Map<Id, String>();

            //System.debug('voy a mirar el mapaOwnerTarea --> '+mapaOwnerTarea);
            if (!mapaOwnerTarea.isEmpty()) {
                for (String ownerId : mapaOwnerTarea.keySet()) {
                    for (SAC_Accion__c tarea : mapaOwnerTarea.get(ownerId)) {
                        if(tarea.RecordTypeId == recTypeTareasSPV || tarea.RecordTypeId == recTypeTareasMaestroSPV){

                            List<String> listaEmails = new List<String>();

                            if(tarea.SAC_EquipoResponsable__c != null && String.isNotBlank(tarea.SAC_EquipoResponsable__r.SAC_Email__c)){
                                listaEmails.add(tarea.SAC_EquipoResponsable__r.SAC_Email__c);
                            }
                            if(tarea.SAC_EquipoResponsable__c != null && String.isNotBlank(tarea.SAC_EquipoResponsable__r.SAC_Email2__c)){
                                listaEmails.add(tarea.SAC_EquipoResponsable__r.SAC_Email2__c);
                            }
                            if(tarea.SAC_EquipoResponsable__c != null && String.isNotBlank(tarea.SAC_EquipoResponsable__r.SAC_Email3__c)){
                                listaEmails.add(tarea.SAC_EquipoResponsable__r.SAC_Email3__c);
                            }


                            //Preparar una alerta
                            SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(tarea.SAC_Reclamacion__c,
                                                                                'SPV_016',
                                                                                'Notificación de la Acción ' + tarea.Name + '. ' + mensaje,
                                                                                ownerId,
                                                                                '',
                                                                                tarea.Id,
                                                                                '');
                                                                                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + tarea.Id;
                                                                                wrapAlerta.listaEmailsGrupo = listaEmails;
                                                                                wrapAlerta.idGrupoColaborador = tarea.SAC_EquipoResponsable__c;
                                                                                wrapAlerta.proyecto = 'SPV';
                            //Añadirla a la lista para posteriormente llamar al método
                            listaWrapperAlerta.add(wrapAlerta);
                        }else{
                            SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(tarea.SAC_Reclamacion__c,
                                                                            'SAC_016',
                                                                            'Notificación tarea: '+tarea.Name + '. ' + mensaje,
                                                                            ownerId,
                                                                            '',
                                                                            tarea.Id,
                                                                            '');
                                                                            wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + tarea.Id;
                            //Añadirla a la lista para posteriormente llamar al método
                            listaWrapperAlerta.add(wrapAlerta);

                            /* Deprecated, se ha cambiado por el nuevo sistema de alertas con el objeto SAC_Alerta
                            //System.debug('notifico la tarea : '+tarea.Name);
                            SAC_Notificacion.enviarNotificacion(ownerId, tarea.Id, 'Notificación tarea: '+tarea.Name, mensaje);*/
                            mapaTareaMensaje.put(tarea.Id, 'Notificación tarea '+tarea.Name+' : '+mensaje);
                        }
                    }
                }
            }
            
            //System.debug('voy a mirar el mapaAdminTarea --> '+mapaAdminTarea);
            if (!mapaAdminTarea.isEmpty()) {
                for (String ownerId : mapaAdminTarea.keySet()) {
                    for (SAC_Accion__c tarea : mapaAdminTarea.get(ownerId)) {
                        if(tarea.RecordTypeId == recTypeTareasSPV || tarea.RecordTypeId == recTypeTareasMaestroSPV){

                            List<String> listaEmails = new List<String>();

                            if(tarea.SAC_EquipoResponsable__c != null && String.isNotBlank(tarea.SAC_EquipoResponsable__r.SAC_Email__c)){
                                listaEmails.add(tarea.SAC_EquipoResponsable__r.SAC_Email__c);
                            }
                            if(tarea.SAC_EquipoResponsable__c != null && String.isNotBlank(tarea.SAC_EquipoResponsable__r.SAC_Email2__c)){
                                listaEmails.add(tarea.SAC_EquipoResponsable__r.SAC_Email2__c);
                            }
                            if(tarea.SAC_EquipoResponsable__c != null && String.isNotBlank(tarea.SAC_EquipoResponsable__r.SAC_Email3__c)){
                                listaEmails.add(tarea.SAC_EquipoResponsable__r.SAC_Email3__c);
                            }


                            //Preparar una alerta
                            SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(tarea.SAC_Reclamacion__c,
                                                                                'SPV_016',
                                                                                'Notificación de la Acción ' + tarea.Name + '. ' + mensaje,
                                                                                ownerId,
                                                                                '',
                                                                                tarea.Id,
                                                                                '');
                                                                                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + tarea.Id;
                                                                                wrapAlerta.listaEmailsGrupo = listaEmails;
                                                                                wrapAlerta.idGrupoColaborador = tarea.SAC_EquipoResponsable__c;
                                                                                wrapAlerta.proyecto = 'SPV';
                            //Añadirla a la lista para posteriormente llamar al método
                            listaWrapperAlerta.add(wrapAlerta);
                        }else{
                            SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(tarea.SAC_Reclamacion__c,
                                                                            'SAC_016',
                                                                            'Notificación tarea: '+tarea.Name + '. ' + mensaje,
                                                                            ownerId,
                                                                            '',
                                                                            tarea.Id,
                                                                            '');
                                                                            wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + tarea.Id;
                            //Añadirla a la lista para posteriormente llamar al método
                            listaWrapperAlerta.add(wrapAlerta);

                            /* Deprecated, se ha cambiado por el nuevo sistema de alertas con el objeto SAC_Alerta
                            //System.debug('notifico la tarea : '+tarea.Name);
                            SAC_Notificacion.enviarNotificacion(ownerId, tarea.Id, 'Notificación tarea: '+tarea.Name, mensaje);*/
                            mapaTareaMensaje.put(tarea.Id, 'Notificación tarea '+tarea.Name+' : '+mensaje);
                        }
                    }
                }
            }

            if (!mapaTareaMensaje.isEmpty()) {
                List<FeedItem> listaFeedInsertar = new List<FeedItem>();
                for (Id idTarea : mapaTareaMensaje.keySet()) {
                    FeedItem feedTarea = new FeedItem();
                    feedTarea.ParentId = idTarea;
                    feedtarea.Body = mapaTareaMensaje.get(idTarea);
                    listaFeedInsertar.add(feedTarea);
                }
                insert listaFeedInsertar;
            }

            //Si tenemos alertas que enviar, se llama al método que las envía
            if (!listaWrapperAlerta.isEmpty()) {
                SAC_Alertas.generarAlertas(listaWrapperAlerta);
            }
    }

}