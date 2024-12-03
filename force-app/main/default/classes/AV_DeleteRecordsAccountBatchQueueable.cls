/**********************************************************************************************************************
 Name:	  AV_DeleteRecordsAccountBatchQueueable
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch Queueable que conecta con AV_DeleteRecordsAccountBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY		AUTHOR				DATE				Description
   1.0			App FSC			Sandra Gómez		01/02/2021			Init version
   1.1			USXXXXXX		Sandra Gómez		22/11/2021			add FWK Batches
   1.2		    AV_Query IT	    Daniel Rodríguez	02/03/2022	        Change AV_Query to SOQL for User, Account, Contact
   1.3			FIX11070844		Ángel Medina		11/07/2024			Fix error The Global modifier should be avoided.
***********************************************************************************************************************/
public class AV_DeleteRecordsAccountBatchQueueable implements Queueable{
	 /**
	 * Executes the Queueable job
	 *
	 * @param qc	QueueableContext param that contains the context of the queueable
	 */
	public void execute(QueueableContext qc) {
		Set<String> listUser = new Set<String>();
		listUser.add(UserInfo.getUserId());
		AV_ScheduleBatch__mdt proccessBatch = [Select AV_Limit__c from AV_ScheduleBatch__mdt where DeveloperName = 'AV_DeleteAccounts' limit 1];
		map<String,Object> params = new map<String,Object>();
		params.put('limitBatch',proccessBatch.AV_Limit__c);
		params.put('setUserIds',listUser);
		String paramStr = JSON.serialize(params);  
		CBK_BatchJob.executeBatchFuture('AV_DeleteRecordsAccountBatch', 200 ,paramStr); 
		//Database.executeBatch(new AV_DeleteRecordsAccountBatch());
	}
}