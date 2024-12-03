@isTest
public class CC_ObtenerSenalesCliente_Test {
    @TestSetup
    static void testSetup() {
        List<Account> accountsInsert = new List<Account>();

        Account cuentaCliente = new Account();
        cuentaCliente.LastName = 'Cliente Senior'; 
        cuentaCliente.CC_NumPerso__c = '0000012';
        cuentaCliente.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        cuentaCliente.CC_Marca_senior__c = false;
        accountsInsert.add(cuentaCliente);

        Account cuentaCliente2 = new Account();
        cuentaCliente2.LastName = 'Cliente Ex senior'; 
        cuentaCliente2.CC_NumPerso__c = '0000060'; 
        cuentaCliente2.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        cuentaCliente2.CC_Marca_senior__c = true;
        accountsInsert.add(cuentaCliente2);

        insert accountsInsert;
    }
    private class MockHttpResponseExito implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {

            CC_ObtenerSenalesCliente.LoyaltySignal senalClienteSenior = new CC_ObtenerSenalesCliente.LoyaltySignal();
            senalClienteSenior.key = '23';
            senalClienteSenior.value = 'Senior';
        
            CC_ObtenerSenalesCliente.RespuestaSenalesCliente respuestaSenalesCliente = new CC_ObtenerSenalesCliente.RespuestaSenalesCliente();
            respuestaSenalesCliente.loyaltySignals.add(senalClienteSenior);
            
            String respuestaObtenerSenales = JSON.serialize(respuestaSenalesCliente);

            HttpResponse res = new HttpResponse();
            res.setHeader('x-absis-customerInternalId', '0000012');
            res.setBody(respuestaObtenerSenales);
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest
    private static void obtenerSenalesCliente() {
        String numperso = [SELECT CC_NumPerso__c FROM Account WHERE LastName ='Cliente Senior'].CC_NumPerso__c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
        CC_InterfaceSettings__mdt configPartyReferenceMdt = CC_MetodosUtiles.getInterfazConfigBody('CC_Int_ObtenerSenalesCliente');
        CC_ObtenerSenalesCliente.obtenerSenalesCliente(numperso, configPartyReferenceMdt);      
        Test.stopTest();

        Boolean esSenior = [SELECT CC_Marca_senior__c FROM Account WHERE LastName ='Cliente Senior'].CC_Marca_senior__c;
        System.assertEquals(true, esSenior);
    }

    private class MockHttpResponseExitoNoSenior implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {

            CC_ObtenerSenalesCliente.LoyaltySignal senalClienteSenior = new CC_ObtenerSenalesCliente.LoyaltySignal();
            senalClienteSenior.key = '3';
            senalClienteSenior.value = 'Teen';
        
            CC_ObtenerSenalesCliente.RespuestaSenalesCliente respuestaSenalesCliente = new CC_ObtenerSenalesCliente.RespuestaSenalesCliente();
            respuestaSenalesCliente.loyaltySignals.add(senalClienteSenior);
            
            String respuestaObtenerSenales = JSON.serialize(respuestaSenalesCliente);

            HttpResponse res = new HttpResponse();
            res.setHeader('x-absis-customerInternalId', '0000060');
            res.setBody(respuestaObtenerSenales);
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest
    private static void obtenerSenalesClienteExSenior() {
        String numperso = [SELECT CC_NumPerso__c FROM Account WHERE LastName ='Cliente Ex senior'].CC_NumPerso__c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExitoNoSenior());
        CC_InterfaceSettings__mdt configPartyReferenceMdt = CC_MetodosUtiles.getInterfazConfigBody('CC_Int_ObtenerSenalesCliente');
        CC_ObtenerSenalesCliente.obtenerSenalesCliente(numperso, configPartyReferenceMdt);      
        Test.stopTest();

        Boolean esSenior = [SELECT CC_Marca_senior__c FROM Account WHERE LastName ='Cliente Ex senior'].CC_Marca_senior__c;
        System.assertEquals(false, esSenior);
    }
}