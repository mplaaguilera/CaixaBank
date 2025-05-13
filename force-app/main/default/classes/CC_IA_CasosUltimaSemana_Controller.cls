public with sharing class CC_IA_CasosUltimaSemana_Controller {

@AuraEnabled
    public static String generarResumenCasos(Id caseId) {
        // Crear el mapa de nombres de objetos y sus respectivos IDs
        Map<String, String> objectIdsMap = new Map<String, String>{
            'Case' => String.valueOf(caseId)
        };
        CC_IA_CallerWrapper callerWrapper = new CC_IA_CallerWrapper();
        String detallesConsulta = callerWrapper.llmCaseCallerWrapper(objectIdsMap, 'CC_IA_ResumenCliente', null);
        return detallesConsulta;
    }
}