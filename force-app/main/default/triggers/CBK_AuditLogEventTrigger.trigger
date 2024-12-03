/**********************************************************************************************************************
 Name:	  CBK_AuditLogEventTrigger
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Trigger de objeto CBK_AuditLogEvent__e
            Al tratarse de un evento de plataforma, solo se ejecuta trigger en el evento "after insert"
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	21/04/2021			Init version
***********************************************************************************************************************/
trigger CBK_AuditLogEventTrigger on CBK_AuditLogEvent__e (after insert) {
    CC_TriggerFactory.createTriggerDispatcher(CBK_AuditLogEvent__e.sObjectType);
}