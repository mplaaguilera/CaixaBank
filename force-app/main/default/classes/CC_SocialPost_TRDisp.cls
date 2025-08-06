public with sharing class CC_SocialPost_TRDisp extends CC_TriggerDispatcherBase {
    
    private static Boolean isBeforeInsertProcessing = false;
    private static Boolean isBeforeUpdateProcessing = false;
    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterUpdateProcessing = false; 
    
    public virtual override void beforeInsert (CC_TriggerParameters tp) {
        
        if(!isBeforeInsertProcessing) {
            isBeforeInsertProcessing = true;
            execute(new CC_SocialPost_BI_TRHan(), tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
            isBeforeInsertProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
    }
}