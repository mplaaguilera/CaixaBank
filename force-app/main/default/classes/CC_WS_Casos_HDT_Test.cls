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
            Id idRtServicioGenesys = Schema.SObjectType.CC_Servicio_Genesys__c.getRecordTypeInfosByDeveloperName().get('CC_Servicio').getRecordTypeId();

            CC_Servicio_Genesys__c s1 = new CC_Servicio_Genesys__c();
            s1.RecordTypeId = idRtServicioGenesys;
            s1.Name = 'Servicio 1';
            s1.CC_Codigo__c = 'S1';
            s1.CBK_Negocio__c = 'HDT';
            s1.CC_VDN__c = '4444444';
            s1.CC_Tipo__C = 'Servicio';
            s1.CC_Canal_Procedencia__c = 'Servicios Centrales';
            s1.CC_Prefijo__c = '0';
            s1.CC_Tipo_Cliente__c = 'Empleado';


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
            
            //Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();

            Id recordTypeCuenta = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            Account cuenta = new Account(Name='Cuenta',CC_NumPerso__c = '0000001', RecordtypeId = recordTypeCuenta);
            insert cuenta;
            

            Id recordTypeContacto = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            Contact contacto = new Contact(RecordTypeId = recordTypeContacto,LastName='Contacto', AccountId=cuenta.Id);
            insert contacto;
            
            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Case c1 = new Case();
            c1.RecordTypeId = recordTypeCaso;
            c1.Subject = 'Prueba';
            c1.CC_Idioma__c = 'es';
            c1.CC_NumPerso__c = '123456';
            c1.CC_Tipo_Cliente__c = 'Empleado';
            c1.Status = 'Activo';
            c1.Origin = 'Chat';
            c1.CC_Numero_Documento__c = '60236005V';
            c1.CC_Tipo_Contacto__c = 'Consulta';
            c1.CC_Canal_Procedencia__c = 'EDG-BUILDING CENTER';
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

            contacto = [SELECT Account.CC_NumPerso__c FROM Contact WHERE Id = :contacto.Id LIMIT 1];

            String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
            
            String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
            CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
            oGrupo.RecordTypeId = sRecordType3;
            oGrupo.Name = 'Grupo1';
            oGrupo.CC_External__c = 'GC-00001';
            insert oGrupo;

            CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
            oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
            oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
            oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
            oClasif.CC_Activa__c = true;
            oClasif.CC_Propietario__c = 'TEST';
            insert oClasif;

            CC_Agrupador__c oAgr = new CC_Agrupador__c();
            oAgr.RecordTypeId = sRecordType;
            oAgr.CC_Titulo__c = 'Test';
            oAgr.CC_Descripcion__c = 'Test';
            oAgr.CC_GrupoMaximo__c = oGrupo.Id;
            oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
            oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
            oAgr.CC_Estado__c = 'Activo';
            insert oAgr;

            //Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Case c2 = new Case();
            c2.RecordTypeId = recordTypeCaso;
            c2.Subject = 'Prueba';
            c2.CC_Idioma__c = 'es';
            c2.CC_NumPerso__c = '123456';
            c2.CC_Tipo_Cliente__c = 'Empleado';
            c2.Status = 'Activo';
            c2.Origin = 'Chat';
            c2.CC_Numero_Documento__c = '60236005V';
            c2.CC_Tipo_Contacto__c = 'Consulta';
            c2.CC_Canal_Procedencia__c = 'EDG-BUILDING CENTER';
            c2.CC_Id_Cognitivo__c = 'HDD_666555666';
            c2.CC_Oficina_Afectada_Lookup__c = cuenta.Id;
            c2.CC_MCC_Motivo__c = mccMotivo.Id;
            c2.CC_MCC_ProdServ__c = mccProducto.Id;
            c2.CC_MCC_Tematica__c = mccTematica.Id;
            c2.CC_Agrupador_Id__c = oAgr.Id;
            insert c2;
            
            /*
            String jsonLlamada = obtenerJsonLlamada(s1.CC_Codigo__c, '', '', contacto.Account.CC_NumPerso__c);
            CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);*/

        }
        
    }

    @isTest
    public static void ccWSCasosHDTSinTiempoEntrada() {

        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDataIn = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input();
        oDataIn.fechaInicio = null;
        
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
    public static void ccWSCasosHDTVacio() {

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
    public static void ccWScasosHDTconFechas() {
        
        //List<CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input> oEntrada = new List<CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input>();
        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDataIn = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input();
        oDataIn.fechaInicio = Datetime.newInstance(2025, 7, 23, 0, 0, 0); // Fecha válida
        oDataIn.fechaFin = Datetime.newInstance(2025, 7, 23, 0, 0, 0); // Fecha válida

        
        User us = [SELECT Id FROM User WHERE Email ='tuser001@amamama.com' LIMIT 1];
        Case caso= [SELECT id, CC_Canal_Procedencia__c, Origin FROM Case WHERE Status ='Activo' LIMIT 1];
        //caso.CC_Canal_Procedencia__c = 'SmartPhones';
        //caso.Origin = 'Phone';
        //update caso;
        
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
    public static void ccWScasosHDTFechaInicioMayor() {
        
        //List<CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input> oEntrada = new List<CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input>();
        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDataIn = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input();
        oDataIn.fechaInicio = Datetime.newInstance(2025, 7, 25, 0, 0, 0); // Fecha válida
        oDataIn.fechaFin = Datetime.newInstance(2025, 7, 23, 0, 0, 0); // Fecha válida

        
        User us = [SELECT Id FROM User WHERE Email ='tuser001@amamama.com' LIMIT 1];
        Case caso= [SELECT id, CC_Canal_Procedencia__c, Origin FROM Case WHERE Status ='Activo' LIMIT 1];
        //caso.CC_Canal_Procedencia__c = 'SmartPhones';
        //caso.Origin = 'Phone';
        //update caso;
        
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
    public static void ccWScasosHDTUmbralMayor() {
        
        //List<CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input> oEntrada = new List<CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input>();
        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDataIn = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input();
        oDataIn.fechaInicio = Datetime.newInstance(2025, 7, 00, 0, 0, 0); // Fecha válida
        oDataIn.fechaFin = Datetime.newInstance(2025, 7, 23, 0, 0, 0); // Fecha válida

        
        User us = [SELECT Id FROM User WHERE Email ='tuser001@amamama.com' LIMIT 1];
        Case caso= [SELECT id, CC_Canal_Procedencia__c, Origin FROM Case WHERE Status ='Activo' LIMIT 1];
        //caso.CC_Canal_Procedencia__c = 'SmartPhones';
        //caso.Origin = 'Phone';
        //update caso;
        
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
    public static void ccWScasosHDT2() {
        
        //List<CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input> oEntrada = new List<CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input>();
        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDataIn = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input();
        oDataIn.tiempo = '10';

        
        User us = [SELECT Id FROM User WHERE Email ='tuser001@amamama.com' LIMIT 1];
        Case caso= [SELECT id, CC_Canal_Procedencia__c, Origin FROM Case WHERE Status ='Activo' LIMIT 1];
        //caso.CC_Canal_Procedencia__c = 'SmartPhones';
        //caso.Origin = 'Phone';
        //update caso;
        
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
    public static void ccWSCasosHDT() {
        
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
    public static void ccWScasosHDTError() {
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
    public static void ccWSCasosHDTError2() {
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

    @isTest
    public static void testObtenerTareasRelacionadas() {
        User us = [SELECT Id FROM User WHERE Email ='tuser001@amamama.com' LIMIT 1];

        Test.startTest();
        Case testCase= [SELECT id, CC_Canal_Procedencia__c, Origin FROM Case WHERE Status ='Activo' LIMIT 1];
        

            Task testTask = new Task(WhatId = testCase.Id, Subject = 'Test Task', Status = 'Not Started');
            insert testTask;
            
            List<Task> tareas = CC_WS_Casos_HDT.obtenerTareasRelacionadas(new List<Case>{testCase});
        System.runAs ( us ) {
            System.assertNotEquals(null, tareas);
        }
        Test.stopTest();
    }

    /*
    @isTest
    static void obtenerLlamadasRelacionadas() {
        Test.startTest();
        Case testCase= [SELECT id, CC_Canal_Procedencia__c, Origin FROM Case WHERE Status ='Activo' LIMIT 1];
        
        Task testTask = new Task(WhatId = testCase.Id, Subject = 'Test Task', Status = 'Not Started');
        insert testTask;
        
        List<CC_Llamada__c> llamadas = CC_WS_Casos_HDT.obtenerLlamadasRelacionadas(new List<Case>{testCase});
        System.assertNotEquals(null, llamadas);
        Test.stopTest();
    }*/

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
    

    /*
    @isTest
    public static void ccprueba02() {
        
		List<CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input> oEntrada = new List<CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input>();
        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDataIn = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input();
        oDataIn.tiempo = '10';
         String jsonMsg=JSON.serialize(oDataIn);
        
        User us = [SELECT Id FROM User WHERE Email ='tuser001@amamama.com' LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CC_Casos_HDT';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        req.resourcePath = 'CC_Casos_HDT';
        RestContext.request = req;
        RestContext.response= res;

        Case testCase= [SELECT id, CC_Canal_Procedencia__c, Origin FROM Case WHERE Status ='Activo' LIMIT 1];

        Test.startTest();
        System.runAs ( us ) {
            List<CC_Llamada__c> llamadas = CC_WS_Casos_HDT.obtenerLlamadasRelacionadas(new List<Case>{testCase});
            //global static CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output searchDetailCase(CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDataIn){

            CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oUtput = CC_WS_Casos_HDT.searchDetailCase(oDataIn);
            //System.assertNotEquals(null, oUtput, 'Error WS en método CC_WS_Llamadas_HDT');
        }
        Test.stopTest();
    }*/

    @isTest
    public static void ccprueba01(){
        
		List<CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input> oEntrada = new List<CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input>();
        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDataIn = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input();
        //oDataIn.tiempo = '10';
         String jsonMsg=JSON.serialize(oDataIn);
        
        User us = [SELECT Id FROM User WHERE Email ='tuser001@amamama.com' LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CC_Casos_HDT';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        req.resourcePath = 'CC_Casos_HDT';
        RestContext.request = req;
        RestContext.response= res;

        Case testCase= [SELECT id, CC_Canal_Procedencia__c, Origin FROM Case WHERE Status ='Activo' LIMIT 1];

        Test.startTest();
        System.runAs ( us ) {
            List<CC_Llamada__c> llamadas = CC_WS_Casos_HDT.obtenerLlamadasRelacionadas(new List<Case>{testCase});
            //global static CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output searchDetailCase(CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDataIn){

            CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oUtput = CC_WS_Casos_HDT.searchDetailCase(oDataIn);
            System.assertEquals(0, llamadas.size(), 'La lista de llamadas no debería estar vacía si existen llamadas relacionadas');

            //System.assertNotEquals(null, oUtput, 'Error WS en método CC_WS_Llamadas_HDT');
        }
        Test.stopTest();
    }

    @isTest
    public static void ccWSLlamadasHDTFallo() {
        
		List<CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input> oEntrada = new List<CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input>();
        CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDataIn = new CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input();
        oDataIn = null;

        //oDataIn.tiempo = '';
         //String jsonMsg=JSON.serialize(oDataIn);
         String jsonMsg = '';

        User us = [SELECT Id FROM User WHERE Email ='tuser001@amamama.com' LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CC_Casos_HDT';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        req.resourcePath = 'CC_Casos_HDT';
        RestContext.request = req;
        RestContext.response= res;

        Case testCase= [SELECT id, CC_Canal_Procedencia__c, Origin FROM Case WHERE Status ='Activo' LIMIT 1];

        Test.startTest();
        System.runAs ( us ) {
            List<CC_Llamada__c> llamadas = CC_WS_Casos_HDT.obtenerLlamadasRelacionadas(new List<Case>{testCase});
            //global static CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output searchDetailCase(CC_WS_Casos_HDT.CC_WS_Casos_HDT_Input oDataIn){

            CC_WS_Casos_HDT.CC_WS_Casos_HDT_Output oUtput = CC_WS_Casos_HDT.searchDetailCase(oDataIn);
            System.assertEquals(0, llamadas.size(), 'La lista de llamadas no debería estar vacía si existen llamadas relacionadas');
            
            //System.assertNotEquals(null, oUtput, 'Error WS en método CC_WS_Llamadas_HDT');
        }
        Test.stopTest();
    }
}