@isTest(seeAllData=true)      
public class CC_Encuestas_Chat_Test {    
    
    
	@isTest
    static void encuestaChatTest() {
        CC_Lista_Valores__c chatEncuesta = new CC_Lista_Valores__c();
        chatEncuesta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        chatEncuesta.CC_Activa__c = true;
        chatEncuesta.Name = 'CC_Encuestas_Satisfaccion_Chat_Empleados';
        insert chatEncuesta;
        
        CC_Lista_Valores__c procedenciaActivo = new CC_Lista_Valores__c();
        procedenciaActivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        procedenciaActivo.CC_Activa__c = true;
        procedenciaActivo.CC_Lista__c = chatEncuesta.Id;
        procedenciaActivo.Name = 'Activo';
        procedenciaActivo.CC_Valor__c = 'Activo';
        procedenciaActivo.CC_Valor2__c = 'Empleado';
        insert procedenciaActivo;     
        
        Account cuenta = new Account(Name='cuenta', RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank'));
        insert cuenta;
        
        Contact contacto = new Contact(LastName='contacto', RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado'), AccountId=cuenta.Id, CC_Num_Empleado__c = 'U011234');
        insert contacto;
        
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            CC_CaseOrigin__c = 'Chat',
            CC_Bienvenida__c = false,
            CC_Nickname__c = 'Cliente 1',
            CC_Idioma__c = 'es',
            LiveChatVisitorId = liveChatVisitor.Id,
            //CC_NumPerso__c = '10559714',
            //CC_NumPerso2__c = '10559714',
            CC_Tipo__c = 'Hidden',
            CC_Cognitive_chat__c='{"user": "U011234", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Como_puedo_dar_de_alta_una_Servicuenta", "confidence": 0.8238105773925781 }, {"id": "Como_dar_de_alta_una_servicuenta_si_no_tengo_un_deposito_de_ahorro", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Operativa_de_Reintegros_Stop_go_", "confidence": 0.23751013278961183 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&iquest;C&oacute;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["es"], "errors": [] }',            CC_Id_Cognitive__c='test01',
            CC_NumEmpleado__c = 'U011234',
            AccountId = cuenta.Id,
            ContactId = contacto.Id
        );
        insert liveChatTranscript;
        
        Case caso = new Case(RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado'), AccountId=cuenta.Id, 
                             ContactId=contacto.Id, Status='Activo', CC_Canal_Procedencia__c = 'Activo', Origin = 'Chat');
        insert caso;
        
        liveChatTranscript.CC_Canal_Procedencia__c = 'Web';
        liveChatTranscript.CC_Tipo__c = 'Agente';
        liveChatTranscript.CaseId = caso.Id;
        update liveChatTranscript;      
        
        Test.startTest();        
        System.assertEquals(1, [SELECT Count() FROM SurveySubject WHERE SubjectId = :caso.Id], 'Debe haber una encuesta relacionada con el chat');
        Test.stopTest();   
    }
    
    
    
    @isTest
    static void procedenciaDesactivadaTest() {
        CC_Lista_Valores__c chatEncuesta = new CC_Lista_Valores__c();
        chatEncuesta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        chatEncuesta.CC_Activa__c = true;
        chatEncuesta.Name = 'CC_Encuestas_Satisfaccion_Chat_Empleados';
        insert chatEncuesta;
        
        CC_Lista_Valores__c procedenciaWeb = new CC_Lista_Valores__c();
        procedenciaWeb.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        procedenciaWeb.CC_Activa__c = false;
        procedenciaWeb.CC_Lista__c = chatEncuesta.Id;
        procedenciaWeb.Name = 'Web';
        procedenciaWeb.CC_Valor__c = 'Web';
        procedenciaWeb.CC_Valor2__c = 'Empleado';
        insert procedenciaWeb;     
        
        Account cuenta = new Account(Name='cuenta', RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank'));
        insert cuenta;
        
        Contact contacto = new Contact(LastName='contacto', RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado'), AccountId=cuenta.Id, CC_Num_Empleado__c = 'U011234');
        insert contacto;
        
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            CC_CaseOrigin__c = 'Chat',
            CC_Bienvenida__c = false,
            CC_Nickname__c = 'Cliente 1',
            CC_Idioma__c = 'es',
            LiveChatVisitorId = liveChatVisitor.Id,
            //CC_NumPerso__c = '10559714',
            //CC_NumPerso2__c = '10559714',
            CC_Tipo__c = 'Hidden',
            CC_Cognitive_chat__c='{"user": "U011234", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Como_puedo_dar_de_alta_una_Servicuenta", "confidence": 0.8238105773925781 }, {"id": "Como_dar_de_alta_una_servicuenta_si_no_tengo_un_deposito_de_ahorro", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Operativa_de_Reintegros_Stop_go_", "confidence": 0.23751013278961183 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&iquest;C&oacute;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["es"], "errors": [] }',            CC_Id_Cognitive__c='test01',
            CC_NumEmpleado__c = 'U011234',
            AccountId = cuenta.Id,
            ContactId = contacto.Id
        );
        insert liveChatTranscript;
        
        Case caso = new Case(RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado'), AccountId=cuenta.Id, 
                             ContactId=contacto.Id, Status='Activo', CC_Canal_Procedencia__c = 'Web', Origin = 'Chat');
        insert caso;
        
        liveChatTranscript.CC_Canal_Procedencia__c = 'Web';
        liveChatTranscript.CC_Tipo__c = 'Agente';        
        liveChatTranscript.CaseId = caso.Id;
        update liveChatTranscript;      
        
        Test.startTest();        
        	System.assertEquals(NULL, [SELECT CC_URL_Encuesta_3N__c FROM Case WHERE Id = :liveChatTranscript.CaseId].CC_URL_Encuesta_3N__c, 'No se tiene que generar la encuesta porque la procedencia está desactivada, si falla mirar lista de valores');
        	System.assertEquals(0, [SELECT Count() FROM SurveySubject WHERE SubjectId = :caso.Id], 'No debe haber una encuesta relacionada con el chat');
        Test.stopTest();   
    }
    
    
    @isTest
    static void clienteTest() {
        CC_Lista_Valores__c chatEncuestaweb = new CC_Lista_Valores__c();
        chatEncuestaweb.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        chatEncuestaweb.CC_Activa__c = true;
        chatEncuestaweb.Name = 'CC_Encuestas_Satisfaccion_Chat_Clientes';
        insert chatEncuestaweb;
        
        CC_Lista_Valores__c procedenciawebc = new CC_Lista_Valores__c();
        procedenciawebc.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        procedenciawebc.CC_Activa__c = true;
        procedenciawebc.CC_Lista__c = chatEncuestaweb.Id;
        procedenciawebc.Name = 'Web';
        procedenciawebc.CC_Valor__c = 'Web';
        procedenciawebc.CC_Valor2__c = 'Cliente';
        insert procedenciawebc;     
          
        Account cuenta = new Account(Name='cuenta', RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente'));
        insert cuenta;
        
        Contact contacto = new Contact(LastName='contacto', RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente'), AccountId=cuenta.Id, CC_Num_Empleado__c = 'U011234');
        insert contacto;
        
        LiveChatVisitor liveChatVisitorWeb = new LiveChatVisitor();
        insert liveChatVisitorWeb;
        LiveChatTranscript liveChatTranscriptWeb = new LiveChatTranscript(
            CC_CaseOrigin__c = 'Chat',
            CC_Bienvenida__c = false,
            CC_Nickname__c = 'Cliente 1',
            CC_Idioma__c = 'es',
            LiveChatVisitorId = liveChatVisitorWeb.Id,
            CC_Tipo__c = 'Hidden',
            CC_Cognitive_chat__c='{"user": "U011234", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Como_puedo_dar_de_alta_una_Servicuenta", "confidence": 0.8238105773925781 }, {"id": "Como_dar_de_alta_una_servicuenta_si_no_tengo_un_deposito_de_ahorro", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Operativa_de_Reintegros_Stop_go_", "confidence": 0.23751013278961183 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&iquest;C&oacute;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["es"], "errors": [] }',            
            CC_Id_Cognitive__c='test01'
        );
        insert liveChatTranscriptWeb;
        
        Case caso = new Case(RecordTypeId=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente'), AccountId=cuenta.Id, 
                             ContactId=contacto.Id, Status='Activo', CC_Canal_Procedencia__c = 'Web', Origin = 'Chat');
        insert caso;
        
        liveChatTranscriptWeb.CC_Canal_Procedencia__c = 'Web';
        liveChatTranscriptWeb.CC_Tipo__c = 'Agente';
        liveChatTranscriptWeb.CaseId = caso.Id;
        update liveChatTranscriptWeb;      
        
        Test.startTest();        
        	System.assertEquals(1, [SELECT Count() FROM SurveySubject WHERE SubjectId = :caso.Id], 'Debe haber una encuesta relacionada con el chat');
        Test.stopTest();   
    }
    
}