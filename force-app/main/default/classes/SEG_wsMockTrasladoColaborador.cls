@isTest
global with sharing class SEG_wsMockTrasladoColaborador implements HttpCalloutMock {
    
	/* global HTTPResponse respond(HTTPRequest req) {

        String mockString = '{"ok":true,"id":"03071242022203900013","errorCode":"","message":""}';
        
        // Crear respueta mock.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(mockString);
        res.setStatusCode(200);
        return res;
    }
     */

    global HTTPResponse respond(HTTPRequest req) {
        if(req.getBody().containsIgnoreCase('01') || req.getBody().containsIgnoreCase('06')) {
            String mockString = '{"actor":"SEGMSF","aud":"ALL","sub":"briefcaseId","iss":"DocumentLibraryVerification:briefcaseRequest","principalName":"SEGMSF","exp":1751530635,"iat":1751528835,"value":"00008008251843400419","jti":"3806b556-56c7-4fac-9ad8-f0acca0857f6"}';

            // Crear respueta mock.
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(mockString);
            res.setStatusCode(200);
            return res;
        }else{
            String mockString = '{"ok":true,"id":"03071242022203900013","errorCode":"","message":""}';
        
            // Crear respueta mock.
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(mockString);
            res.setStatusCode(200);
            return res;
        }
         
    }
}