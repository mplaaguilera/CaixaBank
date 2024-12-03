public with sharing class CC_LiveChatTranscript_AU_TRHan extends CC_TriggerHandlerBase  {
	public override void mainEntry(CC_TriggerParameters tp) {

        process((List<LiveChatTranscript>)tp.newList,(Map<Id, LiveChatTranscript>)tp.oldMap); //(Map<Id, LiveChatTranscript>)tp.newMap
	}
	
    private void process(List<LiveChatTranscript> listNewObj, Map<Id, LiveChatTranscript> mapNewObj) {
        


        //Informa Origen a partir de la Procedencia antes de guardar el registro
        //Descartar los que vengan de CSBD
        List<LiveChatTranscript> listNewTranscript = new List<LiveChatTranscript>();
        for(LiveChatTranscript transcript : listNewObj){
            if(transcript.CC_Tipo__c != 'CSBD' && transcript.UserAgent != 'ChatdeempleadosHDT'){
                listNewTranscript.add(transcript);
            }
        }
        if(!listNewTranscript.isEmpty()){
            processAux(listNewTranscript, mapNewObj);
        }

        
	}


	private void processAux(List<LiveChatTranscript> listNewObj, Map<Id, LiveChatTranscript> mapOldObj) { //Map<Id, LiveChatTranscript> mapNewObj
      
        
		List<LiveChatTranscript> chatsUpdCase = new list<LiveChatTranscript>();        
        for (LiveChatTranscript chatAgente : listNewObj){            
            //Se modifica el espacio, la categor?a o el caso asociado
            if ((chatAgente.CC_Espacio__c!=mapOldObj.get(chatAgente.Id).CC_Espacio__c) ||
                (chatAgente.CC_Categoria__c!=mapOldObj.get(chatAgente.Id).CC_Categoria__c)||
                (chatAgente.caseId != mapOldObj.get(chatAgente.Id).caseId)
               )
            {
                chatsUpdCase.add(chatAgente);
            }
        }
        
        if (!chatsUpdCase.isEmpty()) {
            system.debug('NMA AU');
                CC_MCC_Preclasificacion.preclasificarCasosObj(chatsUpdCase);
                // NO DESCOMENTAR ESTO: CC_Encuestas_Chat.generarEncuesta(chatsUpdCase);
        }
       
    }
   
}