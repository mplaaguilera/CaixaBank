public with sharing class CC_copado_Release_TRDisp extends CC_TriggerDispatcherBase {
    private static Boolean isAfterUpdateProcessing = false;
    private static String objectApiName = 'copado__Release__c';

    public virtual override void afterUpdate(CC_TriggerParameters tp) {
        
        if (!isAfterUpdateProcessing) {           
            isAfterUpdateProcessing = true;
            for (String handlerClassName : getAssociatedHandlers(objectApiName, 'afterUpdate')) {
                Type handlerClassType = Type.forName(handlerClassName);
                execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
            }
            isAfterUpdateProcessing = false;
        }
        else {
            execute(null, tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
        }
    }
}