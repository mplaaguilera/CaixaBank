/**********************************************************************************************************************
 Name:	  AV_Account_BI_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Account BeforeInsert
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Carolina Alonso	   	15/06/2020			Init version
	1.1			App FSC			David Rufo			09/12/2020			Include a general check of the Record Types
	1.2			Bug				Sandra Gómez		29/01/2021			Include if hasCustomPermission
	1.3			Fix Performance	Carolina Alonso		21/10/2021			Include if has custom setting of Forbidden Words validation
	1.4         USXXXXXX	    Daniel Rodríguez	10/03/2022          Add isBatch()

***********************************************************************************************************************/
public class AV_Account_BI_TRHan extends CC_TriggerHandlerBase{
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Account>)tp.newList, (Map<Id, Account>)tp.newMap, (List<Account>) tp.oldList, (Map<Id, Account>) tp.oldMap);
	}
	
	private void process(List<Account> listNewObj, Map<Id, Account> mapNewObj, List<Account> listOldObj, Map<Id, Account> mapOldObj) {
		//General check the Record type's for intouch project
		List<Account> listData = AV_AccountTriggerHelper.checkGeneralRT(listNewObj);
		
		if (listData!=null && !listData.isEmpty()){
			/*Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
			if (!hasCustomPermission && AV_Bypass__c.getOrgDefaults().AV_ForbiddenWords__c && !System.IsBatch()) {
				AV_AccountTriggerHelper.validateForbiddenWords(listData, mapOldObj);
			}*/
			AV_AccountTriggerHelper.descriptionLastModifiedDate(listData);
			AV_AccountTriggerHelper.processOwnerEAPGestor(listData, mapOldObj);
			AV_AccountTriggerHelper.accountValueOficinaPrincipalRelacionas(listData);
		}
	}
}