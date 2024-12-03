public with sharing class CC_Case_TRDisp extends CC_TriggerDispatcherBase {
    
    private static Boolean isBeforeInsertProcessing = false;
    private static Boolean isBeforeUpdateProcessing = false;
    private static Boolean isBeforeDeleteProcessing = false;
    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterUpdateProcessing = false;
    private static Boolean isAfterDeleteProcessing = false;
    private static Boolean isAfterUndeleteProcessing = false;
	private static String objectApiName = 'Case';
    
    //Old BI
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

    //nuevo BI con filtrado de RT,negocio y profile
    //  public virtual override void beforeInsert(CC_TriggerParameters tp) {
        
    //     if (!isBeforeInsertProcessing) {           
    //         isBeforeInsertProcessing = true;
    //         Map<String, List<SObject>> mLaunchApexWithSObject = segmentationHandlers(tp, objectApiName, 'beforeInsert', false);

    //         for(String handlerClassName : mLaunchApexWithSObject.keySet()){
    //             tp.newList = mLaunchApexWithSObject.get(handlerClassName);
    //             if (tp.newList.size() > 0){
    //                 Type handlerClassType = Type.forName(handlerClassName);
    //                 CBK_Log.debug('handlerClassType ' + handlerClassType);
    //                 CBK_Log.debug('TP:  ' + JSON.serialize(tp));
    //                 execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
    //             }
    //         }
    //         isBeforeInsertProcessing = false;
    //     }
    //     else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
    // }
    
    //Old BU
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

    //nuevo BU con filtrado de RT,negocio y profile
    // public virtual override void beforeUpdate(CC_TriggerParameters tp) {
        
    //     if (!isBeforeUpdateProcessing) {           
    //         isBeforeUpdateProcessing = true;
    //         Map<String, List<SObject>> mLaunchApexWithSObject = segmentationHandlers(tp, objectApiName, 'beforeUpdate', false);
    //         CC_TriggerParameters tpold =  new CC_TriggerParameters();
    //         tpold.oldList = tp.oldList;
    //         for(String handlerClassName : mLaunchApexWithSObject.keySet()){
    //             tp.newList = mLaunchApexWithSObject.get(handlerClassName);
    //             if (tp.newList.size() > 0){
    //                 list<Case> lstcase  = tp.newList;
    //                 tp.newMap = new Map<Id, Case>(lstcase);
    //                 tp.oldList = generateOldList(tp.newList, tpold.oldList);
    //                 lstcase  = tp.oldList;
    //                 tp.oldMap = new Map<Id, Case>(lstcase);
    //                 Type handlerClassType = Type.forName(handlerClassName);
    //                 CBK_Log.debug('handlerClassType ' + handlerClassType);
    //                 CBK_Log.debug('TP:  ' + JSON.serialize(tp));
    //                 execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
    //             }
    //         }
    //         isBeforeUpdateProcessing = false;
    //     }
    //     else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
    // }
    
    //Old BD
    /*public virtual override void beforeDelete(CC_TriggerParameters tp) {
        
        if (!isBeforeDeleteProcessing) {           
            isBeforeDeleteProcessing = true;
            for (String handlerClassName : getAssociatedHandlers(objectApiName, 'beforeDelete')) {
                Type handlerClassType = Type.forName(handlerClassName);
                execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
            }
            isBeforeDeleteProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
    }*/

    //nuevo BD con filtrado de RT,negocio y profile
    // public virtual override void beforeDelete(CC_TriggerParameters tp) {
        
    //     if (!isBeforeDeleteProcessing) {           
    //         isBeforeDeleteProcessing = true;
    //         Map<String, List<SObject>> mLaunchApexWithSObject = segmentationHandlers(tp, objectApiName, 'beforeDelete', true);

    //         for(String handlerClassName : mLaunchApexWithSObject.keySet()){
    //             tp.oldList = mLaunchApexWithSObject.get(handlerClassName);
    //             if (tp.oldList.size() > 0){
    //                 list<Case> lstcase  = tp.oldList;
    //                 tp.oldMap = new Map<Id, Case>(lstcase);
    //                 tp.newList = null;
    //                 Type handlerClassType = Type.forName(handlerClassName);
    //                 CBK_Log.debug('handlerClassType ' + handlerClassType);
    //                 CBK_Log.debug('TP:  ' + JSON.serialize(tp));
    //                 execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
    //             }
    //         }
    //         isBeforeDeleteProcessing = false;
    //     }
    //     else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
    // }

    //Old AI
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

    //nuevo AI con filtrado de RT,negocio y profile
    // public virtual override void afterInsert(CC_TriggerParameters tp) {
    //     if (!isAfterInsertProcessing) {           
    //         isAfterInsertProcessing = true;
    //         Map<String, List<SObject>> mLaunchApexWithSObject = segmentationHandlers(tp, objectApiName, 'afterInsert', false);
    //         for(String handlerClassName : mLaunchApexWithSObject.keySet()){
    //             tp.newList = mLaunchApexWithSObject.get(handlerClassName);
    //             if (tp.newList.size() > 0){
    //                 list<Case> lstcase  = tp.newList;
    //                 tp.newMap = new Map<Id, Case>(lstcase);
                
    //                 Type handlerClassType = Type.forName(handlerClassName);
    //                 CBK_Log.debug('handlerClassType ' + handlerClassType);
    //                 CBK_Log.debug('TP:  ' + JSON.serialize(tp) + '\n\n');
    //                 execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterInsert);
    //             }
    //         }
    //         isAfterInsertProcessing = false;
    //     }
    //     else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterInsert);
    // }
    
    //Old AU
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
   
    //nuevo AU con filtrado de RT,negocio y profile
    // public virtual override void afterUpdate(CC_TriggerParameters tp) {
        
    //     if (!isAfterUpdateProcessing) {           
    //         isAfterUpdateProcessing = true;
    //         Map<String, List<SObject>> mLaunchApexWithSObject = segmentationHandlers(tp, objectApiName, 'afterUpdate', false);
    //         CC_TriggerParameters tpold =  new CC_TriggerParameters();
    //         tpold.oldList = tp.oldList;

    //         for(String handlerClassName : mLaunchApexWithSObject.keySet()){
    //             tp.newList = mLaunchApexWithSObject.get(handlerClassName);
    //             if (tp.newList.size() > 0){
    //                 list<Case> lstcase  = tp.newList;
    //                 tp.newMap = new Map<Id, Case>(lstcase);
    //                 tp.oldList = generateOldList(tp.newList, tpold.oldList);
    //                 lstcase = tp.oldList;
    //                 tp.oldMap = new Map<Id, Case>(lstcase);
    //                 Type handlerClassType = Type.forName(handlerClassName);
    //                 CBK_Log.debug('handlerClassType ' + handlerClassType);
    //                 CBK_Log.debug('TP:  ' + JSON.serialize(tp));
    //                 execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
    //             }
    //         }
    //         isAfterUpdateProcessing = false;
    //     }
    //     else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
    // }

    //Old AD
    public virtual override void afterDelete(CC_TriggerParameters tp) {
        
        if (!isAfterDeleteProcessing) {           
            isAfterDeleteProcessing = true;
            for (String handlerClassName : getAssociatedHandlers(objectApiName, 'afterDelete')) {
                Type handlerClassType = Type.forName(handlerClassName);
                execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterDelete);
            }
            isAfterDeleteProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterDelete);
    }

   //nuevo AD con filtrado de RT,negocio y profile
//    public virtual override void afterDelete(CC_TriggerParameters tp) {
        
//         if (!isAfterDeleteProcessing) {           
//             isAfterDeleteProcessing = true;
//             Map<String, List<SObject>> mLaunchApexWithSObject = segmentationHandlers(tp, objectApiName, 'afterDelete', true);

//             for(String handlerClassName : mLaunchApexWithSObject.keySet()){
//                 tp.oldList = mLaunchApexWithSObject.get(handlerClassName);
//                 if (tp.oldList.size() > 0){
//                     list<Case> lstcase  = tp.oldList;
//                     tp.oldMap = new Map<Id, Case>(lstcase);
//                     tp.newlist = null;
//                     Type handlerClassType = Type.forName(handlerClassName);
//                     CBK_Log.debug('handlerClassType ' + handlerClassType);
//                     CBK_Log.debug('TP:  ' + JSON.serialize(tp));
//                     execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterDelete);
//                 }
//             }
//             isAfterDeleteProcessing = false;
//         }
//         else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterDelete);
//     }

    //Old AUnDel
/*    public virtual override void afterUndelete(CC_TriggerParameters tp) {
        
        if (!isAfterUndeleteProcessing) {           
            isAfterUndeleteProcessing = true;
            for (String handlerClassName : getAssociatedHandlers(objectApiName, 'afterUndelete')) {
                Type handlerClassType = Type.forName(handlerClassName);
                execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterUndelete);
            }
            isAfterUndeleteProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterUndelete);
    }*/

    //nuevo AUnDelete con filtrado de RT,negocio y profile
    // public virtual override void afterUndelete(CC_TriggerParameters tp) {
    //     if (!isAfterUndeleteProcessing) {           
    //         isAfterUndeleteProcessing = true;
    //         Map<String, List<SObject>> mLaunchApexWithSObject = segmentationHandlers(tp, objectApiName, 'afterUndelete', false);

    //         for(String handlerClassName : mLaunchApexWithSObject.keySet()){
    //             tp.newList = mLaunchApexWithSObject.get(handlerClassName);
    //             if (tp.newList.size() > 0){
    //                 list<Case> lstcase  = tp.newList;
    //                 tp.newMap = new Map<Id, Case>(lstcase);
    //                 Type handlerClassType = Type.forName(handlerClassName);
    //                 system.debug('handlerClassType ' + handlerClassType);
    //                 system.debug('TP:  ' + JSON.serialize(tp.newList));
    //                 execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterUndelete);
    //             }
    //         }

    //         isAfterUndeleteProcessing = false;
    //     }
    //     else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterUndelete);
    // }
}