/**********************************************************************************************************************
 Name:	  AV_DeleteRelatedTaskQueueable
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Queueable para eliminar la entidades relacionandas con la tarea
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			Init version        Sandra Gómez		04/01/2023			Init version
	1.1			Fix CBK				Sandra Gómez		07/07/2023			Change Error to list without for
	
***********************************************************************************************************************/
global with sharing class AV_DeleteRelatedTaskQueueable implements Queueable {
	
	global List<AV_ManagementHistory__c> listManagementHistory = new List<AV_ManagementHistory__c>();
	global List<CBK_Activity_Extension__c> listTaskExtension= new List<CBK_Activity_Extension__c>();
	global List<AV_CustomActivityOpportunity__c> listTaskOpp = new List<AV_CustomActivityOpportunity__c>();
	global List<AV_HeaderCustomActivity__c> listHeaderTask = new List<AV_HeaderCustomActivity__c>();

	
	public AV_DeleteRelatedTaskQueueable(List<AV_ManagementHistory__c> listManagementHistory, List<CBK_Activity_Extension__c> listTaskExtension, List<AV_CustomActivityOpportunity__c> listTaskOpp,list<AV_HeaderCustomActivity__c> listHeaderTask) {
		this.listManagementHistory = listManagementHistory;
		this.listTaskExtension = listTaskExtension;
		this.listTaskOpp = listTaskOpp;
		this.listHeaderTask = listHeaderTask;
	}

	global void execute(System.QueueableContext qc){
		String methodName = 'executeDeleteRelatedTask';
		if(listManagementHistory != null && !listManagementHistory.isEmpty()){
			List<String> listErrorsManagementHistory = new List<String>();
			AV_LogDebug.printLogDebug(methodName, 'AV_ManagementHistory__c que se eliminan: '+listManagementHistory.size());
			List<Database.DeleteResult> updateResults = Database.delete(listManagementHistory, false);
			Database.emptyRecycleBin(listManagementHistory);
			Integer i = 0;
			for (Database.DeleteResult sr : updateResults) {
				if (sr.getErrors()!=null) {
					for(Database.Error err : sr.getErrors()) {
						AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getMessage() + ' -> Id: ' + listManagementHistory.get(i).Id);
						listErrorsManagementHistory.add('Error: ' + err.getMessage() + ' -> Id: ' + listManagementHistory.get(i).Id);  
					}
				}
				i++;
			}
			if(listErrorsManagementHistory != null && !listErrorsManagementHistory.isEmpty()) {
				CBK_log.debug('Metodo: '+methodName+' listErrorsManagementHistory: '+listErrorsManagementHistory,listErrorsManagementHistory,LoggingLevel.ERROR);
			}
		}
		if(listTaskExtension != null && !listTaskExtension.isEmpty()){
			List<String> listErrorsTaskExtension = new List<String>();
			AV_LogDebug.printLogDebug(methodName, 'CBK_Activity_Extension__c que se eliminan: '+listTaskExtension.size());
			List<Database.DeleteResult> updateResults = Database.delete(listTaskExtension, false);
			Database.emptyRecycleBin(listTaskExtension);
			Integer i = 0;
			for (Database.DeleteResult sr : updateResults) {
				if (sr.getErrors()!=null) {
					for(Database.Error err : sr.getErrors()) {
						AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getMessage() + ' -> Id: ' + listTaskExtension.get(i).Id);
						listErrorsTaskExtension.add('Error: ' + err.getMessage() + ' -> Id: ' + listTaskExtension.get(i).Id); 
					}
				}
				i++;
			}
			if(listErrorsTaskExtension != null && !listErrorsTaskExtension.isEmpty()) {
				CBK_log.debug('Metodo: '+methodName+' listErrorsTaskExtension: '+listErrorsTaskExtension,listErrorsTaskExtension,LoggingLevel.ERROR);
			}
		}
		if(listTaskOpp != null && !listTaskOpp.isEmpty()){
			List<String> listErrorsTaskOpp = new List<String>();
			AV_LogDebug.printLogDebug(methodName, 'AV_CustomActivityOpportunity__c que se eliminan: '+listTaskOpp.size());
			List<Database.DeleteResult> updateResults = Database.delete(listTaskOpp, false);
			Database.emptyRecycleBin(listTaskOpp);
			Integer i = 0;
			for (Database.DeleteResult sr : updateResults) {
				if (sr.getErrors()!=null) {
					for(Database.Error err : sr.getErrors()) {
						AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getMessage() + ' -> Id: ' + listTaskOpp.get(i).Id);
						listErrorsTaskOpp.add('Error: ' + err.getMessage() + ' -> Id: ' + listTaskOpp.get(i).Id);   
					}
				}
				i++;
			}
			if(listErrorsTaskOpp != null && !listErrorsTaskOpp.isEmpty()) {
				CBK_log.debug('Metodo: '+methodName+' listErrorsTaskOpp: '+listErrorsTaskOpp,listErrorsTaskOpp,LoggingLevel.ERROR);
			}
		}
		if(listHeaderTask != null && !listHeaderTask.isEmpty()){
			List<String> listErrorsHeaderTask = new List<String>();
			AV_LogDebug.printLogDebug(methodName, 'AV_HeaderCustomActivity__c que se eliminan: '+listHeaderTask.size());
			List<Database.DeleteResult> updateResults = Database.delete(listHeaderTask, false);
			Database.emptyRecycleBin(listHeaderTask);
			Integer i = 0;
			for (Database.DeleteResult sr : updateResults) {
				if (sr.getErrors()!=null) {
					for(Database.Error err : sr.getErrors()) {
						AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getMessage() + ' -> Id: ' + listHeaderTask.get(i).Id);
						listErrorsHeaderTask.add('Error: ' + err.getMessage() + ' -> Id: ' + listHeaderTask.get(i).Id);
					}
				}
				i++;
			}
			if(listErrorsHeaderTask != null && !listErrorsHeaderTask.isEmpty()) {
				CBK_log.debug('Metodo: '+methodName+' listErrorsHeaderTask: '+listErrorsHeaderTask,listErrorsHeaderTask,LoggingLevel.ERROR);
			}
		}
	}
}