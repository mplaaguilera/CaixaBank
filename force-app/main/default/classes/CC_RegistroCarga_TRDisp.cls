public with sharing class CC_RegistroCarga_TRDisp extends CC_TriggerDispatcherBase {
    
   
    private static Boolean isAfterInsertProcessing = false;
	private static String objectApiName = 'GRR_RegistroCarga__c';

    public virtual override void afterInsert(CC_TriggerParameters tp) {
        
        if (!isAfterInsertProcessing) {           
            isAfterInsertProcessing = true;
            for (String handlerClassName : getAssociatedHandlers(objectApiName, 'afterInsert')) {
                Type handlerClassType = Type.forName(handlerClassName);
                execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterInsert);
            }
            isAfterInsertProcessing = false;
        }
        else {
            execute(null, tp, CC_TriggerParameters.TriggerEvent.afterInsert);
        }
    }
    
}