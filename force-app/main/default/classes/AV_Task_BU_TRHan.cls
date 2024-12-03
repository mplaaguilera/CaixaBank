/**********************************************************************************************************************
 Name:	  AV_Task_BU_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Task BeforeUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US124210		Jashanpreet   	    08/10/2020			Init version
	1.1			US104665		Esperanza Conde		21/10/2020			logic completeValueDateReal
	1.2			App FSC			David Rufo			09/12/2020			Include a general check of the Record Types
	1.3			US147562		Sandra Gómez		14/01/2020			Added new method createCRMTask
	1.4			Bug				Sandra Gómez		29/01/2021			Include if hasCustomPermission
	1.5			FIX-IOP Marzo	Carolina Alonso		09/03/2021			Comment method oppoReminder. Conflicts with the new reporting
	1.6			Fix Performance	Carolina Alonso		21/10/2021			Include if has custom setting of Forbidden Words validation
	1.7			DE52465			Sandra Gómez		30/09/2021			insertOrUpdateCodigoGestorAsignado
	1.8         USXXXXXX	    Daniel Rodríguez	10/03/2022          Add isBatch()
	1.9			US339508		Luis Fernández		29/03/2022			Added updateCentro call
	2.0			DE63589			Sandra Gómez		01/09/2022			Add new method updateGCF
	2.1			US457715		Eduardo González	19/10/2022			Add new method updateSinGestor
	2.2 		US481618		Ángel Medina		09/01/2023			Add new method recordChannel
	2.3			DE70392			Sandra Gómez		08/02/2023			Add AV_AvoidBulkApi in method updateCentro
	2.4		 	US610044		Luis Fernández		19/06/2023			Add checkOfficeTaskUpdate method call
	2.5			US546892		Sandra Gómez		12/09/2023			Add method checkReportClient
	2.6			Fix				Sandra Gómez		13/11/2023			Add mapToByPassTask given checkReportClient to bypass
***********************************************************************************************************************/
public class AV_Task_BU_TRHan extends CC_TriggerHandlerBase{
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Task>)tp.newList, (Map<Id, Task>)tp.newMap, (List<Task>) tp.oldList, (Map<Id, Task>) tp.oldMap);
	}
	
	private void process(List<Task> listNewObj, Map<Id, Task> mapNewObj, List<Task> listOldObj, Map<Id, Task> mapOldObj) {
		//General check the Record type's for intouch project
		List<Task> listData = AV_TaskTriggerHelper.checkGeneralRT(listNewObj);
		if (listData!=null && !listData.isEmpty()){
			AV_TaskTriggerHelper.updateGCF(listData, mapOldObj);
			Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
            AV_TaskTriggerHelper.updateSinGestor(listData, mapOldObj);
			/*-- Palabras prohhibidas --
			if (!hasCustomPermission && AV_Bypass__c.getOrgDefaults().AV_ForbiddenWords__c && !System.isbatch()) {
				AV_TaskTriggerHelper.validateForbiddenWords(listData, mapOldObj);
			}*/
			AV_TaskTriggerHelper.changeOwner(listData, mapOldObj);
			AV_TaskTriggerHelper.processOwnerGestores(listData, mapOldObj);
			AV_TaskTriggerHelper.createCRMTask(listData, mapOldObj);
			AV_TaskTriggerHelper.insertOrUpdateCodigoGestorAsignado(listData, mapOldObj);
			if (!hasCustomPermission) {
				AV_TaskTriggerHelper.updateCentro(listData,mapOldObj);
				AV_TaskTriggerHelper.checkOfficeTaskUpdate(listData,mapOldObj);
				mapToByPassTask = AV_TaskTriggerHelper.checkReportClient(listData,mapOldObj);
			}
			AV_TaskTriggerHelper.insertOrUpdateCenterAndRt(listData, mapOldObj);
		}
	}
}