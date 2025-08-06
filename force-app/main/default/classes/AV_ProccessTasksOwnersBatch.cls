/**********************************************************************************************************************
 Name:	  AV_ProccessTasksOwnersBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para cambiar el ownerId de Ficha Cliente al Gestor.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Jashanpreet Singh	07/10/2020			Init version
	1.1			App FSC			David Rufo			11/02/2020			Improve batch for execution list users
    1.2			US254531		Sandra Gómez		18/08/2021			add query LastModifiedDate
    1.3			USXXXXXX		Sandra Gómez		22/11/2021			add FWK Batches
    1.4		    AV_Query IT		Daniel Rodríguez	3/02/2022			Change AV_Query to SOQL for User and Account
    1.5         US592987	    Ángel Medina		30/05/2023		    Changed AV_Query to SOQL queries
    1.6			Fix error		Daniel Rodriguez	15/01/2024			Fix to null map
	1.7         FIX28080841     Oscar Moreno        28/08/2024          Fix error The Global modifier should be avoided.

    
***********************************************************************************************************************/
public class  AV_ProccessTasksOwnersBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public Integer recordsProcessed = 0;
	public String limitBatch;
	public Set<String> setUserIds;
    
    public AV_ProccessTasksOwnersBatch(String limitQuery, Set<String> userId) {
		limitBatch = limitQuery;
		setUserIds = new Set<String>();
        setUserIds.addAll(userId);
    }

    public AV_ProccessTasksOwnersBatch(){}
    
    
	/**
	 * Get a list of Tasks to process the owners
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {
        String methodName = 'start';
		AV_LogDebug.printLogDebug(methodName, 'Batch limit: ' + limitBatch);
        AV_LogDebug.printLogDebug(methodName, 'List users ids: ' + setUserIds);
        
        Map<String, User> mapUsers = getUsers();
        String avQuery = 'SELECT Id, AV_CodigoGestorAsignado__c, OwnerId FROM Task ';
		avQuery += ' WHERE LastModifiedDate >= LAST_N_MONTHS:2 ';
        if(!mapUsers.isEmpty() && mapUsers != null){
			avQuery += ' AND AV_CodigoGestorAsignado__c IN ' + AV_AppUtilities.setToStringIn(mapUsers.keySet());
        }else{
            avQuery += ' AND AV_CodigoGestorAsignado__c IN ' + '(\'\')';
        }
		
		if(String.isNotBlank(limitBatch)){
            avQuery += ' LIMIT ' + Integer.valueOf(limitBatch);
		}

        AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);
		return Database.getQueryLocator(avQuery);
	}
    
    
    private Map<String, User> getUsers(){
        List<User> listUsers  = [Select Id, AV_ExternalID__c From User Where Id in :setUserIds and IsActive = true];
        //Key of the map: Matricula
        Map<String, User> mapUsers = new Map<String, User>();
        for (User u : listUsers){
            if (String.isNotBlank(u.AV_ExternalID__c)){
            	mapUsers.put(u.AV_ExternalID__c, u);
            }
        }
        return mapUsers;
    }

	/**
	 * Update Task OwnerId
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Task> param with the list of Tasks
	 */
	public void execute(Database.BatchableContext bc, List<Task> scope){
        // Procesar cada batch de registros
		String methodName = 'execute';
        try{
            AV_LogDebug.printLogDebug(methodName,'Data to check: ' + scope.size());
            recordsProcessed = scope.size();
            List<Task> listDataToUpdate = new List<Task>();
            Map<String, User> mapUsers = getUsers();
            
            for(Task data : scope){
                User u = mapUsers.get(data.AV_CodigoGestorAsignado__c);
                if (u!=null && data.OwnerId != u.Id){
                    data.OwnerId = u.Id;
                    listDataToUpdate.add(data);
                }
            } 
          
            AV_LogDebug.printLogDebug(methodName,'Data for update: ' + listDataToUpdate.size());
            recordsProcessed = listDataToUpdate.size();
            Database.update(listDataToUpdate,false);
        }catch(System.Exception e){
            AV_LogDebug.printException(methodName, e);
        }
	}	

	/**
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	public void finish(Database.BatchableContext bc){
		String methodName='finish';
        AV_LogDebug.printLogDebug(methodName, 'Record Processes: ' + recordsProcessed);

        map<String,Object> params = new map<String,Object>();
		params.put('limitBatch',limitBatch);
		params.put('setUserIds',setUserIds);
		CBK_BatchJob.executeBatch('AV_ProccessEventsOwnersBatch', 200 ,params); 

    }

}