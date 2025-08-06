public with sharing class CSBD_LiveAgent_BackgroundItemController {
    public static final String TIMEOUT_STATUS = 'TimeOut';
    @AuraEnabled
	public static void onCloseChatEvent(Id recordId) {
        try{
            if(recordId != null){
                List<LiveChatTranscript> chatList = [
                    SELECT CSBD_Oportunidad_Id__c, 
                        CSBD_Oportunidad_Id__r.CSBD_PrimerContactoSLA__c, 
                        CSBD_Oportunidad_Id__r.CSBD_SLA_Primera_Respuesta__c, 
                        CSBD_Oportunidad_Id__r.CSBD_SLA_TGT__c, 
                        CSBD_Oportunidad_Id__r.CSBD_SLA_TMO__c 
                    FROM LiveChatTranscript 
                    WHERE Id = :recordId AND 
                    CSBD_Oportunidad_Id__c != null
                    LIMIT 1
                ];
                //significa que es un chat de CSBD porque tiene Oportunidad
                if(!chatList.isEmpty()){
                    LiveChatTranscript chat = chatList[0];
                    //find if a time out event was capture
                    CSBD_LiveAgent_Welcome_Controller.Response resp = CSBD_LiveAgent_Welcome_Controller.searchEventTranscript(recordId);
                    Boolean timeout = (resp.status == TIMEOUT_STATUS);
                    //end chat logic - task creation 
                    CSBD_LiveAgent_Welcome_Controller.finChat(recordId, timeout);
                    //update SLA in Opportunity
                    if (chat.CSBD_Oportunidad_Id__r.CSBD_SLA_TGT__c == null && chat.CSBD_Oportunidad_Id__r.CSBD_PrimerContactoSLA__c != null) {
                        Datetime now = Datetime.now();
                        Datetime oppPrimerContact = chat.CSBD_Oportunidad_Id__r.CSBD_PrimerContactoSLA__c;
                        Integer tiempoAtencion = Math.round((now.getTime() - oppPrimerContact.getTime() ) / 1000);

                        Opportunity opp = new Opportunity();
                        opp.Id = chat.CSBD_Oportunidad_Id__c;
                        opp.CSBD_SLA_TGT__c = tiempoAtencion;
                        update opp;
                    }
                }
            }
        }catch(Exception ex){
            throw new AuraException('An error occurs: ' + ex.getMessage());
        }    
	}
}