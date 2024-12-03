/**********************************************************************************************************************
 Name: AV_GenerateRecordsQueueable
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Propósito: Clase Queueable para insertar Opportunity que vienen de la clase AV_GenerateRecords
-----------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            US466765         Patricia Solano  30/11/2022          Init version
   
***********************************************************************************************************************/
public with sharing class AV_GenerateRecordsQueueable implements Queueable {

    public Integer recordsProcessed = 0;
	public static final String BATCHNAME = 'AV_GenerateRecordsQueueable';
    @testVisible private static Boolean doChainJob = !Test.isRunningTest();
	public List<Opportunity> opportunityList = new List<Opportunity>();
	public Boolean linkedOpps;
    
    public AV_GenerateRecordsQueueable(List<Opportunity> opportunityList) {
		this.opportunityList = opportunityList;
    }

    public void execute(System.QueueableContext qc){
		String methodName = 'executeOpp';
		Integer maxSize = (Integer) AV_LimitBook__c.getOrgDefaults().AV_LimitGenerateData__c;
		List<Opportunity> aux = new List<Opportunity>();
		List<Opportunity> listaOppRe = new List<Opportunity>();
		if(opportunityList != null && !opportunityList.isEmpty()){
			for (Opportunity opp:opportunityList) {
				if(maxSize == aux.size()) {
					listaOppRe.add(opp);
				} else {
					aux.add(opp);
				}
			}
			if (!aux.isEmpty()) {
				List<Database.SaveResult> insertResults = Database.insert(aux, true);
				if(listaOppRe != null && !listaOppRe.isEmpty()){ 
					if (doChainJob) {
						System.enqueueJob(new AV_GenerateRecordsQueueable(listaOppRe));
					}
				} 
			}
		} 
	}
}