public with sharing class CSBD_WS_AVECaracterizaCliente {
    
    public class RespuestaClienteDigital {
        public String empleado1;
        public String gestorOEAP1;
        public String oficina1;
        public String clienteDigital;
        public String muroAbierto;
        public String resultado;
        public String pilotoAppNow1;
        public String indSexo1;
    }

    public static Map<String, Object> caracterizaCliente(Map<String, Object> params) {
        Map<String, Object> respuestaClienteDigital = new Map<String, Object>();
        String numperso = (String)params.get('numperso');
       
        if (String.isNotBlank(numperso)) {
            try {
                Decimal numpersoDecimal = Decimal.valueOf(numperso);
                Map<String, String> requestHeaders = new Map<String, String>();
                requestHeaders.put('x-absis-customerInternalId', CC_MetodosUtiles.decimalToHex(numpersoDecimal));
                
                CBK_HttpServiceIntegration.RequestWapper integracion = new CBK_HttpServiceIntegration.RequestWapper();
                integracion.intSetting = 'CSBD_AVE_CaracterizaCliente';            
                integracion.mHeaders = requestHeaders;

                HttpRequest request = CBK_HttpServiceIntegration.getRequest(integracion);    
                HttpResponse response = CBK_HttpServiceIntegration.multiCallHttpService(request, 'CSBD_AVE_CaracterizaCliente', integracion.intSetting);
    
                if(response.getStatusCode() == 200) {
                    RespuestaClienteDigital valoresCliente = (RespuestaClienteDigital) JSON.deserialize(response.getBody(), RespuestaClienteDigital.class);
                    respuestaClienteDigital.put('result', 'OK');
                    respuestaClienteDigital.put('datosCliente', valoresCliente);               
                } else {
                    respuestaClienteDigital.put('result', 'KO');
                    respuestaClienteDigital.put('errorMessage', 'La integracion ha devuelvo status code ' + response.getStatusCode() + ' body ' + response.getBody());   
                }

               // CBK_HttpServiceIntegration.registroTrazaIntegracion();

            } catch (Exception e) {
                respuestaClienteDigital.put('result', 'KO');                
                respuestaClienteDigital.put('errorMessage', 'Ha ocurrido una exception ' + e.getMessage());        
                CBK_Log.error(e);
            }
        } else {
            respuestaClienteDigital.put('result', 'KO');
            respuestaClienteDigital.put('errorMessage', 'El número de persona no está informado');           
        }
     
        //Loguear en traza int        
        return respuestaClienteDigital;
    }

}