/**********************************************************************************************************************
 Name:	  AV_GenerateRecordsEventQueueable
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Queueable para insertar Events que vienen de las clase AV_GenerateRecords
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR					DATE				Description
	1.0			Init version        Vladislav Lityagin		30/11/2022			Init version
	
***********************************************************************************************************************/
public with sharing class AV_GenerateRecordsEventQueueable implements Queueable {
	public Integer recordsProcessed = 0;
	public static final String BATCHNAME = 'AV_GenerateRecordsEventQueueable';
	@testVisible private static Boolean doChainJob = !Test.isRunningTest();
	public List<Event> eventList = new List<Event>();
    public List<AV_CustomActivityOpportunity__c> custActList = new List<AV_CustomActivityOpportunity__c>();
	public Boolean hasOpportunityLink;

	public AV_GenerateRecordsEventQueueable(List<Event> eventList,List<AV_CustomActivityOpportunity__c> custActList,Boolean hasOpportunityLink) {
		this.eventList = eventList;
        this.custActList = custActList;
		this.hasOpportunityLink = hasOpportunityLink;
	}

	public void execute(System.QueueableContext qc){
		String methodName = 'executeEvent';
	    Integer maxSize = (Integer) AV_LimitBook__c.getOrgDefaults().AV_LimitGenerateData__c;
		List<Event> aux = new List<Event>();
		List<Event> listaRe = new List<Event>();
		if(eventList != null && !eventList.isEmpty()){
			for (Event ev:eventList) {
				if(maxSize == aux.size()) {
					listaRe.add(ev);
				} else {
					aux.add(ev);
				}
			}
			if (!aux.isEmpty()) {
				List<Database.SaveResult> insertResults = Database.insert(aux, false);
				Set<Id> eventIds = new Set<Id>();
				if(hasOpportunityLink){
					for(Event e :aux ){
						if(e.Id != null){
						eventIds.add(e.Id);
					}
				}
				Map<Id, List<Opportunity>> oppMap = new Map<Id, List<Opportunity>>();
				Map<Id, Event> eventMap = new Map<Id, Event>();
				List<Event> auxEventList = [SELECT Id, AV_Task__c, WhatId FROM Event WHERE id IN : eventIds];
				Set<String> oppStageName = new Set<String> {	
					AV_AppConstants.OPP_STATUS_ENGESTION, 
					AV_AppConstants.OPP_STATUS_POTENCIAL,
					AV_AppConstants.OPP_STATUS_ENESPERA
				};
				for(Event ev : auxEventList){
					eventMap.put(ev.WhatId,ev);
				}
				Set<Id> accIds = eventMap.keySet();
				List<Opportunity> opportunitiesList =  [SELECT Id, AccountId FROM Opportunity WHERE AccountId in :accIds AND RecordType.DeveloperName = 'AV_Iniciativa' AND StageName IN :oppStageName ORDER BY CreatedDate DESC LIMIT :eventIds.size()];
				for(Opportunity opp: opportunitiesList){
					if(oppMap.keySet().contains(opp.AccountId)){
						oppMap.get(opp.AccountId).add(opp);
					}else{
						oppMap.put(opp.AccountId, new List<Opportunity>{opp});
					}
				}
				custActList.addAll(AV_GenerateRecords.insertEventOpportunity(eventIds.size(), oppMap, eventMap, accIds));
			}
				if (doChainJob) {
					if(listaRe != null && !listaRe.isEmpty()){
						System.enqueueJob(new AV_GenerateRecordsEventQueueable(listaRe,custActList,hasOpportunityLink));
					} else if (hasOpportunityLink){
						System.enqueueJob(new AV_GenerateRecordsCusActOppQueueable(custActList));
					}
                }
			}
		}else{
            if (doChainJob && hasOpportunityLink) {
                System.enqueueJob(new AV_GenerateRecordsCusActOppQueueable(custActList));
            }
		}   
	}
}