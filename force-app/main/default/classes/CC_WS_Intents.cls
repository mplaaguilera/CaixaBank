public with sharing class CC_WS_Intents {
    
    public class ResponseConversation{
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public List<String> lstConversationId;
    }

    public class ResponseDetailConversation{
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public DetailConversation conversationDetail;
    }

    public class DetailConversation {
		@AuraEnabled
        public Integer took;
		@AuraEnabled
        public boolean timed_out;
		@AuraEnabled
        public Shards shards;
		@AuraEnabled
        public Hits hits;
    }
    public class Shards {
		@AuraEnabled
		public Integer total;
		@AuraEnabled
		public Integer successful;
		@AuraEnabled
		public Integer skipped;
		@AuraEnabled
		public Integer failed;
	}
	public class Hits {
		@AuraEnabled
		public Hits[] hits;
		@AuraEnabled
		public String index;
		@AuraEnabled
		public String type;
		@AuraEnabled
		public String id;
		@AuraEnabled
		public Double score;
		@AuraEnabled
		public Source source;
	}
	public class Source {
		@AuraEnabled
		public String prioritaria;
		@AuraEnabled
		public String conversationID;
		@AuraEnabled
        public String[] userQuery;
		@AuraEnabled
		public String[] areas;
		@AuraEnabled
		public String idioma;
		@AuraEnabled
		public Integer reformulations;
		@AuraEnabled
		public String dan;
		@AuraEnabled
		public String dt;
		@AuraEnabled
		public String result;
		@AuraEnabled
		public Integer duration;
		@AuraEnabled
		public Datos[] datos;
		@AuraEnabled
		public String centro;
		@AuraEnabled
		public String connId;
		@AuraEnabled
		public String startTime;
		@AuraEnabled
		public String aplicacionOrigen;
		@AuraEnabled
		public Integer currentID;
		@AuraEnabled
		public String[] idiomaDetectado;
		@AuraEnabled
		public String phoneId;
		@AuraEnabled
		public String[] pilotaje;
		@AuraEnabled
		public String aplicacionCorpus;
		@AuraEnabled
		public Integer iterations;
		@AuraEnabled
		public String entorno;
		@AuraEnabled
		public String revision;
		@AuraEnabled
		public String perfil;
		@AuraEnabled
		public String[] agents;
		@AuraEnabled
		public String insertTime;
		@AuraEnabled
		public String segmento;
		//@AuraEnabled
		//public String @timestamp;
		@AuraEnabled
		public String[] badClassifications;
		@AuraEnabled
		public ConversationUnits[] conversationUnits;
		@AuraEnabled
		public String endTime;
		@AuraEnabled
		public String user;
		@AuraEnabled
		public String[] errors;
	}
	public class Datos {
		@AuraEnabled
		public IdentifiedObjects[] identifiedObjects;
		@AuraEnabled
		public String userTextOriginal;
		@AuraEnabled
		public String userTextObfuscate;
	}
	public class ConversationUnits {
		@AuraEnabled
		public String text;
		@AuraEnabled
		public Integer type;
		@AuraEnabled
		public String timestamp;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public Actions[] actions;
        @AuraEnabled
        public String[] nodesVisited;
        @AuraEnabled
        public Results[] results;
	}
    public class IdentifiedObjects {
        @AuraEnabled
        public Integer fromPosOutText;
        @AuraEnabled
        public Integer fromPosInText;
        @AuraEnabled
        public String data;
        @AuraEnabled
        public Integer length;
        @AuraEnabled
        public Integer toPosInText;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public Boolean obfuscated;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Integer toPosOutText;
    }
    public class Actions {
        @AuraEnabled
        public String action;
        @AuraEnabled
        public String result;
    }
    public class Results {
        @AuraEnabled
        public Double confidence;
        @AuraEnabled
        public String id;
    }


    /**
     * @description Obtención del Id de la conversación
     */
    public static ResponseConversation getConversationId(CC_Llamada__c llamada) {
        
        ResponseConversation result = new ResponseConversation();

        // Recuperamos la configuración para la llamada al WS de recuperar la conversación con Cognitive
        CC_InterfaceSettings__mdt recuperaLog = CC_MetodosUtiles.getInterfazConfigBody('CC_ConversationId');
        List<String> lstConversationId = new List<String>();
        String transcripcionCog = '';
        String dataMockup = '';

        if(recuperaLog != null){

            //Llamada al WS para recuperar la conversación de cognitive, crear el caso y la transcripción de la conversación
            try {
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                // En el endpoint del mdt hay que incluir un placeholder #placeholder_connId# que se sustituirá con el id correspondiente.
                // Esto permite añadir parámetros directamente en el End Point del mdt, como por ejemplo: #placeholder_connId#?fromTime=2021-01-31&toTime=2022-12-31
                String endPoint = recuperaLog.CC_EndPoint__c;
                endPoint = endPoint.replaceAll('#.*#', llamada.CC_ConnId__c);
                request.setEndpoint(endPoint);

                request.setMethod(recuperaLog.CC_TipoPeticion__c);
                request.setHeader('Content-Type', recuperaLog.CC_ContentType__c);

                if (Test.isRunningTest()){
                    dataMockup = '{"hits" : {"total" : 2,"hits" : [{"_index" : "app-112","_id" : "AYKDttITXJVSpIkmGr5S","_source" : {"result" : "CN","prioritaria" : "NO","conversationID" : "2208090214260636","areas" : ["112Conversacional","CXR"],"userQuery" : ["Petición de DNI","hablar con un agente","sacar dinero con código"],"startTime" : "2022-08-09T17:43:27.579Z","user" : "53753318","iterations" : 8,"entorno" : "RUNTIME","revision" : "NO","agents" : ["WATSON"]}},{"_index" : "app-112","_id" : "AYKDttfTQEhgDgw0z6X3","_source" : {"result" : "C2C","prioritaria" : "NO","conversationID" : "2208090214261161","areas" : ["HLO"],"userQuery" : ["no no"],"startTime" : "2022-08-09T17:43:27.579Z","user" : "53753318","iterations" : 0,"entorno" : "RUNTIME","revision" : "NO","agents" : ["WATSON"]}}]}}';
                } 
                if (!Test.isRunningTest()){
                    request.setClientCertificateName(recuperaLog.CC_Certificado__c);
                }
                
                HTTPResponse response = String.isNotBlank(dataMockup) ? getDataMockup(dataMockup) : http.send(request);
                result.statusCode = String.valueOf(response.getStatusCode());

                // Parse the JSON response
                if (!result.statusCode.equalsIgnoreCase('200')) {
                    result.errorCode = 'Error petición.';
                    result.errorMessage =  String.valueOf(response.getBody());
                } else {
                    
                    // Recuperamos el JSON de la conversación con cognitive a partir de la respuesta del WS
                    Map<String, Object> mapRespuesta = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf(response.getBody()));
                    String hitsLevel = JSON.serialize(mapRespuesta.get('hits'));
                    Map<String, Object> mapListadoHits = (Map<String, Object>) JSON.deserializeUntyped(hitsLevel);
                    List<Map<String, Object>> data = new List<Map<String, Object>>();
                    for (Object instance : (List<Object>)mapListadoHits.get('hits')){
                        data.add((Map<String, Object>)instance);
                        for (Object nivel : data){
                            String sourceLevel = JSON.serialize(nivel);
                            Map<String, Object> mapSource = (Map<String, Object>) JSON.deserializeUntyped(sourceLevel);
                            transcripcionCog = JSON.serialize(mapSource.get('_source'));
                            Map<String, Object> mapConversation =   (Map<String, Object>) JSON.deserializeUntyped(transcripcionCog);
                            if(!lstConversationId.contains((String) mapConversation.get('conversationID'))){
                                lstConversationId.add((String) mapConversation.get('conversationID'));
                            }
                        }
                    }
                }

                if(!lstConversationId.isEmpty()){
                    result.lstConversationId = lstConversationId;
                }
                

            } catch (Exception e){
                // Error comunicaciones.
                result.errorCode = 'Error comunicaciones.';
                result.errorMessage = e.getMessage();
            }
        }else{
            result.errorCode = 'Error comunicaciones.';
            result.errorMessage = 'Problemas obteniendo la configuración de la llamada.'; 
        }
        return result;
    }


    /**
     * @description Obtención del detalle de la conversación
     */
    public static ResponseDetailConversation getConversationDetail(String conversationId) {
        
        ResponseDetailConversation result = new ResponseDetailConversation();
        CC_WS_Intents.DetailConversation responseData = new CC_WS_Intents.DetailConversation();

        String dataMockup = '';
        // Recuperamos la configuración para la llamada al WS de recuperar la conversación con Cognitive
        CC_InterfaceSettings__mdt recuperaLog = CC_MetodosUtiles.getInterfazConfigBody('CC_ConversationDetail');

        if(recuperaLog != null){

            //Llamada al WS para recuperar la conversación de cognitive, crear el caso y la transcripción de la conversación
            try {
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(recuperaLog.CC_EndPoint__c + conversationId);
                request.setMethod(recuperaLog.CC_TipoPeticion__c);
                request.setHeader('Content-Type', recuperaLog.CC_ContentType__c);

                if (Test.isRunningTest()){
                    dataMockup = '{"took":0,"timed_out":false,"_shards":{"total":1,"successful":1,"skipped":0,"failed":0},"hits":{"total":1,"max_score":10.680915,"hits":[{"_index":"app-112","_type":"logs","_id":"AX3iSAAYomBbMcCaaaiW","_score":10.680915,"_source":{"prioritaria":"NO","conversationID":"16_190199932","userQuery":["Petición de DNI","Quiero bloquear mi tarjeta de crédito"],"areas":["TGT"],"idioma":"es","reformulations":0,"dan":"00000","dt":"00000","result":"NODEF","duration":5011,"datos":[{"identifiedObjects":[],"userTextOriginal":"Quiero bloquear mi tarjeta de crédito","userTextObfuscate":"Quiero bloquear mi tarjeta de crédito"}],"centro":"","connId":"16","startTime":"2021-12-16T11:52:27.697Z","aplicacionOrigen":"NUC","currentID":190199932,"idiomaDetectado":[],"phoneId":"55b1ca3486dd6da2ffa98d5fdd6164ed56c309f9bfd7cc04735f6ed9760a79eb","pilotaje":["BLOQUEO_DE_TARJETAS","OMNICANALIDAD"],"aplicacionCorpus":"112","iterations":5,"entorno":"RUNTIME","revision":"NO","perfil":"DEFAULT","agents":["WATSON"],"insertTime":"2021-12-22T13:15:04.423Z","segmento":"","@timestamp":"2021-12-22T13:15:04.423Z","badClassifications":[],"conversationUnits":[{"text":"El parámetro USE_NEW_CONVERSATION_ID de tipo D no está definido. Usando valor por defecto (0)","type":16,"timestamp":"2021-12-16T11:52:12.973Z"},{"text":"Se ha producido un error al recuperar la estructura del centro ","type":16,"timestamp":"2021-12-16T11:52:12.973Z"},{"text":"El parámetro USE_NEW_CONVERSATION_ID de tipo D no está definido. Usando valor por defecto (0)","type":16,"timestamp":"2021-12-16T11:52:12.836Z"},{"text":"Se ha producido un error al recuperar la estructura del centro ","type":16,"timestamp":"2021-12-16T11:52:12.836Z"},{"text":"El parámetro HA_DEFAULT_WS de tipo S no está definido. Usando valor por defecto (Global)","type":16,"timestamp":"2021-12-16T11:52:12.838Z"},{"text":"El parámetro END_CONVERSATION_ON_NO_ESCALATION de tipo D no está definido. Usando valor por defecto (0)","type":16,"timestamp":"2021-12-16T11:52:12.964Z"},{"text":"El mensaje ST_PROC_REQ no está definido.","type":16,"timestamp":"2021-12-16T11:52:13.453Z"},{"text":"El mensaje MSG_NOTIFICATIONS no está definido.","type":16,"timestamp":"2021-12-16T11:52:13.453Z"},{"text":"El mensaje MSG_NOTIFICATIONS_LINK no está definido.","type":16,"timestamp":"2021-12-16T11:52:13.453Z"},{"text":"El mensaje MSG_NOTIFICATIONS_LINK_HOT no está definido.","type":16,"timestamp":"2021-12-16T11:52:13.453Z"},{"text":"El mensaje MSG_SUBTITLE no está definido.","type":16,"timestamp":"2021-12-16T11:52:13.453Z"},{"text":"El mensaje MSG_TITLE no está definido.","type":16,"timestamp":"2021-12-16T11:52:13.453Z"},{"text":"El mensaje MSG_USUARIO_CONTEXTUALIZADO no está definido.","type":16,"timestamp":"2021-12-16T11:52:13.453Z"},{"text":"El mensaje MSG_USUARIO_SIN_CONTEXTUALIZAR no está definido.","type":16,"timestamp":"2021-12-16T11:52:13.453Z"},{"text":"El mensaje MSG_QUESTION no está definido.","type":16,"timestamp":"2021-12-16T11:52:13.453Z"},{"text":"El mensaje MSG_PRODUCT_LINK no está definido.","type":18,"timestamp":"2021-12-16T11:52:13.454Z"}],"endTime":"2021-12-16T11:52:32.708Z","user":"16","errors":[]}}]}}';
                }
                if (!Test.isRunningTest()){
                    request.setClientCertificateName(recuperaLog.CC_Certificado__c);
                }

                HTTPResponse response = String.isNotBlank(dataMockup) ? getDataMockup(dataMockup) : http.send(request);
                result.statusCode = String.valueOf(response.getStatusCode());
                
                // Parse the JSON response
                if (!result.statusCode.equalsIgnoreCase('200')) {
                    result.statusCode = String.valueOf(response.getStatusCode());
                    result.errorCode = 'Error petición.';
                    result.errorMessage =  String.valueOf(response.getBody());
                } else {
                    // Recuperamos el JSON de la conversación con cognitive a partir de la respuesta del WS
                    // Parseamos el resultado
                    String responseBody = response.getBody().stripHtmlTags();
                    responseBody = responseBody.replace('\n', '\\n');
                    responseBody = responseBody.replace('"_shards":','"shards":');
                    responseBody = responseBody.replace('"_index":','"index":');
                    responseBody = responseBody.replace('"_type":','"type":');
                    responseBody = responseBody.replace('"_id":','"id":');
                    responseBody = responseBody.replace('"_score":','"score":');
                    responseBody = responseBody.replace('"_source":','"source":');
                    responseData = (CC_WS_Intents.DetailConversation)JSON.deserialize(responseBody, CC_WS_Intents.DetailConversation.class);
                    
                    result.conversationDetail = responseData;
                }

            } catch (Exception e){
                // Error comunicaciones.
                result.errorCode = 'Error comunicaciones.';
                result.errorMessage = e.getMessage();
            }
        }else{
            result.errorCode = 'Error comunicaciones.';
            result.errorMessage = 'Problemas obteniendo la configuración de la llamada.'; 
        }

        return result;
    }

    /**
     * @description Generate the response for the mockup data
     */
    private static HTTPResponse getDataMockup(String dataMockup){
        
        HTTPResponse res = new HTTPResponse();
        res.setStatusCode(Integer.valueOf('200'));
        res.setStatus('OK');
        res.setBody(dataMockup);
        return res;
    }

}