/**********************************************************************************************************************
 Name:	  CIBE_ProccessTasksOwnersBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para cambiar el ownerId de Task.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US639303		Bea	                21/07/2023			Init version


***********************************************************************************************************************/
public class  CIBE_ProccessTasksOwnersBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public Integer recordsProcessed = 0;
	public String  limitBatch;
	public Set<String> setUserIds;
    
    public CIBE_ProccessTasksOwnersBatch(String limitQuery, Set<String> userId) {
		limitBatch = '100';
		setUserIds = new Set<String>();
        setUserIds.addAll(userId);
    }

    /*Se declara un constructor vacío y sin parámetros y con un System.Debug dentro para que no salte un error de constructor vacío.
	  Es necesario para que ejecute el Framework de batch porque busca en CBK_BatchJob el constructor vacío y allí rellena los parámetros*/
	public CIBE_ProccessTasksOwnersBatch() {
		System.debug('Constructor sin parametros de CIBE_ProccessTasksOwnersBatch');
	}
	
	/**
	 * Get a list of Tasks to process the owners
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {
        String methodName = 'start'; 
        Map<String, User> mapUsers = getUsers();

        List <String> rtCIBE = new List <String>{
            CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT,
            CIBE_AppConstants.TASK_ALERTACOMERCIAL_EMP_RT,
            CIBE_AppConstants.TASK_ONBOARDING_CIB_RT,
            CIBE_AppConstants.TASK_ONBOARDING_EMP_RT,
            CIBE_AppConstants.TASK_ONBOARDING_EMP_RT,
            CIBE_AppConstants.TASK_PRIORIZADOS_CIB_RT,
            CIBE_AppConstants.TASK_PRIORIZADOS_EMP_RT,
            CIBE_AppConstants.TASK_OTROS_CIB_RT,
            CIBE_AppConstants.TASK_OTROS_EMP_RT,
            CIBE_AppConstants.TASK_AVISOS_CIB_RT,
            CIBE_AppConstants.TASK_AVISOS_EMP_RT,
            CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_CIB_RT,
            CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_EMP_RT
        };

        String cibeQuery = 'SELECT Id, AV_CodigoGestorAsignado__c, OwnerId FROM Task ';
		cibeQuery += ' WHERE LastModifiedDate >= LAST_N_MONTHS:2 ';
		cibeQuery += ' AND AV_CodigoGestorAsignado__c IN ' + AV_AppUtilities.setToStringIn(mapUsers.keySet());
        cibeQuery += ' AND RecordType.DeveloperName IN ' + AV_AppUtilities.listToStringIn(rtCIBE);

		if(String.isNotBlank(limitBatch)){
            cibeQuery += ' LIMIT ' + Integer.valueOf(limitBatch);
		}
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
	 * Update Task OwnerId
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Task> param with the list of Tasks
	 */
	public void execute(Database.BatchableContext bc, List<Task> scope){
        // Procesar cada batch de registros
		String methodName = 'execute';
        try{
            recordsProcessed = scope.size();
            List<Task> listDataToUpdate = new List<Task>();
            Map<String, User> mapUsers = getUsers();
            
            for(Task data : scope){
                if(mapUsers.containsKey(data.AV_CodigoGestorAsignado__c)){
                    User u = mapUsers.get(data.AV_CodigoGestorAsignado__c);
                    if (u!=null && data.OwnerId != u.Id){
                        data.OwnerId = u.Id;
                        listDataToUpdate.add(data);
                    }
                }
                
            } 
            recordsProcessed = listDataToUpdate.size();
            Database.update(listDataToUpdate,true);
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
        map<String,Object> params = new map<String,Object>();
		params.put('limitBatch',limitBatch);
		params.put('setUserIds',setUserIds);
		CBK_BatchJob.executeBatch('CIBE_ProccessEventsOwnersBatch', 100 ,params); 
        
        // CIBE_ProccessEventsOwnersBatch eventBatch = new CIBE_ProccessEventsOwnersBatch(limitBatch, setUserIds);
        // Database.executeBatch(eventBatch);
    }

}