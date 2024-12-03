/**********************************************************************************************************************
 Name:	  CIBE_Account_BI_TRHan
 Copyright © 2020  CaixaBank
------------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Account BeforeInsert
------------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				  DATE				Description
	1.0			Init version	Jose Maria	   	      16/11/2022	    Init version
    2.0         US425471        Jose Maria            16/11/2022        Add Rating PD calc
***********************************************************************************************************************/

public with sharing class CIBE_Account_BI_TRHan  extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Account>)tp.newList, (Map<Id, Account>)tp.newMap, (List<Account>) tp.oldList, (Map<Id, Account>) tp.oldMap);
    }
    
    private void process(List<Account> listNewObj, Map<Id, Account> mapNewObj, List<Account> listOldObj, Map<Id, Account> mapOldObj) {
        //General check the Record type's for intouch project
        List<Account> listData = CIBE_AccountTriggerHelper.checkGeneralRT(listNewObj);

        if (listData != null && !listData.isEmpty()) {
            AV_AccountTriggerHelper.descriptionLastModifiedDate(listData);
			AV_AccountTriggerHelper.processOwnerEAPGestor(listData, mapOldObj);
			AV_AccountTriggerHelper.accountValueOficinaPrincipalRelacionas(listData);
            CIBE_AccountTriggerHelper.updateRatingPD(listData);
        }
	}
}