public with sharing class GRR_Case_BU_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap, (List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
    }
    
    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj, List<Case> listOldObj, Map<Id, Case> mapOldObj) { 
        List<Case> casosGRR = GRR_CaseTriggerHelper.filtrarCasosGRR(listNewObj);
        if(!casosGRR.isEmpty()){
            GRR_CaseTriggerHelper.informarCamposOficina(casosGRR,mapOldObj);
            GRR_CaseTriggerHelper.asignarDirecciones(casosGRR,mapOldObj);
            GRR_CaseTriggerHelper.limpiarDireccionesSiCambiaContacto(casosGRR,mapOldObj);
        }    
    }
}