public with sharing class SAC_ParametrizacionSLATME_TRDisp extends CC_TriggerDispatcherBase {
    private static Boolean isBeforeInsertProcessing = false;
    private static Boolean isBeforeUpdateProcessing = false;
    private static String objectApiName = 'SAC_ParametrizacionSLATME__c';

    /**
    * @description Método invocado en el beforeInsert del trigger de SAC_ParametrizacionSLATME__c
    * @author   Jose Manuel Fernández
    * @param    tp  Parametros del trigger (CC_TriggerParameters)
    **/
    public virtual override void beforeInsert(CC_TriggerParameters tp) {
        if (!isBeforeInsertProcessing) {           
            isBeforeInsertProcessing = true;
            for (String handlerClassName : getAssociatedHandlers(objectApiName, 'beforeInsert')) {
                Type handlerClassType = Type.forName(handlerClassName);
                execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
            }
            isBeforeInsertProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
    }
    
    /**
    * @description Método invocado en el beforeUpdate del trigger de SAC_ParametrizacionSLATME__c
    * @author   Jose Manuel Fernández
    * @param    tp  Parametros del trigger (CC_TriggerParameters)
    **/
    public virtual override void beforeUpdate(CC_TriggerParameters tp) {
        if (!isBeforeUpdateProcessing) {           
            isBeforeUpdateProcessing = true;
            for (String handlerClassName : getAssociatedHandlers(objectApiName, 'beforeUpdate')) {
                Type handlerClassType = Type.forName(handlerClassName);
                execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
            }
            isBeforeUpdateProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
    }    
}