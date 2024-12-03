/**********************************************************************************************************************
 Name:	  AV_GenerateRecordsManHistoryQueueable
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Queueable para insertar Managements History que vienen de las clase AV_GenerateRecords
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR					DATE				Description
	1.0			Init version        Vladislav Lityagin		09/01/2023			Init version
	
***********************************************************************************************************************/
public with sharing class AV_GenerateRecordsManHistoryQueueable implements Queueable {
	public Integer recordsProcessed = 0;
	public static final String BATCHNAME = 'AV_GenerateRecordsManHistoryQueueable';
	@testVisible private static Boolean doChainJob = !Test.isRunningTest();
    public List<AV_ManagementHistory__c> mhList = new List<AV_ManagementHistory__c>();
    public List<AV_CustomActivityOpportunity__c> custActList = new List<AV_CustomActivityOpportunity__c>();
	public Boolean hasOpportunityLink;

    public AV_GenerateRecordsManHistoryQueueable(List<AV_ManagementHistory__c> mhList, List<AV_CustomActivityOpportunity__c> custActList,Boolean hasOpportunityLink) {
        this.custActList = custActList;
		this.hasOpportunityLink = hasOpportunityLink;
        this.mhList=mhList;
	}

	public void execute(System.QueueableContext qc){
		String methodName = 'executeManagementHistory';
	    Integer maxSize = (Integer) AV_LimitBook__c.getOrgDefaults().AV_LimitGenerateData__c;
		List<AV_ManagementHistory__c> aux = new List<AV_ManagementHistory__c>();
		List<AV_ManagementHistory__c> listaRe = new List<AV_ManagementHistory__c>();
		if(mhList != null && !mhList.isEmpty()){
			for (AV_ManagementHistory__c mh : mhList) {
				if(maxSize == aux.size()) {listaRe.add(mh);}
                else {aux.add(mh);}
			}
			if (!aux.isEmpty()) {
				List<Database.SaveResult> insertResults = Database.insert(aux, false);
				if (doChainJob) {
					if(listaRe != null && !listaRe.isEmpty()){
						System.enqueueJob(new AV_GenerateRecordsManHistoryQueueable(listaRe,custActList,hasOpportunityLink));
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