/**********************************************************************************************************************
 Name:	  CIBE_EconomicGroupsAcc_Batch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para borrar grupos económicos
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US429528		Mikel Lezama        06/09/2022			Init version
	1.1			US429528		Alex Campos        	26/09/2022			Batch Framework Fix
***********************************************************************************************************************/
global class CIBE_EconomicGroupsAcc_Batch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {

    global Integer recordsProcessed = 0;
    global static final String BATCHNAME = 'CIBE_EconomicGroupsAcc';

    private static final String RT_ACC = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoEconomico').getRecordTypeId();
		
    private String avQuery;
	private Date toDeleteDate = null;
	
    public CIBE_EconomicGroupsAcc_Batch(){
        this.avQuery = setQuery();
    }

    public CIBE_EconomicGroupsAcc_Batch(String avQuery){
        this.avQuery = avQuery;
    }

	private String setQuery(){
		String batchLimit = AV_SchedulerBatches.getLimit(BATCHNAME);
        
		List<Account> listaAcc = [SELECT CIBE_FechaCargaGE__c FROM Account WHERE RecordTypeId = :RT_ACC AND CIBE_FechaCargaGE__c != null ORDER BY CIBE_FechaCargaGE__c DESC LIMIT 1];
        
		if (!listaAcc.isEmpty()){
			this.toDeleteDate = listaAcc.get(0).CIBE_FechaCargaGE__c;
			
			if(String.isNotBlank(batchLimit)) {
				avQuery = 'SELECT Id, CIBE_FechaCargaGE__c FROM Account WHERE RecordTypeId = :RT_ACC AND CIBE_FechaCargaGE__c != :toDeleteDate LIMIT '+ batchLimit + '';
			} else {
				avQuery = 'SELECT Id, CIBE_FechaCargaGE__c FROM Account WHERE RecordTypeId = :RT_ACC and CIBE_FechaCargaGE__c != :toDeleteDate';
			}
		}
            
        return avQuery;
    }
    
	/**
	 * Find the last CIBE_FechaCargaGE__c date and the Accounts differents from that date
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
    global Database.QueryLocator start(Database.BatchableContext bc){
        if(String.isBlank(avQuery)){
            avQuery = setQuery();
        }
		
		CBK_Log.debug('QUERY:' + avQuery);
        return Database.getQueryLocator(avQuery);
    }
    
	/**
	 * Delete the Accounts
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Account> param with the list of Accounts.
	 */
    global void execute(Database.BatchableContext bc, List<Account> scope) {
		recordsProcessed = scope.size();
		CBK_Log.debug('Data for delete: ' + recordsProcessed);
		
		List<Object> debugObjs = new List<Object>();
		for(Account acc : scope) {
			debugObjs.add(acc);
		}
		CBK_Log.debug('Grupo Economico', debugObjs);

		Database.DeleteResult[] deletes = Database.delete(scope, false);

		boolean hasError = false;
		List<Object> objs = new List<Object>();
		Map<String, String> msjs = new Map<String, String>();
		for (Integer i = 0; i < scope.size(); i++) {
			Database.DeleteResult dr = deletes[i];
			if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
				msjs.put(scope[i].Id, ((String)dr.getErrors()[0].getMessage()));
				objs.add(scope[i]);
				hasError = true;
			}
		}
		if(hasError) {
			CBK_Log.error(msjs, objs);
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

	/**
	 * Executes the scheduled Apex job
	 *
	 * @param sc	SchedulableContext param that contains the job ID
	 */
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new CIBE_EconomicGroupsAcc_Batch());
	}
    
}