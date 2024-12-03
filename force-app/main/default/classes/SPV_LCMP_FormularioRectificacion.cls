public with sharing class SPV_LCMP_FormularioRectificacion {
    private static Set<String> objetos = new Set<String>{'Case','SPV_Formulario__c', 'CC_Grupo_Colaborador__c'};

    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    private static final Id RECTYPEFORMULARIO = mapRTsObjects.get('SPV_Formulario__c').get('SPV_FormularioRectificacion').getRecordTypeId();
    private static final Id RECORDTYPEGRUPOLET = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoLetrado').getRecordTypeId();


    /*****************************************************************************
    * Proposito: Comprueba si hay algún formulario en la reclamación que no se haya decidido pasar al estado de rectificar/No rectificar
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             -               Carlos Gómez   17/10/24        Creación
    *****************************************************************************/
    @AuraEnabled(cacheable=true)
    public static String getFormularioExistente(String casoId) {
        if(Schema.sObjectType.SPV_Formulario__c.isAccessible()) {
            List<SPV_Formulario__c> listaFormularios = [SELECT Id, SPV_RectificacionCompletada__c FROM SPV_Formulario__c WHERE RecordTypeId = :RECTYPEFORMULARIO AND SPV_Caso__c = :casoId];
            if (!listaFormularios.isEmpty()) {
                for(SPV_Formulario__c rectificacion: listaFormularios){
                    if(rectificacion.SPV_RectificacionCompletada__c == false){
                        return rectificacion.id;
                    }
                }
            }
        }
        return null;
    }
    /*****************************************************************************
    * Proposito: Obtiene todas las rectificaciones que tienen marcado el check de SPV_RectificacionCompletada__c 
    *              para mostrarlas en la tabla
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             -               Carlos Gómez   18/10/24        Creación
    *****************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<SPV_Formulario__c> getRectificacionesAnteriores(String casoId) {
        if(Schema.sObjectType.SPV_Formulario__c.isAccessible()) {
            List<SPV_Formulario__c> listaRectificaciones = [SELECT SPV_FechaRectificacion__c, SPV_PropuestaRectificacion__c, SPV_InstruccionesRect__c FROM SPV_Formulario__c WHERE RecordTypeId = :RECTYPEFORMULARIO AND SPV_Caso__c = :casoId AND SPV_RectificacionCompletada__c = true];
            if (!listaRectificaciones.isEmpty()) {    
                return listaRectificaciones;           
            }
        }
        return null;
    }
    /*****************************************************************************
    * Proposito: Comprobar si el usuario que modifica el formulario pertenece al grupo Letrado
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             -               Carlos Gómez   22/10/24        Creación
    *****************************************************************************/
    @AuraEnabled
    public static Boolean compruebaLetradoSPV(Id caseId) {
        Boolean tienePermiso = false;

        Case casoActual = [SELECT SAC_GrupoLetrado__c, RecordTypeId FROM Case WHERE Id = :caseId];
        User usuario = [SELECT Id, SAC_GruposPerteneciente__c FROM user WHERE Id =: UserInfo.getUserId()];

        List<String> idList = usuario.SAC_GruposPerteneciente__c.split(';');

        List<CC_Grupo_Colaborador__c> listGrupos = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE RecordTypeId = :RECORDTYPEGRUPOLET AND Id IN :idList];
        for(CC_Grupo_Colaborador__c grupo : listGrupos){
            if(grupo.Id == casoActual.SAC_GrupoLetrado__c){
                tienePermiso = true;
            }
        }
        return tienePermiso;
    }

}