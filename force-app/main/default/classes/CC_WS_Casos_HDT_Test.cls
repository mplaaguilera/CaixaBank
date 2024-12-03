@isTest
public with sharing class CC_WS_Casos_HDT_Test {
    
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
            CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
            wsc.Name = 'CC_WS_Casos_HDT';
            wsc.RegistroTrazaIntegracion__c = true;
            insert wsc;
            
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
            
            Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            Case c1 = new Case();
            c1.RecordTypeId = recordTypeCaso;
            c1.Subject = 'Prueba';
            c1.CC_Idioma__c = 'es';
            c1.CC_NumPerso__c = '123456';
            c1.CC_Tipo_Cliente__c = 'Empleado';
            c1.Status = 'Activo';
            c1.Origin = 'Email';
            c1.CC_Numero_Documento__c = '60236005V';
            c1.CC_Tipo_Contacto__c = 'Petición de servicio';
            c1.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
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
        }
        

    }
    @isTest
    static void CC_WS_Casos_HDTVacio() {

        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDataIn = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input();
        oDataIn.tiempo = '';
        
        String jsonMsg=JSON.serialize(oDataIn);
        
        User us = [SELECT Id FROM User WHERE Email ='tuser001@amamama.com' LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CC_Casos_HDT';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        System.runAs ( us ) {
            CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oUtput = CC_WS_Casos_HDT.searchDetailCase(oDataIn);
            System.assertNotEquals(null, oUtput);
        }
        Test.stopTest();
    }
 
    @isTest
    static void CC_WS_Casos_HDT_2() {
        
        //List<CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input> oEntrada = new List<CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input>();
        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDataIn = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input();
        oDataIn.tiempo = '10';

        
        User us = [SELECT Id FROM User WHERE Email ='tuser001@amamama.com' LIMIT 1];
        Case caso= [SELECT id, CC_Canal_Procedencia__c, Origin FROM Case WHERE Status ='Activo' LIMIT 1];
        caso.CC_Canal_Procedencia__c = 'SmartPhones';
        caso.Origin = 'Phone';
        update caso;
        
        String jsonMsg=JSON.serialize(oDataIn);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CC_Casos_HDT';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        System.runAs ( us ) {
            CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oUtput = CC_WS_Casos_HDT.searchDetailCase(oDataIn);
            System.assertNotEquals(null, oUtput);
        }
        Test.stopTest();
    }
    @isTest
    static void CC_WS_Casos_HDT() {
        
        //List<CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input> oEntrada = new List<CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input>();
        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDataIn = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input();
        oDataIn.tiempo = '10';
        
        User us = [SELECT Id FROM User WHERE Email ='tuser001@amamama.com' LIMIT 1];
        String jsonMsg=JSON.serialize(oDataIn);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CC_Casos_HDT';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        System.runAs ( us ) {
            CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oUtput = CC_WS_Casos_HDT.searchDetailCase(oDataIn);
            System.assertNotEquals(null, oUtput);
        }
        Test.stopTest();
    }
    
    @isTest
    static void CC_WS_Casos_HDT_Error() {
        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDataIn = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input();
        oDataIn.tiempo = 'a';
        User us = [SELECT Id FROM User WHERE Email ='tuser001@amamama.com' LIMIT 1];
        
        String jsonMsg=JSON.serialize(oDataIn);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CC_Casos_HDT';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        System.runAs ( us ) {
            CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oUtput = CC_WS_Casos_HDT.searchDetailCase(oDataIn);
            System.assertNotEquals(null, oUtput);
        }
        Test.stopTest();
    }
    @isTest
    static void CC_WS_Casos_HDT_Error_2() {
        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDataIn = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input();
        oDataIn.tiempo = null;
        User us = [SELECT Id FROM User WHERE Email ='tuser001@amamama.com' LIMIT 1];
        
        String jsonMsg=JSON.serialize(oDataIn);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CC_Casos_HDT';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        System.runAs ( us ) {
            CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oUtput = CC_WS_Casos_HDT.searchDetailCase(oDataIn);
            System.assertNotEquals(null, oUtput);
        }
        Test.stopTest();
    }
}