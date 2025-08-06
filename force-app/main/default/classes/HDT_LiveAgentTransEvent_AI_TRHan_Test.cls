@isTest
public class HDT_LiveAgentTransEvent_AI_TRHan_Test {
    @TestSetup
    static void makeData(){
        //Cometario para que suba a COPADO
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
        relacion.Name = 'It';
        relacion.CC_Activa__c = true;
        relacion.CC_Valor__c = 'Conectividad';
        relacion.CC_Servicio__c = 'Servicio';
        relacion.CC_Orden__c = 1;
        relacion.CC_Lista__c = listaRelacionEspacioCategoriaServicio.Id;
        relacionEspacioCategoriaServicio.add(relacion);
        
        insert relacionEspacioCategoriaServicio;
        
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            CC_Bienvenida__c = false,
            RecordTypeId = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByDeveloperName().get('HDT_Empleados').getRecordTypeId(),
            CC_Nickname__c = 'Empleado HDT',
            CC_Idioma__c = 'es',
            CC_CaseOrigin__c = 'Chat',
            LiveChatVisitorId = liveChatVisitor.Id,
            CC_Id_Cognitive__c='testAIEventHDT',
            CC_Tipo__c = 'Agente',
            CC_Espacio__c = 'It',
            CC_Categoria__c = 'Conectividad',
            CC_Aplicacion__c = 'CC_OFICINAS',
            CC_NumEmpleado__c = 'U01A45E2',
            UserAgent = 'ChatdeempleadosHDT', 
            CC_Cognitive_chat__c='{"user": "U0137298", "startTime": "2018-09-06T07:15:30.194Z", "duration": 1536218130194, "iterations": 2, "reformulations": 0, "areas": ["Ahorro"], "userQuery": ["convertir en seervicuenta una cuenta que no es servicuenta"], "conversationUnits": [{"type": 4, "text": "Bienvenido. ¿En qué puedo ayudarte?", "timestamp": "2018-09-06T07:15:29.923Z"}, {"type": 2, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-0  9-06T07:15:30.194Z"}, {"type": 5, "text": "convertir en seervicuenta una cuenta que no es servicuenta", "timestamp": "2018-09-06T07:15:30.194Z"}, {"type": 8, "text": "Ahorro", "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 3, "results": [{"id": "Como_puedo_dar_de_alta_una_Servicuenta", "confidence": 0.8238105773925781 }, {"id": "Como_dar_de_alta_una_servicuenta_si_no_tengo_un_deposito_de_ahorro", "confidence": 0.3118317008018494 }, {"id": "Se_puede_cambiar_la_modalidad_de_una_Servicuenta", "confidence": 0.2550765454769135 }, {"id": "Digitalizacion_de_documentos_identificativos_de_No_clientes_en_Ingresos_en_Cuenta_Ajena", "confidence": 0.2510948121547699 }, {"id": "Que_tarjetas_puedo_vincular_a_una_servicuenta", "confidence": 0.24829841256141663 }, {"id": "Deseo_toda_la_informacion_sobre_Servicuentas_ahora", "confidence": 0.2416720747947693 }, {"id": "Por_que_no_reconoce_la_propuesta_de_inversion_al_realizar_la_contratacion_de_Productos_Estructurados", "confidence": 0.2384248733520508 }, {"id": "Operativa_de_Reintegros_Stop_go_", "confidence": 0.23751013278961183 }, {"id": "Cual_es_la_operativa_para_dar_de_baja_una_servicuenta", "confidence": 0.2371295839548111 }, {"id": "Como_senalizar_una_cuenta_para_que_no_tenga_remuneracion", "confidence": 0.23371837735176088 } ], "timestamp": "2018-09-06T07:15:31.957Z"}, {"type": 4, "text": "<p>&iquest;C&oacute;mo puedo dar de alta una Servicuenta?</p><BR/><BR>Por favor, selecciona la opción más adecuada:<BR/><li>¿Cómo dar de alta una servicuenta desde un depósito de ahorro?</li><li>¿Cómo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:31.960Z"}, {"type": 6, "text": "¿Cómo puedo dar de alta una Servicuenta?", "id": "Como_puedo_dar_de_alta_una_Servicuenta", "timestamp": "2018-09-06T07:  15:31.960Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:40.695Z"}, {"type": 4, "text": "He encontrado las siguientes respuestas<BR/><li>¿Có  mo dar de alta una servicuenta si no tengo un depósito de ahorro?</li><li>¿Se puede cambiar la modalidad de una Servicuenta?</li><li>Digitalizació   n de documentos identificativos de No clientes en Ingresos en Cuenta Ajena</li><li>Ninguna de las anteriores</li>", "timestamp": "2018-09-06T07:15:40.696Z"}, {"type": 5, "text": "Ninguna de las anteriores", "timestamp": "2018-09-06T07:15:48.657Z"} ], "revision": "NO", "centro": "09945", "badClassifications": [], "agents": ["WATSON"], "aplicacionOrigen": "Chat", "conversationID": "U0137298_61456930", "currentID": 61456930, "aplicacionCorpus": "CC_OFICINAS", "idioma": "ca", "idiomasDetectados": ["es"], "errors": [], "perfil":"bueno", "idGlobalList":["123456789"], "pilotaje":["piloto"],"sourceConversationID":"34625791388_226572751","sourceAplicacionCorpus":"NoaWhatsapp" }'
        );
        insert LiveChatTranscript;
        
        
    }
    @isTest
    static void testLeaveAgentWithTask(){    
        
        LiveChatTranscript liveChatTranscript  = [SELECT Id,RecordType.developername, CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c 
                                                  FROM LiveChatTranscript WHERE CC_Nickname__c = 'Empleado HDT'
                                                  AND CC_NumEmpleado__c = 'U01A45E2' AND CC_Tipo__c = 'Agente' ];        
        Task task = new Task();
        task.Status = 'Completed';
        task.Priority = 'Normal';
        task.WhatId = liveChatTranscript.CaseId;
        task.OwnerId = liveChatTranscript.OwnerId;
        task.CC_Categoria__c = liveChatTranscript.CC_Categoria__c;
        task.CC_Espacio__c = liveChatTranscript.CC_Espacio__c;
        task.CC_Chat_Cognitivo_Id__c = liveChatTranscript.CC_Id_Cognitive__c;
        task.CC_LiveChatTranscript_Id__c = liveChatTranscript.Id;
        task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
        task.Type = 'Fin';
        task.Subject = 'Chat finalizado por agente';
        
        insert task;
        
        LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
            Type = 'LeaveAgent',
            LiveChatTranscriptId = liveChatTranscript.Id,
            time = system.now()
        );
        Test.startTest();
        insert liveChatTranscriptEvent;
        Test.stopTest();
        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            List<Task> tasks = [SELECT Id, CreatedDate, recordtype.developername, subject  FROM Task WHERE CC_LiveChatTranscript_Id__c =: liveChatTranscript.Id AND Type =: 'Fin' order by createdDate asc];
            system.debug('NMAAA  tasks: '+tasks);
            System.assertEquals(tasks.size(),1);
            System.assertEquals(tasks.get(0).Id, task.Id);
        }
    }
    
    @isTest
    static void testLeaveAgentWithoutTask(){ 
        
        
        LiveChatTranscript liveChatTranscript  = [SELECT Id,RecordType.developername, CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c 
                                                  FROM LiveChatTranscript WHERE CC_Nickname__c = 'Empleado HDT'
                                                  AND CC_NumEmpleado__c = 'U01A45E2' AND CC_Tipo__c = 'Agente' ];        
        LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
            Type = 'LeaveAgent',
            LiveChatTranscriptId = liveChatTranscript.Id,
            time = system.now()
        );
        Test.startTest();
        insert liveChatTranscriptEvent;
        Test.stopTest();
         System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            List<Task> tasks = [SELECT Id FROM Task WHERE CC_LiveChatTranscript_Id__c =: liveChatTranscript.Id AND Type =: 'Fin'];
            
            System.assertEquals(tasks.size(),1);
        }
    }
    
    @isTest
    static void testEndAgentWithTask(){     
        
        LiveChatTranscript liveChatTranscript  = [SELECT Id,RecordType.developername, CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c 
                                                  FROM LiveChatTranscript WHERE CC_Nickname__c = 'Empleado HDT'
                                                  AND CC_NumEmpleado__c = 'U01A45E2' AND CC_Tipo__c = 'Agente' ];      
        Task task = new Task();
        task.Status = 'Completed';
        task.Priority = 'Normal';
        task.WhatId = liveChatTranscript.CaseId;
        task.OwnerId = liveChatTranscript.OwnerId;
        task.CC_Categoria__c = liveChatTranscript.CC_Categoria__c;
        task.CC_Espacio__c = liveChatTranscript.CC_Espacio__c;
        task.CC_Chat_Cognitivo_Id__c = liveChatTranscript.CC_Id_Cognitive__c;
        task.CC_LiveChatTranscript_Id__c = liveChatTranscript.Id;
        task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
        task.Type = 'Fin';
        task.Subject = 'Chat finalizado por agente';
        
        insert task;
        
        LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
            Type = 'EndAgent',
            LiveChatTranscriptId = liveChatTranscript.Id,
            time = system.now()
        );
        Test.startTest();
        insert liveChatTranscriptEvent;
        Test.stopTest();
         System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {   
            List<Task> tasks = [SELECT Id FROM Task WHERE CC_LiveChatTranscript_Id__c =: liveChatTranscript.Id AND Type =: 'Fin'];
            System.assertEquals(tasks.size(), 1);
            System.assertEquals(tasks.get(0).Id, task.Id);
        }
    }
    
    @isTest
    static void testEndAgentWithoutTask(){     
         
            LiveChatTranscript liveChatTranscript  = [SELECT Id,RecordTypeId, RecordType.developername, CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c 
                                                      FROM LiveChatTranscript WHERE CC_Nickname__c = 'Empleado HDT'
                                                      AND CC_NumEmpleado__c = 'U01A45E2' AND CC_Tipo__c = 'Agente' ]; 
            system.debug('liveChatTranscript: '+liveChatTranscript);
            LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
                Type = 'EndAgent',
                LiveChatTranscriptId = liveChatTranscript.Id,
                time = system.now()
            );
            Test.startTest();
            insert liveChatTranscriptEvent;
            Test.stopTest();
          System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {  
                List<Task> tasks = [SELECT Id FROM Task WHERE CC_LiveChatTranscript_Id__c =: liveChatTranscript.Id AND Type =: 'Fin'];
                System.assertEquals(tasks.size(), 1);
            }
        }
        
        @isTest
        static void testEndVisitorWithTask(){  
          
                LiveChatTranscript liveChatTranscript  = [SELECT Id,RecordType.developername, CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c 
                                                          FROM LiveChatTranscript WHERE CC_Nickname__c = 'Empleado HDT'
                                                          AND CC_NumEmpleado__c = 'U01A45E2' AND CC_Tipo__c = 'Agente' ];      
                Task task = new Task();
                task.Status = 'Completed';
                task.Priority = 'Normal';
                task.WhatId = liveChatTranscript.CaseId;
                task.OwnerId = liveChatTranscript.OwnerId;
                task.CC_Categoria__c = liveChatTranscript.CC_Categoria__c;
                task.CC_Espacio__c = liveChatTranscript.CC_Espacio__c;
                task.CC_Chat_Cognitivo_Id__c = liveChatTranscript.CC_Id_Cognitive__c;
                task.CC_LiveChatTranscript_Id__c = liveChatTranscript.Id;
                task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
                task.Type = 'Fin';  
                task.Subject = 'Chat finalizado por empleado';
                
                insert task;
                
                LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
                    Type = 'EndVisitor',
                    LiveChatTranscriptId = liveChatTranscript.Id,
                    time = system.now()
                );
                Test.startTest();
                insert liveChatTranscriptEvent;
                Test.stopTest();
                System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
                    List<Task> tasks = [SELECT Id FROM Task WHERE CC_LiveChatTranscript_Id__c =: liveChatTranscript.Id AND Type =: 'Fin'];
                    System.assertEquals(tasks.size(),1);
                    System.assertEquals(tasks.get(0).Id, task.Id);
                }
            }
            
            @isTest
            static void testEndVisitorWithoutTask(){   
                
                LiveChatTranscript liveChatTranscript  = [SELECT Id,RecordType.developername, CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c 
                                                          FROM LiveChatTranscript WHERE CC_Nickname__c = 'Empleado HDT'
                                                          AND CC_NumEmpleado__c = 'U01A45E2' AND CC_Tipo__c = 'Agente' ];        
                LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
                    Type = 'EndVisitor',
                    LiveChatTranscriptId = liveChatTranscript.Id,
                    time = system.now()
                );
                Test.startTest();
                insert liveChatTranscriptEvent;
                Test.stopTest();
                System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) { 
                    List<Task> tasks = [SELECT Id FROM Task WHERE CC_LiveChatTranscript_Id__c =: liveChatTranscript.Id AND Type =: 'Fin'];
                    System.assertEquals(tasks.size(), 1);
                }
            }
            
            @isTest
            static void testLeaveVisitorTask(){ 
                
                LiveChatTranscript liveChatTranscript  = [SELECT Id,RecordType.developername, CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c 
                                                          FROM LiveChatTranscript WHERE CC_Nickname__c = 'Empleado HDT'
                                                          AND CC_NumEmpleado__c = 'U01A45E2' AND CC_Tipo__c = 'Agente' ];      
                Task task = new Task();
                task.Status = 'Completed';
                task.Priority = 'Normal';
                task.WhatId = liveChatTranscript.CaseId;
                task.OwnerId = liveChatTranscript.OwnerId;
                task.CC_Categoria__c = liveChatTranscript.CC_Categoria__c;
                task.CC_Espacio__c = liveChatTranscript.CC_Espacio__c;
                task.CC_Chat_Cognitivo_Id__c = liveChatTranscript.CC_Id_Cognitive__c;
                task.CC_LiveChatTranscript_Id__c = liveChatTranscript.Id;
                task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
                task.Type = 'Fin';   
                task.Subject = 'Chat finalizado por empleado';
                
                insert task;
                
                LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
                    Type = 'LeaveVisitor',
                    LiveChatTranscriptId = liveChatTranscript.Id,
                    time = system.now()
                );
                Test.startTest();
                insert liveChatTranscriptEvent;
                Test.stopTest();
                System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) { 
                    List<Task> tasks = [SELECT Id FROM Task WHERE CC_LiveChatTranscript_Id__c =: liveChatTranscript.Id AND Type =: 'Fin'];
                    System.assertEquals(tasks.size(), 1);
                    System.assertEquals(tasks.get(0).Id, task.Id);
                }
            }
            
            @isTest
            static void testLeaveVisitorWithoutTask(){   
                
                LiveChatTranscript liveChatTranscript  = [SELECT Id,RecordType.developername, CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c 
                                                          FROM LiveChatTranscript WHERE CC_Nickname__c = 'Empleado HDT'
                                                          AND CC_NumEmpleado__c = 'U01A45E2' AND CC_Tipo__c = 'Agente' ];        
                LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
                    Type = 'LeaveVisitor',
                    LiveChatTranscriptId = liveChatTranscript.Id,
                    time = system.now()
                );
                Test.startTest();
                insert liveChatTranscriptEvent;
                Test.stopTest();
                System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) { 
                    List<Task> tasks = [SELECT Id FROM Task WHERE CC_LiveChatTranscript_Id__c =: liveChatTranscript.Id AND Type =: 'Fin'];
                    System.assertEquals(tasks.size(), 1);
                }
            }
            
            @isTest
            static void testPauseTaskLeaveAgent(){
                
                
                LiveChatTranscript liveChatTranscript  = [SELECT Id,RecordType.developername, CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c 
                                                          FROM LiveChatTranscript WHERE CC_Nickname__c = 'Empleado HDT'
                                                          AND CC_NumEmpleado__c = 'U01A45E2' AND CC_Tipo__c = 'Agente' ];  
                Case caso = new Case();
                insert caso;
                
                Id taskId = HDT_LiveAgent_BotonesController.CreateActivityPausa(caso.Id,'testAIEventHDT',liveChatTranscript.id,23);
                
                LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
                    Type = 'LeaveAgent',
                    LiveChatTranscriptId = liveChatTranscript.Id,
                    time = system.now()
                );
                Test.startTest();
                insert liveChatTranscriptEvent;
                Test.stopTest();
                 System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
                    Task taskAssert = [SELECT Status FROM Task WHERE Id = :taskId];
                    System.assertEquals('Completed', taskAssert.Status);
                }
            }
            
            @isTest
            static void testPauseTaskEndAgent(){
                
                LiveChatTranscript liveChatTranscript  = [SELECT Id,RecordType.developername, CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c 
                                                          FROM LiveChatTranscript WHERE CC_Nickname__c = 'Empleado HDT'
                                                          AND CC_NumEmpleado__c = 'U01A45E2' AND CC_Tipo__c = 'Agente' ];  
                Case caso = new Case();
                insert caso;
                
                Id taskId = HDT_LiveAgent_BotonesController.CreateActivityPausa(caso.Id,'testAIEventHDT',liveChatTranscript.id,23);
                
                LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
                    Type = 'EndAgent',
                    LiveChatTranscriptId = liveChatTranscript.Id,
                    time = system.now()
                );
                Test.startTest();
                insert liveChatTranscriptEvent;
                Test.stopTest();
                  System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
                    Task taskAssert = [SELECT Status FROM Task WHERE Id = :taskId];
                    System.assertEquals('Completed', taskAssert.Status);
                }
            }
            
            @isTest
            static void testPauseTaskEndVisitor(){
                
                
                LiveChatTranscript liveChatTranscript  = [SELECT Id,RecordType.developername, CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c 
                                                          FROM LiveChatTranscript WHERE CC_Nickname__c = 'Empleado HDT'
                                                          AND CC_NumEmpleado__c = 'U01A45E2' AND CC_Tipo__c = 'Agente' ];  
                Case caso = new Case();
                insert caso;
                
                Id taskId = HDT_LiveAgent_BotonesController.CreateActivityPausa(caso.Id,'testAIEventHDT',liveChatTranscript.id,23);
                
                LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
                    Type = 'EndVisitor',
                    LiveChatTranscriptId = liveChatTranscript.Id,
                    time = system.now()
                );
                Test.startTest();
                insert liveChatTranscriptEvent;
                Test.stopTest();
                  System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
                    Task taskAssert = [SELECT Status FROM Task WHERE Id = :taskId];
                    System.assertEquals('Completed', taskAssert.Status);
                }
            }
            
            @isTest
            static void testPauseTaskLeaveVisitor(){
                
                
                LiveChatTranscript liveChatTranscript  = [SELECT Id,RecordType.developername, CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c 
                                                          FROM LiveChatTranscript WHERE CC_Nickname__c = 'Empleado HDT'
                                                          AND CC_NumEmpleado__c = 'U01A45E2' AND CC_Tipo__c = 'Agente' ];  
                Case caso = new Case();
                insert caso;
                
                Id taskId = HDT_LiveAgent_BotonesController.CreateActivityPausa(caso.Id,'testAIEventHDT',liveChatTranscript.id,23);
                
                LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
                    Type = 'LeaveVisitor',
                    LiveChatTranscriptId = liveChatTranscript.Id,
                    time = system.now()
                );
                Test.startTest();
                insert liveChatTranscriptEvent;
                Test.stopTest();
                  System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
                    Task taskAssert = [SELECT Status FROM Task WHERE Id = :taskId];
                    System.assertEquals('Completed', taskAssert.Status);
                }
            }
        }