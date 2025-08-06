public with sharing class CSBD_WS_LegoDisponibilidad {
    public class SlotWrapper {
        public String starTimeSlot;
        public String endTimeSlot;
        public Integer numberPlaces;
        public Integer numberPlacesAvailable;
        public Boolean isAvailable;
    }
    
    public class DisponibilidadWrapper {
        public List<SlotWrapper> slots;
        public Integer currentWaitTime;
        public String slotDate;
    }
    

    public static Map<String, Object> obtenerDisponibilidadesOficina(Map<String, Object> params) {
        Map<String, Object> resultado = new Map<String, Object>();
        List<DisponibilidadWrapper> horariosDisponibles = new List<DisponibilidadWrapper>();
        String numOficina = (String)params.get('numOficina');
        String fecha = (String)params.get('fecha');
        if (String.isBlank(numOficina)) {
            resultado.put('result', 'KO');
            resultado.put('errorMessage', 'Número de oficina no informado');         
        } else {
            try {
                //Obtener el custom setting de cita gestor
                CSBD_CitaGestorSetting__c setting = CSBD_CitaGestorSetting__c.getInstance();
                if(setting == null || String.isBlank( setting.CSBD_Device_LEGO__c) || String.isBlank(setting.CSBD_ReservationType_LEGO__c)){
                    resultado.put('result', 'KO');
                    resultado.put('errorMessage', 'No se ha encontrado el custom setting de cita gestor');
                    return resultado;
                }
                Map<String, String> requestHeaders = getRequestHeaders(setting.CSBD_Header_LEGO__c);
                Blob digest = Crypto.generateDigest('SHA-256', Blob.valueOf(numOficina + 'asesorVentas1'));
                String branchHashId = EncodingUtil.convertToHex(digest);

                CBK_HttpServiceIntegration.RequestWapper integracion = new CBK_HttpServiceIntegration.RequestWapper();
                integracion.intSetting = 'CSBD_Lego_DisponibilidadCitas';             
                integracion.mHeaders = requestHeaders;
                integracion.mUriParams = new Map<String, String>{
                    'branchId' => numOficina                    
                };

                integracion.mQueryParams = new Map<String, String>{
                    'slotDate' => fecha,
                    'device' => setting.CSBD_Device_LEGO__c,
                    'reservationType' => setting.CSBD_ReservationType_LEGO__c,
                    'branchHashId' => branchHashId
                };

                HttpRequest httpRequest = CBK_HttpServiceIntegration.getRequest(integracion);
                HttpResponse httpResponse = CBK_HttpServiceIntegration.callHttpService(httpRequest, 'CSBD_Lego_DisponibilidadCitas', integracion.intSetting);

                if (httpResponse.getStatusCode() != 200) {                
                    resultado.put('result', 'KO');
                    resultado.put('errorMessage', 'El servidor de Agendar Citas ha devuelto un error');
                } else {
                    horariosDisponibles = (List<DisponibilidadWrapper>) JSON.deserialize(httpResponse.getBody(), List<DisponibilidadWrapper>.class);
                    resultado.put('result', 'OK');
                    resultado.put('horariosDisponibles', horariosDisponibles);
                }
            } catch (Exception e) {
                resultado.put('result', 'KO');
                resultado.put('errorMessage', 'Ha ocurrido un error interno: ' + e.getMessage());
                CBK_Log.error(e);
            }            
        }
        //Loguear en traza int
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