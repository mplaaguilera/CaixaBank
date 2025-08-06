public with sharing class CC_UR_TRDisp extends CC_TriggerDispatcherBase {
    private static Boolean isAfterUpdateProcessing = false;
    private static Boolean isAfterDeleteProcessing = false;
   
	private static String objectApiName = 'GRR_UR__c';

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

    public virtual override void afterDelete(CC_TriggerParameters tp) {
        
        if (!isAfterDeleteProcessing) {           
            isAfterDeleteProcessing = true;
            for (String handlerClassName : getAssociatedHandlers(objectApiName, 'afterDelete')) {
                Type handlerClassType = Type.forName(handlerClassName);
                execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterDelete);
            }
            isAfterDeleteProcessing = false;
        }
        else {
            execute(null, tp, CC_TriggerParameters.TriggerEvent.afterDelete);
        }
    }
   
}