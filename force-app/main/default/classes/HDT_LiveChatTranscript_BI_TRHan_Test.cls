@isTest
public with sharing class HDT_LiveChatTranscript_BI_TRHan_Test {

    @testSetup
    public static void testSetup()
    {

        //Datos para el email
        List <String> owaEmails = new List<String>{('Atención Empleados Contact Center IT Grupo CaixaBank')};
        List <OrgWideEmailAddress> owa = new List <OrgWideEmailAddress>([SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName IN : owaEmails]);

        HDT_Parametros__c params = new HDT_Parametros__c();
        params.Name = 'HDT_Email_Respuesta_Empleados_New';
        params.HDT_Configuracion_1__c = owa[0].Address;
        params.HDT_Configuracion_2__c = owa[0].Address;
        insert params;

        
        //Obtenemos los RecordTypes de la lista de valores
        Id listaRelacionRT = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        Id listaValorRT = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        
        //Creamos los registros que relacionan Espacio-Categoría con el Servicio
        List<CC_Lista_Valores__c> relacionEspacioCategoriaServicio = new List<CC_Lista_Valores__c>();
        CC_Lista_Valores__c listaRelacionEspacioCategoriaServicio = new CC_Lista_Valores__c();
        listaRelacionEspacioCategoriaServicio.RecordTypeId = listaRelacionRT;
        listaRelacionEspacioCategoriaServicio.Name = 'HDT_Relacion_EspacioCategoria_Skill_Chat';
        listaRelacionEspacioCategoriaServicio.CC_Activa__c = true;
        insert listaRelacionEspacioCategoriaServicio;

        CC_Lista_Valores__c relacion = new CC_Lista_Valores__c();
        relacion.RecordTypeId = listaValorRT;
        relacion.Name = 'Espacio';
        relacion.CC_Activa__c = true;
        relacion.CC_Valor__c = 'Categoria';
        relacion.CC_Servicio__c = 'Servicio';
        relacion.CC_Orden__c = 1;
        relacion.CC_Lista__c = listaRelacionEspacioCategoriaServicio.Id;
        relacionEspacioCategoriaServicio.add(relacion);

        insert relacionEspacioCategoriaServicio;
    }
    
    @isTest
    static void testEmployee() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        List<LiveChatTranscript> oChats;
        
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        
        Id rt = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByDeveloperName().get('HDT_Empleados').getRecordTypeId();
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            CC_Bienvenida__c = false,
            UserAgent = 'ChatdeempleadosHDT',
            recordtypeId = rt,
            CC_Nickname__c = 'Cliente 1',
            CC_Idioma__c = 'es',
            LiveChatVisitorId = liveChatVisitor.Id,
            CC_CaseOrigin__c='Chat',
            CC_Tipo__c = 'Hidden',
            CC_NumEmpleado__c = 'U0137298',
            CC_Cognitive_chat__c='{"user": "U0137298", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Como_puedo_dar_de_alta_una_Servicuenta", "confidence": 0.8238105773925781 }, {"id": "Como_dar_de_alta_una_servicuenta_si_no_tengo_un_deposito_de_ahorro", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Operativa_de_Reintegros_Stop_go_", "confidence": 0.23751013278961183 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&iquest;C&oacute;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "Chat", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["es"], "errors": [], "perfil":"bueno", "idGlobalList":["123456789"], "pilotaje":["piloto"],"sourceConversationID":"34625791388_226572751","sourceAplicacionCorpus":"NoaWhatsapp" }',
            CC_Id_Cognitive__c='test0',
            CC_Espacio__c = 'Espacio',
            CC_Categoria__c = 'Categoria'
        );

        Test.startTest();
            
            insert liveChatTranscript;
        Test.stopTest();

        List<LiveChatTranscript> listaChats = [SELECT Id, CC_Servicio_Chat__c,UserAgent FROM LiveChatTranscript WHERE Id = :liveChatTranscript.Id];
        System.assertEquals(1, listaChats.size());
        System.assertEquals('Servicio', listaChats[0].CC_Servicio_Chat__c);
        }
    }
    
    @isTest
    static void testBU() {  
        System.runAs(new User(Id = UserInfo.getUserId())) {

        Id recordApp = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Aplicaciones').getRecordTypeId();
        CC_FAQ__c app = new CC_FAQ__c();
        app.RecordTypeId = recordApp;
        app.CC_Id_App__c = '7';
        app.Name = 'LiniaObertaAppP';
        app.CC_Aplicacion_Siebel__c = 'WEB';
        app.CC_Origen__c = 'Web';
        app.CC_Nombre__c = 'LiniaObertaAppP';
        insert app;
        
        Id recordEsp = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
        CC_FAQ__c esp = new CC_FAQ__c();
        esp.RecordTypeId = recordEsp;
        esp.CC_Id_Espacio__c = '15000000';
        esp.Name = 'liniaObertaWSLOEP';
        esp.CC_Descripcion_es__c = 'Línea Abierta de LOE';
        esp.CC_Descripcion_ca__c = 'Línia Oberta de LOE';
        insert esp;
        
        Id espacio = [SELECT Id FROM CC_FAQ__c WHERE Name = 'liniaObertaWSLOEP'].Id;
        Id recordCat = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Categoria').getRecordTypeId();
        CC_FAQ__c cat = new CC_FAQ__c();
        cat.RecordTypeId = recordCat;
        cat.CC_Lookup_Espacio__c = espacio;
        cat.CC_Id_Categoria__c = '13830021';
        cat.Name = 'LineaAbiertaLOEP';
        cat.CC_Descripcion_es__c = 'Linea Abierta Prueba';
        cat.CC_Topic__c = 'LineaAbiertaLOEP';
        insert cat;
        
        List<LiveChatTranscript> oChats;
        
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;

        Account cuenta = new Account(Name='cuenta', RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente'));
        insert cuenta;
        
        Contact contacto = new Contact(LastName='contacto', RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente'), AccountId=cuenta.Id);
        insert contacto;
        
        Case caso = new Case(RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'HDT_Empleado'), AccountId=cuenta.Id, ContactId=contacto.Id,CC_Id_Cognitivo__c='test01');
        insert caso;        
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            CC_Bienvenida__c = false,
            CC_Nickname__c = 'Cliente 1',
            CC_Idioma__c = 'es',
            LiveChatVisitorId = liveChatVisitor.Id,
            CC_NumPerso__c = '10559714',
            CC_NumPerso2__c = '10559714',
            CC_Tipo__c = 'Agente',
            CC_Cognitive_chat__c='{"user": "U0137298", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Como_puedo_dar_de_alta_una_Servicuenta", "confidence": 0.8238105773925781 }, {"id": "Como_dar_de_alta_una_servicuenta_si_no_tengo_un_deposito_de_ahorro", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Operativa_de_Reintegros_Stop_go_", "confidence": 0.23751013278961183 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&iquest;C&oacute;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["es"], "errors": [] }',            
            CC_Id_Cognitive__c='test01',
            CC_Espacio__c = 'liniaObertaWSLOEP',
            CC_Categoria__c = 'LineaAbiertaLOEP',
            CC_Aplicacion__c = 'LiniaObertaAppP'
        );

        Test.startTest();
            insert liveChatTranscript;
            liveChatTranscript.AccountId = cuenta.Id;
            liveChatTranscript.ContactId = contacto.Id;
            liveChatTranscript.CaseId = caso.Id;
            update liveChatTranscript;
        Test.stopTest();
        /* TODO: no se está verificando el envío a Siebel, se supone que tiene su propia clase de test */
        
        /* Verificamos que cuando se informan cuenta, contacto y caso al chat del agente
      se informan también para el chat de cognitivo */
        Id chatCognitivoId = [SELECT CC_ChatOrigen__c FROM LiveChatTranscript WHERE Id=:liveChatTranscript.Id].CC_ChatOrigen__c;
        LiveChatTranscript chatCognitivo = [SELECT AccountId, ContactId, CaseId FROM LiveChatTranscript WHERE Id=:chatCognitivoId];
        System.assertEquals(chatCognitivo.AccountId, liveChatTranscript.AccountId);
        System.assertEquals(chatCognitivo.ContactId, liveChatTranscript.ContactId);
        System.assertEquals(chatCognitivo.CaseId, liveChatTranscript.CaseId);
        }
    }

    @isTest
    static void testEmployeeAgente() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        List<LiveChatTranscript> oChats;
        
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        
        Id rt = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByDeveloperName().get('HDT_Empleados').getRecordTypeId();
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            CC_Bienvenida__c = false,
            recordtypeId = rt,
            CC_Nickname__c = 'Cliente 1',
            CC_Idioma__c = 'es',
            LiveChatVisitorId = liveChatVisitor.Id,
            CC_CaseOrigin__c='Chat',
            CC_Tipo__c = 'Agente',
            CC_NumEmpleado__c = 'U0137298',
            CC_Cognitive_chat__c='{"user": "U0137298", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Como_puedo_dar_de_alta_una_Servicuenta", "confidence": 0.8238105773925781 }, {"id": "Como_dar_de_alta_una_servicuenta_si_no_tengo_un_deposito_de_ahorro", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Operativa_de_Reintegros_Stop_go_", "confidence": 0.23751013278961183 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&iquest;C&oacute;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["es"], "errors": [] }',
            CC_Id_Cognitive__c='test0',
            CC_Espacio__c = 'Espacio',
            CC_Servicio_Chat__c = 'Servicio',
            CC_Categoria__c = 'Categoria'
        );

        Test.startTest();
            insert liveChatTranscript;
        Test.stopTest();

        List<LiveChatTranscript> listaChats = [SELECT Id, CC_Servicio_Chat__c FROM LiveChatTranscript WHERE Id = :liveChatTranscript.Id];
        System.assertEquals(1, listaChats.size());
        System.assertEquals('Servicio', listaChats[0].CC_Servicio_Chat__c);
        }
    }

}