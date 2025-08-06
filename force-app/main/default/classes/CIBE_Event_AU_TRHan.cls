/**********************************************************************************************************************
 Name:	  CIBE_Event_AU_TRHan
 Copyright © 2022  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Event AfterUpdate para CIBE
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US407183		Jose Maria        	29/08/2022			Init version
    2.0         US407183        Jose Maria          29/08/2022          Copy Retail functionality

***********************************************************************************************************************/

public class CIBE_Event_AU_TRHan extends CC_TriggerHandlerBase{

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Event>)tp.newList, (Map<Id, Event>)tp.newMap, (List<Event>) tp.oldList, (Map<Id, Event>) tp.oldMap);
	}
	
	private void process(List<Event> listNewObj, Map<Id, Event> mapNewObj, List<Event> listOldObj, Map<Id, Event> mapOldObj) {
		//General check the Record type's for intouch project
		List<Event> listData = CIBE_EventTriggerHelper.checkGeneralRT(listNewObj);
		List<Event> listDataWithoutOutlook = CIBE_EventTriggerHelper.checkGeneralRTWithoutOutlook(listNewObj); //No tiene los eventos de Outlook
		
		if (listData!=null && !listData.isEmpty()){
			CIBE_EventTriggerHelper.updateHeaderCustomActivityExtId(listData, mapOldObj);
			CIBE_EventTriggerHelper.updateAccessList(listData, mapOldObj);
			CIBE_EventTriggerHelper.updateNextMeetingDate(listData, mapOldObj, null);
		}

		if (listDataWithoutOutlook!=null && !listDataWithoutOutlook.isEmpty()){
			CIBE_EventTriggerHelper.syncEvents(listDataWithoutOutlook, mapOldObj);
			// Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
			// if (!hasCustomPermission && !System.isbatch()){
			// 	CIBE_EventTriggerHelper.updateNextManagementDateOpp(listDataWithoutOutlook, mapOldObj);
				
			// }
		}
	}
}