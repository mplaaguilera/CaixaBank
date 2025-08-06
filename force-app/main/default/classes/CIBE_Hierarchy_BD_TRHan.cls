/**********************************************************************************************************************
Name:	CIBE_Hierarchy_BD_TRHan
Copyright © 2023  CaixaBank
------------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de CIBE_Hierarchy Before Delete
------------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				  DATE				Description
    1.0			US717285	    Luis Martínez 	          26/10/2023	    Init version
***********************************************************************************************************************/
public with sharing class CIBE_Hierarchy_BD_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        system.debug('ENTRA Trigger DELETE');
        process((List<CIBE_Hierarchy__c>)tp.newList, (Map<Id, CIBE_Hierarchy__c>)tp.newMap,(List<CIBE_Hierarchy__c>) tp.oldList, (Map<Id, CIBE_Hierarchy__c>) tp.oldMap);
    }

    private void process(List<CIBE_Hierarchy__c> listNewObj, Map<Id, CIBE_Hierarchy__c> mapNewObj, List<CIBE_Hierarchy__c> listOldObj, Map<Id, CIBE_Hierarchy__c> mapOldObj) {
        List<CIBE_Hierarchy__c> listData = CIBE_HierachyTriggerHelper.checkGeneralRT(listOldObj);

        if (listData != null && !listData.isEmpty()) {
            CIBE_HierachyTriggerHelper.deleteBusinessUser(listData);
        }
    }
}