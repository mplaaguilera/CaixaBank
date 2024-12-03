public with sharing class CC_WS_Disponibilidad_Cita {
    public static List<String> disponibilidadCitas(String numOficina, String fecha) {
        List<String> horariosDisponibles = new List<String>();
        if (String.isBlank(numOficina)) {
            CBK_Log.error('Número de oficina no informado');
        } else {
            try {
                CC_Settings__c reservationType = CC_Settings__c.getValues('CC_Configuracion_Cita_Rapida');
                Map<String, String> requestHeaders = getRequestHeaders();
                Blob digest = Crypto.generateDigest('SHA-256', Blob.valueOf(numOficina + 'asesorVentas1'));
                String branchHashId = EncodingUtil.convertToHex(digest);

                CBK_HttpServiceIntegration.RequestWapper integracion = new CBK_HttpServiceIntegration.RequestWapper();
                integracion.intSetting = 'CC_Disponibilidad_Citas';
                integracion.method = 'GET';
                integracion.mHeaders = requestHeaders;
                integracion.mUriParams = new Map<String, String>{
                    'branchId' => numOficina                    
                };

                integracion.mQueryParams = new Map<String, String>{
                    'slotDate' => fecha,
                    'device' => '2',
                    'slotType' => reservationType.CC_Configuracion_2__c,
                    'branchHashId' => branchHashId
                };

                HttpRequest httpRequest = CBK_HttpServiceIntegration.getRequest(integracion);
                HttpResponse httpResponse = CBK_HttpServiceIntegration.callHttpService(httpRequest, 'CC_WS_Disponibilidad_Cita', integracion.intSetting);

                if (httpResponse.getStatusCode() != 200) {
                    CBK_Log.debug('::: Error Status Code: ' + httpResponse.getStatusCode());
                } else {
                    List<Object> responseList = (List<Object>) JSON.deserializeUntyped(httpResponse.getBody());

                    for (Object diaObj : responseList) {
                        // Cada elemento en responseList es un día con un mapa de slots
                        Map<String, Object> diaMap = (Map<String, Object>) diaObj;
                        List<Object> slots = (List<Object>) diaMap.get('Slots');
                        for (Object slotObj : slots) {
                            Map<String, Object> slotMap = (Map<String, Object>) slotObj;                            
                            if ((Boolean) slotMap.get('isAvailable')) {
                                String startTime = (String) slotMap.get('starTimeSlot');
                                String endTime = (String) slotMap.get('endTimeSlot');
                                horariosDisponibles.add(startTime + ' - ' + endTime);
                            }
                        }
                    }
                }
            } catch (Exception e) {
                CBK_Log.error(e);
            }
        }
        return horariosDisponibles;
    }

    @AuraEnabled
    public static List<String> obtenerFechasDisponiblidadGestorPool(String numOficina, String fecha) {
        try {
            return disponibilidadCitas(numOficina, fecha);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Map<String, String> getRequestHeaders() {
        /* Ejemplo de headers:
            · Content-Type: application/json;charset=UTF-8
            · x-api-actor-simulated: CCSF   (solo para previos)
            · HTTP-HEADER-ACTOR: CBCCSF     (solo para previos)
        */
        //Map<String, String> headers = new Map<String, String>{'HTTP-HEADER-ACTOR' => 'CBCCSF'};
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json;charset=UTF-8'};
        if ([SELECT IsSandbox FROM Organization].IsSandbox) {
            for (CC_Lista_Valores__c lov : [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c
                                            WHERE CC_Lista__r.Name = 'Request headers específicos del sandbox'
                                            AND CC_Lista__r.CC_Activa__c = TRUE AND CC_Activa__c = TRUE]) {
                headers.put(lov.Name, lov.CC_Valor__c);
            }
        }
        return headers;
    }
}