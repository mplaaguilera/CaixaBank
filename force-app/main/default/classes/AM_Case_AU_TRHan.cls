public with sharing class AM_Case_AU_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<ID, Case>)tp.newMap,(List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
    }

    private void process(List<Case> listObj, Map<ID, Case> mapObj, List<Case> listOldObj, Map<ID, Case> mapOldObj){
        List<Case> casosAM = AM_CaseTriggerHelper.filtrarCasosAM(listObj);

        if (!casosAM.isEmpty()){
            AM_CaseTriggerHelper.actualizarAgrupadorAU(casosAM,mapOldObj);
            AM_CaseTriggerHelper.asociaActivoAU(casosAM,mapOldObj);
        }
    }
}