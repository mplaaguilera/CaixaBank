@isTest
public with sharing class CSBD_CMN_Comdata_Test {

    @TestSetup
    private static void altaDatosPrueba() {
        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor.CC_Lista__c = listaValores.Id;
        valor.Name = 'Préstamo';
        valor.CC_Valor__c = '1';
        listaValores.CC_Activa__c = true;
        insert valor;

        Pricebook2 listaPrecios = new Pricebook2();
        listaPrecios.Name = 'CSBD Price Book';
        listaPrecios.Description = 'CSBD Price Book';
        listaPrecios.IsActive = true;
        insert listaPrecios;
    }

    @isTest
    public static void test() {

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = '46979396X';
        cuenta.Phone = '666666666';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.Phone = '666666666';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        Map<String, Object> campos = new Map<String, Object>();
        campos.put('Name', 'oportunidad de prueba');
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        Opportunity cmn = CSBD_Opportunity.crearOportunidad('CSBD_CMN', campos);


        CSBD_CMN_Comdata.Input input = new CSBD_CMN_Comdata.Input();
        input.recordId = cmn.Id;
        input.producto = 'PrestamoFamilyExt';
        input.telefono = '600000000';
        input.nombre = 'ElNombre';
        input.apellido_1 = 'Ape1';
        input.apellido_2 = 'Ape2';
        input.nif = '12345678Z';
        input.origen = 'orig';
        input.proceso = 'proc';

        /*
        System.assert(
            respuesta.ok == 'false' || respuesta.ok == 'true',
            'El parámetro "ok" de la respuesta debe ser igual a "true" o "flase"'
        );
        */

        CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'CSBD_CMN_Comdata';
		wsc.NamedCredential__c = 'callout:CSBD_CMN_Comdata/api/CMN';
		insert wsc;
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
                String jsonToken = '{"ok":true,"transaccion":"061b2af9d543416d855f625ac908a502"}';
                HttpResponse resp = new HttpResponse();
                resp.setBody(jsonToken);		
                resp.setStatusCode(200);
                resp.setStatus('Ok');

                CSBD_CMN_Comdata.enviarCMNComdata(input);
                CSBD_CMN_Comdata.CSBD_CMN_Comdata_Respuesta respuesta = (CSBD_CMN_Comdata.CSBD_CMN_Comdata_Respuesta)JSON.deserialize(resp.getBody(), CSBD_CMN_Comdata.CSBD_CMN_Comdata_Respuesta.class);
                System.assertEquals(respuesta.ok,'true');
            Test.stopTest();
        }
    }
}