public with sharing class HDT_LiveChatTranscript_AI_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<LiveChatTranscript>)tp.newList); //(Map<Id, LiveChatTranscript>)tp.newMap
	}

	private void process(List<LiveChatTranscript> listNewObj) { //Map<Id, LiveChatTranscript> mapNewObj

        List<LiveChatTranscript> nuevosChatsCognitivo = new List<LiveChatTranscript>();
        Map<Id, Integer> mapeoArrays = new Map<Id, Integer>();
        List<Id> listadoChatsCreadosEmpleados = new List<Id>();

        Id idRtChatHdt = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByDeveloperName().get('HDT_Empleados').getRecordTypeId();
		for (LiveChatTranscript chatAgente : listNewObj) {
            // Desvinculamos el código para los chats de empleados.
            if (chatAgente.CC_Tipo__c != 'Chatbot' && chatAgente.RecordTypeId == idRtChatHdt) {
                // Para los chats de empleados HDT, tras finalizar su creación y antes de enrutamiento, procedemos a lanzar de
                // forma asíncrona la actualización del caso y creación de tareas. FIX. LOCK_ROW en la entrada de chats de empleados.
                listadoChatsCreadosEmpleados.add(chatAgente.Id);
            }
        }

        if (!listadoChatsCreadosEmpleados.isEmpty())
        {
            // Llamada asíncrona para actualizar el caso y crear tareas.
            HDT_GestionEntradaChat.actualizarDatosChatAIFuture(listadoChatsCreadosEmpleados);
        }
	}

}