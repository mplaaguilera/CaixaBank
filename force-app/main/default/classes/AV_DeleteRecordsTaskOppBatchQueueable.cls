/**********************************************************************************************************************
 Name:	  AV_DeleteRecordsTaskOppBatchQueueable
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch Queueable que conecta con AV_DeleteRecordsTaskOppBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY		AUTHOR				DATE				Description
   1.0			App FSC			Sandra Gómez		01/02/2021			Init version
   1.1			USXXXXXX		Sandra Gómez		22/11/2021			add FWK Batches
   1.2		    AV_Query IT	    Daniel Rodríguez    03/03/2022	        Change AV_Query to SOQL for User, Account, Contact


***********************************************************************************************************************/
global class AV_DeleteRecordsTaskOppBatchQueueable implements Queueable{
	 /**
	 * Executes the Queueable job
	 *
	 * @param qc	QueueableContext param that contains the context of the queueable
	 */
	global void execute(QueueableContext qc) {
		Set<String> listUser = new Set<String>();
		listUser.add(UserInfo.getUserId());
		AV_ScheduleBatch__mdt proccessBatch = [Select AV_Limit__c from AV_ScheduleBatch__mdt where DeveloperName = 'AV_DeleteTaskOpps' limit 1];
		/*AV_ScheduleBatch__mdt proccessBatch =(AV_ScheduleBatch__mdt) new AV_Query('AV_ScheduleBatch__mdt')
										.selectFields('AV_Limit__c')
										.addConditionEq('DeveloperName', 'AV_DeleteTaskOpps')
										.fetch();*/
		map<String,Object> params = new map<String,Object>();
		params.put('limitBatch',proccessBatch.AV_Limit__c);
		params.put('setUserIds',listUser);
		String paramStr = JSON.serialize(params);  
		CBK_BatchJob.executeBatchFuture('AV_DeleteRecordsTaskOppBatch', 200 ,paramStr); 
		//Database.executeBatch(new AV_DeleteRecordsTaskOppBatch());
	}
}