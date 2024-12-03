@isTest
public with sharing class OB_WS_LlamadasPendientesValidar_Test {

    @isTest
    public static void testOk() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/services/apexrest/LlamadasPendientesValidarOutbound';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"referencia": "123", "fecha": "20220118"}');
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        OB_WS_LlamadasPendientesValidar.llamadasPendientesValidar();
        Test.stopTest();
    }
    
    @isTest
    public static void testKo() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/services/apexrest/LlamadasPendientesValidarOutbound';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"referencia": "", "fecha": "20220118"}');
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        OB_WS_LlamadasPendientesValidar.llamadasPendientesValidar();
        Test.stopTest();
    }
}