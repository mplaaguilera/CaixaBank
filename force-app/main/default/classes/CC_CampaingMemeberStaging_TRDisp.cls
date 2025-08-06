public with sharing class CC_CampaingMemeberStaging_TRDisp extends CC_TriggerDispatcherBase {

    private static Boolean isBeforeInsertProcessing = false; 
    private static Boolean isBeforeUpdateProcessing = false; 
    private static Boolean isBeforeDeleteProcessing = false;
    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterUpdateProcessing = false; 
    
    public virtual override void afterInsert(CC_TriggerParameters tp) {
        if(!isAfterInsertProcessing) {
            isAfterInsertProcessing = true;
            execute(new EV_CampaignMemberStaging_AI_TRHan(), tp, CC_TriggerParameters.TriggerEvent.afterInsert);
            isAfterInsertProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterInsert);
    }
    
    
    public virtual override void beforeInsert(CC_TriggerParameters tp) {
        if(!isBeforeInsertProcessing) {
            isBeforeInsertProcessing = true;
            execute(new EV_CampaignMemberStaging_BI_TRHan(), tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
            isBeforeInsertProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
    }

    

}