/**********************************************************************************************************************
 Name:  EV_PortalCaixaBankTalks_BI_TRHan
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase BI para el trigger de EV_PortalCaixaBankTalks__c
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
  VERSION	USER_STORY		AUTHOR				DATE			Description
  1.0		US633077		Mamen Arias			06/09/2023		Init version
***********************************************************************************************************************/
public with sharing class EV_PortalCaixaBankTalks_BI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<EV_PortalCaixaBankTalks__c>)tp.newList, (Map<Id, EV_PortalCaixaBankTalks__c>)tp.newMap, (List<EV_PortalCaixaBankTalks__c>)tp.oldList, (Map<Id, EV_PortalCaixaBankTalks__c>)tp.oldMap);
    }
    
    private void process(List<EV_PortalCaixaBankTalks__c> listNewObj, Map<Id, EV_PortalCaixaBankTalks__c> mapNewObj, List<EV_PortalCaixaBankTalks__c> listOldObj, Map<Id, EV_PortalCaixaBankTalks__c> mapOldObj) {
        EV_PortalCaixaBankTalksTriggerHelper.checkExist(listNewObj);  
    }
}