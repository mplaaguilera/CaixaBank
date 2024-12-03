@isTest
public class CC_GestionEntradaChat_Test {

    // Clase de test temporal.
    @isTest
    static void test01_chatCliente() {
        
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

        String texto = '{"user":"13619528"}';        
/*texto = texto + '"{\"user\":\"13619528\",\"startTime\":\"2019-08-21T05:55:19.134Z\",\"duration\":1566366919134,\"iterations\":4,\"reformulations\":1,\"areas\":[\"NeoApp\"],\"userQuery\":[\"a ver me puedes poner con\",\"hablar con un gestor\"],\"conversationUnits\":[{\"type\":60,\"text\":\"1\",\"timestamp\":\"2019-08-21T05:55:19.134Z\"},{\"type\":1,\"text\":\"a ver me puedes poner con\",\"timestamp\":\"2019-08-21T05:55:19.134Z\",\"auto\":false},{\"type\":5,\"text\":\"a ver me puedes poner con\",\"timestamp\":\"2019-08-21T05:55:19.134Z\"},{\"type\":13,\"results\":[{\"id\":\"NeoApp\",\"confidence\":0.050811272}],\"timestamp\":\"2019-08-21T05:55:20.756Z\"},{\"type\":23,\"text\":\"a ver me puedes poner con\",\"timestamp\":\"2019-08-21T05:55:20.756Z\"},{\"type\":8,\"text\":\"NeoApp\",\"timestamp\":\"2019-08-21T05:55:20.756Z\"},{\"type\":3,\"results\":[{\"id\":\"Como_puedes_consultar_los_recibos_domiciliados_en_tu_cuenta_NeoApp\",\"confidence\":0.4552262544631958},{\"id\":\"_Como_puedes_ver_los_prestamos_que_has_contratado_en_CaixaBank_\",\"confidence\":0.30560939311981206},{\"id\":\"Como_consultar_los_pagos_a_terceros_emitidos_NeoApp\",\"confidence\":0.2869901299476624},{\"id\":\"Como_puedes_solicitar_una_cita_previa_con_tu_gestor_NeoApp\",\"confidence\":0.2732272565364838},{\"id\":\"Como_puedes_consultar_los_movimientos_de_tus_cuentas_anteriores_a_los_ultimos_12_meses_NeoApp\",\"confidence\":0.2731297731399536},{\"id\":\"Como_consultar_liquidaciones_de_periodos_anteriores_de_tu_tarjeta_de_credito_NeoApp\",\"confidence\":0.26579814553260805},{\"id\":\"Donde_puedes_consultar_los_seguros_que_tienes_contratados_NeoApp\",\"confidence\":0.2656560242176056},{\"id\":\"Como_puedo_consultar_el_cuadro_medico_de_mi_seguro_de_salud_NeoApp\",\"confidence\":0.26206207275390625},{\"id\"';
texto = texto + ':\"Como_puedes_ver_un_resumen_de_tus_ingresos_y_gastos_NeoApp\",\"confidence\":0.2591778874397278},{\"id\":\"Cuales_son_los_requisitos_de_gratuidad_de_la_cuenta_inTouch_NeoApp\",\"confidence\":0.2551810681819916}],\"timestamp\":\"2019-08-21T05:55:20.756Z\"},{\"type\":63,\"results\":[{\"id\":\"Como_puedes_consultar_los_recibos_domiciliados_en_tu_cuenta_NeoApp\",\"confidence\":0.4552262544631958},{\"id\":\"_Como_puedes_ver_los_prestamos_que_has_contratado_en_CaixaBank_\",\"confidence\":0.30560939311981206},{\"id\":\"Como_consultar_los_pagos_a_terceros_emitidos_NeoApp\",\"confidence\":0.2869901299476624},{\"id\":\"Como_puedes_solicitar_una_cita_previa_con_tu_gestor_NeoApp\",\"confidence\":0.2732272565364838},{\"id\":\"Como_puedes_consultar_los_movimientos_de_tus_cuentas_anteriores_a_los_ultimos_12_meses_NeoApp\",\"confidence\":0.2731297731399536}],\"timestamp\":\"2019-08-21T05:55:20.756Z\"},{\"type\":4,\"text\":\"\\u003cBR\/\\u003e\\u003cli\\u003e\u00bfC\u00f3mo puedes consultar los recibos domiciliados en tu cuenta?\\u003c\/li\\u003e\\u003cli\\u003e\u00bfC\u00f3mo puedes ver los pr\u00e9stamos que has contratado en CaixaBank?\\u003c\/li\\u003e\\u003cli\\u003e\u00bfC\u00f3mo consultar los pagos a terceros emitidos?\\u003c\/li\\u003e\\u003cli\\u003e\u00bfC\u00f3mo puedes solicitar una cita previa con tu gestor?\\u003c\/li\\u003e\\u003cli\\u003e\u00bfC\u00f3mo puedes consultar los movimientos de tus cuentas anteriores a los \u00faltimos 12 meses?\\u003c\/li\\u003e\\u003cli\\u003eVer m\u00e1s respuestas\\u003c\/li\\u003e\",\"timestamp\":\"2019-08-21T05:55:20.757Z\"},{\"type\":5,\"text\":\"\u00bfC\u00f3mo puedes solicitar una cita previa con tu gestor?\",\"timestamp\":\"2019-08-21T05:56:31.920Z\"},{\"type\":4,\"text\":\"Si tienes disponible Cita Previa, puedes solicitar una con tu gestor accediendo a la secci\u00f3n Mi Gestor\/Mi Oficina en la pantalla de inicio. En el men\u00fa de la secci\u00f3n podr\u00e1s ver los datos de contacto o solicitar una cita previa.\\u003cBR\/\\u003e\\u003cB\\u003e\u00bfC\u00f3mo puedes solicitar una cita previa con tu gestor?\\u003c\';
texto = texto + '/B\\u003e\\u003cBR\/\\u003e\",\"timestamp\":\"2019-08-21T05:56:31.920Z\"},{\"type\":66,\"text\":\"\u00bfC\u00f3mo puedes solicitar una cita previa con tu gestor?\",\"id\":\"Como_puedes_solicitar_una_cita_previa_con_tu_gestor_NeoApp\",\"timestamp\":\"2019-08-21T05:56:31.920Z\",\"responseCode\":\"FAQ\"},{\"type\":6,\"text\":\"\u00bfC\u00f3mo puedes solicitar una cita previa con tu gestor?\",\"id\":\"Como_puedes_solicitar_una_cita_previa_con_tu_gestor_NeoApp\",\"timestamp\":\"2019-08-21T05:56:31.920Z\",\"responseCode\":\"FAQ\"},{\"type\":4,\"text\":\"\u00bfTe ha sido \u00fatil mi respuesta? U+1F600;\\u003cBR\/\\u003e\\u003cli\\u003eU+1F44D;\\u003c\/li\\u003e\\u003cli\\u003eU+1F44E;\\u003c\/li\\u003e\",\"timestamp\":\"2019-08-21T05:56:31.920Z\"},{\"type\":65,\"results\":[{\"id\":\"POSITIVO\"},{\"id\":\"MAS_OPCIONES\"}],\"timestamp\":\"2019-08-21T05:56:31.920Z\"},{\"type\":70,\"text\":\"MAS_OPCIONES\",\"id\":\"MORE_OPTIONS_FEED\",\"timestamp\":\"2019-08-21T05:57:03.653Z\"},{\"type\":5,\"text\":\"U+1F44E;\",\"timestamp\":\"2019-08-21T05:57:03.653Z\"},{\"type\":4,\"text\":\"Vaya, lo siento. Tambi\u00e9n he encontrado esto, que ahora s\u00ed, espero que sea lo que buscabas.\",\"timestamp\":\"2019-08-21T05:57:03.654Z\"},{\"type\":63,\"results\":[{\"id\":\"Como_consultar_liquidaciones_de_periodos_anteriores_de_tu_tarjeta_de_credito_NeoApp\",\"confidence\":0.26579814553260805},{\"id\":\"Donde_puedes_consultar_los_seguros_que_tienes_contratados_NeoApp\",\"confidence\":0.2656560242176056},{\"id\":\"Como_puedo_consultar_el_cuadro_medico_de_mi_seguro_de_salud_NeoApp\",\"confidence\":0.26206207275390625},{\"id\":\"Como_puedes_ver_un_resumen_de_tus_ingresos_y_gastos_NeoApp\",\"confidence\":0.2591778874397278},{\"id\":\"Cuales_son_los_requisitos_de_gratuidad_de_la_cuenta_inTouch_NeoApp\",\"confidence\":0.2551810681819916}],\"timestamp\":\"2019-08-21T05:57:03.654Z\"},{\"type\":4';
texto = texto + ',\"text\":\"\\u003cBR\/\\u003e\\u003cli\\u003e\u00bfC\u00f3mo consultar liquidaciones de per\u00edodos anteriores de tu tarjeta de cr\u00e9dito?\\u003c\/li\\u003e\\u003cli\\u003e\u00bfD\u00f3nde puedes consultar los seguros que tienes contratados?\\u003c\/li\\u003e\\u003cli\\u003e\u00bfC\u00f3mo puedo consultar el cuadro m\u00e9dico de mi seguro de salud?\\u003c\/li\\u003e\\u003cli\\u003e\u00bfC\u00f3mo puedes ver un resumen de tus ingresos y gastos?\\u003c\/li\\u003e\\u003cli\\u003e\u00bfCu\u00e1les son los requisitos de gratuidad de la cuenta inTouch?\\u003c\/li\\u003e\\u003cli\\u003eVer m\u00e1s respuestas\\u003c\/li\\u003e\",\"timestamp\":\"2019-08-21T05:57:03.654Z\"},{\"type\":13,\"results\":[{\"id\":\"NeoApp\",\"confidence\":0.009196575}],\"timestamp\":\"2019-08-21T05:57:37.513Z\"},{\"type\":60,\"text\":\"2\",\"timestamp\":\"2019-08-21T05:57:37.513Z\"},{\"type\":2,\"text\":\"hablar con un gestor\",\"timestamp\":\"2019-08-21T05:57:37.513Z\",\"auto\":true},{\"type\":5,\"text\":\"hablar con un gestor\",\"timestamp\":\"2019-08-21T05:57:37.513Z\"},{\"type\":8,\"text\":\"NeoApp\",\"timestamp\":\"2019-08-21T05:57:37.513Z\"},{\"type\":3,\"results\":[{\"id\":\"Como_puedes_solicitar_una_cita_previa_con_tu_gestor_NeoApp\",\"confidence\":0.625798225402832},{\"id\":\"_Como_contacto_con_un_agente_993368263\",\"confidence\":0.5846513509750366},{\"id\":\"Como_puedes_reclamar_un_cargo_hecho_en_tu_tarjeta_NeoApp\",\"confidence\":0.2751889765262604},{\"id\":\"Como_funciona_el_BOT_de_CaixaBank_NeoApp\",\"confidence\":0.25250639319419865},{\"id\":\"_Como_alquilar_un_coche_993368280\",\"confidence\":0.25222427248954776},{\"id\":\"_Que_tienes_que_hacer_si_tienes_un_descubierto_en_cuenta___993368334\",\"confidence\":0.25188765525817874},{\"id\":\"Como_puedes_modificar_un_perfil_ya_creado_en_Mis_finanzas_NeoApp\",\"confidence\":0.24957865774631502},{\"id\":\"_Como_anular_una_orden_de_impago_dada_de_alta_previamente_993368350\",\"confidence\":0.24849270284175873},{\"id\":\"_Puedes_dar_de_alta_una_cuenta_con_varios_titulares_conjuntamente_993367163\",\"confidence\":0.2473608285188675},{\"id\":\"Como_funciona_Bizum_para_enviar_dinero_de_movil_a_movil_NeoApp\",\"confidence\":0.24674556851387025}],\"timestamp\":\"2019-08-21T05:57:37.513Z\"},{\"type\":63,\"results\":[{\"id\":\"_Como_contacto_con_un_agente_993368263\",\"confidence\":0.5846513509750366}],\"timestamp\":\"2019-08-21T05:57:37.514Z\"},{\"type\":6';
texto = texto + ',\"text\":\"\u00bfC\u00f3mo contacto con un agente?\",\"id\":\"_Como_contacto_con_un_agente_993368263\",\"timestamp\":\"2019-08-21T05:57:37.514Z\",\"responseCode\":\"FAQ\"},{\"type\":10,\"text\":\"Si no he entendido mal, creo que quieres hablar con un agente humano, \u00bfprefieres que te solucione yo la consulta y as\u00ed evitas esperas?\\u003cBR\/\\u003e\\u003cli\\u003eS\u00ed\\u003c\/li\\u003e\\u003cli\\u003eNo\\u003c\/li\\u003e\",\"timestamp\":\"2019-08-21T05:57:37.614Z\"},{\"type\":64,\"text\":\"_Como_contacto_con_un_agente_993368263\",\"id\":\"3\",\"timestamp\":\"2019-08-21T05:57:37.614Z\",\"orgText\":\"hablar con un gestor\"},{\"type\":5,\"text\":\"No\",\"timestamp\":\"2019-08-21T05:57:49.314Z\"},{\"type\":10,\"text\":\"Te estamos poniendo en contacto con uno de nuestros agentes. Espera unos segundos.\\u003cBR\/\\u003e\\u003cBR\/\\u003e\\u003cBR\/\\u003e\\u003cli\\u003eAPPCaixaBankNow\\u003c\/li\\u003e\",\"timestamp\":\"2019-08-21T05:57:49.314Z\"},{\"type\":4,\"text\":\"Chat a APP CaixaBankNow\",\"timestamp\":\"2019-08-21T05:57:49.314Z\"},{\"type\":64,\"text\":\"_Como_contacto_con_un_agente_993368263\",\"id\":\"5\",\"timestamp\":\"2019-08-21T05:57:49.314Z\"}],\"revision\":\"NO\",\"centro\":\"00000\",\"badClassifications\":[],\"agents\":[\"WATSON\"],\"aplicacionOrigen\":\"\",\"conversationID\":\"13619528_100069719\",\"currentID\":100069719,\"aplicacionCorpus\":\"NeoAPP\",\"idioma\":\"es\",\"idiomasDetectados\":[\"es\",\"es\"],\"perfil\":\"Default\",\"idGlobalList\":[\"17\",\"22\",\"37\"],\"errors\":[],\"datos\":[{\"userTextOriginal\":\"a ver me puedes poner con\",\"userTextObfuscate\":\"a ver me puedes poner con\",\"identifiedObjects\":[]},{\"userTextOriginal\":\"hablar con un gestor\",\"userTextObfuscate\":\"hablar con un gestor\",\"identifiedObjects\":[]}],\"prioritaria\":\"NO\"}"';
     */   
        LiveChatTranscript liveChatTranscript2 = new LiveChatTranscript(
            CC_Bienvenida__c = false,
            CC_Nickname__c = 'Cliente 1',
            CC_Idioma__c = 'es',
            LiveChatVisitorId = liveChatVisitor2.Id,
            CC_Id_Cognitive__c='9001029ab',
            CC_NumEmpleado__c = 'U011234',
            CC_Cognitive_chat__c = texto//,
            //CC_NumPerso2__c = '999910559714',
            //AccountId = [SELECT Id FROM Account WHERE CC_NumPerso__c = '999910559714'].Id,
            //ContactId = [SELECT Id FROM Contact WHERE CC_NumPerso__c = '999910559714'].Id//,
            //CaseId = [SELECT Id FROM Case WHERE Subject = 'Test_01'].Id
        );
        
        // Se pone try/catch por configuración de valores de entorno.
        try
        {
            insert liveChatTranscript2;
        }catch(Exception e){
            CBK_Log.error('Error al crear chat: test01_chatCliente - ' + e.getMessage());
        }
        
        List<LiveChatTranscript> chats2 = new List<LiveChatTranscript>();
        chats2.add(liveChatTranscript2);
        
        try
        {
            CC_GestionEntradaChat.gestionEntradaChats(chats2);
        }catch(Exception e){
            CBK_Log.error('Error gestión entrada chats: test01_chatCliente - ' + e.getMessage());
        }
        
        
    }   
    
    @isTest
    static void testChatEmpleadoCSIBankia() {
        
        //Creacion de una cuenta Oficina
        Id recordTypeOficina = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Centro CaixaBank').getRecordTypeId();
        Account accountTest = new Account();
        accountTest.recordtypeId=recordTypeOficina;
        accountTest.Name = 'Account Test';
        accountTest.CC_Numero_Oficina_Empresa__c = '001-0101';
        insert accountTest;  

        //Creacion de un contacto de tipo Empleado
        Id recordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        Contact testContact = new Contact();
        testContact.FirstName = 'Contacto';
        testContact.LastName = 'Test';
        testContact.CC_Matricula__c = 'U011234';
        testContact.Email = 'prueba21@caixabank.com';
        testContact.AccountId = accountTest.Id;
        testContact.RecordTypeId = recordTypeEmpleado;
        testContact.CC_Idioma__c = 'ES';
        testContact.CC_NumPerso__c = '999910559714';
        insert testContact;
        
        // Crear teléfono y mail del contacto.
        String sRecordType1 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        String sRecordType2 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        
        CC_Canal_Com__c c1 = new CC_Canal_Com__c();
        c1.CC_NumPerso__c = '999910559714';
        c1.CC_ContactoId__c = testContact.Id;
        c1.CC_CuentaId__c = accountTest.Id;
        c1.CC_Telefono__c = '34 956565656';
        c1.RecordTypeId = sRecordType1;
        insert c1;
        
        List<CC_Canal_Com__c> o3 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Telefono__c = '34 956565656'];
        System.assertEquals(o3.size(), 1);
        
        CC_Canal_Com__c c2 = new CC_Canal_Com__c();
        c2.CC_NumPerso__c = '999910559714';
        c2.CC_ContactoId__c = testContact.Id;
        c2.CC_CuentaId__c = accountTest.Id;
        c2.CC_Email__c = 'prueba21@caixabank.com';
        c2.RecordTypeId = sRecordType2;
        insert c2;
        
        List<CC_Canal_Com__c> o4 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Email__c = 'prueba21@caixabank.com'];
        System.assertEquals(o4.size(), 1);

        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            CC_Bienvenida__c = false,
            CC_Nickname__c = 'Empleado',
            CC_Idioma__c = 'es',
            LiveChatVisitorId = liveChatVisitor.Id,
            CC_Id_Cognitive__c='9001029aa',
            CC_NumEmpleado__c = 'U011234',
            CC_Tipo__c = 'Agente',
            CC_Aplicacion__c = 'CC_OFICINAS_CSI',
            CC_Subject__c = 'como dar de alta una llave',
            CC_Descripcion__c = 'como dar de alta una llave',
            CC_CaseOrigin__c = 'Chat',
            CC_Prioridad__c = 'Low',
            CC_IdiomaCV__c = 'es',
            CC_Canal_Procedencia__c = 'CCO CSI',
            CC_Espacio__c = 'Neocsi',
            CC_Categoria__c = 'C_CSI_CCO',
            CC_Empresa__c = '001',
            CC_Oficina__c = '0101', 
            CC_Cognitive_chat__c = cognitiveChatJSONExample()
        );
        insert liveChatTranscript;
        
        List<LiveChatTranscript> chatList = new List<LiveChatTranscript>();
        chatList.add(liveChatTranscript);

        Map<String,Map<String,String>> datosChatsRetorno = new Map<String,Map<String,String>>();
        Test.startTest();
            datosChatsRetorno = CC_GestionEntradaChat.gestionEntradaChats(chatList);
        Test.stopTest();
        
        List<Case> caseList = [SELECT Id, AccountId, ContactId, Canal_del_Empleado__c, RecordType.DeveloperName FROM Case WHERE CC_Id_Cognitivo__c = '9001029aa'];
        System.assertEquals(1, caseList.size());
        System.assertEquals('CSI', caseList[0].Canal_del_Empleado__c);
        System.assertEquals('CC_CSI_Bankia', caseList[0].RecordType.DeveloperName);
        System.assertEquals(accountTest.Id, caseList[0].AccountId);
        System.assertEquals(testContact.Id, caseList[0].ContactId);
    }

    public static String cognitiveChatJSONExample()
    {
        String cognChat = '{"user":"U011234","startTime":"2021-02-23T12:11:40.374Z","duration":1614082300374,"iterations":1,"reformulations":0,'
        + '"areas":["NeocsiChitChat","Neocsi"],"userQuery":["seguros","como dar de alta una llave"],'
        +'"conversationUnits":[{"type":18,"text":"El mensaje FAMILIA_MENSAJES_COMERCIALES no está definido.","timestamp":"2021-02-23T12:10:24.350Z"},'
        +'{"type":18,"text":"El parámetro FAQ_GREETINGS_ACTIVATED de tipo D no está definido. Usando valor por defecto (0)","timestamp":"2021-02-23T12:10:24.467Z"},'
        +'{"type":4,"text":"¡Bienvenido! Soy Neo CSI, ¿en qué puedo ayudarte?","timestamp":"2021-02-23T12:10:24.468Z"},{"type":60,"text":"1","timestamp":"2021-02-23T12:11:40.374Z"},'
        +'{"type":1,"text":"seguros","timestamp":"2021-02-23T12:11:40.374Z","auto":false},{"type":5,"text":"seguros","timestamp":"2021-02-23T12:11:40.374Z"},'
        +'{"type":13,"results":[{"id":"NeocsiChitChat","confidence":0.0234375}],"timestamp":"2021-02-23T12:11:42.331Z"},{"type":8,"text":"NeocsiChitChat","timestamp":"2021-02-23T12:11:42.331Z"},'
        +'{"type":21,"text":"seguros","timestamp":"2021-02-23T12:11:42.331Z"},{"type":4,"text":"Lo siento, no tengo una respuesta para esto. Por favor, intenta reformular la pregunta.",'
        +'"timestamp":"2021-02-23T12:11:42.331Z"},{"type":60,"text":"2","timestamp":"2021-02-23T12:11:53.864Z"},{"type":2,"text":"como dar de alta una llave","timestamp":"2021-02-23T12:11:53.864Z",'
        +'"auto":false},{"type":5,"text":"como dar de alta una llave","timestamp":"2021-02-23T12:11:53.864Z"},{"type":18,"text":"El parámetro NEW_CLASSIFIER_ACTIVATED de tipo D no está definido.'
        +' Usando valor por defecto (0)","timestamp":"2021-02-23T12:11:54.355Z"},{"type":13,"results":[{"id":"Neocsi","confidence":0.032987863}],"timestamp":"2021-02-23T12:11:55.484Z"},'
        +'{"type":23,"text":"como dar de alta una llave","timestamp":"2021-02-23T12:11:55.484Z"},{"type":8,"text":"Neocsi","timestamp":"2021-02-23T12:11:55.484Z"},{"type":3,'
        +'"results":[{"id":"_Como_puedo_solicitar_una_llave_extra_de_la_oficina_1986772559","confidence":0.7507101893424988},{"id":"_Como_hacer_una_compra_de_valores_1986772566",'
        +'"confidence":0.16318191587924957},{"id":"Pasos_a_seguir_en_caso_de_cliente_con_DNI_o_NIE_duplicado1986772569","confidence":0.1287849098443985},{"id":"_Como_puedo_activar_mi_usuario_VPN_1986772557",'
        +'"confidence":0.1197027862071991},{"id":"_Has_olvidado_tu_contrasena_de_Virtaula_1986772575","confidence":0.10082046687602997},'
        +'{"id":"_Cuando_estara_hecho_el_cambio_de_contrasena_en_un_entorno_o_aplicacion_1986772556","confidence":0.0896313413977623},'
        +'{"id":"_Que_comision_de_Administracion_tienen_los_depositos_de_ahorro_a_la_vista_1986772571","confidence":0.0839037299156189},{"id":"Como_contratar_SIA1986772572","confidence":0.07888000458478928},'
        +'{"id":"_Como_conectarme_a_un_equipo_por_primera_vez_1986772558","confidence":0.0757516622543335},{"id":"_Que_debo_hacer_si_pierdo_una_libreta_1986772570","confidence":0.07477126270532608}],'
        +'"timestamp":"2021-02-23T12:11:55.484Z"},{"type":63,"results":[{"id":"_Como_puedo_solicitar_una_llave_extra_de_la_oficina_1986772559","confidence":0.7507101893424988}],'
        +'"timestamp":"2021-02-23T12:11:55.484Z"},{"type":4,"text":"Siempre que se trate de solicitar una copia debes realizar la solicitud desde Servicenow, indicando en el campo “Servicio a pedir “: '
        +'Suministrar llave extra de acceso a la oficina (KABA).\u003cBR/\u003e\u003cB\u003e¿Cómo puedo solicitar una llave extra de la oficina?\u003c/B\u003e\u003cBR/\u003e",'
        +'"timestamp":"2021-02-23T12:11:55.484Z"},{"type":6,"text":"¿Cómo puedo solicitar una llave extra de la oficina?","id":"_Como_puedo_solicitar_una_llave_extra_de_la_oficina_1986772559",'
        +'"timestamp":"2021-02-23T12:11:55.484Z","responseCode":"FAQ"},{"type":4,"text":"¿Es lo que estabas buscando?\u003cBR/\u003e\u003cli\u003eSí, ¡gracias!\u003c/li\u003e\u003cli\u003eMás '
        +'opciones\u003c/li\u003e\u003cli\u003eReformular\u003c/li\u003e","timestamp":"2021-02-23T12:11:55.485Z"},{"type":65,"results":[{"id":"POSITIVO"},{"id":"MAS_OPCIONES"},{"id":"REFORMULAR"}],'
        +'"timestamp":"2021-02-23T12:11:55.485Z"},{"type":70,"text":"MAS_OPCIONES","id":"MORE_OPTIONS_FEED","timestamp":"2021-02-23T12:12:00.505Z"},{"type":5,"text":"Más opciones",'
        +'"timestamp":"2021-02-23T12:12:00.505Z"},{"type":4,"text":"Voy a buscar más.","timestamp":"2021-02-23T12:12:00.505Z"},{"type":60,"text":"3","timestamp":"2021-02-23T12:12:01.116Z"},'
        +'{"type":18,"text":"Error en DOCS ([IllegalPathParamsException] Has not been reported all PathParams necessary): [IllegalPathParamsException] Has not been reported all PathParams necessary",'
        +'"timestamp":"2021-02-23T12:12:01.891Z"},{"type":8,"text":"Neocsi","timestamp":"2021-02-23T12:12:01.891Z"},{"type":7,"results":[],"timestamp":"2021-02-23T12:12:01.891Z"},{"type":4,'
        +'"text":"Parece que voy a necesitar refuerzos. ¿Te parece bien si un agente revisa tu consulta?\u003cBR/\u003e\u003cli\u003eSí, ¡gracias!\u003c/li\u003e\u003cli\u003eNo\u003c/li\u003e",'
        +'"timestamp":"2021-02-23T12:12:01.891Z"},{"type":65,"results":[{"id":"POSITIVO"},{"id":"REFORMULAR"}],"timestamp":"2021-02-23T12:12:01.891Z"},{"type":70,"text":"POSITIVO","id":"CONTACTAR_AGENTE_MSG_OK",'
        +'"timestamp":"2021-02-23T12:12:08.868Z"},{"type":5,"text":"Sí, ¡gracias!","timestamp":"2021-02-23T12:12:08.868Z"},{"type":4,"text":"Chat a Operativas oficina","timestamp":"2021-02-23T12:12:09.008Z"},'
        +'{"type":4,"text":"Chat a Incidencias Técnicas y Telefonía","timestamp":"2021-02-23T12:12:09.009Z"},{"type":4,"text":"Chat a Seguros","timestamp":"2021-02-23T12:12:09.009Z"},{"type":4,"text":'
        +'"Chat a Operativas oficina","timestamp":"2021-02-23T12:12:12.238Z"}],"revision":"NO","centro":"05579","dan":"09768","dt":"09098","badClassifications":[],"agents":["WATSON"],"conversationID":"2102230000474561",'
        +'"currentID":164626624,"aplicacionCorpus":"CC_OFICINAS_CSI","idioma":"es","idiomaDetectado":[],"errors":["DOCS:Neocsi"],"datos":[{"userTextOriginal":"seguros","userTextObfuscate":"seguros","identifiedObjects":[]},'
        +'{"userTextOriginal":"como dar de alta una llave","userTextObfuscate":"como dar de alta una llave","identifiedObjects":[]}],"prioritaria":"NO","perfil":"","idGlobalList":["195","195"],"pilotaje":["DEFAULT"],'
        +'"segmento":"BANKIA","canal":"CC_OFICINAS","entorno":"RUNTIME"}';
        
        return cognChat;
    }
}