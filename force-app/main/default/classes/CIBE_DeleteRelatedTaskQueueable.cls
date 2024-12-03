/**********************************************************************************************************************
Name:	  CIBE_DeleteRelatedTaskQueueable
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Queueable para eliminar la entidades relacionandas con la tarea
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			Init version        Luis Martinez		12/05/2023			Init version

***********************************************************************************************************************/
global with sharing class CIBE_DeleteRelatedTaskQueueable implements Queueable {
    
    global List<AV_ManagementHistory__c> listManagementHistory = new List<AV_ManagementHistory__c>();
	global List<CBK_Activity_Extension__c> listTaskExtension= new List<CBK_Activity_Extension__c>();
	global List<AV_CustomActivityOpportunity__c> listTaskOpp = new List<AV_CustomActivityOpportunity__c>();
    global List<AV_HeaderCustomActivity__c> listHeaderTask = new List<AV_HeaderCustomActivity__c>();
	
	public CIBE_DeleteRelatedTaskQueueable(List<AV_ManagementHistory__c> listManagementHistory, List<CBK_Activity_Extension__c> listTaskExtension, List<AV_CustomActivityOpportunity__c> listTaskOpp,list<AV_HeaderCustomActivity__c> listHeaderTask) {
		this.listManagementHistory = listManagementHistory;
		this.listTaskExtension = listTaskExtension;
		this.listTaskOpp = listTaskOpp;
        this.listHeaderTask = listHeaderTask;
	}

    global void execute(System.QueueableContext qc){
		String methodName = 'executeDeleteRelatedTask';
		if(listManagementHistory != null && !listManagementHistory.isEmpty()){
            AV_LogDebug.printLogDebug(methodName, 'AV_ManagementHistory__c que se eliminan: '+listManagementHistory.size());
            List<Database.DeleteResult> updateResults = Database.delete(listManagementHistory, false);
            Database.emptyRecycleBin(listManagementHistory);
            Integer i = 0;
            for (Database.DeleteResult sr : updateResults) {
                if (sr.getErrors()!=null) {
                    for(Database.Error err : sr.getErrors()) {
                        CBK_Log.debug(methodName, 'Error: ' + err.getMessage() + ' -> Id: ' + listManagementHistory.get(i).Id);  
                    } 
                }
                i++;
            }
		}
        if(listTaskExtension != null && !listTaskExtension.isEmpty()){
            AV_LogDebug.printLogDebug(methodName, 'CBK_Activity_Extension__c que se eliminan: '+listTaskExtension.size());
            List<Database.DeleteResult> updateResults = Database.delete(listTaskExtension, false);
            Database.emptyRecycleBin(listTaskExtension);
            Integer i = 0;
            for (Database.DeleteResult sr : updateResults) {
                if (sr.getErrors()!=null) {
                    for(Database.Error err : sr.getErrors()) {
                        CBK_Log.debug(methodName, 'Error: ' + err.getMessage() + ' -> Id: ' + listTaskExtension.get(i).Id);  
                    } 
                }
                i++;
            }
		}
        if(listTaskOpp != null && !listTaskOpp.isEmpty()){
            AV_LogDebug.printLogDebug(methodName, 'AV_CustomActivityOpportunity__c que se eliminan: '+listTaskOpp.size());
            List<Database.DeleteResult> updateResults = Database.delete(listTaskOpp, false);
            Database.emptyRecycleBin(listTaskOpp);
            Integer i = 0;
            for (Database.DeleteResult sr : updateResults) {
                if (sr.getErrors()!=null) {
                    for(Database.Error err : sr.getErrors()) {
                        CBK_Log.debug(methodName, 'Error: ' + err.getMessage() + ' -> Id: ' + listTaskOpp.get(i).Id);  
                    } 
                }
                i++;
            }
		}
        if(listHeaderTask != null && !listHeaderTask.isEmpty()){
            List<Database.DeleteResult> updateResults = Database.delete(listHeaderTask, false);
            Database.emptyRecycleBin(listHeaderTask);
            Integer i = 0;
            for (Database.DeleteResult sr : updateResults) {
                if (sr.getErrors()!=null) {
                    for(Database.Error err : sr.getErrors()) {
                        CBK_Log.debug(methodName, 'Error: ' + err.getMessage() + ' -> Id: ' + listHeaderTask.get(i).Id);  
                    } 
                }
                i++;
            }
		}
	}
}