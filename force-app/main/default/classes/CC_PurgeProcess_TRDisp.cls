/**********************************************************************************************************************
 Name:	  CC_PurgeProcess_TRDisp
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase Dispatcher del trigger del custom object CBK_PurgeProcess__c del FW de purgado.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	25/11/2021			Init version
***********************************************************************************************************************/
public with sharing class CC_PurgeProcess_TRDisp  extends CC_TriggerDispatcherBase {
    
    private static Boolean isBeforeDeleteProcessing = false;
    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterUpdateProcessing = false;
    private static String objectApiName = 'CBK_PurgeProcess__c';
    
    /**
    * @description Metodo invocado en el before delete del trigger 
    * @author   fzaragoza | 26/11/2021 
    * @param    tp  Parametros del trigger (CC_TriggerParameters)
    **/
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

    /**
    * @description Metodo invocado en el after insert del trigger 
    * @author   fzaragoza | 26/11/2021 
    * @param    tp  Parametros del trigger (CC_TriggerParameters)
    **/
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
    
    /**
    * @description Metodo invocado en el after update del trigger 
    * @author   fzaragoza | 26/11/2021 
    * @param    tp  Parametros del trigger (CC_TriggerParameters)
    **/
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