/**********************************************************************************************************************
 Name:	  CIBE_Account_BU_TRHan
 Copyright © 2020  CaixaBank
------------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Account BeforeUpdate
------------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				  DATE				Description
	1.0			Init version	Jose Maria	   	      16/11/2022	    Init version
    1.1         US425471        Jose Maria            16/11/2022        Add Rating PD calc
    1.2                         Alex                  23/11/2022        Save TeamMembers
    1.3						    Lucia				  21/05/2024		Add retrieveComercialGroup

***********************************************************************************************************************/
public with sharing class CIBE_Account_BU_TRHan  extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Account>)tp.newList, (Map<Id, Account>)tp.newMap, (List<Account>) tp.oldList, (Map<Id, Account>) tp.oldMap);
    }
    
    private void process(List<Account> listNewObj, Map<Id, Account> mapNewObj, List<Account> listOldObj, Map<Id, Account> mapOldObj) {
        //General check the Record type's for intouch project
        List<Account> listData = CIBE_AccountTriggerHelper.checkGeneralRT(listNewObj);
        List<Account> listData2 = CIBE_AccountTriggerHelper.checkGeneralRTGC(listNewObj);

        if (listData != null && !listData.isEmpty()) {
            AV_AccountTriggerHelper.descriptionLastModifiedDateAndUser(listData, mapOldObj);
			AV_AccountTriggerHelper.processOwnerEAPGestor(listData, mapOldObj);
			AV_AccountTriggerHelper.accountValueOficinaPrincipalRelacionas(listData);
            CIBE_AccountTriggerHelperWS.queryTeamMembers(listData, mapOldObj);
            CIBE_AccountTriggerHelper.updateRatingPD(listData); 
        }

        if(listData2 != null && !listData2.isEmpty()){
            CIBE_AccountTriggerHelper.retrieveComercialGroup(listData2); 
        }

	}
}