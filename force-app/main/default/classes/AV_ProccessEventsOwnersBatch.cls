/**********************************************************************************************************************
 Name:	  AV_ProccessEventsOwnersBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para cambiar el ownerId de Ficha Cliente al Gestor.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Jashanpreet Singh	07/10/2020			Init version
	1.1			US164515		Sandra Gómez		27/01/2021			Remodel Batch
	1.2			App FSC		    David Rufo			15/02/2020			Improve batch for execution list users
    1.3			US254531		Sandra Gómez		18/08/2021			add query LastModifiedDate
    1.4			USXXXXXX		Sandra Gómez		22/11/2021			add FWK Batches
    1.5		    AV_Query IT		Daniel Rodríguez	3/02/2022			Change AV_Query to SOQL for User and Account
    1.6         US592987	    Ángel Medina		29/05/2023		    Changed AV_Query to SOQL queries
    1.1		    FIX11070844	    Oscar Moreno	    22/07/2024			Fix error The Global modifier should be avoided.
   
***********************************************************************************************************************/
public class  AV_ProccessEventsOwnersBatch implements Database.Batchable<sObject>, Database.Stateful{

    public Integer recordsProcessed = 0;
	public String limitBatch;
	public Set<String> setUserIds;
    
    public AV_ProccessEventsOwnersBatch(String limitQuery, Set<String> userId) {
		limitBatch = limitQuery;
		setUserIds = new Set<String>();
        setUserIds.addAll(userId);
        Map<String, User> mapUsers = getUsers();
    }

    public AV_ProccessEventsOwnersBatch(){}

    
	
	/**
	 * Get a list of Events to process the owners

	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {

        String methodName = 'start';
		AV_LogDebug.printLogDebug(methodName, 'Batch limit: ' + limitBatch);
        AV_LogDebug.printLogDebug(methodName, 'List users ids: ' + setUserIds);
        
        Map<String, User> mapUsers = getUsers();
       
        String avQuery = 'SELECT Id, AV_CodigoGestorAsignado__c, OwnerId FROM Event WHERE (LastModifiedDate >= LAST_N_MONTHS:2) AND AV_CodigoGestorAsignado__c IN ' + AV_AppUtilities.setToStringIn(mapUsers.keySet());
       
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
	 * Update Event OwnerId
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Event> param with the list of Events
	 */
	public void execute(Database.BatchableContext bc, List<Event> scope){
        // Procesar cada batch de registros

		String methodName = 'execute';
        try{
            AV_LogDebug.printLogDebug(methodName,'Data to check: ' + scope.size());
            recordsProcessed = scope.size();
            List<Event> listDataToUpdate = new List<Event>();
            Map<String, User> mapUsers = getUsers();
            
            for(Event data : scope){
                User u = mapUsers.get(data.AV_CodigoGestorAsignado__c);
                if (u!=null && data.OwnerId != u.Id){
                    data.OwnerId = u.Id;
                    listDataToUpdate.add(data);
                }
            } 
          
            AV_LogDebug.printLogDebug(methodName,'Data for update: ' + listDataToUpdate.size());
            if (!listDataToUpdate.isEmpty()) {
                recordsProcessed = listDataToUpdate.size();
                List<Database.SaveResult> listUpdateResult = Database.update(listDataToUpdate, false);
                displayErrors(listUpdateResult);
            }

        }catch(System.Exception e){
            AV_LogDebug.printException(methodName, e);
        }
	}
    
    private void displayErrors(List<Database.SaveResult> listUpdateResult){
        String methodName = 'displayErrors';
        for (Database.SaveResult sr : listUpdateResult) {
            if (!sr.isSuccess()) {
                // Operation failed, so get all errors
                for(Database.Error err : sr.getErrors()) {
                    AV_LogDebug.printLogError(methodName, '****************ERR status: ' + err.getStatusCode() + ': ' + err.getMessage());
                    AV_LogDebug.printLogError(methodName, '****************ERR fields: ' + err.getFields());
                }
            }
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
		CBK_BatchJob.executeBatch('AV_ProccessOpportunityOwnersBatch', 200 ,params);

        //AV_ProccessOpportunityOwnersBatch oppBatch = new AV_ProccessOpportunityOwnersBatch(limitBatch, setUserIds);
        //Database.executeBatch(oppBatch);
    }



}