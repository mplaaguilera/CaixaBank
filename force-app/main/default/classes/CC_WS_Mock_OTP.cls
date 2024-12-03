@isTest
global with sharing class CC_WS_Mock_OTP implements HttpCalloutMock {

    Integer statusCode;
    public CC_WS_Mock_OTP(Integer strStatusCode){
        statusCode = strStatusCode;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
		// Crear respueta mock.
        HttpResponse res = new HttpResponse();
        if(statusCode==200){
        	String json = 	'{'+
             '\"codAp\":\"BCCOTP01\",'+
                    '\"dateTime\":\"2023-05-21-23.51.19.949\",'+
                        '\"McdBlock\":{\"version\":\"00\",'+
                            '\"programName\":\"C3CCSF\",'+
                                '\"eventCode\":\"0BCC00000353000\",'+
                                    '\"eventData\":\"CLAU0O01050                a0b6M00000ZbSv3QAF2023521235119950IDI00001003002PER00002008033122fe99999999\",'+
                                        '\"eventType\":\"O\"},'+
                                            '\"personId\":"12345678"'+
                                               '}';
            
        	res.setHeader('Content-Type', 'text/xml');
            res.setBody(json);
            res.setStatusCode(200);
        } else if(statusCode==404){
            String json = '{"detail":"Error interno del servidor","stackTrace":[],"type":"architecture/internal-server-error","title":"Error aplicativo","status":404}';
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(json);
            res.setStatusCode(404);
        }
        return res;
    }
}