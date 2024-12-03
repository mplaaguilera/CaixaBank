@isTest
public with sharing class SIR_cls_WS_procesoInfoMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse response = new HttpResponse();
        Map<String, Object> respMap = new  Map<String, Object>();
        Map<String, Object> respuestaMap = new  Map<String, Object>(); 
        Map<String, Object> infoMap = new  Map<String, Object>();
        Map<String, Object> errorMap = new  Map<String, Object>();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        respuestaMap.put('idProceso',123456);
        respuestaMap.put('idActividad',123456);     
        respMap.put('respuesta', respuestaMap);
        respMap.put('info', infoMap);
        respMap.put('idProceso', infoMap);
        List<Object> lstError = new List<Object>();
        lstError.add(errorMap);
        respMap.put('error', lstError);

        if(req.getEndpoint().equals('callout:procesoInfo/12345645')){
            infoMap.put('codigo', 1);    
            response.setBody(Json.serializePretty(respMap));
        } else if(req.getEndpoint().equals('callout:procesoInfo/12345646')){
            infoMap.put('codigo', 2);    
            response.setBody(Json.serializePretty(respMap));
        }else if(req.getEndpoint().equals('callout:procesoInfo/12345647')){
            response.setStatusCode(300);
            infoMap.put('codigo', 1);    
            response.setBody(Json.serializePretty(respMap));
        }else if(req.getEndpoint().equals('callout:procesoInfo/12345648')){
            response.setStatusCode(500);
            infoMap.put('codigo', 1);    
            response.setBody(Json.serializePretty(respMap));
        }
        
        return response;

    }

}