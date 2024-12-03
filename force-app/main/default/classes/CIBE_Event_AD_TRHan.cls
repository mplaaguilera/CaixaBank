/**********************************************************************************************************************
Name:    CIBE_Event_AD_TRHan
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Event AfterDelete
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION     USER_STORY          AUTHOR              DATE                Description
    1.0                             Luis Martínez       29/05/2023          Init version
***********************************************************************************************************************/
public class CIBE_Event_AD_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Event>)tp.newList, (Map<Id, Event>)tp.newMap, (List<Event>)tp.oldList, (Map<Id, Event>)tp.oldMap);
    }
    
    private void process(List<Event> listNewObj, Map<Id, Event> mapNewObj, List<Event> listOldObj, Map<Id, Event> mapOldObj) {
        //General check the Record type's for intouch project
        List<Event> listData = CIBE_EventTriggerHelper.checkGeneralRT(listOldObj);
        
        if (listData!=null && !listData.isEmpty()){
            CIBE_EventTriggerHelper.deleteRecordsRelatedWithEvent(listData);
        }
    }
}