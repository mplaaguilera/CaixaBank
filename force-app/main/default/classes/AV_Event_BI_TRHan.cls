/**********************************************************************************************************************
 Name:	  AV_Event_BI_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Event BeforeInsert
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Carolina Alonso	   	06/05/2020			Init version
	1.1			App FSC			David Rufo	   		22/05/2020			Update class for DML error's in the batches
	1.2			App FSC			Carolina Alonso 	02/10/2020			Add ExternalId on events created from Flow associated with Opportunity
	1.3			US104665		Esperanza Conde		21/10/2020			logic completeValueDateReal
	1.4			App FSC			David Rufo			09/12/2020			Include a general check of the Record Types
	1.5			Bug				Sandra Gómez		29/01/2021			Include if hasCustomPermission
	1.6			FIX Outlook		Jashanpreet			27/07/2021			Included method checkOutlookEvent
	1.7			Fix Performance	Carolina Alonso		21/10/2021			Include if has custom setting of Forbidden Words validation
	1.8			DE52465			Sandra Gómez		30/09/2021			insertOrUpdateCodigoGestorAsignado
	1.9         USXXXXXX	    Daniel Rodríguez	10/03/2022          Add isBatch()
	1.10        US304978	    Víctor Santiago		07/04/2022          Added setMeetingLocation
	2.0			DE63338			Sandra Gómez		18/08/2022			WhitOut Events Outlook
    2.1			FIX		        Alex 			    16/11/2022			Dispatcher Previo Events
	2.2			DE70392			Sandra Gómez		03/01/2023			Add AV_AvoidBulkApi in method updateCentro

***********************************************************************************************************************/
public class AV_Event_BI_TRHan { //extends CC_TriggerHandlerBase {
	
	/*public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Event>)tp.newList, (Map<Id, Event>)tp.newMap, (List<Event>) tp.oldList, (Map<Id, Event>) tp.oldMap);
	}*/
	
	public void process(List<Event> listNewObj, Map<Id, Event> mapNewObj, List<Event> listOldObj, Map<Id, Event> mapOldObj) {
		//General check the Record type's for intouch project
		List<Event> listData = AV_EventTriggerHelper.checkGeneralRT(listNewObj);
		List<Event> listDataWhitoutOutlook = AV_EventTriggerHelper.checkGeneralRTWithoutOutlook(listNewObj); //No tiene los eventos de Outlook

		if (listData!=null && !listData.isEmpty()){
			AV_EventTriggerHelper.headerCustomActivity(listDataWhitoutOutlook);
			AV_EventTriggerHelper.checkOutlookEvent(listData);
			AV_EventTriggerHelper.changeOwner(listData, mapOldObj);
			AV_EventTriggerHelper.insertOrUpdateCodigoGestorAsignado(listData, mapOldObj);
		}
		AV_EventTriggerHelper.setEventChanelAndPurpose(listNewObj);

		if (listDataWhitoutOutlook != null && !listDataWhitoutOutlook.isEmpty()){
			Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
			/*if (!hasCustomPermission && AV_Bypass__c.getOrgDefaults().AV_ForbiddenWords__c && !System.isbatch()) {
				AV_EventTriggerHelper.validateForbiddenWords(listDataWhitoutOutlook, mapOldObj);
			}*/
			AV_EventTriggerHelper.processOwnerGestores(listDataWhitoutOutlook, mapOldObj);
			AV_EventTriggerHelper.setMeetingLocation(listDataWhitoutOutlook, mapOldObj, false);
			if (!hasCustomPermission) {
				AV_EventTriggerHelper.updateCentro(listDataWhitoutOutlook,mapOldObj);
			}
		}
	}
	
}