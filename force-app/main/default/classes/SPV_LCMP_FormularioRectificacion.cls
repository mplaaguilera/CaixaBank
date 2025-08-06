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
        List<SPV_Formulario__c> listaFormularios = [
            SELECT Id FROM SPV_Formulario__c 
            WHERE SPV_Caso__c = :casoId 
            AND  RecordTypeId = :RECTYPEFORMULARIO 
            ORDER BY LastModifiedDate DESC 
            LIMIT 1
        ];
        return !listaFormularios.isEmpty() ? listaFormularios[0].Id : null;
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
        return [SELECT Id, SPV_FechaRectificacion__c, SPV_PropuestaRectificacionLetrado__c, 
                SPV_InstruccionesRect__c 
                FROM SPV_Formulario__c 
                WHERE RecordTypeId = :RECTYPEFORMULARIO 
                AND SPV_Caso__c = :casoId 
                AND SPV_RectificacionCompletada__c = true
                ORDER BY SPV_FechaRectificacion__c DESC];
    }
    return new List<SPV_Formulario__c>(); 
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



        /*********************************************************************************
    * Proposito: Recupera los campos deseados de las pretensiones 
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             --------     Pablo  Natera   07/05/25        Creación

    ************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Case> getPretensiones(String casoId) {
        List<Case> listaPretensiones = new List<Case>();
        if(Schema.sObjectType.Case.isAccessible()) {
            listaPretensiones = [
                SELECT Id, CaseNumber, Subject, SPV_CriterioBDEMateriaFuente__c, 
                    SPV_DecisionAllanamiento__c,
                    SAC_ResumenManual__c,
                    CC_Importe_Reclamado__c,
                    // Campos de Case Extension
                    CBK_Case_Extension_Id__c,
                    CBK_Case_Extension_Id__r.Id,
                    // Campos para Decisión Final
                    CBK_Case_Extension_Id__r.SPV_DecisionPretensionLetrado__c,
                    CBK_Case_Extension_Id__r.SPV_ObservacionesDecisionPretLetrado__c,
                    // Campos específicos para el bloque Funcionamiento del SAC
                    CBK_Case_Extension_Id__r.SPV_EmisionSAC__c,
                    CBK_Case_Extension_Id__r.SPV_ResolucionRemitidaEnPlazo__c,
                    CBK_Case_Extension_Id__r.SPV_CongruenciaRespuestaSAC__c,
                    CBK_Case_Extension_Id__r.SPV_CalidadRespuesta__c,
                    // Campos de MCC completo
                    CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name,
                    CC_MCC_ProdServ__c, CC_MCC_ProdServ__r.Name,
                    CC_MCC_Motivo__c, CC_MCC_Motivo__r.Name,
                    SEG_Detalle__c, SEG_Detalle__r.Name
                FROM Case 
                WHERE RecordTypeId = :RECTYPEPRETENSION 
                AND SAC_Reclamacion__c = :casoId
            ];
        }
        return listaPretensiones;
    }


        /*********************************************************************************
    * Proposito: Obtiene el importe abonado total de las tareas relacionadas con la reclamación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             --------     Pablo  Natera   09/05/25        Creación

    ************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Decimal getImporteAbonadoTotal(String caseId) {
        Decimal totalAmount = 0;
        
        if(Schema.sObjectType.SAC_Accion__c.isAccessible() && 
        Schema.sObjectType.SAC_Accion__c.fields.SAC_ImporteAbonar__c.isAccessible()) {
            
            AggregateResult result = [
                SELECT SUM(SAC_ImporteAbonar__c) totalAmount 
                FROM SAC_Accion__c 
                WHERE SAC_Reclamacion__c = :caseId
            ];
            
            if(result != null && result.get('totalAmount') != null) {
                totalAmount = (Decimal)result.get('totalAmount');
            }
        }
        
        return totalAmount;
    }




         /*********************************************************************************
    * Marca una rectificación existente como completada para permitir la creación de una nueva
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             --------     Pablo  Natera   12/05/25        Creación

    ************************************************************************************/
    @AuraEnabled
    public static Boolean completarRectificacionAnterior(Id formularioId) {
        try {
            if(Schema.sObjectType.SPV_Formulario__c.isUpdateable() &&
            Schema.sObjectType.SPV_Formulario__c.fields.SPV_RectificacionCompletada__c.isUpdateable()) {
                
                SPV_Formulario__c formulario = [
                    SELECT Id, SPV_RectificacionCompletada__c, SPV_FechaRectificacion__c
                    FROM SPV_Formulario__c
                    WHERE Id = :formularioId
                ];
                
                formulario.SPV_RectificacionCompletada__c = true;
                
                // Si no tiene fecha de rectificación, establecer la fecha actual
                if(formulario.SPV_FechaRectificacion__c == null) {
                    formulario.SPV_FechaRectificacion__c = CBK_UtilsDate.nowSYS();
                }
                
                update formulario;
                return true;
            }
            return false;
        } catch(Exception e) {
            throw new AuraHandledException('Error al marcar la rectificación como completada: ' + e.getMessage());
        }
    }


    /*********************************************************************************
    * Marca una rectificación crear un nuevo formulario de rectificación
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             --------     Pablo  Natera   12/05/25        Creación

    ************************************************************************************/
    @AuraEnabled
    public static Id crearNuevoFormularioRectificacion(Id casoId) {
        try {
            if(Schema.sObjectType.SPV_Formulario__c.isCreateable()) {
                SPV_Formulario__c nuevoFormulario = new SPV_Formulario__c();
                nuevoFormulario.SPV_Caso__c = casoId;
                nuevoFormulario.RecordTypeId = RECTYPEFORMULARIO;
                nuevoFormulario.SPV_FechaRectificacion__c = CBK_UtilsDate.nowSYS();
                nuevoFormulario.SPV_RectificacionCompletada__c = false;
                
                insert nuevoFormulario;
                return nuevoFormulario.Id;
            }
            return null;
        } catch(Exception e) {
            throw new AuraHandledException('Error al crear el formulario de rectificación: ' + e.getMessage());
        }
    }

}