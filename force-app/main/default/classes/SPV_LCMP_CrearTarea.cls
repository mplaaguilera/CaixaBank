/***************************************************************** 
 * Name: SPV_LCMP_EscaladoOperativas
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Controlador del componente spv_CrearTarea
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            --------         CS             21/06/2024   Creación
*****************************************************************/
public with sharing class SPV_LCMP_CrearTarea {
    //Obtención record types
    private static Set<String> objetos = new Set<String>{'Case', 'SAC_Accion__c', 'CC_Grupo_Colaborador__c', 'SAC_MaestroAccionesReclamacion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION =  mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION =  mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    private static final Id RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SPV_MaestroDeTareas').getRecordTypeId();
    private static final Id RECTYPEOTRASTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SPV_Acciones').getRecordTypeId();
    private static final Id RECTYPEGRUPODETAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();
    private static final Id RECTYPEMAESTROACCIONESREC = mapRTsObjects.get('SAC_MaestroAccionesReclamacion__c').get('SPV_MaestroAcciones').getRecordTypeId();


    /********************************************************************************************************
     * Proposito: Comprobar si puede tener el permiso de crear una nueva tarea
     *            Comprueba desde el caso en el que operamos si es una reclamación o pretensión para
     *            posteriormente comprobar si el usuario es el owner del caso o de una de las pretensiones
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            --------         CS             21/06/2024   Creación      
    *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static Boolean tienePermisos(String idCaso){ 

        Boolean tienePermiso= false;      

        try {
            List<Case> casos = new List<Case>();
            String idUsuario = UserInfo.getUserId();

            if(!Schema.sObjectType.Case.isAccessible()){ throw new AuraHandledException( 'No puede recuperar el caso.' ); }
            casos = [SELECT Id, OwnerId, SAC_Reclamacion__c, SAC_Reclamacion__r.OwnerId, SAC_PretensionPrincipal__r.OwnerId, Status FROM Case WHERE (RecordTypeId =:RECTYPEPRETENSION OR RecordTypeId =:RECTYPERECLAMACION) AND Id =: idCaso];

            if(!casos.isEmpty()){
                // Comprobamos si el usuario es propietario de la reclamación o pretensión
                for (Case caso : casos) {
                    if((caso.OwnerId == idUsuario || caso.SAC_PretensionPrincipal__r.OwnerId == idUsuario || caso.SAC_Reclamacion__r.OwnerId == idUsuario)/* && !caso.Status.equals('SAC_014')*/){
                        tienePermiso=true;
                        return tienePermiso;
                    } 
                }

                // Si el usuario no es propietario de la reclamación/pretensión comprobamos si pertenece al/os grupos responsables de las tareas creadas en la reclamación/pretensión
                if(tienePermiso == false){
                    //Obtenemos las acciones que se han realizado en la reclamación.
                    if(!Schema.sObjectType.SAC_Accion__c.isAccessible()){ throw new AuraHandledException( 'No puede recuperar las tareas de la reclamación.' ); }
                    List<SAC_Accion__c> acciones = [SELECT Id, SAC_EquipoResponsable__c, SAC_EquipoResponsable__r.SAC_PermiteTareas__c FROM SAC_Accion__c
                            WHERE (RecordTypeId = :RECTYPEMAESTROTAREAS OR RecordTypeId = :RECTYPEOTRASTAREAS) AND (SAC_Reclamacion__c = :idCaso OR SAC_Pretension__c = :idCaso)];

                    // Select de los grupos pertenecientes del usuario
                    if(!Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible() || !Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isAccessible()){ throw new AuraHandledException( 'No puede recuperar los grupos a los que pertenece su usuario' ); }
                    List<CC_Grupo_Colaborador__c> listaGrupos = [SELECT id, SAC_PermiteTareas__c FROM CC_Grupo_Colaborador__c WHERE id IN (SELECT CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c = :idUsuario)];

                    tienePermiso = tienePermisosGrupoAccion(acciones, listaGrupos);
                    return tienePermiso;
                }
            }  
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return tienePermiso;
    }

    /*********************************************************************************************
     * Proposito: Comprobar si puede tener el permiso de crear una nueva tarea
     *            Comprueba si el usuario es miembro de los grupos responsables de las tareas creadas en la reclamación/pretensión.
     *            En caso de serlo dentro de la reclamación/pretensión  puede crear una nueva Tareas
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0            --------         CS             21/06/2024    Creación    
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

    /*********************************************************************************************
     * Proposito: Recoger los grupos que cumplan las condiciones de record type SPV_GrupoDeTareas y
     *            permiten tareas para posteriormente mostrarlos en el combobox y trabajar con ellos.
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0            --------         CS             21/06/2024    Creación    
    *********************************************************************************************/
    @AuraEnabled
    public static List<CC_Grupo_Colaborador__c> camposRequeridos(String caseId, String tipoTarea){

        List<CC_Grupo_Colaborador__c> listagrupos = new List<CC_Grupo_Colaborador__c>();
        
        if(tipoTarea.equals('OtrasTareas')){
            listagrupos = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :RECTYPEGRUPODETAREAS
                            AND SAC_PermiteTareas__c = true ORDER BY Name ASC];
        }

        if(!listagrupos.isEmpty()){
            return listagrupos;  
        }else{
            return null;
        }
    }

     /*********************************************************************************************
    * Proposito: Recoger los Maestro Acciones Reclamaciones que cumplan las condiciones de record type SPV_MaestroAcciones y
     *           esten activos para posteriormente mostrarlos en el combobox y trabajar con ellos.
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0            --------         CS             21/06/2024    Creación    
    *********************************************************************************************/
    @AuraEnabled
    public static List<SAC_MaestroAccionesReclamacion__c> camposRequeridosMaestro(String caseId, String tipoTarea){

        List<SAC_MaestroAccionesReclamacion__c> listagrupos = new List<SAC_MaestroAccionesReclamacion__c>();
        
        if(tipoTarea.equals('MaestroTareas')){
            listagrupos = [SELECT Id, Name FROM SAC_MaestroAccionesReclamacion__c WHERE RecordTypeId = :RECTYPEMAESTROACCIONESREC AND SAC_Activo__c = true ORDER BY Name ASC];  
        }

        if(!listagrupos.isEmpty()){
            return listagrupos;  
        }else{
            return null;
        }
    }

     /*********************************************************************************************
     * Proposito: Método para insertar tareas en el sistema, diferenciando si se trata de Otra Tarea o Maestro de Tareas
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0            --------         CS             21/06/2024    Creación    
    *********************************************************************************************/
    @AuraEnabled
    public static String insertarTarea(String tareaId, String descripcion, String equipoResponsableId, Boolean esMaestroOrOtras){
        
        Case caso = [SELECT Id, RecordTypeId, SAC_Reclamacion__c FROM Case WHERE Id =: tareaId];   
        SAC_Accion__c tarea = new SAC_Accion__c();

        // esMaestroOrOtras viene con valor true en caso de ser Otras Tareas
        if(esMaestroOrOtras == true){
            tarea.RecordTypeId = RECTYPEOTRASTAREAS;

            // Rellenar los campos SAC_Reclamacion y SAC_Pretension dependiendo desde dondes se crea la tarea
            if(caso.RecordTypeId ==  RECTYPERECLAMACION){
                tarea.SAC_Reclamacion__c = tareaId;
            }
            if(caso.RecordTypeId ==  RECTYPEPRETENSION){
                tarea.SAC_Pretension__c = tareaId;
                tarea.SAC_Reclamacion__c = caso.SAC_Reclamacion__c;
            }
            
            tarea.SAC_Descripcion__c = descripcion;
            tarea.SAC_EquipoResponsable__c = equipoResponsableId;
            try {
                if (!Schema.sObjectType.SAC_Accion__c.isCreateable()) { throw new AuraHandledException( 'No tienes permisos para realziar esta accion.' ); }
                Database.insert(tarea);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        // esMaestroOrOtras viene con valor false en caso de ser Maestro de Tareas
        if(esMaestroOrOtras == false){
            tarea.RecordTypeId = RECTYPEMAESTROTAREAS;

            // Rellenar los campos SAC_Reclamacion y SAC_Pretension dependiendo desde dondes se crea la tarea
            if(caso.RecordTypeId ==  RECTYPERECLAMACION){
                tarea.SAC_Reclamacion__c = tareaId;
            }
            if(caso.RecordTypeId ==  RECTYPEPRETENSION){
                tarea.SAC_Pretension__c = tareaId;
                tarea.SAC_Reclamacion__c = caso.SAC_Reclamacion__c;
            }

            tarea.SAC_MaestroAccionesReclamacion__c = equipoResponsableId;
            try {
                if (!Schema.sObjectType.SAC_Accion__c.isCreateable()) { throw new AuraHandledException( 'No tienes permisos para realziar esta accion.' ); }
                Database.insert(tarea);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        return tarea.Id;
    }
}