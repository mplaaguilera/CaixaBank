public with sharing class CC_WS_Autenticacion_CuentaCliente {
    public static List<String> validacionCuenta(String numPerso) {
        // String sSalida;
        CC_Settings__c parametrosBody = [SELECT CC_Configuracion_1__c, CC_Configuracion_2__c, CC_Configuracion_3__c, CC_Configuracion_4__c, CC_Configuracion_5__c, CC_Configuracion_6__c, CC_Configuracion_7__c FROM CC_Settings__c WHERE Name = 'CC_Integracion_Autenticacion' AND CC_Activa__c = true LIMIT 1];
        List<String> cuentas = new List<String>();
        try {
            String httpRequestBody = '{"filter": "' + parametrosBody.CC_Configuracion_1__c + '","isFullData": ' + parametrosBody.CC_Configuracion_2__c + ',"isCancelledContracts": ' + parametrosBody.CC_Configuracion_3__c + ',"userType": "' + parametrosBody.CC_Configuracion_4__c + '","pageKey": ' + parametrosBody.CC_Configuracion_5__c + ',"pageSize": ' + parametrosBody.CC_Configuracion_6__c + ',"ticket" : "' + parametrosBody.CC_Configuracion_7__c + '"}';
            Map<String, String> mHeaders = new Map<String, String>();
            mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
            mHeaders.put('x-absis-customerInternalId',  CC_MetodosUtiles.decimalToHex(Decimal.valueOf(numPerso)));

            CBK_HttpServiceIntegration.RequestWapper integracion = new CBK_HttpServiceIntegration.RequestWapper();
            integracion.body = httpRequestBody;
            integracion.intSetting = 'CC_Autenticacion_Cuenta';
            integracion.method = 'POST';
            integracion.mHeaders = mHeaders;
            HttpRequest request = CBK_HttpServiceIntegration.getRequest(integracion);

            HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, null, 'CC_Autenticacion_Cuenta');
            if (response.getStatusCode() != 200) {
                CBK_Log.debug('::: Error Status Code: ' + response.getStatusCode());
            } else {
                ResponseProducts listaRespuesta = (ResponseProducts) System.JSON.deserialize(response.getBody(),  ResponseProducts.class);
                CBK_Log.debug('::: Respuesta JSON: ' + response.getBody());

                for (Product producto : listaRespuesta.Products) {
                    for (Contract contratos : producto.Contracts) {
                        cuentas.add(String.valueOf(contratos.iban));
                    }
                }
            }
        } catch (Exception e) {
            CBK_Log.error(e); 
        }
        return cuentas;
    }
    
    public class ResponseProducts {
        public List<Product> products;
    }

    public class Product {
        public List<Contract> contracts;
    }
    public class Contract {
        public String iban;
    }
}