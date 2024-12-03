/**********************************************************************************************************************
 Name:	  AV_OpportunityTriggerHelperAux
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar para AV_OpportunityTriggerHelper
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Eric Vazquez		11/02/2021			Init version
	1.1			US189148		Sandra Gómez		17/03/2021			add dateExternalId
	1.2			US365180		Víctor Santiago		14/04/2022			added if System.isQueueable in createTaskOppWhenCheck
	
***********************************************************************************************************************/
public with sharing class AV_OpportunityTriggerHelperAux {
    
    /**
	 * Description 	Create task-opp when check is on
	 *
	 * @param setExternalIds retrieve external Id's from Task
	 * @param listOpp retrieve list opp
	 * @param suffixExternalId external Id from task
	 */
    public static List<AV_CustomActivityOpportunity__c> createTaskOppWhenCheck(Set<String> setExternalIds, List<Opportunity> listOpp, String suffixExternalId) {
        String externalIdKey, externalIdOppKey;
		//Obtenemos todas las Cabecera-Tarea creadas.
        List<AV_CustomActivityOpportunity__c> listTareaOpp = new List<AV_CustomActivityOpportunity__c>();
        // List<Task> listTareas = new AV_Query('Task')
        //     						.selectFields('Id, AV_ExternalID__c, AV_Task__c')
        //     						.addConditionIn('AV_ExternalID__c', setExternalIds)
        //     						.run();
		List<Task> listTareas = [SELECT Id,AV_ExternalID__c,AV_Task__c,OwnerId FROM Task WHERE AV_ExternalID__c IN :setExternalIds];
        Map<String, Task> mapTask = new Map<String, Task>();
        for (Task task : listTareas){
            mapTask.put(task.AV_ExternalID__c, task);
        }
        
		for(Opportunity opp : listOpp){
			if (System.isQueueable()) {
				externalIdKey = suffixExternalId.split('@')[0] + opp.AV_ExternalID__c + suffixExternalId.split('@')[1];
				externalIdOppKey = suffixExternalId.split('@')[0] + opp.Id + suffixExternalId.split('@')[1];
			} else {
				externalIdKey = suffixExternalId + opp.AV_ExternalID__c + AV_OpportunityTriggerHelper.dateExternalId;
				externalIdOppKey = suffixExternalId + opp.Id + AV_OpportunityTriggerHelper.dateExternalId;
			}
			if(opp != null && setExternalIds.contains(externalIdKey) 
               		|| setExternalIds.contains(externalIdOppKey)){
				//Get the task related with the opp via "externalid"
                Task task = mapTask.get(externalIdKey);
				if (task==null){
                	task = mapTask.get(externalIdOppKey);
                }
				if (task!=null){
                    AV_CustomActivityOpportunity__c tareaOpp = new AV_CustomActivityOpportunity__c();
                	tareaOpp.AV_Task__c = task.AV_Task__c;
                    tareaOpp.AV_Opportunity__c = opp.Id;
                    tareaOpp.AV_IsMain__c = true;
                    tareaOpp.OwnerId = task.OwnerId;
                    listTareaOpp.add(tareaOpp);            
                }
			}	
        }
        
		return listTareaOpp;
    }
    
    /**
	 * Description 	This method retrieve de header task and fill the IDTask__c for related task
	 *
	 * @param listTask 			list task data
	 * @param mapHeaderTask 	map with header-task data
	 */
    public static void fillHeaderTask(List<Task> listTask, Map<String, AV_HeaderCustomActivity__c> mapHeaderTask) {
        List<AV_HeaderCustomActivity__c> listHeaderTask = new List<AV_HeaderCustomActivity__c>();
		for(Task task : listTask){
			AV_HeaderCustomActivity__c hca = mapHeaderTask.get(task.AV_ExternalID__c);            
            hca.IDTask__c = task.Id;
            listHeaderTask.add(hca);
        }
        Database.update(listHeaderTask, false);
    }
	
}