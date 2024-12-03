/**********************************************************************************************************************
 Name:	  CBK_Framework_Batch_BI_TRHan
 Copyright © 2024  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Framework_Batch para el Before Insert.
------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	        AUTHOR		   		DATE				Description
	1.0			US807680		    Sergio Garcia	   	05/03/2024		    Init version
***********************************************************************************************************************/
public with sharing class CBK_Framework_Batch_BI_TRHan extends CC_TriggerHandlerBase{
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CBK_Framework_Batch__c>) tp.newList);
	}

	private void process(List<CBK_Framework_Batch__c> listNewObj) {
		Set<String> setNewBatchNames = new Set<String>();
		List<String> batchNamesList = new List<String>();

		for(CBK_Framework_Batch__c batch : listNewObj){
			if(batch.Tipo__c == 'Periodico'){
				setNewBatchNames.add(batch.Name);
			}
			
		}
		if(!setNewBatchNames.isEmpty()){
			for(CBK_Framework_Batch__c fb : [SELECT Name FROM CBK_Framework_Batch__c WHERE Name IN : setNewBatchNames]){
				batchNamesList.add(fb.Name);
			}

			if(!batchNamesList.isEmpty()){
				for(CBK_Framework_Batch__c batch : listNewObj){
					if(batchNamesList.contains(batch.Name)){
						batch.addError('Ya existe un Batch con ese nombre');
					}
				}
			}
		}
	}

}