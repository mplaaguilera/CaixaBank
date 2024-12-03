public with sharing class CC_ChatHistory_Controller {

    public class ChatTexto {
        //Clase de parseo Chat LiveAgent
        String sPersona;
        String sTexto;
        String sTiempo;
        Boolean bCliente;
    }

    @AuraEnabled(cacheable=true)
    public static String dummy() {
        return 'abc';
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_LiveAgent_Cognitive_Chat_Model> getHistoryChat(Id recordId) {
        //Si se llama a getHistoryChat sin el parámetro "Boolean cognitivo" se asume que éste es falso
        return getHistoryChat(recordId, false);
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_LiveAgent_Cognitive_Chat_Model> getHistoryChat(Id recordId, Boolean cognitivo) {

		System.debug('getHistoryChat(' + recordId + ', ' + cognitivo + ')');
		System.debug('recordId.getSObjectType() = ' + recordId.getSObjectType());
		System.debug('LiveChatTranscript.getSObjectType() = ' + LiveChatTranscript.getSObjectType());

        List<CC_LiveAgent_Cognitive_Chat_Model> oListConv = new List<CC_LiveAgent_Cognitive_Chat_Model>();
        List<LiveChatTranscript> conversaciones = new List<LiveChatTranscript>();

        //Se recuperan las transcripciones a renderizar en función de la página en la que está el componente
        if (recordId.getSObjectType() == Task.sObjectType) {
            //Tarea
            Task actividad = [SELECT CC_LiveChatTranscript_Id__c FROM Task WHERE Id = :recordId LIMIT 1];
            conversaciones = [SELECT Body, ContactId, Contact.Name, EndedBy, CaseId, CC_Cognitive_chat__c,
                                    CC_Nickname__c, CC_Tipo__c, StartTime, EndTime, CC_ChatOrigen__c, RecordTypeId, RecordType.Name
                                FROM LiveChatTranscript WHERE Id = :actividad.CC_LiveChatTranscript_Id__c LIMIT 1];
        } else if (recordId.getSObjectType() == Case.sObjectType) {
            //Caso
            conversaciones = [SELECT Body, ContactId, Contact.Name, EndedBy, CaseId, CC_Cognitive_chat__c,
                                    CC_Nickname__c, CC_Tipo__c, StartTime, EndTime, CC_ChatOrigen__c, RecordTypeId, RecordType.Name
                                FROM LiveChatTranscript WHERE CaseId = :recordId ORDER BY CC_Orden__c ASC, CreatedDate ASC];
        } else if (recordId.getSObjectType() == LiveChatTranscript.sObjectType && !cognitivo) {
            //Transcripción de chat (sin flag mostrar cognitivo)
            conversaciones = [SELECT Body, ContactId, Contact.Name, EndedBy, CaseId, CC_Cognitive_chat__c,
                                    CC_Nickname__c, CC_Tipo__c, StartTime, EndTime, CC_ChatOrigen__c, RecordTypeId, RecordType.Name
                                FROM LiveChatTranscript WHERE Id = :recordId LIMIT 1];
        } else if (recordId.getSObjectType() == LiveChatTranscript.sObjectType && cognitivo) {
            //Transcripción de chat (con flag mostrar cognitivo)
            Id idChatOrigen = [SELECT CC_ChatOrigen__c, CC_Source_Conversation_Id__c, CC_Source_Aplicacion_Corpus__c FROM LiveChatTranscript WHERE Id = :recordId LIMIT 1].CC_ChatOrigen__c;
            conversaciones = [SELECT Body, ContactId, Contact.Name, EndedBy, CaseId, CC_Cognitive_chat__c,
                                    CC_Nickname__c, CC_Tipo__c, StartTime, EndTime, CC_ChatOrigen__c, CC_ChatOrigen__r.CC_Tipo__c, RecordTypeId, RecordType.Name
                                    FROM LiveChatTranscript WHERE Id = :idChatOrigen LIMIT 1];
			if (!conversaciones.isEmpty()) {
				if (!String.isBlank(conversaciones[0].CC_ChatOrigen__c) && conversaciones[0].CC_ChatOrigen__r.CC_Tipo__c=='Whatsapp') {
					conversaciones.addAll([SELECT Body, ContactId, Contact.Name, EndedBy, CaseId, CC_Cognitive_chat__c,
                                    CC_Nickname__c, CC_Tipo__c, StartTime, EndTime, CC_ChatOrigen__c, RecordTypeId, RecordType.Name
									FROM LiveChatTranscript WHERE Id=:conversaciones[0].CC_ChatOrigen__c LIMIT 1]);
				}
			}
        } else if (recordId.getSObjectType() == CC_Llamada__c.sObjectType) {
            //Llamada
            CC_Llamada__c llamada = [SELECT CC_Id_Cognitivo__c FROM CC_Llamada__c WHERE Id = :recordId];
            conversaciones = [SELECT Body, ContactId, Contact.Name, EndedBy, CaseId, CC_Cognitive_chat__c,
                                    CC_Nickname__c, CC_Tipo__c, StartTime, EndTime, CC_ChatOrigen__c, RecordTypeId, RecordType.Name
                                FROM LiveChatTranscript WHERE CC_Id_Cognitive__c = :llamada.CC_Id_Cognitivo__c AND CC_Id_Cognitive__c != NULL
                                ORDER BY CC_Orden__c ASC, CreatedDate ASC];
        } else {
            return null;
        }
        for (LiveChatTranscript conversacion : conversaciones) {
            CC_LiveAgent_Cognitive_Chat_Model chat;
            //TO_DO: Tratar el agente Hidden

            if (conversacion.CC_Tipo__c == 'Chatbot') {
                chat = getChatCognitivo(conversacion);
			} else if (conversacion.CC_Tipo__c == 'Whatsapp') {
				chat = getChatWhatsappContext(conversacion);
            } else {
                chat = getChatAgente(conversacion);
            }

            if (chat != null) {
                oListConv.add(chat);
            }
        }

        return oListConv;
    }
    public static CC_LiveAgent_Cognitive_Chat_Model getChatCognitivo(LiveChatTranscript oChat) {
        //Se comprueba si la conversación con ChatBot ha derivado en una conversación con agente

        Boolean traspasadoAgente = true;
        if ([SELECT Count() FROM LiveChatTranscript WHERE CC_Tipo__c != 'Chatbot' AND CC_ChatOrigen__c = :oChat.Id] == 0) {
            traspasadoAgente = false;
        }

        //Se recupera la conversación a partir del JSON recibido
        CC_Cognitive_Chat_JSON json = CC_Cognitive_Chat_JSON.parse(oChat.CC_Cognitive_chat__c);

        //Si se ha podido recuperar la conversación se retorna su estructura para renderizarla, si no se retorna nulo
        if (json != null) {
            List<CC_LiveAgent_Cognitive_Chat_Model> listaChats = json.getConversacion(oChat.CC_Nickname__c, traspasadoAgente, oChat.RecordType.Name);
            return listaChats[0]; //El método devuelve una lista de un solo chat
        } else {
            return null;
        }
    }

	public static CC_LiveAgent_Cognitive_Chat_Model getChatWhatsappContext(LiveChatTranscript oChat) {
        // La conversación contexto Whatsapp deriva en una conversación con agente
        Boolean traspasadoAgente = true;
        if ([SELECT Count() FROM LiveChatTranscript WHERE CC_Tipo__c = 'Chatbot' AND CC_Tipo__c != 'Whatsapp' AND CC_ChatOrigen__c = :oChat.Id] == 0) {
            traspasadoAgente = false;
        }

        //Se recupera la conversación a partir del JSON recibido
        CC_Cognitive_Chat_JSON json = CC_Cognitive_Chat_JSON.parse(oChat.CC_Cognitive_chat__c);

        //Si se ha podido recuperar la conversación se retorna su estructura para renderizarla, si no se retorna nulo
        if (json != null) {
            List<CC_LiveAgent_Cognitive_Chat_Model> listaChats = json.getConversacion(oChat.CC_Nickname__c, traspasadoAgente, oChat.RecordType.Name);
            return listaChats[0]; //El método devuelve una lista de un solo chat
        } else {
            return null;
        }
    }

    public static CC_LiveAgent_Cognitive_Chat_Model getChatAgente(LiveChatTranscript oChat) {

        CC_LiveAgent_Cognitive_Chat_Model oConv = new CC_LiveAgent_Cognitive_Chat_Model();
        try {
            Integer iId = 0;
            String sContacto = oChat.Contact.Name;
            String sFin = oChat.EndedBy;
            String sAgente = '';

            if (oChat.Body == null) {
                oConv.inicio = 'Chat iniciado. ';
                oConv.inicio2 = 'Transcripción no disponible.';
                oConv.fin = 'Chat finalizado. ';
                oConv.fin2 = 'Transcripción no disponible.';
                return oConv;
            }

            //Buscaremos el tipo de chat anterior. Ahora tenemos el chatbot y agente, pendiente definir con cognitivo
            Boolean traspasadoAgente = false;
            if ([SELECT Count() FROM LiveChatTranscript WHERE CC_Tipo__c = 'Chatbot' AND Id = :oChat.CC_ChatOrigen__c] > 0) {
                traspasadoAgente = true;
            }

            //Buscar el nombre del agente
            List<String> oListAg = oChat.Body.split('<p align="center">Agent(\\s|\\S\\s)');
            if (oListAg.size() == 2) {
                sAgente = oListAg[1].substring(0, oListAg[1].indexOf('<'));
                sAgente = sAgente.trim();
            }

            //Limpiar Cabecera Transcripción Chat
            oChat.Body = oChat.Body.replaceAll('<p align=(\\s|\\S)*<\\/p>', '');
            oChat.Body = oChat.Body.trim();

            //Recuperar la lista de textos del chat (sin tiempos)
            Map<Integer, ChatTexto> oMapChats = new Map<Integer, ChatTexto>();
            List<String> sTextos = oChat.Body.split('\\(\\s(\\d+m\\s)?\\d+s\\s\\)');
            String sAux = '';
            String sPersonaAux = '';
            String sTextoAux = '';

            //Recorrer los textos. El primero está vacío del split
            for (Integer i = 1; i < sTextos.size(); i++) {
                sAux = sTextos[i].trim();
                sPersonaAux = sAux.substring(0, sAux.indexOf(':')).trim();
                sTextoAux = sAux.substring(sAux.indexOf(':') + 2).trim();

                //Limpiar <br> final
                if (sTextoAux.endsWith('<br>')) {
                    sTextoAux = sTextoAux.left(sTextoAux.length() - 4);
                }

                //Añadir el chat a la lista
                ChatTexto oChatAux = new ChatTexto();
                oChatAux.sPersona = sPersonaAux;
                oChatAux.sTexto = sTextoAux;

                if (sContacto == sPersonaAux) {
                    //Cliente detectado
                    oChatAux.bCliente = true;
                } else {
                    if (sAgente == sPersonaAux) {
                        //Agente detectado
                        oChatAux.bCliente = false;
                    } else {
                        //Cliente por omisión
                        oChatAux.bCliente = true;
                    }
                }
                oMapChats.put(i, oChatAux);
            }

            //Recorrer los tiempos
            Pattern oPatt = Pattern.compile('\\(\\s(\\d+m\\s)?\\d+s\\s\\)');
            Matcher oMatcher = oPatt.matcher(oChat.Body);
            Integer iCont = 1;
            while (oMatcher.find()) {
                //Control de tamaño de la lista de Textos Chats
                if (iCont <= oMapChats.size()) {
                    sAux = oMatcher.group();
                    sAux = sAux.substring(2, sAux.length() - 2);
                    ChatTexto oChatAux = oMapChats.get(iCont);
                    oChatAux.sTiempo = sAux;
                    oMapChats.put(iCont, oChatAux);
                }
                iCont++;
            }

            //Inicio Chat
            ChatTexto oChatAux = new ChatTexto();
            oChatAux.sPersona = sContacto;
            if (traspasadoAgente) {
                if (sAgente != '') {
                    oChatAux.sTexto = 'Chat transferido al agente ' + sAgente;
                } else {
                    oChatAux.sTexto = 'Chat transferido a un agente';
                }
            } else {
                /*if(oChat.RecordType.Name =='Clientes'){*/
                    oChatAux.sTexto = 'Chat iniciado por el cliente1234';
               /* }else{
                    oChatAux.sTexto = 'Chat iniciado por el empleado';
                }*/

            }

            if (oChat.StartTime != null) {
                oChatAux.sTexto = oChatAux.sTexto + ' el ' + oChat.StartTime.format();
            }
            oChatAux.bCliente = true;
            oMapChats.put(0, oChatAux);

            //Fin Chat
            ChatTexto oChatAux2 = new ChatTexto();
            oChatAux2.sPersona = sContacto;
            if (sFin == 'Visitor') {
                oChatAux2.bCliente = true;
                oChatAux2.sTexto = 'Chat finalizado por ' + sContacto;
            } else {
                oChatAux2.bCliente = false;
                oChatAux2.sTexto = 'Chat finalizado por el agente';
            }

            if (oChat.EndTime != null) {
                oChatAux2.sTexto = oChatAux2.sTexto + ' el ' + oChat.EndTime.format();
            }
            oMapChats.put(oMapChats.size(), oChatAux2);

            //Conversión a la estructura final.
            List<CC_LiveAgent_Cognitive_Chat_Model.Mensaje> oListMsg = new List<CC_LiveAgent_Cognitive_Chat_Model.Mensaje>();
            for (Integer i = 0; i < oMapChats.size(); i++) {
                if (i == 0) {
                    // Mensaje de inicio chat.
                    oConv.Inicio = oMapChats.get(i).sTexto;
                } else if (i == oMapChats.size() - 1) {
                    // Mensaje de fin de chat.
                    oConv.Fin = oMapChats.get(i).sTexto;
                } else {
                    iId++;
                    CC_LiveAgent_Cognitive_Chat_Model.Mensaje oMsg = new CC_LiveAgent_Cognitive_Chat_Model.Mensaje();
                    oMsg.Texto = oMapChats.get(i).sTexto;
                    oMsg.Hora = oMapChats.get(i).sTiempo;
                    oMsg.Nombre = oMapChats.get(i).sPersona;
                    oMsg.Cliente = oMapChats.get(i).bCliente;
                    oMsg.Id = String.valueOf(iId);
                    oListMsg.add(oMsg);
                }
            }
            oConv.Mensajes = oListMsg;
        } catch (Exception e) {
            oConv.inicio = 'Chat iniciado. ';
            oConv.inicio2 = 'Transcripción no disponible.';
            oConv.fin = 'Chat finalizado. ';
            oConv.fin2 = 'Transcripción no disponible.';
        }

        return oConv;
    }
    @AuraEnabled(cacheable=true)
    public static Boolean getVacio(Id recordId, Boolean cognitivo) {
        List<LiveChatTranscript> conversaciones = new List<LiveChatTranscript>();
        //Se recuperan las transcripciones a renderizar en función de la página en la que está el componente
        if (recordId.getSObjectType() == Task.sObjectType) {
            Task actividad = [SELECT CC_LiveChatTranscript_Id__c FROM Task WHERE Id = :recordId LIMIT 1];
            conversaciones = [SELECT Body, ContactId, Contact.Name, EndedBy, CaseId, CC_Cognitive_chat__c,
                                    CC_Nickname__c, CC_Tipo__c, StartTime, EndTime, CC_ChatOrigen__c
                                FROM LiveChatTranscript WHERE Id = :actividad.CC_LiveChatTranscript_Id__c LIMIT 1];
        } else if (recordId.getSObjectType() == Case.sObjectType) {
            conversaciones = [SELECT Body, ContactId, Contact.Name, EndedBy, CaseId, CC_Cognitive_chat__c,
                                    CC_Nickname__c, CC_Tipo__c, StartTime, EndTime, CC_ChatOrigen__c
                                FROM LiveChatTranscript WHERE CaseId = :recordId ORDER BY CC_Orden__c ASC, CreatedDate ASC];
        } else if (recordId.getSObjectType() == LiveChatTranscript.sObjectType && !cognitivo) {
            conversaciones = [SELECT Body, ContactId, Contact.Name, EndedBy, CaseId, CC_Cognitive_chat__c,
                                    CC_Nickname__c, CC_Tipo__c, StartTime, EndTime, CC_ChatOrigen__c
                                FROM LiveChatTranscript WHERE Id = :recordId LIMIT 1];
        } else if (recordId.getSObjectType() == LiveChatTranscript.sObjectType && cognitivo) {
            Id idChatOrigen = [SELECT CC_ChatOrigen__c FROM LiveChatTranscript WHERE Id = :recordId LIMIT 1].CC_ChatOrigen__c;
            conversaciones = [SELECT Body, ContactId, Contact.Name, EndedBy, CaseId, CC_Cognitive_chat__c,
                                    CC_Nickname__c, CC_Tipo__c, StartTime, EndTime, CC_ChatOrigen__c
                                    FROM LiveChatTranscript WHERE Id = :idChatOrigen LIMIT 1];
        } else if (recordId.getSObjectType() == CC_Llamada__c.sObjectType) {
            CC_Llamada__c llamada = [SELECT CC_Id_Cognitivo__c FROM CC_Llamada__c WHERE Id = :recordId];
            conversaciones = [SELECT Body, ContactId, Contact.Name, EndedBy, CaseId, CC_Cognitive_chat__c,
                                    CC_Nickname__c, CC_Tipo__c, StartTime, EndTime, CC_ChatOrigen__c, RecordTypeId, RecordType.Name
                                FROM LiveChatTranscript WHERE CC_Id_Cognitive__c = :llamada.CC_Id_Cognitivo__c AND CC_Id_Cognitive__c != NULL
                                ORDER BY CC_Orden__c ASC, CreatedDate ASC];
        } else {
            return null;
        }

        Boolean vacio = (conversaciones.size() == 0);
        return vacio;
    }
}