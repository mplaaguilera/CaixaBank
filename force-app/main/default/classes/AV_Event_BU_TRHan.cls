/**********************************************************************************************************************
 Name:	  AV_Event_BU_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Event BeforeUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US124210		Jashanpreet   	    08/10/2020			Init version
	1.1			US104665		Esperanza Conde		21/10/2020			logic completeValueDateReal
	1.2			App FSC			David Rufo			09/12/2020			Include a general check of the Record Types
	1.3			US147562		Álvaro López		13/01/2020			Added new method createCRMTask
	1.4         Bug             Sandra Gómez        29/01/2021          Include if hasCustomPermission
	1.5			Fix Performance	Carolina Alonso		21/10/2021			Include if has custom setting of Forbidden Words validation
	1.6			DE52465			Sandra Gómez		30/09/2021			insertOrUpdateCodigoGestorAsignado
	1.7         USXXXXXX	    Daniel Rodríguez	10/03/2022          Add isBatch()
	1.8			DE63338			Sandra Gómez		18/08/2022			WhitOut Events Outlook
    1.9			FIX		        Alex 			    16/11/2022			Dispatcher Previo Events
	2.0         US453532        Elisabeth Rodríguez 14/12/2022          Added call to changeSubjectToCanceled method
	2.1			DE70392			Sandra Gómez		08/02/2023			Add AV_AvoidBulkApi in method updateCentro

***********************************************************************************************************************/
public class AV_Event_BU_TRHan extends CC_TriggerHandlerBase{
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Event>)tp.newList, (Map<Id, Event>)tp.newMap, (List<Event>) tp.oldList, (Map<Id, Event>) tp.oldMap);
	}
	
	private void process(List<Event> listNewObj, Map<Id, Event> mapNewObj, List<Event> listOldObj, Map<Id, Event> mapOldObj) {
		//General check the Record type's for intouch project
		List<Event> listData = AV_EventTriggerHelper.checkGeneralRT(listNewObj);
		//List<Event> listDataNonRecurrentEvents = AV_EventTriggerHelper.checkNonRecurrentEvents(listData); //Envio Eventos Datapool
		List<Event> listDataWhitoutOutlook = AV_EventTriggerHelper.checkGeneralRTWithoutOutlook(listNewObj); //No tiene los eventos de Outlook
		Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
		if (listData!=null && !listData.isEmpty()){
			AV_EventTriggerHelper.checkOutlookEvent(listData);
		}

		if (listDataWhitoutOutlook!=null && !listDataWhitoutOutlook.isEmpty()) {
			AV_EventTriggerHelper.processOwnerGestores(listDataWhitoutOutlook, mapOldObj);
			/*if (!hasCustomPermission && AV_Bypass__c.getOrgDefaults().AV_ForbiddenWords__c && !System.isbatch()) {
				AV_EventTriggerHelper.validateForbiddenWords(listDataWhitoutOutlook, mapOldObj);
			}*/
		}

		if (listData!=null && !listData.isEmpty()){
			AV_EventTriggerHelper.changeOwner(listData, mapOldObj);
		}

		if (listDataWhitoutOutlook!=null && !listDataWhitoutOutlook.isEmpty()) {
			AV_EventTriggerHelper.createCRMTask(listDataWhitoutOutlook, mapOldObj);
		}

		if (listData!=null && !listData.isEmpty()){
			AV_EventTriggerHelper.insertOrUpdateCodigoGestorAsignado(listData, mapOldObj);
		}
		
		if (listDataWhitoutOutlook!=null && !listDataWhitoutOutlook.isEmpty()) {
			AV_EventTriggerHelper.setMeetingLocation(listDataWhitoutOutlook, mapOldObj, true);
			if (!hasCustomPermission) {
			AV_EventTriggerHelper.updateCentro(listDataWhitoutOutlook, mapOldObj);
		}

		if (listData!=null && !listData.isEmpty()){
			AV_EventTriggerHelper.changeSubjectToCanceled(listNewObj, mapOldObj);
		}
		
	}

		if (listData!=null && !listData.isEmpty()){
			AV_EventTriggerHelper.changeSubjectToCanceled(listNewObj, mapOldObj);
		}
		/*if(listDataNonRecurrentEvents!=null && !listDataNonRecurrentEvents.isEmpty()){ //Envio Eventos Datapool

			AV_SendEvents_Integration sendEvents = new AV_SendEvents_Integration(listDataNonRecurrentEvents, 'M');
  			System.enqueueJob(sendEvents);  

		}*/

		
	}
}