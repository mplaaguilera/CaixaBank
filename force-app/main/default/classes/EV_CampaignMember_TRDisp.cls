public with sharing class EV_CampaignMember_TRDisp extends CC_TriggerDispatcherBase {

    private static Boolean isBeforeDeleteProcessing = false;
    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterUpdateProcessing = false; 
    
    public virtual override void afterInsert(CC_TriggerParameters tp) {
        if(!isAfterInsertProcessing) {
            isAfterInsertProcessing = true;
            execute(new EV_CampaignMember_AI_TRHan(), tp, CC_TriggerParameters.TriggerEvent.afterInsert);
            isAfterInsertProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterInsert);
    }
    
    public virtual override void afterUpdate(CC_TriggerParameters tp) {
        if(!isAfterUpdateProcessing) {
            isAfterUpdateProcessing = true;
            execute(new EV_CampaignMember_AU_TRHan(), tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
            isAfterUpdateProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
    }
    
    public virtual override void beforeDelete(CC_TriggerParameters tp) {
        if(!isBeforeDeleteProcessing) {
            isBeforeDeleteProcessing = true;
            execute(new EV_CampaignMember_BD_TRHan(), tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
            isBeforeDeleteProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
    }
    

}