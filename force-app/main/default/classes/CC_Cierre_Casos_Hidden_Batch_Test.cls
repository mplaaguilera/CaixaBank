@istest
public with sharing class CC_Cierre_Casos_Hidden_Batch_Test {
	@istest
    public static void test() {   
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App Imagin';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
		//'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
                
        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Chat';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'App';
		caso.CC_MCC_ProdServ__c = prod.Id;
        caso.CC_MCC_Tematica__c = tem.Id;
        caso.CC_Tipo_ChatTranscript__c = 'Agente';
        insert caso;               
        
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta 999';        
        insert cuenta;        
        
        Id accountId = cuenta.Id;
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '999';      	
        contacto.AccountId = cuenta.Id;
        insert contacto;
                
        LiveChatVisitor chatVisitor = new LiveChatVisitor();
		insert chatVisitor;  
        
        LiveChatTranscript chattrue = new LiveChatTranscript();
        chattrue.CaseId = caso.Id;
        chattrue.Status = 'Completed';
        chattrue.CC_Tipo__c = 'Hidden';
        chattrue.AccountId = cuenta.Id;
        chattrue.CC_Idioma__c = 'es';
        chattrue.CC_Cognitive_chat__c= '{"user": "U0137298", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Como_puedo_dar_de_alta_una_Servicuenta", "confidence": 0.8238105773925781 }, {"id": "Como_dar_de_alta_una_servicuenta_si_no_tengo_un_deposito_de_ahorro", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Operativa_de_Reintegros_Stop_go_", "confidence": 0.23751013278961183 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&#191;C&#243;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["es"], "errors": [] }';
        chattrue.LiveChatVisitorId= chatVisitor.Id;
        insert chattrue;
                
        Test.StartTest();
        CC_Cierre_Casos_Hidden_Batch batch = new CC_Cierre_Casos_Hidden_Batch();
		Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @istest
    public static void test2() {   
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App Imagin';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
		//'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
                
        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Chat';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'App';
		caso.CC_MCC_ProdServ__c = prod.Id;
        caso.CC_MCC_Tematica__c = tem.Id;
        caso.CC_Tipo_ChatTranscript__c = 'Hidden';
        insert caso;               
        
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta 999';        
        insert cuenta;        
        
        Id accountId = cuenta.Id;
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '999';      	
        contacto.AccountId = cuenta.Id;
        insert contacto;
                
        LiveChatVisitor chatVisitor = new LiveChatVisitor();
		insert chatVisitor;  
        
        LiveChatTranscript chattrue = new LiveChatTranscript();
        chattrue.CaseId = caso.Id;
        chattrue.Status = 'Missed';
        chattrue.CC_Tipo__c = 'Hidden';
        chattrue.AccountId = cuenta.Id;
        chattrue.CC_Idioma__c = 'es';
        chattrue.CC_Cognitive_chat__c= '{"user": "U0137298", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Como_puedo_dar_de_alta_una_Servicuenta", "confidence": 0.8238105773925781 }, {"id": "Como_dar_de_alta_una_servicuenta_si_no_tengo_un_deposito_de_ahorro", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Operativa_de_Reintegros_Stop_go_", "confidence": 0.23751013278961183 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&#191;C&#243;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["es"], "errors": [] }';
        chattrue.LiveChatVisitorId= chatVisitor.Id;
        insert chattrue;
                
        Test.StartTest();
        CC_Cierre_Casos_Hidden_Batch batch = new CC_Cierre_Casos_Hidden_Batch();
		Database.executeBatch(batch);
        Test.stopTest();
    }

}