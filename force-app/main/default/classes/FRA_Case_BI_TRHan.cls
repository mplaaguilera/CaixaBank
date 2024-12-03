public with sharing class FRA_Case_BI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList);
    }

    private void process(List<Case> listObj){
        List<Case> casosFRA = FRA_CaseTriggerHelper.filtrarCasosFRA(listObj);
        if(!casosFRA.isEmpty()){
            FRA_CaseTriggerHelper.informarCanalResolucion(casosFRA);
        }
    }
    
}