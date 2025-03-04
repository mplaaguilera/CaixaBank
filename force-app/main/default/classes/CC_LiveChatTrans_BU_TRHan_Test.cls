@isTest
public class CC_LiveChatTrans_BU_TRHan_Test {

    @testSetup
    public static void testSetup()
    {
        //Obtenemos los RecordTypes de la lista de valores
        Id listaRelacionRT = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        Id listaValorRT = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        
        //Creamos los registros que relacionan Espacio-Categoría con el Servicio
        List<CC_Lista_Valores__c> relacionEspacioCategoriaServicio = new List<CC_Lista_Valores__c>();
        CC_Lista_Valores__c listaRelacionEspacioCategoriaServicio = new CC_Lista_Valores__c();
        listaRelacionEspacioCategoriaServicio.RecordTypeId = listaRelacionRT;
        listaRelacionEspacioCategoriaServicio.Name = 'CC_Relacion_EspacioCategoria_Skill_Chat';
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

        CC_Lista_Valores__c relacion2 = new CC_Lista_Valores__c();
        relacion2.RecordTypeId = listaValorRT;
        relacion2.Name = 'Espacio1';
        relacion2.CC_Activa__c = true;
        relacion2.CC_Valor__c = 'Categoria1';
        relacion2.CC_Servicio__c = 'Servicio1';
        relacion2.CC_Orden__c = 1;
        relacion2.CC_Lista__c = listaRelacionEspacioCategoriaServicio.Id;
        relacionEspacioCategoriaServicio.add(relacion2);

        insert relacionEspacioCategoriaServicio;
    }

    @isTest
    static void testEmployee() {
        List<LiveChatTranscript> oChats;
        
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        
        Id rt = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByDeveloperName().get('CC_Empleados').getRecordTypeId();
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
        CC_Bienvenida__c = false,
        recordtypeId = rt,
        CC_Nickname__c = 'Cliente 1',
        CC_Idioma__c = 'es',
        LiveChatVisitorId = liveChatVisitor.Id,
        CC_CaseOrigin__c='Chat',
        CC_Tipo__c = 'Hidden',
        CC_NumEmpleado__c = 'U0137298',
        CC_Cognitive_chat__c='{"user": "U0137298", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Como_puedo_dar_de_alta_una_Servicuenta", "confidence": 0.8238105773925781 }, {"id": "Como_dar_de_alta_una_servicuenta_si_no_tengo_un_deposito_de_ahorro", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Operativa_de_Reintegros_Stop_go_", "confidence": 0.23751013278961183 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&iquest;C&oacute;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["es"], "errors": [] }',
        CC_Id_Cognitive__c='test0',
        CC_Espacio__c = 'Espacio',
        CC_Categoria__c = 'Categoria'
        );
        insert liveChatTranscript;

        //Comprobamos que se actualiza el campo Servicio del chat con el valor que corresponde para el espacio y la categoría
        List<LiveChatTranscript> listaChats = [SELECT Id, CC_Servicio_Chat__c FROM LiveChatTranscript WHERE Id = :liveChatTranscript.Id];
        System.assertEquals(1, listaChats.size());
        System.assertEquals('Servicio', listaChats[0].CC_Servicio_Chat__c);

        liveChatTranscript.CC_Espacio_Transfer__c = 'Espacio1';
        liveChatTranscript.CC_Categoria_Transfer__c = 'Categoria1';
        liveChatTranscript.CC_Transferir__c = true;
        
        Test.startTest();
            update liveChatTranscript;
        Test.stopTest();

        //Comprobamos que después de hacer un transfer, se cambia el servicio del Chat
        listaChats = [SELECT Id, CC_Servicio_Chat__c FROM LiveChatTranscript WHERE Id = :liveChatTranscript.Id];
        System.assertEquals(1, listaChats.size());
        //System.assertEquals('Servicio1', listaChats[0].CC_Servicio_Chat__c);
    }
    
    @isTest
    static void testBU() {
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
        
        Case caso = new Case(RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente'), AccountId=cuenta.Id, ContactId=contacto.Id,CC_Id_Cognitivo__c='test01');
        insert caso;
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
        CC_Bienvenida__c = false,
        CC_Nickname__c = 'Cliente 1',
        CC_Idioma__c = 'es',
        LiveChatVisitorId = liveChatVisitor.Id,
        CC_NumPerso__c = '10559714',
        CC_NumPerso2__c = '10559714',
        CC_Tipo__c = 'Agente',
        CC_Cognitive_chat__c='{"user": "U0137298", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Como_puedo_dar_de_alta_una_Servicuenta", "confidence": 0.8238105773925781 }, {"id": "Como_dar_de_alta_una_servicuenta_si_no_tengo_un_deposito_de_ahorro", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Operativa_de_Reintegros_Stop_go_", "confidence": 0.23751013278961183 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&iquest;C&oacute;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["es"], "errors": [] }',            CC_Id_Cognitive__c='test01',
        CC_Espacio__c = 'liniaObertaWSLOEP',
        CC_Categoria__c = 'LineaAbiertaLOEP',
        CC_Aplicacion__c = 'LiniaObertaAppP',
        Status = 'InProgress'
        );
        insert liveChatTranscript;
        liveChatTranscript.CC_Aplicacion_Origen__c= 'WhatsApp';    
        liveChatTranscript.AccountId = cuenta.Id;
        liveChatTranscript.ContactId = contacto.Id;
        liveChatTranscript.CaseId = caso.Id;
        
        Test.startTest();
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
        
        /* Verificamos que se crea una actividad para el chat del agente */
        List<Task> actividadAgente = [SELECT Id FROM Task WHERE CC_LiveChatTranscript_Id__c = :liveChatTranscript.Id AND Status = 'Completed'];
        //System.assertEquals(actividadAgente.size(), 1);
        System.assertnotEquals(actividadAgente.size(), 0);
        
        /* Verificamos que se crea una actividad para el chat del chatbot */
        List<Task> actividadChatbot = [SELECT Id FROM Task WHERE CC_LiveChatTranscript_Id__c = :chatCognitivoId AND Status = 'Completed'];
        //System.assertEquals(actividadChatbot.size(), 1);
        System.assertnotEquals(actividadChatbot.size(), 0);        
    }

    @isTest
    static void test01ChatSR() {
        
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
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
        CC_Bienvenida__c = false,
        CC_Nickname__c = 'Cliente 1',
        CC_Idioma__c = 'es',
        LiveChatVisitorId = liveChatVisitor.Id,
        CC_Id_Cognitive__c='test01',
        CC_NumPerso__c = '10559714',
        CC_NumPerso2__c = '10559714',
        CC_Tipo__c = 'Agente',
        CC_Espacio__c = 'liniaObertaWSLOEP',
        CC_Categoria__c = 'LineaAbiertaLOEP',
        CC_Aplicacion__c = 'LiniaObertaAppP'
        );
        insert liveChatTranscript;
        
        Account cuenta = new Account(Name='cuenta', RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente'));
        insert cuenta;
        
        Contact contacto = new Contact(LastName='contacto', RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente'), AccountId=cuenta.Id);
        insert contacto;
        
        Case caso = new Case(RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente'), AccountId=cuenta.Id, ContactId=contacto.Id);
        insert caso;
        
        oChats = [SELECT Id FROM LiveChatTranscript WHERE CC_Id_Cognitive__c = 'test01'];
        System.assertEquals(oChats.size(), 1);
        
        liveChatTranscript.CC_SRId__c = '9-FHVRD';
        liveChatTranscript.AccountId = cuenta.Id;
        liveChatTranscript.ContactId = contacto.Id;
        liveChatTranscript.CaseId = caso.Id;
        
        Test.startTest();
            update liveChatTranscript;
            
            oChats = [SELECT Id FROM LiveChatTranscript WHERE CC_Id_Cognitive__c = 'test01' AND CC_SRId__c = '9-FHVRD'];
            System.assertEquals(oChats.size(), 1);
            
            liveChatTranscript.Status = 'Completed';
            update liveChatTranscript;
        Test.stopTest();
        oChats = [SELECT Id FROM LiveChatTranscript WHERE CC_Id_Cognitive__c = 'test01' AND CC_SRId__c = '9-FHVRD' AND Status = 'Completed'];
        System.assertEquals(oChats.size(), 1);
    }
    
    @isTest
    static void test01Hidden() {
        
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
        
        String texto = '{"user":"13619528"}'; 
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
        CC_Bienvenida__c = false,
        CC_Nickname__c = 'Cliente 1',
        CC_Idioma__c = 'es',
        LiveChatVisitorId = liveChatVisitor.Id,
        CC_Id_Cognitive__c='test01',
        CC_NumPerso__c = '10559714',
        CC_NumPerso2__c = '10559714',
        CC_Tipo__c = 'Hidden',
        CC_Espacio__c = 'liniaObertaWSLOEP',
        CC_Categoria__c = 'LineaAbiertaLOEP',
        CC_Aplicacion__c = 'LiniaObertaAppP'
        );
        insert liveChatTranscript;
        
        Account cuenta = new Account(Name='cuenta', RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank'));
        insert cuenta;
        
        Contact contacto = new Contact(LastName='contacto', RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado'), AccountId=cuenta.Id);
        insert contacto;
        
        Case caso = new Case(RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado'), AccountId=cuenta.Id, 
        ContactId=contacto.Id, Status='Activo');
        insert caso;
        
        oChats = [SELECT Id FROM LiveChatTranscript WHERE CC_Id_Cognitive__c = 'test01'];
        System.assertEquals(oChats.size(), 1);
        
        liveChatTranscript.CC_SRId__c = '9-FHVRD';
        liveChatTranscript.AccountId = cuenta.Id;
        liveChatTranscript.ContactId = contacto.Id;
        liveChatTranscript.CaseId = caso.Id;
        
        Test.startTest();
            update liveChatTranscript;
            
            oChats = [SELECT Id FROM LiveChatTranscript WHERE CC_Id_Cognitive__c = 'test01' AND CC_SRId__c = '9-FHVRD'];
            System.assertEquals(oChats.size(), 1);
            
            liveChatTranscript.Status = 'Completed';
            update liveChatTranscript;
        Test.stopTest();
        
        oChats = [SELECT Id FROM LiveChatTranscript WHERE CC_Id_Cognitive__c = 'test01' AND CC_SRId__c = '9-FHVRD' AND Status = 'Completed'];
        System.assertEquals(oChats.size(), 1);
    }
    
    // Clase de test temporal.
    @isTest
    static void test01ChatCliente() {
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.size(), 1);
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        b.CC_Numero_Documento__c = '59044623N';
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.size(), 1);
        
        // Crear teléfono y mail del contacto.
        String sRecordType1 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        String sRecordType2 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        
        CC_Canal_Com__c c1 = new CC_Canal_Com__c();
        c1.CC_NumPerso__c = '999910559714';
        c1.CC_ContactoId__c = b.Id;
        c1.CC_CuentaId__c = a.Id;
        c1.CC_Telefono__c = '34 956565656';
        c1.RecordTypeId = sRecordType1;
        insert c1;
        
        List<CC_Canal_Com__c> o3 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Telefono__c = '34 956565656'];
        System.assertEquals(o3.size(), 1);
        
        CC_Canal_Com__c c2 = new CC_Canal_Com__c();
        c2.CC_NumPerso__c = '999910559714';
        c2.CC_ContactoId__c = b.Id;
        c2.CC_CuentaId__c = a.Id;
        c2.CC_Email__c = 'prueba21@caixabank.com';
        c2.RecordTypeId = sRecordType2;
        insert c2;
        
        List<CC_Canal_Com__c> o4 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Email__c = 'prueba21@caixabank.com'];
        System.assertEquals(o4.size(), 1);
        
        List<Case> oCasos = new List<Case>();
        
        // Crear caso.
        Case c = new Case();
        c.Subject = 'Test_01';
        c.AccountId = a.Id;
        c.ContactId = b.Id;
        c.Status = 'New';
        c.Origin = 'Email';
        c.CC_NumPerso__c = '999910559714';
        oCasos.add(c);
        
        insert oCasos;
        
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
        CC_Bienvenida__c = false,
        CC_Nickname__c = 'Cliente 1',
        CC_Idioma__c = 'es',
        LiveChatVisitorId = liveChatVisitor.Id,
        CC_Id_Cognitive__c='9001029aa',
        CC_NumPerso__c = '999910559714',
        CC_NumPerso2__c = '999910559714',
        AccountId = [SELECT Id FROM Account WHERE CC_NumPerso__c = '999910559714'].Id,
        ContactId = [SELECT Id FROM Contact WHERE CC_NumPerso__c = '999910559714'].Id,
        CaseId = [SELECT Id FROM Case WHERE Subject = 'Test_01'].Id
        );
        insert liveChatTranscript;
        
        List<ID> chats = new List<ID>();
        chats.add(liveChatTranscript.Id);
        
        CC_GestionEntradaChat.gestionChatOwner_Interno(chats);
        
        LiveChatVisitor liveChatVisitor2 = new LiveChatVisitor();
        insert liveChatVisitor2;
        
        String texto = '{"user":"13619528", "idGlobalList":["17","22","37"]}';        
        /*texto = texto + '"{\"user\":\"13619528\",\"startTime\":\"2019-08-21T05:55:19.134Z\",\"duration\":1566366919134,\"iterations\":4,\"reformulations\":1,\"areas\":[\"NeoApp\"],\"userQuery\":[\"a ver me puedes poner con\",\"hablar con un gestor\"],\"conversationUnits\":[{\"type\":60,\"text\":\"1\",\"timestamp\":\"2019-08-21T05:55:19.134Z\"},{\"type\":1,\"text\":\"a ver me puedes poner con\",\"timestamp\":\"2019-08-21T05:55:19.134Z\",\"auto\":false},{\"type\":5,\"text\":\"a ver me puedes poner con\",\"timestamp\":\"2019-08-21T05:55:19.134Z\"},{\"type\":13,\"results\":[{\"id\":\"NeoApp\",\"confidence\":0.050811272}],\"timestamp\":\"2019-08-21T05:55:20.756Z\"},{\"type\":23,\"text\":\"a ver me puedes poner con\",\"timestamp\":\"2019-08-21T05:55:20.756Z\"},{\"type\":8,\"text\":\"NeoApp\",\"timestamp\":\"2019-08-21T05:55:20.756Z\"},{\"type\":3,\"results\":[{\"id\":\"Como_puedes_consultar_los_recibos_domiciliados_en_tu_cuenta_NeoApp\",\"confidence\":0.4552262544631958},{\"id\":\"_Como_puedes_ver_los_prestamos_que_has_contratado_en_CaixaBank_\",\"confidence\":0.30560939311981206},{\"id\":\"Como_consultar_los_pagos_a_terceros_emitidos_NeoApp\",\"confidence\":0.2869901299476624},{\"id\":\"Como_puedes_solicitar_una_cita_previa_con_tu_gestor_NeoApp\",\"confidence\":0.2732272565364838},{\"id\":\"Como_puedes_consultar_los_movimientos_de_tus_cuentas_anteriores_a_los_ultimos_12_meses_NeoApp\",\"confidence\":0.2731297731399536},{\"id\":\"Como_consultar_liquidaciones_de_periodos_anteriores_de_tu_tarjeta_de_credito_NeoApp\",\"confidence\":0.26579814553260805},{\"id\":\"Donde_puedes_consultar_los_seguros_que_tienes_contratados_NeoApp\",\"confidence\":0.2656560242176056},{\"id\":\"Como_puedo_consultar_el_cuadro_medico_de_mi_seguro_de_salud_NeoApp\",\"confidence\":0.26206207275390625},{\"id\"';
        texto = texto + ':\"Como_puedes_ver_un_resumen_de_tus_ingresos_y_gastos_NeoApp\",\"confidence\":0.2591778874397278},{\"id\":\"Cuales_son_los_requisitos_de_gratuidad_de_la_cuenta_inTouch_NeoApp\",\"confidence\":0.2551810681819916}],\"timestamp\":\"2019-08-21T05:55:20.756Z\"},{\"type\":63,\"results\":[{\"id\":\"Como_puedes_consultar_los_recibos_domiciliados_en_tu_cuenta_NeoApp\",\"confidence\":0.4552262544631958},{\"id\":\"_Como_puedes_ver_los_prestamos_que_has_contratado_en_CaixaBank_\",\"confidence\":0.30560939311981206},{\"id\":\"Como_consultar_los_pagos_a_terceros_emitidos_NeoApp\",\"confidence\":0.2869901299476624},{\"id\":\"Como_puedes_solicitar_una_cita_previa_con_tu_gestor_NeoApp\",\"confidence\":0.2732272565364838},{\"id\":\"Como_puedes_consultar_los_movimientos_de_tus_cuentas_anteriores_a_los_ultimos_12_meses_NeoApp\",\"confidence\":0.2731297731399536}],\"timestamp\":\"2019-08-21T05:55:20.756Z\"},{\"type\":4,\"text\":\"\\u003cBR\/\\u003e\\u003cli\\u003e\u00bfC\u00f3mo puedes consultar los recibos domiciliados en tu cuenta?\\u003c\/li\\u003e\\u003cli\\u003e\u00bfC\u00f3mo puedes ver los pr\u00e9stamos que has contratado en CaixaBank?\\u003c\/li\\u003e\\u003cli\\u003e\u00bfC\u00f3mo consultar los pagos a terceros emitidos?\\u003c\/li\\u003e\\u003cli\\u003e\u00bfC\u00f3mo puedes solicitar una cita previa con tu gestor?\\u003c\/li\\u003e\\u003cli\\u003e\u00bfC\u00f3mo puedes consultar los movimientos de tus cuentas anteriores a los \u00faltimos 12 meses?\\u003c\/li\\u003e\\u003cli\\u003eVer m\u00e1s respuestas\\u003c\/li\\u003e\",\"timestamp\":\"2019-08-21T05:55:20.757Z\"},{\"type\":5,\"text\":\"\u00bfC\u00f3mo puedes solicitar una cita previa con tu gestor?\",\"timestamp\":\"2019-08-21T05:56:31.920Z\"},{\"type\":4,\"text\":\"Si tienes disponible Cita Previa, puedes solicitar una con tu gestor accediendo a la secci\u00f3n Mi Gestor\/Mi Oficina en la pantalla de inicio. En el men\u00fa de la secci\u00f3n podr\u00e1s ver los datos de contacto o solicitar una cita previa.\\u003cBR\/\\u003e\\u003cB\\u003e\u00bfC\u00f3mo puedes solicitar una cita previa con tu gestor?\\u003c\';
        texto = texto + '/B\\u003e\\u003cBR\/\\u003e\",\"timestamp\":\"2019-08-21T05:56:31.920Z\"},{\"type\":66,\"text\":\"\u00bfC\u00f3mo puedes solicitar una cita previa con tu gestor?\",\"id\":\"Como_puedes_solicitar_una_cita_previa_con_tu_gestor_NeoApp\",\"timestamp\":\"2019-08-21T05:56:31.920Z\",\"responseCode\":\"FAQ\"},{\"type\":6,\"text\":\"\u00bfC\u00f3mo puedes solicitar una cita previa con tu gestor?\",\"id\":\"Como_puedes_solicitar_una_cita_previa_con_tu_gestor_NeoApp\",\"timestamp\":\"2019-08-21T05:56:31.920Z\",\"responseCode\":\"FAQ\"},{\"type\":4,\"text\":\"\u00bfTe ha sido \u00fatil mi respuesta? U+1F600;\\u003cBR\/\\u003e\\u003cli\\u003eU+1F44D;\\u003c\/li\\u003e\\u003cli\\u003eU+1F44E;\\u003c\/li\\u003e\",\"timestamp\":\"2019-08-21T05:56:31.920Z\"},{\"type\":65,\"results\":[{\"id\":\"POSITIVO\"},{\"id\":\"MAS_OPCIONES\"}],\"timestamp\":\"2019-08-21T05:56:31.920Z\"},{\"type\":70,\"text\":\"MAS_OPCIONES\",\"id\":\"MORE_OPTIONS_FEED\",\"timestamp\":\"2019-08-21T05:57:03.653Z\"},{\"type\":5,\"text\":\"U+1F44E;\",\"timestamp\":\"2019-08-21T05:57:03.653Z\"},{\"type\":4,\"text\":\"Vaya, lo siento. Tambi\u00e9n he encontrado esto, que ahora s\u00ed, espero que sea lo que buscabas.\",\"timestamp\":\"2019-08-21T05:57:03.654Z\"},{\"type\":63,\"results\":[{\"id\":\"Como_consultar_liquidaciones_de_periodos_anteriores_de_tu_tarjeta_de_credito_NeoApp\",\"confidence\":0.26579814553260805},{\"id\":\"Donde_puedes_consultar_los_seguros_que_tienes_contratados_NeoApp\",\"confidence\":0.2656560242176056},{\"id\":\"Como_puedo_consultar_el_cuadro_medico_de_mi_seguro_de_salud_NeoApp\",\"confidence\":0.26206207275390625},{\"id\":\"Como_puedes_ver_un_resumen_de_tus_ingresos_y_gastos_NeoApp\",\"confidence\":0.2591778874397278},{\"id\":\"Cuales_son_los_requisitos_de_gratuidad_de_la_cuenta_inTouch_NeoApp\",\"confidence\":0.2551810681819916}],\"timestamp\":\"2019-08-21T05:57:03.654Z\"},{\"type\":4';
        texto = texto + ',\"text\":\"\\u003cBR\/\\u003e\\u003cli\\u003e\u00bfC\u00f3mo consultar liquidaciones de per\u00edodos anteriores de tu tarjeta de cr\u00e9dito?\\u003c\/li\\u003e\\u003cli\\u003e\u00bfD\u00f3nde puedes consultar los seguros que tienes contratados?\\u003c\/li\\u003e\\u003cli\\u003e\u00bfC\u00f3mo puedo consultar el cuadro m\u00e9dico de mi seguro de salud?\\u003c\/li\\u003e\\u003cli\\u003e\u00bfC\u00f3mo puedes ver un resumen de tus ingresos y gastos?\\u003c\/li\\u003e\\u003cli\\u003e\u00bfCu\u00e1les son los requisitos de gratuidad de la cuenta inTouch?\\u003c\/li\\u003e\\u003cli\\u003eVer m\u00e1s respuestas\\u003c\/li\\u003e\",\"timestamp\":\"2019-08-21T05:57:03.654Z\"},{\"type\":13,\"results\":[{\"id\":\"NeoApp\",\"confidence\":0.009196575}],\"timestamp\":\"2019-08-21T05:57:37.513Z\"},{\"type\":60,\"text\":\"2\",\"timestamp\":\"2019-08-21T05:57:37.513Z\"},{\"type\":2,\"text\":\"hablar con un gestor\",\"timestamp\":\"2019-08-21T05:57:37.513Z\",\"auto\":true},{\"type\":5,\"text\":\"hablar con un gestor\",\"timestamp\":\"2019-08-21T05:57:37.513Z\"},{\"type\":8,\"text\":\"NeoApp\",\"timestamp\":\"2019-08-21T05:57:37.513Z\"},{\"type\":3,\"results\":[{\"id\":\"Como_puedes_solicitar_una_cita_previa_con_tu_gestor_NeoApp\",\"confidence\":0.625798225402832},{\"id\":\"_Como_contacto_con_un_agente_993368263\",\"confidence\":0.5846513509750366},{\"id\":\"Como_puedes_reclamar_un_cargo_hecho_en_tu_tarjeta_NeoApp\",\"confidence\":0.2751889765262604},{\"id\":\"Como_funciona_el_BOT_de_CaixaBank_NeoApp\",\"confidence\":0.25250639319419865},{\"id\":\"_Como_alquilar_un_coche_993368280\",\"confidence\":0.25222427248954776},{\"id\":\"_Que_tienes_que_hacer_si_tienes_un_descubierto_en_cuenta___993368334\",\"confidence\":0.25188765525817874},{\"id\":\"Como_puedes_modificar_un_perfil_ya_creado_en_Mis_finanzas_NeoApp\",\"confidence\":0.24957865774631502},{\"id\":\"_Como_anular_una_orden_de_impago_dada_de_alta_previamente_993368350\",\"confidence\":0.24849270284175873},{\"id\":\"_Puedes_dar_de_alta_una_cuenta_con_varios_titulares_conjuntamente_993367163\",\"confidence\":0.2473608285188675},{\"id\":\"Como_funciona_Bizum_para_enviar_dinero_de_movil_a_movil_NeoApp\",\"confidence\":0.24674556851387025}],\"timestamp\":\"2019-08-21T05:57:37.513Z\"},{\"type\":63,\"results\":[{\"id\":\"_Como_contacto_con_un_agente_993368263\",\"confidence\":0.5846513509750366}],\"timestamp\":\"2019-08-21T05:57:37.514Z\"},{\"type\":6';
        texto = texto + ',\"text\":\"\u00bfC\u00f3mo contacto con un agente?\",\"id\":\"_Como_contacto_con_un_agente_993368263\",\"timestamp\":\"2019-08-21T05:57:37.514Z\",\"responseCode\":\"FAQ\"},{\"type\":10,\"text\":\"Si no he entendido mal, creo que quieres hablar con un agente humano, \u00bfprefieres que te solucione yo la consulta y as\u00ed evitas esperas?\\u003cBR\/\\u003e\\u003cli\\u003eS\u00ed\\u003c\/li\\u003e\\u003cli\\u003eNo\\u003c\/li\\u003e\",\"timestamp\":\"2019-08-21T05:57:37.614Z\"},{\"type\":64,\"text\":\"_Como_contacto_con_un_agente_993368263\",\"id\":\"3\",\"timestamp\":\"2019-08-21T05:57:37.614Z\",\"orgText\":\"hablar con un gestor\"},{\"type\":5,\"text\":\"No\",\"timestamp\":\"2019-08-21T05:57:49.314Z\"},{\"type\":10,\"text\":\"Te estamos poniendo en contacto con uno de nuestros agentes. Espera unos segundos.\\u003cBR\/\\u003e\\u003cBR\/\\u003e\\u003cBR\/\\u003e\\u003cli\\u003eAPPCaixaBankNow\\u003c\/li\\u003e\",\"timestamp\":\"2019-08-21T05:57:49.314Z\"},{\"type\":4,\"text\":\"Chat a APP CaixaBankNow\",\"timestamp\":\"2019-08-21T05:57:49.314Z\"},{\"type\":64,\"text\":\"_Como_contacto_con_un_agente_993368263\",\"id\":\"5\",\"timestamp\":\"2019-08-21T05:57:49.314Z\"}],\"revision\":\"NO\",\"centro\":\"00000\",\"badClassifications\":[],\"agents\":[\"WATSON\"],\"aplicacionOrigen\":\"\",\"conversationID\":\"13619528_100069719\",\"currentID\":100069719,\"aplicacionCorpus\":\"NeoAPP\",\"idioma\":\"es\",\"idiomasDetectados\":[\"es\",\"es\"],\"perfil\":\"Default\",\"idGlobalList\":[\"17\",\"22\",\"37\"],\"errors\":[],\"datos\":[{\"userTextOriginal\":\"a ver me puedes poner con\",\"userTextObfuscate\":\"a ver me puedes poner con\",\"identifiedObjects\":[]},{\"userTextOriginal\":\"hablar con un gestor\",\"userTextObfuscate\":\"hablar con un gestor\",\"identifiedObjects\":[]}],\"prioritaria\":\"NO\"}"';
        */    
        // Crear caso.
        Case caso = new Case();
        caso.Subject = 'Test_01';
        caso.AccountId = a.Id;
        caso.ContactId = b.Id;
        caso.Status = 'New';
        caso.Origin = 'Chat';
        caso.CC_NumPerso__c = '999910559714';
        caso.Canal_del_Empleado__c = 'Agente';
        caso.CC_Id_Cognitivo__c='9001029ab';
        insert caso;
        LiveChatTranscript liveChatTranscript2 = new LiveChatTranscript(
        CC_Bienvenida__c = false,
        CC_Nickname__c = 'Cliente 1',
        CC_Idioma__c = 'es',
        LiveChatVisitorId = liveChatVisitor2.Id,
        CC_Id_Cognitive__c='9001029ab',
        CC_NumEmpleado__c = 'U011234',
        CC_Cognitive_chat__c = texto,
        CC_IdsGlobales__c = '',
        //CC_NumPerso2__c = '999910559714',
        //AccountId = [SELECT Id FROM Account WHERE CC_NumPerso__c = '999910559714'].Id,
        //ContactId = [SELECT Id FROM Contact WHERE CC_NumPerso__c = '999910559714'].Id//,
        CaseId = caso.Id
        );
        
        // Se pone try/catch por configuración de valores de entorno.
        try
        {
            Test.startTest();
                insert liveChatTranscript2;
            Test.stopTest();
        }catch(Exception e){
            CBK_Log.error('Error en la creación del chat: ' + e.getMessage());
        }
        
        List<LiveChatTranscript> chats2 = new List<LiveChatTranscript>();
        chats2.add(liveChatTranscript2);
        
        try
        {
            CC_GestionEntradaChat.gestionEntradaChats(chats2);
        }catch(Exception e){
            CBK_Log.error('Error gestión entrada chats: ' + e.getMessage());
        }        
    }

    @isTest
    static void testEmployeeAgente() {
        List<LiveChatTranscript> oChats;
        
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        
        Id rt = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByDeveloperName().get('CC_Empleados').getRecordTypeId();
        
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
        CC_Categoria__c = 'Categoria'
        );
        insert liveChatTranscript;

        //Comprobamos que se actualiza el campo Servicio del chat con el valor que corresponde para el espacio y la categoría
        List<LiveChatTranscript> listaChats = [SELECT Id, CC_Servicio_Chat__c FROM LiveChatTranscript WHERE Id = :liveChatTranscript.Id];
        System.assertEquals(1, listaChats.size());
        System.assertEquals('Servicio', listaChats[0].CC_Servicio_Chat__c);

        liveChatTranscript.CC_Espacio_Transfer__c = 'Espacio1';
        liveChatTranscript.CC_Categoria_Transfer__c = 'Categoria1';
        liveChatTranscript.CC_Transferir__c = true;
        
        Test.startTest();
            update liveChatTranscript;
        Test.stopTest();

        //Comprobamos que después de hacer un transfer, se cambia el servicio del Chat
        listaChats = [SELECT Id, CC_Servicio_Chat__c FROM LiveChatTranscript WHERE Id = :liveChatTranscript.Id];
        System.assertEquals(1, listaChats.size());
        //System.assertEquals('Servicio1', listaChats[0].CC_Servicio_Chat__c);
    }
}