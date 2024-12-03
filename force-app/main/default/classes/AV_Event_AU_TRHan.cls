/**********************************************************************************************************************
 Name:	  AV_Event_AU_TRHan
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase para Trigger de Event AfterUpdate
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Jashanpreet        	20/10/2020			Init version
	1.1			App FSC			David Rufo			09/12/2020			Include a general check of the Record Types
	1.2			US286825 		Daniel Rodríguez	13/01/2022			Add Method updateNextManagementDateOpp
	1.3         USXXXXXX	    Daniel Rodríguez	10/03/2022          Add isBatch()
	1.4			DE63338			Sandra Gómez		18/08/2022			WhitOut Events Outlook
	1.5			Fix GCF			Sandra Gómez		17/02/2023			hasCustomPermission add apigcf
	1.6			US-0006226      David Ramos			23/10/2023			Add Kafka mathod syncEventsKafka
***********************************************************************************************************************/
public class AV_Event_AU_TRHan extends CC_TriggerHandlerBase{
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Event>)tp.newList, (Map<Id, Event>)tp.newMap, (List<Event>) tp.oldList, (Map<Id, Event>) tp.oldMap);
	}
	
	private void process(List<Event> listNewObj, Map<Id, Event> mapNewObj, List<Event> listOldObj, Map<Id, Event> mapOldObj) {
		//General check the Record type's for intouch project
		List<Event> listData = AV_EventTriggerHelper.checkGeneralRT(listNewObj);
		List<Event> listDataWhitoutOutlook = AV_EventTriggerHelper.checkGeneralRTWithoutOutlook(listNewObj); //No tiene los eventos de Outlook
		Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
		if (listDataWhitoutOutlook!=null && !listDataWhitoutOutlook.isEmpty()){
			if (!hasCustomPermission){
				AV_EventTriggerHelper.syncEvents(listDataWhitoutOutlook, listOldObj);

				//POC Kafka configuration in AV_KafkaConfiguration__mdt
				AV_KafkaEv_Integration.syncEventsKafka(listDataWhitoutOutlook);
			}

		}

		if (listData!=null && !listData.isEmpty()){
			AV_EventTriggerHelper.updateHeaderCustomActivityExtId(listData, mapOldObj);
		}

		if (listDataWhitoutOutlook!=null && !listDataWhitoutOutlook.isEmpty()){
			if (!hasCustomPermission && !System.isbatch()){
				AV_EventTriggerHelper.updateNextManagementDateOpp(listDataWhitoutOutlook, mapOldObj);
			}
		}

		if (listData!=null && !listData.isEmpty()){
			AV_EventTriggerHelper.recordChannel(listData, mapOldObj);
		}



	}
}