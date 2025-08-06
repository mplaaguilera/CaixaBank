@isTest
public with sharing class CC_WS_Mock_Autenticacion_Validacion implements HttpCalloutMock {

    Integer statusCode;
    public CC_WS_Mock_Autenticacion_Validacion(Integer strStatusCode) {
        statusCode = strStatusCode;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        
        if (statusCode == 200) {
            String responseBody = '{'
            + '"ticketId":"N0000000000000000020601825",'
            + '"totalContracts":345,'
            + '"Products":[{'
            + '"productId":10158,'
            + '"productDescription":"Cuentas a la vista",'
            + '"Contracts":[{'
            + '"contractId":180020002194,'
            + '"contractId28":"0012100018020020600000219400",'
            + '"area":1,'
            + '"modality":2,'
            + '"office":180,'
            + '"entity":2100,'
            + '"iban":"ES1521000180810200219491",'
            + '"ownerName":"                                                    ",'
            + '"aplication":"TLE",'
            + '"returnCode":"1",'
            + '"description":"Cuenta corriente",'
            + '"descriptionId":10613,'
            + '"ownerType":"1",'
            + '"ccy":"EUR",'
            + '"branchId":1,'
            + '"country":"11",'
            + '"openingDate":"1995-05-18",'
            + '"Indicators":[{'
            + '"key":"ARC",'
            + '"value":"N"'
            + '},{'
            + '"key":"CAN",'
            + '"value":"N"'
            + '},{'
            + '"key":"EMP",'
            + '"value":"N"'
            + '},{'
            + '"key":"RST",'
            + '"value":"N"'
            + '},{'
            + '"key":"VIN",'
            + '"value":"N"'
            + '},{'
            + '"key":"NAC",'
            + '"value":"S"'
            + '},{}],'
            + '"Balance":[{'
            + '"type":"Available",'
            + '"amount":3273.36,'
            + '"ccy":"EUR"'
            + '}]'
            + '}]'
            + '}],'
            + '"pagination":{'
            + '"pageKey":1,'
            + '"pageSize":10,'
            + '"totalPages":35'
            + '}'
            + '}';
            
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(200);
        } else if (this.statusCode == 404) {
            String json = '{"detail":"Error interno del servidor","stackTrace":[],"type":"architecture/internal-server-error","title":"Error aplicativo","status":404}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(json);
            res.setStatusCode(404);
        }
        return res;
    }
}