/**********************************************************************************************************************
 Name:	  CIBE_Account_AU_TRHan
 Copyright © 2020  CaixaBank
------------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Account AfterUpdate
------------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				  DATE				Description
	1.0			App FSC			Luis	   	          5/11/2021	        Init version
    1.1                         Alex                  23/11/2022        Commit TeamMembers
***********************************************************************************************************************/
public with sharing class CIBE_Account_AU_TRHan  extends CC_TriggerHandlerBase{

	public override void mainEntry(CC_TriggerParameters tp) {
    	process((List<Account>)tp.newList, (Map<Id, Account>)tp.newMap, (List<Account>) tp.oldList, (Map<Id, Account>) tp.oldMap);
  	}
  
  	private void process(List<Account> listNewObj, Map<Id, Account> mapNewObj, List<Account> listOldObj, Map<Id, Account> mapOldObj) {
    	//General check the Record type's for intouch project
    	List<Account> listData = CIBE_AccountTriggerHelper.checkGeneralRT(listNewObj);

		if (listData != null && !listData.isEmpty()) {
			CIBE_AccountTriggerHelper.updateOppConfidentiality(listData, mapOldObj);
			CIBE_AccountTriggerHelper.updateTaskConfidentiality(listData, mapOldObj);
			CIBE_AccountTriggerHelper.updateEvntConfidentiality(listData, mapOldObj);
			CIBE_AccountTriggerHelperWS.commitTeamMembers(listData, mapOldObj);
			CIBE_AccountTriggerHelper.processEAPGestorUser(listData, mapOldObj);
		}
  	}

}