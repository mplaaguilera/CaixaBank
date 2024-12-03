/*****************************************************************
 Name:  SIR_cls_WS_procOtrasUdsGestMock
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clases Mock necesario de la clase de test del WS en la clase SIR_cls_WS_procOtrasUdsGest                                                                                                        
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US271096         Atmira         15/09/2021     	  Created    

*****************************************************************/

@isTest
global with sharing class SIR_cls_WS_procOtrasUdsGestMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        SIR_cls_WS_procOtrasUdsGest.ProcOtrasUdsGestRequest request = (SIR_cls_WS_procOtrasUdsGest.ProcOtrasUdsGestRequest)JSon.deserialize(req.getBody(), SIR_cls_WS_procOtrasUdsGest.ProcOtrasUdsGestRequest.class);
        SIR_cls_WS_procOtrasUdsGest.ProcOtrasUdsGestResponse responseJson = new SIR_cls_WS_procOtrasUdsGest.ProcOtrasUdsGestResponse();
        List<SIR_cls_WS_procOtrasUdsGest.ProcesoOtrasUnidGestDto> lstprocesos = new List<SIR_cls_WS_procOtrasUdsGest.ProcesoOtrasUnidGestDto>();
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        SIR_cls_WS_procOtrasUdsGest.ProcesoOtrasUnidGestDto proceso = new SIR_cls_WS_procOtrasUdsGest.ProcesoOtrasUnidGestDto();
        proceso.descripcion = 'E.4 – Nuevos impagos';
        proceso.fechaInicio =  '2021-07-16';
        proceso.descSituacion = 'Pendiente Inicio Gestión';
        proceso.fechaSituac =  '2021-07-28';
        proceso.empleado = 'Daniel Gonzalez';
        lstprocesos.add(proceso);
        SIR_cls_WS_procOtrasUdsGest.DatosResponseDto datos = new SIR_cls_WS_procOtrasUdsGest.DatosResponseDto();
        datos.listaProcesoOtrasUnidGestDto = new List<SIR_cls_WS_procOtrasUdsGest.ProcesoOtrasUnidGestDto>();
        datos.listaProcesoOtrasUnidGestDto.addAll(lstprocesos);
        if(request.idPersona == 'IdCorrecto'){
            response.setStatusCode(200);
            responseJson.datosResponseDto = datos;
            responseJson.codigoSalida = '1'; 
        }else if(request.idPersona == 'IdINCorrecto'){
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