@isTest
global with sharing class CC_WS_Mock_Autenticacion2 implements HttpCalloutMock {
    
    Integer statusCode;
    public CC_WS_Mock_Autenticacion2(Integer strStatusCode){
        statusCode = strStatusCode;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
		// Crear respueta mock.
        HttpResponse res = new HttpResponse();
        if(statusCode==200){
        String json = '{'+
            '  \"authorizationId\": \"SK_01202301191155550210010040ABSIS_GENERICO000000000000000DEF22snoQ3bJy9jczLqCj4\",'+
			'  \"status\": \"INPROGRESS\",'+
            '  \"challengeType\": \"SAG\",'+
            '  \"approverId\": \"10559714\"'+       
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