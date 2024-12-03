/**********************************************************************************************************************
 Name:  EV_PortalCaixaBankTalks_AI_TRHan
 Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase AI para el trigger de EV_PortalCaixaBankTalks__c
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
  VERSION	USER_STORY		AUTHOR				DATE			Description
  1.0		US854993		Carolina Lopez		10/04/2024		Init version
***********************************************************************************************************************/
public with sharing class EV_PortalCaixaBankTalks_AI_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<EV_PortalCaixaBankTalks__c>)tp.newList, (Map<Id, EV_PortalCaixaBankTalks__c>)tp.newMap, (List<EV_PortalCaixaBankTalks__c>)tp.oldList, (Map<Id, EV_PortalCaixaBankTalks__c>)tp.oldMap);
    }
    private void process(List<EV_PortalCaixaBankTalks__c> listNewObj, Map<Id, EV_PortalCaixaBankTalks__c> mapNewObj, List<EV_PortalCaixaBankTalks__c> listOldObj, Map<Id, EV_PortalCaixaBankTalks__c> mapOldObj) {
        EV_LogDebug.printLogDebug('EV_PortalCaixaBankTalks_AI_TRHan ',String.valueof(listNewObj));
        EV_PortalCaixaBankTalksTriggerHelper.transferDateVisibility(listNewObj);
    }
}