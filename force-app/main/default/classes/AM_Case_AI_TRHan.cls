public with sharing class AM_Case_AI_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList);
    }

    private void process(List<Case> listObj){
        List<Case> casosAM = AM_CaseTriggerHelper.filtrarCasosAM(listObj);

        if (!casosAM.isEmpty()){
            AM_CaseTriggerHelper.creacionCaso_AI(JSON.serialize(listObj));

        }
    }
}