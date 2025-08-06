public with sharing class CSBD_WS_LegoAltaCita {


    public static Map<String, Object> altaCita(Map<String, Object> params) {
        String numOficina = (String)params.get('numOficina');
        String numPer = (String)params.get('numPer');
        String fechaSeleccionada = (String)params.get('fechaSeleccionada');
        String franjaSeleccionada = (String)params.get('franjaSeleccionada'); //se espera la hora inicio: 10:30 por ejemplo
        String asunto = (String)params.get('asunto');      
        String tipoCita = (String)params.get('tipoCita');

        Map<String, Object> resultado = new Map<String, Object>();

        if (String.isBlank(numPer)) {
            resultado.put('result', 'KO');
            resultado.put('errorMessage', 'Numperso no informado');           
        }else {         
            //Obtener el custom setting de cita gestor
            CSBD_CitaGestorSetting__c setting = CSBD_CitaGestorSetting__c.getInstance();       
            if(setting == null || setting.CSBD_Device_LEGO__c == null || setting.CSBD_ReservationType_LEGO__c == null){
                resultado.put('result', 'KO');
                resultado.put('errorMessage', 'No se ha encontrado el custom setting de cita gestor');
                return resultado;
            }
         
            String versionAPI = setting.CSBD_VersionAPI_Lego__c == null ? 'v2' : setting.CSBD_VersionAPI_Lego__c;
            Blob digest = null;
            if(versionAPI == 'v2'){ //by default sera v2
                digest = Crypto.generateDigest('SHA-512', Blob.valueOf(numPer));             
            }else{ //v1 
                digest = Crypto.generateDigest('SHA-256', Blob.valueOf(numPer + 'asesorVentas1'));
            }

           
            String branchHashId = EncodingUtil.convertToHex(digest);
            Map<String, String> requestHeaders = getRequestHeaders(setting.CSBD_Header_LEGO__c);
            
            asunto = (tipoCita == String.valueOf(42) ? ' Cita presencial' : ' Cita telefónica') + ' - ' + asunto;
            Map<String, String> bodyRequest = new Map<String, String>();
            bodyRequest.put('branchId', numOficina);
            bodyRequest.put('reasonId', '999');
            bodyRequest.put('reasonText', asunto);
            bodyRequest.put('waitingRoomDate', fechaSeleccionada);
            bodyRequest.put('device', setting.CSBD_Device_LEGO__c);
            bodyRequest.put('slotStartTime', franjaSeleccionada);
            bodyRequest.put('reservationType', setting.CSBD_ReservationType_LEGO__c);
            if(versionAPI == 'v1'){ //este parámetro solo es valido para la version v1
                bodyRequest.put('customerInternalId', numPer);
            }            
            bodyRequest.put('customerInternalHashId', branchHashId); //este parametro se envia para ambas versiones
            String jsonBody = JSON.serialize(bodyRequest);

            CBK_HttpServiceIntegration.RequestWapper integracion = new CBK_HttpServiceIntegration.RequestWapper();
            integracion.intSetting = 'CSBD_Lego_AltaCita';
            integracion.mHeaders = requestHeaders;
            integracion.body = jsonBody;
            
            HttpRequest request = CBK_HttpServiceIntegration.getRequest(integracion);

            HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, 'CSBD_Lego_AltaCita', integracion.intSetting);
            
            if(response.getStatusCode() != 200 && response.getStatusCode() != 201) {
                Map<String, Object> parsedError = new Map<String, Object>();
                String detail = 'El servidor LEGO ha devuelto un error al agendar la cita';
                if (String.isNotBlank(response.getBody())) {
                    parsedError = (Map<String, Object>) JSON.deserializeUntyped(response.getbody());
                    detail = parsedError.containsKey('detail') ? detail + ': ' + (String) parsedError.get('detail') : detail;
                }    
                resultado.put('result', 'KO');           
                resultado.put('errorMessage', detail);
            } else {            
                resultado.put('result', 'OK');  
                Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                resultado.put('appointmentId', parsedResponse.get('appointmentId'));
            }
        } 
       
        return resultado;
    }

    private static Map<String, String> getRequestHeaders(Boolean incluirHeader) {
        /* Ejemplo de headers:
            · Content-Type: application/json;charset=UTF-8
            · x-api-actor-simulated: CCSF   (solo para previos)
            · HTTP-HEADER-ACTOR: CBCCSF     (solo para previos)
        */
        Map<String, String> headers = new Map<String, String>();
        if(incluirHeader){
            for (CC_Lista_Valores__c lov : [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c
                            WHERE CC_Lista__r.Name = 'CSBD Request headers LEGO'
                            AND CC_Lista__r.CC_Activa__c = TRUE AND CC_Activa__c = TRUE]) {
                headers.put(lov.Name, lov.CC_Valor__c);
            }
        }
        return headers;
    }
}