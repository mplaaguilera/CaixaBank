@isTest
public with sharing class CC_ChatHistory_Controller_Test {

    @isTest
    static void test() {
        //Preparación de datos de prueba
        Case caso = new Case();
        caso.Origin = 'Chat';
        caso.CC_Canal_Procedencia__c = 'App';
        insert caso;
        
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;

        LiveChatTranscript chatBot = new LiveChatTranscript(
            CC_Tipo__c = 'ChatBot',
            CC_Bienvenida__c = false, 
            CC_Nickname__c = 'Nick N.', 
            CC_Idioma__c = 'ca',
            LiveChatVisitorId = liveChatVisitor.Id,
            CaseId = caso.Id,
            CC_Cognitive_chat__c = [SELECT Body FROM StaticResource WHERE Name = 'JSON_COGN_CHAT' LIMIT 1].Body.toString()
        );
        insert chatBot;

        Task actividadBot = new Task(
            WhatId = caso.Id,
            CC_LiveChatTranscript_Id__c = chatBot.Id
        );
        insert actividadBot;

        List<String> html = new List<String>();
        html.add('Chat Started: Friday, April 12, 2019, 13:41:39 (+0200)');
        html.add('Chat Origin: Chat');
        html.add('Agent Noelia M');
        html.add('( 51s ) Noelia M: Hola Nickname_XXXX, em dic Noelia i t\'ajudaré amb la teva consulta.');
        html.add('( 53s ) Noelia M: <auto>FAQ enviada: Com puc fer una eurotransferència?');
        html.add('Pots fer una eurotransferència des de Comptes > Internacional > Transferències > Eurotransferències bàsiques en euros.');
        html.add('( 1m 22s ) Noelia M: <auto>FAQ enviada: Quins costos té sol·licitar un talonari?');
        html.add('Per a saber quins costos té un talonari ens has d\'inidicar el tipus de talonari.');
        html.add('( 1m 46s ) Noelia M: <auto>FAQ enviada: Com puc fer una eurotransferència?');
        html.add('Pots fer una eurotransferència des de Comptes > Internacional > Transferències > Eurotransferències bàsiques en euros.');

        LiveChatTranscript chatAgente = new LiveChatTranscript(
            CC_Tipo__c = 'Agente',
            CC_Bienvenida__c = false,
            CC_Nickname__c = 'Nick N.',
            CC_Idioma__c = 'ca',
            LiveChatVisitorId = liveChatVisitor.Id,
            CaseId = caso.Id,
            CC_Cognitive_chat__c = [SELECT Body FROM StaticResource WHERE Name = 'JSON_COGN_CHAT' LIMIT 1].Body.toString(),
            Body = String.join(html, '\n')
        );
        insert chatAgente;
        
        Task actividadAgente = new Task(
            WhatId = caso.Id,
            CC_LiveChatTranscript_Id__c = chatAgente.Id
        );
        insert actividadAgente;

        LiveChatTranscript chatAgenteSinTranscripcion = new LiveChatTranscript(
            CC_Tipo__c = 'Agente',
            CC_Bienvenida__c = false,
            CC_Nickname__c = 'Nick N.',
            CC_Idioma__c = 'ca',
            LiveChatVisitorId = liveChatVisitor.Id,
            CaseId = caso.Id,
            CC_Cognitive_chat__c = [SELECT Body FROM StaticResource WHERE Name = 'JSON_COGN_CHAT' LIMIT 1].Body.toString()
            //Body sin informar para probar el caso de transcripción no disponible
        );
        insert chatAgenteSinTranscripcion;

        Task actividadAgenteSinTranscripcion = new Task(
            WhatId = caso.Id,
            CC_LiveChatTranscript_Id__c = chatAgenteSinTranscripcion.Id
        );
        insert actividadAgenteSinTranscripcion;
        //Fin de la preparación de datos de prueba

        //Ejecución de las pruebas
        Test.startTest();
        //Recuperar histórico de conversación a partir del caso creado
        List<CC_LiveAgent_Cognitive_Chat_Model> chatsCaso = CC_ChatHistory_Controller.getHistoryChat(caso.Id);

        //Recuperar histórico de conversación a partir del caso creado
        List<CC_LiveAgent_Cognitive_Chat_Model> chatsActividad = CC_ChatHistory_Controller.getHistoryChat(chatBot.Id);

        //Recuperar histórico de conversación a partir del caso creado
        List<CC_LiveAgent_Cognitive_Chat_Model> chatsTranscripcion = CC_ChatHistory_Controller.getHistoryChat(chatAgenteSinTranscripcion.Id);
        
        
        //Recuperar histórico de conversación a partir del caso creado
        List<CC_LiveAgent_Cognitive_Chat_Model> chatsTranscripcionCognitivo = CC_ChatHistory_Controller.getHistoryChat(chatAgenteSinTranscripcion.Id, true);
        
        
        //Recuperar histórico de conversación a partir del caso creado
        Boolean chatsTranscripcionVacio = CC_ChatHistory_Controller.getVacio(chatAgenteSinTranscripcion.Id, true);
        
         //Recuperar histórico de conversación whatsapp a partir del caso creado
        CC_LiveAgent_Cognitive_Chat_Model chatsTranscripcionWhatsapp = CC_ChatHistory_Controller.getChatWhatsappContext(chatAgenteSinTranscripcion);

        
        Test.stopTest();

        //Deben existir los 3 chats insertados + los 2 creados automáticamente por el trigger al insertar chats de tipo agente.
        System.assertEquals(3, chatsCaso.size()); //5
        System.assertEquals(1, chatsActividad.size());//5
        System.assertEquals(1, chatsTranscripcion.size());//5
    }
}