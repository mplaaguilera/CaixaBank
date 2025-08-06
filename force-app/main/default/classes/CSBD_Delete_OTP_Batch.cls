/**********************************************************************************************************************
 Name:      CSBD_Delete_OTP_Batch
 Copyright © 2022 CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Batch para eliminar los OTP generados y liberar almacenamiento.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0			App CSBD			Esperanza Conde		09/06/2022			Init version
***********************************************************************************************************************/
public class CSBD_Delete_OTP_Batch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
    
    public Integer recordsProcessed = 0;
    
    /**
     * Crear la lista de oportunidades de chat con el OTP de la .
     *
     * @param bc  Database.BatchableContext param that contains the batch job ID
     */    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String methodName = 'start';
        String query;
        if(!Test.isRunningTest()){
            query = 'SELECT ID FROM CBK_OTP_Generado__c Where RecordType.DeveloperName = \'CSBD_Chat\' AND CreatedDate = YESTERDAY';
        }else{
            query = 'SELECT ID FROM CBK_OTP_Generado__c Where RecordType.DeveloperName = \'CSBD_Chat\' AND CreatedDate = TODAY';
        }

		return Database.getQueryLocator(query); 
    }
        
    /**
     * Borramos los registros
     *
     * @param bc    Database.BatchableContext param that contains the batch job ID
     * @param scope List<CBK_OTP_Generado__c> lista de OTP de CSBD para borrar
     */
    public void execute(Database.BatchableContext bc, List<CBK_OTP_Generado__c> lstOTP){


            if(!lstOTP.isEmpty()){
                recordsProcessed = lstOTP.size();
                Database.delete(lstOTP);
                Database.emptyRecycleBin(lstOTP); 
            }

    }
    
     /**
     * Executes the scheduled Apex job
     *
     * @param sc    SchedulableContext param that contains the job ID
     */
     public void execute(SchedulableContext sc) {
         Database.executeBatch(new CSBD_Delete_OTP_Batch());
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