public with sharing class FRA_Case_AU_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap, (List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
	}

    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) {

        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FRA_Cliente').getRecordTypeId();
        List<Case> lstCasesCC = new List<Case>();
        for (Case caso : listNewObj) {
            if (caso.RecordTypeId == rtEmpleado) {
                lstCasesCC.add(caso);
            }
        }

        //Ejecutamos las acciones correspondientes dentro de este codigo después de actualizar el caso.
        if (!lstCasesCC.isEmpty()) {          
            FRA_CaseTriggerHelper.cambiarbuzonescolas(lstCasesCC, mapOldObj);
        }
    }
}