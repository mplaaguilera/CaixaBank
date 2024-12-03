/**********************************************************************************************************************
 Name:      AV_ProccessOwners
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase que inicializa la cadena de procesos Batches para cambiar el ownerId
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY       AUTHOR               DATE                Description
   1.0            App FSC          Jashanpreet Singh    27/01/2021          Init version
   1.1			  USXXXXXX		   Daniel Rodriguez	    22/11/2021			add FWK Batches

***********************************************************************************************************************/
global with sharing class AV_ProccessOwners {


    webService static void proccess(String param) {
        Set<String> listUser = new Set<String>{param};
        String accountOwnersBatch = 'AV_ProccessAccountsOwnersBatch';
		
		AV_ScheduleBatch__mdt schedulerParticular = AV_AppUtilities.getScheduleBatch(accountOwnersBatch);
		map<String,Object> params = new map<String,Object>();
		params.put('limitBatch',schedulerParticular.AV_Limit__c);
		params.put('setUserIds',listUser);
		String paramParStr = JSON.serialize(params);  
		CBK_BatchJob.executeBatchFuture('AV_ProccessAccountsOwnersBatch', 200 ,paramParStr); 
		//Id batchId = Database.executeBatch(new AV_ProccessAccountsOwnersBatch('1000000', setUserIds)); // this is your call
		//return (String)batchId;

	}
    

}