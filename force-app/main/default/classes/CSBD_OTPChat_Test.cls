@isTest
public class CSBD_OTPChat_Test {

    @testSetup
    private static void setup() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

        Account cliente = new Account();
        cliente.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Particular').getRecordTypeId();
        cliente.FirstName = 'OLGA';
        cliente.LastName = 'ROBLES GEA';
        cliente.CC_NumPerso__c = '16849239';
        cliente.AV_NumPerso__c = '16849239';
        insert cliente;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cliente.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        //Insertamos la lista de valores
        Id rtListaValores = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        CC_Lista_Valores__c listValoresHorario = new CC_Lista_Valores__c();
        listValoresHorario.RecordTypeId = rtListaValores;
        listValoresHorario.Name = 'CSBD: Relación de valores Now - Salesforce: Turno';
        CC_Lista_Valores__c listValoresProducto = new CC_Lista_Valores__c();
        listValoresProducto.RecordTypeId = rtListaValores;
        listValoresProducto.Name = 'CSBD: Relación de valores Now - Salesforce: Empresa, familia y producto';
        insert new List<CC_Lista_Valores__c>{listValoresHorario, listValoresProducto};

        Id rtValores = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        CC_Lista_Valores__c valoresHorario = new CC_Lista_Valores__c();
        valoresHorario.Name = '08-10h';
        valoresHorario.RecordTypeId = rtValores;
        valoresHorario.CC_Lista__c = listValoresHorario.Id;
        valoresHorario.CC_Valor__c = 'Mañana';
        valoresHorario.CC_Valor2__c = '08:00 - 10:00';
        valoresHorario.CC_Valor2__c = '8';
        CC_Lista_Valores__c valoresProducto = new CC_Lista_Valores__c();
        valoresProducto.Name = 'Prestamo Online';
        valoresProducto.RecordTypeId = rtValores;
        valoresProducto.CC_Lista__c = listValoresProducto.Id;
        valoresProducto.CC_Valor__c = 'Préstamos';
        valoresProducto.CC_Valor2__c = 'Genérico';
        valoresProducto.CC_Valor2__c = 'CaixaBank';
        valoresProducto.CC_Activa__c = true;
        insert new List<CC_Lista_Valores__c>{valoresHorario, valoresProducto};
    }

    @isTest
    private static void testConsultaOTPOK() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Account cliente = [SELECT PersonContactId, AV_NumPerso__c FROM Account WHERE AV_NumPerso__c = '16849239' LIMIT 1];

            Contact contacto = [SELECT AV_NumPerso__c FROM Contact WHERE Id = :cliente.PersonContactId];
            contacto.AV_NumPerso__c = '16849239';
            update contacto;

            String jsonConsulta = '{"consultaWrapper": {"NUMPERSO": "01011957","IDIOMA": "es","CANAL": "Web","EMAILCLIENTE": "ramame69@hotmail.com","TELEFONOCLIENTE": "prueba2.txt","NOMBRESOLICITANTE": "RAQUEL","APELLIDO1": "Martos","APELLIDO2": "Medina","NIFSOLICITANTE": "46636883J","NOMBREPRODUCTO": "Prestamo Online","HORARIOCONTACTO": "08-10h"}}';
            RestRequest req = new RestRequest();
            req.requestURI = '/services/apexrest/ConsultaOTP';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(jsonConsulta);
            RestContext.request = req;

            RestResponse res = new RestResponse();
            RestContext.response = res;

            Test.startTest();
            CSBD_OTPChat.getOPT();
            Test.stopTest();

            CBK_OTP_Generado__c otpGenerado = [SELECT CBK_Codigo_OTP__c, CBK_Oportunidad__c FROM CBK_OTP_Generado__c];

            System.assert(otpGenerado != null, 'Comprobamos se crea el registro del OTP');
            System.assert(otpGenerado.CBK_Codigo_OTP__c != null, 'Comprobamos se asocia un sessionId al registro OTP');
            System.assert(otpGenerado.CBK_Oportunidad__c != null, 'Comprobamos se asocia una oportunidad al registro OTP');
        }
    }

    @isTest
    private static void testConsultaOTP1KO() {
        String jsonConsulta = '{"consultaWrapper": {"NUMPERSO": "","IDIOMA": "es","CANAL": "Web","EMAILCLIENTE": "ramame69@hotmail.com","TELEFONOCLIENTE": "prueba2.txt","NOMBRESOLICITANTE": "RAQUEL","APELLIDO1": "Martos","APELLIDO2": "Medina","NIFSOLICITANTE": "46636883J","NOMBREPRODUCTO": "Prestamo Online","HORARIOCONTACTO": "08-10h"}}';
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ConsultaOTP';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonConsulta);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            CSBD_OTPChat.getOPT();
            Test.stopTest();

            System.assert(res.statusCode == 400, 'Comprobamos el error de la integración');
        }
    }
}