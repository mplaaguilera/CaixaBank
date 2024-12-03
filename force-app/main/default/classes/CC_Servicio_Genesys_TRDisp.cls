public with sharing class CC_Servicio_Genesys_TRDisp extends CC_TriggerDispatcherBase {

    public virtual override void beforeDelete(CC_TriggerParameters tp) 
    {
        execute(new CC_Servicio_Genesys_BD_TRHan(), tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
    }
    
}