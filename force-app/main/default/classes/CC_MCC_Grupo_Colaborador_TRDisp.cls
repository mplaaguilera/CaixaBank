public with sharing class CC_MCC_Grupo_Colaborador_TRDisp extends CC_TriggerDispatcherBase{
    private static Boolean isBeforeInsertProcessing = false;
    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterUpdateProcessing = false;
    private static Boolean isAfterDeleteProcessing = false;
    private static String objectApiName = 'CC_MCC_Grupo_Colaborador__c';
    
    public virtual override void beforeInsert(CC_TriggerParameters tp) {
        if (!isBeforeInsertProcessing) {
            isBeforeInsertProcessing = true;
            for (String handlerClassName : getAssociatedHandlers(objectApiName, 'beforeInsert')) {
                Type handlerClassType = Type.forName(handlerClassName);
                execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
            }
            isBeforeInsertProcessing = false;
        }
        else {
            execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
        }
    }
    
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