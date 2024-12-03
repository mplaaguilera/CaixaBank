/**********************************************************************************************************************
 Name:	  AV_DeleteRecordsCarteraBatchQueueable
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch Queueable que conecta con AV_DeleteRecordsCarteraBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY		AUTHOR				DATE				Description
   1.0			App FSC			Sandra Gómez		01/02/2021			Init version
   1.1			USXXXXXX		Sandra Gómez		22/11/2021			add FWK Batches

***********************************************************************************************************************/
global class AV_DeleteRecordsCarteraBatchQueueable implements Queueable{
	 /**
	 * Executes the Queueable job
	 *
	 * @param qc	QueueableContext param that contains the context of the queueable
	 */
	global void execute(QueueableContext qc) {
		Set<String> listUser = new Set<String>();
		listUser.add(UserInfo.getUserId());
		AV_ScheduleBatch__mdt proccessBatch = [SELECT AV_Limit__c FROM AV_ScheduleBatch__mdt WHERE DeveloperName = 'AV_DeleteCartera' LIMIT 1];
		map<String,Object> params = new map<String,Object>();
		params.put('limitBatch',proccessBatch.AV_Limit__c);
		params.put('setUserIds',listUser);
		String paramStr = JSON.serialize(params);  
		CBK_BatchJob.executeBatchFuture('AV_DeleteRecordsCarteraBatch', 200 ,paramStr); 
	}
}