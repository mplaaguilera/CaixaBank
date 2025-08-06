public with sharing class SAC_Case_AD_TRHan extends CC_TriggerHandlerBase {
    
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap, (List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
	}
    
    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {

        Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        List<Case> listaCasosVieja = new List<Case>();
      
        for (case caso : listOldObj) {
            if (caso.RecordTypeId == recTypePretension) {
                listaCasosVieja.add(caso);
            }
        }

        if(!listaCasosVieja.isEmpty()){
            SAC_CaseCalcularImporte.calcular(new List<Case>(), null, mapOldObj);
        }

    }
}