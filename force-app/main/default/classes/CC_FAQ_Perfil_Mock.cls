@isTest
global with sharing class CC_FAQ_Perfil_Mock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {

        String sFakeRespuesta = '';
        sFakeRespuesta = sFakeRespuesta + '{[';
        sFakeRespuesta = sFakeRespuesta + '22,';
        sFakeRespuesta = sFakeRespuesta + '23,';
        sFakeRespuesta = sFakeRespuesta + '24';
        sFakeRespuesta = sFakeRespuesta + ']';
        sFakeRespuesta = sFakeRespuesta + '}';

        // Crear respueta mock.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(sFakeRespuesta);
        res.setStatusCode(200);
        return res;
    }
}