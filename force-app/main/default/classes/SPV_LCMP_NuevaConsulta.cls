/*****************************************************************************************
 * Name: SPV_LCMP_NuevaConsulta
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controlador  para poder insertar consultas
 * Principal objetivo: Insertar una consulta dentro de un caso.
 * LWC asociado: spv_NuevaConsulta
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE          Description
 * 1.0             US945746     Raúl Santos     18/06/24         Creación
******************************************************************************************/

public with sharing class SPV_LCMP_NuevaConsulta {

    private static Set<String> objetos = new Set<String>{'SAC_Interaccion__c', 'Case', 'CC_Grupo_Colaborador__c','SAC_Accion__c','SAC_ImagenDocumento__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SPV_MaestroDeTareas').getRecordTypeId();
    private static final Id RECTYPEOTRASTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SPV_Acciones').getRecordTypeId();
    private static final Id RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    private static final Id RECTYPECONSULTA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Consulta').getRecordTypeId();
    private static final Id RECTYPECONSULTA_TAREA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_ConsultaTarea').getRecordTypeId();
    private static final Id RECTYPEGRUPOTAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();
    private static final Id RECTYPEOFICINAS = mapRTsObjects.get('SAC_ImagenDocumento__c').get('SPV_OficinaAfectada').getRecordTypeId();



    /*********************************************************************************************
     * Proposito: Método para insertar consultas en la reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US945746     Raúl Santos     18/06/24         Creación
    *********************************************************************************************/
    @AuraEnabled
    public static String insertarConsulta(String idRegistro, String grupoId, String idOficina, String tipoRegistro){

        SAC_Interaccion__c consulta = new SAC_Interaccion__c();
        consulta.SAC_GrupoColaborador__c = grupoId;
        if(String.isNotBlank(idOficina)){
            Account oficina = [SELECT Id, CC_Email__c FROM Account WHERE Id = :idOficina LIMIT 1];
            consulta.SAC_Oficina__c = oficina.Id;
            consulta.SAC_EmailOficina__c = oficina.CC_Email__c;
        }

        if(tipoRegistro == 'Case'){
            consulta.RecordTypeId = RECTYPECONSULTA;
            consulta.SAC_Reclamacion__c = idRegistro;
        }else if(tipoRegistro == 'SAC_Accion__c'){
            consulta.RecordTypeId = RECTYPECONSULTA_TAREA;
            consulta.SPV_TareaRelacionada__c = idRegistro;
        }        

        try {
            SPV_DatabaseDML.insertDML(consulta, true);
            return consulta.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

     /********************************************************************************************************
    * Proposito: Comprobar si el usuario tiene permisos para crear una nueva consulta
    *            Comprueba si el usuario es propietario de la reclamación o de sus pretensiones
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE          Description
    * 1.0             US945746     Raúl Santos     18/06/24         Creación
    *
    *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static Boolean tienePermisos(String idRegistro, String tipoRegistro){ 
        Boolean tienePermiso= false;      

        try {
            if(tipoRegistro == 'Case'){
                if(!Schema.sObjectType.Case.isAccessible()){ throw new AuraHandledException( 'No puede recuperar el caso.' ); }
                List<Case> listCasos = [SELECT Id, OwnerId, RecordTypeId FROM Case WHERE (RecordTypeId = :RECORDTYPERECLAMACION OR RecordTypeId = :RECORDTYPEPRETENSION) AND (Id = :idRegistro OR SAC_Reclamacion__c = :idRegistro)];

                if(!listCasos.isEmpty()){
                    String idUsuario = UserInfo.getUserId();
                    String idReclamacion = '';

                    // Comprobamos si el usuario es propietario de la reclamación o pretensión
                    for (Case caso : listCasos) {
                        if(caso.OwnerId == idUsuario){
                            tienePermiso=true;
                            return tienePermiso;
                        }
                        if(caso.RecordTypeId == RECORDTYPERECLAMACION){
                            idReclamacion = caso.Id;
                        }
                    }

                    // Si el usuario no es propietario de la reclamación/pretensión comprobamos es miembro del grupo al que se ha realizado una consulta interna anteriomente en la reclamación o es miembro del grupo al que se ha realizado una tarea anteriomente 
                    if(tienePermiso == false){
                        tienePermiso = tienePermisosGrupoConsultaOrAccion(idReclamacion);
                        return tienePermiso;
                    }
                }  
            }else if(tipoRegistro == 'SAC_Accion__c'){
                List<SAC_Accion__c> listAcciones = [SELECT Id, OwnerId FROM SAC_Accion__c WHERE RecordTypeId IN (:RECTYPEOTRASTAREAS, :RECTYPEMAESTROTAREAS) AND Id = :idRegistro LIMIT 1];

                if(!listAcciones.isEmpty() && listAcciones[0].OwnerId == UserInfo.getUserId()){
                    tienePermiso=true;
                    return tienePermiso;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return tienePermiso;
    }


    /********************************************************************************************************
    * Proposito: Comprobar si puede tener el permiso de crear una nueva Consulta
    *            Comprueba si el usuario es miembro del grupo al que se ha realizado una consulta interna anteriomente en la reclamación
    *            Comprueba si el usuario es miembro del grupo al que se ha realizado una tarea anteriomente en la reclamación, para en caso afirmativo, dar permisos a este para crear consultas
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE          Description
    * 1.0             US945746     Raúl Santos     18/06/24         Creación
    *****************************************************************/
    public static Boolean tienePermisosGrupoConsultaOrAccion(String idCaso){ 
        Boolean tienePermiso= false;

        try {
            //Obtenemos las consultas internas que se han realizado en la reclamación.      
            if(!Schema.sObjectType.SAC_Interaccion__c.isAccessible()){ throw new AuraHandledException( 'No puede recuperar las consultas.' ); }      
            List<SAC_Interaccion__c> interacciones = [SELECT Id, SAC_Reclamacion__c,SAC_GrupoColaborador__c,SAC_Estado__c, RecordTypeId, SAC_GrupoColaborador__r.SAC_DeveloperName__c, 
                                                    SAC_GrupoColaborador__r.SAC_Externo__c, SAC_GrupoColaborador__r.SAC_PermiteConsultas__c
                                                    FROM SAC_Interaccion__c
                                                    WHERE RecordTypeId = :RECTYPECONSULTA AND SAC_Reclamacion__c = :idCaso];

            //Obtenemos las acciones que se han realizado en la reclamación.
            // if(!Schema.sObjectType.SAC_Accion__c.isAccessible()){ throw new AuraHandledException( 'No puede recuperar las tareas de la reclamación.' ); }
            // List<SAC_Accion__c> acciones = [SELECT Id, SAC_EquipoResponsable__c, SAC_EquipoResponsable__r.SAC_PermiteTareas__c FROM SAC_Accion__c
            //                                 WHERE (RecordTypeId = :RECTYPEMAESTROTAREAS OR RecordTypeId = :RECTYPEOTRASTAREAS) AND SAC_Reclamacion__c = :idCaso];

            //Grupos pertenecientes del usuario actual
            if(!Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible()){ throw new AuraHandledException( 'No puede recuperar los grupos.' ); }      
            List<CC_Grupo_Colaborador__c> listaGrupos = [SELECT id, SAC_PermiteConsultas__c , SAC_DeveloperName__c, SAC_Externo__c, SAC_TienePropietario__c, SAC_PermiteTareas__c FROM CC_Grupo_Colaborador__c 
                                                         WHERE id IN (SELECT CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =: UserInfo.getUserId())];

            if (!listaGrupos.isEmpty()) {
                Map<Id, CC_Grupo_Colaborador__c> mapaGrupos = new Map<Id, CC_Grupo_Colaborador__c>(listaGrupos);

                //Recorremos las consultas para comprobar si el usuario actual pertenece al grupo de alguna de estas.
                for (SAC_Interaccion__c consulta : interacciones) {
                    //Si el grupo de la consulta es un grupo que pertenece el usuario, y NO es oficina el grupo, y NO es externo y es un grupo que permite consultas, le damos permisos para crear nuevas consultas
                    if (mapaGrupos.containsKey(consulta.SAC_GrupoColaborador__c) && mapaGrupos.get(consulta.SAC_GrupoColaborador__c).SAC_DeveloperName__c != 'OFICINA' 
                            && mapaGrupos.get(consulta.SAC_GrupoColaborador__c).SAC_Externo__c == false && mapaGrupos.get(consulta.SAC_GrupoColaborador__c).SAC_PermiteConsultas__c == true
                            && mapaGrupos.get(consulta.SAC_GrupoColaborador__c).SAC_TienePropietario__c == true) {        
                                tienePermiso = true;
                        break;    
                    }
                }

                //US607734 - Recorremos las acciones para comprobar si el usuario actual pertenece al grupo de alguna de estas.
                // for (SAC_Accion__c accion : acciones) {
                //     //Si el grupo de la tarea es un grupo que pertenece el usuario, le damos permisos para crear nuevas tareas
                //     if (mapaGrupos.containsKey(accion.SAC_EquipoResponsable__c) && mapaGrupos.get(accion.SAC_EquipoResponsable__c).SAC_PermiteTareas__c == true) {     
                //         tienePermiso = true;
                //         break;  
                //     }
                // }
            }            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return tienePermiso;
    }

    /**************************************************************************
     * Proposito: Obtener todas las consultas en estado pendiente de respuesta de un caso y las consultas sin grupo y sin pregunta informados
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US945746     Raúl Santos     23/07/24         Creación
    **************************************************************************/  
    @AuraEnabled
    public static List<SAC_Interaccion__c> getConsultas(String idRegistro, String ownerId) {
        List<SAC_Interaccion__c> consultasPendientes = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> consultas = new List<SAC_Interaccion__c>();

        try {
            if(ownerId == UserInfo.getUserId()){
                consultas = [SELECT id, Name, SAC_GrupoColaborador__c ,SAC_GrupoColaborador__r.Name, CreatedDate, SAC_FechaRespuesta__c, SAC_Pregunta__c, toLabel(SAC_Estado__c) FROM SAC_Interaccion__c  WHERE (RecordTypeId = :RECTYPECONSULTA AND SAC_Reclamacion__c =: idRegistro) OR (RecordTypeId = :RECTYPECONSULTA_TAREA AND SPV_TareaRelacionada__c =: idRegistro)];
                for(SAC_Interaccion__c consulta : consultas) {
                    if((consulta.SAC_Estado__c == 'Pendiente Respuesta' || consulta.SAC_Estado__c == 'Pendiente Respuesta Definitiva' || ((consulta.SAC_GrupoColaborador__c == null || String.isBlank(consulta.SAC_Pregunta__c)) && consulta.SAC_Estado__c != 'Finalizada'))) {
                        consultasPendientes.add(consulta);
                    }
                }
            }else{
                consultas = [SELECT id, Name, SAC_GrupoColaborador__c ,SAC_GrupoColaborador__r.Name, CreatedDate, toLabel(SAC_Estado__c), SAC_FechaRespuesta__c, SAC_Pregunta__c FROM SAC_Interaccion__c  WHERE (RecordTypeId = :RECTYPECONSULTA AND CreatedById =: Userinfo.getUserId() AND SAC_Reclamacion__c =: idRegistro) OR (RecordTypeId = :RECTYPECONSULTA_TAREA AND CreatedById =: Userinfo.getUserId() AND SPV_TareaRelacionada__c =: idRegistro)];
                for(SAC_Interaccion__c consulta : consultas) {
                    if((consulta.SAC_Estado__c == 'Pendiente Respuesta' || consulta.SAC_Estado__c == 'Pendiente Respuesta Definitiva' || ((consulta.SAC_GrupoColaborador__c == null || String.isBlank(consulta.SAC_Pregunta__c)) && consulta.SAC_Estado__c != 'Finalizada'))) {
                        consultasPendientes.add(consulta);
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return consultasPendientes;
    }

    /**************************************************************************
     * Proposito: Finaliza las consultas en estado pendiende de respuesta de un caso
     * 
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US945746     Raúl Santos     23/07/24         Creación
    **************************************************************************/  
    @AuraEnabled
    public static void finalizarConsultasCaso(String[] idConsultas, String motivo) {
        List<SAC_Interaccion__c> listaConsultasAFinalizar = [SELECT id, SAC_Estado__c, SAC_MotivoDeFinalizado__c FROM SAC_Interaccion__c  WHERE RecordTypeId IN (:RECTYPECONSULTA, :RECTYPECONSULTA_TAREA) AND Id IN: Idconsultas AND (SAC_Estado__c = 'SAC_PendienteRespuesta' OR SAC_Estado__c = 'SAC_PendienteRespuestaDefinitiva' OR SAC_Estado__c = '')];
        if (!listaConsultasAFinalizar.isEmpty()) {
            for (SAC_Interaccion__c consulta : listaConsultasAFinalizar) {
                consulta.SAC_Estado__c = 'SAC_Finalizada';
                consulta.SAC_MotivoDeFinalizado__c = motivo;
            }
            SPV_DatabaseDML.updateListDML(listaConsultasAFinalizar, false);
        }
    }

    /*
    * @description: Comprueba si el grupo seleccionado es una oficina y en caso afirmativo, compruebas las oficinas de la reclamación
    * @author: Raúl Sanatos
    * @date: 12 mayo 2025
    */
    @AuraEnabled
    public static List<SAC_ImagenDocumento__c> comprobarPosibleOficina(String idGrupo, String idRegistro){

        List<SAC_ImagenDocumento__c> oficinasReclamacion = new List<SAC_ImagenDocumento__c>();
        List<CC_Grupo_Colaborador__c> listaGrupos = [SELECT id, SAC_DeveloperName__c FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = : RECTYPEGRUPOTAREAS AND id = :idGrupo LIMIT 1];

        if(!listaGrupos.isEmpty() && listaGrupos[0].SAC_DeveloperName__c == 'OFICINA' ){
            oficinasReclamacion = [SELECT Id, SPV_OficinaAfectada_Lookup__c, SPV_OficinaAfectada_Lookup__r.Name FROM SAC_ImagenDocumento__c WHERE RecordTypeId = :RECTYPEOFICINAS AND SAC_Caso__c = :idRegistro AND SPV_OficinaAfectada_Lookup__c != null];
        }

        return oficinasReclamacion;
    }
}