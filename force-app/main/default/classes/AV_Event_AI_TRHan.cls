/**********************************************************************************************************************
 Name:	  AV_Event_AI_TRHan
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase para Trigger de Event AfterInsert
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Jashanpreet        	20/10/2020			Init version
	1.1			App FSC			David Rufo			09/12/2020			Include a general check of the Record Types
	1.2			US147562		Álvaro López		13/01/2020			Added new method createCRMTask
	1.3			DE63338			Sandra Gómez		18/08/2022			WhitOut Events Outlook
	1.4			DE66184			Sandra Gómez		26/10/2022			Add callApiTeams method
	1.5			Fix GCF			Sandra Gómez		17/02/2023			hasCustomPermission add apigcf
	1.6			US-0006226      David Ramos			23/10/2023			Add Kafka mathod syncEventsKafka
	1.8			PPM100538432	Sandra Gómez		17/09/2024			Add parameter mapToByPassEvent
***********************************************************************************************************************/
public class AV_Event_AI_TRHan extends AV_TriggerHandlerBase {
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Event>)tp.newList, (Map<Id, Event>)tp.newMap, (List<Event>) tp.oldList, (Map<Id, Event>) tp.oldMap);
	}
	
	private void process(List<Event> listNewObj, Map<Id, Event> mapNewObj, List<Event> listOldObj, Map<Id, Event> mapOldObj) {
		//General check the Record type's for intouch project
		List<Event> listData = AV_EventTriggerHelper.checkGeneralRT(listNewObj);
		//List<Event> listDataNonRecurrentEvents = AV_EventTriggerHelper.checkNonRecurrentEvents(listData); //Envio Eventos Datapool
		List<Event> listDataWhitoutOutlook= AV_EventTriggerHelper.checkGeneralRTWithoutOutlook(listNewObj); //No tiene los eventos de Outlook
		if (listDataWhitoutOutlook!=null && !listDataWhitoutOutlook.isEmpty()){
			Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
			if (!hasCustomPermission) {
				AV_EventTriggerHelper.callApiTeams(listDataWhitoutOutlook);
				AV_EventTriggerHelper.syncEvents(listDataWhitoutOutlook, listOldObj,mapToByPassEvent);
				//POC Kafka configuration in AV_KafkaConfiguration__mdt
				AV_KafkaEv_Integration.syncEventsKafka(listDataWhitoutOutlook);
			}
			AV_EventTriggerHelper.createCRMTask(listDataWhitoutOutlook, mapOldObj);
			AV_EventTriggerHelper.updateNextEventDateFieldOfOpp(listDataWhitoutOutlook, mapOldObj);
		}
	}
}