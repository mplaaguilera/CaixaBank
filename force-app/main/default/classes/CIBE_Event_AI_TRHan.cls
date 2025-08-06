/**********************************************************************************************************************
 Name:	  CIBE_Event_AI_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Event AfterInsert para CIBE
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US407183		Jose Maria        	29/08/2022			Init version
    2.0         US407183        Jose Maria          29/08/2022          Copy Retail functionality

***********************************************************************************************************************/
public class CIBE_Event_AI_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Event>)tp.newList, (Map<Id, Event>)tp.newMap, (List<Event>) tp.oldList, (Map<Id, Event>) tp.oldMap);
	}
	
	private void process(List<Event> listNewObj, Map<Id, Event> mapNewObj, List<Event> listOldObj, Map<Id, Event> mapOldObj) {
		List<Event> listDataWhitoutOutlook= CIBE_EventTriggerHelper.checkGeneralRTWithoutOutlook(listNewObj); 
		
		if (listDataWhitoutOutlook!=null && !listDataWhitoutOutlook.isEmpty()){
			Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
			if (!hasCustomPermission) {
				CIBE_EventTriggerHelper.callApiTeams(listDataWhitoutOutlook);
				CIBE_EventTriggerHelper.syncEvents(listDataWhitoutOutlook, mapOldObj);
			}
			CIBE_EventTriggerHelper.createCRMTask(listDataWhitoutOutlook, mapOldObj);
		}
	}
}