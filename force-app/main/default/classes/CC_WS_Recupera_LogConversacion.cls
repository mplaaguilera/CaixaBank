public class CC_WS_Recupera_LogConversacion {
    /* 
     * A partir del id_cognitive que nos llega en la llamada buscamos si existe caso,
     * sino existe, se realiza una llamada al WS de recuperar los logs de la conversación y crear un caso con la transcripción del chat
     */
    public static Case CC_WS_Recupera_Conversacion(CC_Llamada__c llamada) {
        // Comprobamos si existe algun caso con ese id de Cognitivo
        Case oCase = null;
        oCase = getDatosCaso(llamada);
        CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Canal_de_Entrada__c, CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c 
                                                  FROM CC_Servicio_Genesys__c WHERE Id = :llamada.CC_Servicio_Genesys__c];
        
        //Reapertura del caso si se trata de un caso cerrado de Hidden
        if (oCase != null){
            if (oCase.CC_Tipo_ChatTranscript__c == 'Hidden' || oCase.CC_Tipo_ChatTranscript__c == 'Agente'){
                //Reactivamos el caso en caso de estar cerrado
                if (oCase.Status == 'Cerrado'){
					oCase.Status = 'Activo';
                }
                //Si es de chat cambiar canal entrada, canal procedencia y canal resolucion y canal empleado
                if (oCase.Origin == 'Chat'){
                    oCase.Origin = 'Phone';
                    oCase.CC_Canal_Respuesta__c = 'Phone';
                    oCase.CC_Canal_Procedencia__c = servicioGenesys.CC_Canal_Procedencia__c;
                    oCase.CC_Canal_Resolucion__c = servicioGenesys.CC_Canal_Procedencia__c;
                    oCase.Canal_del_Empleado__c = llamada.CC_Canal_del_Empleado__c;
                }
                update oCase;
            }
        }
        
        if (oCase == null) {
            // Recuperamos la configuración para la llamada al WS de recuperar la conversación con Cognitive
            CC_InterfaceSettings__mdt recuperaLog = CC_MetodosUtiles.getInterfazConfigBody('CC_Recupera_Log');
            List<CC_TrazaInt__c> oListTraza = new List<CC_TrazaInt__c>();
            String errorCode;
            String errorMsg;
            String dataMockup = '';
            // Gestión trazas.
            CC_TrazaInt__c oTraza;
            String sDescError = '';
            String sDetalleError = '';
            String sSalida = '';
            String transcripcionCog = '';
            // Comprobar que tenemos el numPerso informado en el Caso para poder realizar el envío
            if (llamada.CC_Id_Cognitivo__c != null && llamada.CC_Id_Cognitivo__c != ''){
                String user = '';
                if (recuperaLog.CC_TrazaActiva__c || Test.isRunningTest()) {
                    oTraza = new CC_TrazaInt__c();
                    oTraza.Name = 'CC_Recupera_Log';
                    oTraza.CC_Identificador__c = llamada.Id;
                    oTraza.CC_FechaInicio__c = datetime.now();
                }
                //Llamada al WS para recuperar la conversación de cognitive, crear el caso y la transcripción de la conversación
                try {
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(recuperaLog.CC_EndPoint__c + llamada.CC_Id_Cognitivo__c);
                    request.setMethod(recuperaLog.CC_TipoPeticion__c);
                    request.setHeader('Content-Type', recuperaLog.CC_ContentType__c);
                    
                    if (!Test.isRunningTest())
                        request.setClientCertificateName(recuperaLog.CC_Certificado__c);

                    if ((recuperaLog.CC_TrazaActiva__c || Test.isRunningTest()) && recuperaLog.CC_TrazaEntrada__c && oTraza != null)
                        oTraza.CC_MensajeEntrada__c = 'Id Cognitive: '+ llamada.CC_Id_Cognitivo__c;
                    if (Test.isRunningTest()){
                        dataMockup = '{"took":2,"timed_out":false,"_shards":{"total":1,"successful":1,"skipped":0,"failed":0},"hits":{"total":0,"max_score":null,"hits":[{"_index" : "app-112","_id" : "AYKDttITXJVSpIkmGr5S","_source" : {"result" : "CN","prioritaria" : "NO","conversationID" : "2208090214260636","areas" : ["112Conversacional","CXR"],"userQuery" : ["Petición de DNI","hablar con un agente","sacar dinero con código"],"startTime" : "2022-08-09T17:43:27.579Z","user" : "53753318","iterations" : 8,"entorno" : "RUNTIME","revision" : "NO","agents" : ["WATSON"]}},{"_index" : "app-112","_id" : "AYKDttfTQEhgDgw0z6X3","_source" : {"result" : "C2C","prioritaria" : "NO","conversationID" : "2208090214261161","areas" : ["HLO"],"userQuery" : ["no no"],"startTime" : "2022-08-09T17:43:27.579Z","user" : "53753318","iterations" : 0,"entorno" : "RUNTIME","revision" : "NO","agents" : ["WATSON"]}}]}}';
                    }
                    HttpResponse response = String.isNotBlank(dataMockup) ? getDataMockup(dataMockup) : http.send(request);
                    // Parse the JSON response
                    if (response.getStatusCode() != 200) {
                        sDescError = 'Error petición.';
                        sDetalleError = response.getStatus() + ' (' + response.getStatusCode() + ')';
                        sSalida = String.valueOf(response.getBody());
                    } else {
                        // Recuperamos el JSON de la conversación con cognitive a partir de la respuesta del WS
                        Map<String, Object> MapRespuesta = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf(response.getBody()));
                        String HitsLevel = JSON.serialize(MapRespuesta.get('hits'));
                        Map<String, Object> MapListadoHits = (Map<String, Object>) JSON.deserializeUntyped(HitsLevel);
                        List<Map<String, Object>> data = new List<Map<String, Object>>();
                        for (Object instance : (List<Object>)MapListadoHits.get('hits')){
                            data.add((Map<String, Object>)instance);
                            for (Object nivel : data){
                                String SourceLevel = JSON.serialize(nivel);
                                Map<String, Object> MapSource = (Map<String, Object>) JSON.deserializeUntyped(SourceLevel);
                                transcripcionCog = JSON.serialize(MapSource.get('_source'));
                                Map<String, Object> MapUser =   (Map<String, Object>) JSON.deserializeUntyped(transcripcionCog);
                                user = (String) MapUser.get('user');
                            }
                        }
                    }
                } catch (Exception e){
                    // Error comunicaciones.
                    sDescError = 'Error comunicaciones.';
                    sDetalleError = e.getMessage();
                }
                // Crear caso
                oCase = CC_Llamada.crearCaso(llamada, servicioGenesys);
                // A partir del caso creado, crear la Transcripción añadiendo la conversación recuperada
                if (transcripcionCog != null && transcripcionCog != ''){
                    LiveChatTranscript oTranscipt = createLiveChatTranscript(oCase.Id, transcripcionCog, llamada.CC_Id_Cognitivo__c, llamada.CC_Idioma__c, llamada.CC_Asunto__c , user);
                    // Crear Tarea de conversación ChatBot asociada al nuevo caso creado
                    Task oTask = createActivity(oCase.Id, llamada.CC_Id_Cognitivo__c, oTranscipt.Id);
                }
            } else{
                // Registrar traza sin datos de envío.
                sDescError = 'Datos llamada no informados.';
                sDetalleError = 'La llamada '+ llamada.Name + ' no tiene un id de conversación asociado.';
            }

            // Finalizar traza.
            if ((recuperaLog.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null){
                oTraza.CC_FechaFin__c = datetime.now();

                if ((recuperaLog.CC_TrazaSalida__c || Test.isRunningTest()) && transcripcionCog != ''){
                    oTraza.CC_MensajeSalida__c = transcripcionCog;
                }

                if (sDescError != ''){
                    oTraza.CC_FinOK__c = false;
                    oTraza.CC_TipoError__c = sDescError;
                    oTraza.CC_DetalleError__c = sDetalleError;
                } else{
                    oTraza.CC_FinOK__c = true;
                }

                oListTraza.add(oTraza);
            }

            // Insertar las trazas generadas.
            if (oListTraza.size() > 0){
                Database.SaveResult[] oResUp = Database.insert(oListTraza, false);
            }
        }

        return oCase;
    }

    //Recuperar el id del caso en caso de existir
    private static Case getDatosCaso (CC_Llamada__c llamada) {
        Case oCaso = null;
        List<Case> oListCaso = [SELECT Id, Subject, Origin, CC_Canal_Respuesta__c, CC_Tipo_Cliente__c, CC_Telefono_Contacto__c, CC_No_Identificado__c,
                                CC_Canal_Procedencia__c, Canal_del_Empleado__c, AccountId, ContactId, CaseNumber, CC_Id_Cognitivo__c, Status,
                                CC_Tipo_ChatTranscript__c
                                FROM Case  WHERE CC_Id_Cognitivo__c = : llamada.CC_Id_Cognitivo__c LIMIT 1];

        if (!oListCaso.isEmpty()){
            for (Case Lcaso : oListCaso){
                oCaso = Lcaso;
            }
        }
        return oCaso;
    }

    //Método publicado para crear actividad de ChatBot.
    private static Task createActivity(Id caseId, String idCognitivo, Id transcriptId) {
        Date todaysDate = system.today();
        Task task = new Task();
        task.ActivityDate = todaysDate;
        task.Subject = 'Conversación ChatBot';
        task.Type = 'Automática'; //Pdte. si es un tipo especial para historico conversación
        task.Status = 'Completed';
        task.Description = 'Conversación con ChatBot.';
        //task.OwnerId = oChatNew.OwnerId;
        task.CC_Chat_Cognitivo_Id__c = idCognitivo;
        task.WhatId = caseId;
        task.CC_LiveChatTranscript_Id__c = transcriptId;
        task.Priority = 'Normal';
        //insert task;
        CC_Activity.crearActividad(task);

        return task;
    }
    
    //Método publicado para crear el LiveChatTranscript de la transcripción del Chat Hidden.
    private static LiveChatTranscript createLiveChatTranscript(Id caseId, String transcript, String idCognitive, String idioma, String asunto, String nickname) {
        ID sRTEmpleado = Schema.getGlobalDescribe().get('LiveChatTranscript').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleados').getRecordTypeId();

        LiveChatTranscript liveChatTranscript = new LiveChatTranscript();
        liveChatTranscript.CC_Idioma__c = idioma;
        liveChatTranscript.RecordTypeId = sRTEmpleado;
        liveChatTranscript.CC_Subject__c = asunto;
        liveChatTranscript.Status = 'Completed';
        liveChatTranscript.CC_Tipo__c = 'Chatbot';
        liveChatTranscript.CC_Cognitive_chat__c = transcript;
        liveChatTranscript.CC_Nickname__c  = nickname;
        liveChatTranscript.CC_Id_Cognitive__c= idCognitive;
        liveChatTranscript.CaseId = caseId;
        // No aplica: Miramos si ya existe el LiveChatTranscript
        //List<LiveChatTranscript> oTranscriptExiste = [SELECT Id FROM LiveChatTranscript WHERE CC_Id_Cognitive__c = :idCognitive];
        //if (oTranscriptExiste.isEmpty()){
            // Creamos LiveChatVisitor sin session key para crear el LiveChatTranscript
            LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
            insert liveChatVisitor;
            // En caso de no existir se informa el chatvisitorId
            liveChatTranscript.LiveChatVisitorId = liveChatVisitor.Id;
        //}
        insert liveChatTranscript;

        return liveChatTranscript;
    }

    /**
     * @description Generate the response for the mockup data
     */
    private static HTTPResponse getDataMockup(String dataMockup){
        
        HTTPResponse res = new HTTPResponse();
        res.setStatusCode(Integer.valueOf('200'));
        res.setStatus('OK');
        res.setBody(dataMockup);
        return res;
    }
    
}