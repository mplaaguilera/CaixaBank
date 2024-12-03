/**********************************************************************************************************************
 Name:	  CIBE_Task_BU_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Task BeforeUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		  	AUTHOR				DATE				Description
	1.0								Mikel Lezama   		29/08/2022			Init version
***********************************************************************************************************************/
public class CIBE_Task_BU_TRHan extends CC_TriggerHandlerBase{
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Task>)tp.newList, (Map<Id, Task>)tp.newMap, (List<Task>) tp.oldList, (Map<Id, Task>) tp.oldMap);
	}
	
	private void process(List<Task> listNewObj, Map<Id, Task> mapNewObj, List<Task> listOldObj, Map<Id, Task> mapOldObj) {
		//General check the Record type's for intouch project
		List<Task> listData = CIBE_TaskTriggerHelper.checkGeneralRT(listNewObj);
		if (listData!=null && !listData.isEmpty()){
			Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
			/*if (!hasCustomPermission && AV_Bypass__c.getOrgDefaults().AV_ForbiddenWords__c && !System.isbatch() || Test.isRunningTest()) {
				CIBE_TaskTriggerHelper.validateForbiddenWords(listData, mapOldObj);
				//AV_TaskTriggerHelper.oppoReminder(listData, mapNewObj, mapOldObj);
			}*/

			CIBE_TaskTriggerHelper.changeOwner(listData, mapOldObj);
			CIBE_TaskTriggerHelper.processOwnerGestores(listData, mapOldObj);
			CIBE_TaskTriggerHelper.createCRMTask(listData, mapOldObj);
			CIBE_TaskTriggerHelper.insertOrUpdateCodigoGestorAsignado(listData, mapOldObj);
			CIBE_TaskTriggerHelper.updateCentro(listData,mapOldObj);
			CIBE_TaskTriggerHelper.insertOrUpdateCenterAndRt(listData, mapOldObj);
			CIBE_TaskTriggerHelper.setConfidentiality(listData, false);
			CIBE_TaskTriggerHelper.updateGCF(listData, mapOldObj);
			
			if ((!hasCustomPermission && !System.isbatch() )) {
				CIBE_TaskTriggerHelper.createManagementHistory(listData, mapOldObj);
			}


		}
	}
}