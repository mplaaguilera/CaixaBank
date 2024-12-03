/**********************************************************************************************************************
Name:	  AV_OpportunityTriggerHelperSharing
Copyright © 2020  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Opportunity without sharing.
------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	        AUTHOR		   		DATE				Description
1.0			Fix		            Elisabeth R.	    11/09/2023		    Init version
***********************************************************************************************************************/
public without sharing class AV_OpportunityTriggerHelperSharing {
    
    	private static final String SUFFIX_EXTERNALID     = 'Opp-';
    	private static AV_AppUtilities.SearchRT rtTaskAlerta     = new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKALERTACOM_RT);
		private static Set<Id> setRtTaskAlerta     = getIdsRT(new Set<AV_AppUtilities.SearchRT>{rtTaskAlerta});

	/**
	* @description       Get the ID's of the RT's requested by param
	* @param setRT      List of the RT
	*/
	public static Set<Id> getIdsRT(Set<AV_AppUtilities.SearchRT> setRT){
		return AV_AppUtilities.getRecordTypeIdsInSet(setRT);
	}
    
    
/**
	* @description     Create a Task associated with a Opportunity Call Me
	* @param  opp  Opportunity callme
	*/
	public static void createTaskCallMeFromJSON(Opportunity opp) {

		Id rtTask = (new List<Id>(setRtTaskAlerta)).get(0);
		List<User> ownerUser = [SELECT AV_NumeroOficinaEmpresa__c FROM User WHERE Id =: opp.OwnerId];

		if(ownerUser != null && !ownerUser.isEmpty()){

			Date activityDate = date.today() + 5;
			Task taskToInsert = createTaskCommercialAlert(opp, activityDate, rtTask, ownerUser[0].AV_NumeroOficinaEmpresa__c);
	
			if (taskToInsert!=null){	
				Database.SaveResult resultList = Database.insert(taskToInsert, false);
	
				if(String.valueOf(resultList.isSuccess()) == 'true' ){
	
					List<Task> taskList = [SELECT Id, AV_ExternalID__c,AV_Task__c  FROM Task WHERE Id =:resultList.getId() LIMIT 1];
	
					//Crea la Tarea-Oportunidad asociada a la oportunidad y a la tarea insertadas
					AV_CustomActivityOpportunity__c tareaOpp = new AV_CustomActivityOpportunity__c();
					tareaOpp.AV_Task__c = taskList[0].AV_Task__c;
					tareaOpp.AV_Opportunity__c = opp.Id;
				
					Database.SaveResult srListopptASK = Database.insert(tareaOpp, false);
	
				}
			}  
		}
	}
    
    
    /**
	* @description         Create Task associated with the Opportunity Call Me.
	* @param  opp        Opportunity.
	* @param  activityDate   Due Date
	* @param  rt         record type
	* @param  numCent    center number
	*/
	private static Task createTaskCommercialAlert(Opportunity opp, Date activityDate, Id rt, String numCent) {
		Task tarea = new Task();
		if(String.isNotBlank(opp.AV_ExternalID__c)){
			tarea.AV_ExternalID__c = SUFFIX_EXTERNALID + opp.AV_ExternalID__c + System.now();
		}else{
			tarea.AV_ExternalID__c = SUFFIX_EXTERNALID + opp.Id + System.now();
		}
		tarea.ActivityDate = activityDate;
		tarea.AV_FechaFinAccionComercial__c = activityDate;
		if(String.isNotBlank(opp.AccountId)){
			tarea.WhatId = opp.AccountId;
		}
		if(opp.Name!=null){
			tarea.Subject = opp.Name;
		}
		tarea.Status = 'Open';
		tarea.Priority = 'Y';
		tarea.RecordTypeId = rt;
		tarea.OwnerId = opp.OwnerId;
		tarea.AV_Center__c = numCent.substring(numCent.length()-5);
		tarea.AV_OrigenApp__c = AV_AppConstants.OPPLLAMADA_RT;
		tarea.AV_Tipo__c = AV_AppConstants.LLAMADA_TIPO;
		return tarea;
	}



}