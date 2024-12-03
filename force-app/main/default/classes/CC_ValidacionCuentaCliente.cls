public class CC_ValidacionCuentaCliente {
    public static void validacionCuenta() {

        try {
            String httpRequestBody = '{"filter": "walletle","isFullData": true,"isCancelledContracts": false,"userType": "N","pageKey": 1,"pageSize": 10,"ticket" : ""}';

            Map<String, String> mHeaders = new Map<String, String>();
            mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
            mHeaders.put('x-absis-customerInternalId',  CC_MetodosUtiles.decimalToHex(Decimal.valueOf('206')));

            CBK_HttpServiceIntegration.RequestWapper integracion = new CBK_HttpServiceIntegration.RequestWapper();
            integracion.body = httpRequestBody;
            integracion.intSetting = 'CC_Autenticacion_Cuenta';
            integracion.method = 'POST';
            integracion.mHeaders = mHeaders;
            HttpRequest request = CBK_HttpServiceIntegration.getRequest(integracion);

            HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, null, 'CC_Autenticacion_Cuenta');
            if (response.getStatusCode() != 200) {
                System.debug('NOK: ' + response.getStatusCode());
            } else {
                System.debug('OK: ' + response.getStatusCode());
            }
        } catch (Exception e) {
        }
    }
}