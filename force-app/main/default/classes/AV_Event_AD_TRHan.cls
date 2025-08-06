/**********************************************************************************************************************
 Name:	  AV_Event_AD_TRHan
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase para Trigger de Event AfterDelete
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			Fix Delete		Elisabeth Rodríguez 07/11/2022			Init version
    1.1         Fix RT          Sandra Gómez        29/11/2022          Add checkGeneralRT

***********************************************************************************************************************/
public class AV_Event_AD_TRHan extends CC_TriggerHandlerBase{
    
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Event>)tp.newList, (Map<Id, Event>)tp.newMap, (List<Event>) tp.oldList, (Map<Id, Event>) tp.oldMap);
	}
    
    private void process(List<Event> listNewObj, Map<Id, Event> mapNewObj, List<Event> listOldObj, Map<Id, Event> mapOldObj) {
        List<Event> listDataOld = AV_EventTriggerHelper.checkGeneralRT(listOldObj);
        Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
		if (!hasCustomPermission && !System.isbatch()) {
			AV_EventTriggerHelper.deleteEvent(listDataOld);
        }

    }
}