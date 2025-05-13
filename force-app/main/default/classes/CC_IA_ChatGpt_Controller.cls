public with sharing class CC_IA_ChatGpt_Controller {
    /**
     * @description         Lanzamiento del prompt a través del Wrapper de llamadas al LLM.
     * @param pregunta Pregunta escrita en el chat por usuario
     * @param casoId Id del caso
     * @return Lista de Knowledge__kav que cumplen con los criterios de filtro.
     * @Autor: Borja Lavesiera Muñoz
     */
    @AuraEnabled
    public static String ejecutarPrompt(String pregunta, Id casoId) {
        try {
            // Obtener el registro de Case
            Case caseRecord = [
                SELECT Subject, CBK_Case_Extension_Id__c, CC_Canal_Procedencia__c
                FROM Case 
                WHERE Id = :casoId 
                WITH SECURITY_ENFORCED 
                LIMIT 1
            ];

            // Obtener el ID de Case Extension
            Id caseExtensionId = caseRecord.CBK_Case_Extension_Id__c;
            if (caseExtensionId == null) {
                return 'El Caso no tiene un registro de Case Extension asociado.';
            }

            // Obtener el registro de Case Extension
            CBK_Case_Extension__c caseExtension = [
                SELECT CC_IA_Historico_ChatGpt__c 
                FROM CBK_Case_Extension__c 
                WHERE Id = :caseExtensionId 
                WITH SECURITY_ENFORCED 
                LIMIT 1
            ];

            // Comprobar que el Subject y el Histórico tienen datos
            if (String.isBlank(caseRecord.Subject) || caseRecord.Subject.containsAny('0123456789')) {
                return 'El Caso no contiene la información necesaria para ejecutar el chat';
            }

            // Crear el mapa de nombres de objetos y sus respectivos IDs
            Map<String, String> objectIdsMap = new Map<String, String>{
                'Case' => String.valueOf(casoId),
                'Case_Extension' => String.valueOf(caseExtensionId)
            };
            // Obtener el valor del custom setting
            CC_IA_Einstein_Config__c config = CC_IA_Einstein_Config__c.getInstance(caseRecord.CC_Canal_Procedencia__c);

            // Verificar el valor del campo CC_IA_RAG_Activo__c
            String promptTemplate;
            if (config != null && config.CC_IA_RAG_Activo__c && config.CC_IA_ON_OFF__c) {  
                promptTemplate = config.CC_IA_RAG_Chat_Template__c;
            } else {
                promptTemplate = 'CC_IA_Chat_Interactivo';
            }
            // Llamar al Wrapper de llamadas al LLM
            CC_IA_CallerWrapper callerWrapper = new CC_IA_CallerWrapper();
            String result = callerWrapper.llmCaseCallerWrapper(objectIdsMap, promptTemplate, pregunta);
            return result;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description         Obtención Case Extension Relacionado
     * @param CaseExtensionId Id del Case Extension asociado al caso.
     * @return caseExtension Lista de caseExtension que cumple con los criterios de filtro.
     * @Autor: Borja Lavesiera Muñoz
     */
    @AuraEnabled(cacheable=true)
    public static CBK_Case_Extension__c getCaseExtension(Id caseExtensionId) {
        try {
            if (caseExtensionId == null) {
                throw new AuraHandledException('El ID de Case Extension no puede ser nulo.');
            }
            // Recuperar el registro relacionado en CBK_Case_Extension__c
            CBK_Case_Extension__c caseExtension = [SELECT Id, CC_IA_Historico_ChatGpt__c, CC_IA_Interacciones_Asistente_IA__c 
                                                FROM CBK_Case_Extension__c 
                                                WHERE Id = :caseExtensionId 
                                                WITH SECURITY_ENFORCED 
                                                LIMIT 1];
            return caseExtension;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description         Actualizar Registro Case Extension
     * @param casoId  Id del Caso.
     * @return fields Lista de campos a actualizar.
     * @Autor: Borja Lavesiera Muñoz
     */
    @AuraEnabled
    public static void actualizarCaseExtension(Id casoId, Map<String, Object> fields) {
        try {
            Case caseRecord = [SELECT CBK_Case_Extension_Id__c FROM Case WHERE Id = :casoId WITH SECURITY_ENFORCED LIMIT 1];
            if (caseRecord.CBK_Case_Extension_Id__c == null) {
                throw new AuraHandledException('No se encontró el Case Extension relacionado.');
            }
            CBK_Case_Extension__c caseExtension = [SELECT Id, CC_IA_Historico_ChatGpt__c, CC_IA_Interacciones_Asistente_IA__c 
                                               FROM CBK_Case_Extension__c 
                                               WHERE Id = :caseRecord.CBK_Case_Extension_Id__c WITH SECURITY_ENFORCED LIMIT 1];
            if (fields.containsKey('historicoChat')) {
                caseExtension.CC_IA_Historico_ChatGpt__c = (String) fields.get('historicoChat');
            }
            if (fields.containsKey('interacciones')) {
                caseExtension.CC_IA_Interacciones_Asistente_IA__c = ((Decimal) fields.get('interacciones')).intValue();
            }
            // DML Mediante clase util
            CC_IA_EinsteinUtils.saveRecords(new List<SObject>{ caseExtension }, false);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}