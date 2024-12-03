public with sharing class CC_ST_AppGallery {
    
    public class Response{
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public String endpoint;
        @AuraEnabled
        public ResponseData review;
    }

    public class ResponseData{
        @AuraEnabled
        public Cls_ret ret;
        @AuraEnabled
	    public Cls_data data;
    }

	public class Cls_ret {
        @AuraEnabled
		public Integer rtnCode;	
        @AuraEnabled
		public String rtnDesc;	
	}

	public class Cls_data {
        @AuraEnabled
		public Cls_reviewList[] reviewList;
        @AuraEnabled
		public Integer hasNext;	
        @AuraEnabled
		public Integer total;	
	}

	public class Cls_reviewList {
        @AuraEnabled
		public String content;	
        @AuraEnabled
		public String reviewId;
        @AuraEnabled
		public String apkVersion;	
        @AuraEnabled
		public String phoneType;
        @AuraEnabled
		public Integer rating;
        @AuraEnabled
		public Integer likes;	
        @AuraEnabled
		public Integer replies;	
        @AuraEnabled
		public String dateline;	
        @AuraEnabled
		public String auditState;	
        @AuraEnabled
		public String devReplyContent;
        @AuraEnabled
		public String countryCode;
	}

    public class ResponseReply{
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public String endpoint;
        @AuraEnabled
        public String estado;
        @AuraEnabled
        public String msjEntrada;
    }

    public class ResponseDataReply{
        @AuraEnabled
        public Cls_ret ret;
    }

    public class TokenObject{
        @AuraEnabled
        public String token;
        @AuraEnabled
        public Google_SA_Token__c objectToken;
        @AuraEnabled
        public Boolean hasUpdate;
        
    }

    /**
     * @description Obtención de los comentarios de HUAWEI
     */
    public static Response sendRequest(String appId, String country, String serviceAcctTokenName, String token) {
        
        Response result = new Response();
        String endpoint  = '';
        CC_ST_AppGallery.ResponseData responseData = new CC_ST_AppGallery.ResponseData();

        List<CC_App_Gallery_Token__mdt> lstAppQueryResult = [SELECT Id, CC_Endpoint__c, CC_Client_Id__c, CC_Client_Secret__c
                                                            FROM CC_App_Gallery_Token__mdt
                                                            WHERE MasterLabel = :serviceAcctTokenName WITH SECURITY_ENFORCED
                                                            LIMIT 1];
        if(!lstAppQueryResult.isEmpty()){
            
            CC_App_Gallery_Token__mdt appQueryResult = lstAppQueryResult.get(0);

            if(token != null){
                String dataMockup = '';

                Map<String, String> mHeaders = new Map<String, String>();
                mHeaders.put('client_id', appQueryResult.CC_Client_Id__c);
                mHeaders.put('Authorization', 'Bearer '+token);
                
                if(Test.isRunningTest()){
                    dataMockup = '{"ret":{"rtnCode":0,"rtnDesc":"success"},"data":{"reviewList":[{"content":"Comentario de prueba 6","reviewId":"89c5a05cf28d4c6f93aea2badb24fddb","apkVersion":"10.5.3","phoneType":"HONOR8-LITE","rating":3,"likes":0,"replies":0,"dateline":1590578852123,"auditState":"3","devReplyContent":null,"countryCode":"CN"},{"content":"Comentario de prueba 5.","reviewId":"9f43c56228854d66a65921938199c0ce","apkVersion":"10.5.3","phoneType":"HONOR8-LITE","rating":4,"likes":0,"replies":4,"dateline":1590564388000,"auditState":"3","devReplyContent":"Reply0086138******48:Replycontent......","countryCode":"CN"}],"hasNext":0,"total":2}}';
                }
                
                HttpRequest req = CBK_HttpServiceIntegration.getRequest('', 'getComments', 'GET', mHeaders);
                Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                endpoint = req.getEndpoint();
                endpoint = endpoint.replace('{appId}',appId);
                
                DateTime dtStart = DateTime.Now().AddDays(-30);
                endpoint = endpoint.replace('{beginTime}',String.valueOf(dtStart.getTime()));
                DateTime dtEnd = DateTime.Now().AddDays(1);
                endpoint = endpoint.replace('{endTime}',String.valueOf(dtEnd.getTime()));
                endpoint = endpoint.replace('{country}',country);
                req.setEndpoint(endpoint);
                result.endpoint = req.getEndpoint();
                //dataMockup = '{"ret":{"rtnCode":0,"rtnDesc":"success"},"data":{"reviewList":[{"content":"Comentario de prueba 6","reviewId":"89c5a05cf28d4c6f93aea2badb24fddb","apkVersion":"10.5.3","phoneType":"HONOR8-LITE","rating":3,"likes":0,"replies":0,"dateline":1590578852123,"auditState":"3","devReplyContent":null,"countryCode":"CN"},{"content":"Comentario de prueba 5.","reviewId":"9f43c56228854d66a65921938199c0ce","apkVersion":"10.5.3","phoneType":"HONOR8-LITE","rating":4,"likes":0,"replies":4,"dateline":1590564388000,"auditState":"3","devReplyContent":"Reply0086138******48:Replycontent......","countryCode":"CN"}],"hasNext":0,"total":2}}';
                HTTPResponse resp = String.isNotBlank(dataMockup) ? getDataMockup(dataMockup) : CBK_HttpServiceIntegration.callHttpService(req);
                String statusCode = String.valueOf(resp.getStatusCode());
                if(statusCode.equalsIgnoreCase('200')){
                    responseData = (CC_ST_AppGallery.ResponseData)getBodyResponse(resp, 'CC_ST_AppGallery.ResponseData');
                    result.review = responseData;
                    result.statusCode = statusCode;
                }else{
                    result.statusCode = statusCode;
                    result.errorCode = 'Error comunicaciones.';
                    result.errorMessage = resp.getStatus(); 
                }   
                   
            }else{
                result.errorCode = 'Error comunicaciones.';
                result.errorMessage = 'Problemas obteniendo el token en el servicio.'; 
            }
        }else{
            result.errorCode = 'Error comunicaciones.';
            result.errorMessage = 'Problemas obteniendo el servicio.'; 
        }

        return result;

    }

    /**
     * @description Contestar a un comentario de HUAWEI
     */
    public static ResponseReply sendRequestReply(String appId, String reviewId, String replyText, CC_ST_AppReviews__c comentario) {
        
        ResponseReply result = new ResponseReply();
        TokenObject tokenObj = new TokenObject();
        CC_ST_AppGallery.ResponseDataReply responseData = new CC_ST_AppGallery.ResponseDataReply();

        String serviceAcctTokenName = 'Huawei_Store';

        List<CC_App_Gallery_Token__mdt> lstAppQueryResult = [SELECT Id, CC_Endpoint__c, CC_Client_Id__c, CC_Client_Secret__c, CC_AppId__c, CC_ReviewId__c
                                                            FROM CC_App_Gallery_Token__mdt
                                                            WHERE MasterLabel = :serviceAcctTokenName WITH SECURITY_ENFORCED
                                                            LIMIT 1];

        if(!lstAppQueryResult.isEmpty()){
            
            CC_App_Gallery_Token__mdt appQueryResult = lstAppQueryResult.get(0);

            tokenObj = getAccessToken(appQueryResult);
            if(tokenObj != null){
                String dataMockup = '';

                Map<String, String> mHeaders = new Map<String, String>();
                mHeaders.put('client_id', appQueryResult.CC_Client_Id__c);
                mHeaders.put('Authorization', 'Bearer '+tokenObj.token);
                mHeaders.put('requestId', comentario.Id); // Id del comentario
                mHeaders.put('Content-Type', 'application/json');

                Map<String, String> mBody = new Map<String, String>();
                
                Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                if(isSandbox){
                    mBody.put('appId', appQueryResult.CC_AppId__c);//'103154993'
                    mBody.put('reviewId', appQueryResult.CC_ReviewId__c); //Identificador de prueba '0b5783e039d74bc0b79b42318dddfa4d'
                }else{
                    mBody.put('appId', appId);
                    mBody.put('reviewId', reviewId);
                }
                mBody.put('devReplyContent', replyText);
                if(comentario.CC_Idioma__c == 'es' || comentario.CC_Idioma__c == 'ca'){
                    mBody.put('countryCode', 'es'); // store countryCode__c   
                    mBody.put('lang', 'es_ES');
                }else if(comentario.CC_Idioma__c == 'en'){
                    mBody.put('countryCode', 'gb'); // store countryCode__c   
                    mBody.put('lang', 'en_GB');  
                }

                String body = JSON.serialize(mBody);
                
                if(Test.isRunningTest()){
                    dataMockup = '{"ret": {"rtnCode": 0,"rtnDesc": "success"}}';
                } 
                HttpRequest req = CBK_HttpServiceIntegration.getRequest(body, 'replyComments', 'POST', mHeaders);

                result.endpoint = req.getEndpoint();
                result.msjEntrada = req.getBody();
                //dataMockup = '{"ret": {"rtnCode": 0,"rtnDesc": "success"}}';
                HTTPResponse resp = String.isNotBlank(dataMockup) ? getDataMockup(dataMockup) : CBK_HttpServiceIntegration.callHttpService(req);
                String statusCode = String.valueOf(resp.getStatusCode());
                 if(statusCode.equalsIgnoreCase('200')){
                    responseData = (CC_ST_AppGallery.ResponseDataReply)getBodyResponse(resp, 'CC_ST_AppGallery.ResponseDataReply');
                    result.estado = responseData.ret.rtnDesc;
                    result.statusCode = statusCode;

                }else{
                    result.statusCode = statusCode;
                    result.errorCode = 'Error comunicaciones.';
                    result.errorMessage = resp.getStatus(); 
                }   
            }else{
                result.errorCode = 'Error comunicaciones.';
                result.errorMessage = 'Problemas obteniendo el token en el servicio.'; 
            }
        }else{
            result.errorCode = 'Error comunicaciones.';
            result.errorMessage = 'Problemas obteniendo el servicio.'; 
        }

        return result;

    }

    /**
     * @description Obtención del token
     */
    public static TokenObject getAccessToken(CC_App_Gallery_Token__mdt appQueryResult) {

        TokenObject tokenObj = new TokenObject();
        Google_SA_Token__c serviceAcctToken = Google_SA_Token__c.getValues('Huawei_Store');

        if (isTokenExpired(serviceAcctToken)) {
            tokenObj = requestAccessToken(serviceAcctToken, appQueryResult);
            tokenObj.hasUpdate = true;
        }else{
            tokenObj.token = serviceAcctToken.value__c;
            tokenObj.objectToken = serviceAcctToken;
            tokenObj.hasUpdate = false;
        }
        return tokenObj;
    }

    /**
     * @description Comprobar si el token ha expirado
     */
    private static Boolean isTokenExpired(Google_SA_Token__c serviceAcctToken) {
        if (serviceAcctToken.Value__c == null) { return true; }

        // Divide by 1000 to convert to seconds and divide by 60 to convert
        // to minutes. Therefore, we divide by 60,000
        Long elapsedMin = (Datetime.now().getTime()
            - serviceAcctToken.Timestamp__c.getTime())/60000;

        if (elapsedMin >= 58) {
            return true;
        }
        return false;
    }

    /**
     * @description Obtención del token si no ha expirado
     */
    private static TokenObject requestAccessToken(Google_SA_Token__c serviceAcctToken, CC_App_Gallery_Token__mdt appQueryResult) {

        TokenObject tokenObj = new TokenObject();

        if(appQueryResult != null){
            String dataMockup = '';

            if(Test.isRunningTest()){
                dataMockup = '{"access_token": "eyJraWQiOiJiUkFqTXg0ZzFhWDNMT2FBMGd6QmgxeDM4aEFaMFREZiIsInR5cCI6IkpXVCIsImFsZyI6IkhTMjU2In0.eyJzdWIiOiI4MjMyMjU3MTkxMjY1MTAyMDgiLCJkbiI6MSwiY2xpZW50X3R5cGUiOjEsImV4cCI6MTY1NDM1NjY4MCwiaWF0IjoxNjU0MTgzODgwfQ.e7zJmzbtAVesBLSQGXIudWwHQ8zj64bHhYhIXM6y2xc", "expires_in": 172799}';
            }

            //Crear Request
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(appQueryResult.CC_Endpoint__c); //URL de token de AppGallery
            req.setMethod('POST');
            req.setTimeout(15 * 1000);
            Map<String, String> mapJson = new Map<String, String>();
            mapJson.put('grant_type','client_credentials');
            mapJson.put('client_id',appQueryResult.CC_Client_Id__c);
            mapJson.put('client_secret',appQueryResult.CC_Client_Secret__c);
            String body = JSON.serialize(mapJson);
            req.setBody(body);
            //Llamar al WS y devolver token
            //dataMockup = '{"access_token": "eyJraWQiOiJiUkFqTXg0ZzFhWDNMT2FBMGd6QmgxeDM4aEFaMFREZiIsInR5cCI6IkpXVCIsImFsZyI6IkhTMjU2In0.eyJzdWIiOiI4MjMyMjU3MTkxMjY1MTAyMDgiLCJkbiI6MSwiY2xpZW50X3R5cGUiOjEsImV4cCI6MTY1NDM1NjY4MCwiaWF0IjoxNjU0MTgzODgwfQ.e7zJmzbtAVesBLSQGXIudWwHQ8zj64bHhYhIXM6y2xc", "expires_in": 172799}';
            HTTPResponse res = String.isNotBlank(dataMockup) ? getDataMockup(dataMockup) : new Http().send(req);
            String respParam = handleResponse(res);

            Map<String, Object> respParams = (Map<String, Object>)
                JSON.deserializeUntyped(res.getBody());


            serviceAcctToken.Value__c = (String) respParams.get('access_token');
            serviceAcctToken.Timestamp__c = Datetime.now();

            tokenObj.token = serviceAcctToken.Value__c;
            tokenObj.objectToken = serviceAcctToken;
        }
        
        return tokenObj;

    }

    /**
     * @description Convertir en objeto el json de la response
     */
    private static String handleResponse(HttpResponse res) {

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            return res.getBody();
        }

        CalloutException respErr = new CalloutException();
        respErr.setMessage(res.getBody());
        throw respErr;
    } 

    /**
     * @description Convertir en objeto el json de la response
     */
    private static Object getBodyResponse(HTTPResponse response, String clazzName){

        Object result = parseJsonToObject(response.getBody(), clazzName);
        return result;

    }

    /**
     * @description Convertir en objeto el json de la response
     */
    private static Object parseJsonToObject(String jsonData, String jsonType){
        Type typeClass = Type.forName(jsonType);
        return System.JSON.deserializeStrict(jsonData, typeClass);
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