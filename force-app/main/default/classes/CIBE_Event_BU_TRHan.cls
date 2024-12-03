/**********************************************************************************************************************
 Name:	  CIBE_Event_BU_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Event BeforeUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US407183		Jose Maria	   	    29/08/2022			Init version
	1.1			US407183		Jose Maria 			29/08/2022			Copy retail functionality
    1.2			FIX		        Alex 			    16/11/2022			Dispatcher Previo Events
***********************************************************************************************************************/
public class CIBE_Event_BU_TRHan extends CC_TriggerHandlerBase{
	
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Event>)tp.newList, (Map<Id, Event>)tp.newMap, (List<Event>) tp.oldList, (Map<Id, Event>) tp.oldMap);
    }
    
    private void process(List<Event> listNewObj, Map<Id, Event> mapNewObj, List<Event> listOldObj, Map<Id, Event> mapOldObj) {
        //General check the Record type's for intouch project
        List<Event> listData = CIBE_EventTriggerHelper.checkGeneralRT(listNewObj);
        List<Event> listDataWhitoutOutlook = CIBE_EventTriggerHelper.checkGeneralRTWithoutOutlook(listNewObj); //No tiene los eventos de Outlook
        
        if (listData!=null && !listData.isEmpty()){
            CIBE_EventTriggerHelper.checkOutlookEvent(listData);
        }

        if (listDataWhitoutOutlook!=null && !listDataWhitoutOutlook.isEmpty()) {
            Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
            CIBE_EventTriggerHelper.processOwnerGestores(listDataWhitoutOutlook, mapOldObj);
            /*if (!hasCustomPermission && AV_Bypass__c.getOrgDefaults().AV_ForbiddenWords__c && !System.isbatch()) {
                CIBE_EventTriggerHelper.validateForbiddenWords(listDataWhitoutOutlook, mapOldObj);
            }*/
        }

        if (listData!=null && !listData.isEmpty()){
            CIBE_EventTriggerHelper.changeOwner(listData, mapOldObj);
            CIBE_EventTriggerHelper.updateRelacionadoGC(listData);
        }

        if (listDataWhitoutOutlook!=null && !listDataWhitoutOutlook.isEmpty()) {
            CIBE_EventTriggerHelper.createCRMTask(listDataWhitoutOutlook, mapOldObj);
        }

        if (listData!=null && !listData.isEmpty()){
            CIBE_EventTriggerHelper.insertOrUpdateCodigoGestorAsignado(listData, mapOldObj);
            CIBE_EventTriggerHelper.setConfidentiality(listData, false);
        }
        
        if (listDataWhitoutOutlook!=null && !listDataWhitoutOutlook.isEmpty()) {
            CIBE_EventTriggerHelper.setMeetingLocation(listDataWhitoutOutlook, mapOldObj, true);
            CIBE_EventTriggerHelper.updateCentro(listDataWhitoutOutlook, mapOldObj);
        }
    }
}