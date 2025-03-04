public with sharing class CC_WS_Autenticacion_SAU {
    /**
     * @description <<Integración para comprobar si un cliente tiene contrato SAU o no, y si está bloqueado o no>>
     * @param clienteImagin -> Boolean para saber si el cliente es imagin o no (Si el campo indicadores cliente de Account tiene 28, es Imagin)
     * @param numPerso -> Numperso del cliente
     * @param traza -> Boolean para controlar si la integración genera trazas o no (Debido a que un componente llama a esta integración no puede generar trazas, ya que es un método Cacheable=true)
     * @return String -> El retorno es un string dependiendo de lo que devuelva la integración (error, datos, datos vacíos, etc)
     */
    public static String ccWsEnvioAutenticacion(Boolean clienteImagin, String numPerso, Boolean traza) {
        String retorno;
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
                    integracionElegida = 'CC_Autenticacion_SAU_No_Traza';
                }
                String hex = CC_MetodosUtiles.decimalToHex(Decimal.valueOf(numPerso));
                String numperHex = String.valueOf(hex).leftPad(8, '0');
                
                Map<String, String> mHeaders = new Map<String, String>();
                mHeaders.put('x-absis-customerInternalId',  numperHex.toUpperCase());
                mHeaders.put('HTTP-HEADER-ACTOR', 'CBCCSF'); // Solo DEV
                // mHeaders.put('x-api-actor-simulated', 'CCSF'); // Solo DEV
                
                String tipoBody = clienteImagin ? 'CNI' : 'CNC';
                String httpRequestBody = '{"validationName": "' + tipoBody + '"}';

                CBK_HttpServiceIntegration.RequestWapper integracion = new CBK_HttpServiceIntegration.RequestWapper();
                integracion.body = httpRequestBody;
                integracion.intSetting = integracionElegida;
                integracion.mHeaders = mHeaders;
                HttpRequest request = CBK_HttpServiceIntegration.getRequest(integracion);
                HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, null, integracionElegida);

                if (response.getStatusCode() != 200) { //KO
                    retorno = 'Ha habido un problema con la integración';
                } else { //OK
                    String jsonResponse = response.getBody();

                    Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
                    
                    // Validacion de si existContract no encuentra nada.
                    if (jsonMap.containsKey('existContract')) {
                        String existContract = (String) jsonMap.get('existContract');
                        retorno = existContract.toLowerCase(); // Debe devolver -> EXIST_CONTRACT / NO_CONTRACT
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
        return retorno;
    }
}