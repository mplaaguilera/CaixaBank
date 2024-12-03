public with sharing class OB_Llamada_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CC_Llamada__c>)tp.newList, (Map<Id, CC_Llamada__c>)tp.newMap);
	}

    private static void process(List<CC_Llamada__c> listNewObj, Map<Id, CC_Llamada__c> mapNewObj) {
        List<Id> idsOutbound = obtenerIdsOutbound(listNewObj);
    }

    private static List<Id> obtenerIdsOutbound(List<CC_Llamada__c> llamadas) {
        List<Id> idsOutbound = new List<Id>();
        for (CC_Llamada__c llamada : llamadas) {
            if (Schema.SObjectType.CC_Llamada__c.getRecordTypeInfosById().get(llamada.RecordTypeId).getDeveloperName().startsWith('OB_')) {
                idsOutbound.add(llamada.Id);
            }
        }
        return idsOutbound;
    }
}