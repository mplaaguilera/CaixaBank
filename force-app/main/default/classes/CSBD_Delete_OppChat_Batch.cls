/**********************************************************************************************************************
 Name:      CSBD_Delete_OppChat_Batch
 Copyright © 2022 CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Batch para eliminar las oportunidades de chat que finalmente no fueron relacionadas a un chat.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0			App CSBD			Esperanza Conde		08/03/2022			Init version
***********************************************************************************************************************/
public class CSBD_Delete_OppChat_Batch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
    
    public Integer recordsProcessed = 0;
    
    /**
     * Crear la lista de oportunidades de chat con el OTP de la .
     *
     * @param bc  Database.BatchableContext param that contains the batch job ID
     */    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String methodName = 'start';
        String query = 'SELECT ID FROM Opportunity Where StageName = \'Solicitud\' AND RecordType.DeveloperName = \'CSBD_Chat\' AND CreatedDate = TODAY';

		return Database.getQueryLocator(query); 
    }
        
    /**
     * Checkeamos que no tiene chat relacionados
     *
     * @param bc    Database.BatchableContext param that contains the batch job ID
     * @param scope List<Opportunity> lista de oportunidades de CSBD aún abiertas
     */
    public void execute(Database.BatchableContext bc, List<Opportunity> lstOpp){
        String methodName = 'execute';

        Set<Id> setId = new Set<Id>();
        List<Id> idOppChat = new List<Id>();
        List<Opportunity> lstOppToDelete = new List<Opportunity>();

        try{

            if(!lstOpp.isEmpty()){
                for(Opportunity opp : lstOpp){
                    setId.add(opp.Id);
                }

                if(!setId.isEmpty()){

                    List<LiveChatTranscript> lstTranscript = [Select Id, CSBD_Oportunidad_Id__c from LiveChatTranscript where CSBD_Oportunidad_Id__c in: setId];
                    if(!lstTranscript.isEmpty()){
                        for(LiveChatTranscript chatTranscript : lstTranscript){
                            idOppChat.add(chatTranscript.CSBD_Oportunidad_Id__c);
                        }
                    }
                    for(Opportunity opp : lstOpp){
                        if(!idOppChat.contains(opp.Id)){
                            lstOppToDelete.add(opp);
                        }
                    }
                }
            }
            if(!lstOppToDelete.isEmpty()){
                recordsProcessed = lstOppToDelete.size();
                Database.delete(lstOppToDelete,false);
            } 
        } catch(Exception ex){
            CBK_Log.error(ex);
        }
    }
    
     /**
     * Executes the scheduled Apex job
     *
     * @param sc    SchedulableContext param that contains the job ID
     */
     public void execute(SchedulableContext sc) {
         Database.executeBatch(new CSBD_Delete_OppChat_Batch());
     }
       

    /**
     * Print the results of the batch process
     *
     * @param bc    Database.BatchableContext param that contains the batch job ID
     */
    public void finish(Database.BatchableContext bc){
        CBK_Log.debug('Record Processed: ');
    } 
}