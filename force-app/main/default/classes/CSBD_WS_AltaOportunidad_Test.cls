@isTest
public class CSBD_WS_AltaOportunidad_Test  {

    @testSetup
    private static void setup() {
        User usuarioAdministrador = CSBD_Usuarios.usuarioAdministrador();

        CSBD_IdentificacionImagin__c customSetting = new CSBD_IdentificacionImagin__c();
        customSetting.Name = 'CSBD_IdentificacionImagin';
        customSetting.CSBD_AplicarLogica__c = true;
        insert customSetting;

        CBK_IntegrationSetting__c cs = new CBK_IntegrationSetting__c();
        cs.Name = 'CSBD_WS_Adobe';
        cs.NamedCredential__c = 'callout:CSBD_WS_CredentialAdobe/{PARAMS_1}/{PARAMS_2}/{PARAMS_3}/{PARAMS_4}';
        insert cs;

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        a.Name = 'test@test.com';
        a.CC_NumPerso__c = '214449821';
        a.CC_TipoDocumento__c = 'NIF';
        a.CC_Numero_Documento__c = '12312312K';
        a.AV_IndicadoresClientes__c = '11';
        insert a;


        Contact c = new Contact();
        c.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        c.Email = 'test@test.com';
        c.LastName = 'test@test.com';
        c.AccountId = a.Id;
        c.CC_NumPerso__c = '214449821';
        c.CC_Numero_Documento__c = '12312312K';
        c.MobilePhone = '666555444';
        insert c;

        Contact c2 = new Contact();
        c2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        c2.Email = 'test@test45.com';
        c2.LastName = 'test@test45.com';
        c2.AccountId = a.Id;
        c2.CC_NumPerso__c = '0020FEA7';
        c2.CC_Numero_Documento__c = 'Y2992285E';
        c2.MobilePhone = '666555443';
        insert c2;

        Contact c3 = new Contact();
        c3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        c3.Email = 'test@test45123.com';
        c3.LastName = 'test@test45123.com';
        c3.AccountId = a.Id;
        c3.CC_NumPerso__c = '';
        c3.CC_Numero_Documento__c = '29801742K';
        c3.MobilePhone = '666555442';
        insert c3;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = a.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c>();
        List<CC_Lista_Valores__c> valoresOmni = new List<CC_Lista_Valores__c>();
        List<CC_Lista_Valores__c> listaValoresPIO = new List<CC_Lista_Valores__c>();
        List<CC_Lista_Valores__c> listaValoresBlacklist = new List<CC_Lista_Valores__c>();
        List<CC_Lista_Valores__c> listaValoresRelacionValoresNow = new List<CC_Lista_Valores__c>();
        List<Product2> productos = new List<Product2>();
        List<PricebookEntry> customPrices = new List<PricebookEntry>();

        Id valorRecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();

        //Lista envío omnichannel
        CC_Lista_Valores__c listaValoresOmni = new CC_Lista_Valores__c();
        listaValoresOmni.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValoresOmni.Name = 'CSBD: Motor de asignación - Tipos de oportunidad que se asignan';
        listaValoresOmni.CC_Activa__c = true;
        insert listaValoresOmni;

        CC_Lista_Valores__c valorHipotecaOmni = new CC_Lista_Valores__c();
        valorHipotecaOmni.RecordTypeId = valorRecordTypeId;
        valorHipotecaOmni.CC_Lista__c = listaValoresOmni.Id;
        valorHipotecaOmni.Name = 'Hipoteca';
        valoresOmni.add(valorHipotecaOmni);

        CC_Lista_Valores__c valorPrestamoOmni = new CC_Lista_Valores__c();
        valorPrestamoOmni.RecordTypeId = valorRecordTypeId;
        valorPrestamoOmni.CC_Lista__c = listaValoresOmni.Id;
        valorPrestamoOmni.Name = 'Préstamo';
        valoresOmni.add(valorPrestamoOmni);

        CC_Lista_Valores__c valorCMNOmni = new CC_Lista_Valores__c();
        valorCMNOmni.RecordTypeId = valorRecordTypeId;
        valorCMNOmni.CC_Lista__c = listaValoresOmni.Id;
        valorCMNOmni.Name = 'CMN';
        valoresOmni.add(valorCMNOmni);

        CC_Lista_Valores__c valorCMBOmni = new CC_Lista_Valores__c();
        valorCMBOmni.RecordTypeId = valorRecordTypeId;
        valorCMBOmni.CC_Lista__c = listaValoresOmni.Id;
        valorCMBOmni.Name = 'CMB';
        valoresOmni.add(valorCMBOmni);

        CC_Lista_Valores__c valorRentingOmni = new CC_Lista_Valores__c();
        valorRentingOmni.RecordTypeId = valorRecordTypeId;
        valorRentingOmni.CC_Lista__c = listaValoresOmni.Id;
        valorRentingOmni.Name = 'Renting';
        valoresOmni.add(valorRentingOmni);

        insert valoresOmni;

        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valorHipoteca = new CC_Lista_Valores__c();
        valorHipoteca.RecordTypeId = valorRecordTypeId;
        valorHipoteca.CC_Lista__c = listaValores.Id;
        valorHipoteca.Name = 'Hipoteca';
        valorHipoteca.CC_Valor__c = '1';
        valores.add(valorHipoteca);

        CC_Lista_Valores__c valorPrestamo = new CC_Lista_Valores__c();
        valorPrestamo.RecordTypeId = valorRecordTypeId;
        valorPrestamo.CC_Lista__c = listaValores.Id;
        valorPrestamo.Name = 'Préstamo';
        valorPrestamo.CC_Valor__c = '1';
        valores.add(valorPrestamo);

        CC_Lista_Valores__c valorRenting = new CC_Lista_Valores__c();
        valorRenting.RecordTypeId = valorRecordTypeId;
        valorRenting.CC_Lista__c = listaValores.Id;
        valorRenting.Name = 'Renting';
        valorRenting.CC_Valor__c = '1';
        valores.add(valorRenting);

        CC_Lista_Valores__c valorCompraEstrella = new CC_Lista_Valores__c();
        valorCompraEstrella.RecordTypeId = valorRecordTypeId;
        valorCompraEstrella.CC_Lista__c = listaValores.Id;
        valorCompraEstrella.Name = 'Wivai';
        valorCompraEstrella.CC_Valor__c = '1';
        valores.add(valorCompraEstrella);

        CC_Lista_Valores__c valorCMN = new CC_Lista_Valores__c();
        valorCMN.RecordTypeId = valorRecordTypeId;
        valorCMN.CC_Lista__c = listaValores.Id;
        valorCMN.Name = 'CMN';
        valorCMN.CC_Valor__c = '1';
        valores.add(valorCMN);

        CC_Lista_Valores__c valorCMB = new CC_Lista_Valores__c();
        valorCMB.RecordTypeId = valorRecordTypeId;
        valorCMB.CC_Lista__c = listaValores.Id;
        valorCMB.Name = 'CMB';
        valorCMB.CC_Valor__c = '1';
        valores.add(valorCMB);

        CC_Lista_Valores__c valorTPV = new CC_Lista_Valores__c();
        valorTPV.Name = 'TPV';
        valorTPV.RecordTypeId = valorRecordTypeId;
        valorTPV.CC_Lista__c = listaValores.Id;
        valorTPV.CC_Valor__c = '1';
        valores.add(valorTPV);

        CC_Lista_Valores__c valorMac = new CC_Lista_Valores__c();
        valorMac.Name = 'MAC';
        valorMac.RecordTypeId = valorRecordTypeId;
        valorMac.CC_Lista__c = listaValores.Id;
        valorMac.CC_Valor__c = '1';
        valores.add(valorMac);

        insert valores;

        CC_Lista_Valores__c valoresBlacklist = new CC_Lista_Valores__c();
        valoresBlacklist.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        valoresBlacklist.Name = 'CSBD: Blacklist';
        valoresBlacklist.CC_Activa__c = true;
        insert valoresBlacklist;

        CC_Lista_Valores__c blacklistTelefono = new CC_Lista_Valores__c();
        blacklistTelefono.RecordTypeId = valorRecordTypeId;
        blacklistTelefono.CC_Lista__c = valoresBlacklist.Id;
        blacklistTelefono.Name = '234098567';
        blacklistTelefono.CC_Valor__c = 'Teléfono';
        blacklistTelefono.CC_Activa__c = true;
        listaValoresBlacklist.add(blacklistTelefono);

        insert listaValoresBlacklist;

        Product2 productoRelacionValoresNow = new Product2(Name = 'Auto', isActive = true);
        Product2 productoAuto = new Product2(Name = 'Auto', Family = 'Auto', isActive = true, AV_ExternalID__c = '2220000');
        productoAuto.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('AV_PF').getRecordTypeId();
        insert productoAuto;

        insert productoRelacionValoresNow;

        CC_Lista_Valores__c valoresRelacionValoresNow= new CC_Lista_Valores__c();
        valoresRelacionValoresNow.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        valoresRelacionValoresNow.Name = 'CSBD: Relación de valores Now - Salesforce: Empresa, familia y producto';
        valoresRelacionValoresNow.CC_Activa__c = true;
        insert valoresRelacionValoresNow;

        CC_Lista_Valores__c valoresRelacionValoresNowInTouch = new CC_Lista_Valores__c();
        valoresRelacionValoresNowInTouch.RecordTypeId = valorRecordTypeId;
        valoresRelacionValoresNowInTouch.CC_Lista__c = valoresRelacionValoresNow.Id;
        valoresRelacionValoresNowInTouch.Name = 'Auto_intouch';
        valoresRelacionValoresNowInTouch.CC_Valor__c = 'Seguros';
        valoresRelacionValoresNowInTouch.CC_Valor2__c = 'Auto';
        valoresRelacionValoresNowInTouch.CSBD_Valor4__c = 'INTOUCH';
        valoresRelacionValoresNowInTouch.CC_Valor_SFDC__c = 'inTouch';
        valoresRelacionValoresNowInTouch.CSBD_Product2__c = productoAuto.Id;
        valoresRelacionValoresNowInTouch.CC_Activa__c = true;
        listaValoresRelacionValoresNow.add(valoresRelacionValoresNowInTouch);

        CC_Lista_Valores__c valorImagin = new CC_Lista_Valores__c();
        valorImagin.RecordTypeId = valorRecordTypeId;
        valorImagin.CC_Lista__c = valoresRelacionValoresNow.Id;
        valorImagin.Name = 'Auto_imaginBank';
        valorImagin.CC_Valor__c = 'Seguros';
        valorImagin.CC_Valor2__c = 'Auto';
        valorImagin.CC_Valor_SFDC__c = 'imaginBank';
        valorImagin.CC_Activa__c = true;
        listaValoresRelacionValoresNow.add(valorImagin);

        insert listaValoresRelacionValoresNow;

        //LISTA DE VALORES PRODUCTOS POR DEFECTO
        CC_Lista_Valores__c listaProductosDefecto= new CC_Lista_Valores__c();
        listaProductosDefecto.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaProductosDefecto.Name = 'CSBD: Acciones comerciales oportunidad';
        listaProductosDefecto.CC_Activa__c = true;
        insert listaProductosDefecto;

        List<CC_Lista_Valores__c> listaValoresProductosDefecto = new List<CC_Lista_Valores__c>();
        CC_Lista_Valores__c valorDefHipoteca = new CC_Lista_Valores__c();
        valorDefHipoteca.RecordTypeId = valorRecordTypeId;
        valorDefHipoteca.CC_Lista__c = listaProductosDefecto.Id;
        valorDefHipoteca.Name = 'Hipoteca';
        valorDefHipoteca.CC_Valor_SFDC__c = 'Hipoteca';
        valorDefHipoteca.CC_Valor__c = 'Hipoteca';
        valorDefHipoteca.CSBD_Alta_creacion__c = true;
        valorDefHipoteca.CC_Activa__c = true;
        listaValoresProductosDefecto.add(valorDefHipoteca);

        CC_Lista_Valores__c valorDefPrestamo = new CC_Lista_Valores__c();
        valorDefPrestamo.RecordTypeId = valorRecordTypeId;
        valorDefPrestamo.CC_Lista__c = listaProductosDefecto.Id;
        valorDefPrestamo.CC_Valor_SFDC__c = 'Préstamo';
        valorDefPrestamo.Name = 'Préstamo';
        valorDefPrestamo.CC_Valor__c = 'Préstamo';
        valorDefPrestamo.CSBD_Alta_creacion__c = true;
        valorDefPrestamo.CC_Activa__c = true;
        listaValoresProductosDefecto.add(valorDefPrestamo);

        Insert listaValoresProductosDefecto;

        //LISTA VALORES REGLAS TRASPASO INTOUCH
        List<CC_Lista_Valores__c> listaReglasTraspaso= new List<CC_Lista_Valores__c>();

        CC_Lista_Valores__c reglaTraspaso1 = new CC_Lista_Valores__c();
        reglaTraspaso1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_Regla_traspaso_oportunidad').getRecordTypeId();
        reglaTraspaso1.CSBD_Tipo_regla__c = 'Producto';
        reglaTraspaso1.Name = 'Auto_imaginBank';
        reglaTraspaso1.CC_Valor_SFDC__c = 'Hipoteca';
        reglaTraspaso1.CC_Valor__c = 'Auto_imaginBank';
        reglaTraspaso1.CC_Activa__c = true;
        reglaTraspaso1.CSBD_Empresa_Proveedora__c = 'imaginBank';
        reglaTraspaso1.CSBD_Aplica_horario__c = true;
        reglaTraspaso1.CC_Fecha_Vigencia_Inicio__c = System.now().addDays(-7);
        reglaTraspaso1.CC_Fecha_Vigencia_Fin__c = System.now().addDays(7);
        listaReglasTraspaso.add(reglaTraspaso1);

        CC_Lista_Valores__c reglaTraspaso2 = new CC_Lista_Valores__c();
        reglaTraspaso2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_Regla_traspaso_oportunidad').getRecordTypeId();
        reglaTraspaso2.CSBD_Tipo_regla__c = 'Tipo oportunidad';
        reglaTraspaso2.Name = 'cmb';
        reglaTraspaso2.CC_Activa__c = true;
        reglaTraspaso2.CC_Fecha_Vigencia_Inicio__c = System.now().addDays(-7);
        reglaTraspaso2.CC_Fecha_Vigencia_Fin__c = System.now().addDays(7);
        listaReglasTraspaso.add(reglaTraspaso2);

        CC_Lista_Valores__c reglaTraspaso3 = new CC_Lista_Valores__c();
        reglaTraspaso3.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_Regla_traspaso_oportunidad').getRecordTypeId();
        reglaTraspaso3.CSBD_Tipo_regla__c = 'Horario';
        reglaTraspaso3.Name = 'imaginBank - Horario invierno - Mañana';
        reglaTraspaso3.CSBD_Empresa_Proveedora__c = 'imaginBank';
        reglaTraspaso3.CC_Activa__c = true;
        reglaTraspaso3.CC_Fecha_Vigencia_Inicio__c = System.now().addDays(-7);
        reglaTraspaso3.CC_Fecha_Vigencia_Fin__c = System.now().addDays(7);
        reglaTraspaso3.CSBD_Hora_inicio_turno__c = Time.newInstance(6, 0, 0, 0);
        reglaTraspaso3.CSBD_Hora_fin_turno__c = Time.newInstance(15, 0, 0, 0);
        listaReglasTraspaso.add(reglaTraspaso3);

        insert listaReglasTraspaso;

    }

    public void altaOportunidadTestPrestamo() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/AltaOportunidad/altaOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf([SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_Prestamo_JSON' LIMIT 1].Body.toString());
        RestContext.request = request;
        RestContext.response = response;

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        list<String> iDs = new list<String>();
        System.runAs (usuarioAdministrador) {
            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();
            for(CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                iDs.add(respuesta.opportunityId);
            }
            list<Opportunity> oportunidades =  [SELECT id,CSBD_SistemaOrigen__c FROM Opportunity WHERE Id = :iDs];
            for(Opportunity oportunidad : oportunidades){
                System.assertEquals('WS',oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

    @isTest
    public static void altaOportunidadTestPrestamoBlacklist() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/AltaOportunidad/altaOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf([SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_Prestamo_Blacklist_JSON' LIMIT 1].Body.toString());
        RestContext.request = request;
        RestContext.response = response;

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        list<String> iDs = new list<String>();
        System.runAs (usuarioAdministrador) {
            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();
            for(CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                iDs.add(respuesta.opportunityId);
            }
            list<Opportunity> oportunidades =  [SELECT id,CSBD_SistemaOrigen__c FROM Opportunity WHERE Id = :iDs];
            for(Opportunity oportunidad : oportunidades){
                System.assertEquals('WS',oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

    @isTest
    public static void altaOportunidadTestHipoteca() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/AltaOportunidad/altaOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf([SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_Hipoteca_JSON' LIMIT 1].Body.toString());
        RestContext.request = request;
        RestContext.response = response;

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        list<String> iDs = new list<String>();
        System.runAs (usuarioAdministrador) {
            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();
            for(CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                iDs.add(respuesta.opportunityId);
            }
            list<Opportunity> oportunidades =  [SELECT id,CSBD_SistemaOrigen__c FROM Opportunity WHERE Id = :iDs];
            for(Opportunity oportunidad : oportunidades){
                System.assertEquals('WS',oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

    @isTest
    public static void altaOportunidadTestRenting() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/AltaOportunidad/altaOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf([SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_Renting_JSON' LIMIT 1].Body.toString());
        RestContext.request = request;
        RestContext.response = response;

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        list<String> iDs = new list<String>();
        System.runAs (usuarioAdministrador) {
            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();
            for(CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                iDs.add(respuesta.opportunityId);
            }
            list<Opportunity> oportunidades =  [SELECT id,CSBD_SistemaOrigen__c FROM Opportunity WHERE Id = :iDs];
            for(Opportunity oportunidad : oportunidades){
                System.assertEquals('WS',oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

    @isTest
    public static void altaOportunidadTestTPV() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/AltaOportunidad/altaOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf([SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_TPV_JSON' LIMIT 1].Body.toString());
        RestContext.request = request;
        RestContext.response = response;

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        list<String> iDs = new list<String>();
        System.runAs (usuarioAdministrador) {
            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();
            for(CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                iDs.add(respuesta.opportunityId);
            }
            list<Opportunity> oportunidades =  [SELECT id,CSBD_SistemaOrigen__c FROM Opportunity WHERE Id = :iDs];
            for(Opportunity oportunidad : oportunidades){
                System.assertEquals('WS',oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

    @isTest
    public static void altaOportunidadTestCompraEstrella() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/AltaOportunidad/altaOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf([SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_CompraEstrella_JSON' LIMIT 1].Body.toString());
        RestContext.request = request;
        RestContext.response = response;

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        list<String> iDs = new list<String>();
        System.runAs (usuarioAdministrador) {
            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();
            for(CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                iDs.add(respuesta.opportunityId);
            }
            list<Opportunity> oportunidades =  [SELECT id,CSBD_SistemaOrigen__c FROM Opportunity WHERE Id = :iDs];
            for(Opportunity oportunidad : oportunidades){
                System.assertEquals('WS',oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

    @isTest
    public static void altaOportunidadTestCmn() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/services/apexrest/AltaOportunidad/altaOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf([SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_CMN_JSON' LIMIT 1].Body.toString());
        RestContext.request = request;
        RestContext.response = response;

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            Set<String> idOportunidadesCreadas = new Set<String>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidadesCreadas.add(respuesta.opportunityId);
            }
            for (Opportunity opp : [SELECT CSBD_SistemaOrigen__c, CSBD_Resumen__c, ContactId FROM Opportunity WHERE Id IN :idOportunidadesCreadas]) {
                System.assertEquals('WS', opp.CSBD_SistemaOrigen__c, opp.Id + ': valor incorrecto en "Sistema origen" (' + opp.CSBD_SistemaOrigen__c + ')');
                System.assert(String.isNotBlank(opp.CSBD_Resumen__c), opp.Id + ': campo "Resumen" vacío');
                System.assert(String.isBlank(opp.ContactId), opp.Id + ': oportunidad con Contacto');
            }
        }
    }

    @isTest
    public static void altaOportunidadTestCmnBuzon() {
        CC_Lista_Valores__c listaValoresCmnWS = new CC_Lista_Valores__c();
        listaValoresCmnWS.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValoresCmnWS.Name = 'CSBD: Entrada CMN Cajeros - Códigos de campaña que se externalizan por correo';
        listaValoresCmnWS.CC_Activa__c = true;
        listaValoresCmnWS.CC_Valor__c='valor';
        insert listaValoresCmnWS;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/services/apexrest/AltaOportunidad/altaOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf([SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_CMNBuzon_JSON' LIMIT 1].Body.toString());
        RestContext.request = request;
        RestContext.response = response;

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            Set<String> idOportunidadesCreadas = new Set<String>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidadesCreadas.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c FROM Opportunity WHERE Id IN :idOportunidadesCreadas]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

    @isTest
    public static void altaOportunidadTestCmnComdata() {
        CC_Lista_Valores__c listaValoresCmnWS = new CC_Lista_Valores__c();
        listaValoresCmnWS.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValoresCmnWS.Name = 'CSBD: CMN - Productos gestionados externamente';
        listaValoresCmnWS.CC_Activa__c = true;
        insert listaValoresCmnWS;

        CC_Lista_Valores__c valorHazteCliente = new CC_Lista_Valores__c();
        valorHazteCliente.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valorHazteCliente.CC_Lista__c = listaValoresCmnWS.Id;
        valorHazteCliente.Name = 'HazteCliente';
        valorHazteCliente.CC_Valor__c = 'Comdata';
        valorHazteCliente.CC_Activa__c = true;
        insert valorHazteCliente;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/services/apexrest/AltaOportunidad/altaOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf([SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_CMN_Comdata_JSON' LIMIT 1].Body.toString());
        RestContext.request = request;
        RestContext.response = response;

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            Set<String> idOportunidadesCreadas = new Set<String>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidadesCreadas.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c FROM Opportunity WHERE Id IN :idOportunidadesCreadas]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

    @isTest
    public static void altaOportunidadTestCmb() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/services/apexrest/AltaOportunidad/altaOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf([SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_CMB_JSON' LIMIT 1].Body.toString());
        RestContext.request = request;
        RestContext.response = response;

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            Set<String> idOportunidadesCreadas = new Set<String>();
            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad. ' + respuesta.detalleError);
                idOportunidadesCreadas.add(respuesta.opportunityId);
            }
            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c, ContactId FROM Opportunity WHERE Id IN :idOportunidadesCreadas]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c);
                System.assert(String.isBlank(oportunidad.ContactId), oportunidad.Id + ': oportunidad con Contacto');
            }
        }
    }

    @isTest
    public static void altaOportunidadTestCmbTrasladoImagin() {
		CC_Lista_Valores__c horario = [SELECT CSBD_Hora_inicio_turno__c, CSBD_Hora_fin_turno__c FROM CC_Lista_Valores__c WHERE CSBD_Tipo_regla__c ='Horario'  AND Name='imaginBank - Horario invierno - Mañana' limit 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/services/apexrest/AltaOportunidad/altaOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf([SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_CMBImagin_JSON' LIMIT 1].Body.toString());
        RestContext.request = request;
        RestContext.response = response;

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs (usuarioAdministrador) {
            Date myDatetime = Datetime.now().date().toStartofWeek();
            CBK_UtilsDate.nowSystem = myDatetime;

            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            for (CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK Traspasada: imaginBank', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
            }
        }
    }

    @isTest
    public static void altaOportunidadTestDesestimientoPrestamo() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{'CSBD_Now_Presolicitud__c' => '4223010549222'});
        oportunidad.OwnerId = usuarioAdministrador.Id;
        update oportunidad;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/AltaOportunidad/altaOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf([SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_DesestimientoPrestamo_JSON' LIMIT 1].Body.toString());
        RestContext.request = request;
        RestContext.response = response;

        System.runAs(usuarioAdministrador) {
            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();
            for(CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
            }
        }
    }

    @isTest
    public static void altaOportunidadTestDesistimiento() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/AltaOportunidad/altaOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf([SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_Desistimiento_JSON' LIMIT 1].Body.toString());
        RestContext.request = request;
        RestContext.response = response;

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();

            Set<String> idOportunidadesCreadas = new Set<String>();
            for(CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                idOportunidadesCreadas.add(respuesta.opportunityId);
            }

            for (Opportunity oportunidad : [SELECT CSBD_SistemaOrigen__c, CSBD_Telefono_Solicitud__c FROM Opportunity WHERE Id IN :idOportunidadesCreadas]) {
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c);
                System.assertEquals('666555443', oportunidad.CSBD_Telefono_Solicitud__c);
            }
        }
    }

    private static CC_InterfaceSettings__mdt obtenerParametrosIntegracion(String interfazDevName) {
        List<CC_InterfaceSettings__mdt> parametrosInterfaz = [SELECT DeveloperName, CC_Certificado__c, CC_Endpoint__c, CC_TipoPeticion__c, CC_ContentType__c
                                                                FROM CC_InterfaceSettings__mdt WHERE DeveloperName = :interfazDevName AND CC_Activa__c = true LIMIT 1];
        if (!parametrosInterfaz.isEmpty()) {
            return parametrosInterfaz[0];
        } else {
            return null;
        }
    }

    @isTest
    public static void altaOportunidadTestDesistimientoPAI() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/services/apexrest/AltaOportunidad/altaOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf([SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_DesistimientoPAI_JSON' LIMIT 1].Body.toString());
        RestContext.request = request;
        RestContext.response = response;

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        list<String> iDs = new list<String>();

        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();
            for(CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                iDs.add(respuesta.opportunityId);
            }
            list<Opportunity> oportunidades =  [SELECT id,CSBD_SistemaOrigen__c FROM Opportunity WHERE Id = :iDs];
            for(Opportunity oportunidad : oportunidades){
                System.assertEquals('WS',oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

     @isTest
    public static void altaOportunidadTestProAutomatica() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/AltaOportunidad/altaOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf([SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_ProAutomatica_JSON' LIMIT 1].Body.toString());
        RestContext.request = request;
        RestContext.response = response;

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        list<String> iDs = new list<String>();
        System.runAs ( usuarioAdministrador ) {
            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();
            for(CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                iDs.add(respuesta.opportunityId);
            }
            list<Opportunity> oportunidades =  [SELECT id,CSBD_SistemaOrigen__c FROM Opportunity WHERE Id = :iDs];
            for(Opportunity oportunidad : oportunidades){
                System.assertEquals('WS',oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

         @isTest
    public static void altaOportunidadTestPlataformaHipoteca() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/AltaOportunidad/altaOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf([SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_PlataformaHipoteca_JSON' LIMIT 1].Body.toString());
        RestContext.request = request;
        RestContext.response = response;

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        list<String> iDs = new list<String>();
        System.runAs ( usuarioAdministrador ) {
            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();
            for(CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                iDs.add(respuesta.opportunityId);
            }
            list<Opportunity> oportunidades =  [SELECT id,CSBD_SistemaOrigen__c FROM Opportunity WHERE Id = :iDs];
            for(Opportunity oportunidad : oportunidades){
                System.assertEquals('WS',oportunidad.CSBD_SistemaOrigen__c);
            }
        }
    }

    @isTest
    public static void altaOportunidadTestSoporteDigital() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/AltaOportunidad/altaOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf([SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_PlataformaHipoteca_SoporteDigital' LIMIT 1].Body.toString());
        RestContext.request = request;
        RestContext.response = response;

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        list<String> iDs = new list<String>();
        System.runAs ( usuarioAdministrador ) {
            Test.startTest();
            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();
            for(CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                iDs.add(respuesta.opportunityId);
            }
            list<Opportunity> oportunidades =  [SELECT id, CSBD_SistemaOrigen__c, CSBD_Now_Origen__c FROM Opportunity WHERE Id = :iDs];
            for(Opportunity oportunidad : oportunidades){
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c);
                System.assertEquals('Contratación pack imaginTeens', oportunidad.CSBD_Now_Origen__c);
            }
        }
    }

    @isTest
    public static void altaOportunidadTestSoporteDigitalKids() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/AltaOportunidad/altaOportunidad';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf([SELECT Body FROM StaticResource WHERE Name = 'CSBD_WS_Alta_Oportunidad_PlataformaHipoteca_SoporteDigital' LIMIT 1].Body.toString());
        RestContext.request = request;
        RestContext.response = response;

        //Preparación de respuestas de prueba de los servicios web guardadas como static resources
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirCalcLimites)) {
            multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
        if (String.isNotBlank(endpointSirConsultaScorings)) {
            multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
        }
        multiMock.setStatusCode(200);
        multiMock.setHeader('Content-Type', 'text/xml');
        Test.setMock(HttpCalloutMock.class, multiMock);

        list<String> iDs = new list<String>();
        System.runAs ( usuarioAdministrador ) {
            Test.startTest();
            Date myDatetime = Date.newInstance(1975, 1, 1);
            CBK_UtilsDate.todaySystem = myDatetime;

            CSBD_WS_AltaOportunidad_Output output = CSBD_WS_AltaOportunidad.altaOportunidad();
            Test.stopTest();
            for(CSBD_WS_AltaOportunidad_Output.Respuesta respuesta : output.respuestas) {
                System.assertEquals('OK', respuesta.resultado, 'Ha habido algun error: ' + respuesta.detalleError);
                System.assertNotEquals('', respuesta.opportunityId, 'No se ha creado la oportunidad.' + respuesta.detalleError);
                iDs.add(respuesta.opportunityId);
            }
            list<Opportunity> oportunidades =  [SELECT id, CSBD_SistemaOrigen__c, CSBD_Now_Origen__c FROM Opportunity WHERE Id = :iDs];
            for(Opportunity oportunidad : oportunidades){
                System.assertEquals('WS', oportunidad.CSBD_SistemaOrigen__c);
                System.assertEquals('Contratación pack imaginKids', oportunidad.CSBD_Now_Origen__c);
            }
        }
    }

    @isTest
    public static void altaOportunidadMac() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs (usuarioAdministrador) {
            Case casoCc = new Case();
            casoCc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            insert casoCc;

            User usuarioGestor = CSBD_Usuarios.usuarioGestor();
            System.runAs(usuarioGestor) {
                Test.startTest();
                CSBD_WS_AltaOportunidad.altaOportunidadMac(casoCc.Id);
                Test.stopTest();
            }

            System.assertEquals(1, [SELECT Count() FROM Opportunity
                                    WHERE RecordType.DeveloperName = 'CSBD_MAC'
                                    AND CSBD_CasoOrigen__c = :casoCc.Id LIMIT 2], 'Debería haberse creado una oportunidad de tipo MAC');
        }
    }
}