public with sharing class CC_WS_Autenticacion_SAU {
    /**
     * @description <<Integración para comprobar si un cliente tiene contrato SAU o no, y si está bloqueado o no>>
     * @param clienteImagin -> Boolean para saber si el cliente es imagin o no (Si el campo indicadores cliente de Account tiene 28, es Imagin)
     * @param numPerso -> Numperso del cliente
     * @param traza -> Boolean para controlar si la integración genera trazas o no (Debido a que un componente llama a esta integración no puede generar trazas, ya que es un método Cacheable=true)
     * @return String -> El retorno es un string dependiendo de lo que devuelva la integración (error, datos, datos vacíos, etc)
     */
    public static String ccWsEnvioAutenticacion(Boolean clienteImagin, String numPerso, Boolean traza) {

        Map<String, String> retorno = ccWsEnvioAutenticacion(clienteImagin, numPerso, traza, null);
        
        return retorno.get('resultado');
    }

    public static Map<String, String> ccWsEnvioAutenticacion(Boolean clienteImagin, String numPerso, Boolean traza, Case caso) {
        Map<String, String> retorno = new Map<String, String>();
       
        //Boolean dejarTrazasFuture = false;
        String jsonResponse;
        String httpRequestBody;
        List<String> allReq = new List<String>();
        List<String> allRes = new List<String>();
        //CC_Settings__c trazaActiva = CC_Settings__c.getValues('CC_Trazas_WS_Autenticacion_SAU_Future');

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
                    //dejarTrazasFuture = true;
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
                allReq.add(httpRequestBody);
                allRes.add(response.getBody());
                if (response.getStatusCode() != 200) { //KO
                    retorno.put('resultado', 'Ha habido un problema con la integración');
                } else { //OK
                    jsonResponse = response.getBody();

                    Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
                    
                    // Validacion de si existContract no encuentra nada.
                    if (jsonMap.containsKey('existContract')) {
                        String existContract = (String) jsonMap.get('existContract');
                        if(existContract =='EXIST_CONTRACT'){
                            retorno.put('resultado', existContract.toLowerCase());
                        } else if(existContract == 'NO_CONTRACT'){
                            tipoBody = tipoBody == 'CNC' ? 'CNI' : 'CNC';
                            httpRequestBody = '{"validationName": "' + tipoBody + '"}';
                            response = invocacionServicio(httpRequestBody, integracionElegida, mHeaders);
                            allReq.add(httpRequestBody);
                            allRes.add(response.getBody());
                            jsonResponse = response.getBody();
                            jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
                            if (response.getStatusCode() != 200) { //KO
                                retorno.put('resultado', 'Ha habido un problema con la integración');
                            } else { //OK
                                 if (jsonMap.containsKey('existContract')) {
                                    existContract = (String) jsonMap.get('existContract');
                                    retorno.put('resultado', existContract.toLowerCase());
                                 } else {
                                    retorno.put('resultado', 'Ha habido un problema con los datos');
                                }
                            }
                        }
                    } else {
                        retorno.put('resultado', 'Ha habido un problema con los datos');
                    }
                }
            } else {
                retorno.put('resultado', 'El numperso está vacío');
            }
        } catch (Exception e) {
            CBK_Log.error(e);
        }

        if(traza) {
            CBK_HttpServiceIntegration.registroTrazaIntegracion();
        }else{
            retorno.put('reqAutenticacionSAU', httpRequestBody);
            retorno.put('resAutenticacionSAU', jsonResponse);
            retorno.put('allReq', JSON.serialize(allReq));
            retorno.put('allRes', JSON.serialize(allRes));
            if(caso != null) {
                retorno.put('nombreTraza', 'CC_Autenticacion_SAU: Caso ' + caso?.Id + '- Account ' + caso?.AccountId);
            } else {
                retorno.put('nombreTraza', 'CC_Autenticacion_SAU');
            }
        }
        
       /* if(dejarTrazasFuture && trazaActiva != null && trazaActiva.CC_Activa__c && caso != null) {
            String casoId = caso != null ? caso.Id : '';
            String accountId = caso != null ? caso.AccountId : '';
            dejarTraza(httpRequestBody, jsonResponse, casoId, accountId);
        }*/
        return retorno;
    }

 /*   public static void dejarTraza(String inputRequest, String inputResponse, String casoId, String accountId) {
        CC_TrazaInt__c traza = new CC_TrazaInt__c();
        traza.Name = 'CC_Autenticacion_SAU';
        traza.CC_FechaInicio__c = System.now();
        traza.CC_FechaFin__c = System.now();
        traza.CC_MensajeEntrada__c = inputRequest?.left(131072);
        traza.CC_MensajeSalida__c = inputResponse?.left(131072);
        traza.CC_Identificador__c  = 'CC_Autenticacion_SAU: Caso ' + casoId + '- Account ' + accountId;
        //traza.CC_Id_Origen__c = casoId;
        traza.CC_FinOK__c = true;
        insert traza;
    }*/

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