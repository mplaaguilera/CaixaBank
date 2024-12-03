/**********************************************************************************************************************
 Name:	  AV_HierarchyEmployeesBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch de Contacts para asociar el Supervisor.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Carolina Alonso		05/05/2020			Init version
	1.1			FIX				David Rufo			31/05/2021			Use the Query FWK
	1.2		    AV_Query IT	    Daniel Rodríguez    04/02/2022	        Change AV_Query to SOQL for User,Account, Contact

***********************************************************************************************************************/
global class AV_HierarchyEmployeesBatch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
   
	global Integer recordsProcessed = 0;
	global static final String BATCHNAME = 'AV_HierarchyEmployees';
	
    private AV_Query avQuery;
	
    /*public AV_HierarchyEmployeesBatch(){
        avQuery = setQuery();
    }

    public AV_HierarchyEmployeesBatch(AV_Query avQuery){
        this.avQuery = avQuery;
    }
    
    private AV_Query setQuery(){
        Set<String> setRt = new Set<String>{AV_AppConstants.EMPLOYEE_RT};
                                                
        AV_Query avQuery = new AV_Query('Contact')
                                    .selectFields('ID, AV_Supervisor__c, AccountId')
            						.addConditionEq('AV_Supervisor__c', null)
                                    .addConditionIn('RecordType.DeveloperName', setRt);
        
        String batchLimit = AV_SchedulerBatches.getLimit(BATCHNAME);
		if(String.isNotBlank(batchLimit)){
			avQuery.setLimit(Integer.valueOf(batchLimit));
		}
        
        return avQuery;
    }*/
    
	/**
	 * Create a list of Contacts does not have an associated AV_Supervisor__c.
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		String methodName = 'start';
        /*if(avQuery==null){
            avQuery = setQuery();
        }
        AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery.toQueryString());
		
		return avQuery.getQueryLocator();*/
		String avQuery = '';
		List<String> setRt = new List<String>{'\''+AV_AppConstants.EMPLOYEE_RT+'\''};

		String batchLimit = AV_SchedulerBatches.getLimit(BATCHNAME);
		if(String.isNotBlank(batchLimit)){
			avQuery = 'Select ID, AV_Supervisor__c, AccountId From Contact Where RecordType.DeveloperName in ' +setRT+' and AV_Supervisor__c = null limit '+ batchLimit+' ';
		}else{
			avQuery = 'Select ID, AV_Supervisor__c, AccountId From Contact Where RecordType.DeveloperName in ' +setRT+' and AV_Supervisor__c = null';
		}
		AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);

		return Database.getQueryLocator(avQuery);
	}

	/**
	 * Update the Supervisor in Contacts.
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param contactList List<Contact> param with the list of Contact to update AV_Supervisor__c
	 */
	global void execute(Database.BatchableContext bc, List<Contact> contactList){
		// Procesar cada batch de registros
		String methodName = 'execute';
		try{
			
			AV_LogDebug.printLogDebug(methodName,'Data does not have an asociated Supervisor: ' + contactList.size());
			List<Account> listAccount= [Select Id, AV_MatriculaResponsable1__c, AV_MatriculaResponsable2__c From Account Where RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT];
			/*List<Account> listAccount =  new AV_Query('Account')
										.selectFields('Id, AV_MatriculaResponsable1__c, AV_MatriculaResponsable2__c')
										.addConditionEq('RecordType.DeveloperName', AV_AppConstants.ACCOUNT_CTO_RT)
										.run();*/
			List<Contact> updatedContacts = new List<Contact>();
			Map<Id, Account> mapAccount = new Map<Id,Account>(listAccount);
			for(Contact empleado : contactList){
				Account centro = mapAccount.get(empleado.AccountId);
				if(centro != null && centro.AV_MatriculaResponsable1__c != empleado.Id){
					empleado.AV_Supervisor__c = String.isNotBlank(centro.AV_MatriculaResponsable1__c) ? centro.AV_MatriculaResponsable1__c : centro.AV_MatriculaResponsable2__c ;
					updatedContacts.add(empleado);
				}
			}
			
			recordsProcessed = updatedContacts.size();
			Database.update(updatedContacts);

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
		Database.executeBatch(new AV_HierarchyEmployeesBatch());
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