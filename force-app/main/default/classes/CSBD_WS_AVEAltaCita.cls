public with sharing class CSBD_WS_AVEAltaCita {
    
    public class AltaContacto {
        public String empleadoEx; 
        public String centroEx; 
        public String origen; 
        public String asunto; 
        public String fecContacto; 
        public String horaIni; 
        public String horaFin; 
        public String medio; 
        public String estado; 
        public String numper; 
        public String nomCli; 
        public String dispGestor; 
    }
    
    public class RespuestaAltaContacto {
        public String resultat;
        public String empleCont;
        public String numCont;
        public String txtError;
    } 
    
    public static Map<String, Object> altaCitaGestor(Map<String, Object> params) {
        // Extracción de parámetros
        Map<String, Object> resultadoAltaCitaGestor = new Map<String, Object>();

        String empleadoEx = (String) params.get('empleadoEx');
        String centroEx = (String) params.get('centroEx');
        String asunto = (String) params.get('asunto');
        String fecContacto = (String) params.get('fecContacto');
        String horaIni = (String) params.get('horaIni');
        String medio = (String) params.get('medio');
        String numperso = (String) params.get('numperso');
        String accName = (String) params.get('accName');
        //Obtener el custom setting de cita gestor
        CSBD_CitaGestorSetting__c setting = CSBD_CitaGestorSetting__c.getInstance();
        if(setting == null){
            resultadoAltaCitaGestor.put('result', 'KO');
            resultadoAltaCitaGestor.put('errorMessage', 'No se ha encontrado el custom setting de cita gestor');
            return resultadoAltaCitaGestor;
        }

        Decimal numpersoDecimal = Decimal.valueOf(numperso);        
        Date fechaIniDate = Date.valueOf(fecContacto);
        String[] timeSplit = horaIni.split(':');
        Time horaIniTime = Time.newInstance(Integer.valueOf(timeSplit[0]),
                                            Integer.valueOf(timeSplit[1]),
                                            0,                            
                                            0);  
        Datetime fechaIniDateTime = Datetime.newInstance(fechaIniDate,horaIniTime);
        String fecContactoFormato = fechaIniDateTime.format('ddMMyyyy');
        
        String horaIniFormato = horaIni.replace(':', '');
        
        Datetime horaFin = fechaIniDateTime.addMinutes(30);
        String horaFinFormato = horaFin.format('HHmm');
        
        AltaContacto datosCita = new AltaContacto();
        datosCita.empleadoEx = empleadoEx;
        datosCita.centroEx = centroEx;
        datosCita.origen = setting.CSBD_Origen_AVE__c != null ? setting.CSBD_Origen_AVE__c : 'P'; 
        datosCita.asunto = asunto;
        datosCita.fecContacto = fecContactoFormato;
        datosCita.horaIni = horaIniFormato;
        datosCita.horaFin = horaFinFormato;
        datosCita.medio = medio;
        datosCita.estado = setting.CSBD_Estado_AVE__c != null ? setting.CSBD_Estado_AVE__c : 'A'; 
        datosCita.numper = numperso;
        datosCita.nomCli = accName;
        datosCita.dispGestor = setting.CSBD_DispGestor_AVE__c != null ? setting.CSBD_DispGestor_AVE__c : 'S'; 

        String bodyRequestAltaCita = JSON.serialize(datosCita);
        
                        
        // Configuración del request usando CBK_HttpServiceIntegration
        CBK_HttpServiceIntegration.RequestWapper requestWrp = new CBK_HttpServiceIntegration.RequestWapper();
        Map<String, String> requestHeaders = new Map<String, String>(); 
        requestHeaders.put('x-absis-customerInternalId', CC_MetodosUtiles.decimalToHex(numpersoDecimal));
        requestHeaders.put('Content-Type', 'application/json');
        requestWrp.body = bodyRequestAltaCita;
        requestWrp.intSetting = 'CSBD_AVE_AltaCita';
        requestWrp.mHeaders = requestHeaders;      
               
        try{
            HttpRequest req = CBK_HttpServiceIntegration.getRequest(requestWrp);     
            HttpResponse respuesta = CBK_HttpServiceIntegration.callHttpService(req, 'CSBD_AVE_AltaCita', requestWrp.intSetting);
            RespuestaAltaContacto resultadoAltaContacto = (RespuestaAltaContacto) System.JSON.deserialize(respuesta.getBody(), RespuestaAltaContacto.class);
            if(respuesta.getStatusCode() == 200){                
                resultadoAltaCitaGestor.put('body', resultadoAltaContacto);
                resultadoAltaCitaGestor.put('result', 'OK');         
                
            } else {
                resultadoAltaCitaGestor.put('result', 'KO');
                resultadoAltaCitaGestor.put('errorMessage', 'Ha ocurrido un error al realizar la llamada al servicio. El servidor ha devuelto el siguiente mensaje: ' + resultadoAltaContacto.txtError);             
            }    
        } catch(Exception e){
            resultadoAltaCitaGestor.put('result', 'KO');
            resultadoAltaCitaGestor.put('errorMessage', 'Ha ocurrido un error interno, al realizar la llamada al WS de AVE Alta Cita: ' + e.getMessage());
        }      
        // Registro de traza usando el framework
      //  CBK_HttpServiceIntegration.registroTrazaIntegracion();
        
        return resultadoAltaCitaGestor;
    }   
  
}