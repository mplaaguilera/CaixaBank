/**********************************************************************************************************************
 Name:	  CIBE_BookManagementMember_AU_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: After Update sobre el objeto Cartera-Gestor
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				  Description
	1.0			  US392789        Jose Maria		14/10/2022	  Init version

***********************************************************************************************************************/
public with sharing class CIBE_BookManagementMember_AU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<AV_BookManagementMember__c>)tp.newList, (Map<Id, AV_BookManagementMember__c>)tp.newMap, (List<AV_BookManagementMember__c>) tp.oldList, (Map<Id, AV_BookManagementMember__c>) tp.oldMap);
    }
    
    private void process(List<AV_BookManagementMember__c> listNewObj, Map<Id, AV_BookManagementMember__c> mapNewObj, List<AV_BookManagementMember__c> listOldObj, Map<Id, AV_BookManagementMember__c> mapOldObj) {
        List<AV_BookManagementMember__c> listData = CIBE_BookManagementMemberTriggerHelper.checkGeneralRT(listNewObj);

        if (listData != null && !listData.isEmpty()) {
            CIBE_BookManagementMemberTriggerHelper.updateOwnerIdFromClient(listNewObj);
        }
    }
}