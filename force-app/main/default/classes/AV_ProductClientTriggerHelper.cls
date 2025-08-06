/**********************************************************************************************************************
 Name:	  AV_ProductClientTriggerHelper
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Aux class for AV_ProductClient__c triggers.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US161442		Álvaro López		15/02/2021			Initial version
	1.1			HOTFIX			Carolina Alonso		20/10/2021			Add RT condition in query
	1.2			HOTFIX			Sandra Gómez		22/10/2021			Add method future for Opps
	1.3 		US592987		Ángel Medina		30/05/2023			Changed AV_Query to SOQL queries

***********************************************************************************************************************/
public with sharing class AV_ProductClientTriggerHelper {

    /**
	 * @description		 Fill the AV_ClientProduct__c field in opportunity
	 * @param  listNews  list of new AV_ProductClient__c records
	 */
	//TODO - Pendiente meter en future
	public static void fillClientProduct(List<AV_ProductClient__c> listNews) {
		Map<String, AV_ProductClient__c> mapProdClient = new Map<String, AV_ProductClient__c>();
		Set<String> setAccIds = new Set<String>();
		Set<String> setPFIds = new Set<String>();
		Set<String> setRTOpp = new Set<String>{'AV_AlertaComercial','AV_Iniciativa','AV_Propuesta','AV_Sugerencia'};
		List<AV_ProductClient__c> listClientProds = [SELECT Id, AV_Cliente__c, AV_ProductoFicha__r.AV_ProductoFicha__c FROM AV_ProductClient__c WHERE Id IN :listNews];
       
		for(AV_ProductClient__c pf : listClientProds) {
			if(pf.AV_ProductoFicha__r.AV_ProductoFicha__c != null && pf.AV_Cliente__c != null) {
				String keyMap = pf.AV_Cliente__c + '-' + pf.AV_ProductoFicha__r.AV_ProductoFicha__c;
				mapProdClient.put(keyMap, pf);
				setAccIds.add(pf.AV_Cliente__c);
				setPFIds.add(pf.AV_ProductoFicha__r.AV_ProductoFicha__c);
			}
		}
		if(!mapProdClient.values().isEmpty() && mapProdClient != null && 
				!setAccIds.isEmpty() && !setPFIds.isEmpty()) {
			List<Opportunity> listOppToUpdate = new List<Opportunity>();
			List<Opportunity> listOpps = [SELECT Id, AV_ClientProduct__c, AccountId, AV_PF__c FROM Opportunity WHERE AccountId IN :setAccIds AND AV_PF__c = :setPFIds AND RecordType.DeveloperName IN :setRTOpp];
			
			for(Opportunity opp : listOpps) {
				String keyMap = opp.AccountId + '-' + opp.AV_PF__c;
				if(mapProdClient.containsKey(keyMap)) {
                    opp.AV_ClientProduct__c = mapProdClient.get(keyMap).Id;
                    listOppToUpdate.add(opp);
				}
			}

            if(!listOppToUpdate.isEmpty()) {
				futureUpdateOpps(JSON.serialize(listOppToUpdate));
            }
		}
	}

	@Future
    private static void futureUpdateOpps(String serializedOppsList){
		List<Opportunity> listOppToUpdate = (List<Opportunity>)JSON.deserialize(serializedOppsList, List<Opportunity>.class);
        Database.SaveResult[] srList = Database.update(listOppToUpdate, false);
        AV_AppUtilities.displayErrors('futureUpdateOpps', srList);
    }
}