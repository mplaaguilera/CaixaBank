/**********************************************************************************************************************
 Name:	  AV_GenerateRecordsTaskQueueable
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Queueable para actualizar Tasks que vienen de las clase AV_GenerateRecords
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR					DATE				Description
	1.0			Init version        Vladislav Lityagin		30/11/2022			Init version
	
***********************************************************************************************************************/
public with sharing class AV_GenerateRecordsTaskQueueable implements Queueable {
	public Integer recordsProcessed = 0;
	public static final String BATCHNAME = 'AV_GenerateRecordsTaskQueueable';
	@testVisible private static Boolean doChainJob = !Test.isRunningTest();
	public List<Task> tasksList = new List<Task>();
	public List<AV_CustomActivityOpportunity__c> custActList = new List<AV_CustomActivityOpportunity__c>();
    public List<AV_ManagementHistory__c> mhList = new List<AV_ManagementHistory__c>();
	public Boolean hasOpportunityLink;
    public Boolean hasCustomPermission;
	
	public AV_GenerateRecordsTaskQueueable(List<Task> tasksList, List<AV_CustomActivityOpportunity__c> custActList, List<AV_ManagementHistory__c> mhList, Boolean hasOpportunityLink, Boolean hasCustomPermission) {
		this.tasksList = tasksList;
		this.custActList = custActList;
        this.mhList=mhList;
		this.hasOpportunityLink = hasOpportunityLink;
        this.hasCustomPermission = hasCustomPermission;
	}

	public void execute(System.QueueableContext qc){
		String methodName = 'executeTask';
	    Integer maxSize = (Integer) AV_LimitBook__c.getOrgDefaults().AV_LimitGenerateData__c;
		List<Task> aux = new List<Task>();
		List<Task> listaTaskRe = new List<Task>();
		if(tasksList != null && !tasksList.isEmpty()){
			for (Task ta:tasksList) {
				if(maxSize == aux.size()) {
					listaTaskRe.add(ta);
				} else {
					aux.add(ta);
				}
			}
			if (!aux.isEmpty()) {
				List<Database.SaveResult> insertResults = Database.insert(aux, false);
				Set<Id> taskIds = new Set<Id>();
					for(Task t : aux){
						if(t.id != null) {
							taskIds.add(t.Id);
						}
					}
					Map<Id, List<Opportunity>> oppMap = new Map<Id, List<Opportunity>>();
					Map<Id, Task> taskMap = new Map<Id, Task>();
				List<Task> auxTaskList = [SELECT Id, AV_Task__c, Status, AV_Tipo__c, Description, IsReminderSet, ReminderDateTime, WhatId FROM Task WHERE id IN : taskIds];
                System.debug('hasCustomPermission: '+hasCustomPermission);
                if(hasCustomPermission){
                    mhList.addAll(AV_GenerateRecords.createManagementHistory(auxTaskList));
                }
				if(hasOpportunityLink){
					/*for(Task t : aux){
						if(t.id != null) {
							taskIds.add(t.Id);
						}
					}
					Map<Id, List<Opportunity>> oppMap = new Map<Id, List<Opportunity>>();
					Map<Id, Task> taskMap = new Map<Id, Task>();
					List<Task> auxTaskList = [SELECT Id, AV_Task__c, WhatId FROM Task WHERE id IN : taskIds];*/
					Set<String> oppStageName = new Set<String> {	
						AV_AppConstants.OPP_STATUS_ENGESTION, 
						AV_AppConstants.OPP_STATUS_POTENCIAL,
						AV_AppConstants.OPP_STATUS_ENESPERA
					};
					for(Task tsk : auxTaskList){
						taskMap.put(tsk.WhatId, tsk);
					}
					Set<Id> accIds = taskMap.keySet();
					List<Opportunity> opportunitiesList = [SELECT Id, AccountId,StageName FROM Opportunity WHERE AccountId in :accIds AND RecordType.DeveloperName = 'AV_Iniciativa' AND StageName IN :oppStageName ORDER BY CreatedDate DESC LIMIT :taskIds.size()];
					for(Opportunity opp : opportunitiesList){
						if(oppMap.keySet().contains(opp.AccountId)){
							oppMap.get(opp.AccountId).add(opp);
						}else{
							oppMap.put(opp.AccountId, new List<Opportunity>{opp});
						}
					}
					custActList.addAll(AV_GenerateRecords.insertTaskOpportunity(taskIds.size(), oppMap, taskMap, accIds));
				}
				if (doChainJob) {
					if(listaTaskRe != null && !listaTaskRe.isEmpty()){
						System.enqueueJob(new AV_GenerateRecordsTaskQueueable(listaTaskRe,custActList,mhList, hasOpportunityLink, hasCustomPermission));
					} else if(hasCustomPermission){
                        System.debug('LLamando generaterecordsmanhistory');
                        System.debug('mhList size: '+mhList.size());
						System.enqueueJob(new AV_GenerateRecordsManHistoryQueueable(mhList, custActList, hasOpportunityLink));
                    }else if(!hasCustomPermission && hasOpportunityLink){
						System.enqueueJob(new AV_GenerateRecordsCusActOppQueueable(custActList));
					}
                }
			}
		}else{
            if (doChainJob && hasCustomPermission) {
                System.enqueueJob(new AV_GenerateRecordsManHistoryQueueable(mhList, custActList, hasOpportunityLink));
            }else if(doChainJob && !hasCustomPermission && hasOpportunityLink){
                System.enqueueJob(new AV_GenerateRecordsCusActOppQueueable(custActList));
            }
		}   
	 }
}