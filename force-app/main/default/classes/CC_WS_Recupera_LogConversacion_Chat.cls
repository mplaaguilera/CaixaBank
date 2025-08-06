public without sharing class CC_WS_Recupera_LogConversacion_Chat {
    
    public static void CC_WS_Recupera_LogConversacion_Chat(String sourceApp, String sourceConversationId, String chatIdAgente, String caseId) {

        String dataMockup = '';
        String sDescError = '';
        String sDetalleError = '';
        String sSalida = '';
        String transcripcionCog = '';
        String user = '';

        //Llamada al WS para recuperar el contexto Whatsapp
        try {
            // Se usa el Framework de integración CBK
            Map<String, String> mHeaders = new Map<String, String>();
            mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
            HttpRequest request = CBK_HttpServiceIntegration.getRequest(null, 'CC_Chat_Contexto_Whatsapp', 'GET', mHeaders);
            // Se añaden sourceApp y sourceConversationId al endpoint de la HTTP Request
            String httpRequestEndpoint = request.getEndpoint();
            httpRequestEndpoint = httpRequestEndpoint.replace('{sourceApp}', sourceApp);
            httpRequestEndpoint = httpRequestEndpoint.replace('{sourceConversationId}', sourceConversationId);
            request.setEndpoint(httpRequestEndpoint);

            if (Test.isRunningTest()) {
                dataMockup = '{"took":2,"timed_out":false,"_shards":{"total":1,"successful":1,"skipped":0,"failed":0},"hits":{"total":0,"max_score":null,"hits":[{"_index" : "app-112","_id" : "AYKDttITXJVSpIkmGr5S","_source" : {"result" : "CN","prioritaria" : "NO","conversationID" : "2208090214260636","areas" : ["112Conversacional","CXR"],"userQuery" : ["Petición de DNI","hablar con un agente","sacar dinero con código"],"startTime" : "2022-08-09T17:43:27.579Z","user" : "53753318","iterations" : 8,"entorno" : "RUNTIME","revision" : "NO","agents" : ["WATSON"]}},{"_index" : "app-112","_id" : "AYKDttfTQEhgDgw0z6X3","_source" : {"result" : "C2C","prioritaria" : "NO","conversationID" : "2208090214261161","areas" : ["HLO"],"userQuery" : ["no no"],"startTime" : "2022-08-09T17:43:27.579Z","user" : "53753318","iterations" : 0,"entorno" : "RUNTIME","revision" : "NO","agents" : ["WATSON"]}}]}}';
            }
            HttpResponse response = String.isNotBlank(dataMockup) ? getDataMockup(dataMockup) : CBK_HttpServiceIntegration.callHttpService(request, null, 'CC_Chat_Contexto_Whatsapp');
            
            // Parse the JSON response
            if (response.getStatusCode() != 200) {
                sDescError = 'Error petición.';
                sDetalleError = response.getStatus() + ' (' + response.getStatusCode() + ')';
                sSalida = String.valueOf(response.getBody());
            } else {
                // Recuperamos el JSON de la conversación con cognitive a partir de la respuesta del WS
                Map<String, Object> MapRespuesta = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf(response.getBody()));
                String HitsLevel = JSON.serialize(MapRespuesta.get('hits'));
                Map<String, Object> MapListadoHits = (Map<String, Object>) JSON.deserializeUntyped(HitsLevel);
                List<Map<String, Object>> data = new List<Map<String, Object>>();
                for (Object instance : (List<Object>)MapListadoHits.get('hits')) {
                    data.add((Map<String, Object>)instance);
                    for (Object nivel : data) {
                        String SourceLevel = JSON.serialize(nivel);
                        Map<String, Object> MapSource = (Map<String, Object>) JSON.deserializeUntyped(SourceLevel);
                        transcripcionCog = JSON.serialize(MapSource.get('_source'));
                        Map<String, Object> MapUser =   (Map<String, Object>) JSON.deserializeUntyped(transcripcionCog);
                        user = (String) MapUser.get('user');
                    }
                }
            }
        }catch (Exception e) {
            sDescError = 'Error comunicaciones.';
            sDetalleError = e.getMessage();
        }

        // Creación de la Transcripción añadiendo la conversación recuperada
        if (!String.isBlank(transcripcionCog)) {
            createLiveChatTranscript(transcripcionCog, user, chatIdAgente, caseId);
        }
    }

    //Método para crear el LiveChatTranscript de la transcripción del Chat
    private static void createLiveChatTranscript(String transcript, String nickname, String chatIdAgente, String caseId) {
        
        List<LiveChatTranscript> lstUpdateChat = [SELECT CC_ChatOrigen__c, CC_ChatOrigen__r.CC_ChatOrigen__c, CC_Aplicacion_Origen__c FROM LiveChatTranscript WHERE Id=:chatIdAgente AND CC_Aplicacion_Origen__c='Whatsapp' LIMIT 1]; //recuperamos el chat de agente
        if(!lstUpdateChat.isEmpty()) {
            if (!String.isBlank(lstUpdateChat[0].CC_ChatOrigen__c) && String.isBlank(lstUpdateChat[0].CC_ChatOrigen__r.CC_ChatOrigen__c)) {

                // Se crea el chat de contexto de Whatsapp si aún no existe
                LiveChatTranscript liveChatTranscript = new LiveChatTranscript();
                liveChatTranscript.RecordTypeId = Schema.getGlobalDescribe().get('LiveChatTranscript').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Clientes').getRecordTypeId();
                liveChatTranscript.Status = 'Completed';
                liveChatTranscript.CC_Tipo__c = 'Whatsapp';
                liveChatTranscript.CC_Cognitive_chat__c = transcript;
                liveChatTranscript.CC_Nickname__c  = nickname;
                liveChatTranscript.CaseId = caseId;
                // Creamos LiveChatVisitor sin session key para crear el LiveChatTranscript
                LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
                insert liveChatVisitor;
                liveChatTranscript.LiveChatVisitorId = liveChatVisitor.Id;
                insert liveChatTranscript;

                // Se actualiza el chat origen del Chatbot si aún no está informado
                List<LiveChatTranscript> lstUpdateChatBot = [SELECT CC_ChatOrigen__c FROM LiveChatTranscript WHERE Id=:lstUpdateChat[0].CC_ChatOrigen__c LIMIT 1];
                lstUpdateChatBot[0].CC_ChatOrigen__c = liveChatTranscript.Id;
                update lstUpdateChatBot;
            }
        }
    }

    /* Generate the response for the mockup data */
    private static HTTPResponse getDataMockup(String dataMockup) {
        HTTPResponse res = new HTTPResponse();
        res.setStatusCode(Integer.valueOf('200'));
        res.setStatus('OK');
        res.setBody(dataMockup);
        return res;
    }
}