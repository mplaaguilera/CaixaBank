/**********************************************************************************************************************
 Name:	  CIBE_BookMember_AI_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: After Insert sobre el objeto Cartera-Cliente
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				  Description
	1.0			  US392789        Jose Maria		14/10/2022	  Init version

***********************************************************************************************************************/
public with sharing class CIBE_BookMember_AI_TRHan extends CC_TriggerHandlerBase{
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<AV_BookMember__c>)tp.newList, (Map<Id, AV_BookMember__c>)tp.newMap, (List<AV_BookMember__c>) tp.oldList, (Map<Id, AV_BookMember__c>) tp.oldMap);
    }
    
    private void process(List<AV_BookMember__c> listNewObj, Map<Id, AV_BookMember__c> mapNewObj, List<AV_BookMember__c> listOldObj, Map<Id, AV_BookMember__c> mapOldObj) {
        List<AV_BookMember__c> listDataNew = CIBE_BookMemberTriggerHelper.checkGeneralRT(listNewObj);

        if (listDataNew!=null && !listDataNew.isEmpty()){
            CIBE_BookMemberTriggerHelper.setBookCenter(listDataNew);
            CIBE_BookMemberTriggerHelper.insertBookMember(listDataNew); 
        }
    }
}