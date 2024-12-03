/*****************************************************************
    Name:  SIR_SendNewAction_WSMock
    Copyright © 2021  CaixaBank
    ============================================================
    Proposito:   Clase Mock para la clase de test SIR_SendNewAction_Test                                                                                                     
    ============================================================
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            USXXXXXX         Atmira         17/09/2021     	  Created    

    *****************************************************************/
@isTest
global with sharing class SIR_SendNewAction_WSMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        SIR_SendNewAction_WS.WrapperclassAction request = (SIR_SendNewAction_WS.WrapperclassAction)JSon.deserialize(req.getBody(), SIR_SendNewAction_WS.WrapperclassAction.class);
        SIR_SendNewAction_WS.AccionResponse responseJson = new SIR_SendNewAction_WS.AccionResponse();
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        if(request.codigoAccion == '01'){
            response.setStatusCode(200);
            responseJson.codigoSalida = '1';
            SIR_SendNewAction_WS.DatosResponseDto responseDto = new SIR_SendNewAction_WS.DatosResponseDto();
            responseDto.codigoSit = 'cod';
            responseJson.datosResponseDto = responseDto;

        }else if(request.codigoAccion == '10'){
            response.setStatusCode(200);
            responseJson.codigoSalida = '0';
            SIR_cls_WS_Wrapper.ErrorResponseDto error = new SIR_cls_WS_Wrapper.ErrorResponseDto();
            error.descripcionError = 'error';
            responseJson.errorResponseDto = error;
            
        }else if(request.codigoAccion == '02'){
            response.setStatusCode(200);
            responseJson.codigoSalida = '1';
            SIR_SendNewAction_WS.DatosResponseDto responseDto = new SIR_SendNewAction_WS.DatosResponseDto();
            responseDto.codigoSit = null;
            responseJson.datosResponseDto = responseDto;
            
        }else{
            response.setStatusCode(404);
            responseJson.codigoSalida = '0';
        }
        response.setBody(Json.serializePretty(responseJson));
        return response;
    }
}