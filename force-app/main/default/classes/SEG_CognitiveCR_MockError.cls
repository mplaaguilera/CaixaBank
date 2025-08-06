@isTest
global with sharing class SEG_CognitiveCR_MockError implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {

        String sRespuesta = '{"resultado":"KO","mensaje":"Error mock","codError":"9987","idUsuario":"","mensajeAux":""}';

        // Crear respueta mock.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json;charset=UTF-8');
        res.setBody(sRespuesta);
        res.setStatusCode(400);
        return res;
    }
}