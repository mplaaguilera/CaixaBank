/**********************************************************************************************************************
 Name:      AV_DeletePermissionBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para eliminar los permisos de el objeto AV_OfficePermission__c
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0			  US448873		   ivonne suntasig  3/7/2023			Deleting permission management

***********************************************************************************************************************/
public class AV_DeletePermissionBatch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
	
	public Integer recordsProcessed = 0;
	public static final String BATCHNAME = 'AV_DeletePermissionBatch';
    private String avQuery;
	
    public AV_DeletePermissionBatch(){
        avQuery = setQuery();
    }

    private String setQuery(){

		String query = 'Select Id,AV_FinalPermiso__c FROM AV_OfficePermission__c WHERE AV_FinalPermiso__c <=TODAY AND RecordType.DeveloperName = \''+AV_AppConstants.PERMISSION_RT+'\'';
        return query;
    }
    
	/**
	 * Create a list of Permission for delete 
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String methodName = 'start';
		if(avQuery == null){
			avQuery = setQuery();
		}
        AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);
		
		return Database.getQueryLocator(avQuery);
	}

	/**
	 *
	 * @param bc		Database.BatchableContext param that contains the batch job ID
	 * @param ListPermissions 	List<AV_OfficePermission__c> param with the list of Permission to delete.
     */
	 
	public void execute(Database.BatchableContext bc, List<AV_OfficePermission__c> listpermissions){
		String methodName = 'execute';
		try{
			recordsProcessed = listpermissions.size();
			AV_LogDebug.printLogDebug(methodName,'Data for delete:' + listpermissions.size());
			Database.delete(listpermissions,true);

        }
            catch(System.Exception e){
             AV_LogDebug.printException(methodName, e);
             }
            }			
    
    
	/**
	 * Executes the scheduled Apex job
	 * 
	 * @param sc	SchedulableContext param that contains the job ID
	 */
	public void execute(SchedulableContext sc) {
		Database.executeBatch(new AV_DeletePermissionBatch());
	}

	/** 
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	public void finish(Database.BatchableContext bc){
		String methodName='finish';
		AV_LogDebug.printLogDebug(methodName, 'Record Processes: ' + recordsProcessed);
	}
}