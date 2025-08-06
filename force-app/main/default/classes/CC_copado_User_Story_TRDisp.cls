public with sharing class CC_copado_User_Story_TRDisp extends CC_TriggerDispatcherBase {
    
    private static Boolean isBeforeUpdateProcessing = false;
    private static String objectApiName = 'copado__User_Story__c';

    public virtual override void beforeUpdate(CC_TriggerParameters tp) {
        
        if (!isBeforeUpdateProcessing) {           
            isBeforeUpdateProcessing = true;
            for (String handlerClassName : getAssociatedHandlers(objectApiName, 'beforeUpdate')) {
                Type handlerClassType = Type.forName(handlerClassName);
                execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
            }
            isBeforeUpdateProcessing = false;
        }
        else {
            execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
        }
    }
    
   
}