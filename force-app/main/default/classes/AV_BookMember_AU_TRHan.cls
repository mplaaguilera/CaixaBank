/**********************************************************************************************************************
 Name:	  AV_BookMember_AU_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: After Update sobre el objeto Cartera-Cliente
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US168560            Eric Vázquez		12/02/2021			Init version
    1.1         PPM100265161        Sandra Gómez		03/10/2024          Add permissionBook
***********************************************************************************************************************/
public with sharing class AV_BookMember_AU_TRHan extends CC_TriggerHandlerBase{
    
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<AV_BookMember__c>)tp.newList, (Map<Id, AV_BookMember__c>)tp.newMap, (List<AV_BookMember__c>) tp.oldList, (Map<Id, AV_BookMember__c>) tp.oldMap);
    }
    
    private void process(List<AV_BookMember__c> listNewObj, Map<Id, AV_BookMember__c> mapNewObj, List<AV_BookMember__c> listOldObj, Map<Id, AV_BookMember__c> mapOldObj) {
        //General check the Record type's for intouch project
		List<AV_BookMember__c> listData = AV_BookMemberTriggerHelper.checkGeneralRT(listNewObj);
        Boolean permissionBook = FeatureManagement.checkPermission('AV_InvalidBookTrigger');
        if (listData!=null && !listData.isEmpty()){
            if (!permissionBook) {
                AV_BookMemberTriggerHelper.updateOwnerIdFromClient(listNewObj);
            }
        }
    }
}