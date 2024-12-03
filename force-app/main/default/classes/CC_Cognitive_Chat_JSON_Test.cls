@isTest
public class CC_Cognitive_Chat_JSON_Test {

    @isTest
    public static void testFormateaDatetime(){
        Datetime newDate = Datetime.newInstance(2021, 3, 29, 11, 30, 15);
        String formateaDate;
        
        String JSONContent = '{"user":"Pedro","startTime":"2019-02-28T11:50:17.923Z", "duration":12345, "iterations":1, "reformulations":1, "areas":["casa"], "userQuery":["home"], "conversationUnits":[{"type":5,"text":"Mensaje de prueba", "timestamp":"2019-02-28T11:50:17.923Z", "results":[{"id":"12345", "confidence":10.23}],"id":"123456789", "auto":true}] ,"revision":"revision", "centro":"centro", "badClassifications":"", "agents":["agente"],  "aplicacionOrigen":"Chat", "conversationID":"123456789", "currentID":123456789, "aplicacionCorpus":"web", "idioma":"castellano", "idiomasDetectados":["ingles","castellano"], "errors":["error1"], "perfil":"bueno", "idGlobalList":["123456789"], "pilotaje":["piloto"]}';
		JSONParser parser = JSON.createParser(JSONContent);

        Test.startTest();
        CC_Cognitive_Chat_JSON  res = new CC_Cognitive_Chat_JSON(parser);
        formateaDate = res.formateaDatetime(newDate);
        Test.stopTest();
        
        System.assertEquals('Monday, March 29, 2021, 11:30:15', formateaDate, 'El cambio de fecha no es correcto');
    }
    
    @isTest
    public static void testTimestamp(){
        String JSONContent = '{"user":"Pedro","startTime":"2019-02-28T11:50:17.923Z", "duration":12345, "iterations":1, "reformulations":1, "areas":["casa"], "userQuery":["home"], "conversationUnits":[{"type":5,"text":"Mensaje de prueba", "timestamp":"2019-02-28T11:50:17.923Z", "results":[{"id":"12345", "confidence":10.23}],"id":"123456789", "auto":true}] ,"revision":"revision", "centro":"centro", "badClassifications":"", "agents":["agente"],  "aplicacionOrigen":"Chat", "conversationID":"123456789", "currentID":123456789, "aplicacionCorpus":"web", "idioma":"castellano", "idiomasDetectados":["ingles","castellano"], "errors":["error1"], "perfil":"bueno", "idGlobalList":["123456789"], "pilotaje":["piloto"]}';
		JSONParser parser = JSON.createParser(JSONContent);
        String newTimestamp = '2019-02-28T11:50:17.923Z';
        Datetime newDate;
        Datetime expectedDate = Datetime.newInstance(2019, 2, 28, 11, 50, 17);
        expectedDate = Datetime.valueOfGmt(newTimestamp.replace('T', ' ').substringBefore('.'));
        
        Test.startTest();
        CC_Cognitive_Chat_JSON  res = new CC_Cognitive_Chat_JSON(parser);
        newDate = res.timestampToDatetime(newTimestamp);
        Test.stopTest();
        
        System.assertEquals(expectedDate, newDate, newDate);
    }  

    @isTest
    public static void testConversationUnits(){
              
        //Create JSONParser knickname 'Cliente'
        String JSONContentCliente = '{"type":5,"text":"Mensaje de prueba", "timestamp":"2019-02-28T11:50:17.923Z", "results":[{"id":"12345", "confidence":10.23}],"id":"123456789", "auto":true}';
		JSONParser parserCliente = JSON.createParser(JSONContentCliente);   
        
        //Create JSONParser knickname 'ChatbotAgente'
        String JSONContentAgente = '{"type":15,"text":"Mensaje de prueba", "timestamp":"2019-02-28T11:50:17.923Z", "id":"123456789", "auto":true}';
		JSONParser parserAgente = JSON.createParser(JSONContentAgente);
        
        //Create JSONParser knickname 'ChatbotHidden'
        String JSONContentHidden = '{"type":14,"text":"Mensaje de prueba", "timestamp":"2019-02-28T11:50:17.923Z", "id":"123456789", "auto":true}';
		JSONParser parserHidden = JSON.createParser(JSONContentHidden);
        
        //Incorrect JSON Parser
        String JSONContent = '{"hola":1234}';
		JSONParser IncorrectParser = JSON.createParser(JSONContent);
              
        
        Test.startTest();
        CC_Cognitive_Chat_JSON.ConversationUnits converCliente = new CC_Cognitive_Chat_JSON.ConversationUnits(parserCliente);
        CC_Cognitive_Chat_JSON.ConversationUnits converAgente = new CC_Cognitive_Chat_JSON.ConversationUnits(parserAgente);
        CC_Cognitive_Chat_JSON.ConversationUnits converHidden = new CC_Cognitive_Chat_JSON.ConversationUnits(parserHidden);
        CC_Cognitive_Chat_JSON.ConversationUnits incorrectConver = new CC_Cognitive_Chat_JSON.ConversationUnits(IncorrectParser);
        Test.stopTest();
        
        //Correct JSON parser
        System.assertEquals('Cliente', converCliente.nickname, 'No se detecta bien el tipo_Z');
        System.assertEquals('ChatbotAgente', converAgente.nickname, 'No se detecta bien el tipo_Z');
        System.assertEquals('ChatbotHidden', converHidden.nickname, 'No se detecta bien el tipo_Z');
        System.assertEquals('Mensaje de prueba', converCliente.text, 'No se guarda bien el mensaje');
        System.assertEquals('2019-02-28T11:50:17.923Z', converAgente.timestamp, 'No se guarda bien el timestamp');
        System.assertEquals('123456789', converHidden.id, 'No se guarda bien el id');
        System.assertEquals(true, converCliente.auto, 'No se guarda bien el auto');
        System.assertEquals('12345', converCliente.results[0].id, 'El id de results no se guarda bien');
        System.assertEquals(10.23, converCliente.results[0].confidence, 'El confidence de results no se guarda bien');  
    }
    
    @isTest
    public static void testResults(){
        //Correct JSON Parser
        String JSONContent = '{"id":"123456789","confidence":10.23}';
		JSONParser parser = JSON.createParser(JSONContent);
        
        //Incorrect JSON Parser
        String JSONContentIncorrect = '{"hola":1234}';
		JSONParser IncorrectParser = JSON.createParser(JSONContentIncorrect);
        
        
        Test.startTest();
        CC_Cognitive_Chat_JSON.Results res = new CC_Cognitive_Chat_JSON.Results(parser);
        CC_Cognitive_Chat_JSON.Results resInc = new CC_Cognitive_Chat_JSON.Results(IncorrectParser);
        Test.stopTest();
        
        
        System.assertEquals('123456789', res.id, 'El id no se guarda bien');
        System.assertEquals(10.23, res.confidence, 'El confidence no lo guarda bien');

    }
    
    @isTest
    public static void testCC_Cognitive_Chat_JSON(){
        //String JSONContent = '{"user":"Pedro","startTime":"2019-02-28T11:50:17.923Z", "duration":12345, "iterations":1, "reformulations":1, "areas":["casa"], "userQuery":{"home"}, "revision":"revision", "centro":"centro", "badClassifications":"", "agents":"agentes", "aplicacionOrigen":"Chat", "conversationID":"123456789", "currentID":"123456789", "aplicacionCorpus":"web", "idioma":"castellano", "idiomasDetectados":"ingles", "errors":"ninguno", "perfil":"bueno", "idGlobalList":"12345", "pilotaje":"piloto"}';
		
        String JSONContent = '{"user":"Pedro","startTime":"2019-02-28T11:50:17.923Z", "duration":12345, "iterations":1, "reformulations":1, "areas":["casa"], "userQuery":["home"], "conversationUnits":[{"type":5,"text":"Mensaje de prueba", "timestamp":"2019-02-28T11:50:17.923Z", "results":[{"id":"12345", "confidence":10.23}],"id":"123456789", "auto":true}] ,"revision":"revision", "centro":"centro", "badClassifications":"", "agents":["agente"],  "aplicacionOrigen":"Chat", "conversationID":"123456789", "currentID":123456789, "aplicacionCorpus":"web", "idioma":"castellano", "idiomasDetectados":["ingles","castellano"], "errors":["error1"], "perfil":"bueno", "idGlobalList":["123456789"], "pilotaje":["piloto"],"sourceConversationID":"34625791388_226572751","sourceAplicacionCorpus":"NoaWhatsapp"}';
        //String JSONContent = '{"user":"Pedro","startTime":"2019-02-28T11:50:17.923Z", "duration":12345, "iterations":1, "reformulations":1, "areas":["casa"], "userQuery":["home"], "conversationUnits":[{"type":5,"text":"Mensaje de prueba", "timestamp":"2019-02-28T11:50:17.923Z", "results":[{"id":"12345", "confidence":10.23}],"id":"123456789", "auto":true}] ,"revision":"revision", "centro":"centro", "badClassifications":"", "agents":["agente"],  "aplicacionOrigen":"Chat", "conversationID":"123456789", "currentID":123456789, "aplicacionCorpus":"web", "idioma":"castellano", "idiomasDetectados":["ingles","castellano"], "errors":["error1"], "perfil":"bueno", "idGlobalList":["123456789"], "pilotaje":["piloto"]}';
		JSONParser parser = JSON.createParser(JSONContent);
        
        Test.startTest();
        CC_Cognitive_Chat_JSON  res = new CC_Cognitive_Chat_JSON(parser);
        Test.stopTest();
        
        System.assertEquals('Pedro', res.user, 'El usuario no se guarda bien');
        System.assertEquals('2019-02-28T11:50:17.923Z', res.startTime, 'La fecha no se guarda bien');
        DateTime fechaEsperada = Datetime.newInstance(2019, 2, 28, 12, 50, 17);
        System.assertEquals(fechaEsperada, res.fechaInicio, 'La fecha no se traspasa bien');
        System.assertEquals(12345, res.duration, 'La duracion no se guarda bien');
        System.assertEquals(1, res.iterations, 'Las iteraciones no se guardan bien');
        System.assertEquals(1, res.reformulations, 'Las reformulaciones no se guardan bien');
        System.assertEquals('casa', res.areas[0], 'Las areas no se guardan bien');
        System.assertEquals('home', res.userQuery[0], 'Las userQuery no se guardan bien');
        System.assertEquals('Cliente', res.conversationUnits[0].nickname, 'Las conversationUnits no se guardan bien');
        System.assertEquals('revision', res.revision, 'La revision no se guarda bien');
        System.assertEquals('centro', res.centro, 'El centro no se guarda bien');
        System.assertEquals('agente', res.agents[0], 'Los agentes no se guardan bien');
        System.assertEquals('Chat', res.aplicacionOrigen, 'La aplicacion de origen no se guarda bien');
        System.assertEquals('123456789', res.conversationID, 'El conversationID no se guarda bien');
        System.assertEquals(123456789, res.currentID, 'El currentID no se guarda bien');
        System.assertEquals('web', res.aplicacionCorpus, 'La aplicacion corpus no se guarda bien');
        System.assertEquals('castellano', res.idioma, 'El idioma no se guarda bien');
        System.assertEquals('ingles', res.idiomasDetectados[0], 'Los idiomas no se guardan bien');
        System.assertEquals('castellano', res.idiomasDetectados[1], 'Los idiomas no se guardan bien');
        System.assertEquals('error1', res.errors[0], 'Los errores no se guardan bien');
        System.assertEquals('bueno', res.perfil, 'El perfil no se guarda bien');
        System.assertEquals('123456789', res.idGlobales[0], 'El idGlobales no se guarda bien');
        System.assertEquals('piloto', res.pilotaje[0], 'Los pilotajes no se guardan bien');
        
    }
    
    @isTest
    public static void testparse(){
        String JSONContent = '{"user":"Pedro","startTime":"2019-02-28T11:50:17.923Z", "duration":12345, "iterations":1, "reformulations":1, "revision":"revision", "centro":"centro", "badClassifications":"", "aplicacionOrigen":"Chat", "conversationID":"123456789", "currentID":123456789, "aplicacionCorpus":"web", "idioma":"castellano", "perfil":"bueno"}';
		JSONParser parser = JSON.createParser(JSONContent);
        
        Test.startTest();
        CC_Cognitive_Chat_JSON res = new CC_Cognitive_Chat_JSON(parser);
        CC_Cognitive_Chat_JSON methodResult = CC_Cognitive_Chat_JSON.parse(JSONContent);
        Test.stopTest();
        
        System.assertEquals('Pedro', methodResult.user, 'El usuario no se guarda bien');
        System.assertEquals('2019-02-28T11:50:17.923Z', methodResult.startTime, 'La fecha no se guarda bien');
        DateTime fechaEsperada = Datetime.newInstance(2019, 2, 28, 12, 50, 17);
        System.assertEquals(fechaEsperada, methodResult.fechaInicio, 'La fecha no se traspasa bien');
        System.assertEquals(12345, methodResult.duration, 'La duracion no se guarda bien');
        System.assertEquals(1, methodResult.iterations, 'Las iteraciones no se guardan bien');
        System.assertEquals(1, methodResult.reformulations, 'Las reformulaciones no se guardan bien');
        System.assertEquals('revision', methodResult.revision, 'La revision no se guarda bien');
        System.assertEquals('centro', methodResult.centro, 'El centro no se guarda bien');
        System.assertEquals('Chat', methodResult.aplicacionOrigen, 'La aplicacion de origen no se guarda bien');
        System.assertEquals('123456789', methodResult.conversationID, 'El conversationID no se guarda bien');
        System.assertEquals(123456789, methodResult.currentID, 'El currentID no se guarda bien');
        System.assertEquals('web', methodResult.aplicacionCorpus, 'La aplicacion corpus no se guarda bien');
        System.assertEquals('castellano', methodResult.idioma, 'El idioma no se guarda bien');
        System.assertEquals('bueno', methodResult.perfil, 'El currentID no se guarda bien');
    }
    
    @isTest
    public static void testArrays(){
        String JSONContent = '{"areas": ["casa","gato"]}';
		JSONParser parser = JSON.createParser(JSONContent);
        
        Test.startTest();
        CC_Cognitive_Chat_JSON  res = new CC_Cognitive_Chat_JSON(parser);
        Test.stopTest();
        
        System.assertEquals('casa', res.areas[0], 'Las areas no se guardan bien');
        System.assertEquals('gato', res.areas[1], 'Las areas no se guardan bien');
    }
    
    @isTest
    public static void testSegundosTranscurridos(){
        
        String segundos;
        String minutes;
        String noChanges; //Comprueba que si no hay un segundo de diferencia por lo menos no da ningún segundo transcurrido
        String noParameters;
        String noSeconds;
        
        Test.startTest();
        segundos = CC_Cognitive_Chat_JSON.segundosTranscurridos('2019-02-28T11:50:17.923Z', '2019-02-28T11:50:26.923Z');
        minutes = CC_Cognitive_Chat_JSON.segundosTranscurridos('2019-02-28T11:50:17.923Z', '2019-02-28T11:51:26.923Z');
        noChanges = CC_Cognitive_Chat_JSON.segundosTranscurridos('2019-02-28T11:50:17.923Z', '2019-02-28T11:50:17.947Z');
        noParameters = CC_Cognitive_Chat_JSON.segundosTranscurridos(null, null);
        noSeconds = CC_Cognitive_Chat_JSON.segundosTranscurridos('2019-02-28T11:50:17.923Z', '2019-02-28T11:50:16.947Z');
        Test.stopTest();
        
        System.assertEquals('9s', segundos, 'No se hace bien la conversión de segundos transcurridos');
        System.assertEquals('1 min 9s', minutes, 'Cuando hay más de 60s no hace bien la conversion');
        System.assertEquals('0s', noChanges, 'Cuando no hay ni un segundo de diferencia no hace bien la conversion');
        System.assertEquals('0', noParameters, 'Cuando los parámetros son nulos no hace bien la conversion');
        System.assertEquals('0s', noSeconds, 'Cuando los segundos que pasan son negativos no hace bien la conversion');
    }
    
    @isTest
    public static void testGetChatbotFaqs(){
        List<CC_Cognitive_Chat_JSON.Results> faqs = new List<CC_Cognitive_Chat_JSON.Results>();
        String JSONContent = '{"user":"Pedro","startTime":"2019-02-28T11:50:17.923Z", "duration":12345, "iterations":1, "reformulations":1, "areas":["casa"], "userQuery":["home"], "conversationUnits":[{"type":63,"text":"Mensaje de prueba", "timestamp":"2019-02-28T11:50:17.923Z", "results":[{"id":"12345", "confidence":10.23}],"id":"123456789", "auto":true}] ,"revision":"revision", "centro":"centro", "badClassifications":"", "agents":["agente"],  "aplicacionOrigen":"Chat", "conversationID":"123456789", "currentID":123456789, "aplicacionCorpus":"web", "idioma":"castellano", "idiomasDetectados":["ingles","castellano"], "errors":["error1"], "perfil":"bueno", "idGlobalList":["123456789"], "pilotaje":["piloto"]}';
		JSONParser parser = JSON.createParser(JSONContent);
        String JSONContentFaqs1 = '{"id":"12345","confidence":10.23}';
		JSONParser parserFaqs1 = JSON.createParser(JSONContentFaqs1);
    
        Test.startTest();
        CC_Cognitive_Chat_JSON.Results faqs1 = new CC_Cognitive_Chat_JSON.Results(parserFaqs1);
        CC_Cognitive_Chat_JSON  res = new CC_Cognitive_Chat_JSON(parser);
        faqs = res.getChatbotFaqs();
        Test.stopTest();
        
        System.assertEquals(faqs1.confidence, faqs[0].confidence, 'No se obtiene bien las faqs del Chatbot');
        System.assertEquals(faqs1.id, faqs[0].id, 'No se obtiene bien las faqs del Chatbot');
    }
    
    @isTest
    public static void testGetChatHTML(){
        String nicknameCliente = 'Cristina';
        
        //Cliente
        String JSONContentCliente = '{"user":"Pedro","startTime":"2019-02-28T11:50:17.923Z", "duration":12345, "iterations":1, "reformulations":1, "areas":["casa"], "userQuery":["home"], "conversationUnits":[{"type":5,"text":"Mensaje de prueba", "timestamp":"2019-02-28T11:50:17.923Z", "results":[{"id":"12345", "confidence":10.23}],"id":"123456789", "auto":true}] ,"revision":"revision", "centro":"centro", "badClassifications":"", "agents":["agente"],  "aplicacionOrigen":"Chat", "conversationID":"123456789", "currentID":123456789, "aplicacionCorpus":"web", "idioma":"castellano", "idiomasDetectados":["ingles","castellano"], "errors":["error1"], "perfil":"bueno", "idGlobalList":["123456789"], "pilotaje":["piloto"]}';
		JSONParser parserCliente = JSON.createParser(JSONContentCliente);
        String expectedCliente = '<p align="center">Chat iniciado: Thursday, February 28, 2019, 12:50:17</p>'+  
                           '\n<p align="center">Origen del chat: Chat</p>'+                                                                                                                      
                           '\n<p align="center">[Noa]</p>( 0s ) Cristina: Mensaje de prueba<br> ';
        //Chatbot
        String JSONContentChatbot = '{"user":"Pedro","startTime":"2019-02-28T11:50:17.923Z", "duration":12345, "iterations":1, "reformulations":1, "areas":["casa"], "userQuery":["home"], "conversationUnits":[{"type":15,"text":"Mensaje de prueba", "timestamp":"2019-02-28T11:50:17.923Z", "results":[{"id":"12345", "confidence":10.23}],"id":"123456789", "auto":true}] ,"revision":"revision", "centro":"centro", "badClassifications":"", "agents":["agente"],  "aplicacionOrigen":"Chat", "conversationID":"123456789", "currentID":123456789, "aplicacionCorpus":"web", "idioma":"castellano", "idiomasDetectados":["ingles","castellano"], "errors":["error1"], "perfil":"bueno", "idGlobalList":["123456789"], "pilotaje":["piloto"]}';
		JSONParser parserChatbot = JSON.createParser(JSONContentChatbot);
        String expectedChatbot = '<p align="center">Chat iniciado: Thursday, February 28, 2019, 12:50:17</p>'+  
                           '\n<p align="center">Origen del chat: Chat</p>'+                                                                                                                      
                           '\n<p align="center">[Noa]</p>( 0s ) [Noa]: Mensaje de prueba<br> ';
        //Chatbot Hidden
        String JSONContentHidden = '{"user":"Pedro","startTime":"2019-02-28T11:50:17.923Z", "duration":12345, "iterations":1, "reformulations":1, "areas":["casa"], "userQuery":["home"], "conversationUnits":[{"type":14,"text":"Mensaje de prueba", "timestamp":"2019-02-28T11:50:17.923Z", "results":[{"id":"12345", "confidence":10.23}],"id":"123456789", "auto":true}] ,"revision":"revision", "centro":"centro", "badClassifications":"", "agents":["agente"],  "aplicacionOrigen":"Chat", "conversationID":"123456789", "currentID":123456789, "aplicacionCorpus":"web", "idioma":"castellano", "idiomasDetectados":["ingles","castellano"], "errors":["error1"], "perfil":"bueno", "idGlobalList":["123456789"], "pilotaje":["piloto"]}';
		JSONParser parserHidden = JSON.createParser(JSONContentHidden);
        String expectedHidden = '<p align="center">Chat iniciado: Thursday, February 28, 2019, 12:50:17</p>'+  
                           '\n<p align="center">Origen del chat: Chat</p>'+                                                                                                                      
                           '\n<p align="center">[Noa]</p>( 0s ) [Hidden]: Mensaje de prueba<br> ';
        //Test
        Test.startTest();
        CC_Cognitive_Chat_JSON  nuevoCliente = new CC_Cognitive_Chat_JSON(parserCliente);
        String resultCliente = nuevoCliente.getChatHTML(nicknameCliente);
        CC_Cognitive_Chat_JSON  nuevoChatbot = new CC_Cognitive_Chat_JSON(parserChatbot);
        String resultChatbot = nuevoChatbot.getChatHTML(nicknameCliente);
        CC_Cognitive_Chat_JSON  nuevoHidden = new CC_Cognitive_Chat_JSON(parserHidden);
        String resultHidden = nuevoHidden.getChatHTML(nicknameCliente);
        Test.stopTest();
        
        System.assertEquals(expectedCliente, resultCliente, 'Se obtiene el chat cuando es cliente mal');
        System.assertEquals(expectedChatbot, resultChatbot,'Se obtiene el chat cuando es chatbot mal');
        System.assertEquals(expectedHidden, resultHidden, 'Se obtiene el chat cuando es chatbot Hidden mal');
    }
    
    @isTest
    public static void testGetConversacion() {
        String JSONContentCliente = '{"user":"Pedro","startTime":"2019-02-28T11:50:17.923Z", "duration":12345, "iterations":1, "reformulations":1, "areas":["casa"], "userQuery":["home"], "conversationUnits":[{"type":5,"text":"Mensaje de prueba", "timestamp":"2019-02-28T11:50:17.923Z", "results":[{"id":"12345", "confidence":10.23}],"id":"123456789", "auto":true}] ,"revision":"revision", "centro":"centro", "badClassifications":"", "agents":["agente"],  "aplicacionOrigen":"Chat", "conversationID":"123456789", "currentID":123456789, "aplicacionCorpus":"web", "idioma":"castellano", "idiomasDetectados":["ingles","castellano"], "errors":["error1"], "perfil":"bueno", "idGlobalList":["123456789"], "pilotaje":["piloto"]}';
		JSONParser parserCliente = JSON.createParser(JSONContentCliente);
        String JSONContentChatbot = '{"user":"Pedro","startTime":"2019-02-28T11:50:17.923Z", "duration":12345, "iterations":1, "reformulations":1, "areas":["casa"], "userQuery":["home"], "conversationUnits":[{"type":15,"text":"Mensaje de prueba", "timestamp":"2019-02-28T11:50:17.923Z", "results":[{"id":"12345", "confidence":10.23}],"id":"123456789", "auto":true}] ,"revision":"revision", "centro":"centro", "badClassifications":"", "agents":["agente"],  "aplicacionOrigen":"Chat", "conversationID":"123456789", "currentID":123456789, "aplicacionCorpus":"web", "idioma":"castellano", "idiomasDetectados":["ingles","castellano"], "errors":["error1"], "perfil":"bueno", "idGlobalList":["123456789"], "pilotaje":["piloto"]}';
		JSONParser parserChatbot = JSON.createParser(JSONContentChatbot);
        String nicknameCliente = 'Cristina';
        List<CC_LiveAgent_Cognitive_Chat_Model> chatListaEmpleados = new List<CC_LiveAgent_Cognitive_Chat_Model>();
        List<CC_LiveAgent_Cognitive_Chat_Model> chatListaClientes = new List<CC_LiveAgent_Cognitive_Chat_Model>();
        List<CC_LiveAgent_Cognitive_Chat_Model> chatListaChatbot = new List<CC_LiveAgent_Cognitive_Chat_Model>();
        
        Test.startTest();
        CC_Cognitive_Chat_JSON  nuevoCliente = new CC_Cognitive_Chat_JSON(parserCliente);
        CC_Cognitive_Chat_JSON  nuevoChatbot = new CC_Cognitive_Chat_JSON(parserChatbot);
        chatListaEmpleados = nuevoCliente.getConversacion(nicknameCliente, true, 'Empleados');
        chatListaClientes = nuevoCliente.getConversacion(nicknameCliente, false, 'Cliente');
        chatListaChatbot = nuevoChatbot.getConversacion(nicknameCliente, false, 'Cliente');
        Test.stopTest();
        
        System.assertEquals('Chat iniciado por el empleado el ', chatListaEmpleados[0].inicio, chatListaEmpleados[0].inicio);
        System.assertEquals('Chat traspasado a agente el ', chatListaEmpleados[0].fin, chatListaEmpleados[0].fin);
        System.assertEquals(nicknameCliente, chatListaEmpleados[0].mensajes[0].Nombre, chatListaEmpleados[0].mensajes[0].Nombre);
        System.assertEquals('Chat iniciado por el cliente el ', chatListaClientes[0].inicio, chatListaClientes[0].inicio);
        System.assertEquals('Chat finalizado por el cliente el ', chatListaClientes[0].fin, chatListaClientes[0].fin);
        System.assertEquals('[Noa]', chatListaChatbot[0].mensajes[0].Nombre, chatListaChatbot[0].mensajes[0].Nombre);
        
    }
}