/*****************************************************************************************
 * Name: SAC_LCMP_InsertarConsulta
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controlador  para poder insertar consultas
 * Principal objetivo: Insertar una consulta dentro de un caso.
 * LWC asociado: sAC_InsertarPretension
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE          Description
 * 1.0            US21970          Esteve Llaó    30/06/21      Creación Clase
******************************************************************************************/

public with sharing class SAC_LCMP_InsertarConsulta {

    private static Set<String> objetos = new Set<String>{'SAC_Accion__c','SAC_Interaccion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_MaestroDeTareas').getRecordTypeId();
    private static final Id RECTYPEOTRASTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SAC_OtrasTareas').getRecordTypeId();
    private static final Id RECTYPECONSULTA = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_Consulta').getRecordTypeId();

    /*********************************************************************************************
     * Proposito: Método para insertar consultas en el sistema
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0            US21970          Esteve Llaó    30/06/21      Creación Clase      
    *********************************************************************************************/
    @AuraEnabled
    public static String insertarConsulta(String consultaId){

        SAC_Interaccion__c consulta = new SAC_Interaccion__c();
        consulta.RecordTypeId = RECTYPECONSULTA;
        consulta.SAC_Reclamacion__c = consultaId;

        try {
            Database.insert(consulta);
            return consulta.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /********************************************************************************************************
    * Proposito: Comprobar si puede tener el permiso de crear una nueva Consulta
    *            Se llama desde el LWC sacInsertarConsulta (Objeto Interacción)
    *            Comprueba si el usuario es miembro del grupo al que se ha realizado una 
    *            consulta interna anteriomente en la reclamación
    * ******************************************************************************
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR           DATE         Description
    * 1.0            US542611      Sergio Martín    11/05/2023       Creación
    * 1.1            US607734       Raúl Santos     23/06/2023       Modificación: Añadido wrapper para retornar los permisos, y comprobar si el usuario es miembro del grupo al que se ha realizado una 
    *                                                                              tarea anteriomente en la reclamación, para en caso afirmativo, dar permisos a este para crear consultas
    *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static PermisosUsuariosWrapper tienePermisosGrupo(String idCaso){ 
        Boolean tienePermisoGrupo= false;    
        Boolean tienePermisoTareas= false;    
        try {
            //Obtenemos las consultas internas que se han realizado en la reclamación.            
            List<SAC_Interaccion__c> interacciones = [SELECT Id, SAC_Reclamacion__c,SAC_GrupoColaborador__c,SAC_Estado__c, RecordTypeId, SAC_GrupoColaborador__r.SAC_DeveloperName__c, 
                                                    SAC_GrupoColaborador__r.SAC_Externo__c, SAC_GrupoColaborador__r.SAC_PermiteConsultas__c
                                                    FROM SAC_Interaccion__c
                                                    WHERE RecordTypeId = :RECTYPECONSULTA AND SAC_Reclamacion__c = :idCaso];

            //Obtenemos las acciones que se han realizado en la reclamación.
            if(!Schema.sObjectType.SAC_Accion__c.isAccessible()){ throw new AuraHandledException( 'No puede recuperar las tareas de la reclamación.' ); }
            List<SAC_Accion__c> acciones = [SELECT Id, SAC_EquipoResponsable__c, SAC_EquipoResponsable__r.SAC_PermiteTareas__c FROM SAC_Accion__c
                                            WHERE (RecordTypeId = :RECTYPEMAESTROTAREAS OR RecordTypeId = :RECTYPEOTRASTAREAS) AND SAC_Reclamacion__c = :idCaso];

            // Select de los grupos pertenecientes del usuario
            List<CC_Grupo_Colaborador__c> listaGrupos = [SELECT id, SAC_PermiteConsultas__c , SAC_DeveloperName__c, SAC_Externo__c, SAC_TienePropietario__c, SAC_PermiteTareas__c FROM CC_Grupo_Colaborador__c 
                                                         WHERE id IN (SELECT CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =: UserInfo.getUserId())];

            if (!listaGrupos.isEmpty()) {
                Map<Id, CC_Grupo_Colaborador__c> mapaGrupos = new Map<Id, CC_Grupo_Colaborador__c>(listaGrupos);
                for (SAC_Interaccion__c consulta : interacciones) {
                    //Si el grupo de la consulta NO es oficina el grupo NO es externo y es un grupo que permite consultas se debe asignar la propiedad de la consulta a la cola
                    if (mapaGrupos.containsKey(consulta.SAC_GrupoColaborador__c) && mapaGrupos.get(consulta.SAC_GrupoColaborador__c).SAC_DeveloperName__c != 'OFICINA' 
                            && mapaGrupos.get(consulta.SAC_GrupoColaborador__c).SAC_Externo__c == false && mapaGrupos.get(consulta.SAC_GrupoColaborador__c).SAC_PermiteConsultas__c == true
                            && mapaGrupos.get(consulta.SAC_GrupoColaborador__c).SAC_TienePropietario__c == true) {        
                        tienePermisoGrupo=true;
                        break;    
                    }
                }

                //US607734 - Recorremos las acciones, para comprobar si el usuario actual pertenece al grupo de alguna de estas.
                for (SAC_Accion__c accion : acciones) {
                    //Si el grupo de la tarea es un grupo que pertenece el usuario, le damos permisos para crear nuevas tareas
                    if (mapaGrupos.containsKey(accion.SAC_EquipoResponsable__c) && mapaGrupos.get(accion.SAC_EquipoResponsable__c).SAC_PermiteTareas__c == true && mapaGrupos.get(accion.SAC_EquipoResponsable__c).SAC_PermiteTareas__c == true) {     
                        tienePermisoTareas=true;
                        break;  
                    }
                }
            }            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        PermisosUsuariosWrapper permisosWrapper = new PermisosUsuariosWrapper(tienePermisoGrupo, tienePermisoTareas);
        return permisosWrapper;
    }


    /*****************************************************************
     * Name: PermisosUsuariosWrapper
     * Copyright © 2021  CaixaBank
     *                                                                                        
     * Proposito: Clase Wrapper para mandar contenido formateado del controlador Apex al controlador JS para el correcto funcionamiento
     *  del Lightning Web Component: sac_insertarConsulta.
     *                                                                                        
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US607734       Raúl Santos    23/06/23       Creación
    *****************************************************************/

    public class PermisosUsuariosWrapper{

        @AuraEnabled public Boolean tienePermisosGrupo {get; set;}
        @AuraEnabled public Boolean tienePermisosAccion {get; set;}

        public PermisosUsuariosWrapper(Boolean tienePermisoGrupoActual, Boolean tienePermisosAccionActual)
        {
            tienePermisosGrupo = tienePermisoGrupoActual;
            tienePermisosAccion = tienePermisosAccionActual;
        }
    }
}