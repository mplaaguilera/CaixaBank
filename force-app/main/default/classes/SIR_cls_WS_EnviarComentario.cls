/*****************************************************************
     Name:  SIR_cls_WS_EnviarComentario
    Copyright © 2021  CaixaBank
    Proposito:   WS0003 - Envío de comentario de gestor                                                                                                            
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US271096            Atmira         17/09/2021     	  Created    

    *****************************************************************/


public with sharing class SIR_cls_WS_EnviarComentario {
    @future(Callout=true)
    public static void sendfutureComentario(List<Id> lstInformacionCliente) {
        // Crear HEADER
        Map<String,string> mHeaders =  new  Map<String,string>();
        mHeaders.put('Content-Type', 'application/json;charset=UTF-8');        

        if(Schema.SObjectType.SIREC__SIREC_obj_informacionCliente__c.isAccessible()){

            for (SIREC__SIREC_obj_informacionCliente__c informacionCliente : [SELECT Id, SIREC__SIREC_fld_codigoEmpleado__c, SIREC__SIREC_fld_fechaModificacion__c, SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_comentariosRecuperaciones__c
                                                                                    FROM SIREC__SIREC_obj_informacionCliente__c
                                                                                    WHERE Id IN:lstInformacionCliente]) {
                ComentarioGestorRequest vBody =  new ComentarioGestorRequest(informacionCliente);
                
                String comentario;
                ComentarioGestorResponse resp;
                if(!SIR_WS_Configuration__mdt.getInstance('EnviarComentario').SIR_fld_isActive__c){
                    // MOCK TEST[START]
                    comentario = sendComentarioMock(JSON.serialize(vBody));
                    resp = (ComentarioGestorResponse)JSon.deserialize(comentario, ComentarioGestorResponse.class);

                    // MOCK TEST[END]
                } else {
                    try {
                        HttpRequest req = CBK_HttpServiceIntegration.getRequest(JSON.serialize(vBody), 'altaComentarioGestor', 'POST', mHeaders);
                        //HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req);
                        HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req,'SIR', 'altaComentarioGestor');
                        if(res.getStatusCode() == 200){
                            resp = (ComentarioGestorResponse)JSon.deserialize(res.getBody(), ComentarioGestorResponse.class);        
                            if( resp.codigoSalida != '1'){
                                CBK_log.error('Error : SIR_cls_WS_EnviarComentario - ' + resp.errorResponseDto.codigoSoft + ': ' + resp.errorResponseDto.descripcionError);
                            }
                        }
                        else{
                            CBK_log.error('Error : SIR_cls_WS_EnviarComentario - ' + res.getStatusCode() + ': ' + res.getBody());
                        }
                    } catch (Exception ex) {
                        CBK_log.error(ex, 'Error : SIR_cls_WS_EnviarComentario - ' + ex.getTypeName() + ': ' + ex.getMessage());
                    }
                }
            
            }
        }
    }

    @InvocableMethod(label='Enviar Comentario a Sirec' description='Enviar comentario a Sirec')
    public static void sendComentario(List<Id> lstInformacionCliente) {
        sendfutureComentario(lstInformacionCliente);
    }

    
    public static String sendComentarioMock (String input){       
        ComentarioGestorRequest request = (ComentarioGestorRequest)JSon.deserialize(input, ComentarioGestorRequest.class);
        ComentarioGestorResponse responseJson = new ComentarioGestorResponse();
        
        if(request.idPersona == 'empleado correcto'){
            responseJson.codigoSalida = '1';
        }else{
            responseJson.codigoSalida = '0';
            SIR_cls_WS_Wrapper.ErrorResponseDto error = new SIR_cls_WS_Wrapper.ErrorResponseDto();
            error.codigoSoft = 'errorCodigoSoft';
            error.codigoOracle = 'errorcodigoOracle';
            error.descripcionError = 'errordescripcionError';
            responseJson.errorResponseDto = error;
        }
        
        return Json.serializePretty(responseJson);
    }


    //REQUEST
    public class ComentarioGestorRequest{
        public String empleado;
        public String fechaAnotac;
        public String idPersona;
        public String textoLibre;
        public ComentarioGestorRequest(SIREC__SIREC_obj_informacionCliente__c informacionCliente){
            empleado = informacionCliente.SIREC__SIREC_fld_codigoEmpleado__c;
            fechaAnotac = SIR_cls_WS_Wrapper.formatDate(informacionCliente.SIREC__SIREC_fld_fechaModificacion__c);
            idPersona = informacionCliente.SIREC__SIREC_fld_masterRecordId__c;
            textoLibre = informacionCliente.SIREC__SIREC_fld_comentariosRecuperaciones__c;
        }
    }
    //RESPONSE
    public class ComentarioGestorResponse{
        public String codigoSalida;
        public SIR_cls_WS_Wrapper.ErrorResponseDto errorResponseDto;

    }

}