/**********************************************************************************************************************
 Name:	  CIBE_Task_BD_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Event BeforeDelete
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		  	AUTHOR				DATE				Description
	1.0		    US872914			Lucia   		    09/05/2024			Init version
***********************************************************************************************************************/
public with sharing class CIBE_Event_BD_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Event>)tp.newList, (Map<Id, Event>)tp.newMap, (List<Event>)tp.oldList, (Map<Id, Event>)tp.oldMap);
    }
    
    private void process(List<Event> listNewObj, Map<Id, Event> mapNewObj, List<Event> listOldObj, Map<Id, Event> mapOldObj) {
        //General check the Record type's for intouch project
        List<Event> listData = CIBE_EventTriggerHelper.checkGeneralRT(listOldObj);
        
        Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
        if (!hasCustomPermission && !System.isbatch()) {
            CIBE_EventTriggerHelper.deleteRelations(listData);
            CIBE_EventTriggerHelper.updateNextMeetingDate(listData, mapOldObj, null);
        }
        
    }
}