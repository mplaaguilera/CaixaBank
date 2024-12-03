/**********************************************************************************************************************
Name:     CSBD_LiveChatTranscript_BU_TRHan
Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Clase trigger para el before update del objeto LiveChatTranscprit
=======================================================================================================================
Historial
---------------------
VERSION     USER_STORY      AUTHOR              DATE                Description
1.0         App CSBD        Esperanza Conde	    21/02/2022          Init version
***********************************************************************************************************************/
public with sharing class CSBD_LiveChatTranscript_BU_TRHan extends CC_TriggerHandlerBase {
    
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<LiveChatTranscript>)tp.newList, (Map<Id, LiveChatTranscript>)tp.oldMap);
	}
    
    private void process(List<LiveChatTranscript> listNewObj, Map<Id, LiveChatTranscript> mapOldObj) {
        //Nos quedamos con los transcript de Tipo = CSBD  
        List<LiveChatTranscript> listTranscript = CSBD_LiveChatTranscriptTriggerHelper.checkTipo(listNewObj);  
        methodCSBDApp(listTranscript, mapOldObj);
        
        for(LiveChatTranscript chat: listTranscript){
            if(chat.OwnerId != mapOldObj.get(chat.Id).OwnerId){
                CSBD_LiveChatTranscriptTriggerHelper.asignarOwnerOpp(listTranscript);
            }
        }
	}

    private void methodCSBDApp(List<LiveChatTranscript> listNewObj, Map<Id, LiveChatTranscript> mapOldObj) {
        // Crea la tarea
        CSBD_LiveChatTranscriptTriggerHelper.createTaskRelated(listNewObj, mapOldObj); 
    }
}