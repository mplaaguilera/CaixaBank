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
	1.3			DT08			Luis Fernández		22/04/2022			Class now Without sharing and added dml method to update opportunities that comes from AV_OpportunityTriggerHelper.calculateScoreOpp
	1.4			PPM100205278	Luis Fernández		28/05/2024			Added No Gestionada where Vencida status is
	1.5			PPM100130465    Sandra Gómez		05/08/2024			Change method calculateScoreOpp to origen app in change opp because ejecute lwc and ejecute check on off two 
***********************************************************************************************************************/
public without sharing class AV_OpportunityTriggerHelperAux {
    
    /**
	 * Description 	Create task-opp when check is on
	 * @param setExternalIds retrieve external Id's from Task
	 * @param listOpp retrieve list opp
	 * @param suffixExternalId external Id from task
	 */
    public static List<AV_CustomActivityOpportunity__c> createTaskOppWhenCheck(Set<String> setExternalIds, List<Opportunity> listOpp, String suffixExternalId) {
        String externalIdKey, externalIdOppKey;
		//Obtenemos todas las Cabecera-Tarea creadas.
        List<AV_CustomActivityOpportunity__c> listTareaOpp = new List<AV_CustomActivityOpportunity__c>();
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
			if(opp != null && setExternalIds.contains(externalIdKey) || setExternalIds.contains(externalIdOppKey)){
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
	 * @param listTask 			list task data
	 * @param mapHeaderTask 	map with header-task data
	 */
    public static void fillHeaderTask(List<Task> listTask, Map<String, AV_HeaderCustomActivity__c> mapHeaderTask) {
        List<AV_HeaderCustomActivity__c> listHeaderTask = new List<AV_HeaderCustomActivity__c>();
		for(Task task : listTask){
			AV_HeaderCustomActivity__c hca = mapHeaderTask.get(task.AV_ExternalID__c); 
			if(hca != null){
				hca.IDTask__c = task.Id;
				listHeaderTask.add(hca);
			}
        }
        Database.update(listHeaderTask, false);
    }

	/**
	 * @param opposForRecalculateScoring opportunities that has been recalculated
	 * @param clientsInEmptyCase clients that has been stripped of all opportunities
	 * @param isQueuable whether has to make the update or just return the list of calculate account scoring
	 * @param transactionType
	 * @return List<Account>
	 */
	public static void calculateScoreOpp(List<Opportunity> listNew, Map<Id, Opportunity> mapOld,List<Opportunity> listToDelete,String transactionType){
		Boolean isInsert = (mapOld == null && listToDelete == null);
		Boolean isUpdate = (mapOld != null && listToDelete == null);
		Boolean isDelete = listToDelete != null;
		List<AV_Score__c> scoringTableQuery = [SELECT RecordType.DeveloperName, Name, AV_Score__c, AV_Active__c, AV_Object__c, AV_RecordType__c, AV_InitialValue__c, AV_EndValue__c, AV_StarValue__c, AV_Potencial__c FROM AV_Score__c];
		Set<String> retailRts = new Set<String>{AV_AppConstants.OPPINICIATIVA_RT,AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPPROPUESTA_RT,AV_AppConstants.OPPSUGERENCIA_RT,AV_AppConstants.OPPLLAMADA_RT};
		Map<String,Decimal> scoringTableRtPotencial = new Map<String,Decimal>();
		Map<String,Decimal> scoringTableRtOpen = new Map<String,Decimal>();
		Map<String,Decimal> scoringTableExpectancy = new Map<String,Decimal>();
		String separador = AV_AppConstants.DASH;
		Map<Id,RecordType> rtsMap = new Map<Id,RecordType>([SELECT Id,DeveloperName FROM RecordType WHERE sObjectType = :AV_AppConstants.OBJECT_NAME_OPPORTUNITY]);
		for(AV_Score__c scT : scoringTableQuery){
			if(scT.AV_Active__c){
				if(scT.RecordType.DeveloperName.equals(AV_AppConstants.OPPORTUNITY_RT_SCORING)){
					String rtOppo = scT.AV_RecordType__c.split(separador)[0];
					String stage = scT.AV_RecordType__c.split(separador)[1];
					if(stage.equals(AV_AppConstants.OPP_STATUS_POTENCIAL)){
						scoringTableRtPotencial.put(rtOppo,scT.AV_Score__c);
					}
					if(stage.equals(AV_AppConstants.OPP_STATUS_ENGESTION)){
						scoringTableRtOpen.put(rtOppo,scT.AV_Score__c);
					}
				}
				if(scT.RecordType.DeveloperName.equals(AV_AppConstants.EXPECTANCY_SCORING)){
					scoringTableExpectancy.put(scT.AV_Potencial__c,scT.AV_Score__c);
				}
			}
		}
		List<Opportunity> listToWork = (isDelete) ? listToDelete : listNew;
		Map<String,List<Opportunity>> mapToOrderByAccount = new Map<String,List<Opportunity>>();
		for(Opportunity opp : listToWork){
			if(mapToOrderByAccount.containsKey(opp.AccountId)){
				mapToOrderByAccount.get(opp.AccountId).add(opp);
			}else{
				mapToOrderByAccount.put(opp.AccountId,new List<Opportunity>{opp});
			}
		}
		listToWork.clear();
		for(List<Opportunity> accOppoList : mapToOrderByAccount.values()){
			listToWork.addAll(accOppoList);
		}
		Map<String,String> opposToAccount = new Map<String,String>();
		Map<String,String> opposToAccountChanged = new Map<String,String>();
		Map<String,Decimal> opposScore = new Map<String,Decimal>();
		Set<String> zeroStatus = new Set<String>{
			AV_AppConstants.OPP_STATUS_POTENCIAL,
			AV_AppConstants.OPP_STATUS_ENGESTION,
			AV_AppConstants.OPP_STATUS_VENCIDO,
			AV_AppConstants.OPP_STATUS_NO_GESTIONADA
		};
		for(Opportunity oppo : listToWork){
			Boolean calculableScoringUpdate = isInsert;
			if(isUpdate){
				calculableScoringUpdate = (isUpdate && (!(oppo.StageName.equals(mapOld.get(oppo.Id).StageName)) || oppo.AV_Potencial__c != mapOld.get(oppo.Id).AV_Potencial__c|| oppo.AV_Propensity__c != mapOld.get(oppo.Id).AV_Propensity__c  || oppo.AccountId != mapOld.get(oppo.Id).AccountId));
			}
			opposToAccount.put(oppo.Id, oppo.AccountId);
			if(isUpdate && (oppo.AccountId != mapOld.get(oppo.Id).AccountId)){
				opposToAccountChanged.put(oppo.Id,mapOld.get(oppo.Id).AccountId);
			}
			if(calculableScoringUpdate ){
				Decimal propensity = (oppo.AV_Propensity__c != null) ? oppo.AV_Propensity__c : 0;
				Decimal	invertedPropensity = (propensity >= 1000 ) ? 0 : (1000 - propensity);
				if (rtsMap.containsKey(oppo.RecordTypeId) && scoringTableRtPotencial.containsKey(rtsMap.get(oppo.RecordTypeId).DeveloperName) && oppo.StageName.equals(AV_AppConstants.OPP_STATUS_POTENCIAL)){
					opposScore.put(oppo.Id, (scoringTableRtPotencial.get(rtsMap.get(oppo.RecordTypeId).DeveloperName) + invertedPropensity) );
				}else if((oppo.AV_Potencial__c == null || scoringTableExpectancy.containsKey(oppo.AV_Potencial__c)) && oppo.StageName.equals(AV_AppConstants.OPP_STATUS_ENGESTION)){
					Decimal enGestionValue = (scoringTableRtOpen.get(rtsMap.get(oppo.RecordTypeId).DeveloperName));
					if(enGestionValue != null){
						if(oppo.AV_Potencial__c != null){
							opposScore.put(oppo.Id, (enGestionValue + scoringTableExpectancy.get(oppo.AV_Potencial__c) + invertedPropensity) );
						}else{
							opposScore.put(oppo.Id, enGestionValue + 1000 + invertedPropensity);
						}
					}
				}else if(((oppo.StageName.equals(AV_AppConstants.OPP_STATUS_VENCIDO) || oppo.StageName.equals(AV_AppConstants.OPP_STATUS_NO_GESTIONADA)) && oppo.AV_FechaActivacion__c == null) || !zeroStatus.contains(oppo.StageName)){
					opposScore.put(oppo.Id,0);
				}
			}
		}
		List<Opportunity> opposToUpdt = new List<Opportunity>();
		Boolean thereIsOpposSuccesful = false;
		if(!opposScore.isEmpty()){
			for(String opp : opposScore.keySet()){
				opposToUpdt.add(new Opportunity(Id = opp, AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP, AV_PotencialityOpportunityValue__c = opposScore.get(opp)));
			}
			List<Database.SaveResult> srUpdtOppos = Database.update(opposToUpdt,false);
			for(Database.SaveResult sr : srUpdtOppos){
				if(sr.isSuccess()){
					thereIsOpposSuccesful = true;
				}
			}
		}
		if(thereIsOpposSuccesful || isDelete){
			List<Opportunity> opposForRecalculateScoring = [SELECT Id,AV_PotencialityOpportunityValue__c,AccountId,Name FROM Opportunity WHERE  ((AccountId IN :opposToAccount.values()) OR (AccountId IN :opposToAccountChanged.values())) AND StageName IN :zeroStatus AND RecordType.DeveloperName IN :retailRts ORDER BY Account.AV_NumPerso__c asc];
			List<String> clientsToWork = new List<String>(opposToAccount.values());
			if(!opposToAccountChanged.isEmpty()){
				clientsToWork.addAll(opposToAccountChanged.values());
			}
			if(!opposToAccount.isEmpty()){
				AV_OpportunityTriggerHelper.calculateScoreClient(opposForRecalculateScoring,clientsToWork,false,transactionType);
			}
		}
	}
}