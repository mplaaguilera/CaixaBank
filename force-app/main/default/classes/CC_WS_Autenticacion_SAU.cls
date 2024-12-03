public with sharing class CC_WS_Autenticacion_SAU {
    public static Map<Boolean, String> CC_WS_Envio_Autenticacion(Boolean clienteImagin, String numPerso) {
        String tipoBody;
        Map<Boolean, String> mapRetorno = new Map<Boolean, String>();
        try {
            tipoBody = clienteImagin ? 'CNI' : 'CNC';
            numPerso = '030ED8F6'; // TEST
            // Escenario OK CNC: 030ED8F6
            // Escenario OK VACIO CNC: 0014A406
            // Escenario OK CNI: 0CCAE285
            // Escenario OK VACIO CNI: 03D65A81

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://api.tst.private.cer.caixabank.com/eChannels/eBranchManagement/customers/id/contracts/validation');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // request.setHeader('x-api-actor-simulated', 'CCSF');
            request.setHeader('HTTP-HEADER-ACTOR', 'CBCCSF');
            request.setBody('{"validationName": "' + tipoBody + '"}');
            request.setHeader('x-absis-customerInternalId', numPerso);
            request.setClientCertificateName('cc_camaleon');
            HttpResponse response = http.send(request);

            if (response.getStatusCode() != 200) { //KO
                System.debug('::: KO');
                mapRetorno.put(false, 'error_KO');
            } else { //OK
                System.debug('::: OK');
                String jsonResponse = response.getBody();
                System.debug('::: jsonResponse: ' + jsonResponse);
                Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
                System.debug('::: jsonMap: ' + jsonMap);
                String existContract = (String) jsonMap.get('existContract');
                System.debug('::: existContract: ' + existContract);
                // retorno = existContract.toLowerCase().contains('exist_contract') ? true : existContract.toLowerCase().contains('no_contract') ? false : retorno;
                // System.debug('::: retorno: ' + retorno);
                mapRetorno.put(
                    existContract.toLowerCase().contains('exist_contract') ? true : false,
                    existContract.toLowerCase().contains('exist_contract') ? 'existContrat' : 'no_contract'
                );
                System.debug('::: mapRetorno: ' + mapRetorno);
            }
        } catch (Exception e) {
            CBK_Log.error(e);
        }
        return mapRetorno;
    }
}