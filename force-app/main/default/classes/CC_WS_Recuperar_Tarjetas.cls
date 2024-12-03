public with sharing class CC_WS_Recuperar_Tarjetas {
    public static List<String> recuperarTarjetasPorCliente(String numPerso) {
        // numPerso = '1608138';
        List<String> tarjetas = new List<String>();
        if(!String.isEmpty(numPerso)){
            try {
                String outputField = recuperarYformatearParametros('CC_Recuperar_Tarjetas_Datos');
                String cardStatusFilter = recuperarYformatearParametros('CC_Recuperar_Tarjetas_Filtro');

               if(!String.isEmpty(outputField) && !String.isEmpty(outputField)){
                   String httpRequestBody = '{"InputFiltersCardUniqueList":{"CardStatusFilter":['+ cardStatusFilter +']}, "OutputField": ['+outputField+']}';
                   Map<String, String> mHeaders = new Map<String, String>();
                 
                   mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
                   mHeaders.put('x-absis-customerInternalId',  CC_MetodosUtiles.decimalToHex(Decimal.valueOf(numPerso)));
                    //SOLO PARA TEST
                    //mHeaders.put('x-api-actor-simulated', 'CBCCSF');
       
                   CBK_HttpServiceIntegration.RequestWapper integracion = new CBK_HttpServiceIntegration.RequestWapper();
                   integracion.body = httpRequestBody;
                   integracion.intSetting = 'CC_Recuperar_Tarjetas';
                   integracion.method = 'POST';
                   integracion.mHeaders = mHeaders;
                   HttpRequest request = CBK_HttpServiceIntegration.getRequest(integracion);
       
                   HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, null, 'CC_Recuperar_Tarjetas');
                   if (response.getStatusCode() != 200) {
                     CBK_Log.debug('::: Error Status Code: ' + response.getStatusCode());
                   } else {
                       ResponseTarjetas listaRespuesta = (ResponseTarjetas) System.JSON.deserialize(response.getBody(),  ResponseTarjetas.class);
                        for (CardList producto : listaRespuesta.CardList) {
                            tarjetas.add(String.valueOf(producto.maskedPan));
                        }
                   }
               }
            } catch (Exception e) {
                CBK_Log.error(e); 
            }
        }else{
            CBK_Log.error('Numperso no informado'); 
        }

        return tarjetas;
    }
    
    public class ResponseTarjetas {
        public List<CardList> cardList;
    }

    public class CardList {
        public String maskedPan;
    }

    private static String recuperarYformatearParametros(String nameValorCS){
        String retorno;
        if(!String.IsEmpty(nameValorCS)){
            CC_Settings__c valoresCS = [SELECT CC_Configuracion_1__c, CC_Configuracion_2__c, CC_Configuracion_3__c, CC_Configuracion_4__c, CC_Configuracion_5__c, CC_Configuracion_6__c, CC_Configuracion_7__c FROM CC_Settings__c WHERE Name = :nameValorCS AND CC_Activa__c = true LIMIT 1];
            Map<String, Object> mapValoresCS = valoresCS.getPopulatedFieldsAsMap();
            for (String fieldName : mapValoresCS.keySet()) {
                if(fieldName != 'Id'){
                    if(String.IsEmpty(retorno)){
                        retorno = '"'+mapValoresCS.get(fieldName)+'",';
                    }else{
                        retorno = retorno + '"'+mapValoresCS.get(fieldName)+'",';
                    }
                }
            }
            if(!String.IsEmpty(retorno)){
                retorno = retorno.substring(0,retorno.length()-1);
            }
            return retorno;
        }
        return retorno;
    } 
}