/*****************************************************************
    Name: SIR_cls_WS_altaProcRefinanciacionMock
    Copyright © 2021 CaixaBank
    ============================================================
    Proposito: Clases Mock necesario de la clase de test del WS en la clase SIR_cls_WS_altaProcRefinanciacio                                                                                               
    ============================================================
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US258825         Atmira         17/09/2021     	  Created    

*****************************************************************/
@isTest
public with sharing class SIR_cls_WS_altaProcRefinanciacionMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        SIR_cls_WS_altaProcRefinanciacion.AltaProcRefinanciacionRequest request = (SIR_cls_WS_altaProcRefinanciacion.AltaProcRefinanciacionRequest)JSon.deserialize(req.getBody(), SIR_cls_WS_altaProcRefinanciacion.AltaProcRefinanciacionRequest.class);
        SIR_cls_WS_altaProcRefinanciacion.AltaProcRefinanciacionResponse responseJson = new SIR_cls_WS_altaProcRefinanciacion.AltaProcRefinanciacionResponse();
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        SIR_cls_WS_altaProcRefinanciacion.DatosResponseDto datosResponseDto = new SIR_cls_WS_altaProcRefinanciacion.DatosResponseDto();
        if(request.idPersona == 'Correcto') {
            datosResponseDto.idProcesoGestion = 'IdProcesoCorrecto';
            responseJson.datosResponseDto = datosResponseDto;
            response.setStatusCode(200);
            responseJson.codigoSalida = '1';
        }else if(request.idPersona == 'INCorrecto') {
            response.setStatusCode(200);
            responseJson.codigoSalida = '0';
            SIR_cls_WS_Wrapper.ErrorResponseDto error = new SIR_cls_WS_Wrapper.ErrorResponseDto();
            error.descripcionError = 'error';
            responseJson.errorResponseDto = error;
        }else{
            response.setStatusCode(404);
            responseJson.codigoSalida = '0';
        }   
        response.setBody(Json.serializePretty(responseJson));
        return response;
    }
}