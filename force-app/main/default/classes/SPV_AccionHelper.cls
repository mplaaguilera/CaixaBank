public with sharing class SPV_AccionHelper {

    public class SPVException extends Exception {}

    private static Set<String> objetos = new Set<String>{'SAC_Accion__c', 'Case', 'CC_Grupo_Colaborador__c', 'SAC_TMECaso__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEACCION = mapRTsObjects.get('SAC_Accion__c').get('SPV_Acciones').getRecordTypeId();
    private static final Id RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SPV_MaestroDeTareas').getRecordTypeId();
    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    private static final Id RECTYPEGRUPOTAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();
    private static final Id RECTYPETMETAREAS = mapRTsObjects.get('SAC_TMECaso__c').get('SPV_Tarea').getRecordTypeId();



    /*****************************************************************
     * Proposito: Filtrar las acciones entrantes para quedarnos únicamente con los de SPV
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0               ---         Raúl Santos   21/05/2024        Creación
     *****************************************************************/
    public static List<SAC_Accion__c> filtrarAccionesSPV(List<SAC_Accion__c> lstAcciones) {

        List<SAC_Accion__c> accionesSPV = new List<SAC_Accion__c>();

        for (SAC_Accion__c accion : lstAcciones) {
            if (accion.RecordTypeId == RECTYPEACCION || accion.RecordTypeId == RECTYPEMAESTROTAREAS) {
                accionesSPV.add(accion);
            }
        }
        
        return accionesSPV;
    }

    /*****************************************************************
     * Proposito: Cuando insertamos una acción, le damos permisos para modificarla al propietario actual de la reclamación/pretensión
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US912970      Raúl Santos   21/05/2024        Creación
     *****************************************************************/
    public static void insertarPermisosAccion(List<SAC_Accion__c> listNewAcciones) {

        Set<Id> idsCaso = new Set<Id>();

        for (SAC_Accion__c accion : listNewAcciones) {
            idsCaso.add(accion.SAC_Reclamacion__c);
        }

        if(!idsCaso.isEmpty() && Schema.sObjectType.Case.isAccessible()){
            List<Case> listCasos = [SELECT id, OwnerId FROM Case WHERE (RecordTypeId =: RECTYPERECLAMACION OR RecordTypeId =: RECTYPEPRETENSION) AND (id IN :idsCaso OR SAC_Reclamacion__c IN :idsCaso)];

            if(!listCasos.isEmpty()){

                List<SAC_Accion__Share> listaAccionShareNuevos = new List<SAC_Accion__Share>();

                for(SAC_Accion__c accion : listNewAcciones){
                    for(Case caso : listCasos){
                        if(caso.Id == accion.SAC_Reclamacion__c || caso.Id == accion.SAC_Pretension__c){
                            SAC_Accion__Share accionShare = new SAC_Accion__Share();
                            accionShare.ParentId = accion.Id;
                            accionShare.AccessLevel = 'Edit';
                            accionShare.UserOrGroupId = caso.OwnerId;
                            
                            listaAccionShareNuevos.add(accionShare); 
                        }
                    }
                }

                SPV_DatabaseDML.insertListDML(listaAccionShareNuevos, false);
            }
        }
    }

    /**************************************************************************
     * Proposito: Comprueba si ha habido un cambio de owner en la accion. De ser asi, busca los casos relacionados y
     * llama a los metodos necesarios cuando ha habido un cambio de owner.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             17/07/24     Creación
    *****************************************************************************/
    public static void cambioDeOwner(List<SAC_Accion__c> listaNewAcciones, Map<Id, SAC_Accion__c> mapOldObj, Group cola) {
        List<SAC_Accion__c> listaCambioOwner = new List<SAC_Accion__c>();
        Map<Id, Case> mapCasosRelated = new Map<Id, Case>();
        Set<Id> setIdsCasosGlobal = new Set<Id>();

        //Filtrar acciones del trigger a las que les haya cambiado el owner
        for (SAC_Accion__c accion : listaNewAcciones) {
            //Si es un cambio de propietario 
            if (accion.OwnerId != mapOldObj.get(accion.Id).OwnerId) {
                listaCambioOwner.add(accion);
                setIdsCasosGlobal.add(accion.SAC_Reclamacion__c);
                if (String.isNotBlank(accion.SAC_Pretension__c)) {
                    setIdsCasosGlobal.add(accion.SAC_Pretension__c);
                }
            }
        }

        //Si ha habido un cambio de owner, se buscan los casos relacionados a las acciones y se llaman a los metodos necesarios
        if (!listaCambioOwner.isEmpty()) {
            //Rellenar mapa case related
            List<Case> casosRelated = [SELECT Id, OwnerId FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACION OR RecordTypeId = :RECTYPEACCION) AND Id IN :setIdsCasosGlobal];
            for (Case caso : casosRelated) {
                mapCasosRelated.put(caso.Id, caso);
            }

            //Comprueba si el owner introducido es correcto. De no serlo, muestra un error.
            comprobarNuevoOwner(listaCambioOwner, mapCasosRelated, cola, mapOldObj);
        }
    }

    /**************************************************************************
     * Proposito: Comprueba si el usuario que se esta insertando en la acción tiene permisos para serlo.
     * Lanza un error de que no se puede poner el nuevo owner si se cumplen las siguientes condiciones:
     * El owner que se está poniendo NO es la cola &&
     * El usuario NO pertenece ni a COPS ni a AJ &&
     * El usuario que se esta poniendo NO pertenece al grupo responsable de la tarea &&
     * ( No es empleado de ninguna oficina O la oficina no es la suya ) &&
     * El owner que se está poniendo es diferente al creador de la tarea &&
     * El owner que se está poniendo NO es ni el owner de la pretension ni de la reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             17/07/24     Creación
    *****************************************************************************/
    public static void comprobarNuevoOwner(List<SAC_Accion__c> listaCambioOwner, Map<Id, Case> mapCasosRelated, Group cola, Map<Id, SAC_Accion__c> mapOldObj) {
        Boolean esCola = false;
        Boolean puedeSerPropietario= false;
        Boolean noPasaValidacionPropiedad = false;
        Map<Id, Id> mapaUsuarioColaboradorCOPSAJ = new Map<Id, Id>();
        Map<String, String> mapaGrupoUsuarios = new Map<String, String>();
        Map<Id,Boolean> mapaUsuarioEsDeRecOPret = new Map<Id,Boolean>();
        Set<Id> setUsuariosAccion = new Set<Id>();
        Set<Id> setGruposAccion = new Set<Id>();
        List<Contact> empleadoOficina = new List<Contact>();
        
        for (SAC_Accion__c accion : listaCambioOwner) {
            //Guardar owners para posteriormente comprobar si pertenecen a COPS o AJ
            setUsuariosAccion.add(accion.OwnerId);
            //Guardar equipos responsables para posteriormente comprobar si los usuarios pertenecen a dicho grupo
            setGruposAccion.add(accion.SAC_EquipoResponsable__c);
        }

        //Recuperar grupos
        mapaGrupoUsuarios = comprobarUsuariosGrupoAccion(setUsuariosAccion, setGruposAccion);

        //Comprobar si los owners pertenecen a COPS o AJ
        mapaUsuarioColaboradorCOPSAJ = comprobarUsuariosCOPSAJ(setUsuariosAccion);

        //Comprobar si el owner que ejecuta es empleado de oficinas
        empleadoOficina = [SELECT AccountId FROM contact WHERE AV_UsuarioAsociado__c =: UserInfo.getUserId()];

        mapaUsuarioEsDeRecOPret = SAC_AccionMetodos.esPropietarioRecOPret(listaCambioOwner);

        //Recorrer acciones a las que les ha cambiado el owner para comprobar si el nuevo owner tiene permiso
        for (SAC_Accion__c accion : listaCambioOwner) {
            //Comprobar si el owner es la cola
            esCola = usuarioEsCola(accion.OwnerId, cola); //Cuando se hace un "Devolver a la cola"

            if(mapCasosRelated.get(accion.SAC_Reclamacion__c) != null){
                noPasaValidacionPropiedad = accion.CreatedById == mapCasosRelated.get(accion.SAC_Reclamacion__c).OwnerId ? true : false;
            }else if(mapCasosRelated.get(accion.SAC_Pretension__c) != null){
                noPasaValidacionPropiedad = accion.CreatedById == mapCasosRelated.get(accion.SAC_Pretension__c).OwnerId ? true : false;
            }
            if(!noPasaValidacionPropiedad){
                if(!SAC_AccionMetodos.laTareaEstaViva(mapOldObj.get(accion.Id))){
                    accion.addError('Tarea finalizada o finalizada incompleta');
                }
                if(!esCola && !mapaUsuarioColaboradorCOPSAJ.containsKey(accion.ownerId) && !mapaGrupoUsuarios.containsKey(String.valueOf(accion.SAC_EquipoResponsable__c)+String.valueOf(accion.ownerId)) &&
                (empleadoOficina.isEmpty() || accion.SAC_Oficina__c != empleadoOficina?.get(0)?.AccountId) && (accion.OwnerId != accion.CreatedById) && 
                mapaUsuarioEsDeRecOPret.containsKey(accion.ownerId) && !mapaUsuarioEsDeRecOPret.get(accion.ownerId)){
                    accion.addError('No tiene privilegios para ser el propietario de esta tarea');
                }
            }
        }
    }

    /**************************************************************************
     * Proposito: Comprueba los usuarios introducidos pertenecen a los grupos
     * de acciones introducidos y lo devuelve en forma de mapa juntando como key la id
     * del usuario y del grupo en caso de que pertenezca
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             17/07/24     Creación
    *****************************************************************************/
    public static Map<String, String> comprobarUsuariosGrupoAccion(Set<Id> setUsuarios, Set<Id> setGrupos) {

        List<CC_Grupo_Colaborador_Contact__c> listaColabContact= new List<CC_Grupo_Colaborador_Contact__c>();
        Map<String, String> mapaGrupoUsers = new Map<String, String>();
        //Buscar si los usuario pertenecen a los grupos de las acciones
        listaColabContact = [SELECT id,CC_Grupo_Colaborador__c,CC_Usuario__c
                        FROM CC_Grupo_Colaborador_Contact__c
                        WHERE CC_Grupo_Colaborador__r.RecordTypeId = :RECTYPEGRUPOTAREAS
                        AND CC_Grupo_Colaborador__c IN :setGrupos
                        AND CC_Usuario__c = :setUsuarios];
        //Pasar lista a mapa
        if (!listaColabContact.isEmpty()) {
            for (CC_Grupo_Colaborador_Contact__c colaborador : listaColabContact) {
                String grupoMasUser = String.valueOf(colaborador.CC_Grupo_Colaborador__c) + String.valueOf(colaborador.CC_Usuario__c);
                mapaGrupoUsers.put(grupoMasUser, grupoMasUser);
            }
        }

        return mapaGrupoUsers;
    }

    /**************************************************************************
     * Proposito: Comprueba si los usuarios introducidos pertenecen a COPS o AJ
     * y lo devuelve en forma de mapa
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             17/07/24     Creación
    *****************************************************************************/
    public static Map<Id, Id> comprobarUsuariosCOPSAJ(Set<Id> setUsuarios) {

        List<CC_Grupo_Colaborador_Contact__c> listaColabContact= new List<CC_Grupo_Colaborador_Contact__c>();
        Map<Id, Id> mapaUserColaborador = new Map<Id, Id>();
        //Buscar si los usuario pertenecen a COPS o a AJ
        listaColabContact = [SELECT id, CC_Usuario__c
                            FROM CC_Grupo_Colaborador_Contact__c
                            WHERE CC_Usuario__c = :setUsuarios
                            AND CC_Grupo_Colaborador__r.RecordTypeId = :RECTYPEGRUPOTAREAS
                            AND (CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'SPV_COPS' OR CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'SPV_AJ')];
        //Pasar lista a mapa
        if (!listaColabContact.isEmpty()) {
            for (CC_Grupo_Colaborador_Contact__c colaborador : listaColabContact) {
                mapaUserColaborador.put(colaborador.CC_Usuario__c, colaborador.CC_Usuario__c);
            }
        }

        return mapaUserColaborador;
    }

    /**************************************************************************
     * Proposito: Comprueba si el que está modificando la tarea es propietario de
     * la reclamación o la pretensión padre. En caso de serlo, devuelve true
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             17/07/24     Creación
    *****************************************************************************/
    public static Map<Id,Boolean> esPropietarioRecOPret(List<SAC_Accion__c> listNewObj){

        List<Case> listaReclamacionesPadre = new List<Case>();
        Map<Id, Case> mapaReclamacionesPadre = new Map<Id, Case>();
        Set<Id> setIdsRec = new Set<Id>();
        Map<Id,Boolean> mapaUserTienePermiso = new Map<Id,Boolean>();
        //Recoger ids de las reclamaciones padre de las acciones
        
        for (SAC_Accion__c accion : listNewObj) {
            setIdsRec.add(accion.SAC_Reclamacion__c);
        }

        //Recuperar las reclamaciones con sus pretensiones principales y los owners de ambas
        if (!setIdsRec.isEmpty()) {
            listaReclamacionesPadre = [SELECT Id, OwnerId, SAC_PretensionPrincipal__c, SAC_PretensionPrincipal__r.OwnerId 
                                        FROM Case 
                                        WHERE RecordTypeId = :RECTYPERECLAMACION
                                        AND Id IN :setIdsRec];
            for (Case reclamacion : listaReclamacionesPadre) {
                mapaReclamacionesPadre.put(reclamacion.Id, reclamacion);
            }
        }

        //Comprobar si el usuario de la accion es usuario de la reclamación o la pretensión para devolverlo en un mapa de booleans
        for (SAC_Accion__c accion : listNewObj) {
            if (mapaReclamacionesPadre.containsKey(accion.SAC_Reclamacion__c) && String.isNotBlank(mapaReclamacionesPadre.get(accion.SAC_Reclamacion__c).SAC_PretensionPrincipal__r.OwnerId)) {
                if (mapaReclamacionesPadre.get(accion.SAC_Reclamacion__c).SAC_PretensionPrincipal__r.OwnerId == accion.OwnerId || mapaReclamacionesPadre.get(accion.SAC_Reclamacion__c).OwnerId == accion.OwnerId) {
                    mapaUserTienePermiso.put(accion.OwnerId, true);
                }
            } else if (mapaReclamacionesPadre.containsKey(accion.SAC_Reclamacion__c) && String.isNotBlank(mapaReclamacionesPadre.get(accion.SAC_Reclamacion__c).OwnerId)) {
                if (mapaReclamacionesPadre.get(accion.SAC_Reclamacion__c).OwnerId == accion.OwnerId) {
                    mapaUserTienePermiso.put(accion.OwnerId, true);
                }
            }
        }

        return mapaUserTienePermiso;
    }

    /**************************************************************************
     * Proposito: Comprueba si el usuario es igual a la cola
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             17/07/24     Creación
    *****************************************************************************/
    public static Boolean usuarioEsCola(Id idUsuario, Group cola) {
        Boolean esCola = false;
        if (idUsuario == cola.Id) {
            esCola = true;
        }

        return esCola;
    }

    /*****************************************************************
     * Proposito: Comprobar si la tarea está viva
     * **************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             17/07/24     Creación
    *****************************************************************/
    public static Boolean laTareaEstaViva(SAC_Accion__c tarea){
        Boolean respuesta = true;

        if(tarea.SAC_Estado__c == 'SAC_Finalizada' || tarea.SAC_Estado__c == 'SAC_FinalizadaIncompleta'){
            respuesta = false;             
        }
        return respuesta;
    }

    /*****************************************************************
     * Proposito: Comprueba si ha habido un cambio de estado en la accion. Lanza los métodos necesarios para cada cambio de estado.
     * Se llama en el SPV_AccionBUTRHan
     * **************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             18/07/24     Creación
    *****************************************************************/
    public static void cambioDeEstadosBU(List<SAC_Accion__c> listaNewAcciones, Map<Id, SAC_Accion__c> mapOldObj) {
        List<SAC_Accion__c> tareasFinalizadas = new list<SAC_Accion__c>();

        for (SAC_Accion__c accion : listaNewAcciones) {
            //Si el estado ha cambiado
            if (mapOldObj.get(accion.Id).SAC_Estado__c != accion.SAC_Estado__c) {
                //Si ha cambiado a finalizada, finalizada incompleta o descartada
                if (accion.SAC_Estado__c == 'SAC_Finalizada' || accion.SAC_Estado__c == 'SAC_FinalizadaIncompleta' || accion.SAC_Estado__c == 'SAC_Descartada') {
                    tareasFinalizadas.add(accion);
                }
            }
        }

        if (!tareasFinalizadas.isEmpty()) {
            rellenarFechaEjecucion(tareasFinalizadas);
        }
    }

    /*****************************************************************
     * Proposito: Comprueba si ha habido un cambio de estado en la accion. Lanza los métodos necesarios para cada cambio de estado.
     * Se llama en el SPV_AccionAUTRHan
     * **************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             18/07/24     Creación
    *****************************************************************/
    public static void cambioDeEstadosAU(List<SAC_Accion__c> listaNewAcciones, Map<Id, SAC_Accion__c> mapOldObj) {
        List<SAC_Accion__c> tareasFinalizarTMEs = new list<SAC_Accion__c>();
        List<SAC_Accion__c> listaRecalculoImportes = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaEnvioGGH = new List<SAC_Accion__c>();
        Set<Id> idsTareaFinalizada = new Set<Id>();
        Set<String> listaEnvioGGHIds = new Set<String>();

        for (SAC_Accion__c accion : listaNewAcciones) {
            //Si el estado ha cambiado
            if (mapOldObj.get(accion.Id).SAC_Estado__c != accion.SAC_Estado__c) {
                //Si ha cambiado a finalizada, finalizada incompleta o descartada
                if (accion.SAC_Estado__c == 'SAC_Finalizada' || accion.SAC_Estado__c == 'SAC_FinalizadaIncompleta' || accion.SAC_Estado__c == 'SAC_Descartada') {
                    tareasFinalizarTMEs.add(accion);

                    if(accion.SAC_Estado__c == 'SAC_Finalizada' || accion.SAC_Estado__c == 'SAC_FinalizadaIncompleta'){
                        idsTareaFinalizada.add(accion.Id);
                    }
                }
                //Si pasa a estar descartada, o sale de descartada
                if (accion.SAC_Estado__c == 'SAC_Descartada' || mapOldObj.get(accion.Id).SAC_Estado__c == 'SAC_Descartada') {
                    listaRecalculoImportes.add(accion);
                }
                //Si pasa a estar pendiente de asignar
                if (accion.SAC_Estado__c == 'SAC_PendienteAsignar' && !listaEnvioGGHIds.contains(accion.Id)) {
                    listaEnvioGGHIds.add(accion.Id);
                    listaEnvioGGH.add(accion);
                }
            }
        }

        if (!tareasFinalizarTMEs.isEmpty()) {
            finalizarTMEs(tareasFinalizarTMEs);
        }
        if (!idsTareaFinalizada.isEmpty()) {
            comprobarTareaFinalizada(idsTareaFinalizada);
        }
        if (!listaRecalculoImportes.isEmpty()) {
            recalculoImportes(listaRecalculoImportes, mapOldObj);
        }
        if (!listaEnvioGGH.isEmpty()) {
            try {
                AsyncOptions options = new AsyncOptions();
                options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                .addId(UserInfo.getUserId())
                .addString(String.valueOf(listaEnvioGGHIds))
                .build();
                System.enqueueJob(new SPV_QueueableEnvioGGH(listaEnvioGGH), options);
            } catch (DuplicateMessageException ex) {
                CBK_Log.error(ex);
            }
            
        }
    }

    /*****************************************************************
     * Proposito: rellenar el campo de Fecha de ejecución cuando se finaliza la tarea
     **************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             18/07/24     Creación
    *****************************************************************/
    public static void rellenarFechaEjecucion(List<SAC_Accion__c> tareasFinalizadas){
        for(SAC_Accion__c accion : tareasFinalizadas){
            if(accion.SAC_FechaDeEjecucion__c == null){
                accion.SAC_FechaDeEjecucion__c = DateTime.now();
            }
        }
    }

    /**************************************************************************
     * Proposito: Cuando se finalizan las tareas se deben finalizar los TMEs
     ***************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             18/07/24     Creación
    *****************************************************************************/
    public static void finalizarTMEs(List<SAC_Accion__c> tareasFinalizadas){

        List<SAC_TMECaso__c> tmesTarea = [SELECT ID, SAC_Accion__c FROM SAC_TMECaso__c WHERE SAC_Accion__c =: tareasFinalizadas];

        if (!tmesTarea.isEmpty()) {
            for(SAC_TMECaso__c tme : tmesTarea){
                tme.SAC_FechaFin__c = Datetime.Now();
            }
            
            Database.update(tmesTarea);
        }
    }

    /**************************************************************************
     * Proposito: Cerrar las reclamaciones
     **************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             18/07/24     Creación
    *****************************************************************************/
    public static void cerrarReclamaciones(List<Id> reclamacionesParaCerrar){
        List<Case> listaReclamaciones = [SELECT id, status, SEG_Subestado__c, SPV_Organismo__c, RecordTypeId FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACION AND Id IN: reclamacionesParaCerrar) OR (RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c IN: reclamacionesParaCerrar)];
        List<Case> casosUpdate = new List<Case>();

        for(Case reclamacion: listaReclamaciones){
            // Una vez que las tareas se finalicen, el subestado pasaría automáticamente a ser el mismo que el estado “Pendiente respuesta Organismo” excepto en el caso de Consumo Autonómico en el que el estado pasaría directamente a “Cerrado”
            if(reclamacion.RecordTypeId == RECTYPERECLAMACION && reclamacion.Status == 'SPV_PendienteRespuestaOrganismos' && reclamacion.SEG_Subestado__c == 'Ejecucion y Pendiente Respuesta Organismo') {
                if(reclamacion.SPV_Organismo__c == 'SPV_Consumo') {
                    reclamacion = SPV_CaseHelper.cerrarReclamacion(reclamacion);
                } else {
                    reclamacion.SEG_Subestado__c='Pendiente respuesta Organismos';
                }
                casosUpdate.add(reclamacion);
            } else if(reclamacion.RecordTypeId == RECTYPEPRETENSION && reclamacion.Status != 'Descartado') {
                reclamacion.Status = 'Cerrado';
                casosUpdate.add(reclamacion);
            }
        }

        if(!casosUpdate.isEmpty()){            
            Database.update(casosUpdate);
        }
    }

    /*****************************************************************
     * Proposito: Comprueba si ha habido un cambio del maestro de acciones en la accion y lanza su correspondiente funcionalidad
     * **************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             18/07/24     Creación
    *****************************************************************/
    public static void cambioMaestroDeAcciones(List<SAC_Accion__c> listaNewAcciones, Map<Id, SAC_Accion__c> mapOldObj) {
        List<SAC_Accion__c> listaCambioMaestroAcciones = new List<SAC_Accion__c>();

        for (SAC_Accion__c accion : listaNewAcciones) {
            if (accion.SAC_MaestroAccionesReclamacion__c != mapOldObj.get(accion.Id).SAC_MaestroAccionesReclamacion__c) {
                listaCambioMaestroAcciones.add(accion);
            }
        }

        if (!listaCambioMaestroAcciones.isEmpty()) {
            cargarDatosMaestroAcciones(listaCambioMaestroAcciones);
        }
    }

    /*****************************************************************
     * Proposito: Carga los datos del maestro de acciones reclamación a la tarea.
     * **************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             18/07/24     Creación
    *****************************************************************/
    public static void cargarDatosMaestroAcciones(List<SAC_Accion__c> listNew) {
        Set<Id> setIdMaestroAcciones = new Set<Id>();
    
        for(SAC_Accion__c tareas: listNew){
            if(tareas.RecordTypeId == RECTYPEMAESTROTAREAS && tareas.SAC_MaestroAccionesReclamacion__c != null){
                setIdMaestroAcciones.add(tareas.SAC_MaestroAccionesReclamacion__c);
            }
        }
        
        if(!setIdMaestroAcciones.isEmpty() && Schema.SObjectType.SAC_MaestroAccionesReclamacion__c.isAccessible()){
            Map<Id,SAC_MaestroAccionesReclamacion__c> mapaMaestroAcciones = new Map<Id,SAC_MaestroAccionesReclamacion__c>
                                                                            ([SELECT id, SAC_Descripcion__c, SAC_EquipoResponsable__c,SAC_PlazoMaximo__c, SAC_Prorroga__c
                                                                            FROM SAC_MaestroAccionesReclamacion__c
                                                                            WHERE id IN:setIdMaestroAcciones]);
        
            if(!mapaMaestroAcciones.isEmpty()){
                for(SAC_Accion__c tareas: listNew){
                    if(tareas.SAC_MaestroAccionesReclamacion__c != null){
                        SAC_MaestroAccionesReclamacion__c datosMaestroAux = mapaMaestroAcciones.get(tareas.SAC_MaestroAccionesReclamacion__c);
                        tareas.SAC_Descripcion__c= datosMaestroAux.SAC_Descripcion__c;
                        tareas.SAC_EquipoResponsable__c =  datosMaestroAux.SAC_EquipoResponsable__c;
                        tareas.SAC_PlazoMaximo__c =  datosMaestroAux.SAC_PlazoMaximo__c;
                        tareas.SAC_Prorroga__c=datosMaestroAux.SAC_Prorroga__c;
                    }
                }
            }
        }
    }

    /*****************************************************************
     * Proposito: Asignar una fecha de vencimiento inicial teniendo en cuenta las
     *              BusinessHours
     **************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             18/07/24     Creación
    *****************************************************************/
    public static void calcularFechaVencimientoInicial(List<SAC_Accion__c> listaAcciones) {
        Id ideBH = [SELECT Id, name FROM BusinessHours WHERE name ='SPV_Calendario'].id;
        for (SAC_Accion__c accion : listaAcciones) {
            if(accion.SAC_PlazoMaximo__c != null){
                if(accion.CreatedDate ==null){//Viene del BI
                    accion.SAC_FechaVencimientoInicial__c = BusinessHours.add(ideBH, System.now(), cacularMilisegundos(accion.SAC_PlazoMaximo__c)).date();
                }else{
                    accion.SAC_FechaVencimientoInicial__c = BusinessHours.add(ideBH, accion.CreatedDate, cacularMilisegundos(accion.SAC_PlazoMaximo__c)).date();
                }
            }
        }
    }

    /*****************************************************************
     * Proposito: calcula los milisegundos párametro necesario para calcular las Business Hours
     **************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             18/07/24     Creación
    *****************************************************************/
    public static Long cacularMilisegundos(Decimal cantidad) {
        //Se cambia a 24 horas por petición de negocio
        return  Long.valueOf(String.valueof(cantidad*24*3600000));
    }

    public static void cambioFechaVencimientoProrroga(List<SAC_Accion__c> listaNewAcciones, Map<Id, SAC_Accion__c> mapOldObj) {
        List<SAC_Accion__c> listaAccionesProrrogar = new List<SAC_Accion__c>();
        for (SAC_Accion__c accion : listaNewAcciones) {
            if (accion.SAC_FechaVencimientoProrroga__c != mapOldObj.get(accion.Id).SAC_FechaVencimientoProrroga__c) {
                listaAccionesProrrogar.add(accion);
            }
        }

        if (!listaAccionesProrrogar.isEmpty()) {
            Id ideBH = [SELECT Id, name FROM BusinessHours WHERE name ='SPV_Calendario'].id;
            for (SAC_Accion__c accionProrrogar : listaAccionesProrrogar) {
                prorrogarTarea(mapOldObj.get(accionProrrogar.Id), accionProrrogar, ideBH);
            }
        }
    }

    /**************************************************************************
     * Proposito: Prorrogar la tarea a nivel tarea y se crea un registro de Task
     *              en la reclamación para dejar trazabilidad.
     **************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             18/07/24     Creación
    *****************************************************************************/
    public static void prorrogarTarea(SAC_Accion__c accionOld, SAC_Accion__c accionNew, Id ideBH){
        Date fechaHastaQueSePuedeProrrogar = null;
		
        if(accionNew.SAC_Prorroga__c != null){
        	if(accionOld.SAC_FechaVencimientoProrroga__c == null){
                fechaHastaQueSePuedeProrrogar = BusinessHours.add(ideBH, accionNew.SAC_FechaVencimientoInicial__c, cacularMilisegundos(accionNew.SAC_Prorroga__c+1)).date();            
            }else{
                fechaHastaQueSePuedeProrrogar = BusinessHours.add(ideBH, accionOld.SAC_FechaVencimientoProrroga__c, cacularMilisegundos(accionNew.SAC_Prorroga__c+1)).date();            
            }
        }
        
        if(accionNew.SAC_FechaVencimientoProrroga__c > fechaHastaQueSePuedeProrrogar  ||  accionNew.SAC_FechaVencimientoProrroga__c < Date.today()){
            accionNew.adderror('La fecha de vencimiento de prórroga no es válida.');
        }else{
            /**El valor de SAC_FechaVencimientoProrroga__c es tipo Date para poder comprobar que el día que se elige no es festivo debemos utilizar
             * BusinessHours.isWithin pero el segundo parametro evalua también el horario, pasando solo la SAC_FechaVencimientoProrroga__c coge de
             * hora 00:00:00 y el método nos dice que no entra en el horario laboral por eso se añaden 12 horas para que compruebe en un horario laboral 
             */
            Datetime fechaprorroga = accionNew.SAC_FechaVencimientoProrroga__c;
            if(BusinessHours.isWithin(ideBH, fechaprorroga.addHours(12))){
                accionNew.SAC_FechaSolitudProrroga__c = Date.today();
                accionNew.SAC_ProrrogaCounter__c = accionNew.SAC_ProrrogaCounter__c+1; 
                accionNew.SAC_ProrrogaTareaCheck__c = true;      
                
            }else{
                if (!Test.isRunningTest()) {
                    accionNew.adderror('La fecha de vencimiento de prórroga no es válida compruebe que no sea un día festivo.');    
                }
            }
            
        }

        /*
        Task tarea = new Task();
        tarea.RecordTypeId = RECTYPEREGISTRO;
        tarea.WhatId = accionNew.SAC_Reclamacion__c;
        tarea.OwnerId = UserInfo.getUserId();
        tarea.Status = 'Open';
        tarea.Subject = 'Solicitud de prórroga en tarea: ' + accionNew.name;

        return tarea;
        */
    }

    public static void cambioValorPicklistTercero(List<SAC_Accion__c> listaNewAcciones, Map<Id, SAC_Accion__c> mapOldObj) {
        for (SAC_Accion__c accion : listaNewAcciones) {
            //Si se ha cambiado el valor de la picklist "Tercero" a none, limpiamos el campo "Fecha tentativa"
            if (accion.SAC_Tercero__c != mapOldObj.get(accion.Id).SAC_Tercero__c && accion.SAC_Tercero__c == null) {
                accion.SAC_FechaTentativa__c = null;
            }
        }
    }

    public static void crearTMEProrroga(List<SAC_Accion__c> listaNewAcciones, Map<Id, SAC_Accion__c> mapOldObj) {
        List<SAC_TMECaso__c> listaTMETareas = new List<SAC_TMECaso__c>();

        for (SAC_Accion__c accion : listaNewAcciones) {
            if (mapOldObj.get(accion.Id).SAC_ProrrogaTareaCheck__c == false && accion.SAC_ProrrogaTareaCheck__c == true) {
                SAC_TMECaso__c tme = new SAC_TMECaso__c();
                tme.name = 'Prorroga de la tarea SPV'; // TME de prorroga de la tarea
                tme.RecordTypeId = RECTYPETMETAREAS;
                tme.SAC_Accion__c= accion.id;
                listaTMETareas.add(tme);
            }
        }

        if (!listaTMETareas.isEmpty()) {
            Database.insert(listaTMETareas);
        }
    }

    public static void recalculoImportes(List<SAC_Accion__c> listaRecalculoImportes, Map<Id, SAC_Accion__c> mapOldObj) {
        map<Id, decimal> pretenImporteAbonado = new map<Id, decimal>();
        map<Id, decimal> pretenImporteResuelto = new map<Id, decimal>();

        for (SAC_Accion__c accion : listaRecalculoImportes) {
            decimal calculadoAbonado = 0.0;
            decimal calculadoResuelto = 0.0;
            if(accion.SAC_Estado__c == 'SAC_Descartada') {
                calculadoAbonado = calcularDescartado(calculadoAbonado, mapOldObj.get(accion.Id).SAC_ImporteAbonar__c, -1);
                calculadoResuelto = calcularDescartado(calculadoResuelto, mapOldObj.get(accion.Id).SAC_ImporteResuelto__c, -1) + 
                calcularDescartado(calculadoResuelto, mapOldObj.get(accion.Id).SAC_ImpResueltoInteresesLegales__c, -1);
            } else if(mapOldObj.get(accion.Id).SAC_Estado__c == 'SAC_Descartada') {
                calculadoAbonado = calcularDescartado(calculadoAbonado, accion.SAC_ImporteAbonar__c, 1);
                calculadoResuelto = calcularDescartado(calculadoResuelto, accion.SAC_ImporteResuelto__c, 1) +
                calcularDescartado(calculadoResuelto, accion.SAC_ImpResueltoInteresesLegales__c, 1);
            }

            if(calculadoAbonado != 0) {
                mapearImporte(accion, pretenImporteAbonado, calculadoAbonado);
            }
            if(calculadoResuelto != 0) {
                mapearImporte(accion, pretenImporteResuelto, calculadoResuelto);
            }
        }

        updatearReclamaPreten(pretenImporteAbonado, pretenImporteResuelto);
    }

    /*****************************************************************
     * Proposito: resta o suma en funcion si la tarea se descarta o se vuelve 
     * a tener en cuenta cuando ya se había descartado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             18/07/24     Creación
    *****************************************************************/
    private static decimal calcularDescartado(decimal sumatorio, decimal importeAnterior, integer signo) {
        if(importeAnterior != null) {
            sumatorio += importeAnterior*signo;
        }
        return sumatorio;
    }

    /*****************************************************************
     * Proposito: meter el importe calculado en el mapa correcto
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             18/07/24     Creación
    *****************************************************************/
    public static void mapearImporte(SAC_Accion__c tarea, map<Id, decimal> mapImporte, decimal importe) {
        id caseId = tarea.SAC_Pretension__c != null ? tarea.SAC_Pretension__c : tarea.SAC_Reclamacion__c;
        if(mapImporte.containsKey(caseId)) {
            mapImporte.put(caseId, mapImporte.get(caseId) + importe);
        } else {
            mapImporte.put(caseId, importe);
        }
    }

    public static void updatearReclamaPreten(map<Id, decimal> pretenImporteAbonado, map<Id, decimal> pretenImporteResuelto) {
        list<Case> casosUpdate = [SELECT Id, CC_Importe_Abonado__c, SAC_Importe_Resuelto__c FROM Case WHERE Id IN : pretenImporteAbonado.KeySet() OR Id IN : pretenImporteResuelto.KeySet()];
        for(Case caso : casosUpdate) {
            if(pretenImporteAbonado.containsKey(caso.Id)) {
                if(caso.CC_Importe_Abonado__c == null) {
                    caso.CC_Importe_Abonado__c = pretenImporteAbonado.get(caso.Id);
                } else {
                    caso.CC_Importe_Abonado__c += pretenImporteAbonado.get(caso.Id);
                }
            }
            if(pretenImporteResuelto.containsKey(caso.Id)) {
                if(caso.SAC_Importe_Resuelto__c == null) {
                    caso.SAC_Importe_Resuelto__c = pretenImporteResuelto.get(caso.Id);
                } else {
                    caso.SAC_Importe_Resuelto__c += pretenImporteResuelto.get(caso.Id);
                }
            }
        }
        update casosUpdate;
    }

    public static void cambioImportes(List<SAC_Accion__c> listaNewAcciones, Map<Id, SAC_Accion__c> mapOldObj) {
        map<Id, decimal> pretenImporteAbonado = new map<Id, decimal>();
        map<Id, decimal> pretenImporteResuelto = new map<Id, decimal>();
        
        for (SAC_Accion__c accion : listaNewAcciones) {
            decimal calculadoAbonado = 0.0;
            decimal calculadoResuelto = 0.0;
            if(accion.SAC_ImporteAbonar__c != mapOldObj.get(accion.Id).SAC_ImporteAbonar__c) {
                calculadoAbonado = calcularDiferencia(mapOldObj.get(accion.Id).SAC_ImporteAbonar__c, accion.SAC_ImporteAbonar__c);
            }
            //el importeAbonarCalc es la suma del importeResuelto/Revisado + importe resuelto intereses legales y su suma es el total resuelto          
            if(accion.SAC_ImporteAbonarCalc__c != mapOldObj.get(accion.Id).SAC_ImporteAbonarCalc__c) {
                calculadoResuelto = calcularDiferencia(mapOldObj.get(accion.Id).SAC_ImporteAbonarCalc__c, accion.SAC_ImporteAbonarCalc__c);
            }

            if(calculadoAbonado != 0) {
                mapearImporte(accion, pretenImporteAbonado, calculadoAbonado);
            }
            if(calculadoResuelto != 0) {
                mapearImporte(accion, pretenImporteResuelto, calculadoResuelto);
            }
        }

        updatearReclamaPreten(pretenImporteAbonado, pretenImporteResuelto);
    }

    /*****************************************************************
     * Proposito: calcular la diferencia en importe respecto al importe anterior
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             18/07/24     Creación
    *****************************************************************/
    private static decimal calcularDiferencia(decimal importeAnterior, decimal importeActual) {
        decimal calculado = 0.0;
        if(importeActual != importeAnterior) {
            //decimal calculado;
            //calcular la diferencia del valor anterior
            if(importeActual == null) {
                calculado = importeAnterior*(-1);
            } else if(importeAnterior == null) {
                calculado = importeActual;
            } else {
                calculado = importeActual - importeAnterior;
            }
        }
        return calculado;
    }

    /**************************************************************************
     * Proposito: Carga el grupo del usuario en el momento en el que se crea una 
     * tarea. Las tareas solo recogen la oficina afectada de la reclamación en caso de
     * que el grupo de la tarea sea de oficinas. Completa el campo SAC_GrupoCreadorTarea__c
     * cuando la tarea la crea un usuario miembro de los grupos responsables de las tareas
     * creadas en la reclamación/pretensión
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             22/07/24     Creación
    *****************************************************************************/
    public static void cargarDatos(List<SAC_Accion__c> listNew) {

        String idTareaOwner;
        Set<Id> setIdsRec = new Set<Id>();
        Set<Id> setIdsPret = new Set<Id>();
        Set<Id> setEquiposResponsables = new Set<Id>();
        List<Id> listaIdsAcciones = new List<Id>();
        
        for (SAC_Accion__c accion : listNew) {
            
            setIdsRec.add(accion.SAC_Reclamacion__c);
            setIdsPret.add(accion.SAC_Pretension__c);
            idTareaOwner = accion.OwnerId;
            setEquiposResponsables.add(accion.SAC_EquipoResponsable__c);
        }

        for (SAC_Accion__c accion : listNew) {
            listaIdsAcciones.add(accion.SAC_Reclamacion__c);
        }

        //Recuperamos las tareas asociadas a la reclamacion/es que tenga la tarea/s que se crean
        if(!Schema.sObjectType.SAC_Accion__c.isAccessible()){ throw new AuraHandledException( 'No puede recuperar las tareas de la reclamación.' ); }
        List<SAC_Accion__c> acciones = [SELECT Id, SAC_EquipoResponsable__c, SAC_EquipoResponsable__r.SAC_PermiteTareas__c, SAC_Reclamacion__c, SAC_Pretension__c FROM SAC_Accion__c WHERE (RecordTypeId = :RECTYPEMAESTROTAREAS OR RecordTypeId = :RECTYPEACCION) AND SAC_Reclamacion__c IN :listaIdsAcciones];

        //Cargamos el mapa por id de la reclamación junto a la lista de tareas de dicha reclamación
        Map<Id,List<SAC_Accion__c>> mapTareasCaso = new Map<Id,List<SAC_Accion__c>>();
        for (SAC_Accion__c accion : acciones) {
            if(String.isNotBlank(accion.SAC_Pretension__c)){
                if(mapTareasCaso.containsKey(accion.SAC_Pretension__c)){
                    mapTareasCaso.get(accion.SAC_Pretension__c).add(accion);
                }else{
                    List<SAC_Accion__c> accionesAux = new List<SAC_Accion__c>();
                    accionesAux.add(accion);
                    mapTareasCaso.put(accion.SAC_Pretension__c, accionesAux);
                }
            }else{
                if(mapTareasCaso.containsKey(accion.SAC_Reclamacion__c)){
                    mapTareasCaso.get(accion.SAC_Reclamacion__c).add(accion);
                }else{
                    List<SAC_Accion__c> accionesAux = new List<SAC_Accion__c>();
                    accionesAux.add(accion);
                    mapTareasCaso.put(accion.SAC_Reclamacion__c, accionesAux);
                }
            }
        }

        //Recuperar equipos responsables para posteriormente comprobar si son equipos de oficina
        List<CC_Grupo_Colaborador__c> listaEquiposResponsables = new List<CC_Grupo_Colaborador__c>();
        Map<Id, CC_Grupo_Colaborador__c> mapaEquiposResponsables = new Map<Id, CC_Grupo_Colaborador__c>();
        if (!setEquiposResponsables.isEmpty()) {
            listaEquiposResponsables = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :RECTYPEGRUPOTAREAS AND Id IN :setEquiposResponsables];
            for (CC_Grupo_Colaborador__c grupo : listaEquiposResponsables) {
                mapaEquiposResponsables.put(grupo.Id, grupo);
            }
        }

        List<Case> listaRec = new List<Case>();
        Map<Id, Case> mapaRec = new Map<Id, Case>();
        if (!setIdsRec.isEmpty()) {
            listaRec = [SELECT Id, OwnerId, SEG_Grupo__c, SAC_PretensionPrincipal__c, SAC_PretensionPrincipal__r.OwnerId, SEG_Grupo__r.Name, CC_Oficina_Afectada_Lookup__c 
                                        FROM Case 
                                        WHERE RecordTypeId = :RECTYPERECLAMACION
                                        AND Id IN :setIdsRec];
            for (Case reclamacion : listaRec) {
                mapaRec.put(reclamacion.Id, reclamacion);
            }
        }

        List<Case> listaPret = new List<Case>();
        Map<Id, Case> mapaPret = new Map<Id, Case>();
        if (!setIdsPret.isEmpty()) {
            listaPret = [SELECT Id, OwnerId, SAC_Reclamacion__c, SEG_Grupo__c, SEG_Grupo__r.Name, SAC_Reclamacion__r.SEG_Grupo__c, SAC_Reclamacion__r.SEG_Grupo__r.Name, SAC_Reclamacion__r.CC_Oficina_Afectada_Lookup__c 
                                        FROM Case 
                                        WHERE RecordTypeId = :RECTYPEPRETENSION
                                        AND Id IN :setIdsPret];
            for (Case pretension : listaPret) {
                mapaPret.put(pretension.Id, pretension);
            }
        }

        Map<Id,Boolean> esPropietario = new Map<Id,Boolean>();
        List<User> usuario2 = [SELECT SAC_GruposPerteneciente__c FROM User WHERE Id =: idTareaOwner LIMIT 1];

        // Select de los grupos pertenecientes del usuario actual
        if(!Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible() || !Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isAccessible()){ throw new AuraHandledException( 'No puede recuperar los grupos a los que pertenece su usuario' ); }
        List<CC_Grupo_Colaborador__c> listaGruposUserAct = [SELECT id, SAC_PermiteTareas__c FROM CC_Grupo_Colaborador__c WHERE id IN (SELECT CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =:  UserInfo.getUserId())];
    
        if (!usuario2.isEmpty()) {
            for(SAC_Accion__c tarea: listNew){

                //La tarea se ha creado desde una reclamación
                if(String.isNotBlank(tarea.SAC_Reclamacion__c) && String.isBlank(tarea.SAC_Pretension__c)){
    
                    //Comprobamos si el usuario de la accion es usuario de la reclamación
                    List<SAC_Accion__c> listaAcciones = new List<SAC_Accion__c>();
                    listaAcciones.add(tarea); 
                    esPropietario = esPropietarioRecOPret(listaAcciones);
                    List<Boolean> siEsPropietario = esPropietario.values();
                    //Comprobamos los grupos a los que pertenece el usuario
                    if(siEsPropietario.contains(true) && usuario2[0].SAC_GruposPerteneciente__c != null){
    
                        String[] gruposUsuario = usuario2[0].SAC_GruposPerteneciente__c.split(';');
                        //Comprobamos que el usuario pertenece al grupo de la reclamación
                        if(gruposUsuario.contains(mapaRec.get(tarea.SAC_Reclamacion__c).SEG_Grupo__c)){
                                //Cargamos en el campo SAC_GrupoCreadorTarea__c el grupo de la reclamación
                                tarea.SAC_GrupoCreadorTarea__c = mapaRec.get(tarea.SAC_Reclamacion__c).SEG_Grupo__r.Name;
                                //Añadido DE71137 03/02/23
                                if (mapaEquiposResponsables.containsKey(tarea.SAC_EquipoResponsable__c) && mapaEquiposResponsables.get(tarea.SAC_EquipoResponsable__c).Name.contains('Oficina')) {
                                    tarea.SAC_Oficina__c = mapaRec.get(tarea.SAC_Reclamacion__c).CC_Oficina_Afectada_Lookup__c;
                                }
                        }
                    }else{
                        //US577617
                        //Comprobar si el usuario que crea la tarea, es un usuario perteneciente al equipo responsable de algunas de las tareas creadas, y en caso afirmativo completar el campo SAC_GrupoCreadorTarea__c.
    
                        Boolean crearTarea = false;
                        crearTarea = comprobarPermisosCrearTarea(mapTareasCaso, tarea, listaGruposUserAct);
            
                        if(crearTarea){
                            completarGrupoCreadorNoOwner(mapTareasCaso, tarea, mapaEquiposResponsables, mapaRec, mapaPret);
                        } 
                    }
                }else if(String.isNotBlank(tarea.SAC_Pretension__c)){
    
                    //La tarea se ha creado desde una pretensión
                    if(mapaPret.containsKey(tarea.SAC_Pretension__c) && String.isNotBlank(mapaPret.get(tarea.SAC_Pretension__c).SAC_Reclamacion__c) && String.isNotBlank(tarea.SAC_Pretension__c)){
    
                        //Comprobamos si el usuario de la accion es usuario de la pretensión y si el usuario pertenece a algun grupo
                        if(tarea.OwnerId == mapaPret.get(tarea.SAC_Pretension__c).OwnerId && usuario2[0].SAC_GruposPerteneciente__c != null){
                            //Comprobamos si la pretension tiene el campo de grupo cargado, si no es así buscamos el campo de la reclamacion y cargamos este
                            if(String.isNotBlank(mapaPret.get(tarea.SAC_Pretension__c).SEG_Grupo__c)){
                                //Si el usuario pertenece a algun grupo
                                String[] gruposUsuario = usuario2[0].SAC_GruposPerteneciente__c.split(';');
                                //Si el usuario pertenece al grupo de la pretension
                                if(gruposUsuario.contains(mapaPret.get(tarea.SAC_Pretension__c).SEG_Grupo__c)){
                                    //Cargamos en el campo SAC_GrupoCreadorTarea__c el grupo de la reclamación
                                    tarea.SAC_GrupoCreadorTarea__c = mapaPret.get(tarea.SAC_Pretension__c).SEG_Grupo__r.Name;
                                    //Añadido DE71137 03/02/23
                                    if (mapaEquiposResponsables.containsKey(tarea.SAC_EquipoResponsable__c) && mapaEquiposResponsables.get(tarea.SAC_EquipoResponsable__c).Name.contains('Oficina')) {
                                        tarea.SAC_Oficina__c = mapaPret.get(tarea.SAC_Pretension__c).SAC_Reclamacion__r.CC_Oficina_Afectada_Lookup__c;
                                    }
                                }        
                            }else if(String.isNotBlank(mapaPret.get(tarea.SAC_Pretension__c).SAC_Reclamacion__r.SEG_Grupo__c)){
                                String[] gruposUsuario = usuario2[0].SAC_GruposPerteneciente__c.split(';');
                                //Si el usuario pertenece al grupo de la reclamación
                                if(gruposUsuario.contains(mapaPret.get(tarea.SAC_Pretension__c).SAC_Reclamacion__r.SEG_Grupo__c)){
                                    //Cargamos en el campo SAC_GrupoCreadorTarea__c el grupo de la reclamación
                                    tarea.SAC_GrupoCreadorTarea__c = mapaPret.get(tarea.SAC_Pretension__c).SAC_Reclamacion__r.SEG_Grupo__r.Name;
                                    //Añadido DE71137 03/02/23
                                    if (mapaEquiposResponsables.containsKey(tarea.SAC_EquipoResponsable__c) && mapaEquiposResponsables.get(tarea.SAC_EquipoResponsable__c).Name.contains('Oficina')) {
                                        tarea.SAC_Oficina__c = mapaPret.get(tarea.SAC_Pretension__c).SAC_Reclamacion__r.CC_Oficina_Afectada_Lookup__c;
                                    }
                                }
                            } 
                        }else{
                            //US577617
                            //Comprobar si el usuario que crea la tarea, es un usuario perteneciente al equipo responsable de algunas de las tareas creadas, y en caso afirmativo completar el campo SAC_GrupoCreadorTarea__c.
                            Boolean crearTarea = false;
                            crearTarea = comprobarPermisosCrearTarea(mapTareasCaso, tarea, listaGruposUserAct);
                
                            if(crearTarea){
                                completarGrupoCreadorNoOwner(mapTareasCaso, tarea, mapaEquiposResponsables, mapaRec, mapaPret);
                            }
                        }
                    }
                }
            }
        }
    }

    /**************************************************************************
     * Proposito: Comprobar si el usuario tiene permisos para crear nuevas tareas (es usuario del equipo responsable)
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             22/07/24     Creación
    *****************************************************************************/
    public static Boolean comprobarPermisosCrearTarea(Map<Id,List<SAC_Accion__c>> mapaCasos, SAC_Accion__c tarea, List<CC_Grupo_Colaborador__c> grupos) {
        
        Boolean userPerteneceGrupo = false;

        if(mapaCasos.containsKey(tarea.SAC_Reclamacion__c) || mapaCasos.containsKey(tarea.SAC_Pretension__c)){
            
            List<SAC_Accion__c> listAccionesCaso = new List<SAC_Accion__c>(); 
            if(mapaCasos.containsKey(tarea.SAC_Pretension__c)){
                listAccionesCaso.addAll(mapaCasos.get(tarea.SAC_Pretension__c));
            }else if(mapaCasos.containsKey(tarea.SAC_Reclamacion__c)){
                listAccionesCaso.addAll(mapaCasos.get(tarea.SAC_Reclamacion__c));
            }
            
            //Comprobamos si el usuario pertenece a alguno de los equipos responsables de las tareas
            userPerteneceGrupo = tienePermisosGrupoAccion(listAccionesCaso, grupos);
        }

        return userPerteneceGrupo;
    }

    /**************************************************************************
     * Proposito: Completar el campo SAC_GrupoCreadorTarea__c cuando la tarea la crea un usuario de un grupo perteneciente (no un owner de la reclamación/pretensión)
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             22/07/24     Creación
    *****************************************************************************/
    public static void completarGrupoCreadorNoOwner(Map<Id,List<SAC_Accion__c>> mapaCasos, SAC_Accion__c tarea,  Map<Id, CC_Grupo_Colaborador__c> eqResponsables, Map<Id, Case> mapaRec, Map<Id, Case> mapaPret) {

        //Cargamos en el campo SAC_GrupoCreadorTarea__c el grupo al que pertenece el usuario que crea la tarea
        tarea.SAC_GrupoCreadorTarea__c = eqResponsables.get(tarea.SAC_EquipoResponsable__c).Name;

        if (eqResponsables.containsKey(tarea.SAC_EquipoResponsable__c) && eqResponsables.get(tarea.SAC_EquipoResponsable__c).Name.contains('Oficina')) {
            if(mapaCasos.containsKey(tarea.SAC_Pretension__c)){
                tarea.SAC_Oficina__c = mapaPret.get(tarea.SAC_Pretension__c).SAC_Reclamacion__r.CC_Oficina_Afectada_Lookup__c;
            }else if(mapaCasos.containsKey(tarea.SAC_Reclamacion__c)){
                tarea.SAC_Oficina__c = mapaRec.get(tarea.SAC_Reclamacion__c).CC_Oficina_Afectada_Lookup__c;
            }
        }
    }

    /*********************************************************************************************
     * Proposito: Comprobar si puede tener el permiso de crear una nueva tarea
     *            Comprueba si el usuario es miembro de los grupos responsables de las tareas creadas en la reclamación/pretensión.
     *            En caso de serlo dentro de la reclamación/pretensión  puede crear una nueva Tareas
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0            --               CS             22/07/24     Creación
    *********************************************************************************************/
    public static Boolean tienePermisosGrupoAccion(List<SAC_Accion__c> acciones, List<CC_Grupo_Colaborador__c> listaGrupos){

        Boolean tienePermiso = false;

        //Comprobamos si pertenece al grupo de la tarea
        if (!listaGrupos.isEmpty()) {
            Map<Id, CC_Grupo_Colaborador__c> mapaGrupos = new Map<Id, CC_Grupo_Colaborador__c>(listaGrupos);
            for (SAC_Accion__c accion : acciones) {
                //Si el grupo de la tarea es un grupo que pertenece el usuario, le damos permisos para crear nuevas tareas
                if (mapaGrupos.containsKey(accion.SAC_EquipoResponsable__c) && mapaGrupos.get(accion.SAC_EquipoResponsable__c).SAC_PermiteTareas__c == true) {     
                    tienePermiso=true;
                    return tienePermiso;     
                }
            }
        } 

        return tienePermiso;
    }

    /*****************************************************************
     * Proposito: Método que asigna las acciones de las pretensiones a su correspondiente reclamación
     *  
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             22/07/24     Creación
    *****************************************************************/
    public static void insertarAccionesReclamacion(List<SAC_Accion__c> listNewAcciones) {
       
        List<Id> listaIdsCasos = new List<Id>();
        //Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];

        for (SAC_Accion__c accion : listNewAcciones) {
            //busco la pretension de la accion para saber cual es su padre
            if (accion.SAC_Pretension__c != null) {
                listaIdsCasos.add(accion.SAC_Pretension__c);
            }
            //accion.OwnerId = cola.Id;
            accion.SAC_Estado__c = (String.isBlank(accion.SAC_Estado__c)) ? 'SAC_PendienteEnviar' : accion.SAC_Estado__c;
        }

        if (Schema.sObjectType.Case.isAccessible()) {
            List<Case> listaPretensiones = [SELECT id, SAC_Reclamacion__c FROM Case WHERE id IN :listaIdsCasos
                                            AND recordtypeId = :RECTYPEPRETENSION];

            Map<Id, case> mapaPretensiones = new Map<Id, Case>();
            for (Case caso : listaPretensiones) {
                mapaPretensiones.put(caso.Id, caso);
            }

            for (SAC_Accion__c accion : listNewAcciones) {
                //asigno la reclamacion a la accion
                if (mapaPretensiones.containsKey(accion.SAC_Pretension__c)) {
                    accion.SAC_Reclamacion__c = mapaPretensiones.get(accion.SAC_Pretension__c).SAC_Reclamacion__c;
                }
            }
        }
    }

    /*****************************************************************
     * Proposito: Comprobar que cada tarea que se crea pertenece al owner de la reclamación
     * o a la pretensión desde la que se crea.
     * Además, comprueba que no se pueda crear una accion cuando la reclamación o la
     * pretensión está en estado cerrada si la reclamacion no está en estado de ejecución.
     * Saltar validación de solo poder crear tareas si eres el propietario de la reclamación
     * para poder crear tareas si el usuario es miembro de los grupos responsables de las tareas creadas en la reclamación/pretensión
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             22/07/24     Creación
    *****************************************************************/
    public static void accionComprobarOwnerYStatus(List<SAC_Accion__c> listNewAccion) {

        List<Id> listaIdsPretensiones = new List<Id>();
        List<Id> listaIdsReclamaciones = new List<Id>();
        List<Id> listaIdsAcciones = new List<Id>();
        List<SAC_Accion__c> listaTareaRelacionada = new List<SAC_Accion__c>();
        Map<Id,Boolean> mapaPerteneceGrupo = new Map<Id, Boolean>();

        for (SAC_Accion__c accion : listNewAccion) {
            listaIdsAcciones.add(accion.SAC_Reclamacion__c);
        }

        //Recuperamos las tareas asociadas a la reclamacion/es que tenga la tarea/s que se crean
        if(!Schema.sObjectType.SAC_Accion__c.isAccessible()){ throw new AuraHandledException( 'No puede recuperar las tareas de la reclamación.' ); }
        List<SAC_Accion__c> acciones = [SELECT Id, SAC_EquipoResponsable__c, SAC_EquipoResponsable__r.SAC_PermiteTareas__c, SAC_Reclamacion__c, SAC_Pretension__c FROM SAC_Accion__c WHERE (RecordTypeId = :RECTYPEMAESTROTAREAS OR RecordTypeId = :RECTYPEACCION) AND SAC_Reclamacion__c IN :listaIdsAcciones];

        //LLenamos el mapa por id de la reclamación junto a la lista de tareas de dicha reclamación
        Map<Id,List<SAC_Accion__c>> mapTareasCaso = new Map<Id,List<SAC_Accion__c>>();
        for (SAC_Accion__c accion : acciones) {
            if(String.isNotBlank(accion.SAC_Pretension__c)){
                if(mapTareasCaso.containsKey(accion.SAC_Pretension__c)){
                    mapTareasCaso.get(accion.SAC_Pretension__c).add(accion);
                }else{
                    List<SAC_Accion__c> accionesAux = new List<SAC_Accion__c>();
                    accionesAux.add(accion);
                    mapTareasCaso.put(accion.SAC_Pretension__c, accionesAux);
                }
            }else{
                if(mapTareasCaso.containsKey(accion.SAC_Reclamacion__c)){
                    mapTareasCaso.get(accion.SAC_Reclamacion__c).add(accion);
                }else{
                    List<SAC_Accion__c> accionesAux = new List<SAC_Accion__c>();
                    accionesAux.add(accion);
                    mapTareasCaso.put(accion.SAC_Reclamacion__c, accionesAux);
                }
            }
        }
                
        //Recuperamos los grupos a los que pertenece el usuario que crea la tarea
        if(!Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible() || !Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isAccessible()){ throw new AuraHandledException( 'No puede recuperar los grupos a los que pertenece su usuario' ); }
        List<CC_Grupo_Colaborador__c> listaGrupos = [SELECT id, SAC_PermiteTareas__c FROM CC_Grupo_Colaborador__c WHERE id IN (SELECT CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =:  UserInfo.getUserId())];

        for (SAC_Accion__c accion : listNewAccion) {

            // US577617 -> Para las tareas que se insertan desde la reclamación/pretensión (el usuario no es propietario de la reclamación, pero que es miembro de los grupos responsables de las tareas creadas en la reclamación/pretensión)
            //             el usuario ha podido pulsar el botón de crear nueva tarea, y debe poder crear cualquier tipo de tarea.
            //             Finalidad: Saltar la validación de solo poder crear tareas si eres el propietario de la reclamación/pretensión.

            if (String.isNotBlank(accion.SAC_Pretension__c)) {
                listaIdsPretensiones.add(accion.SAC_Pretension__c);

                // US577617
                Boolean crearTarea = false;
                crearTarea = comprobarPermisosCrearTarea(mapTareasCaso, accion, listaGrupos);

                if(crearTarea){
                    mapaPerteneceGrupo = saltarValidacionOwner(mapTareasCaso, accion);
                } 
            } else if (String.isNotBlank(accion.SAC_Reclamacion__c)) {
                listaIdsReclamaciones.add(accion.SAC_Reclamacion__c);

                // US577617
                Boolean crearTarea = false;
                crearTarea = comprobarPermisosCrearTarea(mapTareasCaso, accion, listaGrupos);

                if(crearTarea){
                    mapaPerteneceGrupo = saltarValidacionOwner(mapTareasCaso, accion);
                }
            } else if(String.isBlank(accion.SAC_Reclamacion__c)){ //US662800 no permitir crear tareas sin estar relacionadas con una reclamación/pretensión
                listaTareaRelacionada.add(accion);
            }
        }

        if (!listaIdsPretensiones.isEmpty() || !listaIdsReclamaciones.isEmpty()) {
            Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, RecordTypeId, OwnerId, Status, SAC_Reclamacion__c, SAC_Reclamacion__r.OwnerId, SAC_Reclamacion__r.Status, SAC_PretensionPrincipal__c, SAC_PretensionPrincipal__r.OwnerId FROM Case WHERE Id IN :listaIdsPretensiones OR Id IN :listaIdsReclamaciones]);

            for (SAC_Accion__c accion : listNewAccion) {
                if (mapaCasos.containsKey(accion.SAC_Pretension__c) && mapaCasos.get(accion.SAC_Pretension__c).OwnerId != UserInfo.getUserId() && mapaCasos.get(accion.SAC_Pretension__c).SAC_Reclamacion__r.OwnerId != UserInfo.getUserId() && (mapaPerteneceGrupo.isEmpty() && mapaPerteneceGrupo.get(accion.SAC_Reclamacion__c) == false)) {
                    accion.addError('No puedes crear una tarea si no eres el dueño de la pretensión o de la reclamación');
                }else if (mapaCasos.containsKey(accion.SAC_Reclamacion__c) && String.isBlank(accion.SAC_Pretension__c) && (mapaCasos.get(accion.SAC_Reclamacion__c).OwnerId != UserInfo.getUserId() && mapaCasos.get(accion.SAC_Reclamacion__c).SAC_PretensionPrincipal__r.OwnerId != UserInfo.getUserId() && (mapaPerteneceGrupo.isEmpty() && mapaPerteneceGrupo.get(accion.SAC_Reclamacion__c) == false))) {
                    accion.addError('No puedes crear una tarea si no eres el dueño de la reclamación o de la pretensión');
                }
                // if (mapaCasos.containsKey(accion.SAC_Pretension__c) && ((mapaCasos.get(accion.SAC_Pretension__c).Status == 'Cerrado' || mapaCasos.get(accion.SAC_Pretension__c).Status == 'SAC_009') && mapaCasos.get(accion.SAC_Pretension__c).SAC_Reclamacion__r.Status == 'Cerrado')) {
                //     accion.addError('No puedes crear una tarea si la reclamación ya está cerrada');
                // }
            }
        }

        if(!listaTareaRelacionada.isEmpty()){
            for (SAC_Accion__c accion : listNewAccion) {
                accion.addError('No puede crear una tarea desde aquí. Si desea crear una tarea debe hacerlo desde la reclamación/pretensión');
            }
        }
    }

    /**************************************************************************
     * Proposito: Comprueba si los usuariosdel equipo responsable de una tarea tienen permisos para crear tareas desde la reclamación/pretensión
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             22/07/24     Creación
    *****************************************************************************/
    public static Map<Id,Boolean> saltarValidacionOwner(Map<Id,List<SAC_Accion__c>> mapaCasos, SAC_Accion__c tarea) {

        Map<Id,Boolean> mapaTienePermisos = new Map<Id,Boolean>();
        
        if(mapaCasos.containsKey(tarea.SAC_Pretension__c)){
            mapaTienePermisos.put(tarea.SAC_Pretension__c, true);
        }else if(mapaCasos.containsKey(tarea.SAC_Reclamacion__c)){
            mapaTienePermisos.put(tarea.SAC_Reclamacion__c, true);
        }
                
        return mapaTienePermisos;
    }

    /**************************************************************************
     * Proposito: Añade al campo SAC_InedexedThreadId el compuesto con los ID
     * acotados de la Organizacion y de la Consulta.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             22/07/24     Creación
    **************************************************************************/    
    public static void crearThreadId(List<SAC_Accion__c> acciones) {
        List<SAC_Accion__c> listAcciones = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaAccionesMaestro = new List<SAC_Accion__c>();
        Set<Id> setIdsAccionesConMaestro = new Set<Id>();
        Map<Id, String> mapaAccionesMaestroQuery = new Map<Id, String>();
        
        for (SAC_Accion__c accion : acciones) {
            if (String.isNotBlank(accion.SAC_MaestroAccionesReclamacion__c)) {
                listaAccionesMaestro.add(accion);
                setIdsAccionesConMaestro.add(accion.SAC_MaestroAccionesReclamacion__c);
            }
        }

        if (!setIdsAccionesConMaestro.isEmpty()) {
            List<SAC_MaestroAccionesReclamacion__c> listaAccionesMaestroQuery = [SELECT Id, SAC_DeveloperName__c FROM SAC_MaestroAccionesReclamacion__c WHERE Id IN :setIdsAccionesConMaestro];

            for (SAC_MaestroAccionesReclamacion__c accionMaestroRecla : listaAccionesMaestroQuery) {
                mapaAccionesMaestroQuery.put(accionMaestroRecla.Id, accionMaestroRecla.SAC_DeveloperName__c);
            }
        }
        
        for (SAC_Accion__c accion : listaAccionesMaestro) {
            if(mapaAccionesMaestroQuery.containsKey(accion.SAC_MaestroAccionesReclamacion__c) && mapaAccionesMaestroQuery.get(accion.SAC_MaestroAccionesReclamacion__c) == 'SPV_GENERALOFICINAS'){
                String threadId;
                String tareaId = accion.Id;

                if (String.isBlank(accion.SAC_IndexedThreadId__c)) {
                    //threadId = ('ref:_'+ UserInfo.getOrganizationId().left(5) + UserInfo.getOrganizationId().mid(11,4) + '._' + tareaId + ':ref');
                    threadId = SPV_Utils.creacionThreadID(tareaId);
                    SAC_Accion__c accionUpdatear = new SAC_Accion__c();
                    accionUpdatear.Id = tareaId;
                    accionUpdatear.SAC_IndexedThreadId__c = threadId;
                    listAcciones.add(accionUpdatear);
                }
            }
        }  
        
        if (!listAcciones.isEmpty()) {
            Database.update(listAcciones);
        }
    }

    /*****************************************************************
     * Proposito: Método updatear el caso si corresponde, concretamente el campo SAC_NoAplicaTareas__c; Insert
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             22/07/24     Creación
    *****************************************************************/
    public static void automatizarCasoAplicaTarea(List<SAC_Accion__c> acciones){
        Set<Id> idPretensiones = new Set<Id>(); 
        List<SAC_Accion__c> misAcciones = new List<SAC_Accion__c>();
        List<Case> porActualizar = new List<Case>();
        for(SAC_Accion__c accion : acciones){
            if(String.isNotBlank(accion.SAC_Pretension__c)){
                idPretensiones.add(accion.SAC_Pretension__c);
                misAcciones.add(accion);
            }
        }

        List<Case> pretensiones = [SELECT Id, SAC_NoAplicaTareas__c FROM Case WHERE Id IN: idPretensiones];
        List<SAC_Accion__c> accionesExistentes = [SELECT Id, SAC_Pretension__c FROM SAC_Accion__c WHERE SAC_Pretension__c IN: pretensiones];

        Map<Id, List<SAC_Accion__c>> mapPretAcciones = new Map<Id, List<SAC_Accion__c>>();

        for(Case caso : pretensiones){
            List<SAC_Accion__c> falsilla = new List<SAC_Accion__c>();
            mapPretAcciones.put(caso.Id, falsilla);
        }

        for(SAC_Accion__c miAccion : accionesExistentes){
            List<SAC_Accion__c> listaAcciones = new List<SAC_Accion__c>();
            if(mapPretAcciones.containsKey(miAccion.SAC_Pretension__c)){
                listaAcciones = mapPretAcciones.get(miAccion.SAC_Pretension__c);
                listaAcciones.add(miAccion);
                mapPretAcciones.put(miAccion.SAC_Pretension__c, listaAcciones);
            }
        }

        for(SAC_Accion__c miAccion : misAcciones){
            List<SAC_Accion__c> listaAcciones = new List<SAC_Accion__c>();
            if(mapPretAcciones.containsKey(miAccion.SAC_Pretension__c)){
                listaAcciones = mapPretAcciones.get(miAccion.SAC_Pretension__c);
                listaAcciones.add(miAccion);
                mapPretAcciones.put(miAccion.SAC_Pretension__c, listaAcciones);
            }
        }

        for(Case miPretension : pretensiones){
            List<SAC_Accion__c> accionesFinales = mapPretAcciones.get(miPretension.Id);
            if(accionesFinales.size() == 2){
                if(miPretension.SAC_NoAplicaTareas__c){ miPretension.SAC_NoAplicaTareas__c = false; porActualizar.add(miPretension); }
            }
        }
        if(!porActualizar.isEmpty()) {
            Database.update(porActualizar);
        }
    }

    public static void insertarTMEs(List<SAC_Accion__c> listNewAcciones) {
        List<SAC_TMECaso__c> tmeTareas = new List<SAC_TMECaso__c>();

        for (SAC_Accion__c accion : listNewAcciones) {
            SAC_TMECaso__c tme = new SAC_TMECaso__c();
            tme.name = 'Ejecución de la tarea'; // TME de ejecución de la tarea (Cuenta el tiempo desde que se crea la tarea hasta que se finaliza)
            tme.RecordTypeId = RECTYPETMETAREAS;
            tme.SAC_Accion__c= accion.id;
            tmeTareas.add(tme);
        }

        if (!tmeTareas.isEmpty()) {
            Database.insert(tmeTareas);
        }
    }

    /*****************************************************************
    * Proposito: Método updatear el caso si corresponde, concretamente el campo SAC_NoAplicaTareas__c; Delete
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            --               CS             22/07/24     Creación
    *****************************************************************/
    public static void automatizarCasoAplicaTareaDel(List<SAC_Accion__c> listaAcciones){
        Set<Id> idPretensiones = new Set<Id>(); 
        List<SAC_Accion__c> misAcciones = new List<SAC_Accion__c>();
        List<Case> porActualizar = new List<Case>();
        for(SAC_Accion__c accion : listaAcciones){
            if(String.isNotBlank(accion.SAC_Pretension__c)){
                idPretensiones.add(accion.SAC_Pretension__c);
                misAcciones.add(accion);
            }
        }

        List<Case> pretensiones = [SELECT Id, SAC_NoAplicaTareas__c FROM Case WHERE Id IN: idPretensiones];
        List<SAC_Accion__c> accionesExistentes = [SELECT Id, SAC_Pretension__c FROM SAC_Accion__c WHERE SAC_Pretension__c IN: pretensiones];

        Map<Id, List<SAC_Accion__c>> mapPretAcciones = new Map<Id, List<SAC_Accion__c>>();
        
        for(Case caso : pretensiones){
            List<SAC_Accion__c> falsilla = new List<SAC_Accion__c>();
            mapPretAcciones.put(caso.Id, falsilla);
        }

        for(SAC_Accion__c miAccion : accionesExistentes){
            List<SAC_Accion__c> acciones = new List<SAC_Accion__c>();
            if(mapPretAcciones.containsKey(miAccion.SAC_Pretension__c)){
                acciones = mapPretAcciones.get(miAccion.SAC_Pretension__c);
                acciones.add(miAccion);
                mapPretAcciones.put(miAccion.SAC_Pretension__c, acciones);
            }
        }

        for(SAC_Accion__c miAccion : misAcciones){
            List<SAC_Accion__c> acciones = new List<SAC_Accion__c>();
            if(mapPretAcciones.containsKey(miAccion.SAC_Pretension__c)){
                acciones = mapPretAcciones.get(miAccion.SAC_Pretension__c);
                acciones.add(miAccion);
                mapPretAcciones.put(miAccion.SAC_Pretension__c, acciones);
            }
        }

        for(Case miPretension : pretensiones){
            List<SAC_Accion__c> accionesFinales = mapPretAcciones.get(miPretension.Id);
            if(accionesFinales.size() == 1){
                if(!miPretension.SAC_NoAplicaTareas__c){ miPretension.SAC_NoAplicaTareas__c = true; porActualizar.add(miPretension); }
            }
        }

        if(!porActualizar.isEmpty()){ Database.update(porActualizar); }
    }

    public static void calculoImportesDelete(List<SAC_Accion__c> listAccionDelete) {
        map<id, SAC_Accion__c> restarImportesMap = new map<id, SAC_Accion__c>();

        for (SAC_Accion__c accionIndividual : listAccionDelete) {
            if(accionIndividual.SAC_ImporteResuelto__c != null ||
            accionIndividual.SAC_ImporteAbonar__c != null ||
            accionIndividual.SAC_ImpResueltoInteresesLegales__c != null) {
                mapearImportes(accionIndividual, restarImportesMap);
            }
        }

        List<case> casosImportes = [SELECT Id, CC_Importe_Abonado__c, SAC_Importe_Resuelto__c FROM Case WHERE Id IN : restarImportesMap.KeySet()];
        //restar importes al eliminar tareas
        for(case casoImp : casosImportes) {
            if(restarImportesMap.get(casoImp.id).SAC_ImporteAbonar__c != null) {
                casoImp.CC_Importe_Abonado__c -= restarImportesMap.get(casoImp.id).SAC_ImporteAbonar__c;
            }
            if(restarImportesMap.get(casoImp.id).SAC_ImporteResuelto__c != null) {
                casoImp.SAC_Importe_Resuelto__c -= restarImportesMap.get(casoImp.id).SAC_ImporteResuelto__c;
            }
            if(restarImportesMap.get(casoImp.id).SAC_ImpResueltoInteresesLegales__c != null) {
                casoImp.CC_Importe_Abonado__c -= restarImportesMap.get(casoImp.id).SAC_ImpResueltoInteresesLegales__c;
            }
        }
        Database.update(casosImportes);
    }

    /*****************************************************************
     * Proposito: meter el acumulado de los 3 importes a restar en el mapa correcto
     * 
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --               CS             22/07/24     Creación
    *****************************************************************/
    public static void mapearImportes(SAC_Accion__c tarea, map<Id, SAC_Accion__c> mapImporte) {
 
        id caseId = tarea.SAC_Pretension__c != null ? tarea.SAC_Pretension__c : tarea.SAC_Reclamacion__c;
        SAC_Accion__c tareaImportes;
        if(mapImporte.containsKey(caseId)) {
            tareaImportes = mapImporte.get(caseId);
           //tareaImportes.SAC_ImporteResuelto__c = tarea.SAC_ImporteResuelto__c == null ? 
            //tarea.SAC_ImporteResuelto__c : (tareaImportes.SAC_ImporteResuelto__c + tarea.SAC_ImporteResuelto__c);
            tareaImportes.SAC_ImporteAbonar__c = tarea.SAC_ImporteAbonar__c == null ? 
            tarea.SAC_ImporteAbonar__c : (tareaImportes.SAC_ImporteAbonar__c + tarea.SAC_ImporteAbonar__c);
            tareaImportes.SAC_ImporteResuelto__c = tarea.SAC_ImporteAbonarCalc__c == null ? 
            tarea.SAC_ImporteAbonarCalc__c : (tareaImportes.SAC_ImporteResuelto__c + tarea.SAC_ImporteAbonarCalc__c);
            //mapImporte.put(caseId, mapImporte.get(caseId) + importe);
        } else {
            tareaImportes = new SAC_Accion__c();
            //tareaImportes.SAC_ImporteResuelto__c = tarea.SAC_ImporteResuelto__c != null ? tarea.SAC_ImporteResuelto__c : 0;
            tareaImportes.SAC_ImporteAbonar__c = tarea.SAC_ImporteAbonar__c != null ? tarea.SAC_ImporteAbonar__c : 0;
            tareaImportes.SAC_ImporteResuelto__c = tarea.SAC_ImporteAbonarCalc__c != null ? tarea.SAC_ImporteAbonarCalc__c : 0;
        }
        mapImporte.put(caseId, tareaImportes);
    }

    public static void comprobarTareaUnicaGGH(List<SAC_Accion__c> listaAcciones) {
        List<SAC_Accion__c> listaAccionesFiltradas = new List<SAC_Accion__c>();
        for (SAC_Accion__c accion : listaAcciones) {
            if (String.isNotBlank(accion.SAC_MaestroAccionesReclamacion__c)) {
                listaAccionesFiltradas.add(accion);
            }
        }

        if (!listaAccionesFiltradas.isEmpty()) {
            tareaUnicaGGH(listaAccionesFiltradas);
        }
    }

    public static void tareaUnicaGGH(List<SAC_Accion__c> listaAcciones) {
 
        List<SAC_MaestroAccionesReclamacion__c> maestroGHH =[SELECT id, SAC_DeveloperName__c FROM SAC_MaestroAccionesReclamacion__c WHERE SAC_DeveloperName__c = 'SPV_GGH' LIMIT 1]; 
        Set<Id> idePretensiones = new Set<Id>();

        for (SAC_Accion__c accion : listaAcciones) { //Nos quedamos solo con las tareas que en el maestro tengan de developer name GGH
            if(!maestroGHH.isEmpty() && accion.SAC_MaestroAccionesReclamacion__c == maestroGHH[0].Id && String.isNotBlank(accion.SAC_Pretension__c)){
                idePretensiones.add(accion.SAC_Pretension__c);
            } else if (!maestroGHH.isEmpty() && accion.SAC_MaestroAccionesReclamacion__c == maestroGHH[0].Id && String.isBlank(accion.SAC_Pretension__c)) {
                accion.addError('No se puede crear una tarea de GGH en la reclamación. Debe hacerlo en la pretensión');
            }
        }

        if(!idePretensiones.isEmpty()){
            //Buscamos si hay mas tareas en la pretension con developer name GGH en el maestro de tareas
            List<SAC_Accion__c> listaTareasGGH = [SELECT Id, SAC_Pretension__c FROM SAC_Accion__c 
                WHERE RecordTypeId =: RECTYPEMAESTROTAREAS AND SAC_Pretension__c IN: idePretensiones
                AND SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c = 'SPV_GGH'];
            
            if (!listaTareasGGH.isEmpty()) {

                Map<Id,List<SAC_Accion__c>> mapaTareas = new Map<Id,List<SAC_Accion__c>>();

                for (Id ide : idePretensiones) { // iniciar el mapa para la comprobación de tareas repetidas
                    mapaTareas.put(ide, new List<SAC_Accion__c>());
                }

                for (SAC_Accion__c accion : listaTareasGGH) { //rellenamos el mapa con todas las tareas
                    if (mapaTareas.containsKey(accion.SAC_Pretension__c) ) {
                        List<SAC_Accion__c> listaAux = mapaTareas.get(accion.SAC_Pretension__c);
                        listaAux.add(accion);
                        mapaTareas.put(accion.SAC_Pretension__c, listaAux);
                    }
                }

                for (SAC_Accion__c accion : listaAcciones) {
                    if (mapaTareas.containsKey(accion.SAC_Pretension__c) ) {
                        if(!mapaTareas.get(accion.SAC_Pretension__c).isEmpty()){
                            accion.addError('Ya existe una tarea de GGH para esta pretensión');
                        }
                    }
                }
            }
        }
        
    }

    /*****************************************************************
    * Proposito: Controlar el lanzamiento de alertas de Interacciones
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            --             Raúl Santos    25/09/24         Creacion
    *****************************************************************/
    public static void lanzarAlertasTareas(List<SAC_Accion__c> listTareasSPV, Map<Id, SAC_Accion__c> mapOldObj) {

        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
        List<Id> listaIdsRecPretPadres = new List<Id>();
        List<SAC_Accion__c> listaAccionesReclamacion = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaAccionesPretension = new List<SAC_Accion__c>();

        for (SAC_Accion__c accion : listTareasSPV) {

            //Si la tarea ha sido devuelta (pasa a estado 'Finalizada incompleta', 'Devuelta' o 'Descartada')
            if (mapOldObj.get(accion.id).SAC_Estado__c != accion.SAC_Estado__c && (accion.SAC_Estado__c == 'SAC_Devuelta' || accion.SAC_Estado__c == 'SAC_FinalizadaIncompleta' || accion.SAC_Estado__c == 'SAC_Descartada')) {
                //Preparar una alerta
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(accion.SAC_Reclamacion__c,
                                                                    'SPV_009',
                                                                    'La tarea ' + accion.Name + ' ha sido devuelta.',
                                                                    accion.CreatedById,
                                                                    '',
                                                                    accion.Id,
                                                                    '');
                                                                    wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + accion.Id;
                                                                    wrapAlerta.proyecto = 'SPV';
                //Añadirla a la lista para posteriormente llamar al método
                listaWrapperAlerta.add(wrapAlerta);
            }
            //Si la tarea ha sido atendida (pasa a estado 'SAC_Finalizada')
            else if (mapOldObj.get(accion.id).SAC_Estado__c != accion.SAC_Estado__c && accion.SAC_Estado__c == 'SAC_Finalizada') {

                //Si el campo SAC_Pretension__c está vacío, es una tarea de reclamación
                if (String.isBlank(accion.SAC_Pretension__c)) {
                    listaAccionesReclamacion.add(accion);        
                    listaIdsRecPretPadres.add(accion.SAC_Reclamacion__c);
                } else { //De lo contrario, es una tarea de pretensión
                    listaAccionesPretension.add(accion);
                    listaIdsRecPretPadres.add(accion.SAC_Pretension__c);
                }
            }
        }

        if (!listaIdsRecPretPadres.isEmpty()) {
            List<Case> listaRecPretPadres = [SELECT Id, OwnerId, SEG_Grupo__r.SAC_Email__c FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACION OR RecordTypeId = :RECTYPEPRETENSION) AND Id IN :listaIdsRecPretPadres];

            if(!listaRecPretPadres.isEmpty()){
                listaWrapperAlerta = tratarAlertasTareaAtendida(listaRecPretPadres, listaAccionesReclamacion, listaAccionesPretension);
            }
        }

        //Si tenemos alertas que enviar, se llama al método que las envía
        if (!listaWrapperAlerta.isEmpty()) {
            SAC_Alertas.generarAlertas(listaWrapperAlerta);
        }
    }

    public static List<SAC_WrapperAlerta> tratarAlertasTareaAtendida(List<Case> listaRecPretPadres, List<SAC_Accion__c> listaAccionesReclamacion, List<SAC_Accion__c> listaAccionesPretension) {

        List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
        List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];

        //Convertimos la lista en mapa y procedemos a preparar las alertas  
        Map<Id, Case> mapaRecPretPadres = new Map<Id, Case>(listaRecPretPadres);

        //Si tenemos tareas de reclamación, preparamos las alertas para informar al gestor
        if (!listaAccionesReclamacion.isEmpty()) {
            for (SAC_Accion__c tarea : listaAccionesReclamacion) {
                if (mapaRecPretPadres.containsKey(tarea.SAC_Reclamacion__c)) {
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(tarea.SAC_Reclamacion__c,
                                                                        'SPV_010',
                                                                        'La tarea ' + tarea.Name + ' ha sido atendida. Ya puede revisarla.',
                                                                        mapaRecPretPadres.get(tarea.SAC_Reclamacion__c).OwnerId,
                                                                        '',
                                                                        tarea.Id,
                                                                        '');
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + tarea.Id;
                    //Si la reclamación padre de la tarea está en pendiente de asignar, le añadimos el email del grupo de la reclamación a la alerta (si no está vacío)
                    if (mapaRecPretPadres.get(tarea.SAC_Reclamacion__c).OwnerId == cola[0].Id && String.isNotBlank(mapaRecPretPadres.get(tarea.SAC_Reclamacion__c).SEG_Grupo__r.SAC_Email__c)) {
                        wrapAlerta.listaEmailsGrupo.add(mapaRecPretPadres.get(tarea.SAC_Reclamacion__c).SEG_Grupo__r.SAC_Email__c);
                    }
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                }  
            }
        }

        //Si tenemos tareas de pretensión, preparamos las alertas para informar al letrado
        if (!listaAccionesPretension.isEmpty()) {
            for (SAC_Accion__c tarea : listaAccionesPretension) {
                if (mapaRecPretPadres.containsKey(tarea.SAC_Pretension__c)) {
                    SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(tarea.SAC_Reclamacion__c,'SPV_010','La tarea ' + tarea.Name + ' ha sido atendida. Ya puede revisarla.',mapaRecPretPadres.get(tarea.SAC_Pretension__c).OwnerId,tarea.SAC_Pretension__c,tarea.Id,'');
                                                                        wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + tarea.Id;
                    //Si la pretensión padre de la tarea está en pendiente de asignar, le añadimos el email del grupo de la pretensión a la alerta (si no está vacío)
                    if (mapaRecPretPadres.get(tarea.SAC_Pretension__c).ownerId == cola[0].Id && String.isNotBlank(mapaRecPretPadres.get(tarea.SAC_Pretension__c).SEG_Grupo__r.SAC_Email__c)) {
                        wrapAlerta.listaEmailsGrupo.add(mapaRecPretPadres.get(tarea.SAC_Pretension__c).SEG_Grupo__r.SAC_Email__c);
                    }
                    //Añadirla a la lista para posteriormente llamar al método
                    listaWrapperAlerta.add(wrapAlerta);
                }
                
            }
        }

        return listaWrapperAlerta;
    }

    /**************************************************************************
     * Proposito: Al finalizar una tarea, comprueba si su maestro es de tipo cambio de estado, en caso afirmativo, la reclamcion cambia de estado al indicado por el maestro
     ***************************************************************************
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --             Raúl Santos     11/04/25       Creación
    *****************************************************************************/
    public static void comprobarTareaFinalizada(Set<Id> idsTareasFinalizadas){

        List<SAC_Accion__c> listTareas = [SELECT Id, SAC_MaestroAccionesReclamacion__r.SAC_tipo_formulario__c, SAC_Reclamacion__c, SAC_MaestroAccionesReclamacion__r.SPV_EstadoAlFinalizar__c FROM SAC_Accion__c WHERE (RecordTypeId = :RECTYPEMAESTROTAREAS OR RecordTypeId = :RECTYPEACCION) AND Id IN : idsTareasFinalizadas];

        if(!listTareas.isEmpty()){
            Map<Id, String> mapRecEstado = new Map<Id, String>();

            //Recorro las tareas finalizadas, si es una tarea cuyp maestro es de cambio de estado, la añado al mapa para posteriormente actualizar la reclamación
            for(SAC_Accion__c tarea : listTareas){
                if(tarea.SAC_MaestroAccionesReclamacion__r.SAC_tipo_formulario__c == 'Cambio de estado'){
                    if(!mapRecEstado.containsKey(tarea.SAC_Reclamacion__c)){
                        mapRecEstado.put(tarea.SAC_Reclamacion__c, tarea.SAC_MaestroAccionesReclamacion__r.SPV_EstadoAlFinalizar__c);
                    }
                }
            }

            if(!mapRecEstado.isEmpty()){

                List<Case> listRecs = [SELECT Id, Status FROM Case WHERE RecordTypeId = :RECTYPERECLAMACION AND Id IN :mapRecEstado.keySet()];

                if(!listRecs.isEmpty()){
                    for(Case caso : listRecs){
                        if(mapRecEstado.containsKey(caso.Id)){
                            caso.Status = mapRecEstado.get(caso.Id);
                        }
                    }

                    SAC_DatabaseDML.updateListDML(listRecs, true);
                }
            }
        }
    }
}