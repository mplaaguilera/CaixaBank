/**
 * @description       :
 * @author            : Moisés Cano
 * @group             :
 * @last modified on  : 15-05-2023
 * @last modified by  : Moisés Cano
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   15-05-2023   Moisés Cano   Initial Version
**/
public with sharing class HDT_LiveChatTranscript_BI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<LiveChatTranscript>)tp.newList, (Map<Id, LiveChatTranscript>)tp.newMap);
    }

    private void process(List<LiveChatTranscript> listNewObj, Map<Id, LiveChatTranscript> mapNewObj) {
        //Informa Origen a partir de la Procedencia antes de guardar el registro
        //Descartar los que vengan de CSBD
        List<LiveChatTranscript> listNewTranscript = new List<LiveChatTranscript>();
        for(LiveChatTranscript transcript : listNewObj){
            if (transcript.UserAgent == 'ChatdeempleadosHDT'){
                listNewTranscript.add(transcript);
            }
        }
        if(!listNewTranscript.isEmpty()){
            processAux(listNewTranscript);
        }
    }

    private void processAux(List<LiveChatTranscript> listNewObj) {

        informarProcedencia(listNewObj);
        //Informa el servicio en los chats Empleados
        informarServicio(listNewObj);
    }

    private void informarProcedencia(List<LiveChatTranscript> listNewObj) {
        //Recupera la relación entre las aplicaciones y las procedencias de las transcripciones
        Map<String, String> relacionAplicacionProcedencia = new Map<String, String>();
        Map<String, String> relacionAplicacionCod = new Map<String, String>();
        Map<String, String> relacionAplicacionNombre = new Map<String, String>();
        Map<String, String> relacionAplicacionCanalOperativo = new Map<String, String>();

        // Gestión entrada chat.
        //Map<String,Map<String,String>> datosChatRetornados = HDT_GestionEntradaChat.gestionEntradaChats(listNewObj);

        //Nuevo listado de transcripciones quitando aquellos que son ChatBot
        List<LiveChatTranscript> oListChat = new List<LiveChatTranscript>();
        for (LiveChatTranscript oChat : listNewObj) {

            if (oChat.CC_Tipo__c != 'Chatbot' && oChat.CC_Tipo__c != 'Whatsapp' ){
                oListChat.add(oChat);
            }
        }

        for (LiveChatTranscript chat : oListChat)
        {
            relacionAplicacionProcedencia.put(chat.CC_Aplicacion__c, '');
            relacionAplicacionCod.put(chat.CC_Aplicacion__c, '');

            chat.RecordTypeId = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByDeveloperName().get('HDT_Empleados').getRecordTypeId();

            //chat.CC_Transferir__c = true;

            // Por cada chat, recuperar los datos necesarios para Cognitivo 360.
            if (String.isBlank(chat.CC_PerfilVisitante__c) || String.isBlank(chat.CC_IdsGlobales__c) || String.isBlank(chat.CC_Pilotaje__c) || String.isBlank(chat.CC_Aplicacion_Origen__c) || String.isBlank(chat.CC_Source_Aplicacion_Corpus__c) || String.isBlank(chat.CC_Source_Conversation_Id__c))
            {
                String jsonInput = chat.CC_Cognitive_chat__c;
                if (!String.isBlank(jsonInput))
                {
                    
                    jsonInput = jsonInput.replaceAll('\b','').replaceAll('\f','').replaceAll('\n','').replaceAll('\r','').replaceAll('\t','');
                    CC_Cognitive_Chat_JSON oDatosPrevios = CC_Cognitive_Chat_JSON.parse(jsonInput);
                    if (oDatosPrevios != null)
                    {
                        // Cambios Cognitivo 360.
                        if (String.isBlank(chat.CC_PerfilVisitante__c) && String.isNotBlank(oDatosPrevios.perfil))
                        {
                            chat.CC_PerfilVisitante__c = oDatosPrevios.perfil;
                        }

                        if (String.isBlank(chat.CC_IdsGlobales__c) && oDatosPrevios.idGlobales != null)
                        {
                            if (!oDatosPrevios.idGlobales.isEmpty())
                            {
                                List<String> oIdsGlobales = oDatosPrevios.idGlobales;
                                chat.CC_IdsGlobales__c = String.join(oIdsGlobales,',');
                            }
                        }
                        //Guardamos los valores de Pilotaje del chat
                        if (String.isBlank(chat.CC_Pilotaje__c) && oDatosPrevios.pilotaje != null)
                        {
                            if (!oDatosPrevios.pilotaje.isEmpty())
                            {
                                List<String> oPilotaje = oDatosPrevios.pilotaje;
                                chat.CC_Pilotaje__c = String.join(oPilotaje,', ');
                            }
                        }

                        //Guardamos los valores de la aplicación origen del chat
                        if (String.isBlank(chat.CC_Aplicacion_Origen__c ) && oDatosPrevios.aplicacionOrigen != null)
                        {
                            if (String.isNotBlank(oDatosPrevios.aplicacionOrigen))
                            {
                                chat.CC_Aplicacion_Origen__c = oDatosPrevios.aplicacionOrigen;
                            }
                        }
                        //US475917: Whatsapp > Chat: contexto agente Start
                        //Guardamos el sourceConversationID y sourceAplicacionCorpus
                        if (String.isBlank(chat.CC_Source_Conversation_Id__c) && !String.isBlank(oDatosPrevios.sourceConversationID))
                        {
                            chat.CC_Source_Conversation_Id__c = oDatosPrevios.sourceConversationID;
                        }
                        if (String.isBlank(chat.CC_Source_Aplicacion_Corpus__c) && !String.isBlank(oDatosPrevios.sourceAplicacionCorpus))
                        {
                            chat.CC_Source_Aplicacion_Corpus__c = oDatosPrevios.sourceAplicacionCorpus;
                        }
                        //US475917: Whatsapp > Chat: contexto agente End

                        //US545644 - Identificar Chat con Origen Transfer
                        if (!oDatosPrevios.conversationUnits.isEmpty())
                        {
                            chat.CC_Chat_Transferido__c  = oDatosPrevios.getIsTransfer();
                        }
                    }
                }
            }
        }

        Id idRecordTypeAplicacion = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Aplicaciones').getRecordTypeId();
        List<CC_FAQ__c> aplicaciones = [SELECT Id, CC_Origen__c, Name, CC_Nombre__c, CC_Id_App__c, CC_Canal_operativo__c FROM CC_FAQ__c
                                                    WHERE RecordType.Id = :idRecordTypeAplicacion AND Name IN :relacionAplicacionProcedencia.keySet()];

        for (CC_FAQ__c aplicacion : aplicaciones) {
            relacionAplicacionProcedencia.put(aplicacion.Name, aplicacion.CC_Origen__c);
            relacionAplicacionCod.put(aplicacion.Name, aplicacion.CC_Id_App__c);
            relacionAplicacionNombre.put(aplicacion.Name,aplicacion.CC_Nombre__c);
            if(aplicacion.CC_Canal_operativo__c != null ) {
                relacionAplicacionCanalOperativo.put(aplicacion.Name, aplicacion.CC_Canal_operativo__c);
            }
        }

        //Informa campo Procedencia en cada transcripción
        for (LiveChatTranscript chat : listNewObj) {
            chat.CC_Canal_Procedencia__c = relacionAplicacionProcedencia.get(chat.CC_Aplicacion__c);

            if(relacionAplicacionCanalOperativo.containsKey(chat.CC_Aplicacion__c)) {
                chat.CC_Canal_operativo__c = relacionAplicacionCanalOperativo.get(chat.CC_Aplicacion__c);
            }
            // Cognitivo 360. Informar el código de aplicación.
            chat.CC_AplicacionId__c = relacionAplicacionCod.get(chat.CC_Aplicacion__c);
            chat.CC_Aplicacion__c = relacionAplicacionNombre.get(chat.CC_Aplicacion__c);
        }
        // Se sustituye listNewObj por oListChat en las dos llamadas al HDT_GestionEntradaChat
        Map<String,Map<String,String>> datosChatRetornados = HDT_GestionEntradaChat.gestionEntradaChats(oListChat);

        for (LiveChatTranscript chat : listNewObj) {
            // Asginar datos creados.
            if (datosChatRetornados != null && !datosChatRetornados.isEmpty())
            {
                if (datosChatRetornados.get(chat.CC_Id_Cognitive__c) != null)
                {
                    Map<String,String> datosActualizar = datosChatRetornados.get(chat.CC_Id_Cognitive__c);
                    if (datosActualizar != null && !datosActualizar.isEmpty())
                    {
                        if (datosActualizar.get('NumCaso') != null)
                        chat.CaseId = datosActualizar.get('NumCaso');

                        if (datosActualizar.get('Cuenta') != null)
                        chat.AccountId = datosActualizar.get('Cuenta');

                        if (datosActualizar.get('Contacto') != null)
                            chat.ContactId = datosActualizar.get('Contacto');

                        if (datosActualizar.get('ChatBotId') != null)
                            chat.CC_ChatOrigen__c = datosActualizar.get('ChatBotId');

                        if (datosActualizar.get('FaqsWatson') != null)
                            chat.CC_FaqsOfrecidas__c = datosActualizar.get('FaqsWatson');
                        //Stop&Go
                        if (datosActualizar.get('LoginUsuario') != null)
                            chat.CC_Login_Agente_Chat_Atendido__c = datosActualizar.get('LoginUsuario');
                    }
                }
            }
        }

        /* Comentado por Moises Cano no aplica para HDT

        Map<String,Map<String,String>> datosChatRetornadosCli = HDT_GestionEntradaChat.gestionEntradaChatsClientes(oListChat);
        for (LiveChatTranscript chat : listNewObj) {

            // Asginar datos creados.
            if (datosChatRetornadosCli != null && !datosChatRetornadosCli.isEmpty())
            {
                if (datosChatRetornadosCli.get(chat.CC_Id_Cognitive__c) != null)
                {
                    Map<String,String> datosActualizar = datosChatRetornadosCli.get(chat.CC_Id_Cognitive__c);
                    if (datosActualizar != null && !datosActualizar.isEmpty())
                    {
                        if (datosActualizar.get('Cuenta') != null)
                        chat.AccountId = datosActualizar.get('Cuenta');

                        if (datosActualizar.get('Contacto') != null)
                        chat.ContactId = datosActualizar.get('Contacto');
                    }
                }
            }
        }*/
    }

    private void informarServicio(List<LiveChatTranscript> listNewObj) {
        //Filtramos los chats de HDT_Empleados
        List<LiveChatTranscript> chatsEmpleadosList = new List<LiveChatTranscript>();
        Id recordTypeIdEmpleado = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByDeveloperName().get('HDT_Empleados').getRecordTypeId();

        for (LiveChatTranscript nuevoChat : listNewObj)
        {
            if (nuevoChat.recordTypeId == recordTypeIdEmpleado && nuevoChat.CC_Tipo__c != 'Chatbot')
            {
                chatsEmpleadosList.add(nuevoChat);
            }
        }

        if (!chatsEmpleadosList.isEmpty())
        {
            //Recupera la relación entre los espacios, categorías y servicios
            List<CC_Lista_Valores__c> relacionesServiciosList = [SELECT Id, Name, CC_Valor__c, CC_Servicio__c, CC_Orden__c FROM CC_Lista_Valores__c
                                                                    WHERE RecordType.DeveloperName = 'CC_Valor' AND CC_Lista__r.Name = 'HDT_Relacion_EspacioCategoria_Skill_Chat' AND CC_Activa__c = true];

            if (!relacionesServiciosList.isEmpty())
            {
                for(LiveChatTranscript chatUpdate: chatsEmpleadosList)
                {
                    for (CC_Lista_Valores__c relacionBuscar: relacionesServiciosList)
                    {
                        //Si es un chat Hidden miramos el Espacio que coincida, si es un chat Agente debe conicidir la Categoría para asignar el Servicio
                        if (chatUpdate.CC_Tipo__c == 'Hidden' && String.isNotBlank(chatUpdate.CC_Espacio__c) && chatUpdate.CC_Espacio__c == relacionBuscar.Name && relacionBuscar.CC_Orden__c == 1)
                        {
                            chatUpdate.CC_Servicio_Chat__c = relacionBuscar.CC_Servicio__c;
                        }
                        else if (chatUpdate.CC_Tipo__c == 'Agente' && String.isNotBlank(chatUpdate.CC_Categoria__c) && chatUpdate.CC_Categoria__c == relacionBuscar.CC_Valor__c)
                        {
                            chatUpdate.CC_Servicio_Chat__c = relacionBuscar.CC_Servicio__c;
                        }
                    }
                }
            }
        }
    }
}