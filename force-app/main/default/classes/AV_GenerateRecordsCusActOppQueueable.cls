/**********************************************************************************************************************
 Name: AV_GenerateRecordsCusActOppQueueable
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Propósito: Clase Queueable para insertar objetos de Tarea-Oportunidad que vienen de la clase AV_GenerateRecords
-----------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            Init version     Patricia Solano  30/11/2022          Init version

***********************************************************************************************************************/
public with sharing class AV_GenerateRecordsCusActOppQueueable implements Queueable{
	public Integer recordsProcessed = 0;
	public static final String BATCHNAME = 'AV_GenerateRecordsCusActOppQueueable';
    @testVisible private static Boolean doChainJob = !Test.isRunningTest();
	public List<AV_CustomActivityOpportunity__c> custActList = new List<AV_CustomActivityOpportunity__c>();
	
	public AV_GenerateRecordsCusActOppQueueable(List<AV_CustomActivityOpportunity__c> custActList) {
		this.custActList = custActList;
	}

	public void execute(System.QueueableContext qc){
		String methodName = 'executeTareaOportunidad';
        Integer maxSize = (Integer) AV_LimitBook__c.getOrgDefaults().AV_LimitGenerateData__c;
		List<AV_CustomActivityOpportunity__c> aux = new List<AV_CustomActivityOpportunity__c>();
		List<AV_CustomActivityOpportunity__c> listaRe = new List<AV_CustomActivityOpportunity__c>();
		if(custActList != null && !custActList.isEmpty()){
			for (AV_CustomActivityOpportunity__c cst:custActList) {
				if(maxSize == aux.size()) {
					listaRe.add(cst);
				} else {
					aux.add(cst);
				}
			}
			if (!aux.isEmpty()) {
				List<Database.SaveResult> insertResults = Database.insert(aux, true);
                if (doChainJob) {
					if(listaRe != null && !listaRe.isEmpty()){
						System.enqueueJob(new AV_GenerateRecordsCusActOppQueueable(listaRe));
					}
                }
			}
		} else {
			AV_LogDebug.printLogDebug(methodName, 'Finalizada la recarterización');
		}  
	}
}