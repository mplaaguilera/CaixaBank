public class HDT_LiveChatTranscriptEvent_TRDisp extends CC_TriggerDispatcherBase {

    /*
    * Trigger dispatcher para el objeto <LiveChatTranscriptEvent>
    *
    * Cada función de Dispatcher gestiona la re-entrada de la misma forma:
    * La varible estática contiene true si se estava ejecutando ese Handler, y false si es la primera vez en este contexto
    *
    * Cada evento invoca a su Handler específico, dedicado a ese evento
    * 
    */
    
    private static Boolean isBeforeInsertProcessing = false;
    private static Boolean isBeforeUpdateProcessing = false;
    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterUpdateProcessing = false; 

    /* EJEMPLO
    public virtual override void beforeInsert(CC_TriggerParameters tp) {
        if(!isBeforeInsertProcessing) {
            isBeforeInsertProcessing = true;
            execute(new CC_LiveAgentTransEvent_AI_TRHan(), tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
            isBeforeInsertProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
    }*/
    
    /* EJEMPLO
    public virtual override void beforeUpdate(CC_TriggerParameters tp) {
        if(!isBeforeUpdateProcessing) {
            isBeforeUpdateProcessing = true;
            execute(new CC_LiveAgentTransEvent_BU_TRHan(), tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
            isBeforeUpdateProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
    }*/
    
    @testvisible
    public virtual override void afterInsert(CC_TriggerParameters tp) {
        if(!isAfterInsertProcessing) {
            isAfterInsertProcessing = true;
            execute(new HDT_LiveAgentTransEvent_AI_TRHan(), tp, CC_TriggerParameters.TriggerEvent.afterInsert);
            isAfterInsertProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterInsert);
    }
    
    /* EJEMPLO
    public virtual override void afterUpdate(CC_TriggerParameters tp) {
        if(!isAfterUpdateProcessing) {
            isAfterUpdateProcessing = true;
            execute(new CC_LiveAgentTransEvent_AU_TRHan(), tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
            isAfterUpdateProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
    }
	*/
}