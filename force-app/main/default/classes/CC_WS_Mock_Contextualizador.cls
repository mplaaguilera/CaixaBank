@isTest
public class CC_WS_Mock_Contextualizador implements HttpCalloutMock{

    Integer statusCode;
    public CC_WS_Mock_Contextualizador(Integer strStatusCode){
        statusCode = strStatusCode;
    }
    public HTTPResponse respond(HTTPRequest req){
        //based on the status code, you can respond differently
        HttpResponse res = new HttpResponse();
        if(statusCode==200){
            String json = '{'+
            '  \"id\": \"15482499\",'+
            '  \"businessModel\": {'+
            '    \"serviceDomains\": {'+
            '      \"paymentExecution\": {'+
            '        \"context\": {'+
            '          \"refunds\": {'+
            '            \"current\": {'+
            '              \"movementId\": \"1\",'+
            '              \"contractCode\": \"62708570\",'+
            '              \"bin\": \"000409013000104724002\",'+
            '              \"pan\": \"flVW\",'+
            '              \"movementDate\": 1668880791245,'+
            '              \"settlementDate\": 5,'+
            '              \"commerceCode\": 32935035,'+
            '              \"commerceDescription\": \"DdkvLxJa\",'+
            '              \"movementAmount\": -1072306198,'+
            '              \"movementAmountDecimals\": 8,'+
            '              \"originalMovementAmount\": 7,'+
            '              \"originalMovementAmountDecimals\": 8'+
            '            },'+
            '            \"historical\": ['+
            '              {'+
            '                \"movementId\": \"6\",'+
            '                \"contractCode\": \"1440502512\",'+
            '                \"bin\": \"000409013000104724003\",'+
            '                \"pan\": \"TZEOz\",'+
            '                \"movementDate\": 1668095093349,'+
            '                \"settlementDate\": 3,'+
            '                \"commerceCode\": 963583795,'+
            '                \"commerceDescription\": \"hDhBsoXUVEqNP\",'+
            '                \"movementAmount\": -1882015954,'+
            '                \"movementAmountDecimals\": 5,'+
            '                \"originalMovementAmount\": 8,'+
            '                \"originalMovementAmountDecimals\": 4'+
            '              },'+
            '              {'+
            '                \"movementId\": \"4\",'+
            '                \"contractCode\": \"1043271648\",'+
            '                \"bin\": \"000409013000104724002\",'+
            '                \"pan\": \"BmQMqntaMIvs\",'+
            '                \"movementDate\": 1668095115344,'+
            '                \"settlementDate\": 6,'+
            '                \"commerceCode\": 1236181522,'+
            '                \"commerceDescription\": \"R\",'+
            '                \"movementAmount\": -26692623,'+
            '                \"movementAmountDecimals\": 1,'+
            '                \"originalMovementAmount\": 4,'+
            '                \"originalMovementAmountDecimals\": 3'+
            '              },'+
            '              {'+
            '                \"movementId\": \"6\",'+
            '                \"contractCode\": \"1761744771\",'+
            '                \"bin\": \"000409013000104724002\",'+
            '                \"pan\": \"EHadftdoRSUeuRpfNCd\",'+
            '                \"movementDate\": 1668095057090,'+
            '                \"settlementDate\": 4,'+
            '                \"commerceCode\": 244769559,'+
            '                \"commerceDescription\": \"VgvvCj\",'+
            '                \"movementAmount\": -1677286383,'+
            '                \"movementAmountDecimals\": 5,'+
            '                \"originalMovementAmount\": 8,'+
            '                \"originalMovementAmountDecimals\": 8'+
            '              },'+
            '              {'+
            '                \"movementId\": \"2\",'+
            '                \"contractCode\": \"1914133784\",'+
            '                \"bin\": \"000409013000104724002\",'+
            '                \"pan\": \"uvJnRzrnRhVKYXXVmB\",'+
            '                \"movementDate\": 1668095256484,'+
            '                \"settlementDate\": 2,'+
            '                \"commerceCode\": 409388713,'+
            '                \"commerceDescription\": \"M\",'+
            '                \"movementAmount\": -1429630238,'+
            '                \"movementAmountDecimals\": 3,'+
            '                \"originalMovementAmount\": 6,'+
            '                \"originalMovementAmountDecimals\": 8'+
            '              },'+
            '              {'+
            '                \"movementId\": \"1\",'+
            '                \"contractCode\": \"1786239238\",'+
            '                \"bin\": \"000409013000104724003\",'+
            '                \"pan\": \"uFNQMhNXx\",'+
            '                \"movementDate\": 1668095263562,'+
            '                \"settlementDate\": 4,'+
            '                \"commerceCode\": 602993708,'+
            '                \"commerceDescription\": \"MTq\",'+
            '                \"movementAmount\": -1834602266,'+
            '                \"movementAmountDecimals\": 2,'+
            '                \"originalMovementAmount\": 5,'+
            '                \"originalMovementAmountDecimals\": 3'+
            '              },'+
            '              {'+
            '                \"movementId\": \"1\",'+
            '                \"contractCode\": \"1872480978\",'+
            '                \"bin\": \"000409013000104724003\",'+
            '                \"pan\": \"a\",'+
            '                \"movementDate\": 1668095285655,'+
            '                \"settlementDate\": 3,'+
            '                \"commerceCode\": 1643780079,'+
            '                \"commerceDescription\": \"N\",'+
            '                \"movementAmount\": -856251094,'+
            '                \"movementAmountDecimals\": 4,'+
            '                \"originalMovementAmount\": 1,'+
            '                \"originalMovementAmountDecimals\": 4'+
            '              },'+
            '              {'+
            '                \"movementId\": \"2\",'+
            '                \"contractCode\": \"1833189855\",'+
            '                \"bin\": \"000409013000104724002\",'+
            '                \"pan\": \"LOipLKjSiyfiJI\",'+
            '                \"movementDate\": 1668095306544,'+
            '                \"settlementDate\": 4,'+
            '                \"commerceCode\": 2079033162,'+
            '                \"commerceDescription\": \"XRzywnRR\",'+
            '                \"movementAmount\": -2058754918,'+
            '                \"movementAmountDecimals\": 2,'+
            '                \"originalMovementAmount\": 8,'+
            '                \"originalMovementAmountDecimals\": 5'+
            '              },'+
            '              {'+
            '                \"movementId\": \"3\",'+
            '                \"contractCode\": \"1866488503\",'+
            '                \"bin\": \"000409013000104724003\",'+
            '                \"pan\": \"qiXHcLRQwyZlplNaLv\",'+
            '                \"movementDate\": 1668880791246,'+
            '                \"settlementDate\": 4,'+
            '                \"commerceCode\": 680582572,'+
            '                \"commerceDescription\": \"sTRZzaqoOiWy\",'+
            '                \"movementAmount\": -2117923863,'+
            '                \"movementAmountDecimals\": 2,'+
            '                \"originalMovementAmount\": 4,'+
            '                \"originalMovementAmountDecimals\": 8'+
            '              },'+
            '              {'+
            '                \"movementId\": \"2\",'+
            '                \"contractCode\": \"1160532371\",'+
            '                \"bin\": \"000409013000104724002\",'+
            '                \"pan\": \"PUQUAHnlQUcbWMG\",'+
            '                \"movementDate\": 1668880766743,'+
            '                \"settlementDate\": 1,'+
            '                \"commerceCode\": 2008356844,'+
            '                \"commerceDescription\": \"CssPRpbCT\",'+
            '                \"movementAmount\": -1904184016,'+
            '                \"movementAmountDecimals\": 3,'+
            '                \"originalMovementAmount\": 4,'+
            '                \"originalMovementAmountDecimals\": 7'+
            '              },'+
            '              {'+
            '                \"movementId\": \"1\",'+
            '                \"contractCode\": \"62708570\",'+
            '                \"bin\": \"000409013000104724002\",'+
            '                \"pan\": \"flVW\",'+
            '                \"movementDate\": 1668880791245,'+
            '                \"settlementDate\": 5,'+
            '                \"commerceCode\": 32935035,'+
            '                \"commerceDescription\": \"DdkvLxJa\",'+
            '                \"movementAmount\": -1072306198,'+
            '                \"movementAmountDecimals\": 8,'+
            '                \"originalMovementAmount\": 7,'+
            '                \"originalMovementAmountDecimals\": 8'+
            '              }'+
            '            ]'+
            '          },'+
            '          \"declinedPayments\": {'+
            '            \"current\": {'+
            '              \"movementId\": \"1164221\",'+
            '              \"contractCode\": \"9612128934779\",'+
            '              \"bin\": \"000409013008934779002\",'+
            '              \"movementDate\": 1671615281791,'+
            '              \"commerceCode\": 7241234249012000,'+
            '              \"commerceDescription\": \"COMPRA PRUEBAS\",'+
            '              \"movementAmount\": 3000.0,'+
            '              \"originalMovementAmount\": 0.21,'+
            '              \"contractCcy\": 978,'+
            '              \"originalCcy\": 414,'+
            '              \"movementNumber\": 1,'+
            '              \"countryCode\": \"ES\",'+
            '              \"operationType\": \"01\",'+
            '              \"ramoCode\": 1234,'+
            '              \"declineCode\": 559,'+
            '              \"exceptionIndex\": \"N\",'+
            '              \"chargeMovementType\": \"C\",'+
            '              \"declineTypology\": \"TPV\",'+
            '              \"declineCategory\": 12,'+
            '              \"denyingCenter\": \"TCRX876 \",'+
            '              \"denyingErrorCode\": \"5032F \",'+
            '              \"updateDate\": 1671467250000,'+
            '              \"contentDate\": 1671467250000,'+
            '              \"shipDate\": 1671467251000,'+
            '              \"terminalDataCaptureCapacity\": \"5\",'+
            '              \"clientAuthenticationCapacity\": \"4\",'+
            '              \"cardHoldCapacity\": \"0\",'+
            '              \"attendedTerminal\": \"1\",'+
            '              \"customerPresence\": \"0\",'+
            '              \"cardPresence\": \"1\",'+
            '              \"terminalDataEntryMode\": \"S\",'+
            '              \"clientAuthenticationMode\": \"T\",'+
            '              \"customerIdentifierEntity\": \"G\",'+
            '              \"terminalCardDataUpdate\": \"3\",'+
            '              \"terminalMessageCapacity\": \"4\",'+
            '              \"terminalMaximumPinLength\": \"C\",'+
            '              \"declineCodeDescription\": \"SUPERADO LIMITE: NO DISPONE DE EXCEDIDO POR FALTA DE SALDO CCC\",'+
            '              \"declineCategoryDescription\": \"Límitedecrédito\",'+
            '              \"declineFamilyCode\": \"01\"'+
            '            }'+
            '          }'+
            '        }'+
            '      }'+
            '    }'+
            '  }'+
            '}';
            
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(json);
            res.setStatusCode(200);
        } else if(statusCode==404){
            String json = '{"detail":"Error interno del servidor","stackTrace":[],"type":"architecture/internal-server-error","title":"Error aplicativo","status":404}';
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(json);
            res.setStatusCode(404);
        }
        return res;
    }

}