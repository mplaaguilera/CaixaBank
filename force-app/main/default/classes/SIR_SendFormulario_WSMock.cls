/*****************************************************************
    Name:  SIR_SendFormulario_WSMock
    Copyright © 2021  CaixaBank
      
    Proposito:   Clase Mock para la clase de test SIR_SendNewAction_Test                                                                                                     
      
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            USXXXXXX         Atmira         02/02/2022     	  Created    

    *****************************************************************/
    @isTest
global with sharing class SIR_SendFormulario_WSMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        SIR_WrapperEnviarFormulario request = (SIR_WrapperEnviarFormulario)JSon.deserialize(req.getBody(), SIR_WrapperEnviarFormulario.class);
        SIR_SendFormulario_WS.FormularioResponse responseJson = new SIR_SendFormulario_WS.FormularioResponse();
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        if(request.cargasComentario == 'correcto'){
            response.setStatusCode(200);
            responseJson.codigoSalida = '1';
        }
        else if(request.cargasComentario == 'incorrecto'){
            response.setStatusCode(200);
            responseJson.codigoSalida = '0';
        }
        response.setBody(Json.serializePretty(responseJson));
        return response;
    }
}