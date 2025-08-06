/**********************************************************************************************************************
 Name:    CC_PortalCaixaBankTalks_TRDisp
 Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
  VERSION	USER_STORY		AUTHOR				DATE			Description
  1.0		US854993		Carolina Lopez		10/04/2024		Add method afterInsert.
***********************************************************************************************************************/
public with sharing class CC_PortalCaixaBankTalks_TRDisp extends CC_TriggerDispatcherBase {
    
    private static Boolean isBeforeInsertProcessing = false;
    private static Boolean isBeforeUpdateProcessing = false;
    private static Boolean isBeforeDeleteProcessing = false;
    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterUpdateProcessing = false;
    private static Boolean isAfterDeleteProcessing = false;
    private static Boolean isAfterUndeleteProcessing = false;
	private static String objectApiName = 'EV_PortalCaixaBankTalks__c';
    
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
}