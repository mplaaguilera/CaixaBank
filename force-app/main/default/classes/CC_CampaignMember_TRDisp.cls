/**********************************************************************************************************************
 Name:   CC_CampaignMember_TRDisp
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Dispatcher para los trigger de CampaignMember
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION     USER_STORY          AUTHOR                  DATE                Description
	1.0         US764367            Carolina Lopez          23/11/2023          Include beforeDelete.
***********************************************************************************************************************/
public with sharing class CC_CampaignMember_TRDisp extends CC_TriggerDispatcherBase {

    private static Boolean isBeforeInsertProcessing = false; 
    private static Boolean isBeforeUpdateProcessing = false; 
    private static Boolean isBeforeDeleteProcessing = false;
    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterUpdateProcessing = false; 
    
    public virtual override void beforeDelete(CC_TriggerParameters tp) {
        if(!isBeforeDeleteProcessing) {
            isBeforeDeleteProcessing = true;
            execute(new EV_CampaignMember_BD_TRHan(), tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
            isBeforeDeleteProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
    }

    public virtual override void beforeInsert(CC_TriggerParameters tp) {
        if(!isBeforeInsertProcessing) {
            isBeforeInsertProcessing = true;
            execute(new EV_CampaignMember_BI_TRHan(), tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
            isBeforeInsertProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
    }

    public virtual override void beforeUpdate(CC_TriggerParameters tp) {
        if(!isBeforeUpdateProcessing) {
            isBeforeUpdateProcessing = true;
            execute(new EV_CampaignMember_BU_TRHan(), tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
            isBeforeUpdateProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
    }

    public virtual override void afterInsert(CC_TriggerParameters tp) {
        if(!isAfterInsertProcessing) {
            isAfterInsertProcessing = true;
            execute(new EV_CampaignMember_AI_TRHan(), tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
            isAfterInsertProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
    }

    public virtual override void afterUpdate(CC_TriggerParameters tp) {
        if(!isAfterUpdateProcessing) {
            isAfterUpdateProcessing = true;
            execute(new EV_CampaignMember_AU_TRHan(), tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
            isAfterUpdateProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
    }
}