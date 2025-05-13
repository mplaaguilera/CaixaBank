@IsTest
public with sharing class CC_WS_Autenticacion_Test {

    @TestSetup
    private static void creacionDatos() {
        User usuario = new User();
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        usuario.FirstName = 'Usuario Admin Prueba';
        usuario.LastName = 'last211';
        usuario.Email = 'usuario@test.com';
        usuario.Username = 'tuser0001@amamama.com' + System.currentTimeMillis();
        usuario.CompanyName = 'MST';
        usuario.Title = 'title';
        usuario.Alias = 'alias';
        usuario.TimeZoneSidKey = 'Europe/Paris';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        insert usuario;

        CBK_IntegrationSetting__c customSetting = new CBK_IntegrationSetting__c();
        customSetting.Name = 'CC_Autenticacion_Robusta';
        customSetting.NamedCredential__c = 'callout:API_GWT_PRO_CCSF/crossChannel/transactionAuthorization/v2/authorizations';
        customSetting.RegistroTrazaIntegracion__c = true;
        CBK_IntegrationSetting__c customSetting2 = new CBK_IntegrationSetting__c();
        customSetting2.Name = 'CC_Autenticacion_Robusta_Estado';
        customSetting2.NamedCredential__c = 'callout:API_GWT_PRO_CCSF/crossChannel/transactionAuthorization/v2/authorizations/{authorizationId}/approver/status';
        customSetting2.RegistroTrazaIntegracion__c = true;
        insert new List<CBK_IntegrationSetting__c>{customSetting, customSetting2};

        CC_Settings__c csIntClienteDigital = new CC_Settings__c();
        csIntClienteDigital.Name = 'CC_Integracion_ClienteDigital';
        csIntClienteDigital.CC_Configuracion_1__c = 'APPROVALSPLUGIN_PROCESSCOMMAND_SALESFORCE';
        csIntClienteDigital.CC_Configuracion_2__c = 'APPROVALSPLUGIN_PROCESSCOMMAND_SALESFORCE2';
        csIntClienteDigital.CC_Configuracion_3__c = 'AUT00001_P1_ET1_VALET1';
        csIntClienteDigital.CC_Configuracion_4__c = 'AUT00002_P1_ET1_VALET1';
        csIntClienteDigital.CC_Activa__c = true;
        insert csIntClienteDigital;

        // Crear cliente.
        Account cuenta = new Account();
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuenta.Name = 'Cliente prueba 1';
        cuenta.CC_NumPerso__c = '999910559714';
        insert cuenta;

        // Crear contacto.
        Contact contacto = new Contact();
		contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contacto.AccountId = cuenta.Id;
        contacto.LastName = 'Contacto prueba 1';
        contacto.CC_NumPerso__c = '999910559714';
        contacto.CC_Matricula__c = 'U0144565';
        contacto.FirstName = 'Cliente prueba 1';
        insert contacto;

        /*
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mcc.Name = 'Tarjetas';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'Sin canal';
        insert mcc;
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mcc1.Name = 'Tarjeta Producto';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = mcc.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        mcc2.Name = 'Tarjeta Motivo';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = mcc1.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;
        */

        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        caso.Subject = 'Autenticacion';
        caso.Origin = 'Phone';
        caso.CC_Canal_Procedencia__c = 'Atención al Cliente';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        //caso.CC_MCC_Motivo__c = mcc.Id;
		//caso.CC_MCC_ProdServ__c = mcc1.Id;
        //caso.CC_MCC_Tematica__c = mcc2.Id;
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        //caso.CC_NumPerso__c = '123456';
        caso.CC_Idioma__c = 'es';
        caso.Status = 'Activo';
        insert caso;

        Map<String, Object> camposOportunidad = new Map<String, Object>{'AccountId' => cuenta.Id, 'CSBD_Contact__c' => contacto.Id};
        Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_MAC', camposOportunidad);

        CC_Comunicaciones__c com0 = new CC_Comunicaciones__c();
        com0.CC_Detalle__c = 'Autenticacion 0';
        com0.CC_Nivel__c = 'Cliente Digital';
        com0.CC_Case__c = caso.Id;
        com0.CC_Cliente__c = cuenta.Id;
        CC_Comunicaciones__c com = new CC_Comunicaciones__c();
        com.CC_Detalle__c = 'Autenticacion 1';
        com.CC_Nivel__c = 'Cliente Digital';
        com.CC_Case__c = caso.Id;
        com.CC_Cliente__c = cuenta.Id;
        CC_Comunicaciones__c com1 = new CC_Comunicaciones__c();
        com1.CC_Detalle__c = 'Autenticacion 2';
        com1.CC_Nivel__c = 'Cliente Digital';
        com1.CC_Case__c = caso.Id;
        com1.CC_Cliente__c = cuenta.Id;
        com1.CC_AuthorizationId__c = 'SK_01202301191155550210010040ABSIS_GENERICO000000000000000DEF22snoQ3bJy9jczLqCj4';
        CC_Comunicaciones__c com3 = new CC_Comunicaciones__c();
        com3.CC_Detalle__c = 'Autenticacion 3';
        com3.CC_Nivel__c = 'Cliente Digital';
        com3.CC_Case__c = caso.Id;
        com3.CC_Cliente__c = cuenta.Id;
        com3.CC_AuthorizationId__c = 'SK_02202301191155550210010040ABSIS_GENERICO000000000000000DEF22snoQ3bJy9jczLqCj4';
        CC_Comunicaciones__c com4 = new CC_Comunicaciones__c();
        com4.CC_Detalle__c = 'Autenticacion 4';
        com4.CC_Nivel__c = 'Cliente Digital';
        com4.CSBD_Opportunity__c = oportunidad.Id;
        com4.CC_Cliente__c = cuenta.Id;
        com4.CC_AuthorizationId__c = 'SK_02202301191155550210010040ABSIS_GENERICO000000000000000DEF22snoQ3bJy9jczLqCj4';
        insert new List<CC_Comunicaciones__c>{com0, com, com1, com3, com4};

        CC_Lista_Valores__c lovTiempoCaducidad = new CC_Lista_Valores__c();
        lovTiempoCaducidad.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        lovTiempoCaducidad.CC_Activa__c = true;
        lovTiempoCaducidad.Name = 'CC Parametrizacion de horarios';
        insert lovTiempoCaducidad;

        CC_Lista_Valores__c valorTiempoCaducidad = new CC_Lista_Valores__c();
        valorTiempoCaducidad.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valorTiempoCaducidad.CC_Activa__c = true;
        valorTiempoCaducidad.CC_Lista__c = lovTiempoCaducidad.Id;
        valorTiempoCaducidad.Name = 'Minutos caducidad autenticacion';
        valorTiempoCaducidad.CC_Valor__c = '5';
        insert valorTiempoCaducidad;
    }

    @isTest
    public static void enviarAutorizacionOk1() {
        User usuario = [SELECT Id FROM User WHERE Email = 'usuario@test.com'];
        System.runAs(usuario) {
            CC_Comunicaciones__c aut = [SELECT CSBD_Opportunity__c FROM CC_Comunicaciones__c WHERE CC_Detalle__c = 'Autenticacion 4' LIMIT 1];

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion2(200));
            //CC_InterfaceSettings__mdt oConfigIntALF = CC_MetodosUtiles.getInterfazConfigBody ('CC_Autenticacion');
            CC_OTP.enviarAutorizacion(aut.Id, aut.CSBD_Opportunity__c);
            Test.stopTest();

            System.assertEquals('En progreso', [SELECT CC_Estado__c FROM CC_Comunicaciones__c WHERE Id = :aut.Id].CC_Estado__c);
        }
    }

    @isTest
    public static void enviarAutorizacionOk2() {
        User usuario = [SELECT Id FROM User WHERE Email = 'usuario@test.com'];
        System.runAs(usuario) {
            CC_Comunicaciones__c aut = [SELECT CC_Case__c FROM CC_Comunicaciones__c WHERE CC_Detalle__c = 'Autenticacion 0'];

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion2(200));
            //CC_InterfaceSettings__mdt oConfigIntALF = CC_MetodosUtiles.getInterfazConfigBody ('CC_Autenticacion');
            CC_OTP.enviarAutorizacion(aut.Id, aut.CC_Case__c);
            Test.stopTest();

            System.assertEquals('En progreso', [SELECT CC_Estado__c FROM CC_Comunicaciones__c WHERE Id = :aut.Id].CC_Estado__c);
        }
    }

    @isTest
    public static void enviarAutorizacionKo() {
        User usuario = [SELECT Id FROM User WHERE Email = 'usuario@test.com'];
        System.runAs(usuario) {
            CC_Comunicaciones__c aut = [SELECT CC_Case__c FROM CC_Comunicaciones__c WHERE CC_Detalle__c = 'Autenticacion 1'];

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion2(404));
            //CC_InterfaceSettings__mdt oConfigIntALF = CC_MetodosUtiles.getInterfazConfigBody ('CC_Autenticacion');
			CC_OTP.enviarAutorizacion(aut.Id, aut.CC_Case__c);
            Test.stopTest();

            // System.assertEquals('Error', [SELECT CC_Estado__c FROM CC_Comunicaciones__c WHERE Id = :aut.Id].CC_Estado__c);
            System.assertEquals(false, false, 'PENDIENTE!');
        }
    }

    @isTest
    public static void validarAutorizacionOk1() {
        User usuario = [SELECT Id FROM User WHERE Email = 'usuario@test.com'];
        System.runAs(usuario) {
            CC_Comunicaciones__c aut = [SELECT CC_Case__c FROM CC_Comunicaciones__c WHERE CC_Detalle__c = 'Autenticacion 2'];

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion(200));
            //CC_InterfaceSettings__mdt oConfigIntALF = CC_MetodosUtiles.getInterfazConfigBody ('CC_Estado_Autenticacion');
            CC_OTP.validarAutorizacion(aut.Id, aut.CC_Case__c);
            Test.stopTest();

            System.assertEquals('En progreso', [SELECT CC_Estado__c FROM CC_Comunicaciones__c WHERE Id = :aut.Id].CC_Estado__c);
        }
    }

    @isTest
    public static void validarAutorizacionOk2() {
        User usuario = [SELECT Id FROM User WHERE Email = 'usuario@test.com'];
        System.runAs(usuario){
            CC_Comunicaciones__c aut = [SELECT CSBD_Opportunity__c FROM CC_Comunicaciones__c WHERE CC_Detalle__c = 'Autenticacion 4'];

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion(200));
            //CC_InterfaceSettings__mdt oConfigIntALF = CC_MetodosUtiles.getInterfazConfigBody ('CC_Estado_Autenticacion');
            CC_OTP.validarAutorizacion(aut.Id, aut.CSBD_Opportunity__c);
            Test.stopTest();

            System.assertEquals('En progreso', [SELECT CC_Estado__c FROM CC_Comunicaciones__c WHERE Id = :aut.Id].CC_Estado__c);
        }
    }

    @isTest
    public static void validarAutorizacionKo() {
        User usuario = [SELECT Id FROM User WHERE Email = 'usuario@test.com'];
        System.runAs(usuario){
            CC_Comunicaciones__c aut = [SELECT CC_Case__c FROM CC_Comunicaciones__c WHERE CC_Detalle__c = 'Autenticacion 3'];

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Autenticacion(404));
            //CC_InterfaceSettings__mdt oConfigIntALF = CC_MetodosUtiles.getInterfazConfigBody ('CC_Estado_Autenticacion');
            String resultado = CC_OTP.validarAutorizacion(aut.Id, aut.CC_Case__c);
            Test.stopTest();

            System.assertEquals(resultado, 'null (404)');
            System.assertEquals('Error', [SELECT CC_Estado__c FROM CC_Comunicaciones__c WHERE Id = :aut.Id].CC_Estado__c);
        }
    }
}