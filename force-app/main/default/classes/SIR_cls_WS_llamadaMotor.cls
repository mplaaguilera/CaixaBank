public with sharing class SIR_cls_WS_llamadaMotor {
    
    public static List<Object> avanzaMotor(SIREC__SIREC_obj_tarea__c tarea){
        List<Object> response = new List<Object>();
        if(SIR_WS_Configuration__mdt.getInstance('llamadaMotor').SIR_fld_isActive__c){
                
                CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
                LLamadaMotorRequest body = new LLamadaMotorRequest(tarea);
                
                reqWrapper.body = JSON.serialize(body);
                reqWrapper.intSetting = SIR_cls_Utils.getActorPrefix() + 'llamadaMotor';
                reqWrapper.method = 'POST';
                
                reqWrapper.mHeaders =  new  Map<String,string>();
                reqWrapper.mHeaders.put('Content-Type', 'application/json;charset=UTF-8');       
                reqWrapper.mHeaders.put('Accept-Language', 'es');
                reqWrapper.mUriParams = new  Map<String,string>();
                reqWrapper.mQueryParams = new  Map<String,string>();
                
                response = SIR_cls_WS_SIREC.llamar(reqWrapper);  
        }else{
            //llamada al mock, por ahora siempre devuelve ok
            response.add('OK');
        }
        return response;
    }

    public class LLamadaMotorRequest{
        public String codigoVar;
        public String empleado;
        public String fechaFinalizacion;
        public String fechaLimite;
        public String fijarEmpleado;
        public String fijarRespuesta;
        public Integer idActividad;
        public Integer idProceso;
        public Integer idExpediente;
        public String[] idSeleccion;
        public String modoEmision;
        public Integer numeroCopias;
        public String requerida;
        public String resultadoActividad;
        public String siModif;
        public String textoLibre;
        public String tipoDialogoImp;
        public String tipoVariable;
        public String valor;
        public String accessToken;
        public Map<String,Object> datosOpc;
        public Integer idProcesoPadre;

        public LLamadaMotorRequest(SIREC__SIREC_obj_tarea__c tarea){
            this.idActividad = Integer.valueOf(tarea.SIREC__SIREC_fld_masterRecordId__c);
            this.idProceso = Integer.valueOf(tarea.SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_masterRecordId__c);
            this.tipoDialogoImp = tarea.SIREC__SIREC_fld_tipo_tarea__c;
                       
            if(tarea.SIREC__SIREC_fld_tipo_tarea__c=='SEL' && 
               tarea.SIREC__SIREC_fld_SEL_respuestas_cod__c!= null) {           
               this.idSeleccion = tarea.SIREC__SIREC_fld_SEL_respuestas_cod__c.split(',');          
               this.tipoVariable = tarea.SIREC__SIREC_fld_seleccion__c;
            }
            if(tarea.SIREC__SIREC_fld_tipo_tarea__c=='DAT'){ 
                this.tipoVariable = tarea.SIREC__SIREC_fld_seleccion__c;
                if(tarea.SIREC__SIREC_fld_seleccion__c == 'N'){              
                   this.valor = String.ValueOf(tarea.SIREC__SIREC_fld_DAT_importe__c);
                }
                if (tarea.SIREC__SIREC_fld_seleccion__c == 'F'){
                   this.valor = SIR_cls_WS_Wrapper.formatDateGMT(tarea.SIREC__SIREC_fld_DAT_fecha__c);                               
                }                
                if (tarea.SIREC__SIREC_fld_seleccion__c == 'A'){                                
                   this.valor = tarea.SIREC__SIREC_fld_codigo_tarea__c.contains('DAT-EE') ? tarea.SIR_RespuestaTarea__c : tarea.SIREC__SIREC_fld_DAT_textoLargo__c;
                }
            }

            if(tarea.SIREC__SIREC_fld_tipo_tarea__c=='OPC'){               
                // ALR excepcion hasta que cambiemos en lwc para enviar la lista de contratos como String en lugar de Lista
                //this.datosOpc = (Map<String,Object>)JSON.deserializeUntyped(tarea.SIR_FormularioOPCResp__c);

                Map<String,Object> auxOpc = (Map<String,Object>)JSON.deserializeUntyped(tarea.SIR_FormularioOPCResp__c);
                if (auxOpc.containsKey('idOpcSeleccionados') && auxOpc.containsKey('idOpcNoSeleccionados') ){

                    String opcSel = JSON.serialize(auxOpc.get('idOpcSeleccionados'));
                    opcSel =  opcSel.remove('[').remove('"').remove(']');

                    String opcNoSel = JSON.serialize(auxOpc.get('idOpcNoSeleccionados'));
                    opcNoSel =  opcNoSel.remove('[').remove('"').remove(']');
                    String resp = '{"idOpcSeleccionados": "' + opcSel + '", "idOpcNoSeleccionados": "' + opcNoSel + '"}';

                    datosOpc = (Map<String,Object>)JSON.deserializeUntyped(resp);
                } else {
                    datosOpc = (Map<String,Object>)JSON.deserializeUntyped(tarea.SIR_FormularioOPCResp__c);       
                }
                // FIN excepcion
                this.datosOpc.put('idPropuesta',tarea.SIR_IdPropuestaOPC__c);
                this.datosOpc.put('codigoActividad',SIR_Constantes.MAP_CODIGO_ACTIVIDAD_AP_PP.get(tarea.SIREC__SIREC_fld_codigo_tarea__c));
                // agregamos el cast a Object para que no falle si el campo es null
                this.idProcesoPadre = Integer.valueOf((Object)tarea.SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_procesoSuperior__r.SIREC__SIREC_fld_masterRecordId__c); 	
            }
            this.accessToken = tarea.SIREC__SIREC_fld_accessToken__c;            
            
            //this.siModif = 'S';
            this.siModif = '1';
            this.requerida = 'X';

            // campos que no se informarán desde llamadaMotor
            this.idExpediente = null;
            this.modoEmision = '';
            this.numeroCopias = null;
            this.resultadoActividad = '';            
            this.textoLibre = '';
            if(tarea.SIREC__SIREC_fld_tipo_tarea__c == 'DAT'){
               this.codigoVar = tarea.SIREC__SIREC_fld_codigo_tarea__c;
            } else {
                this.codigoVar = '';
            }

            this.empleado = '';
            this.fechaFinalizacion = '';
            this.fechaLimite = '';
            this.fijarEmpleado = '';
            this.fijarRespuesta = '';

        }
    }
}