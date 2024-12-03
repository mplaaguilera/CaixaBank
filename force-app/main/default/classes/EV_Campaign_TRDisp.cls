public with sharing class EV_Campaign_TRDisp extends CC_TriggerDispatcherBase {
    
    private static Boolean isAfterInsertProcessing = false;
    
    public virtual override void afterInsert(CC_TriggerParameters tp) {
        if(!isAfterInsertProcessing) {
            isAfterInsertProcessing = true;
            execute(new EV_Campaign_AI_TRHan(), tp, CC_TriggerParameters.TriggerEvent.afterInsert);
            isAfterInsertProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterInsert);
    }
    
}