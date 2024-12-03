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
	1.1			CStatistics			Mamen Arias			13/03/2024			Add method afterDelete and modify methods with getAssociatedHandlers()
***********************************************************************************************************************/
public with sharing class CC_CampaignMemberC_TRDisp extends CC_TriggerDispatcherBase {
	private static Boolean isBeforeDeleteProcessing = false;
	private static Boolean isBeforeInsertProcessing = false;
	private static Boolean isBeforeUpdateProcessing = false;
	private static Boolean isAfterInsertProcessing = false;
	private static Boolean isAfterUpdateProcessing = false;
	private static Boolean isAfterDeleteProcessing = false;
	private static String objectApiName = 'EV_CampaignMember__c';
	
	public virtual override void afterInsert(CC_TriggerParameters tp) {
		if(!isAfterInsertProcessing) {
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
		if(!isAfterUpdateProcessing) {
			isAfterUpdateProcessing = true;
			for (String handlerClassName : getAssociatedHandlers(objectApiName, 'afterUpdate')) {
				Type handlerClassType = Type.forName(handlerClassName);
				execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
			}
			isAfterUpdateProcessing = false;
		}
		else{
			execute(null, tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
		} 
	}

	public virtual override void afterDelete(CC_TriggerParameters tp) {
		if(!isAfterDeleteProcessing) {
			isAfterDeleteProcessing = true;
			for (String handlerClassName : getAssociatedHandlers(objectApiName, 'afterDelete')) {
				Type handlerClassType = Type.forName(handlerClassName);
				execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterDelete);
			}
			isAfterDeleteProcessing = false;
		}
		else{
			execute(null, tp, CC_TriggerParameters.TriggerEvent.afterDelete);
		} 
	}
	
	public virtual override void beforeDelete(CC_TriggerParameters tp) {
		if(!isBeforeDeleteProcessing) {
			isBeforeDeleteProcessing = true;
			for (String handlerClassName : getAssociatedHandlers(objectApiName, 'beforeDelete')) {
				Type handlerClassType = Type.forName(handlerClassName);
				execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
			}
			isBeforeDeleteProcessing = false;
		}
		else{
			execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
		} 
	}

	public virtual override void beforeInsert(CC_TriggerParameters tp) {
		if(!isBeforeInsertProcessing) {
			isBeforeInsertProcessing = true;
			for (String handlerClassName : getAssociatedHandlers(objectApiName, 'beforeInsert')) {
				Type handlerClassType = Type.forName(handlerClassName);
				execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
			}
			isBeforeInsertProcessing = false;
		}
		else{
			execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
		} 
	}

	public virtual override void beforeUpdate(CC_TriggerParameters tp) {
		if(!isBeforeUpdateProcessing) {
			isBeforeUpdateProcessing = true;
			for (String handlerClassName : getAssociatedHandlers(objectApiName, 'beforeUpdate')) {
				Type handlerClassType = Type.forName(handlerClassName);
				execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
			}
			isBeforeUpdateProcessing = false;
		}
		else{
			execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
		} 
	}
}