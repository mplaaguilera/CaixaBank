/**********************************************************************************************************************
 Name:	  AV_Task_BI_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Task BeforeInsert
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Carolina Alonso	   	24/04/2020			Init version
	1.1			App FSC			Carolina Alonso		05/05/2020			Change RecordType query and its DeveloperName set
	1.2			App FSC			David Rufo	   		22/05/2020			Update class for DML error's in the batches
	1.3			App FSC			David Rufo	   		17/08/2020			New RT's to include in the process
	1.4			US104665		Esperanza Conde		21/10/2020			logic completeValueDateReal
	1.5			App FSC			David Rufo			09/12/2020			Include a general check of the Record Types
	1.6			Bug				Sandra Gómez		29/01/2021			Include if hasCustomPermission
	1.7			Fix Performance	Carolina Alonso		21/10/2021			Include if has custom setting of Forbidden Words validation
	1.8			DE52465			Sandra Gómez		30/09/2021			insertOrUpdateCodigoGestorAsignado
	1.9         USXXXXXX	    Daniel Rodríguez	10/03/2022          Add isBatch()
	2.0			DE70392			Sandra Gómez		03/01/2023			Add AV_AvoidBulkApi in method updateCentro

***********************************************************************************************************************/
public class AV_Task_BI_TRHan extends CC_TriggerHandlerBase {
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Task>)tp.newList, (Map<Id, Task>)tp.newMap, (List<Task>) tp.oldList, (Map<Id, Task>) tp.oldMap);
	}
	
	private void process(List<Task> listNewObj, Map<Id, Task> mapNewObj, List<Task> listOldObj, Map<Id, Task> mapOldObj) {
		//General check the Record type's for intouch project
		List<Task> listData = AV_TaskTriggerHelper.checkGeneralRT(listNewObj);
		
		if (listData!=null && !listData.isEmpty()){
			Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
			AV_TaskTriggerHelper.headerCustomActivity(listData);
			/*if (!hasCustomPermission && AV_Bypass__c.getOrgDefaults().AV_ForbiddenWords__c && !System.isbatch()) {
				AV_TaskTriggerHelper.validateForbiddenWords(listData, mapOldObj);
			}*/
			AV_TaskTriggerHelper.changeOwner(listData, mapOldObj);
			AV_TaskTriggerHelper.processOwnerGestores(listData, mapOldObj);
			AV_TaskTriggerHelper.insertOrUpdateCodigoGestorAsignado(listData, mapOldObj);
			if (!hasCustomPermission) {
				AV_TaskTriggerHelper.updateCentro(listData, mapOldObj);
			}
			AV_TaskTriggerHelper.insertOrUpdateCenterAndRt(listData, mapOldObj);
		}
	}
}