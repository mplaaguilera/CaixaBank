@isTest
global with sharing class CC_WS_Mock_SBLFIN_HTTP_01 implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {

        String sRespuesta = '{"resultado":"OK","mensaje":"","codError":"","idUsuario":"","mensajeAux":""}';

        // Crear respueta mock.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json;charset=UTF-8');
        res.setBody(sRespuesta);
        res.setStatusCode(200);
        return res;
    }
}