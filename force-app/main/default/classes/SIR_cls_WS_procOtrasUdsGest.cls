/*****************************************************************
    Name:  SIR_cls_WS_procOtrasUdsGest
    Copyright © 2021  CaixaBank

    Proposito:   WS0003 - Consulta en Sirec de procesos de otras unidades de gestion                                                                                                           

        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US271097         Atmira         17/09/2021     	  Created    

    *****************************************************************/


public with sharing class SIR_cls_WS_procOtrasUdsGest {

    public static List<String> getProcOtrasUdsGest(SIREC__SIREC_obj_informacionCliente__c informacionCliente){
        List<String> lstResponse = new List<String>();
        List<ProcesoOtrasUnidGestDto> otrosProcesos = new List<ProcesoOtrasUnidGestDto>();
        // Crear HEADER
        Map<String,string> mHeaders =  new  Map<String,string>();
        mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

        // Body
        ProcOtrasUdsGestRequest vBody =  new ProcOtrasUdsGestRequest(informacionCliente);

        if(!SIR_WS_Configuration__mdt.getInstance('procOtrasUdsGest').SIR_fld_isActive__c){
            // MOCK TEST[START]
            String otrosProcesosJson = procOtrasUdsGestRequestMock(JSON.serialize(vBody));
            ProcOtrasUdsGestResponse resp = (ProcOtrasUdsGestResponse)JSon.deserialize(otrosProcesosJson, ProcOtrasUdsGestResponse.class);
            lstResponse.add('OK');
            lstResponse.add(JSON.serializePretty(resp.datosResponseDto));
            // MOCK TEST[END]
        }else{
            try {
                HttpRequest req = CBK_HttpServiceIntegration.getRequest(JSON.serialize(vBody), 'consProcOtrasUdsGest', 'POST', mHeaders);
                HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req);
                if(res.getStatusCode() == 200){
                    ProcOtrasUdsGestResponse resp = (ProcOtrasUdsGestResponse)JSon.deserialize(res.getBody(), ProcOtrasUdsGestResponse.class);        
                    if( resp.codigoSalida == '1'){
                        otrosProcesos = resp.datosResponseDto.listaProcesoOtrasUnidGestDto;   
                        lstResponse.add('OK');
                        lstResponse.add(JSON.serializePretty(resp.datosResponseDto));
                    }else{
                        return SIR_cls_WS_Wrapper.responseError(res.getStatusCode(),resp.errorResponseDto);
                    }
                }else{
                    SIR_cls_WS_Wrapper.ErrorResponseDto errorResponseDto = new SIR_cls_WS_Wrapper.ErrorResponseDto();
                    errorResponseDto.descripcionError = 'Problema con conexion';
                    errorResponseDto.codigoSoft = String.valueOf(res.getStatusCode());
                    return SIR_cls_WS_Wrapper.responseError(res.getStatusCode(),errorResponseDto);
                }
            } catch (Exception ex) {
                CBK_log.error(ex, 'Error : SIR_cls_WS_procOtrasUdsGest - ' + ex.getTypeName() + ': ' + ex.getMessage());
                //return SIR_cls_WS_Wrapper.responseError(res.getStatusCode(),resp.errorResponseDto);
            }
        }
        return lstResponse;

    }

    public static String procOtrasUdsGestRequestMock (String input){       
        ProcOtrasUdsGestRequest request = (ProcOtrasUdsGestRequest)JSon.deserialize(input, ProcOtrasUdsGestRequest.class);
        ProcOtrasUdsGestResponse responseJson = new ProcOtrasUdsGestResponse();
        List<ProcesoOtrasUnidGestDto> lstprocesos = new List<ProcesoOtrasUnidGestDto>();
        ProcesoOtrasUnidGestDto proceso = new ProcesoOtrasUnidGestDto();
        proceso.descripcion = 'E.4 – Nuevos impagos';
        proceso.fechaInicio =  '2021-07-16';
        proceso.descSituacion = 'Pendiente Inicio Gestión';
        proceso.fechaSituac =  '2021-07-28';
        proceso.empleado = 'Daniel Gonzalez';
        lstprocesos.add(proceso);
        DatosResponseDto datos = new DatosResponseDto();
        datos.listaProcesoOtrasUnidGestDto = new List<ProcesoOtrasUnidGestDto>();
        datos.listaProcesoOtrasUnidGestDto.addAll(lstprocesos);
        responseJson.datosResponseDto = datos;
        responseJson.codigoSalida = '1';
        return Json.serializePretty(responseJson);
    }


    //REQUEST
    public class ProcOtrasUdsGestRequest{
        public String idPersona;
        public ProcOtrasUdsGestRequest(SIREC__SIREC_obj_informacionCliente__c informacionCliente){
            idPersona = informacionCliente.SIREC__SIREC_fld_masterRecordId__c;

        }
    }

    //RESPONSE
    public class ProcOtrasUdsGestResponse{
        public String codigoSalida;
        public SIR_cls_WS_Wrapper.ErrorResponseDto errorResponseDto;
        public DatosResponseDto datosResponseDto;
    }
    public class DatosResponseDto{
        public List<ProcesoOtrasUnidGestDto> listaProcesoOtrasUnidGestDto;
    }

    public class ProcesoOtrasUnidGestDto{
        public String descripcion;
        public String fechaInicio;
        public String descSituacion;
        public String fechaSituac;
        public String empleado;
    }
}