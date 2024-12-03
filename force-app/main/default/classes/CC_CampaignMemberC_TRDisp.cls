/**********************************************************************************************************************
 Name:   CC_CampaignMemberC_TRDisp
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Dispatcher para los trigger de EV_CampaignMember__c
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION     USER_STORY          AUTHOR              DATE                Description
	1.0			US584499			Mamen Arias			20/04/2023			Init Version.
***********************************************************************************************************************/
public with sharing class CC_CampaignMemberC_TRDisp extends CC_TriggerDispatcherBase {
	private static Boolean isBeforeDeleteProcessing = false;
	private static Boolean isBeforeInsertProcessing = false;
	private static Boolean isBeforeUpdateProcessing = false;
	private static Boolean isAfterInsertProcessing = false;
	private static Boolean isAfterUpdateProcessing = false;
	
	public virtual override void afterInsert(CC_TriggerParameters tp) {
		if(!isAfterInsertProcessing) {
			isAfterInsertProcessing = true;
			execute(new EV_CampaignMemberC_AI_TRHan(), tp, CC_TriggerParameters.TriggerEvent.afterInsert);
			isAfterInsertProcessing = false;
		}
		else{
			execute(null, tp, CC_TriggerParameters.TriggerEvent.afterInsert);
		} 
	}
	
	public virtual override void afterUpdate(CC_TriggerParameters tp) {
		if(!isAfterUpdateProcessing) {
			isAfterUpdateProcessing = true;
			execute(new EV_CampaignMemberC_AU_TRHan(), tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
			isAfterUpdateProcessing = false;
		}
		else{
			execute(null, tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
		} 
	}
	
	public virtual override void beforeDelete(CC_TriggerParameters tp) {
		if(!isBeforeDeleteProcessing) {
			isBeforeDeleteProcessing = true;
			execute(new EV_CampaignMemberC_BD_TRHan(), tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
			isBeforeDeleteProcessing = false;
		}
		else{
			execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
		} 
	}

	public virtual override void beforeInsert(CC_TriggerParameters tp) {
		if(!isBeforeInsertProcessing) {
			isBeforeInsertProcessing = true;
			execute(new EV_CampaignMemberC_BI_TRHan(), tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
			isBeforeInsertProcessing = false;
		}
		else{
			execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
		} 
	}

	public virtual override void beforeUpdate(CC_TriggerParameters tp) {
		if(!isBeforeUpdateProcessing) {
			isBeforeUpdateProcessing = true;
			execute(new EV_CampaignMemberC_BU_TRHan(), tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
			isBeforeUpdateProcessing = false;
		}
		else{
			execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
		} 
	}
}