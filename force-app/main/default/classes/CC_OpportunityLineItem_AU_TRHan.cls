public with sharing class CC_OpportunityLineItem_AU_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<OpportunityLineItem>)tp.newList, (Map<Id, OpportunityLineItem>)tp.newMap, (List<OpportunityLineItem>)tp.oldList, (Map<Id, OpportunityLineItem>)tp.oldMap);
    }
    
    private void process(List<OpportunityLineItem> listNewObj, Map<Id, OpportunityLineItem> mapNewObj, List<OpportunityLineItem> listOldObj, Map<Id, OpportunityLineItem> mapOldObj) {
        
    }
}