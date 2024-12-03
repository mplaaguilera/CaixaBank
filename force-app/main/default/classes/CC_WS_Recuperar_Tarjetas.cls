public with sharing class CC_WS_Recuperar_Tarjetas {

    public static List<String> recuperarTarjetasPorCliente(String numPerso) {
        // numPerso = '1608138';
        List<String> tarjetas = new List<String>();
        if (String.isBlank(numPerso)) {
			CBK_Log.error('Numperso no informado');
		} else {
            try {
                String outputField = recuperarYformatearParametros('CC_Recuperar_Tarjetas_Datos');
                String cardStatusFilter = recuperarYformatearParametros('CC_Recuperar_Tarjetas_Filtro');
				if (!String.isEmpty(outputField) && !String.isEmpty(outputField)) {

					CBK_HttpServiceIntegration.RequestWapper integracion = new CBK_HttpServiceIntegration.RequestWapper();
					integracion.body = '{"InputFiltersCardUniqueList":{"CardStatusFilter":[' + cardStatusFilter + ']}, "OutputField": [' + outputField + ']}';
					integracion.intSetting = 'CC_Recuperar_Tarjetas';
					integracion.method = 'POST';
					Map<String, String> requestHeaders = getRequestHeaders();
					requestHeaders.put('x-absis-customerInternalId', CC_MetodosUtiles.decimalToHex(Decimal.valueOf(numPerso)));

					HttpResponse response = CBK_HttpServiceIntegration.callHttpService(CBK_HttpServiceIntegration.getRequest(integracion), null, 'CC_Recuperar_Tarjetas');

					if (response.getStatusCode() != 200) {
						CBK_Log.debug('::: Error Status Code: ' + response.getStatusCode());
					} else {
						ResponseTarjetas listaRespuesta = (ResponseTarjetas)System.JSON.deserialize(response.getBody(),  ResponseTarjetas.class);
                        for (CardList producto : listaRespuesta.CardList) {
                            tarjetas.add(String.valueOf(producto.maskedPan));
                        }
					}
				}
            } catch (Exception e) {
                CBK_Log.error(e);
            }
        }
        return tarjetas;
    }

    public class ResponseTarjetas {
        public List<CardList> cardList;
    }

    public class CardList {
        public String maskedPan;
    }

    private static String recuperarYformatearParametros(String nameValorCS) {
        String retorno;
        if (!String.isEmpty(nameValorCS)) {
			CC_Settings__c valoresCS = [SELECT CC_Configuracion_1__c, CC_Configuracion_2__c, CC_Configuracion_3__c,
										CC_Configuracion_4__c, CC_Configuracion_5__c, CC_Configuracion_6__c, CC_Configuracion_7__c
										FROM CC_Settings__c WHERE Name = :nameValorCS AND CC_Activa__c = true LIMIT 1];
            Map<String, Object> mapValoresCS = valoresCS.getPopulatedFieldsAsMap();
            for (String fieldName : mapValoresCS.keySet()) {
                if (fieldName != 'Id') {
                    if (String.isEmpty(retorno)) {
                        retorno = '"' + mapValoresCS.get(fieldName) + '",';
                    } else {
                        retorno = retorno + '"' + mapValoresCS.get(fieldName) + '",';
                    }
                }
            }
            if (String.isNotBlank(retorno)) {
                retorno = retorno.substring(0, retorno.length() - 1);
            }
            return retorno;
        }
        return retorno;
    }

	private static Map<String, String> getRequestHeaders() {
		/* Ejemplo de headers:
			· Content-Type: application/json;charset=UTF-8
			· x-api-actor-simulated: CCSF 	(solo para previos)
			· HTTP-HEADER-ACTOR: CBCCSF 	(solo para previos)
		*/
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