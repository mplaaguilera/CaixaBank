/*****************************************************************
    Name:  SIR_SendNewAction_WS
    Copyright © 2021  CaixaBank
      
    Proposito:   WS0001 - Envio a sirec de acciones con resultado                                                                                                           
      
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US249675         Atmira         17/09/2021     	  Created    

    *****************************************************************/
    public with sharing class SIR_SendNewAction_WS {
        
        @TestVisible
    	public static Boolean throwException = false;
        

    /*****************************************************************
    Proposito:  Wrapper                                                      
    Parameters: N/A
    Returns: N/A                                                       
    
    Historial
    -------- 
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249675         Atmira         05/08/2021     	  Created    
    
    *****************************************************************/
    public class WrapperclassAction{
        
        @AuraEnabled
        public String codigoAccion;
        @AuraEnabled
        public String codigoResultadoAccion;
        @AuraEnabled
        public String codigoTipoAccion;
        @AuraEnabled
        public String comentario;
        @AuraEnabled
        public String fechaAccion;
        @AuraEnabled
        public String empleado;
        @AuraEnabled
        public Integer idPersonaContactada;
        @AuraEnabled
        public List<Integer> idPersonas;
        @AuraEnabled
        public String idProcesoGestion;
    }

    public class ListWrapperclassAction{
        public List<WrapperclassAction> lstWrapperclassAction;
        
    }
    /***************************************************************** 
    Proposito:  Send Action                                                      
    Parameters: acciones
    Returns: N/A                                                       
    
    Historial
    -------- 
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US249675         Atmira         05/08/2021     	  Created    
    
    *****************************************************************/
    public static List<String> sendAction(String accionId){
        List<String> lstResponse = new List<String>();
        WrapperclassAction wrapper = new WrapperclassAction();
        if(Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isAccessible() && Schema.SObjectType.SIREC__SIREC_obj_informacionCliente__c.isAccessible()){
            List<Integer> listIdPersonas = new List<Integer>();
            
            SIREC__SIREC_obj_acciones__c accion = [SELECT id ,SIREC__SIREC_fld_accion__c , SIREC__SIREC_fld_resultado__c , SIREC__SIREC_fld_tipo__c,
                                                                SIREC__SIREC_fld_comentarios__c , SIREC__SIREC_fld_responsable__c , SIREC__SIREC_fld_interviniente__c,
                                                                SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c ,SIREC__SIREC_fld_persona__c ,SIREC__SIREC_fld_fechaContacto__c
                                                                FROM SIREC__SIREC_obj_acciones__c 
                                                                WHERE Id = :accionId];
                                                                            
            String gestor = null;
            if(accion.SIREC__SIREC_fld_responsable__c != null && Schema.SObjectType.USER.isAccessible()){
                List <USER> usuario = [SELECT id ,EmployeeNumber FROM USER WHERE id =: accion.SIREC__SIREC_fld_responsable__c];
                if(usuario[0].EmployeeNumber != null){
                    gestor = usuario[0].EmployeeNumber;
                }
            }
            Set<Id> setIds = new Set<Id>();
            setIds.add(accion.SIREC__SIREC_fld_interviniente__c);
            setIds.add(accion.SIREC__SIREC_fld_persona__c);
            
            integer idContactada = null;
            for(SIREC__SIREC_obj_informacionCliente__c persona :[SELECT  SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_masterRecordId__c
                                                                FROM SIREC__SIREC_obj_informacionCliente__c
                                                                WHERE SIREC__SIREC_fld_cliente__c IN :setIds]){
                if(persona.SIREC__SIREC_fld_cliente__c == accion.SIREC__SIREC_fld_interviniente__c){
                    idContactada = integer.valueOf(persona.SIREC__SIREC_fld_masterRecordId__c); 
                }
                if(persona.SIREC__SIREC_fld_cliente__c == accion.SIREC__SIREC_fld_persona__c){
                    listIdPersonas.add(integer.valueOf(persona.SIREC__SIREC_fld_masterRecordId__c));
                }
            }
            /*
            // Recuperamos el masterRecordId de la persona contactada que es el parametro que espera recibir sirec
            List<SIREC__SIREC_obj_informacionCliente__c> personaContactada = [SELECT  SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_masterRecordId__c
                                                                                FROM SIREC__SIREC_obj_informacionCliente__c
                                                                                WHERE SIREC__SIREC_fld_cliente__c =: accion.SIREC__SIREC_fld_interviniente__c];
            integer idContactada = null;
            if(personaContactada.size()> 0){
                idContactada = integer.valueOf(personaContactada[0].SIREC__SIREC_fld_masterRecordId__c); 
            }
            // Recuperamos el masterRecordId de la persona asociada al proceso que es el parametro que espera recibir sirec
            List<SIREC__SIREC_obj_informacionCliente__c> personaProceso = [SELECT  SIREC__SIREC_fld_cliente__c, SIREC__SIREC_fld_masterRecordId__c
                                                                                FROM SIREC__SIREC_obj_informacionCliente__c
                                                                                WHERE SIREC__SIREC_fld_cliente__c =: accion.SIREC__SIREC_fld_persona__c];
                if(personaProceso.size()> 0){
                listIdPersonas.add(integer.valueOf(personaProceso[0].SIREC__SIREC_fld_masterRecordId__c));
                }*/
                String idProceso = '';
                if(accion.SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c != null){
                    idProceso = accion.SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c;
                }
                wrapper.codigoAccion            = accion.SIREC__SIREC_fld_accion__c;
                wrapper.codigoResultadoAccion   = accion.SIREC__SIREC_fld_resultado__c;
                wrapper.codigoTipoAccion        = accion.SIREC__SIREC_fld_tipo__c;
                wrapper.comentario              = String.isNotEmpty(accion.SIREC__SIREC_fld_comentarios__c) ? accion.SIREC__SIREC_fld_comentarios__c.left(499) : '';
                wrapper.empleado                = gestor;
                wrapper.fechaAccion             = SIR_cls_WS_Wrapper.formatDate(accion.SIREC__SIREC_fld_fechaContacto__c);
                wrapper.idPersonaContactada     = idContactada; 
                wrapper.idPersonas              = listIdPersonas;
                wrapper.idProcesoGestion        = idProceso;
            if(wrapper != null){
                
                Map<String,string> mHeaders =  new  Map<String,string>();
                mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

                String body = JSON.serialize(wrapper);
                if(!SIR_WS_Configuration__mdt.getInstance('SendNewAction').SIR_fld_isActive__c &&
                    Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isAccessible() &&
                    Schema.sObjectType.SIREC__SIREC_obj_acciones__c.fields.SIR_accionEnviada__c.isUpdateable()){
                    lstResponse.add('OK');
                    accion.SIR_accionEnviada__c = true;
                    update accion;
                }else{
                    SIREC__SIREC_obj_proceso__c proceso = [SELECT Id, SIREC__SIREC_fld_masterRecordId__c, SIREC__SIREC_fld_situacion__c, SIR_fld_Situacion_SF__c, recordtype.Name
                                                            FROM SIREC__SIREC_obj_proceso__c
                                                            WHERE SIREC__SIREC_fld_masterRecordId__c = : accion.SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c];
                    try {
                        HttpRequest req = CBK_HttpServiceIntegration.getRequest(body, 'altaResultAcciones', 'POST', mHeaders);                        
                        HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req,'SIR','altaResultAcciones');
                        AccionResponse resp = (AccionResponse)JSon.deserialize(res.getBody(), AccionResponse.class); 
                        if(res.getStatusCode() == 200){
                            if(resp.codigoSalida == '1'){
                                // Actualizamos la accion con este campo a true para controlar el envio duplicado en el process
                                lstResponse.add('OK');
                                if(Schema.SObjectType.SIREC__SIREC_obj_acciones__c.isAccessible()){
                                    accion.SIR_accionEnviada__c = true;
                                    update accion;
                                }
                                updateProceso(proceso, accion, resp.datosResponseDto.codigoSit);
                            }else{
                                updateProceso(proceso, accion, null);
                                return SIR_cls_WS_Wrapper.responseError(res.getStatusCode(),resp.errorResponseDto);
                            }
                            if(Test.isRunningTest() && throwException){
                                CalloutException e = new CalloutException();
                                e.setMessage('Error Test');
                                throw e;
                            }
                        }  else {
                            updateProceso(proceso, accion, null);
                            return SIR_cls_WS_Wrapper.responseError(res.getStatusCode(),resp.errorResponseDto);
                        }
                        
                        }catch (CBK_ServiceRestManager.BadResponseException ex) {
                            updateProceso(proceso, accion, null);
                            CBK_log.error(ex, 'Error : SIR_SendNewAction_WS - ' + ex.getTypeName() + ': ' + ex.getMessage());
                            SIR_cls_WS_Wrapper.ErrorResponseDto error = new SIR_cls_WS_Wrapper.ErrorResponseDto();
                            error.codigoSoft = ex.status;
                            error.descripcionError = ex.getMessage();
                            return SIR_cls_WS_Wrapper.responseError(ex.statusCode,error);
                        }catch (Exception ex) {
                            updateProceso(proceso, accion, null);
                            CBK_log.error(ex, 'Error : SIR_SendNewAction_WS - ' + ex.getTypeName() + ': ' + ex.getMessage());
                            SIR_cls_WS_Wrapper.ErrorResponseDto error = new SIR_cls_WS_Wrapper.ErrorResponseDto();
                            error.descripcionError = ex.getTypeName() + ': ' + ex.getMessage();
                            return SIR_cls_WS_Wrapper.responseError(0,error);
                        }
                    }

                }
            return lstResponse;
        }
        lstResponse.add('KO');
        lstResponse.add('No tiene permisos para poder crear esta acción');
        lstResponse.add('');
        return lstResponse;
    }

    private static void updateProceso(SIREC__SIREC_obj_proceso__c proceso,SIREC__SIREC_obj_acciones__c accion, String codigoSit){
        List<SObject> lstSObjects = new List<SObject>();
        lstSObjects.add(proceso);
        lstSObjects.add(accion);
        try{
            if(Schema.SObjectType.SIREC__SIREC_obj_proceso__c.isAccessible() &&
               Schema.sObjectType.SIREC__SIREC_obj_proceso__c.fields.SIR_fld_Situacion_SF__c.isUpdateable()){
                if(accion.SIREC__SIREC_fld_resultado__c != SIR_Constantes.ACCION_RESULTADO_INTENTO_DE_CONTACTO){
                    if(proceso.recordtype.Name == SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL){
                        proceso.SIR_fld_Situacion_SF__c = SIR_Constantes.mapSituacionesPresol.get(accion.SIREC__SIREC_fld_resultado__c);
                    }else if(proceso.recordtype.Name == SIR_Constantes.PROCESO_RECORDTYPE_NAME_AMISTOSO){
                        proceso.SIR_fld_Situacion_SF__c = SIR_Constantes.mapSituacionesImpa.get(accion.SIREC__SIREC_fld_resultado__c);
                    }
                }
                if(String.isNotBlank(codigoSit)){
                    proceso.SIREC__SIREC_fld_situacion__c = codigoSit;
                }
                update proceso;
            }
        }catch(Exception ex){
            CBK_log.error(ex, 'Error : SIR_SendNewAction_WS - ' + ex.getTypeName() + ': ' + ex.getMessage() + ' - codigoSit : ' + codigoSit, lstSObjects);

        }
        
    }

    //-----------------------------------------------------------------

    @future(Callout=true)
    public static void futureSendAction(String accionId){
        sendAction(accionId);
    }

    //RESPONSE
    public class AccionResponse{
        public String codigoSalida;
        public SIR_cls_WS_Wrapper.ErrorResponseDto errorResponseDto;
        public DatosResponseDto datosResponseDto;
        //public AccionResponse(){}
    }
    
    public class DatosResponseDto{
        public String codigoSit;
        //public DatosResponseDto(){}
    }
}