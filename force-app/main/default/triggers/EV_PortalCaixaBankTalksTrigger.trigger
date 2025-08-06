/**********************************************************************************************************************
 Name:    EV_PortalCaixaBankTalksTrigger
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Trigger para el objeto EV_PortalCaixaBankTalks__c
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
  VERSION	USER_STORY		AUTHOR				DATE			Description
  1.0		US633077		Mamen Arias			06/09/2023		Init version
***********************************************************************************************************************/
trigger EV_PortalCaixaBankTalksTrigger on EV_PortalCaixaBankTalks__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	CC_TriggerFactory.createTriggerDispatcher(EV_PortalCaixaBankTalks__c.sObjectType);
}