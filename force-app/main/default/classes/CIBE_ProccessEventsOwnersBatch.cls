/**********************************************************************************************************************
 Name:	  CIBE_ProccessEventsOwnersBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para cambiar el ownerId de Event
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
    1.0			US639303		Bea	                21/07/2023			Init version

***********************************************************************************************************************/
public class  CIBE_ProccessEventsOwnersBatch implements Database.Batchable<sObject>, Database.Stateful{

    public Integer recordsProcessed = 0;
	public String limitBatch;
	public Set<String> setUserIds;
    
    public CIBE_ProccessEventsOwnersBatch(String limitQuery, Set<String> userId) {
		limitBatch = '100';
		setUserIds = new Set<String>();
        setUserIds.addAll(userId);
        Map<String, User> mapUsers = getUsers();
    }

    /*Se declara un constructor vacío y sin parámetros y con un System.Debug dentro para que no salte un error de constructor vacío.
	  Es necesario para que ejecute el Framework de batch porque busca en CBK_BatchJob el constructor vacío y allí rellena los parámetros*/
	public CIBE_ProccessEventsOwnersBatch() {
		System.debug('Constructor sin parametros de CIBE_ProccessEventsOwnersBatch');
	}
	
	/**
	 * Get a list of Events to process the owners

	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {

        String methodName = 'start';
        Map<String, User> mapUsers = getUsers();
        List <String> rtCIBE = new List <String>{
            CIBE_AppConstants.EVENT_CLIENTE_RT,
            CIBE_AppConstants.EVENT_GESTOR_RT
        };
        String  cibeQuery = 'SELECT Id, AV_CodigoGestorAsignado__c, OwnerId FROM Event WHERE (LastModifiedDate >= LAST_N_MONTHS:2) AND AV_CodigoGestorAsignado__c IN ' + AV_AppUtilities.setToStringIn(mapUsers.keySet());
                cibeQuery += ' AND RecordType.DeveloperName IN ' + AV_AppUtilities.listToStringIn(rtCIBE);
                cibeQuery += ' LIMIT ' + Integer.valueOf(limitBatch); 

    return Database.getQueryLocator(cibeQuery); 

	}
    
    private Map<String, User> getUsers(){
        List<User> listUsers  = [SELECT Id, AV_ExternalID__c FROM User WHERE Id in :setUserIds and IsActive = true];
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
            recordsProcessed = listDataToUpdate.size();
            List<Database.SaveResult> listUpdateResult = Database.update(listDataToUpdate, false);
            displayErrors(listUpdateResult);

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
        map<String,Object> params = new map<String,Object>();
		params.put('limitBatch',limitBatch);
		params.put('setUserIds',setUserIds);
		CBK_BatchJob.executeBatch('CIBE_ProccessOpportunityOwnersBatch', 100 ,params);
        
        // CIBE_ProccessOpportunityOwnersBatch oppBatch = new CIBE_ProccessOpportunityOwnersBatch(limitBatch, setUserIds);
        // Database.executeBatch(oppBatch);
    }



}