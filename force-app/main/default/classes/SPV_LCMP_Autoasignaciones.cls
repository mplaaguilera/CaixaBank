/*****************************************************************
 * Name: SPV_LCMP_Autoasignaciones
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Clase apex controladora del LWC spv_AutoasignacionesCmp.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             US912956      Raúl Santos    13/05/24        Creación
****************************************************************/ 

public with sharing class SPV_LCMP_Autoasignaciones {

    public class SPVException extends Exception {}

    private static Set<String> objetos = new Set<String>{'Case', 'CC_Grupo_Colaborador__c', 'SAC_Interaccion__c','SAC_Accion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPECONSULTA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Consulta').getRecordTypeId();
    private static final Id RECTYPEESCALADO = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();
    private static final Id RECTYPEOTRASTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SPV_Acciones').getRecordTypeId();
    private static final Id RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SPV_MaestroDeTareas').getRecordTypeId();
    private static final Id RECTYPEGESTORES = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoGestor').getRecordTypeId();
    private static final Id RECTYPELETRADOS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoLetrado').getRecordTypeId();
    private static final Id RECTYPETAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();

    private static final String OBJ_CASO = 'Case';
    private static final String OBJ_ACCION = 'SAC_Accion__c';
    private static final String OBJ_INTERACCION = 'SAC_Interaccion__c';
   

    /*****************************************************************
     * Proposito: Dependiendo del tipo de objeto en el que se encuentre el componnete (Caso, Accion, Interaccion) derivamos la ejecución a un método u otro.
     *            Además devolveremos un boolean al LWC con valor true en caso de que se realice la autoasignación. False en caso contrario.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US912956      Raúl Santos    13/05/24        Creación
    *****************************************************************/
    @AuraEnabled
    public static Boolean autoasignarPropiedad(String objectType, Id recordId, Id usuarioActualId){

        if (objectType == OBJ_CASO) {
            return autoasignarCaso(recordId, usuarioActualId);
        } 
        else if (objectType == OBJ_ACCION) {
            return autoasignarAccion(recordId, usuarioActualId);
        } 
        else if (objectType == OBJ_INTERACCION) {
            return autoasignarInteraccion(recordId, usuarioActualId);
        }

        return false;
    }

    /*****************************************************************
     * Proposito: Métodos que comprueban la autoasignación para los diferentes objetos (Case, Accion, Interaccion). Si el Owner actual es la cola Pte. ASignar, comprueba si el usuario actual (el usuario de la ejecución)
     *            pertenece al grupo del correspondiente registro. En caso afirmatico se asigna a este usuario como propietario del registro.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US912956      Raúl Santos    13/05/24        Creación
    *****************************************************************/
    private static Boolean autoasignarCaso(String recordId, String usuarioActualId) {

        if(!Schema.sObjectType.Case.isAccessible()){ throw new SPVException( 'No puede recuperar el caso' ); }
        Case caso = [SELECT Id, OwnerId, SEG_Grupo__C FROM Case WHERE RecordTypeId = :RECTYPERECLAMACION AND Id = :recordId LIMIT 1];

        if(!Schema.sObjectType.Group.isAccessible()){ throw new SPVException( 'No puede recuperar la cola' ); }
        Group colaPteAsignar = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];

        //Si el owner del caso es diferente del actual y el owner del caso es la cola 'Pte Asignar'
        if(caso.OwnerId != usuarioActualId && caso.OwnerId == colaPteAsignar.Id){

            //Comprobamos si el usuario actual pertenece al grupo del caso como colaborador 
            if(!Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isAccessible()){ throw new SPVException( 'No puede recuperar los colaboradores' ); }
            List<CC_Grupo_Colaborador_Contact__c> listColaboradorGrupo = [SELECT id FROM CC_Grupo_Colaborador_Contact__c WHERE (CC_Grupo_Colaborador__r.RecordTypeId = :RECTYPEGESTORES OR  CC_Grupo_Colaborador__r.RecordTypeId = :RECTYPELETRADOS
                            OR CC_Grupo_Colaborador__r.RecordTypeId = :RECTYPETAREAS) AND CC_Grupo_Colaborador__c = :caso.SEG_Grupo__c AND CC_Usuario__c = :usuarioActualId LIMIT 1]; 

            //Si es colaborador del grupo del caso, lo asignamos como propietario
            if(!listColaboradorGrupo.isEmpty()){
                caso.OwnerId = usuarioActualId;

                if (!Schema.sObjectType.Case.isUpdateable()) { throw new SPVException( 'No tienes permisos para actualizar el caso.' ); }
                SPV_DatabaseDML.updateDML(caso, false);

                // SPV_RecuperarDocumentosController.recuperarTicketERR(caso.Id);

                return true;
            }
        }
     
        return false;
    }

    
    private static Boolean autoasignarAccion(String recordId, String usuarioActualId) {

        if(!Schema.sObjectType.SAC_Accion__c.isAccessible()){ throw new SPVException( 'No puede recuperar la tarea' ); }
        SAC_Accion__c accion = [SELECT Id, OwnerId, SAC_EquipoResponsable__c, SAC_Estado__c FROM SAC_Accion__c WHERE (RecordTypeId = :RECTYPEOTRASTAREAS OR RecordTypeId = :RECTYPEMAESTROTAREAS) AND Id = :recordId LIMIT 1];

        if(!Schema.sObjectType.Group.isAccessible()){ throw new SPVException( 'No puede recuperar la cola' ); }
        Group colaPteAsignar = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];

        //Si el owner de la tarea es diferente del actual y el owner de la tarea es la cola 'Pte Asignar' y el estado de la tarea es Pte Asignar
        if(accion.OwnerId != usuarioActualId && accion.OwnerId == colaPteAsignar.Id && accion.SAC_Estado__c == 'SAC_PendienteAsignar'){
            //Comprobamos si el usuario actual pertenece al grupo de la tarea como colaborador
            if(!Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isAccessible()){ throw new SPVException( 'No puede recuperar los colaboradores' ); }
            List<CC_Grupo_Colaborador_Contact__c> listColaboradorGrupo = [SELECT id FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__r.RecordTypeId = :RECTYPETAREAS AND CC_Grupo_Colaborador__c = :accion.SAC_EquipoResponsable__c AND CC_Usuario__c = :usuarioActualId LIMIT 1]; 

            //Si es colaborador del grupo de la tarea, lo asignamos como propietario
            if(!listColaboradorGrupo.isEmpty()){
                accion.OwnerId = usuarioActualId;
                accion.SAC_Estado__c = 'SAC_EnGestion';

                if (!Schema.sObjectType.SAC_Accion__c.isUpdateable()) { throw new SPVException( 'No tienes permisos para actualizar la tarea.' ); }
                SPV_DatabaseDML.updateDML(accion, false);

                return true;
            }
        }
     
        return false;
    }
    

    private static Boolean autoasignarInteraccion(String recordId, String usuarioActualId) {

        if(!Schema.sObjectType.SAC_Interaccion__c.isAccessible()){ throw new SPVException( 'No puede recuperar la interaccion' ); }
        SAC_Interaccion__c interaccion = [SELECT Id, OwnerId, SAC_GrupoColaborador__c, SAC_Estado__c FROM SAC_Interaccion__c WHERE (RecordTypeId = :RECTYPEESCALADO OR RecordTypeId= :RECTYPECONSULTA) AND Id = :recordId LIMIT 1];

        if(!Schema.sObjectType.Group.isAccessible()){ throw new SPVException( 'No puede recuperar la cola' ); }
        Group colaPteAsignar = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];

        //Si el owner de la interaccion es diferente del actual y el owner de la interaccion es la cola 'Pte Asignar' y el estado de la interaccion es Pte Asignar
        if(interaccion.OwnerId != usuarioActualId && interaccion.OwnerId == colaPteAsignar.Id && interaccion.SAC_Estado__c == 'SAC_PendienteRespuesta'){
            //Comprobamos si el usuario actual pertenece al grupo de la interaccion como colaborador
            if(!Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isAccessible()){ throw new SPVException( 'No puede recuperar los colaboradores' ); }
            List<CC_Grupo_Colaborador_Contact__c> listColaboradorGrupo = [SELECT id FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__r.RecordTypeId = :RECTYPETAREAS AND CC_Grupo_Colaborador__c = :interaccion.SAC_GrupoColaborador__c AND CC_Usuario__c = :usuarioActualId LIMIT 1]; 

            //Si es colaborador del grupo de la interaccion, lo asignamos como propietario
            if(!listColaboradorGrupo.isEmpty()){
                interaccion.OwnerId = usuarioActualId;

                if (!Schema.sObjectType.SAC_Interaccion__c.isUpdateable()) { throw new SPVException( 'No tienes permisos para actualizar la interaccion.' ); }
                SPV_DatabaseDML.updateDML(interaccion, false);

                return true;
            }
        }
     
        return false;
    }
}