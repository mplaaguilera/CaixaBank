/*****************************************************************
    Name:  SIR_cls_WS_SIRECMock
    Copyright © 2021  CaixaBank
    ============================================================
    Proposito:   Clases Mock necesario de la clase de test del WS en la clase SIR_cls_WS_SIREC                                                                                               
    ============================================================
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US258825         Atmira         03/10/2021     	  Created    

    *****************************************************************/

@isTest
global with sharing class SIR_cls_WS_SIRECMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        Map<String, Object> request = (Map<String, Object>)JSon.deserializeUntyped(req.getBody());       
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');   
        Map<String, Object> respMap = new  Map<String, Object>();
    
        String requestValue = (String)request.get('requestValue');
        if(requestValue == 'respuestaCorrecta'){
            Map<String, Object> respuestaMap = new  Map<String, Object>(); 
            Map<String, Object> infoMap = new  Map<String, Object>();
            infoMap.put('codigo', 1);           
            respMap.put('respuesta', respuestaMap);
            respMap.put('info', infoMap);
            response.setStatusCode(200);
        }
        else if(requestValue == 'respuestaInCorrecta'){
            Map<String, Object> respuestaMap = new  Map<String, Object>();
            Map<String, Object> infoMap = new  Map<String, Object>();
            infoMap.put('codigo', 0);
            infoMap.put('descripcion', 'Descripción del error');
            respMap.put('info', infoMap);
            respMap.put('respuesta', respuestaMap);
            response.setStatusCode(200);
        }else{
            Map<String, Object> errorMap = new  Map<String, Object>();
            errorMap.put('codigo', '0');
            errorMap.put('mensaje', 'Mensaje del error');
            List<Object> lstError = new List<Object>();
            lstError.add(errorMap);
            respMap.put('error', lstError);
            response.setStatusCode(500);
        }
        response.setBody(Json.serializePretty(respMap));
        return response;
    }
}