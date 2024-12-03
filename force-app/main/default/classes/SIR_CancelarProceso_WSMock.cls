@isTest
global with sharing class SIR_CancelarProceso_WSMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        
        SIR_CancelarProceso_WS.CancelarRequest request = (SIR_CancelarProceso_WS.CancelarRequest)JSon.deserialize(req.getBody(), SIR_CancelarProceso_WS.CancelarRequest.class);
        SIR_CancelarProceso_WS.CancelarResponse responseJson = new SIR_CancelarProceso_WS.CancelarResponse();
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        
        if(request.idProcesoGestion == 'Idcorrecto'){
            response.setStatusCode(200);
            responseJson.codigoSalida = '1';
        }
        if(request.idProcesoGestion == 'IdIncorrecto'){
            response.setStatusCode(200);
            responseJson.codigoSalida = '0';
            SIR_cls_WS_Wrapper.ErrorResponseDto error = new SIR_cls_WS_Wrapper.ErrorResponseDto();
            error.codigoSoft = 'errorCodigoSoft';
            error.codigoOracle = 'errorcodigoOracle';
            error.descripcionError = 'errordescripcionError';
            responseJson.errorResponseDto = error;
        }
        if(request.idProcesoGestion == 'Fallo de conexión'){
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