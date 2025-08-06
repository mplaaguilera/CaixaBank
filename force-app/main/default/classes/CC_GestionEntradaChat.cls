public with sharing class CC_GestionEntradaChat {

    @InvocableMethod(label='CC_GestionEntradaChat' description='CC_GestionEntradaChat')
    public static void gestionChatOwner(List<ID> chatsEntrantes) {
        gestionChatOwner_Future(chatsEntrantes);
    }

    @future
    public static void gestionChatOwner_Future (List<ID> chatsEntrantes)
    {
        gestionChatOwner_Interno(chatsEntrantes);
    }

    /*
    * Método llamado desde el Trigger BI de entrada de chats, unificación lógica de gestión del caso.
    */
    public static Map<String,Map<String,String>> gestionEntradaChats (List<LiveChatTranscript> listadoChats)
    {
        Map<String,Map<String,String>> datosChatsRetorno = new Map<String,Map<String,String>>();

        ID casoGenerado;
        ID cuenta;
        ID contacto;

        if (!listadoChats.isEmpty())
        {
            List<Case> casosUpsert = new List<Case>();
            Map<String,String> faqsOfrecidasWatson = new Map<String,String>();
            Map<String,Set<String>> faqsChats = new Map<String,Set<String>>();
            Set<String> todasFaqs = new Set<String>();
            Set<String> todosUsuarios = new Set<String>();
            Map<String,String> mapUsuario = new Map<String,String>();
            Map<String,LiveChatTranscript> mapaChatBots = new Map<String,LiveChatTranscript>();

            // Preparar la búsqueda de contactos de empleados.
            List<String> listadoMatriculas = new List<String>();
            for (LiveChatTranscript chat : listadoChats)
            {
                if (String.isNotBlank(chat.CC_NumEmpleado__c))
                {
                    listadoMatriculas.add(chat.CC_NumEmpleado__c);
                }
            }

            // Buscar los empleados.
            Map<String,ID> empleadoMatriculaId = new Map<String,ID>();
            Map<String,ID> empleadoAccountId = new Map<String,ID>();
            Map<String,String> chatNumeroEmpleado = new Map<String,String>();
            for (Contact empleado : [SELECT Id, CC_Matricula__c, AccountId FROM Contact WHERE RecordType.DeveloperName = 'CC_Empleado' AND CC_Matricula__c = :listadoMatriculas])
            {
                empleadoMatriculaId.put(empleado.CC_Matricula__c, empleado.Id);
                empleadoAccountId.put(empleado.CC_Matricula__c, empleado.AccountId);
            }

            for (LiveChatTranscript chat : listadoChats)
            {
                if (String.isNotBlank(chat.CC_NumEmpleado__c))
                {
                    Case caso = new Case();
                    caso.CC_Id_Cognitivo__c = chat.CC_Id_Cognitive__c;
                    caso.Canal_del_Empleado__c = chat.CC_Tipo__c;

                    if (String.isNotBlank(chat.CC_NumEmpleado__c))
                    {
                        // Empleados.
                        if (String.isNotBlank(chat.CC_Aplicacion__c) && chat.CC_Aplicacion__c.equalsIgnoreCase('CC_OFICINAS_CSI'))
                        {
                            caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
                            caso.Canal_del_Empleado__c = 'CSI';
                        }
                        else
                        {
                            caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
                        }
                    }else{
                        // Clientes.
                        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();



                    }
                    caso.Subject = chat.CC_Subject__c;
                    caso.Status = 'Activo';
                    caso.Description = chat.CC_Descripcion__c; //Long 32000
                    caso.Origin = chat.CC_CaseOrigin__c; //Text 80
                    caso.Priority = chat.CC_Prioridad__c; //Text 40
                    caso.CC_Idioma__c = chat.CC_IdiomaCV__c;
                    // DPK - US718894 - [GENiaL] Modificar integración Cognitive Chat - Salesforce - START
                    caso.CC_Resumen_AI__c = String.isNotBlank(chat.CC_Resumen_AI__c) ? chat.CC_Resumen_AI__c : 'Sin Información';
                    caso.CC_Sentimiento__c = String.isNotBlank(chat.CC_Sentimiento__c) ? chat.CC_Sentimiento__c : null;
                    //caso.CC_Respuesta_Asistente__c = String.isNotBlank(chat.CC_Respuesta_Asistente__c) ? chat.CC_Respuesta_Asistente__c : null;
                    //caso.CC_Asunto__c = String.isNotBlank(chat.CC_Asunto__c) ? chat.CC_Asunto__c : null;
                     // DPK - US718894 - [GENiaL] Modificar integración Cognitive Chat - Salesforce - END
                    if (String.isNotBlank(chat.CC_Canal_Procedencia__c))
                    {
                        caso.CC_Canal_Procedencia__c = chat.CC_Canal_Procedencia__c;
                        caso.CC_Tipo_Contacto__c = 'Consulta'; // update traído del PB CC_Gestion_Caso - 10/12/2019
                        
                        caso.CC_Canal_Resolucion__c = chat.CC_Canal_Procedencia__c;
                    }
                    if (String.isNotBlank(chat.CC_Canal_operativo__c))
                    {
                        caso.CC_Canal_Operativo__c = chat.CC_Canal_operativo__c;
                    }

                    caso.CC_Tipo_ChatTranscript__c =  chat.CC_Tipo__c;

                    // Asignar el empleado al caso.
                    // Pasaremos a un método future para vincular la oficina y empleado. Evitar LOCK_ROW en la creación.
                    //caso.ContactId = (empleadoMatriculaId.get(chat.CC_NumEmpleado__c) != null) ? empleadoMatriculaId.get(chat.CC_NumEmpleado__c) : null;
                    //caso.AccountId = (empleadoAccountId.get(chat.CC_NumEmpleado__c) != null) ? empleadoAccountId.get(chat.CC_NumEmpleado__c) : null;
                    chatNumeroEmpleado.put(chat.CC_Id_Cognitive__c,chat.CC_NumEmpleado__c);

                    //INI: Traspaso de PB CC_LiveChatTranscript_Preclasificacion a código
                    Boolean chatTransferido = chat.CC_Chat_Transferido__c;
                    String espacio = '';
                    String categoria = '';
                    if(chatTransferido){
                        if(String.isBlank(chat.CC_Espacio_Transfer__c)){
                            espacio = chat.CC_Espacio__c;    
                        }else{
                          espacio = chat.CC_Espacio_Transfer__c;    
                        }
                        
                        if(String.isBlank(chat.CC_Categoria_Transfer__c)){
                            categoria = chat.CC_Categoria__c;    
                        }else{
                          categoria = chat.CC_Categoria_Transfer__c;    
                        }
                    }else{
                        espacio = chat.CC_Espacio__c;
                        categoria = chat.CC_Categoria__c;
                    }
                    Map<String, String> mapaClasificacionEquivalente = CC_MCC_Metodos.obtenerClasificacionEquivalente(espacio, categoria);
                    
                    if(String.isBlank(mapaClasificacionEquivalente.get('Temática'))){
                      caso.CC_Codigo_Externo_Tematica__c = null;
                        caso.CC_Tematica__c = null;    
                    }
                    
                    if(String.isBlank(mapaClasificacionEquivalente.get('Producto'))){
                      caso.CC_Codigo_Externo_Producto__c = null;
                        caso.CC_Producto_Servicio__c = null;    
                    }
                    
                    
                    caso.CC_MCC_Tematica__c = mapaClasificacionEquivalente.get('Temática');
                    caso.CC_MCC_ProdServ__c = mapaClasificacionEquivalente.get('Producto');
                    caso.CC_MCC_Motivo__c = null;
                    caso.CC_MCC_Causa__c = null;
                    caso.CC_MCC_Solucion__c = null;
                    if (mapaClasificacionEquivalente.get('Canal de procedencia') != null) {
                        
                        caso.CC_Canal_Procedencia__c = mapaClasificacionEquivalente.get('Canal de procedencia');
                    }
                    caso.CC_Canal_Resolucion__c = mapaClasificacionEquivalente.get('Canal de procedencia');
                    //FIN: Traspaso de PB CC_LiveChatTranscript_Preclasificacion a código


                    casosUpsert.add(caso);

                    // Preparar estructura para búsqueda de FAQs.
                    
                    
                    String jsonInput = chat.CC_Cognitive_chat__c;
                    jsonInput = jsonInput.replaceAll('\b','').replaceAll('\f','').replaceAll('\n','').replaceAll('\r','').replaceAll('\t','');

                    CC_Cognitive_Chat_JSON chatCognitivo = CC_Cognitive_Chat_JSON.parse(jsonInput);
                    if (!Test.isRunningTest() && chatCognitivo != null)
                    {
                        List<CC_Cognitive_Chat_JSON.Results> faqs = chatCognitivo.getChatbotFaqs();
                        Set<String> faqsRespuesta = new Set<String>();
                        for (CC_Cognitive_Chat_JSON.Results listfaqs: faqs) {
                            faqsRespuesta.add(listfaqs.id);
                        }
                        // Modo test.
                        //faqsRespuesta.add('Cuales_son_las_modalidades_de_pago_de_la_Declaracion_de_la_Renta_con_tarjeta');
                        todasFaqs.addAll(faqsRespuesta);

                        faqsChats.put(chat.CC_Id_Cognitive__c, faqsRespuesta);
                    }

                    //Stop&GO
                    todosUsuarios.add(chat.CC_Agente_Chat_Atendido__c);
                    mapUsuario.put(chat.CC_Id_Cognitive__c, chat.CC_Agente_Chat_Atendido__c);
                    mapUsuario.put('proveedorAnterior', chat.CC_Proveedor_Atendido__c);

                    mapUsuario.put('resumenAI', chat.CC_Resumen_AI__c);
                    // Crear transcripcion del chatbot.
                    LiveChatTranscript nuevoChatCognitivo = new LiveChatTranscript();
                    CC_Cognitive_Chat_JSON json = chatCognitivo;//CC_Cognitive_Chat_JSON.parse(chat.CC_Cognitive_chat__c);
                    nuevoChatCognitivo.CC_Tipo__c = 'Chatbot';
                    nuevoChatCognitivo.CC_NumEmpleado__c = chat.CC_NumEmpleado__c;

                    if (String.isBlank(chat.CC_NumEmpleado__c))
                    {
                        // Chat de clientes.
                        nuevoChatCognitivo.RecordTypeId = Schema.getGlobalDescribe().get('LiveChatTranscript').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Clientes').getRecordTypeId();
                    }else{
                        // Chat de empleados.
                        nuevoChatCognitivo.RecordTypeId = Schema.getGlobalDescribe().get('LiveChatTranscript').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleados').getRecordTypeId();
                    }

                    nuevoChatCognitivo.LiveChatVisitorId = chat.LiveChatVisitorId;
                    nuevoChatCognitivo.CC_Nickname__c = chat.CC_Nickname__c;
                    nuevoChatCognitivo.CC_Cognitive_chat__c = chat.CC_Cognitive_chat__c;

                    if (!Test.isRunningTest())
                    nuevoChatCognitivo.Body = json.getChatHTML(chat.CC_Nickname__c);

                    nuevoChatCognitivo.StartTime = json.fechaInicio;
                    nuevoChatCognitivo.EndTime = json.fechaFin;
                    nuevoChatCognitivo.CC_Espacio__c = chat.CC_Espacio__c;
                    nuevoChatCognitivo.CC_Categoria__c = chat.CC_Categoria__c;
                    nuevoChatCognitivo.CC_Cognitive_chat__c = chat.CC_Cognitive_chat__c;
                    nuevoChatCognitivo.CC_Canal_Procedencia__c = chat.CC_Canal_Procedencia__c;
                    nuevoChatCognitivo.Status = 'Completed';
                    nuevoChatCognitivo.CC_Id_Cognitive__c = chat.CC_Id_Cognitive__c;

                    mapaChatBots.put(chat.CC_Id_Cognitive__c, nuevoChatCognitivo);
                }
            }

            //Stop&GO
            if (!mapUsuario.isEmpty()){
                List<CC_Usuario_Genesys__c> usuariosGenesys = [SELECT Id, Name, CC_User__c, CC_User__r.EmployeeNumber FROM CC_Usuario_Genesys__c WHERE CC_User__r.EmployeeNumber in: todosUsuarios];
                for(CC_Usuario_Genesys__c usuario: usuariosGenesys)
                {
                    for (String sClave : mapUsuario.keySet())
                    {
                        if (mapUsuario.get(sClave) != null)
                        {
                            if (mapUsuario.get(sClave) == usuario.CC_User__r.EmployeeNumber)
                            {
                                mapUsuario.put(sClave, usuario.Name);
                            }

                        }
                    }
                }
            }

            // Gestión de FAQs.
            if (!faqsChats.isEmpty())
            {
                List<CC_Intent__c> intentListId = new List<CC_Intent__c>();
                intentListId = [SELECT CC_FAQ_Id__c, CC_FAQ_Id__r.CC_FAQ_Ident__c, CC_Nombre__c
                FROM CC_Intent__c WHERE CC_Nombre__c in :todasFaqs AND RecordType.DeveloperName = 'CC_Intent'];

                for(CC_Intent__c listIntents: intentListId)
                {
                    for (String sClave : faqsChats.keySet())
                    {
                        if (faqsChats.get(sClave) != null)
                        {
                            if (faqsChats.get(sClave).contains(listIntents.CC_Nombre__c))
                            {
                                String sFaqsTmp = faqsOfrecidasWatson.get(sClave);
                                if (String.isNotBlank(sFaqsTmp))
                                {
                                    sFaqsTmp = sFaqsTmp + ',';
                                }else{
                                    sFaqsTmp = '';
                                }
                                sFaqsTmp = sFaqsTmp + listIntents.CC_FAQ_Id__c;

                                faqsOfrecidasWatson.put(sClave,sFaqsTmp);
                            }
                        }
                    }
                }
            }

            // Gestión de creación de casos de empleados.
            if (!casosUpsert.isEmpty())
            {
                upsert casosUpsert CC_Id_Cognitivo__c;

                for (Case datosCaso : casosUpsert)
                {
                    String numeroEmpleado = chatNumeroEmpleado.get(datosCaso.CC_Id_Cognitivo__c);
                    ID cuentaOficina = (String.isNotBlank(numeroEmpleado)) ? ((empleadoAccountId.get(numeroEmpleado) != null) ? empleadoAccountId.get(numeroEmpleado) : null) : null;
                    ID empleadoId = (String.isNotBlank(numeroEmpleado)) ? ((empleadoMatriculaId.get(numeroEmpleado) != null) ? empleadoMatriculaId.get(numeroEmpleado) : null) : null;

                    Map<String,String> datosChatVincular = new Map<String,String>();
                    datosChatVincular.put('NumCaso',datosCaso.Id);
                    //datosChatVincular.put('Cuenta',datosCaso.AccountId);
                    //datosChatVincular.put('Contacto',datosCaso.ContactId);
                    datosChatVincular.put('Cuenta',cuentaOficina);
                    datosChatVincular.put('Contacto',empleadoId);
                    
                    if (faqsOfrecidasWatson.get(datosCaso.CC_Id_Cognitivo__c) != null)
                    {
                        datosChatVincular.put('FaqsWatson', faqsOfrecidasWatson.get(datosCaso.CC_Id_Cognitivo__c));
                    }
                    //Stop&GO
                    if (mapUsuario.get(datosCaso.CC_Id_Cognitivo__c) != null)
                    {
                        datosChatVincular.put('LoginUsuario', mapUsuario.get(datosCaso.CC_Id_Cognitivo__c));
                        datosChatVincular.put('ProveedorAnterior', mapUsuario.get('proveedorAnterior'));
                    }

                    datosChatVincular.put('ResumenIA', mapUsuario.get('resumenAI'));
                    datosChatsRetorno.put(datosCaso.CC_Id_Cognitivo__c, datosChatVincular);

                    // Vincular los datos del cliente, contacto y caso a la transcripción del chatbot.
                    if (mapaChatBots.get(datosCaso.CC_Id_Cognitivo__c) != null)
                    {
                        LiveChatTranscript chatBot = mapaChatBots.get(datosCaso.CC_Id_Cognitivo__c);
                        chatBot.AccountId = cuentaOficina;
                        chatBot.ContactId = empleadoId;
                        chatBot.CaseId = datosCaso.Id;
                    }
                }
                //CC_Encuestas_Chat.generarEncuesta(casosUpsert);
            }

            if (!mapaChatBots.isEmpty())
            {
                List<LiveChatTranscript> listadoTranscripcionesBot = mapaChatBots.values();
                Database.SaveResult[] oResUp = Database.insert(listadoTranscripcionesBot, false);

                for (Integer i = 0; i < oResUp.size(); i++)
                {
                    if (oResUp[i].isSuccess())
                    {
                        // Mejora. Vincular el chatbot insertado con la transcripción en curso.
                        LiveChatTranscript chatBotTranscript = listadoTranscripcionesBot[i];
                        String claveCognitivoBot = chatBotTranscript.CC_Id_Cognitive__c;
                        if (datosChatsRetorno.get(claveCognitivoBot) != null)
                        {
                            Map<String,String> dataChat = datosChatsRetorno.get(claveCognitivoBot);
                            dataChat.put('ChatBotId', chatBotTranscript.Id);
                            datosChatsRetorno.put(claveCognitivoBot, dataChat);
                        }
                    }
                }
            }
        }
        return datosChatsRetorno;
    }

    /*public static void prepararTareaChat (LiveChatTranscript chatAsociado, String asuntoTarea, List<Task> listadoTareas)
    {
        // Preparación tarea.
        Task nuevaActividadChat = new Task();
        nuevaActividadChat.Status = 'Completed';
        nuevaActividadChat.Subject = asuntoTarea;
        nuevaActividadChat.Priority = 'Normal';
        nuevaActividadChat.Type = 'Automática';
        nuevaActividadChat.CC_Categoria__c = chatAsociado.CC_Categoria__c;
        nuevaActividadChat.CC_Espacio__c = chatAsociado.CC_Espacio__c;
        nuevaActividadChat.CC_Chat_Cognitivo_Id__c = chatAsociado.CC_Id_Cognitive__c;
        nuevaActividadChat.CC_LiveChatTranscript_Id__c = chatAsociado.Id;
        nuevaActividadChat.WhatId = chatAsociado.CaseId;

        listadoTareas.add(nuevaActividadChat);
    }*/

    public static void prepararTareaChat (LiveChatTranscript chatAsociado, Boolean bChatBot, String asuntoTarea, List<Task> listadoTareas)
    {
        // Preparación tarea.
        Task nuevaActividadChat = new Task();
        nuevaActividadChat.Status = 'Completed';
        nuevaActividadChat.Subject = asuntoTarea;
        nuevaActividadChat.Priority = 'Normal';
        nuevaActividadChat.Type = 'Automática';
        nuevaActividadChat.CC_Categoria__c = chatAsociado.CC_Categoria__c;
        nuevaActividadChat.CC_Espacio__c = chatAsociado.CC_Espacio__c;
        nuevaActividadChat.CC_Chat_Cognitivo_Id__c = chatAsociado.CC_Id_Cognitive__c;
        nuevaActividadChat.CC_LiveChatTranscript_Id__c = (!bChatBot) ? chatAsociado.Id : chatAsociado.CC_ChatOrigen__c;
        nuevaActividadChat.WhatId = chatAsociado.CaseId;
		nuevaActividadChat.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        listadoTareas.add(nuevaActividadChat);
    }

   @future
    public static void actualizarDatosChatAIFuture (List<Id> listadoIdChats) {
        List<Task> listadoTareas = new List<Task>();
        List<Case> listadoCases = new List<Case>();
        for (LiveChatTranscript chatAgente : [SELECT CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c,CC_ChatOrigen__c ,status,cc_tipo__c, AccountId, ContactId, CaseId
                                                FROM LiveChatTranscript WHERE Id IN :listadoIdChats]) {
            // Actualizar datos del caso
            if (chatAgente.CaseId != null && chatAgente.AccountId != null && chatAgente.ContactId != null) {
                Case casoUpdate = new Case(Id = chatAgente.CaseId);
                casoUpdate.AccountId = chatAgente.AccountId;
                casoUpdate.ContactId = chatAgente.ContactId;
                listadoCases.add(casoUpdate);
            }

            // Se ha aceptado el chat. Crear la tarea asociada al chatbot vinculado.
            String asuntoTarea = 'Conversación con chatbot';
            CC_GestionEntradaChat.prepararTareaChat(chatAgente, true, asuntoTarea, listadoTareas);

            if (chatAgente.Status!='Missed'){

                // Se ha aceptado el chat. Crear la tarea asociada al agente.
                asuntoTarea = '';
                if (chatAgente.CC_Tipo__c == 'Hidden')
                {
                    asuntoTarea = 'Conversación con agente hidden';
                }else{
                    asuntoTarea = 'Conversación con agente chat';
                }
                CC_GestionEntradaChat.prepararTareaChat (chatAgente, false, asuntoTarea, listadoTareas);
            }
        }

        if (!listadoCases.isEmpty())
        {
            Database.SaveResult[] listadoCasesUpdated = Database.update(listadoCases, false);
        }

        if (!listadoTareas.isEmpty())
        {
            Database.SaveResult[] listadoTareasUpdated =  CC_Activity.crearActividades(listadoTareas, false);
        }

    }


    public static void gestionChatOwner_Interno (List<ID> chatsEntrantes)
    {
        if (!chatsEntrantes.isEmpty())
        {
            List<LiveChatTranscript> listadoChats = [SELECT Id, CC_Id_Cognitive__c, OwnerId, CaseId, Case.AccountId, Case.ContactId
            FROM LiveChatTranscript
            WHERE Id IN :chatsEntrantes];

            List<Case> casosUpdate = new List<Case>();
            List<LiveChatTranscript> nuevasTranscripciones = new List<LiveChatTranscript>();
            for (LiveChatTranscript chat : listadoChats)
            {
                Case caso = new Case();
                caso.Id = chat.CaseId;
                caso.OwnerId = chat.OwnerId; // Asignación del caso al propietario del caso.
                casosUpdate.add(caso);
            }

            // Lanzamos actualización primero, en el caso que no exista (primer hidden, fallará. Simulación Trigger BU)
            if (!casosUpdate.isEmpty())
            {
                Database.SaveResult[] oResUp = Database.update(casosUpdate, false);
            }
        }
    }

    /*
    * Método llamado desde el Trigger BI de entrada de chats de clientes.
    */
    public static Map<String,Map<String,String>> gestionEntradaChatsClientes (List<LiveChatTranscript> listadoChats)
    {
        Map<String,Map<String,String>> datosChatsRetorno = new Map<String,Map<String,String>>();
        List<Account> listaNuevasCuentas = new List<Account>();
        List<Account> convRT = new List<Account>();
        List<Account> convName = new List<Account>();
        List<Account> convNamePA = new List<Account>();
        List<Account> actAVNumPer = new List<Account>();
        Set<String> listaNumPer = new Set<String>();
        Map<String,String> mapChatNumper = new Map<String,String>();

        if (!listadoChats.isEmpty())
        {
            // Recorrer la entrada de chats.
            for (LiveChatTranscript chat : listadoChats)
            {
                if (chat.RecordTypeId == Schema.getGlobalDescribe().get('LiveChatTranscript').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Clientes').getRecordTypeId() && chat.CC_Tipo__c == 'Agente')
                {
                    // Forzar conversión como se hac en ALF para clientes existentes.
                    Account oConversionUpdate = new Account();
                    oConversionUpdate.CC_NumPerso__c = chat.CC_NumPerso__c;
                    oConversionUpdate.AV_NumPerso__c = chat.CC_NumPerso__c;
                    oConversionUpdate.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
                    convRT.add(oConversionUpdate);

                    Account oActualizarName = new Account();
                    oActualizarName.CC_NumPerso__c = chat.CC_NumPerso__c;
                    oActualizarName.AV_NumPerso__c = chat.CC_NumPerso__c;
                    oActualizarName.Name = chat.CC_Nickname__c;
                    convName.add(oActualizarName);

                    Account oActualizarPAName = new Account();
                    oActualizarPAName.CC_NumPerso__c = chat.CC_NumPerso__c;
                    oActualizarPAName.AV_NumPerso__c = chat.CC_NumPerso__c;
                    oActualizarPAName.FirstName = '';
                    oActualizarPAName.LastName = chat.CC_Nickname__c;
                    oActualizarPAName.CC_NumPerso__pc = chat.CC_NumPerso__c;
                    oActualizarPAName.AV_NumPerso__pc = chat.CC_NumPerso__c;
                    convNamePA.add(oActualizarPAName);

                    Account nuevoCliente = new Account();
                    nuevoCliente.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
                    nuevoCliente.LastName = chat.CC_Nickname__c;
                    nuevoCliente.CC_NumPerso__c = chat.CC_NumPerso__c;
                    nuevoCliente.CC_NumPerso__pc = chat.CC_NumPerso__c;
                    nuevoCliente.AV_NumPerso__c = chat.CC_NumPerso__c;
                    nuevoCliente.AV_NumPerso__pc = chat.CC_NumPerso__c;
                    nuevoCliente.CC_Idioma__pc = chat.CC_IdiomaCV__c;
                    listaNuevasCuentas.add(nuevoCliente);
                    if (String.isNotBlank(chat.CC_NumPerso__c))
                    {
                        listaNumPer.add(chat.CC_NumPerso__c);
                    }
                    mapChatNumper.put(chat.CC_Id_Cognitive__c, chat.CC_NumPerso__c);

                    // Actualizar nuevo campo AV_NumPer.
                    Account oUpdAVNumPer = new Account();
                    oUpdAVNumPer.CC_NumPerso__c = chat.CC_NumPerso__c;
                    oUpdAVNumPer.AV_NumPerso__c = chat.CC_NumPerso__c;
                    actAVNumPer.add(oUpdAVNumPer);
                }
            }

            // INICIO Conversión a PA.
            Schema.SObjectField oCampoSearch = Account.Fields.CC_NumPerso__c;

            if (!listaNuevasCuentas.isEmpty())
            {
                Database.UpsertResult[] oResInsert = Database.upsert(listaNuevasCuentas, false);
            }

            if (convRT.size() > 0)
            {
                Database.UpsertResult[] oResUp = Database.upsert(convRT, oCampoSearch, false);
            }

            if (convName.size() > 0)
            {
                Database.UpsertResult[] oResUp = Database.upsert(convName, oCampoSearch, false);
            }

            if (convNamePA.size() > 0)
            {
                Database.UpsertResult[] oResUp = Database.upsert(convNamePA, oCampoSearch, false);
            }

            if (actAVNumPer.size() > 0)
            {
                Database.UpsertResult[] oResUpAV = Database.upsert(actAVNumPer, oCampoSearch, false);
            }

            // FIN Conversión a PA.

            // Recuperar los clientes creados.
            if (!listaNumPer.isEmpty())
            {
                List<Account> clientesExistentes = [SELECT Id, PersonContactId, CC_NumPerso__c
                FROM Account
                WHERE CC_NumPerso__c IN :listaNumPer];
                for (Account cuenta : clientesExistentes)
                {
                    for (String sClave : mapChatNumper.keySet())
                    {
                        if (mapChatNumper.get(sClave) != null)
                        {
                            if (mapChatNumper.get(sClave) == cuenta.CC_NumPerso__c)
                            {
                                Map<String,String> datosChatVincular = new Map<String,String>();
                                datosChatVincular.put('Cuenta',cuenta.Id);
                                datosChatVincular.put('Contacto',cuenta.PersonContactId);

                                datosChatsRetorno.put(sClave, datosChatVincular);
                            }
                        }
                    }
                }

                for (String numPerCons : listaNumPer)
                {
                    CC_IdentCliente_Future.IdentificarPersALFASynchronous ('NP',numPerCons);
                }
            }
        }

        return datosChatsRetorno;
    }
}