/**********************************************************************************************************************
 Name:	  AV_BookManagementMember_AU_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: After Update sobre el objeto Cartera-Gestor
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			Init version        Sandra Gómez		14/10/2021			Init version

***********************************************************************************************************************/
public with sharing class AV_BookManagementMember_AU_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<AV_BookManagementMember__c>)tp.newList, (Map<Id, AV_BookManagementMember__c>)tp.newMap, (List<AV_BookManagementMember__c>) tp.oldList, (Map<Id, AV_BookManagementMember__c>) tp.oldMap);
    }
    
    private void process(List<AV_BookManagementMember__c> listNewObj, Map<Id, AV_BookManagementMember__c> mapNewObj, List<AV_BookManagementMember__c> listOldObj, Map<Id, AV_BookManagementMember__c> mapOldObj) {
        //General check the Record type's for intouch project
		List<AV_BookManagementMember__c> listData = AV_BookManagementMemberTriggerHelper.checkGeneralRT(listNewObj);
        
        if (listData!=null && !listData.isEmpty()){
        	AV_BookManagementMemberTriggerHelper.updateOwnerIdFromClient(listNewObj);
        }
    }
}