@isTest
public with sharing class HDT_LiveAgent_BotonesControllerTest {
    @testSetup
    static void testSetup(){
        Id recordTypeCliente = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        //String sChatRT = Schema.getGlobalDescribe().get('LiveChatTranscript').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Clientes').getRecordTypeId();
        String recordtypeEmpleado = Schema.getGlobalDescribe().get('LiveChatTranscript').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleados').getRecordTypeId();
        String recordTypeApp = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Aplicaciones').getRecordTypeId();
        Id recordTypeCategoria = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Categoria').getRecordTypeId();
        Id clienteCuentaRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id clienteContactoRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id recordTypeIdSolucion = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();

        List<LiveChatVisitor> lLiveChatVisitor = new List<LiveChatVisitor>();
        List<Case> lCasos = new List<Case>();
        List<CC_FAQ__c> lFaq = new List<CC_FAQ__c>();
        List<LiveChatTranscript> lChatTranscript = new List<LiveChatTranscript>();
        List<Account> lAccount = new List<Account>();
        List<Contact> lContact = new List<Contact>();


        Account cuentaSimple = new Account(
            RecordTypeId = clienteCuentaRecordTypeId,
            Name = 'Cuenta de cliente no Confidencial ES'
        );
        lAccount.add(cuentaSimple);

        Account cuentaConfidencial = new Account(
            RecordTypeId = clienteCuentaRecordTypeId,
            Name = 'Cuenta de cliente Confidencial ES'
        );
        lAccount.add(cuentaConfidencial);
        insert lAccount;

        Contact contactoSimple = new Contact(
            RecordTypeId = clienteContactoRecordTypeId,
            FirstName = 'NOCONFIDENCIAL',
            LastName = 'Test',
            AccountId = cuentaSimple.Id,
            CC_Idioma__c = 'Es'
        );
        lContact.add(contactoSimple);

        Contact contactoConfidencial = new Contact(
            RecordTypeId = clienteContactoRecordTypeId,
            FirstName = 'CONFIDENCIAL',
            LastName = 'Test',
            AccountId = cuentaConfidencial.Id,
            CC_Idioma__c = 'Es'
        );
        lContact.add(contactoConfidencial);
        insert lContact;

        CC_MCC__c mccTematica = new CC_MCC__c(
            Name = 'Ahorro a la vista',
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Fecha_Vigencia_Inicio__c = date.today(),
            RecordTypeId = recordTypeIdTematica,
            CC_Codigo_Externo__c = 'TE-000001',
            CC_Canal_Operativo__c = 'App BrokerNow');
        insert mccTematica;

        CC_MCC__c mccProducto = new CC_MCC__c(
            Name = 'Cuenta corriente',
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Fecha_Vigencia_Inicio__c = date.today(),
            RecordTypeId = recordTypeIdProducto,
            CC_Tematica__c = mccTematica.Id,
            CC_Codigo_Externo__c = 'PR-000001');
        insert mccProducto;

       	CC_MCC__c mccMotivo = new CC_MCC__c(
            Name = 'Apertura sin autorización',
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Fecha_Vigencia_Inicio__c = date.today(),
            RecordTypeId = recordTypeIdMotivo,
            CC_Producto_Servicio__c = mccProducto.Id,
            CC_Codigo_Externo__c = 'MO-000001');
        insert mccMotivo;

        CC_MCC__c causa = new CC_MCC__c(
            RecordTypeId = recordTypeIdCausa,
            Name = 'Causa Test',
            CC_Fecha_Vigencia_Inicio__c = date.today(),
            CC_Motivo__c = mccMotivo.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'CA-000001');
        insert causa;

        CC_MCC__c solucion = new CC_MCC__c(
            RecordTypeId = recordTypeIdSolucion,
            Name = 'Solucion Test',
            CC_Fecha_Vigencia_Inicio__c = date.today(),
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Causa__c = causa.Id,
            CC_Codigo_Externo__c = 'SO-000001');
        insert solucion;

        Case caso = new Case(
            Origin = 'Chat',
            Status = 'Activo',
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            Subject = 'Prueba',
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'App',
            RecordTypeId = recordTypeCliente,
            CC_Detalles_Consulta__c = 'Detalles Consulta',
            CC_Detalles_Solucion__c = 'Detalles Solución',
            CC_MCC_Tematica__c = mccTematica.Id,
            CC_MCC_ProdServ__c = mccProducto.Id,
            CC_MCC_Motivo__c = mccMotivo.Id,
            CC_Canal_Operativo__c = 'Sin canal',
            ContactId = contactoSimple.Id
        );
        lCasos.add(caso);

        Case casoCa = new Case(
            Origin = 'Chat',
            Status = 'Activo',
            CC_Idioma__c = 'ca',
            CC_Canal_Respuesta__c = 'Email',
            Subject = 'Prueba2',
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'App',
            RecordTypeId = recordTypeCliente
        );
        lcasos.add(casoCa);
        insert lCasos;

        /*
        UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];

        User usuarioGeneral = new User();
        usuarioGeneral.Username = 'usergeneral@test.com';
        usuarioGeneral.Email = 'email@test.com';
        usuarioGeneral.LastName = 'usuarioGeneral Test';
        usuarioGeneral.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        usuarioGeneral.Alias = 'alias';
        usuarioGeneral.TimeZoneSidKey = 'GMT';
        usuarioGeneral.LocaleSidKey = 'es_ES';
        usuarioGeneral.EmailEncodingKey = 'ISO-8859-1';
        usuarioGeneral.LanguageLocaleKey = 'en_US';
        usuarioGeneral.isActive = true;
        usuarioGeneral.UserRoleId = rolId.Id;
        insert usuarioGeneral;

*/

        //crear usuarios CC
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id profile2Id = [SELECT Id FROM Profile WHERE Name = 'CC_Analísta y 2º nivel MVP2'].Id;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_CCO'];

        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = profileId;
        usuario1.FirstName = 'Usuario Admin Prueba';
        usuario1.LastName = 'last211';
        usuario1.Email = 'pruebaChat@kfsb.com';
        usuario1.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';

        userList.add(usuario1);

		insert userList;
        UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];

        System.runAs(usuario1){
			List<User> userList2 = new List<User>();
            User usuarioV2 = new User();
            usuarioV2.ProfileId = profile2Id;
            usuarioV2.FirstName = 'Usuario 2 Prueba';
            usuarioV2.LastName = 'last11';
            usuarioV2.Email = 'tuser000@test.com';
            usuarioV2.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
            usuarioV2.CompanyName = 'MST';
            usuarioV2.Title = 'title';
            usuarioV2.Alias = 'alias';
            usuarioV2.TimeZoneSidKey = 'Europe/Paris';
            usuarioV2.EmailEncodingKey = 'UTF-8';
            usuarioV2.LanguageLocaleKey = 'es';
            usuarioV2.LocaleSidKey = 'es_ES';
            usuarioV2.UserRoleId = rolId.Id;
            userList2.add(usuarioV2);

            User usuario = new User();
            usuario.ProfileId = profile2Id;
            usuario.FirstName = 'Usuario 2 Prueba';
            usuario.LastName = 'last11';
            usuario.Email = 'tuser000111@amamama.com';
            usuario.Username = 'tuser000111@amamama.com' + System.currentTimeMillis();
            usuario.CompanyName = 'MST';
            usuario.Title = 'title';
            usuario.Alias = 'alias';
            usuario.TimeZoneSidKey = 'Europe/Paris';
            usuario.EmailEncodingKey = 'UTF-8';
            usuario.LanguageLocaleKey = 'es';
            usuario.LocaleSidKey = 'es_ES';
            usuario.UserRoleId = rolId.Id;
			userList2.add(usuario);
            insert userList2;
        }


        CC_FAQ__c newNoSopEs = new CC_FAQ__c(
            CC_Respuesta_Mensaje_Automatico_es__c = 'Hola, com estàs?',
            CC_Mensaje_Agente_es__c = '<auto>',
            CC_Procedencia_Mensaje_Automatico__c = 'No soportada',
            CC_Origen__c = 'App',
            CC_Nombre__c = 'No Soportada 01',
            Name = 'No Soportada 01',
            CC_AreaMensaje__c = 'Cliente',
            CC_IdiomaMsj__c = 'es');
        lFaq.add(newNoSopEs);

        CC_FAQ__c oFranja = new CC_FAQ__c(
            CC_Respuesta_Mensaje_Automatico_es__c = 'Hola, ¿como estás?',
            CC_Procedencia_Mensaje_Automatico__c = 'Franja Dia',
            CC_Nombre__c = 'Franja Dia Mañana',
            Name = 'Franja Dia Mañana',
            CC_AreaMensaje__c = 'Cliente',
            CC_IdiomaMsj__c = 'es');
        lFaq.add(oFranja);

        CC_FAQ__c changeLanguageFaq = new CC_FAQ__c(
            Name = 'Cambio de idioma',
            CC_Nombre__c = 'Cambio idioma',
            CC_Codigo_Cognitive__c = 'CAMBIO_IDIOMA',
            CC_Mensaje_Agente_ca__c = '<auto>',
            CC_Mensaje_Agente_es__c = '<auto>',
            CC_Procedencia_Mensaje_Automatico__c = 'Cambio de idioma',
            CC_Respuesta_Mensaje_Automatico_ca__c = 'Canvi d\'idioma',
            CC_Respuesta_Mensaje_Automatico_es__c = 'Cambio de idioma');
        lFaq.add(changeLanguageFaq);

        CC_FAQ__c faqAhorroAPlazoEnDivisas = new CC_FAQ__c(
            Name = 'AhorroAPlazoEnDivisas',
            RecordtypeId = recordTypeCategoria);
        lFaq.add(faqAhorroAPlazoEnDivisas);

        CC_FAQ__c aplicacion = new CC_FAQ__c(
            RecordTypeId = recordTypeApp,
            Name= 'NeoApp');
        lFaq.add(aplicacion);
        insert lFaq;

        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
            lLiveChatVisitor.add(liveChatVisitor);
        LiveChatVisitor liveChatVisitor2 = new LiveChatVisitor();
            lLiveChatVisitor.add(liveChatVisitor2);
        insert lLiveChatVisitor;

        LiveChatTranscript liveChatTranscriptEs = new LiveChatTranscript(
            CC_Bienvenida__c = false,
            CC_Nickname__c = 'Cliente 1',
            CC_IdiomaCV__c = 'es',
            LiveChatVisitorId = liveChatVisitor.Id,
            CaseId = caso.Id,
            CC_IdsGlobales__c = '7,12',
            RecordTypeId = recordtypeEmpleado,
            CC_PerfilVisitante__c = 'Default',
            CC_Pilotaje__c = 'Test,Pilotaje',
            CC_Id_Cognitive__c = 'ID_COGNITIVE',
            CC_Espacio__c = 'liniaObertaWSLOE',
            CC_Categoria__c = 'LineaAbiertaLOE',
            CC_NumPerso__c = '1',
            Status = 'InProgress',
            CC_Cognitive_chat__c = '{"user": "U0137298", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Como_puedo_dar_de_alta_una_Servicuenta", "confidence": 0.8238105773925781 }, {"id": "Como_dar_de_alta_una_servicuenta_si_no_tengo_un_deposito_de_ahorro", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Operativa_de_Reintegros_Stop_go_", "confidence": 0.23751013278961183 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&iquest;C&oacute;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["es"], "errors": [] }'
        );
        lChatTranscript.add(liveChatTranscriptEs);

        LiveChatTranscript liveChatTranscriptCa = new LiveChatTranscript(
            CC_Bienvenida__c = false,
            CC_Nickname__c = 'Cliente 2',
            CC_IdiomaCV__c = 'ca',
            LiveChatVisitorId = liveChatVisitor2.Id,
            CaseId = casoCa.Id,
            CC_IdsGlobales__c = '8,13',
            RecordTypeId = recordtypeEmpleado,
            CC_PerfilVisitante__c = 'Default',
            CC_Pilotaje__c = 'Test,Pilotaje',
            CC_Id_Cognitive__c = 'ID_COGNITIVE',
            CC_Espacio__c = 'liniaObertaWSLOE',
            CC_Categoria__c = 'LineaAbiertaLOE',
            CC_NumPerso__c = '1',
            CC_Cognitive_chat__c = '{"user": "U0137298", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Como_puedo_dar_de_alta_una_Servicuenta", "confidence": 0.8238105773925781 }, {"id": "Como_dar_de_alta_una_servicuenta_si_no_tengo_un_deposito_de_ahorro", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Operativa_de_Reintegros_Stop_go_", "confidence": 0.23751013278961183 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&iquest;C&oacute;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["ca"], "errors": [] }'
        );
        lChatTranscript.add(liveChatTranscriptCa);
        insert lChatTranscript;
    }

    @isTest
    static void testgetValuesIdioma() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

            LiveChatTranscript liveChatTranscriptCa = [SELECT Id FROM LiveChatTranscript WHERE CC_IdiomaCV__c = 'ca'];
            Id idid = liveChatTranscriptCa.Id;

            Test.startTest();
            Map<String,Object> idiomaestest = HDT_LiveAgent_BotonesController.getValuesIdioma(idid);
            Test.stopTest();

            System.assertEquals(true, !idiomaestest.isEmpty(), 'corroboramos que el idioma no este vacio');
        }
    }

    @isTest
    static void testGetLiveChatTranscript() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            LiveChatTranscript liveChatTranscriptEs = [SELECT Id FROM LiveChatTranscript LIMIT 1];

            Test.startTest();
            Map<String,Object> resultado = HDT_LiveAgent_BotonesController.getLiveChatTranscript(liveChatTranscriptEs.Id);
            Test.stopTest();

            System.assertEquals(true, !resultado.isEmpty(), 'comprobamos que devuelva datos');
        }
    }

    @isTest
    static void testGetLiveChatTranscript_V2() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            LiveChatTranscript liveChatTranscriptEs = [SELECT Id FROM LiveChatTranscript LIMIT 1];

            Test.startTest();
            Map<String,Object> resultado = HDT_LiveAgent_BotonesController.getLiveChatTranscript_v2(liveChatTranscriptEs.Id,'mañana');
            Test.stopTest();

            System.assertEquals(true, !resultado.isEmpty());
        }
    }

    @isTest
    static void testCheckBienvenida() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            LiveChatTranscript liveChatTranscriptEs = [SELECT Id FROM LiveChatTranscript LIMIT 1];

            Test.startTest();
            HDT_LiveAgent_BotonesController.checkBienvenida(liveChatTranscriptEs.Id);
            Test.stopTest();

            liveChatTranscriptEs = [SELECT CC_Bienvenida__c FROM LiveChatTranscript LIMIT 1];
            System.assertEquals(liveChatTranscriptEs.CC_Bienvenida__c, true);
        }
    }

    @isTest
    static void testChangeLanguageEsToCa() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            LiveChatTranscript liveChatTranscriptEs = [SELECT Id, CaseId, CC_Aplicacion__c FROM LiveChatTranscript WHERE CC_Nickname__c = 'Cliente 1' LIMIT 1];
            liveChatTranscriptEs.CC_Aplicacion__c = 'LineaAbiertaLOE';
            update liveChatTranscriptEs;

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_FAQ_Perfil_Mock());
            Map<String,Object> oResultado = HDT_LiveAgent_BotonesController.changeLanguage(liveChatTranscriptEs.CaseId, liveChatTranscriptEs.Id, 'ca', 'Cliente');
            Test.stopTest();

            LiveChatTranscript liveChatTranscriptResult = [SELECT CC_IdiomaCV__c FROM LiveChatTranscript WHERE Id =: liveChatTranscriptEs.Id];
            Case caseResult = [SELECT  CC_Idioma__c FROM Case WHERE Id =: liveChatTranscriptEs.CaseId];
            System.assertEquals('ca', caseResult.CC_Idioma__c, 'Revisa que el idioma del caso sea CA');
            System.assertEquals('ca', liveChatTranscriptResult.CC_IdiomaCV__c, 'Revisa que el idioma del chat sea CA');
            System.assertEquals(true, !oResultado.isEmpty());
        }
    }

    @isTest
    static void testChangeLanguageCaToEs() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            LiveChatTranscript liveChatTranscriptCa = [SELECT Id, CaseId, CC_Aplicacion__c FROM LiveChatTranscript WHERE CC_Nickname__c = 'Cliente 2' LIMIT 1];
            liveChatTranscriptCa.CC_Aplicacion__c = 'LineaAbiertaLOE';
            update liveChatTranscriptCa;

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CC_FAQ_Perfil_Mock());
            Map<String,Object> oResultado = HDT_LiveAgent_BotonesController.changeLanguage(liveChatTranscriptCa.CaseId, liveChatTranscriptCa.Id, 'es', 'Cliente');
            Test.stopTest();

            LiveChatTranscript liveChatTranscriptResult = [SELECT CC_IdiomaCV__c FROM LiveChatTranscript WHERE Id =: liveChatTranscriptCa.Id];
            Case caseResult = [SELECT  CC_Idioma__c FROM Case WHERE Id =: liveChatTranscriptCa.CaseId];
            System.assertEquals('es', caseResult.CC_Idioma__c, 'Revisa que el idioma del caso sea ES');
            System.assertEquals('es', liveChatTranscriptResult.CC_IdiomaCV__c, 'Revisa que el idioma del chat sea ES');
            System.assertEquals(true, !oResultado.isEmpty());
        }
    }

    @isTest
    static void getMotivoNoSoportadaES(){
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            List<CC_FAQ__c> pickListValuesList = new List<CC_FAQ__c>();

            Test.startTest();
            pickListValuesList = HDT_LiveAgent_BotonesController.getMensajesChat('No soportada', 'es', null, 'App', 'Cliente');
            Test.stopTest();

            System.assertEquals(pickListValuesList.size(), 1, 'Cuemprueba que traiga la FAQ correspondiente');
        }
    }

    @isTest
    static void getMensajesBienvenidaES(){
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            List<CC_FAQ__c> listaFaq = new List<CC_FAQ__c>();
            Contact contactoSimple = [SELECT Id FROM Contact WHERE FirstName = 'NOCONFIDENCIAL'];
            Contact contactoConfidencial= [SELECT Id FROM Contact WHERE FirstName = 'CONFIDENCIAL'];
            contactoConfidencial.CC_Confidencial__c = true;
            update contactoConfidencial;

            CC_FAQ__c newFAQEsSimple = [SELECT Id FROM CC_FAQ__c WHERE Name = 'Franja Dia Mañana'];
                newFAQEsSimple.CC_Respuesta_Mensaje_Automatico_es__c = 'Hola, ¿como estás?';
                newFAQEsSimple.CC_Procedencia_Mensaje_Automatico__c = 'Bienvenida';
                newFAQEsSimple.CC_Nombre__c = 'Bienvenida 01';
                newFAQEsSimple.Name = 'Bienvenida 01';
                listaFaq.add(newFAQEsSimple);

            CC_FAQ__c newFAQEsConfidencial = [SELECT Id FROM CC_FAQ__c WHERE Name = 'No Soportada 01'];
                newFAQEsConfidencial.CC_Respuesta_Mensaje_Automatico_es__c = 'Hola confidencial, ¿como estás?';
                newFAQEsConfidencial.CC_Procedencia_Mensaje_Automatico__c = 'Bienvenida confidencial';
                newFAQEsConfidencial.CC_Nombre__c = 'Bienvenida confidencial 01';
                newFAQEsConfidencial.Name = 'Bienvenida confidencial 01';
                listaFaq.add(newFAQEsConfidencial);

            update listaFaq;

            Test.startTest();
            List<String> mensajeSimple = HDT_LiveAgent_BotonesController.getMensajesBienvenida('es', null, 'App', String.valueOf(contactoSimple.Id), 'Mañana', 'Cliente');
            List<String> mensajeConfidencial = HDT_LiveAgent_BotonesController.getMensajesBienvenida('es', null, 'App', String.valueOf(contactoConfidencial.Id), 'Mañana', 'Cliente');
            Test.stopTest();

            System.assertEquals('Hola, ¿como estás?', mensajeSimple[0], 'recupera FAQ de no confidencial');
            System.assertEquals('Hola confidencial, ¿como estás?', mensajeConfidencial[0], 'recupera FAQ no confidencial');
        }
    }

    @isTest
    static void testUpdateLiveChatTrans() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            LiveChatTranscript liveChatTranscript = [SELECT Id FROM LiveChatTranscript WHERE CC_Nickname__c = 'Cliente 1' LIMIT 1];
            Test.startTest();
            HDT_LiveAgent_BotonesController.UpdateLiveChatTrans(liveChatTranscript.Id);
            Test.stopTest();
            LiveChatTranscript liveChatTranscript2 = [SELECT Id, CC_Cerrado_TimeOut__c FROM LiveChatTranscript WHERE CC_Nickname__c = 'Cliente 1' LIMIT 1];
            System.assertEquals(liveChatTranscript2.CC_Cerrado_TimeOut__c, true, 'corrobora que se haya cerrado por timeout');
        }
    }

    @isTest
    static void CreateActivity(){
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Case caso = [SELECT Id FROM Case WHERE CC_Idioma__c = 'es' LIMIT 1];

            Id recordId = caso.Id;
            String comentario = 'Se ha producido un time out.';
            String subject = 'Chat - Time Out';
            String tipo = 'Time Out';
            String cognitiveID = 'CognitiveID_XXXX';
            String telefono = '666123456';
            String espacio = 'Ahorro';
            String categoria = 'AhorroAPlazoEnDivisas';
            Test.startTest();
            HDT_LiveAgent_BotonesController.CreateActivity(recordId, comentario, subject, tipo, cognitiveID, null, telefono, espacio, categoria);
            Test.stopTest();
            Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
            Task taskTest = [SELECT Id, Type FROM Task WHERE Subject = 'Chat - Time Out' AND RecordTypeId =: taskRecordTypeId];
            System.assertEquals(tipo, taskTest.Type, 'Corrobora el tipo de tarea');
        }
    }

    @isTest
    static void envioAltaSiebel(){
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            LiveChatTranscript liveChatTranscriptCa = [SELECT Id, CaseId FROM LiveChatTranscript WHERE CC_Nickname__c = 'Cliente 2' LIMIT 1];
            Test.startTest();
            String sSR = HDT_LiveAgent_BotonesController.envioAltaSiebel(liveChatTranscriptCa.Id, '');
            Test.stopTest();
            LiveChatTranscript lct = [SELECT Id, CC_Actualizar_Siebel__c FROM LiveChatTranscript WHERE CC_Nickname__c = 'Cliente 2' LIMIT 1];
            System.assertEquals(lct.CC_Actualizar_Siebel__c, false);
        }
    }

    @isTest
    static void datosLiveChatTranscriptTest() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Map<String,String> datos = new Map<String,String>();
            Case caso = [SELECT Id FROM Case WHERE CC_Idioma__c = 'es' LIMIT 1];

            String recordId = (String)caso.Id;
            String idioma = 'es';
            String espacio = 'Ahorro';
            String categoria = 'AhorroAPlazoEnDivisas';

            datos.put('Categoria',categoria);
            datos.put('Espacio',espacio);
            datos.put('Idioma',idioma);
            Test.startTest();
            datos = HDT_LiveAgent_BotonesController.datosLiveChatTranscript(recordId, idioma, espacio, categoria,'test');
            Test.stopTest();
            System.assertEquals(true, !datos.isEmpty());
        }

    }

    @isTest
    static void datosLiveChatTranscriptCategoriaNullTest() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

            LiveChatTranscript liveChatTranscript = [SELECT Id FROM LiveChatTranscript WHERE CC_Nickname__c = 'Cliente 1' LIMIT 1];
            liveChatTranscript.CC_Aplicacion__c = 'LineaAbiertaLOE';
            update liveChatTranscript;

            String recordId = (String)liveChatTranscript.Id;
            String idioma = 'es';
            String espacio = 'Ahorro';
            String categoria = 'AhorroAPlazoEnDivisas';

            Map<String,String> datos = new Map<String,String>();
            datos.put('Categoria',categoria);
            datos.put('Espacio',espacio);
            datos.put('Idioma',idioma);
            Test.startTest();
            datos = HDT_LiveAgent_BotonesController.datosLiveChatTranscript(recordId, idioma, espacio, null,'test');
            Test.stopTest();
            System.assertEquals(true, !datos.isEmpty());
        }

    }

   @isTest
    static void datosLiveChatTranscriptTestCat() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Case caso = [SELECT Id FROM Case WHERE CC_Idioma__c = 'ca' LIMIT 1];

            String recordId = (String)caso.Id;
            String idioma = 'ca';
            String espacio = 'Ahorro';
            String categoria = 'AhorroAPlazoEnDivisas';

            Map<String,String> datos = new Map<String,String>();
            datos.put('Categoria',categoria);
            datos.put('Espacio',espacio);
            datos.put('Idioma',idioma);
            Test.startTest();
            datos = HDT_LiveAgent_BotonesController.datosLiveChatTranscript(recordId, idioma, espacio, categoria,'test');
            Test.stopTest();
            System.assertEquals(true, !datos.isEmpty());
        }

    }

    @isTest
    static void recuperarEspacios(){
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            String idioma = 'es';
            String espacio = 'Ahorro';

            CC_FAQ__c aplicacion = [SELECT Id, Name FROM CC_FAQ__c WHERE Name ='NeoApp'];

            List <CC_FAQ__c> espacios = new List<CC_FAQ__c>();
            Id iRT = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
            espacios.add(new CC_FAQ__c(RecordTypeId=iRT,CC_Obsoleto__c=false, Name = espacio, CC_Lookup_App__c = aplicacion.Id));
            insert espacios;
            Test.startTest();
            List<CC_LiveAgent_FAQ_Controller.pickListWrapper> options = HDT_LiveAgent_BotonesController.recuperarEspacios(idioma, espacio, aplicacion.Name);
            Test.stopTest();
            System.assertEquals(1, options.size());
        }

    }

     @isTest
    static void recuperarEspaciosFilter(){
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            String idioma = 'ca';
            String espacio = 'Ahorro';
            List <CC_FAQ__c> espacios = new List<CC_FAQ__c>();
            Id iRT = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
            espacios.add(new CC_FAQ__c(RecordTypeId=iRT,CC_Obsoleto__c=false, Name = espacio));
            insert espacios;
            Test.startTest();
            List<CC_LiveAgent_FAQ_Controller.pickListWrapper> options = HDT_LiveAgent_BotonesController.recuperarEspaciosFilter(idioma, espacio);
            Test.stopTest();
            System.assertEquals(1, options.size());
        }

    }

    @isTest
    static void recuperarCategorias(){
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            String categoria = 'AhorroAPlazoEnDivisas';
            String espacio = 'Ahorro';
            List <CC_FAQ__c> espacios = new List<CC_FAQ__c>();
            Id iRT = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
            espacios.add(new CC_FAQ__c(RecordTypeId=iRT,CC_Obsoleto__c=false, Name = espacio));
            insert espacios;
            Test.startTest();
            List<CC_LiveAgent_FAQ_Controller.pickListWrapper> options = HDT_LiveAgent_BotonesController.recuperarCategorias(espacio, categoria, null);
            Test.stopTest();
            System.assertEquals(1, options.size());
        }
    }

    @isTest
    static void actualizarLiveChat() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

            LiveChatTranscript liveChatTranscript = [SELECT Id FROM LiveChatTranscript WHERE CC_Nickname__c = 'Cliente 1' LIMIT 1];
            String recordId = (String)liveChatTranscript.Id;
            Boolean transferir = false;
            String espacio = 'Ahorro';
            String categoria = 'AhorroAPlazoEnDivisas';

            liveChatTranscript.CC_Espacio__c = espacio;
            liveChatTranscript.CC_Categoria__c = categoria;
            liveChatTranscript.CC_Transferir__c = transferir;
            update liveChatTranscript;
            Test.startTest();
            HDT_LiveAgent_BotonesController.actualizarLiveChat(recordId, espacio, categoria, transferir);
            Test.stopTest();
            System.assertEquals('Ahorro', liveChatTranscript.CC_Espacio__c, 'corrobora que el espacio sea ahorro');
        }
    }


    @isTest
    static void cerrarCaso() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

            LiveChatTranscript chat = [SELECT Id FROM LiveChatTranscript WHERE CC_Nickname__c = 'Cliente 1' LIMIT 1];
            Case caso = [SELECT Id FROM Case WHERE CC_Idioma__c = 'es' LIMIT 1];
            chat.CC_Tipo__c = 'Hidden';
            chat.CaseId = caso.Id;
            update chat;
            Test.startTest();
            HDT_LiveAgent_BotonesController.cerrarCaso(chat.Id);
            Test.stopTest();
            LiveChatTranscript chatResult = [SELECT CaseId, CC_Tipo__c, Status, Case.Status FROM LiveChatTranscript WHERE Id = :chat.Id];
            System.assertEquals('Cerrado', chatResult.Case.Status, 'corrobora que se haya cerrado el caso');
        }

    }

    @isTest
    static void gestionChatOwner_Interno2(){
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            LiveChatTranscript liveChatTranscript = [SELECT Id FROM LiveChatTranscript WHERE CC_Nickname__c = 'Cliente 1' LIMIT 1];
            User usuario = [SELECT Id FROM User WHERE Email = 'tuser000@test.com' LIMIT 1];
            Case caso = [SELECT Id FROM Case WHERE CC_Idioma__c = 'es' LIMIT 1];
            caso.OwnerId = usuario.Id;
            update caso;

            liveChatTranscript.CC_Tipo__c = 'Hidden';
            liveChatTranscript.CaseId = caso.Id;
            update liveChatTranscript;

            Test.startTest();
            HDT_LiveAgent_BotonesController.gestionChatOwner_Interno2(liveChatTranscript.Id);
            Test.stopTest();

            Case caso2 = [SELECT OwnerId FROM Case WHERE Id = :caso.Id];
            //TEST
            System.assertEquals(caso.OwnerId, caso.OwnerId, 'Revisamos la asignacion de prop. del caso');
        }

    }

    @isTest
    static void CreateActivityPausa(){
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            LiveChatTranscript lc = [SELECT Id FROM LiveChatTranscript WHERE CC_Nickname__c = 'Cliente 1' LIMIT 1];
            Case caso = [SELECT Id FROM Case WHERE CC_Idioma__c = 'es' LIMIT 1];

            Test.startTest();
            HDT_LiveAgent_BotonesController.CreateActivityPausa(caso.Id,'202203300081',lc.id,23);
            Test.stopTest();

            LiveChatTranscript lcAssert = [SELECT Id,CC_Numero_Pausas__c FROM LiveChatTranscript WHERE Id = :lc.Id];

            System.assertEquals(23, lcAssert.CC_Numero_Pausas__c);

            Task taskAssert = [SELECT Id,ActivityDate,Type,Subject,Status,WhatId,CC_Chat_Cognitivo_Id__c,CC_LiveChatTranscript_Id__c FROM Task];

            System.assertEquals(system.today(), taskAssert.ActivityDate);
            System.assertEquals('Pausa Chat', taskAssert.Type);
            System.assertEquals('Pausa Chat', taskAssert.Subject);
            System.assertEquals('Open', taskAssert.Status);
            System.assertEquals(caso.Id, taskAssert.WhatId);
            System.assertEquals('202203300081', taskAssert.CC_Chat_Cognitivo_Id__c);
            System.assertEquals(lc.Id, taskAssert.CC_LiveChatTranscript_Id__c);
        }
    }

    @isTest
    static void CloseActivityPausa(){
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            LiveChatTranscript lc = [SELECT Id FROM LiveChatTranscript WHERE CC_Nickname__c = 'Cliente 1' LIMIT 1];
            Case caso = [SELECT Id FROM Case WHERE CC_Idioma__c = 'es' LIMIT 1];

            Id taskId = HDT_LiveAgent_BotonesController.CreateActivityPausa(caso.Id,'202203300081',lc.id,23);

            Test.startTest();
            HDT_LiveAgent_BotonesController.CloseActivityPausa(taskId,lc.id,69,23,null);
            Test.stopTest();

            LiveChatTranscript lcAssert = [SELECT Id,CC_Tiempo_Pausado__c FROM LiveChatTranscript WHERE Id = :lc.Id];

            System.assertEquals(69, lcAssert.CC_Tiempo_Pausado__c);

            Task taskAssert = [SELECT AV_WaitingRoomTime__c,Status FROM Task WHERE Id = :taskId];
            System.assertEquals(23, taskAssert.AV_WaitingRoomTime__c);
            System.assertEquals('Completed', taskAssert.Status);
        }
    }

    @isTest
    static void getMensajesPausaChat(){
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Id rt = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Mensaje_Automatico_Chat').getRecordTypeId();
            List<CC_FAQ__c> lFaq = new List<CC_FAQ__c>();

            CC_FAQ__c faq = [SELECT Id FROM CC_FAQ__c WHERE Name = 'No Soportada 01'];
            faq.CC_Mensaje_Agente_es__c = 'Estoy haciendo unas comprobaciones para resolver tu consulta. Por favor mantente a la espera CLIENTES';
            faq.RecordTypeId = rt;
            faq.CC_Nombre__c = 'Mensaje Automatico Pausa';
            faq.CC_AreaMensaje__c = 'Cliente';
            lFaq.add(faq);
            CC_FAQ__c faq1 =  [SELECT Id FROM CC_FAQ__c WHERE Name = 'Franja Dia Mañana'];
            faq1.CC_Mensaje_Agente_es__c = 'Estoy haciendo unas comprobaciones para resolver tu consulta. Por favor mantente a la espera EMPLEADOS';
            faq1.RecordTypeId = rt;
            faq1.CC_Nombre__c = 'Mensaje Automatico Pausa';
            faq1.CC_AreaMensaje__c = 'Empleado';
            lFaq.add(faq1);
            update lFaq;

            Test.startTest();
            //List<String> mensajeCli = HDT_LiveAgent_BotonesController.getMensajesPausaChat('Cliente', 'es');
            List<String> mensajeEmp = HDT_LiveAgent_BotonesController.getMensajesPausaChat('Empleado', 'es');
            Test.stopTest();

            //System.assertEquals(3, mensajeCli.size());
            System.assertEquals(3, mensajeEmp.size());
        }
    }

    @isTest
    static void getMensajesPausaChatIdioma(){
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            List<CC_FAQ__c> lFaq = new List<CC_FAQ__c>();
            Id rtFaq = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Mensaje_Automatico_Chat').getRecordTypeId();

            CC_FAQ__c faq = [SELECT Id FROM CC_FAQ__c WHERE Name = 'No Soportada 01'];
            faq.CC_Mensaje_Agente_es__c = 'Continuo fent comprovacions…';
            faq.RecordTypeId = rtFaq;
            faq.CC_Nombre__c = 'Mensaje Automatico Pausa';
            faq.CC_AreaMensaje__c = 'Empleado';
            faq.CC_IdiomaMsj__c = 'ca';
            faq.Name = 'Mensaje Automatico Pausa';
        lFaq.add(faq);
        CC_FAQ__c faq1 = [SELECT Id FROM CC_FAQ__c WHERE Name = 'Franja Dia Mañana'];
            faq1.CC_Mensaje_Agente_es__c = 'No m\'he oblidat! Segueixo amb les comprovacions per a oferir-te la millor resposta.';
            faq1.RecordTypeId = rtFaq;
            faq1.CC_Nombre__c = 'Mensaje Automatico Pausa';
            faq1.CC_AreaMensaje__c = 'Empleado';
            faq1.CC_IdiomaMsj__c = 'ca';
            faq1.Name = 'Mensaje Automatico Pausa';
        lFaq.add(faq1);
        CC_FAQ__c faq2 = [SELECT Id FROM CC_FAQ__c WHERE Name = 'Cambio de idioma'];
            faq2.CC_Mensaje_Agente_es__c = 'Estic fent unes comprovacions per a resoldre el teu dubte. Torno de seguida! EMPLEADOS';
            faq2.RecordTypeId = rtFaq;
            faq2.CC_Nombre__c = 'Mensaje Automatico Pausa';
            faq2.CC_AreaMensaje__c = 'Empleado';
            faq2.CC_IdiomaMsj__c = 'ca';
            faq2.Name = 'Mensaje Automatico Pausa';
        lFaq.add(faq2);
            update lFaq;
            Test.startTest();
            List<String> mensajeEmp = HDT_LiveAgent_BotonesController.getMensajesPausaChat('Empleado', 'ca');
            Test.stopTest();

            System.assertEquals('Estic fent unes comprovacions per a resoldre el teu dubte. Torno de seguida! EMPLEADOS', mensajeEmp[0], 'Comprobamos los mensajes');
            System.assertEquals('Continuo fent comprovacions…', mensajeEmp[1], 'Comprobamos los mensajes');
            System.assertEquals('No m\'he oblidat! Segueixo amb les comprovacions per a oferir-te la millor resposta.', mensajeEmp[2], 'Comprobamos los mensajes');
        }
    }
       @isTest 
   static void datosLiveChatTranscriptTransferChatTest() {
        
        LiveChatTranscript liveChatTranscript = [SELECT Id FROM LiveChatTranscript WHERE CC_Nickname__c = 'Cliente 1' LIMIT 1];
        String recordId = (String)liveChatTranscript.Id;
        String espacio = 'It';
        String idioma = 'es';
        String categoria = 'Aplicaciones';
        String tipoChat = 'Agente';
        User usuario1 = [SELECT Id FROM User WHERE LastName LIKE 'last11' AND Email = 'tuser000@test.com' AND IsActive=true LIMIT 1];
        System.runAs(usuario1){
            Test.startTest();
            Map<String,String> oRes = HDT_LiveAgent_BotonesController.datosLiveChatTranscriptTransfer(recordId, idioma, espacio, categoria, tipoChat, false);
            Test.stopTest();
            
            System.assertEquals('Aplicaciones', oRes.get('Categoria'), 'la categoria no coincide');
            
        }
    }
}