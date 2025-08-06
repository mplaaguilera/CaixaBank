/**
 * @description       : 
 * @group             : 
 * @last modified on  : 03-29-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   03-29-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class CC_Auditoria_TRDisp extends CC_TriggerDispatcherBase {
    
    private static Boolean isBeforeInsertProcessing = false;
    private static Boolean isBeforeUpdateProcessing = false;
    private static Boolean isBeforeDeleteProcessing = false;
    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterUpdateProcessing = false;
    private static Boolean isAfterDeleteProcessing = false;
    private static Boolean isAfterUndeleteProcessing = false;
	private static String objectApiName = 'SEG_Auditoria__c';
    
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
    
   /* public virtual override void beforeUpdate(CC_TriggerParameters tp) {
        
        if (!isBeforeUpdateProcessing) {           
            isBeforeUpdateProcessing = true;
            for (String handlerClassName : getAssociatedHandlers(objectApiName, 'beforeUpdate')) {
                Type handlerClassType = Type.forName(handlerClassName);
                execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
            }
            isBeforeUpdateProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
    }*/

    public virtual override void afterUpdate(CC_TriggerParameters tp) {
        
        if (!isAfterUpdateProcessing) {           
            isAfterUpdateProcessing = true;
            for (String handlerClassName : getAssociatedHandlers(objectApiName, 'afterUpdate')) {
                Type handlerClassType = Type.forName(handlerClassName);
                execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
            }
            isAfterUpdateProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
    }
}