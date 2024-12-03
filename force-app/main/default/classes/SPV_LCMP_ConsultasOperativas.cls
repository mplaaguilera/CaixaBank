public with sharing class SPV_LCMP_ConsultasOperativas {

    private static Set<String> objetos = new Set<String>{'SAC_Interaccion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPECONSULTA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Consulta').getRecordTypeId();
    
    /**************************************************************************************
     * Proposito: Actualizar el estado de la consulta a pendiente de repuesta definitiva
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     *   1.0           US828257      Raúl Santos      29/04/24        Creación
    **************************************************************************************/
    @AuraEnabled
    public static void marcarPendienteRespuestaDefinitiva(Id consultaId) {

        if(Schema.sObjectType.SAC_Interaccion__C.isAccessible()){
            SAC_Interaccion__c consulta = [SELECT Id, SAC_Estado__c FROM SAC_Interaccion__C WHERE RecordTypeId = :RECTYPECONSULTA AND Id = :consultaId];

            if(consulta.SAC_Estado__c == 'SAC_Resuelta') {
                consulta.SAC_Estado__c = 'SAC_PendienteRespuestaDefinitiva';
                SPV_DatabaseDML.updateDML(consulta, true);
            }
        }
    }

    @AuraEnabled
    public static void tomarPropiedadConsulta(String consultaId, String grupoConsulta, String usuarioActualId) {
        String mensajeError = '';
        try {
            //Asignar id consulta
            SAC_Interaccion__c consulta = new SAC_Interaccion__c();
            consulta.Id = consultaId;

            //Buscar si el usuario que ejecuta la interacción pertenece al mismo grupo al que pertenece la interacción
            List<CC_Grupo_Colaborador_Contact__c> colabContact = [SELECT Id
                                                                    FROM CC_Grupo_Colaborador_Contact__c
                                                                    WHERE CC_Grupo_Colaborador__c = :grupoConsulta
                                                                    AND CC_Usuario__c = :usuarioActualId LIMIT 1];

            //Si pertenece al grupo, actualizar el registro. De lo contrario mostrar error.
            if (!colabContact.isEmpty()) {
                consulta.OwnerId = usuarioActualId;
                if(Schema.sObjectType.SAC_Interaccion__c.isUpdateable()){   
                    Database.update(consulta);
                }else{
                    mensajeError = 'No tienes permisos para actualizar la consulta';
                    throw new AuraHandledException(mensajeError);
                }
            } else {
                mensajeError = 'No perteneces al grupo de la consulta';
                throw new AuraHandledException(mensajeError);
            }
        } catch (Exception e) {
            if (String.isNotBlank(mensajeError)) { e.setMessage(mensajeError); }
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void devolverConsultaAlGrupo(String consultaId) {
        try {
            //Asignar id de consulta
            SAC_Interaccion__c consulta = new SAC_Interaccion__c();
            consulta.Id = consultaId;

            //Buscar la cola
            List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
            //Si se ha encontrado la cola, cambiar el owner por la cola y updatear el consulta
            if(!cola.isEmpty()){
                consulta.OwnerId = cola[0].id;
                if(Schema.sObjectType.SAC_Interaccion__c.isUpdateable()){   
                    Database.update(consulta);
                }else{
                    throw new AuraHandledException('No tienes permisos para actualizar e la consulta');
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
}