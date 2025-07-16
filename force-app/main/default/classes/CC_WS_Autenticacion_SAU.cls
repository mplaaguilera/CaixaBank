public with sharing class CC_WS_Autenticacion_SAU {
    /**
     * @description <<Integración para comprobar si un cliente tiene contrato SAU o no, y si está bloqueado o no>>
     * @param clienteImagin -> Boolean para saber si el cliente es imagin o no (Si el campo indicadores cliente de Account tiene 28, es Imagin)
     * @param numPerso -> Numperso del cliente
     * @param traza -> Boolean para controlar si la integración genera trazas o no (Debido a que un componente llama a esta integración no puede generar trazas, ya que es un método Cacheable=true)
     * @return String -> El retorno es un string dependiendo de lo que devuelva la integración (error, datos, datos vacíos, etc)
     */
    public static String ccWsEnvioAutenticacion(Boolean clienteImagin, String numPerso, Boolean traza) {

        String retorno = ccWsEnvioAutenticacion(clienteImagin, numPerso, traza, null);

        return retorno;
    }

    public static String ccWsEnvioAutenticacion(Boolean clienteImagin, String numPerso, Boolean traza, Case caso) {
        String retorno;
        Boolean dejarTrazasFuture = false;
        String jsonResponse;
        String httpRequestBody;
        CC_Settings__c trazaActiva = CC_Settings__c.getValues('CC_Trazas_WS_Autenticacion_SAU_Future');

        try {
            // Numpersos de prueba
            // Cliente Caixa con contrato: 51304694
            // Cliente Caixa sin contrato: 1352710
            // Cliente Imagin con contrato: 214622853
            // Cliente Imagin sin contrato: 64379521

            if (!String.isEmpty(numPerso)) {
                String integracionElegida;
                if(traza) {
                    integracionElegida = 'CC_Autenticacion_SAU';
                } else {
                    dejarTrazasFuture = true;
                    integracionElegida = 'CC_Autenticacion_SAU_No_Traza';
                }
                String hex = CC_MetodosUtiles.decimalToHex(Decimal.valueOf(numPerso));
                String numperHex = String.valueOf(hex).leftPad(8, '0');

                Map<String, String> mHeaders = new Map<String, String>();
                mHeaders.put('x-absis-customerInternalId',  numperHex.toUpperCase());
                mHeaders.put('HTTP-HEADER-ACTOR', 'CBCCSF'); // Solo DEV
                // mHeaders.put('x-api-actor-simulated', 'CCSF'); // Solo DEV

                String tipoBody = clienteImagin ? 'CNI' : 'CNC';

                Map<String,Object> payload = new Map<String,Object>{
                    'validationName' => tipoBody
                };

                //httpRequestBody = '{"validationName":"' + tipoBody +'"}';
                httpRequestBody = JSON.serialize(payload);
                HttpResponse response = invocacionServicio(httpRequestBody, integracionElegida, mHeaders);
                if (response.getStatusCode() != 200) { //KO
                    retorno = 'Ha habido un problema con la integración';
                } else { //OK
                    jsonResponse = response.getBody();

                    Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);

                    // Validacion de si existContract no encuentra nada.
                    if (jsonMap.containsKey('existContract')) {
                        String existContract = (String) jsonMap.get('existContract');
                        if(existContract =='EXIST_CONTRACT'){
                            retorno = existContract.toLowerCase();
                        } else if(existContract == 'NO_CONTRACT'){
                            tipoBody = tipoBody == 'CNC' ? 'CNI' : 'CNC';
                            httpRequestBody = '{"validationName": "' + tipoBody + '"}';
                            response = invocacionServicio(httpRequestBody, integracionElegida, mHeaders);
                            jsonResponse = response.getBody();
                            jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
                            if (response.getStatusCode() != 200) { //KO
                                retorno = 'Ha habido un problema con la integración';
                            } else { //OK
                                 if (jsonMap.containsKey('existContract')) {
                                    existContract = (String) jsonMap.get('existContract');
                                    retorno = existContract.toLowerCase();
                                 } else {
                                    retorno = 'Ha habido un problema con los datos';
                                }
                            }
                        }
                    } else {
                        retorno = 'Ha habido un problema con los datos';
                    }
                }
            } else {
                retorno = 'El numperso está vacío';
            }
        } catch (Exception e) {
            CBK_Log.error(e);
        }

        if(dejarTrazasFuture && trazaActiva != null && trazaActiva.CC_Activa__c && caso != null) {
           dejarTrazaFuture(httpRequestBody, jsonResponse, caso.Id, caso.AccountId);
        }
        return retorno;
    }

    @future
    public static void dejarTrazaFuture(String inputRequest, String inputResponse, String casoId, String accountId) {
        CC_TrazaInt__c traza = new CC_TrazaInt__c();
        traza.Name = 'CC_Autenticacion_SAU';
        traza.CC_FechaInicio__c = System.now();
        traza.CC_FechaFin__c = System.now();
        traza.CC_Identificador__c = 'CC_Autenticacion_SAU';
        traza.CC_MensajeEntrada__c = inputRequest?.left(131072);
        traza.CC_MensajeSalida__c = inputResponse?.left(131072);
        traza.CBK_Body__c = 'Caso ' + casoId + '- Account ' + accountId;
        traza.CC_FinOK__c = true;
        insert traza;
    }

    private static HttpResponse invocacionServicio(String httpRequestBody, String integracionElegida, Map<String, String> mHeaders) {
        HttpResponse response;
        try {
            CBK_HttpServiceIntegration.RequestWapper integracion = new CBK_HttpServiceIntegration.RequestWapper();
            integracion.body = httpRequestBody;
            integracion.intSetting = integracionElegida;
            integracion.mHeaders = mHeaders;
            HttpRequest request = CBK_HttpServiceIntegration.getRequest(integracion);
            response =  CBK_HttpServiceIntegration.multiCallHttpService(request, null, integracionElegida);
        } catch (Exception e) {
            CBK_Log.error(e);
        }

    return response;

    }

}