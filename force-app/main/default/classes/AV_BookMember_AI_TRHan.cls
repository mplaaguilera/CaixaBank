/**********************************************************************************************************************
 Name:	  AV_BookMemberTriggerHelper
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: After Insert sobre el objeto Cartera-Cliente
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US168560            Eric Vázquez		12/02/2021			Init version

***********************************************************************************************************************/
public with sharing class AV_BookMember_AI_TRHan extends CC_TriggerHandlerBase{
    
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<AV_BookMember__c>)tp.newList, (Map<Id, AV_BookMember__c>)tp.newMap, (List<AV_BookMember__c>) tp.oldList, (Map<Id, AV_BookMember__c>) tp.oldMap);
    }
    
    private void process(List<AV_BookMember__c> listNewObj, Map<Id, AV_BookMember__c> mapNewObj, List<AV_BookMember__c> listOldObj, Map<Id, AV_BookMember__c> mapOldObj) {
        //General check the Record type's for intouch project
		List<AV_BookMember__c> listData = AV_BookMemberTriggerHelper.checkGeneralRT(listNewObj);
        
        if (listData!=null && !listData.isEmpty()){
        	AV_BookMemberTriggerHelper.updateOwnerIdFromClient(listNewObj);
        }
    }
}