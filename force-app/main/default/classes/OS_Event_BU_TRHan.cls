public with sharing class OS_Event_BU_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Event>)tp.newList, (Map<Id, Event>)tp.newMap, (List<Event>)tp.oldList, (Map<Id, Event>)tp.oldMap);
    }

    private void process(List<Event> listNewObj, Map<Id, Event> mapNewObj, List<Event> listOldObj, Map<Id, Event> mapOldObj) {
        alertaVencida(mapOldObj, listNewObj);
    }

    private void alertaVencida(Map<Id, Event> mapOldObj, List<Event> listNewObj) {
        System.debug('hhh');
    }
}