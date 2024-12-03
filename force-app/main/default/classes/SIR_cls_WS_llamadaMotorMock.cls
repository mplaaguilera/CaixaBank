/*****************************************************************
    Name:  SIR_cls_WS_llamadaMotorMock
    Copyright © 2021  CaixaBank
    ============================================================
    Proposito:   Clases Mock necesario de la clase de test del WS en la clase SIR_cls_WS_llamadaMotor                                                                                               
    ============================================================
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US258825         Atmira         04/10/2021     	  Created    

    *****************************************************************/
    
@isTest  
public with sharing class SIR_cls_WS_llamadaMotorMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        SIR_cls_WS_llamadaMotor.LLamadaMotorRequest request = (SIR_cls_WS_llamadaMotor.LLamadaMotorRequest)JSON.deserialize(req.getBody(), SIR_cls_WS_llamadaMotor.LLamadaMotorRequest.class);
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        Map<String, Object> respMap = new  Map<String, Object>();
        if(request.tipoDialogoImp == 'SEL' || request.tipoDialogoImp == 'DAT'){
            Map<String, Object> respuestaMap = new  Map<String, Object>(); 
            Map<String, Object> infoMap = new  Map<String, Object>();
            Map<String, Object> errorMap = new  Map<String, Object>();
            infoMap.put('codigo', 1);    
            respuestaMap.put('idProceso',request.idProceso);
            respuestaMap.put('idActividad',123456);     
            respMap.put('respuesta', respuestaMap);
            respMap.put('info', infoMap);
            respMap.put('idProceso', infoMap);
            List<Object> lstError = new List<Object>();
            lstError.add(errorMap);
            respMap.put('error', lstError);
            response.setStatusCode(200);
        }else{
            Map<String, Object> respuestaMap = new  Map<String, Object>(); 
            Map<String, Object> infoMap = new  Map<String, Object>();
            infoMap.put('codigo', 0);
            infoMap.put('descripcion', 'Descripcion de tipo tarea Erroneo');           
            respMap.put('respuesta', respuestaMap);
            respMap.put('info', infoMap);
            response.setStatusCode(200);
        }
        response.setBody(Json.serializePretty(respMap));
        return response;
    }

}