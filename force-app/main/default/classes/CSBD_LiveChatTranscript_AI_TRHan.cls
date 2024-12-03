/**********************************************************************************************************************
Name:     CSBD_LiveChatTranscript_AI_TRHan
Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Clase trigger para el after insert del objeto LiveChatTranscprit
=======================================================================================================================
Historial
---------------------
VERSION     USER_STORY      AUTHOR              DATE                Description
1.0         App CSBD        Esperanza Conde	    02/02/2022          Init version
***********************************************************************************************************************/
public with sharing class CSBD_LiveChatTranscript_AI_TRHan extends CC_TriggerHandlerBase {
    
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<LiveChatTranscript>)tp.newList, (Map<Id, LiveChatTranscript>)tp.newMap);
	}
 
    private void process(List<LiveChatTranscript> listNewObj, Map<Id, LiveChatTranscript> mapNewObj) {
        //Nos quedamos con los transcript de Tipo = CSBD  
        List<LiveChatTranscript> listTranscript = CSBD_LiveChatTranscriptTriggerHelper.checkTipo(listNewObj);  
        methodCSBDApp(listTranscript);
	}

    private void methodCSBDApp(List<LiveChatTranscript> listNewObj) {
        //Cambiar el owner de la oportunidad
        CSBD_LiveChatTranscriptTriggerHelper.asignarOwnerOpp(listNewObj);
        // Crea la tarea
        CSBD_LiveChatTranscriptTriggerHelper.createTaskRelated(listNewObj, null); 

    }
     
}