@isTest
public with sharing class CC_WS_Mock_Autenticacion_SAU implements HttpCalloutMock {
    
    Integer statusCode;
    public CC_WS_Mock_Autenticacion_SAU(Integer strStatusCode) {
        statusCode = strStatusCode;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        
        if (statusCode == 200) {
            String responseBody = '{'
            + '"existContract":"EXIST_CONTRACT",'
            + '"cloContract":"pruebaContract",'
            + '"cloUser": "pruebaUser"'
            + '}';
            
            res.setBody(responseBody);
            res.setStatusCode(200);
        } else if (this.statusCode == 404) {
            String responseBody = '{'
            + '"existContract":"NO_CONTRACT"'
            + '}';
            res.setBody(responseBody);
            res.setStatusCode(404);
        }
        return res;
    }
}