@isTest
public with sharing class CC_WS_Llamadas_HDT_Test {


    public static String obtenerJsonLlamada(String servicio, String llamadaId, String casoId, String numPerso) {
        return obtenerJsonLlamada(servicio, llamadaId, casoId, numPerso, '666666666');
    }

    public static String obtenerJsonLlamada(String servicio, String llamadaId, String casoId, String numPerso, String ani) {
        return
        '{ "usuario": "1218",' +
        '  "extension": "1118",' +
        '  "connId": "12345678",' +
        '  "ani": "' + ani +'",' +
        '  "dnis": "666666666",' +
        '  "servicio": "' + servicio + '",' +
        '  "asunto": "Asunto",' +
        '  "numPerso": "' + numPerso + '",' +
        '  "idioma": "Castellano",' +
        '  "datos": "Datos",' +
        '  "connIdCognitivo": "87654321",' +
        '  "casoId": "' + casoId + '",' +
        '  "salesforceParentId": null,' +
        '  "llamadaId": "' + llamadaId + '"}';
    }

    // public static Contact crearContacto() {
	// 	Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
	// 	Id recordTypeOficina = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

    //     Account oficinaGestora = new Account(RecordTypeId = recordTypeOficina, Name = 'Cuenta oficina gestora', CC_Tipo_Centro__c = 'OF',  CC_Email__c = 'test@test.com');
    //     insert oficinaGestora;
    //     Account cuenta = new Account(RecordTypeId = recordTypeCuenta, Name = 'Cuenta', CC_NumPerso__c = '666', CC_OficinaGestoraId__c = oficinaGestora.Id);
    //     insert cuenta;

    //     Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
    //     Contact contacto = new Contact(RecordTypeId = recordTypeContacto, FirstName = 'Contacto', LastName='Contacto', AccountId = cuenta.Id);
    //     insert contacto;
    //     return contacto;
    // }
    @testSetup
    static void data(){
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Supervisor'].Id;
        UserRole roleId = [SELECT Id FROM UserRole WHERE Name = 'Contact Center' LIMIT 1];
        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = profileId;
        usuario1.UserRoleId = roleId.Id;
        usuario1.FirstName = 'Usuario Prueba';
        usuario1.LastName = 'last1';
        usuario1.Email = 'tuser000@amamama.com';
        usuario1.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';
        userList.add(usuario1);

        Id profileId2 = [SELECT Id FROM Profile WHERE Name = 'API Only'].Id;
        User usuario2 = new User();
        usuario2.ProfileId = profileId2;
        usuario2.UserRoleId = roleId.Id;
        usuario2.FirstName = 'Usuario Prueba 2';
        usuario2.LastName = 'last2';
        usuario2.Email = 'tuser001@amamama.com';
        usuario2.Username = 'tuser001@amamama.com' + System.currentTimeMillis();
        usuario2.CompanyName = 'MST';
        usuario2.Title = 'title';
        usuario2.Alias = 'alias2';
        usuario2.TimeZoneSidKey = 'Europe/Paris';
        usuario2.EmailEncodingKey = 'UTF-8';
        usuario2.LanguageLocaleKey = 'es';
        usuario2.LocaleSidKey = 'es_ES';
        userList.add(usuario2);

        insert userList;

        System.runAs(usuario1){

            CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(Name = 'Servicio 1',
                CC_Codigo__c = 'INC_TEC_CAJEROS',
                CC_VDN__c = '4444444',
                CC_Tipo__C = 'Servicio',
                CC_Canal_Procedencia__c = 'CaixaBankNow',
                CC_Prefijo__c = '0',
                CC_Fecha_Inicio_Salesforce__c = date.today(),
                CC_Tipo_Cliente__c = 'Empleado');
            insert servicio;
            
            Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
            CC_MCC__c mccTematica = new CC_MCC__c();
            mccTematica.Name = 'Alfabético';
            mccTematica.CC_Tipo_Cliente__c = 'Cliente';
            mccTematica.CC_Canal_Operativo__c = 'Sin canal';
            mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
            mccTematica.RecordTypeId = recordTypeIdTematica;
            mccTematica.CC_Codigo_Externo__c = 'TE-000001';
            insert mccTematica;
            
            Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
            CC_MCC__c mccProducto = new CC_MCC__c();
            mccProducto.Name = 'Personas';
            mccProducto.CC_Tipo_Cliente__c = 'Cliente';
            mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
            mccProducto.RecordTypeId = recordTypeIdProducto;
            mccProducto.CC_Tematica__c = mccTematica.Id;
            mccProducto.CC_Codigo_Externo__c = 'PR-000001';
            insert mccProducto; 
            
            Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
            CC_MCC__c mccMotivo = new CC_MCC__c();
            mccMotivo.Name = 'Personas confidenciales';
            mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
            mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today()-1;
            mccMotivo.RecordTypeId = recordTypeIdMotivo;
            mccMotivo.CC_Tematica__c = mccTematica.Id;
            mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
            mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
            insert mccMotivo;
            
            Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Account cuenta = new Account(Name='Cuenta',CC_NumPerso__c = '0000001', RecordtypeId = recordTypeCuenta);
            insert cuenta;
            
            Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Contact contacto = new Contact(RecordTypeId = recordTypeContacto,LastName='Contacto', AccountId=cuenta.Id);
            insert contacto;
            
            Case c1 = new Case();
            c1.Subject = 'Prueba';
            c1.CC_Idioma__c = 'es';
            c1.CC_NumPerso__c = '123456';
            c1.CC_Tipo_Cliente__c = 'Cliente';
            c1.Status = 'Activo';
            c1.Origin = 'Phone';
            c1.CC_Numero_Documento__c = '60236005V';
            c1.CC_Tipo_Contacto__c = 'Petición de servicio';
            c1.CC_Canal_Procedencia__c = 'Accionista';
            c1.CC_Id_Cognitivo__c = 'HDD_666555666';
            c1.CC_Oficina_Afectada_Lookup__c = cuenta.Id;
            c1.CC_MCC_Motivo__c = mccMotivo.Id;
            c1.CC_MCC_ProdServ__c = mccProducto.Id;
            c1.CC_MCC_Tematica__c = mccTematica.Id;
            insert c1;
            
            Task oTask = new Task();
            oTask.WhatId = c1.Id;
            oTask.CC_Chat_Cognitivo_Id__c = 'HDD_666555666';
            oTask.Status = 'Open';
            oTask.Subject = 'Conversación ChatBot - Hidden';
            insert oTask;
            
            CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
        wsc.Name = 'CC_WS_Llamadas_HDT_DET';
        wsc.RegistroTrazaIntegracion__c = true;
        insert wsc;

            contacto = [SELECT Account.CC_NumPerso__c FROM Contact WHERE Id = :contacto.Id LIMIT 1];

            String jsonLlamada = obtenerJsonLlamada(servicio.CC_Codigo__c, '', '', contacto.Account.CC_NumPerso__c);
            CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        }
    }
 @isTest
    static void CC_WS_Llamadas_HDT_2() {
        
		List<CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input> oEntrada = new List<CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input>();
        CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input oDataIn = new CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input();
        oDataIn.tiempo = '0';
         String jsonMsg=JSON.serialize(oDataIn);
        
        User us = [SELECT Id FROM User WHERE Email ='tuser001@amamama.com' LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CC_Llamadas_HDT';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        req.resourcePath = 'CC_Llamadas_HDT';
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        System.runAs ( us ) {
            CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Output oUtput = CC_WS_Llamadas_HDT.searchDetailLlamada(oDataIn);
            System.assertNotEquals(null, oUtput, 'Error WS en método CC_WS_Llamadas_HDT_2');
        }
        Test.stopTest();
    }
    @isTest
    static void CC_WS_Llamadas_HDTVacio() {
        
        CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input oDataIn = new CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input();
        oDataIn.tiempo = '';
        String jsonMsg=JSON.serialize(oDataIn);
        
        User us = [SELECT Id FROM User WHERE Email ='tuser001@amamama.com' LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CC_Llamadas_HDT';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        req.resourcePath = 'CC_Llamadas_HDT';
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        System.runAs ( us ) {
            CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Output oUtput = CC_WS_Llamadas_HDT.searchDetailLlamada(oDataIn);
            System.assertNotEquals(null, oUtput, 'Error WS en método CC_WS_Llamadas_HDTVacio');

        }
        Test.stopTest();
    }
    
    @isTest
    static void CC_WS_Llamadas_HDT() {
        
		List<CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input> oEntrada = new List<CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input>();
        CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input oDataIn = new CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input();
        oDataIn.tiempo = '10';
         String jsonMsg=JSON.serialize(oDataIn);
        
        User us = [SELECT Id FROM User WHERE Email ='tuser001@amamama.com' LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CC_Llamadas_HDT';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        req.resourcePath = 'CC_Llamadas_HDT';
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        System.runAs ( us ) {
            CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Output oUtput = CC_WS_Llamadas_HDT.searchDetailLlamada(oDataIn);
            System.assertNotEquals(null, oUtput, 'Error WS en método CC_WS_Llamadas_HDT');
        }
        Test.stopTest();
    }
    
    @isTest
    static void CC_WS_Llamadas_HDT_Error() {
        List<CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input> oEntrada = new List<CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input>();
        CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input oDataIn = new CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input();
        oDataIn.tiempo='a'; String jsonMsg=JSON.serialize(oDataIn);
        
        User us = [SELECT Id FROM User WHERE Email ='tuser001@amamama.com' LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CC_Llamadas_HDT';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        req.resourcePath = 'CC_Llamadas_HDT';
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        System.runAs ( us ) {
            CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Output oUtput = CC_WS_Llamadas_HDT.searchDetailLlamada(oDataIn);
            System.assertNotEquals(null, oUtput, 'Error WS en método CC_WS_Llamadas_HDT_Error');
        }
        Test.stopTest();
    }
       @isTest
    static void CC_WS_Llamadas_HDT_Error_2() {
        List<CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input> oEntrada = new List<CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input>();
        CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input oDataIn = new CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Input();
        oDataIn.tiempo=null; 
        String jsonMsg=JSON.serialize(oDataIn);
        
        User us = [SELECT Id FROM User WHERE Email ='tuser001@amamama.com' LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CC_Llamadas_HDT';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        req.resourcePath = 'CC_Llamadas_HDT';
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        System.runAs ( us ) {
            CC_WS_Llamadas_HDT.CC_WS_Llamadas_HDT_Output oUtput = CC_WS_Llamadas_HDT.searchDetailLlamada(oDataIn);
            System.assertNotEquals(null, oUtput, 'Error WS en método CC_WS_Llamadas_HDT_Error_2');
        }
        Test.stopTest();
    }
}