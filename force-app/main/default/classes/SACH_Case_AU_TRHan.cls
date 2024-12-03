public with sharing class SACH_Case_AU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<ID, Case>)tp.newMap,(List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
    }

    private void process(List<Case> listObj, Map<ID, Case> mapObj, List<Case> listOldObj, Map<ID, Case> mapOldObj){
        List<Case> casosSACH = SACH_CaseTriggerHelper.filtrarCasosSACH(listObj);

        if (!casosSACH.isEmpty()){
            SACH_CaseTriggerHelper.crearTareaDeCerrar(casosSACH, mapOldObj);
            SACH_CaseTriggerHelper.crearTareaDeReasignacion(casosSACH, mapOldObj);
        }
    }
}