/*****************************************************************
 Name:  SIR_cls_WS_EnviarComentarioMock
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clases Mock necesario de la clase de test del WS en la clase SIR_cls_WS_EnviarComentario                                                                                                        
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US271096         Atmira         15/09/2021     	  Created    

*****************************************************************/

@isTest
public with sharing class SIR_cls_WS_EnviarComentarioMock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        
        SIR_cls_WS_EnviarComentario.ComentarioGestorRequest request = (SIR_cls_WS_EnviarComentario.ComentarioGestorRequest)JSon.deserialize(req.getBody(), SIR_cls_WS_EnviarComentario.ComentarioGestorRequest.class);
        SIR_cls_WS_EnviarComentario.ComentarioGestorResponse responseJson = new SIR_cls_WS_EnviarComentario.ComentarioGestorResponse();
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        
        if(request.textoLibre == 'Comentario correcto'){
            response.setStatusCode(200);
            responseJson.codigoSalida = '1';
        }
        if(request.textoLibre == 'Comentario Incorrecto'){
            response.setStatusCode(200);
            responseJson.codigoSalida = '0';
            SIR_cls_WS_Wrapper.ErrorResponseDto error = new SIR_cls_WS_Wrapper.ErrorResponseDto();
            error.codigoSoft = 'errorCodigoSoft';
            error.codigoOracle = 'errorcodigoOracle';
            error.descripcionError = 'errordescripcionError';
            responseJson.errorResponseDto = error;
        }
        if(request.textoLibre == 'Fallo de conexión'){
            response.setStatusCode(404);
            responseJson.codigoSalida = '0';
            SIR_cls_WS_Wrapper.ErrorResponseDto error = new SIR_cls_WS_Wrapper.ErrorResponseDto();
            error.codigoSoft = 'errorCodigoSoft';
            error.codigoOracle = 'errorcodigoOracle';
            error.descripcionError = 'errordescripcionError';
            responseJson.errorResponseDto = error;
        }
        response.setBody(Json.serializePretty(responseJson));
        return response;
    }
}