@isTest
global with sharing class SEG_wsMockTrasladoValijaKO500 implements HttpCalloutMock {
    
	global HTTPResponse respond(HTTPRequest req) {

        String mockString = '{"ok":false,"id":"03071242022203900013","errorCode":"","message":""}';
        
        // Crear respueta mock.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(mockString);
        res.setStatusCode(500);
        return res;
    }
}