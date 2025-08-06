/**********************************************************************************************************************
 Name:	  AV_TaskStatusBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para cambiar el estado de las Tareas que no tengan estado final 
			cuando la fecha de vencimiento sea inferior al día actual
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Carolina Alonso		26/08/2020			Init version
	1.1			Hotfix			David Rufo			07/10/2020			Fix problem with the huge amount or records + status
	1.2			Hotfix			Carolina Alonso		13/10/2020			Add RT Check
	2.0			App FSC		  	Sandra Gómez		01/12/2020			Improve the limit query: dynamic limit query
	2.1			IOP Enero		Carolina Alonso		13/01/2020			Add condition ActivityDate = LAST_N_DAYS:45 in query
	2.2			IOP Marzo		Carolina Alonso		04/03/2020			Modify condition ActivityDate = LAST_N_DAYS:15 in query
	2.3			FIX				David Rufo			18/05/2021			Fix problem with the expire Iniciativa task after 3 days
	2.4			US206851		David Rufo			26/05/2021			"Avisos" task will expire after 7 days after due date
	2.5			US384943		Víctor Santiago		30/05/2022			Updates iniciativa and alertas. Converted to SOQL.
	2.6			DE71732			Sandra Gómez		07/02/2023			Add iniciativa + 3 days
	2.7			US542315		Ángel Medina		23/05/2023			Add condition RT = TASKEXPCLIENT_RT AND AV_OrigenApp__c = AV_SAC in query
	2.8         US349042        Oscar Moreno        16/06/2023          Add condition ActivityDate < TODAY AND ActivityDate < LAST_N_DAYS:7
    2.9		    FIX11070844	    Oscar Moreno		   22/07/2024			Fix error The Global modifier should be avoided.


***********************************************************************************************************************/
public class AV_TaskStatusBatch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
	
	public Integer recordsProcessed = 0;
	public static final String BATCHNAME = 'AV_TaskStatusBatch';
	private static final String STATUS_PENDING_NOT_LOCATE 	= 'Pendiente no localizado';
	private static final String STATUS_OPEN_ENGLISH 		= 'Open';
	private static final String STATUS_OPEN_SPANISH 		= 'Pendiente';
	private static final String STATUS_MANAGE_NOT_LOCATE 	= 'Gestionado no localizado';
	private static final String STATUS_NOT_MANAGE 			= 'No gestionada';
    
    private String avQuery;
	
    public AV_TaskStatusBatch(){
        avQuery = setQuery();
    }

    public AV_TaskStatusBatch(String avQuery){
        this.avQuery = avQuery;
    }
    
	private String setQuery(){
		String query = 'SELECT Id, Status, RecordType.DeveloperName, ActivityDate FROM Task WHERE (RecordType.DeveloperName = \'' + AV_AppConstants.TASKALERTACOM_RT + '\'  AND ActivityDate < TODAY AND ActivityDate = LAST_N_DAYS:15  AND AV_BatchProcessChangeStatus__c = \'' + Label.AV_BatchLabel_ToBeProcess + '\') OR (RecordType.DeveloperName = \'' + AV_AppConstants.TASKEXPCLIENT_RT + '\' AND AV_OrigenApp__c = \'AV_SAC\' AND ActivityDate < TODAY AND ActivityDate = LAST_N_DAYS:15  AND AV_BatchProcessChangeStatus__c = \'' + Label.AV_BatchLabel_ToBeProcess + '\') OR (RecordType.DeveloperName = \'' + AV_AppConstants.TASKINICIATIVA_RT + '\' AND ActivityDate < TODAY AND ActivityDate < LAST_N_DAYS:7 AND AccountId != null  AND AV_BatchProcessChangeStatus__c = \'' + Label.AV_BatchLabel_ToBeProcess + '\')';		
		String batchLimit = AV_SchedulerBatches.getLimit(BATCHNAME);
		if(String.isNotBlank(batchLimit)){
			//avQuery.setLimit(Integer.valueOf(batchLimit));
			query += ' LIMIT ' + batchLimit;
		}    
        return query;
    }
    
	/**
	 * Create a list of Task that have a not final status and due date less than today to change the status to a final one.
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String methodName = 'start';
        if(avQuery==null){
            avQuery = setQuery();
        }
        AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);
		return Database.getQueryLocator(avQuery);
	}

	/**
	 * Update the Status of selected Task
	 *
	 * @param bc		Database.BatchableContext param that contains the batch job ID
	 * @param listTask 	List<Task> param with the list of Task to update.
	 */
	public void execute(Database.BatchableContext bc, List<Task> listTask){
		// Procesar cada batch de registros
		String methodName = 'execute';
       
		try{
			recordsProcessed = listTask.size();
			AV_LogDebug.printLogDebug(methodName,'Data does not have a final state with a due date earlier than today: ' + listTask.size());
			List<Task> listTaskToUpdate = new List<Task>();
			for(Task task : listTask){
				if(task.RecordType.DeveloperName.equalsIgnoreCase(AV_AppConstants.TASKINICIATIVA_RT) && ((task.ActivityDate + 7) < (System.today())) ||  task.RecordType.DeveloperName.equalsIgnoreCase(AV_AppConstants.TASKALERTACOM_RT) || task.RecordType.DeveloperName.equalsIgnoreCase(AV_AppConstants.TASKEXPCLIENT_RT) ){
					updateTaskStatus(task,listTaskToUpdate);
				}							
			}
			//Update Tasks
			if(listTaskToUpdate!=null && !listTaskToUpdate.isEmpty()){
				AV_LogDebug.printLogDebug(methodName,'Records updated: ' + listTaskToUpdate.size());
                List<Database.SaveResult> listUpdateResult = Database.update(listTaskToUpdate, false);
				AV_AppUtilities.displayErrors(methodName, listUpdateResult);
			}
		}catch(System.Exception e){
			AV_LogDebug.printException(methodName, e);
		}
	}
    
    /**
     * Update the status of the task:
     * 	"Open" 						-> "No gestionada"
     *  "Pendiente no localizado" 	-> "Gestionado no localizado"
     */

	 
    private void updateTaskStatus(Task task, List<Task> listTaskToUpdate){
        if(STATUS_PENDING_NOT_LOCATE.equalsIgnoreCase(task.Status) ){
            task.Status = STATUS_MANAGE_NOT_LOCATE;
            listTaskToUpdate.add(task);
        }
        else if (STATUS_OPEN_ENGLISH.equals(task.Status) || STATUS_OPEN_SPANISH.equalsIgnoreCase(task.Status)){
            task.Status = STATUS_NOT_MANAGE;
            listTaskToUpdate.add(task);
        }
    }
	

	/**
	 * Executes the scheduled Apex job
	 * 
	 * @param sc	SchedulableContext param that contains the job ID
	 */
	public void execute(SchedulableContext sc) {
		Database.executeBatch(new AV_TaskStatusBatch());
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