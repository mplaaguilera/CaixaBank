@isTest
global with sharing class CC_WS_Mock_SBLALTA implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {

        String sRespuesta = '{"chatID":null,"type":null,"rc":"OK","msg":"","idSR":"8-5I03HY"}';

        // Crear respueta mock.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json;charset=UTF-8');
        res.setBody(sRespuesta);
        res.setStatusCode(200);
        return res;
    }
}