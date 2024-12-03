/*****************************************************************
    Name:  SIR_cls_WS_altaAccionWorkflowMock
    Copyright © 2021  CaixaBank
    ============================================================
    Proposito:   Clase Mock para la clase de test SIR_cls_WS_altaAccionWorkflow                                                                                                     
    ============================================================
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US448852         Atmira         03/10/2022     	  Created    

    *****************************************************************/
    @isTest
    global with sharing class SIR_cls_WS_altaAccionWorkflowMock implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest req) {
           
            SIR_cls_WS_altaAccionWorkflow.WrapperclassAction request = (SIR_cls_WS_altaAccionWorkflow.WrapperclassAction)JSon.deserialize(req.getBody(), SIR_cls_WS_altaAccionWorkflow.WrapperclassAction.class);
                   
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            if(request.codigoAccion == '01'){
                response.setStatusCode(200);                
                response.setBody(Json.serializePretty(SIR_TestDataFactory.createSirecRespone(1,'','')));                  
            }else if(request.codigoAccion == '10'){
                response.setStatusCode(200);
                response.setBody(Json.serializePretty(SIR_TestDataFactory.createSirecRespone(0,'','')));               
            }else if(request.codigoAccion == '02'){
                response.setStatusCode(200);
                response.setBody(Json.serializePretty(SIR_TestDataFactory.createSirecRespone(1,'','')));               
            }else if(request.comentario == 'Acción INCORRECTA'){
                response.setStatusCode(500);
                response.setBody(Json.serializePretty(SIR_TestDataFactory.createSirecRespone(0,'Acción INCORRECTA','')));                    
            }else{
                response.setStatusCode(500);
                response.setBody(Json.serializePretty(SIR_TestDataFactory.createSirecErrorRespone('API-APP-001','No existe el codigo de PERSONA para la ACCION_PERSONA ; operacion cancelada','')));                    
            }            
            return response;
        }
    }