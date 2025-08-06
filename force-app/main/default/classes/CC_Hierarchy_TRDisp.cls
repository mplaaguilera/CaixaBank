public with sharing class CC_Hierarchy_TRDisp extends CC_TriggerDispatcherBase{
    private static Boolean isBeforeInsertProcessing = false;
    private static Boolean isBeforeUpdateProcessing = false;
    private static Boolean isBeforeDeleteProcessing = false;
    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterUpdateProcessing = false;
    private static Boolean isAfterDeleteProcessing = false;
    private static Boolean isAfterUndeleteProcessing = false;
    private static String objectApiName = 'CIBE_Hierarchy__c';

    
    public virtual override void afterInsert(CC_TriggerParameters tp) {
        
        if (!isAfterInsertProcessing) {           
            isAfterInsertProcessing = true;
            for (String handlerClassName : getAssociatedHandlers(objectApiName, 'afterInsert')) {
                Type handlerClassType = Type.forName(handlerClassName);
                execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterInsert);
            }
            isAfterInsertProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterInsert);
    }
    
    public virtual override void beforeDelete(CC_TriggerParameters tp) {
        
        if (!isBeforeDeleteProcessing) {           
            isBeforeDeleteProcessing = true;
            for (String handlerClassName : getAssociatedHandlers(objectApiName, 'beforeDelete')) {
                Type handlerClassType = Type.forName(handlerClassName);
                execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
            }
            isBeforeDeleteProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
    }
}