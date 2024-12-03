public with sharing class SAC_ContentDocument_TRDisp extends CC_TriggerDispatcherBase {

    private static Boolean isBeforeDeleteProcessing = false;
    private static String objectApiName = 'ContentDocument';
    
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