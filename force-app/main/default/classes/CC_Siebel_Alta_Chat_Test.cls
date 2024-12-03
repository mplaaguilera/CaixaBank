@isTest
public class CC_Siebel_Alta_Chat_Test {
	
    @testSetup
    static void testSetup(){
        //Required fields are missing: [EmailEncodingKey]
        User oUser = new User();
        oUser.Alias = 'prueba';
        oUser.Username = 'pruebaName@test.com';
        oUser.LastName = 'pruebaLastName';
        oUser.Email = 'prueba@test.com';
		oUser.CommunityNickname = 'pruebaName12234654';
        oUser.FederationIdentifier = 'U0198765';
        oUser.TimeZoneSidKey = 'Europe/Paris';
        oUser.LocaleSidKey = 'en_US';
        oUser.ProfileId = userinfo.getProfileId();
        oUser.LanguageLocaleKey = 'en_US';
        oUser.EmailEncodingKey = 'UTF-8';
        oUser.EmployeeNumber = 'U0198765';
        insert oUser;
        
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
                
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            CC_Bienvenida__c = false, 
            CC_Nickname__c = 'Cliente 1', 
            CC_Idioma__c = 'es',
            LiveChatVisitorId = liveChatVisitor.Id,
            CaseId = caso.Id
        );
        liveChatTranscript.CC_Espacio__c = 'liniaObertaWSLOE';
        liveChatTranscript.CC_Categoria__c = 'lObertaPrueba';
        liveChatTranscript.CC_Aplicacion__c = 'LiniaObertaApp';
        insert liveChatTranscript;
        
        Id recordCat = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Categoria').getRecordTypeId();
        CC_FAQ__c cat = new CC_FAQ__c();
        cat.RecordTypeId = recordCat;
        cat.CC_Id_Categoria__c = '13830021';
        cat.Name = 'lObertaPrueba';
        cat.CC_Descripcion_es__c = 'Linea Abierta Prueba';
        cat.CC_Topic__c = 'lObertaPrueba';
        insert cat;
        
        Id recordEsp = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
        CC_FAQ__c esp = new CC_FAQ__c();
        esp.RecordTypeId = recordEsp;
        esp.CC_Id_Espacio__c = '15000000';
        esp.Name = 'liniaObertaWSLOE';
        esp.CC_Descripcion_es__c = 'Línea Abierta de LOE';
        esp.CC_Descripcion_ca__c = 'Línia Oberta de LOE';
        insert esp;
        
        Id recordApp = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Aplicaciones').getRecordTypeId();
        CC_FAQ__c app = new CC_FAQ__c();
        app.RecordTypeId = recordApp;
        app.CC_Id_App__c = '7';
        app.Name = 'LiniaObertaApp';
        app.CC_Aplicacion_Siebel__c = 'WEB';
        app.CC_Origen__c = 'Web';
        app.CC_Nombre__c = 'LiniaObertaApp';
        insert app;
    }
    
    @isTest 
    static void testgetFederationId() {
        Id oUser = [SELECT Id FROM User WHERE Username = 'pruebaName@test.com'].Id; 
        String matricula = CC_Siebel_Alta_Chat.getFederationId(oUser);
        System.assertEquals(matricula, 'U0198765');
    }
    
    @isTest 
    static void testgetDatosChat() {
        //List<LiveChatTranscript> listNewObj = new List<LiveChatTranscript>();
        Id listNewObj = [SELECT Id FROM LiveChatTranscript LIMIT 1].Id;
        Set<ID> oID = new Set<ID>();
        oID.add(listNewObj);
                
        List<LiveChatTranscript> result = new List<LiveChatTranscript>();
        result = CC_Siebel_Alta_Chat.getDatosChat(oID);
        System.assertEquals(result.size(), 1);
    }
    
    //CC_Siebel_Alta_Chat
    @isTest
    static void testCC_Siebel_Alta_Chat() {
        Test.startTest();
        
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        Case caso = new Case();
        caso.Subject = 'Test01';
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
        
        List<Case> o1 = [SELECT Id FROM Case WHERE Subject = 'Test01'];
        System.assertEquals(o1.size(), 1);
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            CC_Bienvenida__c = false, 
            CC_Nickname__c = 'Cliente 1', 
            CC_Idioma__c = 'es',
            LiveChatVisitorId = liveChatVisitor.Id,
            CaseId = caso.Id
        );
        liveChatTranscript.CC_Espacio__c = 'liniaObertaWSLOEP';
        liveChatTranscript.CC_Categoria__c = 'LineaAbiertaLOEP';
        liveChatTranscript.CC_Aplicacion__c = 'LiniaObertaAppP';
        liveChatTranscript.CC_Id_Cognitive__c = 'TESTCOGNI01';
        liveChatTranscript.CC_IdiomaCV__c = 'es';
        liveChatTranscript.CC_NumPerso__c = '12345679';
        liveChatTranscript.CC_Cognitive_chat__c = '{"user":"12345678Z","startTime":"2019-04-12T07:08:02.986Z","duration":1555052882986,"iterations":3,"reformulations":0,"areas":["liniaObertaWSLOE"],"userQuery":["agent"],"conversationUnits":[{"type":4,"text":"Si vols que t\u0027ajudi en alguna cosa més, estaré aquí.","timestamp":"2019-04-12T07:07:27.461Z"},{"type":60,"text":"1","timestamp":"2019-04-12T07:08:02.986Z"},{"type":1,"text":"agent","timestamp":"2019-04-12T07:08:02.986Z","auto":false},{"type":5,"text":"agent","timestamp":"2019-04-12T07:08:02.986Z"},{"type":13,"results":[{"id":"liniaObertaWSLOE","confidence":0.0076428107}],"timestamp":"2019-04-12T07:08:09.868Z"},{"type":17,"text":"agente","timestamp":"2019-04-12T07:08:09.869Z"},{"type":23,"text":"agente","timestamp":"2019-04-12T07:08:09.869Z"},{"type":8,"text":"liniaObertaWSLOE","timestamp":"2019-04-12T07:08:09.869Z"},{"type":3,"results":[{"id":"_Como_contacto_con_un_agente_","confidence":0.3105816450430382},{"id":"Como_puedes_personalizar_una_tarjeta_de_CaixaBank","confidence":0.11570915986160984},{"id":"Como_puedes_abrir_una_nueva_cuenta_corriente","confidence":0.11277258477325633},{"id":"Como_puedes_gestionar_una_reclamacion","confidence":0.11273339930590609},{"id":"Cuanto_tarda_una_transferencia_urgente_via_Banco_de_Espana","confidence":0.10811385051827571},{"id":"Operativa_Internacional_en_banca_digital_CaixaBankNow","confidence":0.1060823451158111},{"id":"Como_puedes_acceder_a_CardBox","confidence":0.10528949263564125},{"id":"Como_puedes_modificar_el_identificador_de_acceso_a_nuestra_banca_digital_CaixaBankNow","confidence":0.1044845547979758},{"id":"Como_puedes_pagar_impuestos_y_multas_municipales","confidence":0.10409508212876412},{"id":"Que_debes_hacer_si_tu_tarjeta_de_CaixaBank_esta_a_punto_de_caducar","confidence":0.10402346376996086}],"timestamp":"2019-04-12T07:08:09.869Z"},{"type":63,"results":[{"id":"_Como_contacto_con_un_agente_","confidence":0.3105816450430382}],"timestamp":"2019-04-12T07:08:09.869Z"},{"type":64,"text":"_Como_contacto_con_un_agente_","timestamp":"2019-04-12T07:08:11.587Z"},{"type":10,"text":"Et podem posar en contacte amb un dels nostres agents perquè t\u0027ajudi a resoldre el teu dubte. Vols que ho fem?\u003cBR/\u003e\u003cli\u003eSí\u003c/li\u003e\u003cli\u003eNo\u003c/li\u003e","timestamp":"2019-04-12T07:08:11.590Z"},{"type":5,"text":"Sí","timestamp":"2019-04-12T07:08:17.534Z"},{"type":64,"text":"_Como_contacto_con_un_agente_","timestamp":"2019-04-12T07:08:18.158Z"},{"type":10,"text":"T\u0027estem posant en contacte amb un dels nostres agents. Espera uns segons.\u003cBR/\u003e","timestamp":"2019-04-12T07:08:18.159Z"},{"type":4,"text":"Xat a Línia Oberta","timestamp":"2019-04-12T07:08:18.159Z"},{"type":4,"text":"Espera uns segons. Un dels nostres agents de Línia Oberta es posarà en contacte amb tu per resoldre els teus dubtes.","timestamp":"2019-04-12T07:08:20.898Z"}],"revision":"NO","centro":"00000","badClassifications":[],"agents":["WATSON"],"aplicacionOrigen":"","conversationID":"12345678Z_88755682","currentID":88755682,"aplicacionCorpus":"LiniaObertaApp","idioma":"ca","idiomasDetectados":["ca","err"],"errors":[],"datos":[{"userTextOriginal":"agent","userTextObfuscate":"agent","identifiedObjects":[]}],"prioritaria":"NO"}';
        liveChatTranscript.CC_Tipo__c = 'Agente';
        insert liveChatTranscript;
        
        List<LiveChatTranscript> o2 = [SELECT Id FROM LiveChatTranscript WHERE CC_Id_Cognitive__c = 'TESTCOGNI01' AND CC_Tipo__c = 'Agente'];
        System.assertEquals(o2.size(), 1);
        
        Id recordEsp = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
        CC_FAQ__c esp = new CC_FAQ__c();
        esp.RecordTypeId = recordEsp;
        esp.CC_Id_Espacio__c = '15000000';
        esp.Name = 'liniaObertaWSLOEP';
        esp.CC_Descripcion_es__c = 'Línea Abierta de LOE';
        esp.CC_Descripcion_ca__c = 'Línia Oberta de LOE';
        insert esp;
        
        List<CC_FAQ__c> o3 = [SELECT Id FROM CC_FAQ__c WHERE Name = 'liniaObertaWSLOEP'];
        System.assertEquals(o3.size(), 1);
        
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
        
        List<CC_FAQ__c> o4 = [SELECT Id FROM CC_FAQ__c WHERE Name = 'LineaAbiertaLOEP'];
        System.assertEquals(o4.size(), 1);
        
        Id recordApp = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Aplicaciones').getRecordTypeId();
        CC_FAQ__c app = new CC_FAQ__c();
        app.RecordTypeId = recordApp;
        app.CC_Id_App__c = '7';
        app.Name = 'LiniaObertaAppP';
        app.CC_Aplicacion_Siebel__c = 'WEB';
        app.CC_Origen__c = 'Web';
        app.CC_Nombre__c = 'LiniaObertaAppP';
        insert app;
        
        List<CC_FAQ__c> o5 = [SELECT Id FROM CC_FAQ__c WHERE Name = 'LiniaObertaAppP'];
        System.assertEquals(o5.size(), 1);
        
        Set<Id> oAlta = new Set<Id>();
        LiveChatTranscript lct = [SELECT Id, CC_Categoria__c, CC_Espacio__c 
                                                 FROM LiveChatTranscript WHERE CC_Espacio__c = 'liniaObertaWSLOEP' LIMIT 1];
		oAlta.add(lct.Id);
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_SBLALTA());
        CC_Siebel_Alta_Chat.CC_Siebel_Alta_Chat(oAlta);
        Test.stopTest();
    }
    
    //getEspacioCategoria
    /*@isTest 
    static void testgetEspacioCategoria() {
        Set<String> oCat = new Set<String>();
        LiveChatTranscript liveChatTranscript = [SELECT Id, CC_Categoria__c, CC_Espacio__c 
                                                 FROM LiveChatTranscript WHERE CC_Espacio__c = 'liniaObertaWSLOE'];
       oCat.add(liveChatTranscript.CC_Categoria__c);
       // Recuperar los códigos de espacios y categorías y appSiebel.
       Map<String,String> oMap = CC_Siebel_Alta_Chat.getEspacioCategoria(oCat);
       
        
    }
    //getAppSiebel
	@isTest 
    static void testgetAppSiebel() {
        Set<String> oApp = new Set<String>();
        LiveChatTranscript liveChatTranscript = [SELECT Id, CC_Categoria__c, CC_Espacio__c, CC_Aplicacion__c 
                                                 FROM LiveChatTranscript WHERE CC_Espacio__c = 'liniaObertaWSLOE'];
        oApp.add(liveChatTranscript.CC_Aplicacion__c);
        Map<String,String> oMapApp = CC_Siebel_Alta_Chat.getAppSiebel(oApp);
    }*/
	//CC_Siebel_Fin_Chat
	@isTest
    static void testCC_Siebel_Fin_Chat() {
        
        Test.startTest();
        
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        Case caso = new Case();
        caso.Subject = 'Test01';
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
        
        List<Case> o1 = [SELECT Id FROM Case WHERE Subject = 'Test01'];
        System.assertEquals(o1.size(), 1);
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            CC_Bienvenida__c = false, 
            CC_Nickname__c = 'Cliente 1', 
            CC_Idioma__c = 'es',
            LiveChatVisitorId = liveChatVisitor.Id,
            CaseId = caso.Id
        );
        liveChatTranscript.CC_Espacio__c = 'liniaObertaWSLOEP';
        liveChatTranscript.CC_Categoria__c = 'LineaAbiertaLOEP';
        liveChatTranscript.CC_Aplicacion__c = 'LiniaObertaAppP';
        liveChatTranscript.CC_Id_Cognitive__c = 'TESTCOGNI02';
        liveChatTranscript.CC_IdiomaCV__c = 'es';
        liveChatTranscript.CC_NumPerso__c = '12345679';
        liveChatTranscript.CC_SRId__c = '2-QW32QE';
        liveChatTranscript.CC_UltFaqSiebel__c = '123905';
        liveChatTranscript.CC_Cognitive_chat__c = '{"user":"12345678Z","startTime":"2019-04-12T07:08:02.986Z","duration":1555052882986,"iterations":3,"reformulations":0,"areas":["liniaObertaWSLOE"],"userQuery":["agent"],"conversationUnits":[{"type":4,"text":"Si vols que t\u0027ajudi en alguna cosa més, estaré aquí.","timestamp":"2019-04-12T07:07:27.461Z"},{"type":60,"text":"1","timestamp":"2019-04-12T07:08:02.986Z"},{"type":1,"text":"agent","timestamp":"2019-04-12T07:08:02.986Z","auto":false},{"type":5,"text":"agent","timestamp":"2019-04-12T07:08:02.986Z"},{"type":13,"results":[{"id":"liniaObertaWSLOE","confidence":0.0076428107}],"timestamp":"2019-04-12T07:08:09.868Z"},{"type":17,"text":"agente","timestamp":"2019-04-12T07:08:09.869Z"},{"type":23,"text":"agente","timestamp":"2019-04-12T07:08:09.869Z"},{"type":8,"text":"liniaObertaWSLOE","timestamp":"2019-04-12T07:08:09.869Z"},{"type":3,"results":[{"id":"_Como_contacto_con_un_agente_","confidence":0.3105816450430382},{"id":"Como_puedes_personalizar_una_tarjeta_de_CaixaBank","confidence":0.11570915986160984},{"id":"Como_puedes_abrir_una_nueva_cuenta_corriente","confidence":0.11277258477325633},{"id":"Como_puedes_gestionar_una_reclamacion","confidence":0.11273339930590609},{"id":"Cuanto_tarda_una_transferencia_urgente_via_Banco_de_Espana","confidence":0.10811385051827571},{"id":"Operativa_Internacional_en_banca_digital_CaixaBankNow","confidence":0.1060823451158111},{"id":"Como_puedes_acceder_a_CardBox","confidence":0.10528949263564125},{"id":"Como_puedes_modificar_el_identificador_de_acceso_a_nuestra_banca_digital_CaixaBankNow","confidence":0.1044845547979758},{"id":"Como_puedes_pagar_impuestos_y_multas_municipales","confidence":0.10409508212876412},{"id":"Que_debes_hacer_si_tu_tarjeta_de_CaixaBank_esta_a_punto_de_caducar","confidence":0.10402346376996086}],"timestamp":"2019-04-12T07:08:09.869Z"},{"type":63,"results":[{"id":"_Como_contacto_con_un_agente_","confidence":0.3105816450430382}],"timestamp":"2019-04-12T07:08:09.869Z"},{"type":64,"text":"_Como_contacto_con_un_agente_","timestamp":"2019-04-12T07:08:11.587Z"},{"type":10,"text":"Et podem posar en contacte amb un dels nostres agents perquè t\u0027ajudi a resoldre el teu dubte. Vols que ho fem?\u003cBR/\u003e\u003cli\u003eSí\u003c/li\u003e\u003cli\u003eNo\u003c/li\u003e","timestamp":"2019-04-12T07:08:11.590Z"},{"type":5,"text":"Sí","timestamp":"2019-04-12T07:08:17.534Z"},{"type":64,"text":"_Como_contacto_con_un_agente_","timestamp":"2019-04-12T07:08:18.158Z"},{"type":10,"text":"T\u0027estem posant en contacte amb un dels nostres agents. Espera uns segons.\u003cBR/\u003e","timestamp":"2019-04-12T07:08:18.159Z"},{"type":4,"text":"Xat a Línia Oberta","timestamp":"2019-04-12T07:08:18.159Z"},{"type":4,"text":"Espera uns segons. Un dels nostres agents de Línia Oberta es posarà en contacte amb tu per resoldre els teus dubtes.","timestamp":"2019-04-12T07:08:20.898Z"}],"revision":"NO","centro":"00000","badClassifications":[],"agents":["WATSON"],"aplicacionOrigen":"","conversationID":"12345678Z_88755682","currentID":88755682,"aplicacionCorpus":"LiniaObertaApp","idioma":"ca","idiomasDetectados":["ca","err"],"errors":[],"datos":[{"userTextOriginal":"agent","userTextObfuscate":"agent","identifiedObjects":[]}],"prioritaria":"NO"}';
        liveChatTranscript.CC_Tipo__c = 'Agente';
        insert liveChatTranscript;
        
        List<LiveChatTranscript> o2 = [SELECT Id FROM LiveChatTranscript WHERE CC_Id_Cognitive__c = 'TESTCOGNI02' AND CC_Tipo__c = 'Agente'];
        System.assertEquals(o2.size(), 1);
        
        Id recordEsp = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
        CC_FAQ__c esp = new CC_FAQ__c();
        esp.RecordTypeId = recordEsp;
        esp.CC_Id_Espacio__c = '15000000';
        esp.Name = 'liniaObertaWSLOEP';
        esp.CC_Descripcion_es__c = 'Línea Abierta de LOE';
        esp.CC_Descripcion_ca__c = 'Línia Oberta de LOE';
        insert esp;
        
        List<CC_FAQ__c> o3 = [SELECT Id FROM CC_FAQ__c WHERE Name = 'liniaObertaWSLOEP'];
        System.assertEquals(o3.size(), 1);
        
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
        
        List<CC_FAQ__c> o4 = [SELECT Id FROM CC_FAQ__c WHERE Name = 'LineaAbiertaLOEP'];
        System.assertEquals(o4.size(), 1);
        
        Id recordApp = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Aplicaciones').getRecordTypeId();
        CC_FAQ__c app = new CC_FAQ__c();
        app.RecordTypeId = recordApp;
        app.CC_Id_App__c = '7';
        app.Name = 'LiniaObertaAppP';
        app.CC_Aplicacion_Siebel__c = 'WEB';
        app.CC_Origen__c = 'Web';
        app.CC_Nombre__c = 'LiniaObertaAppP';
        insert app;
        
        List<CC_FAQ__c> o5 = [SELECT Id FROM CC_FAQ__c WHERE Name = 'LiniaObertaAppP'];
        System.assertEquals(o5.size(), 1);
        
        Set<Id> oAlta = new Set<Id>();
        LiveChatTranscript lct = [SELECT Id, CC_Categoria__c, CC_Espacio__c 
                                                 FROM LiveChatTranscript WHERE CC_SRId__c =: '2-QW32QE' LIMIT 1];
		oAlta.add(lct.Id);
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_SBLFIN_HTTP_01());
        
        CC_Siebel_Alta_Chat.CC_Siebel_Fin_Chat(oAlta);
        
        Test.stopTest();
    }
    
	@isTest
    static void testCC_Siebel_Fin_Chat_ERROR() {
        
        Test.startTest();
        
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        Case caso = new Case();
        caso.Subject = 'Test01';
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
        
        List<Case> o1 = [SELECT Id FROM Case WHERE Subject = 'Test01'];
        System.assertEquals(o1.size(), 1);
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            CC_Bienvenida__c = false, 
            CC_Nickname__c = 'Cliente 1', 
            CC_Idioma__c = 'es',
            LiveChatVisitorId = liveChatVisitor.Id,
            CaseId = caso.Id
        );
        liveChatTranscript.CC_Espacio__c = 'liniaObertaWSLOEP';
        liveChatTranscript.CC_Categoria__c = 'LineaAbiertaLOEP';
        liveChatTranscript.CC_Aplicacion__c = 'LiniaObertaAppP';
        liveChatTranscript.CC_Id_Cognitive__c = 'TESTCOGNI03';
        liveChatTranscript.CC_IdiomaCV__c = 'es';
        liveChatTranscript.CC_NumPerso__c = '12345679';
        liveChatTranscript.CC_SRId__c = '2-QW32QE';
        liveChatTranscript.CC_UltFaqSiebel__c = '123905';
        liveChatTranscript.CC_Cognitive_chat__c = '{"user":"12345678Z","startTime":"2019-04-12T07:08:02.986Z","duration":1555052882986,"iterations":3,"reformulations":0,"areas":["liniaObertaWSLOE"],"userQuery":["agent"],"conversationUnits":[{"type":4,"text":"Si vols que t\u0027ajudi en alguna cosa més, estaré aquí.","timestamp":"2019-04-12T07:07:27.461Z"},{"type":60,"text":"1","timestamp":"2019-04-12T07:08:02.986Z"},{"type":1,"text":"agent","timestamp":"2019-04-12T07:08:02.986Z","auto":false},{"type":5,"text":"agent","timestamp":"2019-04-12T07:08:02.986Z"},{"type":13,"results":[{"id":"liniaObertaWSLOE","confidence":0.0076428107}],"timestamp":"2019-04-12T07:08:09.868Z"},{"type":17,"text":"agente","timestamp":"2019-04-12T07:08:09.869Z"},{"type":23,"text":"agente","timestamp":"2019-04-12T07:08:09.869Z"},{"type":8,"text":"liniaObertaWSLOE","timestamp":"2019-04-12T07:08:09.869Z"},{"type":3,"results":[{"id":"_Como_contacto_con_un_agente_","confidence":0.3105816450430382},{"id":"Como_puedes_personalizar_una_tarjeta_de_CaixaBank","confidence":0.11570915986160984},{"id":"Como_puedes_abrir_una_nueva_cuenta_corriente","confidence":0.11277258477325633},{"id":"Como_puedes_gestionar_una_reclamacion","confidence":0.11273339930590609},{"id":"Cuanto_tarda_una_transferencia_urgente_via_Banco_de_Espana","confidence":0.10811385051827571},{"id":"Operativa_Internacional_en_banca_digital_CaixaBankNow","confidence":0.1060823451158111},{"id":"Como_puedes_acceder_a_CardBox","confidence":0.10528949263564125},{"id":"Como_puedes_modificar_el_identificador_de_acceso_a_nuestra_banca_digital_CaixaBankNow","confidence":0.1044845547979758},{"id":"Como_puedes_pagar_impuestos_y_multas_municipales","confidence":0.10409508212876412},{"id":"Que_debes_hacer_si_tu_tarjeta_de_CaixaBank_esta_a_punto_de_caducar","confidence":0.10402346376996086}],"timestamp":"2019-04-12T07:08:09.869Z"},{"type":63,"results":[{"id":"_Como_contacto_con_un_agente_","confidence":0.3105816450430382}],"timestamp":"2019-04-12T07:08:09.869Z"},{"type":64,"text":"_Como_contacto_con_un_agente_","timestamp":"2019-04-12T07:08:11.587Z"},{"type":10,"text":"Et podem posar en contacte amb un dels nostres agents perquè t\u0027ajudi a resoldre el teu dubte. Vols que ho fem?\u003cBR/\u003e\u003cli\u003eSí\u003c/li\u003e\u003cli\u003eNo\u003c/li\u003e","timestamp":"2019-04-12T07:08:11.590Z"},{"type":5,"text":"Sí","timestamp":"2019-04-12T07:08:17.534Z"},{"type":64,"text":"_Como_contacto_con_un_agente_","timestamp":"2019-04-12T07:08:18.158Z"},{"type":10,"text":"T\u0027estem posant en contacte amb un dels nostres agents. Espera uns segons.\u003cBR/\u003e","timestamp":"2019-04-12T07:08:18.159Z"},{"type":4,"text":"Xat a Línia Oberta","timestamp":"2019-04-12T07:08:18.159Z"},{"type":4,"text":"Espera uns segons. Un dels nostres agents de Línia Oberta es posarà en contacte amb tu per resoldre els teus dubtes.","timestamp":"2019-04-12T07:08:20.898Z"}],"revision":"NO","centro":"00000","badClassifications":[],"agents":["WATSON"],"aplicacionOrigen":"","conversationID":"12345678Z_88755682","currentID":88755682,"aplicacionCorpus":"LiniaObertaApp","idioma":"ca","idiomasDetectados":["ca","err"],"errors":[],"datos":[{"userTextOriginal":"agent","userTextObfuscate":"agent","identifiedObjects":[]}],"prioritaria":"NO"}';
        liveChatTranscript.CC_Tipo__c = 'Agente';
        insert liveChatTranscript;
        List<LiveChatTranscript> o2 = [SELECT Id FROM LiveChatTranscript WHERE CC_Id_Cognitive__c = 'TESTCOGNI03' AND CC_Tipo__c = 'Agente'];
        System.assertEquals(o2.size(), 1);
        
        Id recordEsp = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
        CC_FAQ__c esp = new CC_FAQ__c();
        esp.RecordTypeId = recordEsp;
        esp.CC_Id_Espacio__c = '15000000';
        esp.Name = 'liniaObertaWSLOEP';
        esp.CC_Descripcion_es__c = 'Línea Abierta de LOE';
        esp.CC_Descripcion_ca__c = 'Línia Oberta de LOE';
        insert esp;
        
        List<CC_FAQ__c> o3 = [SELECT Id FROM CC_FAQ__c WHERE Name = 'liniaObertaWSLOEP'];
        System.assertEquals(o3.size(), 1);
        
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
        
        List<CC_FAQ__c> o4 = [SELECT Id FROM CC_FAQ__c WHERE Name = 'LineaAbiertaLOEP'];
        System.assertEquals(o4.size(), 1);
        
        Id recordApp = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Aplicaciones').getRecordTypeId();
        CC_FAQ__c app = new CC_FAQ__c();
        app.RecordTypeId = recordApp;
        app.CC_Id_App__c = '7';
        app.Name = 'LiniaObertaAppP';
        app.CC_Aplicacion_Siebel__c = 'WEB';
        app.CC_Origen__c = 'Web';
        app.CC_Nombre__c = 'LiniaObertaAppP';
        insert app;
        
        List<CC_FAQ__c> o5 = [SELECT Id FROM CC_FAQ__c WHERE Name = 'LiniaObertaAppP'];
        System.assertEquals(o5.size(), 1);
        
        Set<Id> oAlta = new Set<Id>();
        LiveChatTranscript lct = [SELECT Id, CC_Categoria__c, CC_Espacio__c 
                                                 FROM LiveChatTranscript WHERE CC_SRId__c =: '2-QW32QE' LIMIT 1];
		oAlta.add(lct.Id);
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_SBLFIN_HTTP_02());
        
        CC_Siebel_Alta_Chat.CC_Siebel_Fin_Chat(oAlta);
        
        Test.stopTest();
    }
    
    @isTest
    static void envioAltaChatSiebel() {
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        Case caso = new Case();
        caso.Subject = 'Test01';
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
        
        List<Case> o1 = [SELECT Id FROM Case WHERE Subject = 'Test01'];
        System.assertEquals(o1.size(), 1);
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            CC_Bienvenida__c = false, 
            CC_Nickname__c = 'Cliente 1', 
            CC_Idioma__c = 'es',
            LiveChatVisitorId = liveChatVisitor.Id,
            CaseId = caso.Id
        );
        liveChatTranscript.CC_Espacio__c = 'liniaObertaWSLOEP';
        liveChatTranscript.CC_Categoria__c = 'LineaAbiertaLOEP';
        liveChatTranscript.CC_Aplicacion__c = 'LiniaObertaAppP';
        liveChatTranscript.CC_Id_Cognitive__c = 'TESTCOGNI01';
        liveChatTranscript.CC_IdiomaCV__c = 'es';
        liveChatTranscript.CC_NumPerso__c = '12345679';
        liveChatTranscript.CC_Cognitive_chat__c = '{"user":"12345678Z","startTime":"2019-04-12T07:08:02.986Z","duration":1555052882986,"iterations":3,"reformulations":0,"areas":["liniaObertaWSLOE"],"userQuery":["agent"],"conversationUnits":[{"type":4,"text":"Si vols que t\u0027ajudi en alguna cosa més, estaré aquí.","timestamp":"2019-04-12T07:07:27.461Z"},{"type":60,"text":"1","timestamp":"2019-04-12T07:08:02.986Z"},{"type":1,"text":"agent","timestamp":"2019-04-12T07:08:02.986Z","auto":false},{"type":5,"text":"agent","timestamp":"2019-04-12T07:08:02.986Z"},{"type":13,"results":[{"id":"liniaObertaWSLOE","confidence":0.0076428107}],"timestamp":"2019-04-12T07:08:09.868Z"},{"type":17,"text":"agente","timestamp":"2019-04-12T07:08:09.869Z"},{"type":23,"text":"agente","timestamp":"2019-04-12T07:08:09.869Z"},{"type":8,"text":"liniaObertaWSLOE","timestamp":"2019-04-12T07:08:09.869Z"},{"type":3,"results":[{"id":"_Como_contacto_con_un_agente_","confidence":0.3105816450430382},{"id":"Como_puedes_personalizar_una_tarjeta_de_CaixaBank","confidence":0.11570915986160984},{"id":"Como_puedes_abrir_una_nueva_cuenta_corriente","confidence":0.11277258477325633},{"id":"Como_puedes_gestionar_una_reclamacion","confidence":0.11273339930590609},{"id":"Cuanto_tarda_una_transferencia_urgente_via_Banco_de_Espana","confidence":0.10811385051827571},{"id":"Operativa_Internacional_en_banca_digital_CaixaBankNow","confidence":0.1060823451158111},{"id":"Como_puedes_acceder_a_CardBox","confidence":0.10528949263564125},{"id":"Como_puedes_modificar_el_identificador_de_acceso_a_nuestra_banca_digital_CaixaBankNow","confidence":0.1044845547979758},{"id":"Como_puedes_pagar_impuestos_y_multas_municipales","confidence":0.10409508212876412},{"id":"Que_debes_hacer_si_tu_tarjeta_de_CaixaBank_esta_a_punto_de_caducar","confidence":0.10402346376996086}],"timestamp":"2019-04-12T07:08:09.869Z"},{"type":63,"results":[{"id":"_Como_contacto_con_un_agente_","confidence":0.3105816450430382}],"timestamp":"2019-04-12T07:08:09.869Z"},{"type":64,"text":"_Como_contacto_con_un_agente_","timestamp":"2019-04-12T07:08:11.587Z"},{"type":10,"text":"Et podem posar en contacte amb un dels nostres agents perquè t\u0027ajudi a resoldre el teu dubte. Vols que ho fem?\u003cBR/\u003e\u003cli\u003eSí\u003c/li\u003e\u003cli\u003eNo\u003c/li\u003e","timestamp":"2019-04-12T07:08:11.590Z"},{"type":5,"text":"Sí","timestamp":"2019-04-12T07:08:17.534Z"},{"type":64,"text":"_Como_contacto_con_un_agente_","timestamp":"2019-04-12T07:08:18.158Z"},{"type":10,"text":"T\u0027estem posant en contacte amb un dels nostres agents. Espera uns segons.\u003cBR/\u003e","timestamp":"2019-04-12T07:08:18.159Z"},{"type":4,"text":"Xat a Línia Oberta","timestamp":"2019-04-12T07:08:18.159Z"},{"type":4,"text":"Espera uns segons. Un dels nostres agents de Línia Oberta es posarà en contacte amb tu per resoldre els teus dubtes.","timestamp":"2019-04-12T07:08:20.898Z"}],"revision":"NO","centro":"00000","badClassifications":[],"agents":["WATSON"],"aplicacionOrigen":"","conversationID":"12345678Z_88755682","currentID":88755682,"aplicacionCorpus":"LiniaObertaApp","idioma":"ca","idiomasDetectados":["ca","err"],"errors":[],"datos":[{"userTextOriginal":"agent","userTextObfuscate":"agent","identifiedObjects":[]}],"prioritaria":"NO"}';
        liveChatTranscript.CC_Tipo__c = 'Agente';
        insert liveChatTranscript;
        
        List<LiveChatTranscript> o2 = [SELECT Id FROM LiveChatTranscript WHERE CC_Id_Cognitive__c = 'TESTCOGNI01' AND CC_Tipo__c = 'Agente'];
        System.assertEquals(o2.size(), 1);
        
        Id recordEsp = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
        CC_FAQ__c esp = new CC_FAQ__c();
        esp.RecordTypeId = recordEsp;
        esp.CC_Id_Espacio__c = '15000000';
        esp.Name = 'liniaObertaWSLOEP';
        esp.CC_Descripcion_es__c = 'Línea Abierta de LOE';
        esp.CC_Descripcion_ca__c = 'Línia Oberta de LOE';
        insert esp;
        
        List<CC_FAQ__c> o3 = [SELECT Id FROM CC_FAQ__c WHERE Name = 'liniaObertaWSLOEP'];
        System.assertEquals(o3.size(), 1);
        
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
        
        List<CC_FAQ__c> o4 = [SELECT Id FROM CC_FAQ__c WHERE Name = 'LineaAbiertaLOEP'];
        System.assertEquals(o4.size(), 1);
        
        Id recordApp = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Aplicaciones').getRecordTypeId();
        CC_FAQ__c app = new CC_FAQ__c();
        app.RecordTypeId = recordApp;
        app.CC_Id_App__c = '7';
        app.Name = 'LiniaObertaAppP';
        app.CC_Aplicacion_Siebel__c = 'WEB';
        app.CC_Origen__c = 'Web';
        app.CC_Nombre__c = 'LiniaObertaAppP';
        insert app;
        
        List<CC_FAQ__c> o5 = [SELECT Id FROM CC_FAQ__c WHERE Name = 'LiniaObertaAppP'];
        System.assertEquals(o5.size(), 1);
        
        List<ID> Listlct = new List<ID>();
        LiveChatTranscript lct = [SELECT Id, CC_Categoria__c, CC_Espacio__c 
                                                 FROM LiveChatTranscript WHERE CC_Espacio__c = 'liniaObertaWSLOEP' LIMIT 1];
        Listlct.add(lct.Id);
        CC_Siebel_Alta_Chat.envioAltaChatSiebel(Listlct);
    }
    
}