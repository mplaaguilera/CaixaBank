/**********************************************************************************************************************
 Name:	  AV_Account_AU_TRHan
 Copyright © 2020  CaixaBank
------------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Account AfterUpdate
------------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY				AUTHOR				DATE				Description
	1.0			App FSC			 		Victor	   	    	25/01/2021			Init version
	1.1			Fix Confiden...	 		Víctor Santiago		04/10/2021			Added updateOppConfidentiality
	1.1     	PPM100265161     		Sandra Gómez		03/10/2024  		Add permissionBook
***********************************************************************************************************************/
public with sharing class AV_Account_AU_TRHan extends CC_TriggerHandlerBase {

		public override void mainEntry(CC_TriggerParameters tp) {
			process((List<Account>)tp.newList, (Map<Id, Account>)tp.newMap, (List<Account>) tp.oldList, (Map<Id, Account>) tp.oldMap);
		}
		private void process(List<Account> listNewObj, Map<Id, Account> mapNewObj, List<Account> listOldObj, Map<Id, Account> mapOldObj) {
			//General check the Record type's for intouch project
			List<Account> listData = AV_AccountTriggerHelper.checkGeneralRT(listNewObj);
			Boolean permissionBook = FeatureManagement.checkPermission('AV_InvalidBookTrigger');
			if (listData != null && !listData.isEmpty()) {
				if (!permissionBook) {
					AV_AccountTriggerHelper.processEAPGestorUser(listData, mapOldObj);
				}
			}
			AV_AccountTriggerHelper.updateOppConfidentiality(listData, mapOldObj);
	}
}