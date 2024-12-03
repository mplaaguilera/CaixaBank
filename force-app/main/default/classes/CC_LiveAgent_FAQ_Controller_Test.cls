@istest
public class CC_LiveAgent_FAQ_Controller_Test {
    
    @TestSetup
    static void makeData() {
        Test.startTest();
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';        
        insert cuenta;

        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';      	
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        insert contacto;
        
        List<Case> listaCasos = new List<Case>();
        Case caso = new Case();
        caso.ContactId = contacto.Id;
        caso.CC_Idioma__c ='es';
        caso.Status = 'Cerrado';
        caso.CC_Canal_Contacto__c = 'Chat';
        caso.Origin = 'Chat';
        caso.CC_Canal_Procedencia__c = 'Web';
        caso.Reason = 'Helpdesk';
        listaCasos.add(caso);
        
        Case casoCatalan = new Case();
        casoCatalan.ContactId = contacto.Id;
        casoCatalan.CC_Idioma__c ='ca';
        casoCatalan.Status = 'Cerrado';
        casoCatalan.CC_Canal_Contacto__c = 'Chat';
        casoCatalan.Origin = 'Chat';
        casoCatalan.CC_Canal_Procedencia__c = 'Web';
        casoCatalan.Reason = 'Helpdesk';
        listaCasos.add(casoCatalan);
        
        Case casoIngles = new Case();
        casoIngles.ContactId = contacto.Id;
        casoIngles.CC_Idioma__c ='en';
        casoIngles.Status = 'Cerrado';
        casoIngles.CC_Canal_Contacto__c = 'Chat';
        casoIngles.Origin = 'Chat';
        casoIngles.CC_Canal_Procedencia__c = 'Web';
        casoIngles.Reason = 'Helpdesk';
        listaCasos.add(casoIngles);
        insert listaCasos;
        
        List<LiveChatVisitor> listaLiveChatVisitor = new List<LiveChatVisitor>();
        LiveChatVisitor chatVisitor = new LiveChatVisitor();
        listaLiveChatVisitor.add(chatVisitor);
        
        LiveChatVisitor chatVisitorCatalan = new LiveChatVisitor();
        listaLiveChatVisitor.add(chatVisitorCatalan);
        
        LiveChatVisitor chatVisitorIngles = new LiveChatVisitor();
        listaLiveChatVisitor.add(chatVisitorIngles);
        insert listaLiveChatVisitor;
        
        Id recordTypeIdAplicacion = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_FAQ__c', 'CC_Aplicaciones');
        List <CC_FAQ__c> apps = new List <CC_FAQ__c> ();
        CC_FAQ__c app = new CC_FAQ__c();
        app.CC_Id_App__c = '2';
        app.CC_Aplicacion_Siebel__c='WEB';
        app.CC_Nombre__c = 'LiniaObertaApp';
        app.CC_Origen__c = 'Web';
        app.Name = 'LiniaObertaApp';
        app.CC_FAQ_Id__c = '2';
        app.CC_FAQ_Ident__c = '2';
        app.CC_IdiomaMsj__c = 'es';
        app.CC_Version__c = 4;
        app.CC_VersionActualizando__c = 4;
        app.CC_IdiomaESDefault__c = '47';
        app.RecordTypeId = recordTypeIdAplicacion;
        apps.add(app);
        
        CC_FAQ__c app1 = new CC_FAQ__c();
        app1.CC_Id_App__c = '3';
        app1.CC_Aplicacion_Siebel__c='WEB';
        app1.CC_Nombre__c = 'CC_OFICINAS';
        app1.CC_Origen__c = 'Web';
        app1.Name = 'CC_OFICINAS';
        app1.CC_FAQ_Id__c = '3';
        app1.CC_FAQ_Ident__c = '3';
        app1.CC_IdiomaMsj__c = 'es';
        app1.CC_Version__c = 4;
        app1.CC_VersionActualizando__c = 4;
        app1.RecordTypeId = recordTypeIdAplicacion;
        apps.add(app1);
        
        CC_FAQ__c app2 = new CC_FAQ__c();
        app2.CC_Id_App__c = '4';
        app2.CC_Aplicacion_Siebel__c='OFICINA';
        app2.CC_Nombre__c = 'CC_OFICINAS1';
        app2.CC_Origen__c = 'Web';
        app2.Name = 'CC_OFICINAS1';
        app2.CC_IdiomaESDefault__c = '46';
        app2.CC_FAQ_Id__c = '4';
        app2.CC_FAQ_Ident__c = '4';
        app2.CC_IdiomaMsj__c = 'es';
        app2.CC_Version__c = 4;
        app2.CC_VersionActualizando__c = 4;
        app2.CC_TextoMostrar__c = 'Texto a Mostrar';
        app2.RecordTypeId = recordTypeIdAplicacion;
        apps.add(app2);
        insert apps;
        
        Id recordTypeIdEspacio = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_FAQ__c', 'CC_Espacios');
        
        CC_FAQ__c espacio = new CC_FAQ__c();
        espacio.CC_Lookup_App__c = app.Id;
        espacio.Name = 'liniaObertaWSLOE';
        espacio.CC_Nombre__c = 'liniaObertaWSLOE';
        espacio.CC_Id_Espacio__c='15000000';
        espacio.CC_FAQ_Id__c = '15000000';
        espacio.CC_FAQ_Ident__c = '15000000';
        espacio.CC_Id_App__c = '2';
        espacio.CC_Descripcion_ca__c ='Línia Oberta de LOE';
        espacio.CC_Descripcion_es__c ='Línea Abierta de LOE';
        espacio.CC_TextoMostrar__c ='Texto';
        espacio.CC_ListaIDsGlobales__c = '2,17,32';
        espacio.CC_Version__c = 3;
        espacio.CC_VersionActualizando__c = 3;
        espacio.RecordTypeId = recordTypeIdEspacio;
        insert espacio;
        
        CC_FAQ__c espacio1 = new CC_FAQ__c();
        espacio1.CC_Lookup_App__c = app.Id;
        espacio1.Name = 'liniaObertaWSLOE1';
        espacio1.CC_Nombre__c = 'liniaObertaWSLOE1';
        espacio1.CC_Categoria__c = 'Hogar';
        espacio1.CC_Id_espacio__c='150000001';
        espacio1.CC_FAQ_Id__c = '150000001';
        espacio1.CC_FAQ_Ident__c = '150000001';
        espacio1.CC_Id_App__c = '21';
        espacio1.CC_Descripcion_ca__c ='Línia Oberta de LOE';
        espacio1.CC_Descripcion_es__c ='Línea Abierta de LOE';
        espacio1.CC_ListaIDsGlobales__c = '2,17,32,46';
        espacio1.CC_Version__c = 3;
        espacio1.CC_VersionActualizando__c = 3;
        espacio1.RecordTypeId = recordTypeIdEspacio;
        espacio1.CC_TextoMostrar__c = 'Texto a Mostrar 1, Texto a Mostrar 1 Texto a Mostrar 1, Texto a Mostrar 1 Texto a Mostrar 1, Texto a Mostrar 1 Texto a Mostrar 1, Texto a Mostrar 1';
        insert espacio1;
        
        Id recordTypeIdCategoria = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_FAQ__c', 'CC_Categoria');
        
        CC_FAQ__c cat = new CC_FAQ__c();
        cat.CC_FAQ_Id__c = '15000000_13830021';
        cat.CC_FAQ_Ident__c = '13830021';
        cat.CC_Id_App__c = '2';
        cat.CC_Id_Categoria__c= '13830021';
        cat.CC_Lookup_App__c = app.Id;
        cat.CC_Lookup_Espacio__c = espacio.Id;
        cat.CC_Nombre__c = 'LineaAbiertaLOE';
        cat.Name = 'LineaAbiertaLOE';
        cat.CC_Id_Espacio__c=  '15000000';
        cat.CC_Descripcion_ca__c ='CaixaBankNow';
        cat.CC_Descripcion_es__c ='CaixaBankNow';
        cat.CC_Topic__c = 'LineaAbiertaLOE';
        cat.CC_Version__c = 3;
        cat.CC_VersionActualizando__c = 3;
        cat.RecordTypeId = recordTypeIdCategoria;
        insert cat;
        
        Id recordTypeIdFaq = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_FAQ__c', 'CC_FAQ');
        CC_FAQ__c faq1 = new CC_FAQ__c();
        faq1.CC_Lookup_Espacio__c = espacio.Id;
        faq1.CC_Lookup_Categoria__c = cat.Id;
        faq1.CC_Espacio__c='liniaObertaWSLOE';
        faq1.CC_Categoria__c='LineaAbiertaLOE';
        faq1.CC_FAQ_Id__c = '15000000_13830021_1';
        faq1.CC_FAQ_Ident__c = '1';
        faq1.CC_Lookup_App__c = app.Id;
        faq1.CC_Pregunta_CAT__c ='Quines transferencies modalitats de Rebut Únic hi ha?';
        faq1.CC_Pregunta_ESP__c ='¿Qué transferencia modalidades de Recibo único hay?';
        faq1.CC_Version__c = 3;
        faq1.RecordTypeId = recordTypeIdFaq; 
        insert faq1;
        
        Id recordTypeIdFaqCustom = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_FAQ__c', 'CC_FAQ_Custom');
        CC_FAQ__c faqCustom = new CC_FAQ__c();
        faqCustom.CC_Lookup_Espacio__c = espacio.Id;
        faqCustom.CC_Lookup_FAQ__c = faq1.Id;
        faqCustom.CC_Lookup_Categoria__c = cat.Id;
        faqCustom.CC_GlobalId__c = '47';
        faqCustom.CC_Espacio__c='liniaObertaWSLOE';
        faqCustom.CC_Categoria__c='LineaAbiertaLOE';
        faqCustom.CC_Pregunta_CAT__c ='Quines transferencies modalitats de Rebut Únic hi ha?';
        faqCustom.CC_Pregunta_ESP__c ='¿Qué transferencia modalidades de Recibo único hay?';   	
        faqCustom.CC_Nombre__c='¿Qué modalidades de Recibo único hay? 1';
        faqCustom.CC_Version__c = 3;
        faqCustom.CC_TextoMostrar__c = 'Puedes hacer una eurotransferencia desde Cuentas > Internacional > Transferencias > Eurotransferencias básicas en euros.';
        faqCustom.RecordTypeId = recordTypeIdFaqCustom; 
        insert faqCustom;
        
        
        Id recordTypeIdIntent = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Intent__c', 'CC_Intent');
        
        CC_Intent__c intent1 = new CC_Intent__c();
        intent1.CC_Descripcion__c = 'Que_gastos_tiene_una_transferencia_internacional';
        intent1.CC_FAQ_Id__c = faq1.Id;
        intent1.CC_Intent_Id__c = 1;
        intent1.CC_IntentIdExt__c = '15000000_13830021_1_1';
        intent1.CC_Nombre__c = 'Que_gastos_tiene_una_transferencia_internacional';
        intent1.CC_Version__c = 3;    
        intent1.Name = 'Que_gastos_tiene_una_transferencia_internacional';
        intent1.RecordTypeId = recordTypeIdIntent;
        insert intent1;
        
        List<CC_Intent__c> intentlst = new List<CC_Intent__c>();
        CC_Intent__c intent0 = new CC_Intent__c();
        intent0.CC_Descripcion__c = 'Que_gastos_tiene_una_transferencia_internacional';
        intent0.CC_FAQ_Id__c = faq1.Id;
        intent0.CC_Intent_Id__c = 1;
        intent0.CC_Nombre__c = 'Que_gastos_tiene_una_transferencia_internacional';
        intent0.CC_Respuesta_CAT__c = 'Com a emissor una transferència internacional pots seleccionar com han de repartir-se les despeses derivades de loperació. Hi ha tres modalitats: SHARE (SHA): Comparteix les despeses entre emissor i destinatari, OUR: Les despeses són íntegrament a càrrec de lemissor i BEN: Les despeses són a càrrec del destinatari. Tingues en compte que en la confirmació de operació, abans de signar-la, podràs consultar el cost aplicat al servei.';
        intent0.CC_Respuesta_ESP__c = 'Como emisor de una transferencia internacional puedes seleccionar como deben repartirse los gastos derivados de la operación. Existen tres modalidades: SHARE (SHA): Comparte los gastos entre emisor y destinatario, OUR: Los gastos corren íntegramente a cargo del emisor y BEN: Los cargos corren a cargo del destinatario. Ten en cuenta que en la confirmación de la operación, antes de firmarla, podrás consultar el coste aplicado al servicio.';
        intent0.Name = 'Que_gastos_tiene_una_transferencia_internacional';
        intentlst.add(intent0);

        Id recordTypeIdIntentCustom = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Intent__c', 'CC_Intent_Custom');
        
        CC_Intent__c intentCustom = new CC_Intent__c();
        intentCustom.CC_Descripcion__c = 'Que_gastos_tiene_una_transferencia_internacional';
        intentCustom.CC_FAQ_Id__c = faq1.Id;
        intentCustom.CC_GlobalId__c = '47';
        intentCustom.CC_Intent_Id__c = 1;
        intentCustom.CC_Intent_Padre__c = intent1.Id;
        intentCustom.CC_IntentIdExt__c = '15000000_13830021_1_1';
        intentCustom.CC_Nombre__c = 'Que_gastos_tiene_una_transferencia_internacional';
        intentCustom.CC_TextoMostrar__c = 'Puedes hacer una eurotransferencia desde Cuentas > Internacional > Transferencias > Eurotransferencias básicas en euros.';
        intentCustom.CC_Version__c = 3;    
        intentCustom.Name = 'Que_gastos_tiene_una_transferencia_internacional';
        intentCustom.RecordTypeId = recordTypeIdIntentCustom;
        intentlst.add(intentCustom);
        
        CC_Intent__c intent2 = new CC_Intent__c();
        intent2.CC_Descripcion__c = 'Que_gastos_tiene_una_transferencia_internacional';
        intent2.CC_FAQ_Id__c = faq1.Id;
        intent2.CC_Intent_Id__c = 1;
        intent2.CC_IntentIdExt__c = '15000000_13830021_1_3';
        intent2.CC_Nombre__c = 'Que_gastos_tiene_una_transferencia_internacional';
        intent2.CC_Respuesta_CAT__c = 'Com a emissor una transferència internacional pots seleccionar com han de repartir-se les despeses derivades de loperació. Hi ha tres modalitats: SHARE (SHA): Comparteix les despeses entre emissor i destinatari, OUR: Les despeses són íntegrament a càrrec de lemissor i BEN: Les despeses són a càrrec del destinatari. Tingues en compte que en la confirmació de operació, abans de signar-la, podràs consultar el cost aplicat al servei.';
        intent2.CC_Respuesta_ESP__c = 'Como emisor de una transferencia internacional puedes seleccionar como deben repartirse los gastos derivados de la operación. Existen tres modalidades: SHARE (SHA): Comparte los gastos entre emisor y destinatario, OUR: Los gastos corren íntegramente a cargo del emisor y BEN: Los cargos corren a cargo del destinatario. Ten en cuenta que en la confirmación de la operación, antes de firmarla, podrás consultar el coste aplicado al servicio.';
        intent2.Name = 'Que_gastos_tiene_una_transferencia_internacional';
        intentlst.add(intent2);
        
        CC_Intent__c intentCustom1 = new CC_Intent__c();
        intentCustom1.CC_Descripcion__c = 'Que_gastos_tiene_una_transferencia_internacional';
        intentCustom1.CC_FAQ_Id__c = faq1.Id;
        intentCustom1.CC_GlobalId__c = '46';
        intentCustom1.CC_Intent_Id__c = 1;
        intentCustom1.CC_Intent_Padre__c = intent1.Id;
        intentCustom1.CC_IntentIdExt__c = '15000000_13830021_1_1_47';
        intentCustom1.CC_IntentIdExt__c = '15000000_13830021_1_1';
        intentCustom1.CC_Nombre__c = 'Que_gastos_tiene_una_transferencia_internacional';
        intentCustom1.CC_TextoMostrar__c = 'Puedes hacer una eurotransferencia desde Cuentas > Internacional > Transferencias > Eurotransferencias básicas en euros.';
        intentCustom1.CC_Version__c = 3;    
        intentCustom1.Name = 'Que_gastos_tiene_una_transferencia_internacional';
        intentCustom1.RecordTypeId = recordTypeIdIntentCustom;
        intentlst.add(intentCustom1);
        insert intentlst;
        
        List<LiveChatTranscript> listaChats = new List<LiveChatTranscript>();
        String faqOfrecida = faq1.Id;
        
        LiveChatTranscript chat = new LiveChatTranscript();
        chat.CaseId = caso.Id;
        chat.AccountId = cuenta.Id;
        chat.CC_Espacio__c = 'liniaObertaWSLOE';
        chat.CC_Categoria__c ='LineaAbiertaLOE';
        chat.CC_IdiomaCV__c = 'es';
        chat.CC_Cognitive_chat__c = '{"user": "U0137298", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Que_gastos_tiene_una_transferencia_internacional", "confidence": 0.8238105773925781 }, {"id": "Que_gastos_tiene_una_transferencia_internacional", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&#191;C&#243;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["es"], "errors": [] }';
        chat.LiveChatVisitorId = chatVisitor.Id;
        chat.CC_AreaChat__c = 'Clientes';
        
        chat.CC_FaqsOfrecidas__c = faqOfrecida;
        listaChats.add(chat);
        
        LiveChatTranscript chatIngles = new LiveChatTranscript();
        chatIngles.CaseId = casoIngles.Id;
        chatIngles.AccountId = cuenta.Id;
        chatIngles.CC_Espacio__c = 'liniaObertaWSLOE';
        chatIngles.CC_Categoria__c ='LineaAbiertaLOE';
        chatIngles.CC_IdiomaCV__c = 'en';
        chatIngles.CC_Cognitive_chat__c = '{"user": "U0137298", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Que_gastos_tiene_una_transferencia_internacional", "confidence": 0.8238105773925781 }, {"id": "Que_gastos_tiene_una_transferencia_internacional", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&#191;C&#243;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["es"], "errors": [] }';
        chatIngles.LiveChatVisitorId = chatVisitorIngles.Id;
        chatIngles.CC_AreaChat__c = 'Clientes';
        chatIngles.CC_FaqsOfrecidas__c = faqOfrecida;
        listaChats.add(chatIngles);
        
        LiveChatTranscript chatCatalan = new LiveChatTranscript();
        chatCatalan.CaseId = casoCatalan.Id;
        chatCatalan.AccountId = cuenta.Id;
        chatCatalan.CC_Espacio__c = 'liniaObertaWSLOE';
        chatCatalan.CC_Categoria__c ='LineaAbiertaLOE';
        chatCatalan.CC_IdiomaCV__c = 'ca';
        chatCatalan.CC_Cognitive_chat__c = '{"user": "U0137298", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Que_gastos_tiene_una_transferencia_internacional", "confidence": 0.8238105773925781 }, {"id": "Que_gastos_tiene_una_transferencia_internacional", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&#191;C&#243;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["es"], "errors": [] }';
        chatCatalan.LiveChatVisitorId = chatVisitorCatalan.Id;
        chatCatalan.CC_AreaChat__c = 'Clientes';
        chatCatalan.CC_FaqsOfrecidas__c = faqOfrecida;
        listaChats.add(chatCatalan);
        insert listaChats;
        
        CC_FAQ__c app4 = new CC_FAQ__c();
        app4.CC_Id_App__c = '1';
        app4.CC_Aplicacion_Siebel__c='OFICINA';
        app4.CC_Nombre__c = 'CC_OFICINAS';
        app4.CC_Origen__c = 'Web';
        app4.Name = 'CC_OFICINAS';
        app4.CC_IdiomaESDefault__c = '46';
        app4.CC_FAQ_Id__c = '5';
        app4.CC_FAQ_Ident__c = '5';
        app4.CC_IdiomaMsj__c = 'es';
        app4.CC_Version__c = 4;
        app4.CC_VersionActualizando__c = 4;
        app4.CC_TextoMostrar__c = 'Texto a Mostrar';
        app4.RecordTypeId = recordTypeIdAplicacion;
        insert app4;
        
        CC_FAQ__c espacio2 = new CC_FAQ__c();
        espacio2.CC_Lookup_App__c = app4.Id;
        espacio2.Name = 'liniaObertaWSLOE2';
        espacio2.CC_Nombre__c = 'liniaObertaWSLOE2';
        espacio2.CC_Categoria__c = 'Hogar';
        espacio.CC_Id_Espacio__c='150000002';
        espacio2.CC_FAQ_Id__c = '150000002';
        espacio2.CC_FAQ_Ident__c = '150000002';
        espacio2.CC_Id_App__c = '6';
        espacio2.CC_Descripcion_ca__c ='Línia Oberta de LOE';
        espacio2.CC_Descripcion_es__c ='Línea Abierta de LOE';
        espacio2.CC_ListaIDsGlobales__c = '2,17,32,46';
        espacio2.CC_Version__c = 3;
        espacio2.CC_VersionActualizando__c = 3;
        espacio2.RecordTypeId = recordTypeIdEspacio;
        espacio2.CC_TextoMostrar__c = 'Texto a Mostrar 1, Texto a Mostrar 1 Texto a Mostrar 1, Texto a Mostrar 1 Texto a Mostrar 1, Texto a Mostrar 1 Texto a Mostrar 1, Texto a Mostrar 1';
        insert espacio2;        
        
        CC_FAQ__c cat1 = new CC_FAQ__c();
        cat1.CC_FAQ_Id__c = '15000000_13830022';
        cat1.CC_FAQ_Ident__c = '13830022';
        cat1.CC_Id_App__c = '5';
        cat1.CC_Id_Categoria__c= '13830022';
        cat1.CC_Lookup_App__c = app4.Id;
        cat1.CC_Lookup_Espacio__c = espacio2.Id;
        cat1.CC_Nombre__c = 'LineaAbiertaLOE';
        cat1.Name = 'LineaAbiertaLOE';
        cat1.CC_Id_Espacio__c=  '150000001';
        cat1.CC_Descripcion_ca__c ='CaixaBankNow';
        cat1.CC_Descripcion_es__c ='CaixaBankNow';
        cat1.CC_Topic__c = 'LineaAbiertaLOE';
        cat1.CC_Version__c = 3;
        cat1.CC_VersionActualizando__c = 3;
        cat1.RecordTypeId = recordTypeIdCategoria;
        insert cat1;
        
        CC_FAQ__c faq2 = new CC_FAQ__c();
        faq2.CC_Lookup_Espacio__c = espacio2.Id;
        faq2.CC_Lookup_Categoria__c = cat1.Id;
        faq2.CC_Espacio__c='liniaObertaWSLOE';
        faq2.CC_Categoria__c='LineaAbiertaLOE';
        faq2.CC_FAQ_Id__c = '15000000_13830021_11';
        faq2.CC_FAQ_Ident__c = '6';
        faq2.CC_Lookup_App__c = app4.Id;
        faq2.CC_Pregunta_CAT__c ='Quines transferencies modalitats de Rebut Únic hi ha?';
        faq2.CC_Pregunta_ESP__c ='¿Qué transferencia modalidades de Recibo único hay?';
        faq2.CC_Version__c = 3;
        faq2.RecordTypeId = recordTypeIdFaq;
        insert faq2;
        
        CC_FAQ__c faqCustom1 = new CC_FAQ__c();
        faqCustom1.CC_Lookup_Espacio__c = espacio2.Id;
        faqCustom1.CC_Lookup_FAQ__c = faq2.Id;
        faqCustom1.CC_Lookup_Categoria__c = cat1.Id;
        faqCustom1.CC_GlobalId__c = '46';
        faqCustom1.CC_Espacio__c='liniaObertaWSLOE2';
        faqCustom1.CC_Categoria__c='LineaAbiertaLOE';
        faqCustom1.CC_Pregunta_CAT__c ='Quines transferencies modalitats de Rebut Únic hi ha?';
        faqCustom1.CC_Pregunta_ESP__c ='¿Qué transferencia modalidades de Recibo único hay?';   	
        faqCustom1.CC_Nombre__c='¿Qué modalidades de Recibo único hay?';
        faqCustom1.CC_Version__c = 3;
        faqCustom1.CC_TextoMostrar__c = 'Puedes hacer una eurotransferencia desde Cuentas > Internacional > Transferencias > Eurotransferencias básicas en euros.';
        faqCustom1.RecordTypeId = recordTypeIdFaqCustom; 
        insert faqCustom1;
        
        CC_Intent__c intent3 = new CC_Intent__c();
        intent3.CC_Descripcion__c = 'Que_gastos_tiene_una_transferencia_internacional';
        intent3.CC_FAQ_Id__c = faq2.Id;
        intent3.CC_Intent_Id__c = 1;
        intent3.CC_Nombre__c = 'Que_gastos_tiene_una_transferencia_internacional';
        intent3.CC_Respuesta_CAT__c = 'Com a emissor una transferència internacional pots seleccionar com han de repartir-se les despeses derivades de loperació. Hi ha tres modalitats: SHARE (SHA): Comparteix les despeses entre emissor i destinatari, OUR: Les despeses són íntegrament a càrrec de lemissor i BEN: Les despeses són a càrrec del destinatari. Tingues en compte que en la confirmació de operació, abans de signar-la, podràs consultar el cost aplicat al servei.';
        intent3.CC_Respuesta_ESP__c = 'Como emisor de una transferencia internacional puedes seleccionar como deben repartirse los gastos derivados de la operación. Existen tres modalidades: SHARE (SHA): Comparte los gastos entre emisor y destinatario, OUR: Los gastos corren íntegramente a cargo del emisor y BEN: Los cargos corren a cargo del destinatario. Ten en cuenta que en la confirmación de la operación, antes de firmarla, podrás consultar el coste aplicado al servicio.';
        intent3.Name = 'Que_gastos_tiene_una_transferencia_internacional';
        insert intent3;
                
        CC_Intent__c intent4 = new CC_Intent__c();
        intent4.CC_Descripcion__c = 'Que_gastos_tiene_una_transferencia_internacional';
        intent4.CC_FAQ_Id__c = faq2.Id;
        intent4.CC_Intent_Id__c = 1;
        intent4.CC_IntentIdExt__c = '15000000_13830021_1_1';
        intent4.CC_Nombre__c = 'Que_gastos_tiene_una_transferencia_internacional';
        intent4.CC_Version__c = 3;    
        intent4.Name = 'Que_gastos_tiene_una_transferencia_internacional';
        intent4.RecordTypeId = recordTypeIdIntent;
        insert intent4;
        
        CC_Intent__c intentCustom2 = new CC_Intent__c();
        intentCustom2.CC_Descripcion__c = 'Que_gastos_tiene_una_transferencia_internacional';
        intentCustom2.CC_FAQ_Id__c = faq2.Id;
        intentCustom2.CC_GlobalId__c = '46';
        intentCustom2.CC_Intent_Id__c = 1;
        intentCustom2.CC_Intent_Padre__c = intent4.Id;
        intentCustom2.CC_IntentIdExt__c = '15000000_13830021_1_1_47';
        intentCustom2.CC_IntentIdExt__c = '15000000_13830021_1_1';
        intentCustom2.CC_Nombre__c = 'Que_gastos_tiene_una_transferencia_internacional';
        intentCustom2.CC_TextoMostrar__c = 'Puedes hacer una eurotransferencia desde Cuentas > Internacional > Transferencias > Eurotransferencias básicas en euros.';
        intentCustom2.CC_Version__c = 3;    
        intentCustom2.Name = 'Que_gastos_tiene_una_transferencia_internacional';
        intentCustom2.RecordTypeId = recordTypeIdIntentCustom;
        insert intentCustom2;

        Test.stopTest();
    }
    
    
    @isTest
    static void getFAQsWrapper() {
        Test.startTest();
        
        //recuperación del chat
        LiveChatTranscript chat = [SELECT Id FROM LiveChatTranscript WHERE CC_IdiomaCV__c = 'es'];
        Map<String,Object> chatTranscript = CC_LiveAgent_FAQ_Controller.getLiveChatTranscript(chat.Id);
        
        LiveChatTranscript chatIngles = [SELECT Id FROM LiveChatTranscript WHERE CC_IdiomaCV__c = 'en'];
        Map<String,Object> chatTranscriptIngles = CC_LiveAgent_FAQ_Controller.getLiveChatTranscript(chatIngles.Id);
        
        LiveChatTranscript chatCatalan = [SELECT Id FROM LiveChatTranscript WHERE CC_IdiomaCV__c = 'ca'];
        Map<String,Object> chatTranscriptCatalan = CC_LiveAgent_FAQ_Controller.getLiveChatTranscript(chatCatalan.Id);
        System.assert(!chatTranscript.isEmpty());
        
        //Idioma es
        String idioma = 'es';
        String recordId = chat.Id;
        String searchKey = 'transferencia';
        Integer limite = 0;
        List<String> oGlobalId = new List<String>();
        oGlobalId.add('1');
        oGlobalId.add('16');
        oGlobalId.add('47');
        CC_FAQ__c espacio = [SELECT Name FROM CC_FAQ__c WHERE Name = 'liniaObertaWSLOE'];
        CC_FAQ__c cat = [SELECT Name FROM CC_FAQ__c WHERE Name = 'LineaAbiertaLOE' LIMIT 1];
        CC_FAQ__c app = [SELECT Name FROM CC_FAQ__c WHERE Name = 'LiniaObertaApp'];
        List<CC_LiveAgent_FAQ_Controller.FaqIntentListWrapper> faqListWrapperSearch = CC_LiveAgent_FAQ_Controller.getFAQsWrapper(recordId, espacio.Name , cat.Name, searchKey, idioma, limite, null);
        faqListWrapperSearch = CC_LiveAgent_FAQ_Controller.getFAQsWrapper(recordId, espacio.Name , cat.Name, searchKey, idioma, limite, oGlobalId);
        System.assertEquals(1, faqListWrapperSearch.size());
        
        List<CC_LiveAgent_FAQ_Controller.pickListWrapper> espacios = CC_LiveAgent_FAQ_Controller.getValuesPicklistEspacios(idioma, espacio.Name, app.Name);
        System.assert(espacios.size()>0);
        List<CC_LiveAgent_FAQ_Controller.pickListWrapper> espaciosFilter = CC_LiveAgent_FAQ_Controller.getValuesPicklistFiltersEspacio(idioma, espacio.Name);
        System.assert(espaciosFilter.size()>0);
        List<CC_LiveAgent_FAQ_Controller.pickListWrapper> categoriasFilter = CC_LiveAgent_FAQ_Controller.getValuesPicklistFiltersCategoria(espacio.Name, cat.Name, 'CC_OFICINAS');
        categoriasFilter = CC_LiveAgent_FAQ_Controller.getValuesPicklistFiltersCategoria(espacio.Name, cat.Name, '');
        System.assert(categoriasFilter.size()>0);
        
        Id recordTypeIdMensaje = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_FAQ__c', 'Mensaje_Automatico_Chat');
        
        CC_FAQ__c mensajeGlobal = new CC_FAQ__c();
        mensajeGlobal.CC_Procedencia_Mensaje_Automatico__c='Buscar FAQ ya ofrecida';
        mensajeGlobal.CC_Codigo_Cognitive__c='MSG_HA_INSIST_FAQ';
        mensajeGlobal.CC_Mensaje_Agente_ca__c ='<auto>FAQ enviada:';
        mensajeGlobal.CC_Mensaje_Agente_es__c   ='<auto>FAQ enviada:';
        mensajeGlobal.RecordTypeId = recordTypeIdMensaje;
        mensajeGlobal.CC_GlobalId__c = '47';
        mensajeGlobal.CC_Origen__c = 'Web';
        mensajeGlobal.CC_AreaMensaje__c = 'Cliente';
        insert mensajeGlobal;
        
        //getMensaje
        List<CC_FAQ__c> mensajes = CC_LiveAgent_FAQ_Controller.getMensaje(null, idioma, oGlobalId, mensajeGlobal.CC_Origen__c, mensajeGlobal.CC_AreaMensaje__c);
        mensajes = CC_LiveAgent_FAQ_Controller.getMensaje(mensajeGlobal.CC_Procedencia_Mensaje_Automatico__c, null, null, mensajeGlobal.CC_Origen__c, mensajeGlobal.CC_AreaMensaje__c);
        mensajes = CC_LiveAgent_FAQ_Controller.getMensaje(mensajeGlobal.CC_Procedencia_Mensaje_Automatico__c, idioma, oGlobalId, mensajeGlobal.CC_Origen__c, mensajeGlobal.CC_AreaMensaje__c);
        System.assert(mensajes.size()>0);
        
        //getMensajeSin Id Global
        List<String> oGlobalId0 = new List<String>();
        oGlobalId.add('0');        
        List<CC_FAQ__c> mensajesSinGlobal = CC_LiveAgent_FAQ_Controller.getMensaje(mensajeGlobal.CC_Procedencia_Mensaje_Automatico__c, idioma, oGlobalId0, mensajeGlobal.CC_Origen__c, mensajeGlobal.CC_AreaMensaje__c);
        System.assert(mensajesSinGlobal.size()>0);
        
        limite= 2;
        List<CC_LiveAgent_FAQ_Controller.FaqIntentListWrapper> faqListWrapperLimite2 = CC_LiveAgent_FAQ_Controller.getFAQsWrapper(recordId, espacio.Name , cat.Name, searchKey, idioma, limite, oGlobalId);
        System.assert(faqListWrapperLimite2.size()>0);
        
        List<CC_LiveAgent_FAQ_Controller.FaqIntentListWrapper> faqListWrapperLimite3 = CC_LiveAgent_FAQ_Controller.getFAQsWrapper(recordId, espacio.Name , '', searchKey, idioma, limite, oGlobalId);
        //System.assert(faqListWrapperLimite2.size()>0);'
        List<CC_LiveAgent_FAQ_Controller.FaqIntentListWrapper> faqListWrapperLimite4 = CC_LiveAgent_FAQ_Controller.getFAQsWrapper(recordId, espacio.Name , '--Selecciona una categoría--', searchKey, idioma, limite, oGlobalId);
        
        
        CC_FAQ__c faqCustom = [SELECT Name FROM CC_FAQ__c WHERE CC_Nombre__c = '¿Qué modalidades de Recibo único hay? 1' LIMIT 1];
        List<CC_Intent__c> lista = CC_LiveAgent_FAQ_Controller.getFaqWithIntentsByFAQ(faqCustom.Id, oGlobalId);
        System.assert(lista.size()>0);
        
        List<CC_Intent__c> listaNull = CC_LiveAgent_FAQ_Controller.getFaqWithIntentsByFAQ(null, oGlobalId);
        System.assertEquals(null, listaNull);
        
        List<CC_Intent__c> listaGlobalNull = CC_LiveAgent_FAQ_Controller.getFaqWithIntentsByFAQ(faqCustom.Id, null);
        System.assertEquals(null, listaGlobalNull);
        
        List<String> listaGlobalId = new List<String>();
        listaGlobalNull = CC_LiveAgent_FAQ_Controller.getFaqWithIntentsByFAQ(faqCustom.Id, listaGlobalId);
        
        Test.stopTest();
    }
    
    @isTest
    static void getFAQsWrapper_CacheES() {
        Test.startTest();
        CC_FAQ__c espacio = [SELECT Name, CC_Nombre__c FROM CC_FAQ__c WHERE Name = 'liniaObertaWSLOE2' LIMIT 1];                
        String idioma = 'es';
        
        List<CC_LiveAgent_FAQ_Controller.FaqIntentListWrapper> lista = CC_LiveAgent_FAQ_Controller.getFAQsWrapper_Cache(espacio.CC_Nombre__c, idioma, 'CC_OFICINAS');
        System.assert(lista.size()>0);
        
        Test.stopTest();
    } 
    
    @isTest 
    static void datosLiveChatTranscriptTest() {
        Test.startTest();
        
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
        
        String recordId = (String)caso.Id;
        String idioma = 'es';
        String espacio = 'Ahorro';
        String categoria = 'AhorroAPlazoEnDivisas';
        Id recordTypeCategoria = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_FAQ__c', 'CC_Categoria');           
        Id recordTypeEspacio = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_FAQ__c', 'CC_Espacios');            
        
        List<CC_FAQ__c> faqs = new List<CC_FAQ__c>();
        faqs.add(new CC_FAQ__c(Name=categoria, RecordtypeId = recordTypeCategoria));
        insert faqs;
        
        
        Map<String,String> datos = new Map<String,String>();
        datos.put('Categoria',categoria);
        datos.put('Espacio',espacio);
        datos.put('Idioma',idioma);
        datos = CC_LiveAgent_FAQ_Controller.datosLiveChatTranscript(recordId, idioma, espacio, categoria);
        System.assertEquals(true, !datos.isEmpty());
        
        Test.stopTest();
    }
}