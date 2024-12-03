/**********************************************************************************************************************
 Name:	  AV_CampaignMember_TRDisp
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Trigger sobre el objeto CampaignMember
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			App FSC            	Sandra Gómez		30/03/2022			Init version

***********************************************************************************************************************/
public with sharing class AV_CampaignMember_TRDisp extends CC_TriggerDispatcherBase {
	private static Boolean isBeforeDeleteProcessing = false;
	private static String objectApiName = 'CampaignMember';
	
	public virtual override void beforeDelete(CC_TriggerParameters tp) {
		if(!isBeforeDeleteProcessing) {
			isBeforeDeleteProcessing = true;
			for (String handlerClassName : getAssociatedHandlers(objectApiName, 'beforeDelete')) {
				Type handlerClassType = Type.forName(handlerClassName);
				execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterInsert);
			}
			isBeforeDeleteProcessing = false;
		}
		else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
	}
}