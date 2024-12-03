public with sharing class SPV_WS_GetReclamaciones {
    
    private static final String SPV_GETRECLAMACIONESSAC   = 'SPV_GetReclamacionesSAC';

    static public void getReclamaciones(){

        String response = '';
        String estado = '';
        String sDescError = '';
        String sDetalleError = '';

        // Recuperar configuración PJUATR Get Reclamaciones
        CC_InterfaceSettings__mdt confInterfaz   = SAC_Utils.getInterfazConfigBody(SPV_GETRECLAMACIONESSAC);
        String sXMLEntrada = confInterfaz.CC_Body__c;

        // Preparar retorno del Servicio Web: CC_WS_ALF_Cons_NP.outconsultapersonasws oRes;
        // Llamada vía HttpRequest.
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        HTTPResponse res;
        
        try {
            request.setTimeOut(Integer.valueOf(confInterfaz.CC_TimeOut__c));   
            request.setMethod(confInterfaz.CC_TipoPeticion__c);   
            request.setHeader('Content-Type', confInterfaz.CC_ContentType__c);
            request.setHeader('Content-Length',''+sXMLEntrada.length());
            if(!Test.isRunningTest()){
                request.setClientCertificateName(confInterfaz.CC_Certificado__c);
            }
            request.setEndpoint(confInterfaz.CC_EndPoint__c);
            request.setbody(sXMLEntrada);
            res = http.send(request);

            response = res.getBody();
            estado = res.getStatus() + ' (' + res.getStatusCode() + ').';

            if (res.getStatusCode() != 200) {
                sDescError = 'Error petición.';
                sDetalleError = res.getStatus() + ' (' + res.getStatusCode() + ')';
                // Gestionar el error para los clientes confidenciales.
            }else{
                response = res.getBody();
            }
    
        }catch (Exception e) {
            // Error comunicaciones.
            sDescError = 'Error comunicaciones.';
            sDetalleError = e.getMessage();
        }
    }
}