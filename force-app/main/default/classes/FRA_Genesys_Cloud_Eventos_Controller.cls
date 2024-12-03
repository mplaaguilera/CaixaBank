public with sharing class FRA_Genesys_Cloud_Eventos_Controller {
  
    @AuraEnabled
    public static Map<String, Object> registrarLlamadaEntrante(String llamadaJson) {
        CC_Llamada_Input input = parseJson(llamadaJson);
        return FRA_Llamada_GC.registrarLlamadaEntrante(input);
    }

    @AuraEnabled
    public static Map<String, Object> registrarLlamadaSaliente(String llamadaJson) {
        CC_Llamada_Input input = parseJson(llamadaJson);
        return FRA_Llamada_GC.registrarLlamadaSaliente(input);
    }

    @AuraEnabled
    public static Map<String, Object> registrarConsulta(String consultaJson) {
        CC_Llamada_Input input = parseJson(consultaJson);
        return FRA_Llamada_GC.registrarConsulta(input);
    }

    @AuraEnabled
    public static Map<String, Object> registrarblindTransfer(String consultaJson) {
        CC_Llamada_Input input = parseJson(consultaJson);
        return FRA_Llamada_GC.registrarblindTransfer(input);
    }

    @AuraEnabled
    public static void finalizarLlamada(String llamadaJson, String tipoCierre) {
        CC_Llamada_Input input = parseJson(llamadaJson);
        FRA_Llamada_GC.finalizarLlamada(input, tipoCierre);
    }

    @AuraEnabled
    public static void registrarACW(String llamadaJson) {
        CC_Llamada_Input input = parseJson(llamadaJson);
        FRA_Llamada_GC.registrarACW(input);
    }

    @AuraEnabled
    public static void finalizarConsulta(String consultaJson, String tipoCierre) {
        FRA_Llamada_GC.finalizarConsulta(parseJson(consultaJson), tipoCierre);
    }

    @AuraEnabled
    public static void finalizarConsultaExterna(String consultaJson, String tipoCierre) {
        FRA_Llamada_GC.finalizarConsultaExterna(parseJson(consultaJson), tipoCierre);
    }

    @AuraEnabled
    public static void iniciarTransferenciaCiega(String consultaJson, String tipoCierre) {
        FRA_Llamada_GC.iniciarTransferenciaCiega(parseJson(consultaJson), tipoCierre);
    }
    @AuraEnabled
    public static void completarConsulta(String connIdConsulta, Id idNuevoOwner) {
        FRA_Llamada_GC.completarConsulta(connIdConsulta, idNuevoOwner);
    }

    private static CC_Llamada_Input parseJson(String inputJson) {
        return (CC_Llamada_Input)JSON.deserialize(inputJson, CC_Llamada_Input.class);
    }

    @AuraEnabled
    public static Map<String, Object> purecloudConversationApi(String interactionId) {
        HttpResponse response = purecloud.SDK.Rest.get('/platform/api/v2/conversations/calls/' + interactionId);
        return new Map<String, Object>{
            'statusCode' => response.getStatusCode(),
            'status' => response.getStatus(),
            'body' => JSON.deserializeUntyped(response.getBody())
        };
    }

    @AuraEnabled
    public static Map<String, Object> atributosLlamadaInicial(String interactionId) {
        List<CC_Llamada__c> llamadasIniciales = [SELECT CC_ANI__c, CC_DNIS__c, CC_Servicio_Genesys__r.CC_Codigo__c, CC_Asunto__c, CC_NumPerso__c, CC_Llamada_Padre__c,
                                                 CC_Idioma__c, CC_ConnId_Cognitivo__c, CC_Canal_del_Empleado__c, KIN_Genesys_Cloud_URL_Grabacion__c, CC_Datos_Genesys__c
                                                 FROM CC_Llamada__c WHERE CC_ConnId__c = :interactionId AND KIN_Llamada_Origen__c = TRUE LIMIT 1];
        if (llamadasIniciales.isEmpty()) {
            return new Map<String, Object>();
        } else {
            CC_Llamada__c llamadaInicial = llamadasIniciales[0];
            Id idCaso;
            List<Task> tareasLlamada = [SELECT WhatId FROM Task WHERE CC_Llamada_Id__c = :llamadaInicial.Id AND WhatId != NULL LIMIT 1];
            if (!tareasLlamada.isEmpty()) {
                idCaso = tareasLlamada[0].WhatId;
            }
            return new Map<String, Object>{
                'usuario' => null,
                'extension' => null,
                'connId' => interactionId,
                'ani' => llamadaInicial.CC_ANI__c,
                'dnis' => llamadaInicial.CC_DNIS__c,
                'servicio' => llamadaInicial.CC_Servicio_Genesys__r.CC_Codigo__c,
                'asunto' => llamadaInicial.CC_Asunto__c,
                'numPerso' => llamadaInicial.CC_NumPerso__c,
                'idioma' => llamadaInicial.CC_Idioma__c,
                'datos' => llamadaInicial.CC_Datos_Genesys__c,
                'connIdCognitivo' => llamadaInicial.CC_ConnId_Cognitivo__c,
                'casoId' => idCaso,
                'salesforceParentId' => llamadaInicial.CC_Llamada_Padre__c,
                'llamadaId' => llamadaInicial.Id,
                'CC_Canal_del_Empleado__c' => llamadaInicial.CC_Canal_del_Empleado__c,
                'urlGrabacion' => llamadaInicial.KIN_Genesys_Cloud_URL_Grabacion__c
            };
        }
    } 
}