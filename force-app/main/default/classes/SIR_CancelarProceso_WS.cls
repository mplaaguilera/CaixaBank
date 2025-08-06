/*****************************************************************
    Name:  SIR_CancelarProceso_WS
    Copyright © 2021  CaixaBank

    Proposito:   WS0000 - cancelar proceso                                                                                                          

        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249675         Atmira         17/09/2021     	  Created    

    *****************************************************************/
    public with sharing class SIR_CancelarProceso_WS {
  /*****************************************************************
    Proposito:  Wrapper                                                      
    Parameters: N/A
    Returns: N/A                                                       
    
    Historial
    -------- 
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249675         Atmira         05/08/2021     	  Created    
    
    *****************************************************************/
    public with sharing class WrapperclassProceso{
        
        @AuraEnabled
        public String usuarioBaja;
        @AuraEnabled
        public Integer idProcesoGestion;
    }
    /*****************************************************************
    Proposito:  cancelar proceso                                                      
    Parameters: proceso
    Returns: N/A                                                       
    
    Historial
    -------- 
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249675         Atmira         05/08/2021     	  Created    
    
    *****************************************************************/
    public static List<String> cancelarProceso(String procesoId){
        String metodo = 'sendAction';
        List<String> lstResponse = new List<String>();
        CancelarRequest request = new CancelarRequest();
        if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible()){
            SIREC__SIREC_obj_proceso__c proceso =[SELECT id ,SIREC__SIREC_fld_codigoEmpleado__c ,SIREC__SIREC_fld_masterRecordId__c
                                                            FROM SIREC__SIREC_obj_proceso__c 
                                                            WHERE Id=: procesoId];     
            if(proceso != null){
                    integer idProceso;
                    if(proceso.SIREC__SIREC_fld_masterRecordId__c != null){
                        request.idProcesoGestion = proceso.SIREC__SIREC_fld_masterRecordId__c;
                    }
                if(request != null){
                    // Crear HEADER
                    Map<String,string> mHeaders =  new  Map<String,string>();
                    mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
                    String intSetting = 'Pre-connection';
    
                    // Body
                    String body = JSON.serializePretty(request);
                    if(!SIR_WS_Configuration__mdt.getInstance('CancelarProceso').SIR_fld_isActive__c){
                        lstResponse.add('OK');
                        return lstResponse;
                    }else{
                        try {
                            HttpRequest req = CBK_HttpServiceIntegration.getRequest(body, 'cancelarProcRefinanciacion', 'POST', mHeaders);
                            HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req,'SIR','cancelarProcRefinanciacion');
                            if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                                CancelarResponse resp = (CancelarResponse)JSon.deserialize(res.getBody(), CancelarResponse.class);        
                                if( resp.codigoSalida == '1'){
                                    lstResponse.add('OK');
                                    return lstResponse;
                                    // Pendiente de ver como ocultamos el boton de cancelar habra que actualizar la situacion 
                                    //SIREC__SIREC_fld_situacion__c
                                }else{
                                    return SIR_cls_WS_Wrapper.responseError(res.getStatusCode(),resp.errorResponseDto);
                                }
                            }else{
                                return SIR_cls_WS_Wrapper.responseError(res.getStatusCode(),new SIR_cls_WS_Wrapper.ErrorResponseDto());
                            }
    
                        } catch (Exception ex) {
                            CBK_log.error(ex, 'Error : SIR_SendNewAction_WS - ' + ex.getTypeName() + ': ' + ex.getMessage());
                        }
                    }
                    
                    
                }
            }      
        }
        return lstResponse;
    }

    //REQUEST
    public class CancelarRequest{
        public String idProcesoGestion;
    }


    //RESPONSE
    public class CancelarResponse{
        public String codigoSalida;
        public SIR_cls_WS_Wrapper.ErrorResponseDto errorResponseDto;
    }

    
}