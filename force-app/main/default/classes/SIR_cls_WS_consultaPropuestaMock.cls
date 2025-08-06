@isTest
public with sharing class SIR_cls_WS_consultaPropuestaMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse response = new HttpResponse();
        Map<String, Object> respMap = new  Map<String, Object>();
        Map<String, Object> cabecera = new  Map<String, Object>(); 
        Map<String, Object> seccionPago = new  Map<String, Object>(); 
        Map<String, Object> pagoCicloActual = new  Map<String, Object>(); 
        Map<String, Object> historicoPagos = new  Map<String, Object>(); 
        Map<String, Object> infoMap = new  Map<String, Object>();
        Map<String, Object> errorMap = new  Map<String, Object>();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        cabecera.put('nombreCompleto','NOMBRE COMPLETO');
        cabecera.put('documento','DOCUMENTO');     
        seccionPago.put('descripcionCodEstado','VIGENTE');    
        pagoCicloActual.put('fechaPago','23/04/2024'); 
        historicoPagos.put('fechaPagoHis','23/04/2024'); 
        List<Object> lstPagos = new List<Object>();
        lstPagos.add(historicoPagos);
        //
        respMap.put('cabecera', cabecera);
        respMap.put('seccionPago', seccionPago);
        respMap.put('pagoCicloActual', pagoCicloActual);
        respMap.put('historicoPagos', lstPagos);
        respMap.put('info', infoMap);
        
        List<Object> lstError = new List<Object>();
        lstError.add(errorMap);
        respMap.put('error', lstError);
        if(req.getEndpoint().equals('callout:consultaPropuesta/OK')){
            infoMap.put('codigo', 1);    
            response.setBody(Json.serializePretty(respMap));
        } else if(req.getEndpoint().equals('callout:consultaPropuesta/ERROR')){
            infoMap.put('codigo', 2);    
            response.setBody(Json.serializePretty(respMap));        
        }else if(req.getEndpoint().equals('callout:consultaPropuesta/NOK')){
            response.setStatusCode(500);
            infoMap.put('codigo', 1);    
            response.setBody(Json.serializePretty(respMap));
        }
        
        return response;

    }

}