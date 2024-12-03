/**********************************************************************************************************************
Name:	  AV_EnmascaramientoBatch
Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Proceso Batch para enmascarar datos del Cliente Particular
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE				Description
1.0			App FSC			Esperanza Conde		14/07/2020			Init version
2.0			App FSC			Esperanza Conde		24/07/2020			Include AV_RecordToMask__c = true in the query
2.1			App FSC			Carolina Alonso		26/10/2020			Delete OrderBy in the query
2.2			PMD			    Víctor Santiago	    15/04/2021			AV_limit changed to avLimit
2.3			USXXXXXX		Sandra Gómez		22/11/2021			add FWK

***********************************************************************************************************************/
global class AV_EnmascaramientoBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	global Integer recordsProcessed = 0;
	global static final String AV_PARTICULAR = 'CC_ClientePA';
	
	global String avLimit;
	
	global AV_EnmascaramientoBatch(String limitQuery) {
		avLimit = limitQuery;
	}

	global AV_EnmascaramientoBatch() {}
	
	/**
* Create a list of Account that the recordtype is CC_ClientePA
* @param bc  Database.BatchableContext param that contains the batch job ID
*/	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		String query = 'SELECT Id, RecordtypeId, AV_FechaEnmascaramiento__c, Description, FirstName, '+
			+'LastName, PersonEmail, PersonMobilePhone, PersonBirthdate, CC_Numero_Documento__pc, '+
			+'Phone, lastModifiedDate FROM Account WHERE RecordType.DeveloperName = \'CC_CLientePA\' '+
			+'AND AV_RecordToMask__c = true';
		
		if(String.isNotBlank(avLimit)){
			query += ' LIMIT ' + avLimit; 
		}		
		return Database.getQueryLocator(query);
	}
	
	/**
     * Update Field to mask in Account
     *
     * @param bc	Database.BatchableContext param that contains the batch job ID
     * @param listAccounts List<Account> param with the list of Accounts.
     */
	global void execute(Database.BatchableContext bc, List<Account> listAccounts){
		// Procesar cada batch de registros
		String methodName = 'execute';
		try{
			List<Account> listAccountsToUpdate = new List<Account>();
			recordsProcessed = listAccounts.size();
			AV_LogDebug.printLogDebug(methodName,'Data which has Fecha de enmascaramiento != Null && < lastModifiedDate : ' + listAccounts.size());
			
			//Recorremos la lista y calculamos sus valores enmascarados
			for(Account cliente : listAccounts){
				//FirstName, LastName, PersonEmail
				AV_MaskUtils.maskPersonInformation(cliente, AV_PARTICULAR);
				AV_MaskUtils.maskBirthDate(cliente); 
				AV_MaskUtils.maskTelephone(cliente, AV_PARTICULAR); 
				AV_MaskUtils.maskIdenNumber(cliente);
				AV_MaskUtils.maskDescription(cliente); 
				cliente.AV_FechaEnmascaramiento__c = DATE.TODAY();
				
				listAccountsToUpdate.add(cliente);
			}
			AV_LogDebug.printLogDebug(methodName, 'Record To Update: ' + listAccountsToUpdate);
			
			if(!listAccountsToUpdate.isEmpty()){
				Database.update(listAccountsToUpdate);
				AV_LogDebug.printLogDebug(methodName, 'Record update: ' + listAccountsToUpdate);
			}
			
		}catch(System.Exception e){
			AV_LogDebug.printException(methodName, e);
		}
	}	
	
	/**
     * Print the results of the batch process
     *
     * @param bc	Database.BatchableContext param that contains the batch job ID
     */
	global void finish(Database.BatchableContext bc){
		String methodName='finish';
		AV_LogDebug.printLogDebug(methodName, 'Record Processes: ' + recordsProcessed);
	}
	
}