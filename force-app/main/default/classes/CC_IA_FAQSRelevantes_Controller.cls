public with sharing class CC_IA_FAQSRelevantes_Controller {

    @AuraEnabled
    public static String generarFAQSRelevantes(Id caseId, String canalProcedencia) {
        CC_IA_Einstein_Config__c config = CC_IA_Einstein_Config__c.getInstance(canalProcedencia);
        String promptTemplate;
        if (config != null && config.CC_IA_RAG_Activo__c && config.CC_IA_ON_OFF__c) {
            promptTemplate = config.CC_IA_RAG_Artprop_Template__c;
        } else {
            promptTemplate = 'CC_IA_FAQS_Relevantes';
        }
        // Crear el mapa de nombres de objetos y sus respectivos IDs
        Map<String, String> objectIdsMap = new Map<String, String>{
            'Case' => String.valueOf(caseId)
        };
        CC_IA_CallerWrapper callerWrapper = new CC_IA_CallerWrapper();
        String response = callerWrapper.llmCaseCallerWrapper(objectIdsMap, promptTemplate, null);
        return response;
    }
}