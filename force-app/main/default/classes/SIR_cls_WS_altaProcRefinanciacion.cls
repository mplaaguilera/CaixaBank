/*****************************************************************
    Name:  SIR_cls_WS_altaProcRefinanciacion
    Copyright © 2021  CaixaBank

    Proposito:   WS0006 - Envio a sirec de procesos de refinanciación                                                                                                           

        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US258825         Atmira         17/09/2021     	  Created    

    *****************************************************************/

public with sharing class SIR_cls_WS_altaProcRefinanciacion {
    public static List<String> altaProcRefinanciacion(String idProceso){
        List<String> lstResponse = new List<String>();
        Map<String,string> mHeaders =  new  Map<String,string>();
        String metodo = 'SIR_cls_WS_altaProcRefinanciacion';
        mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
        AltaProcRefinanciacionRequest vBody =  new AltaProcRefinanciacionRequest(idProceso);
        String idProcesoSirec;
        if(!SIR_WS_Configuration__mdt.getInstance('altaProcRefinanciacion').SIR_fld_isActive__c){            
            // MOCK TEST[START]
            String procesoJson = altaProcRefinanciacionMock(JSON.serialize(vBody));
            AltaProcRefinanciacionResponse resp = (AltaProcRefinanciacionResponse)JSon.deserialize(procesoJson, AltaProcRefinanciacionResponse.class);
            lstResponse.add('OK');
            lstResponse.add(resp.datosResponseDto.idProcesoGestion);
            // MOCK TEST[END]
        }else{
            try {                
                HttpRequest req = CBK_HttpServiceIntegration.getRequest(JSON.serialize(vBody), 'altaProcRefinanciacion', 'POST', mHeaders);                
                HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req,'SIR','altaProcRefinanciacion');                 
                                
                if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                    AltaProcRefinanciacionResponse resp = (AltaProcRefinanciacionResponse)JSon.deserialize(res.getBody(), AltaProcRefinanciacionResponse.class);        
                    if( resp.codigoSalida == '1'){
                        lstResponse.add('OK');
                        lstResponse.add(resp.datosResponseDto.idProcesoGestion);
                    }else{
                        return SIR_cls_WS_Wrapper.responseError(res.getStatusCode(),resp.errorResponseDto);
                    }
                }
                else{
                      return SIR_cls_WS_Wrapper.responseError(res.getStatusCode(),null);
                }
            } catch (Exception ex) {                
                CBK_log.error(ex, 'Error : SIR_SendNewAction_WS - ' + ex.getTypeName() + ': ' + ex.getMessage());
            }
            
        }        
        return lstResponse;
    }

    public static String altaProcRefinanciacionMock(String input){
        AltaProcRefinanciacionRequest request = (AltaProcRefinanciacionRequest)JSon.deserialize(input, AltaProcRefinanciacionRequest.class);
        AltaProcRefinanciacionResponse responseJson = new AltaProcRefinanciacionResponse();
        String idProcesoSirec = 'idProcesoSirec' + Integer.valueof((Math.random() * 100));
        DatosResponseDto datosResponseDto = new DatosResponseDto();
        datosResponseDto.idProcesoGestion = idProcesoSirec;
        responseJson.datosResponseDto = datosResponseDto;
        responseJson.codigoSalida = '0';
        return Json.serializePretty(responseJson);
    }
    //REQUEST

    public with sharing class AltaProcRefinanciacionRequest{
        public String empleado;
        public String fechaInicio;
        public List<String> idCuentas = new List<String>() ;
        public String idPersona;
        public List<String> idPersonas = new List<String>();
        public AltaProcRefinanciacionRequest(String idProceso){

            if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible() &&
                Schema.SObjectType.SIREC__SIREC_obj_personaAsociada__c.isAccessible() &&
                Schema.SObjectType.SIREC__SIREC_obj_informacionCliente__c.isAccessible() &&
                Schema.SObjectType.SIREC__SIREC_obj_procesoContrato__c.isAccessible()){

                SIREC__SIREC_obj_proceso__c proceso = [SELECT Id, SIREC__SIREC_fld_codigoEmpleado__c, SIREC__SIREC_fld_fechaInicio__c, SIREC__SIREC_fld_cliente__c  
                                                            FROM SIREC__SIREC_obj_proceso__c
                                                            WHERE Id = :idProceso];
                
                empleado = proceso.SIREC__SIREC_fld_codigoEmpleado__c;
                fechaInicio = SIR_cls_WS_Wrapper.formatDate(proceso.SIREC__SIREC_fld_fechaInicio__c);

                Set<id> setAccountIds = new Set<Id>();
                setAccountIds.add(proceso.SIREC__SIREC_fld_cliente__c);
                for (SIREC__SIREC_obj_personaAsociada__c personaAsocianda : [SELECT SIREC__SIREC_fld_persona__c 
                                                                                FROM SIREC__SIREC_obj_personaAsociada__c 
                                                                                WHERE SIREC__SIREC_fld_proceso__c = :proceso.Id AND SIR_estadoCarga__c != 'B']) {
                    setAccountIds.add(personaAsocianda.SIREC__SIREC_fld_persona__c);
                }
                Map<Id,String> mapClienteIdPersona = new Map<Id,String>();
                for (SIREC__SIREC_obj_informacionCliente__c informacionCLiente : [SELECT  SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_masterRecordId__c
                                                                            FROM SIREC__SIREC_obj_informacionCliente__c
                                                                            WHERE SIREC__SIREC_fld_cliente__c IN :setAccountIds]) {
                    mapClienteIdPersona.put(informacionCliente.SIREC__SIREC_fld_cliente__c, informacionCliente.SIREC__SIREC_fld_masterRecordId__c);
                }
                for(Id clienteId : mapClienteIdPersona.keySet()){
                    if(clienteId == proceso.SIREC__SIREC_fld_cliente__c){
                        idPersona = mapClienteIdPersona.get(clienteId);
                    }
                    idPersonas.add(mapClienteIdPersona.get(clienteId));
                }

                for (SIREC__SIREC_obj_procesoContrato__c procesoContrato : [SELECT Id, SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_masterRecordI__c
                                                                        FROM SIREC__SIREC_obj_procesoContrato__c
                                                                        WHERE SIREC__SIREC_fld_proceso__c = : proceso.Id AND SIR_estadoCarga__c != 'B']) {
                    idCuentas.add(procesoContrato.SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_masterRecordI__c);
                }
            }
        }
    }


    //RESPONSE
    public class AltaProcRefinanciacionResponse{
        public String codigoSalida;
        public SIR_cls_WS_Wrapper.ErrorResponseDto errorResponseDto;
        public DatosResponseDto datosResponseDto;
    }

    public class DatosResponseDto{
        public String idProcesoGestion;
    }

}