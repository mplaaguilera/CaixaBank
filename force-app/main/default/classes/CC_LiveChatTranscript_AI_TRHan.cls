public with sharing class CC_LiveChatTranscript_AI_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<LiveChatTranscript>)tp.newList); //(Map<Id, LiveChatTranscript>)tp.newMap
	}

	private void process(List<LiveChatTranscript> listNewObj) { //Map<Id, LiveChatTranscript> mapNewObj

        List<LiveChatTranscript> nuevosChatsCognitivo = new List<LiveChatTranscript>();
        Map<Id, Integer> mapeoArrays = new Map<Id, Integer>();
        List<ID> listadoChatsCreadosEmpleados = new List<ID>();

        Id rtHdtId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('LiveChatTranscript', 'HDT_Empleados');
        Id rtEmpleadosId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('LiveChatTranscript', 'CC_Empleados');
        Id rtCSBD = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('LiveChatTranscript', 'CSBD_Gestor');

		for (LiveChatTranscript chatAgente : listNewObj) {
            // Desvinculamos el código para los chats de empleados.
            if (chatAgente.RecordTypeId != rtEmpleadosId && chatAgente.RecordTypeId != rtHdtId && chatAgente.RecordTypeId != rtCSBD)
            {
                //Para cada transcripción
                try {
                    //Creación de un nuevo Chat para el Cognitivo
                    if (chatAgente.CC_Tipo__c != 'Chatbot' && chatAgente.CC_Tipo__c != 'Whatsapp' && chatAgente.CC_Cognitive_chat__c != null && chatAgente.CC_Cognitive_chat__c != '') {
                        LiveChatTranscript nuevoChatCognitivo = new LiveChatTranscript();
                        String jsonInput = chatAgente.CC_Cognitive_chat__c;
                        jsonInput = jsonInput.replaceAll('\b','').replaceAll('\f','').replaceAll('\n','').replaceAll('\r','').replaceAll('\t','');
                        CC_Cognitive_Chat_JSON json = CC_Cognitive_Chat_JSON.parse(jsonInput);
                        nuevoChatCognitivo.CC_Tipo__c = 'Chatbot';
                        nuevoChatCognitivo.CC_NumEmpleado__c = chatAgente.CC_NumEmpleado__c;
                        nuevoChatCognitivo.RecordTypeId = chatAgente.RecordTypeId;
                        nuevoChatCognitivo.LiveChatVisitorId = chatAgente.LiveChatVisitorId;
                        nuevoChatCognitivo.CC_Nickname__c = chatAgente.CC_Nickname__c;
                        nuevoChatCognitivo.CC_Cognitive_chat__c = chatAgente.CC_Cognitive_chat__c;
                        nuevoChatCognitivo.Body = json.getChatHTML(chatAgente.CC_Nickname__c);
                        nuevoChatCognitivo.StartTime = json.fechaInicio;
                        nuevoChatCognitivo.EndTime = json.fechaFin;
                        nuevoChatCognitivo.CC_Espacio__c = chatAgente.CC_Espacio__c;
                        nuevoChatCognitivo.CC_Categoria__c = chatAgente.CC_Categoria__c;
                        nuevoChatCognitivo.CC_Cognitive_chat__c = chatAgente.CC_Cognitive_chat__c;
                        nuevoChatCognitivo.CC_Canal_Procedencia__c = chatAgente.CC_Canal_Procedencia__c;
                        nuevoChatCognitivo.Status = 'Completed';
                        nuevoChatCognitivo.CC_Id_Cognitive__c = chatAgente.CC_Id_Cognitive__c;
                        if(chatAgente.CC_Canal_operativo__c != null) {
                            nuevoChatCognitivo.CC_Canal_operativo__c = chatAgente.CC_Canal_operativo__c;
                        }

                        nuevosChatsCognitivo.add(nuevoChatCognitivo);

                        //Guarda mapeo entre chats para vincularlos cuando se disponga del Id
                        mapeoArrays.put(chatAgente.Id, nuevosChatsCognitivo.size() - 1);
                    }

                } catch (Exception e) {
                    System.debug('Error ' + e.getMessage());
                    chatAgente.addError('No ha sido posible crear la transcripción para el chat cognitivo. ' + e.getMessage());
                    continue; //Siguiente iteración del for
                }
            }else if(chatAgente.RecordTypeId != rtHdtId){
                // Para los chats de empleados, tras finalizar su creación y antes de enrutamiento, procedemos a lanzar de forma asíncrona la actualización del caso y creación de tareas.
                // FIX. LOCK_ROW en la entrada de chats de empleados.
                if (chatAgente.CC_Tipo__c != 'Chatbot')
                {
                    listadoChatsCreadosEmpleados.add(chatAgente.Id);
                }
            }
        }

        if (!nuevosChatsCognitivo.isEmpty()) {
            //Insert de las transcripciones de cognitivo
            insert nuevosChatsCognitivo;

            //Vinculación de las nuevas transcripciones ahora que se dispone de los Ids
            List<LiveChatTranscript> chatsAgenteModificar = [SELECT Id FROM LiveChatTranscript WHERE Id IN :listNewObj]; //no es posible DML con los params de entrada del trigger
            for (LiveChatTranscript chatAgente : chatsAgenteModificar) {
                chatAgente.CC_ChatOrigen__c = nuevosChatsCognitivo[mapeoArrays.get(chatAgente.Id)].Id;
            }
            update chatsAgenteModificar;
        }

        if (!listadoChatsCreadosEmpleados.isEmpty())
        {
            // Llamada asíncrona para actualizar el caso y crear tareas.
            CC_GestionEntradaChat.actualizarDatosChatAIFuture(listadoChatsCreadosEmpleados);
        }
	}

	//public override void inProgressEntry(CC_TriggerParameters tp) {
	//	System.debug('Código para la gestión de reentradas en caso necesario...');
	//}

	/*private static void envioAltaSiebel(Map<Id, LiveChatTranscript> listNewObj) {
        //Detectar el cierre de chat para envío de datos a Siebel
        Set<Id> chats = new Set<Id>();
        for (Id key : listNewObj.keySet()) {
			chats.add(key);
        }

        //Realizar el envío a Siebel. Lanzamos un máximo de 50 callouts (límite Hard), con las llamadas repartidas.
        if (!chats.isEmpty()) {
            List<Id> oIDList = new List<Id>(chats);
            Integer j = 1;
            Map<Integer, Set<Id>> oMap = new Map<Integer, Set<Id>>();
            for (Integer i = 0; i < oIDList.size(); i++) {
                if (j > 50) j = 1;

                //Inicializar listas.
                if (oMap.get(j) == null) {
                    Set<ID> oSet = new Set<ID>();
                    oMap.put(j, oSet);
                }

                //Añadir valor.
                oMap.get(j).add(oIDList[i]);
                j++;
            }

            //Lanzar llamadas Futuras
            for (Integer i : oMap.keySet())
            {
                CC_Siebel_Alta_Chat.CC_Siebel_Alta_Chat(oMap.get(i));
            }

            oIDList.clear();
            oIDList = null;

            oMap.clear();
            oMap = null;
        }

        chats.clear();
        chats = null;
    }*/
}