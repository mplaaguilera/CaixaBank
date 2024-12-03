/**********************************************************************************************************************
 Name:	  AV_DeleteAccountTeamMemberBatch
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para eliminar los accountTeamMember antes del proceso batch AV_ConfidencialBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Daniel Rodriguez	02/12/2021			Init version
	1.1		    AV_Query IT	    Daniel Rodríguez	02/03/2022	        Change AV_Query to SOQL for User, Account, Contact
	1.2			Fix Confidencial	Carolina Alonso	26/09/2022			Add condition to check that the record is from MC's proyect (AV_Tipo__c = 'MC')
	1.3			US423397		Carolina Alonso		17/11/2022			Delete call to AV_ConfidentialBatch

***********************************************************************************************************************/
global class AV_DeleteAccountTeamMemberBatch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {

	global Integer recordsProcessed = 0;
    global static final String BATCHNAME = 'AV_DeleteAccountTeamMemberBatch';
	global static final String TIPOMC  = 'MC';
	
    
	/**
	 * Create a list of Cartera Cliente that is Activa and the associated Client is Confidential.
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		String methodName = 'start';
		String avQuery = '';
		//List<String> setRt = new List<String>{'AV_CarteraCliente'};
		String limitBatch = AV_SchedulerBatches.getLimit(BATCHNAME);
		if(String.isNotBlank(limitBatch)){
			avQuery = 'Select Id FROM AccountTeamMember where AV_Tipo__c = '+ '\'' + TIPOMC + '\''+' limit '+ Integer.valueOf(limitBatch)+' ';
		}else{
			avQuery = 'Select Id FROM AccountTeamMember where AV_Tipo__c = '+ '\'' + TIPOMC + '\''+' ';
		}

		AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);
        return Database.getQueryLocator(avQuery);


	}

	/**
	 * Delete the AccountTeamMembers
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param listAccountMember List<AccountTeamMember> param with the list of AccountTeamMember.
	 */
	global void execute(Database.BatchableContext bc, List<AccountTeamMember> listAccountMember){
		// Procesar cada batch de registros
        String methodName = 'execute';
		AV_LogDebug.printLogDebug(methodName, 'Record Processes: ' + listAccountMember);

		try{
            recordsProcessed = listAccountMember.size();
            List<AccountTeamMember> deleteAccTeamMember = new List<AccountTeamMember>();
            for(AccountTeamMember accTM : listAccountMember){
                deleteAccTeamMember.add(accTM);
            }
            if(deleteAccTeamMember.size() > 0){
                delete deleteAccTeamMember;
            }

		}catch(System.Exception e){
			AV_LogDebug.printException(methodName, e);
		}
	}	

	/**
	 * Executes the scheduled Apex job
	 *
	 * @param sc	SchedulableContext param that contains the job ID
	 */
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new AV_DeleteAccountTeamMemberBatch());
	}

	/**
	 * Print the results of the batch process and Call AV_ConfidentialBatch
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	global void finish(Database.BatchableContext bc){
		String methodName='finish';
		AV_LogDebug.printLogDebug(methodName, 'Record Processes: ' + recordsProcessed);
        AV_LogDebug.printLogDebug(methodName, 'Call Batch Confidential');
        
        Set<String> listUser = new Set<String>();
        listUser.add(UserInfo.getUserId());
		AV_ScheduleBatch__mdt proccessBatch = [Select AV_Limit__c from AV_ScheduleBatch__mdt where DeveloperName = 'AV_ConfidentialBatch' limit 1];
        map<String,Object> params = new map<String,Object>();
        params.put('limitBatch',proccessBatch.AV_Limit__c);
        params.put('setUserIds',listUser); 
        //if(!test.isRunningTest())CBK_BatchJob.executeBatch('AV_ConfidentialBatch', 200 ,params); 
	}

}