/**********************************************************************************************************************
Name:     CSBD_LiveChatTranscript_BI_TRHan
Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Clase trigger para el before insert del objeto LiveChatTranscprit
=======================================================================================================================
Historial
---------------------
VERSION     USER_STORY      AUTHOR              DATE                Description
1.0         App CSBD        Esperanza Conde	    01/02/2022          Init version
***********************************************************************************************************************/
public with sharing class CSBD_LiveChatTranscript_BI_TRHan extends CC_TriggerHandlerBase {
    
	public override void mainEntry(CC_TriggerParameters tp) {
    
		process((List<LiveChatTranscript>)tp.newList, (Map<Id, LiveChatTranscript>)tp.newMap);
	}
    
    private void process(List<LiveChatTranscript> listNewObj, Map<Id, LiveChatTranscript> mapNewObj) {
    
        //Nos quedamos con los transcript de Tipo = CSBD  
        List<LiveChatTranscript> listTranscript = CSBD_LiveChatTranscriptTriggerHelper.checkTipo(listNewObj);  
        methodCSBDApp(listTranscript);
	}

    private void methodCSBDApp(List<LiveChatTranscript> listNewObj) {
      
        //1º Asignar el RT al transcript
        CSBD_LiveChatTranscriptTriggerHelper.assignRTCSBD(listNewObj); 
        //2º Validar el transcript dependiendo del OTP de la cuenta
        CSBD_LiveChatTranscriptTriggerHelper.validarOTP(listNewObj); 
    }

}