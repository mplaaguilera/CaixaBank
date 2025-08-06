public with sharing class GRR_Case_BI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList);
    }

    private void process(List<Case> listObj){
        List<Case> casosGRR = GRR_CaseTriggerHelper.filtrarCasosGRR(listObj);
        if(!casosGRR.isEmpty()){
            GRR_CaseTriggerHelper.informarDatosEntradaCOPS(casosGRR);
        }
    }
    
}