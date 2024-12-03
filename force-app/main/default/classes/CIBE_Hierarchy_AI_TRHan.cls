/**********************************************************************************************************************
Name:	CIBE_Hierarchy_AI_TRHan
Copyright © 2023  CaixaBank
------------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de CIBE_Hierarchy After Insert
------------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				  DATE				Description
    1.0			US717285	    Luis Martínez 	          26/10/2023	    Init version
***********************************************************************************************************************/
public with sharing class CIBE_Hierarchy_AI_TRHan extends CC_TriggerHandlerBase {
        public override void mainEntry(CC_TriggerParameters tp) {
            process((List<CIBE_Hierarchy__c>)tp.newList, (Map<Id, CIBE_Hierarchy__c>)tp.newMap);
        }
        private void process(List<CIBE_Hierarchy__c> listNewObj, Map<Id, CIBE_Hierarchy__c> mapNewObj) {
            List<CIBE_Hierarchy__c> listData = CIBE_HierachyTriggerHelper.checkGeneralRT(listNewObj);
            if (listData != null && !listData.isEmpty()) {
                CIBE_HierachyTriggerHelper.insertBusinessUser(listData);
            }
        }
}