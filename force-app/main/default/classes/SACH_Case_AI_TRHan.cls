public with sharing class SACH_Case_AI_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList);
    }

    private void process(List<Case> lstCasos){
        List<Case> casosSACH = SACH_CaseTriggerHelper.filtrarCasosSACH(lstCasos);

        if (!casosSACH.isEmpty()){
            SACH_CaseTriggerHelper.comprobacionContactoAI(lstCasos);  
        }
    }
}