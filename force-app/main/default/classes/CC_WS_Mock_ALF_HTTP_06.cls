@isTest
global with sharing class CC_WS_Mock_ALF_HTTP_06 implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {

        String sRespuesta = '';
        sRespuesta = sRespuesta + '<?xml version="1.0"?>';
        sRespuesta = sRespuesta + '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
        sRespuesta = sRespuesta + '<soap:Header/>';
        sRespuesta = sRespuesta + '<soap:Body2>';
        sRespuesta = sRespuesta + '</soap:Body>';
        sRespuesta = sRespuesta + '</soap:Envelope>';

        // Crear respueta mock.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody(sRespuesta);
        res.setStatusCode(200);
        return res;
    }
}