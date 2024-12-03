//Proposito: Clase para Trigger de Account AfterInsert

public with sharing class AV_Account_AI_TRHan extends CC_TriggerHandlerBase {
   
   
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Account>)tp.newList, (Map<Id, Account>)tp.newMap, (List<Account>) tp.oldList, (Map<Id, Account>) tp.oldMap);
    }
    
    private void process(List<Account> listNewObj, Map<Id, Account> mapNewObj, List<Account> listOldObj, Map<Id, Account> mapOldObj) {
        //General check the Record type's for intouch project
        List<Account> listData = AV_AccountTriggerHelper.checkGeneralRT(listNewObj);

        if (listData != null && !listData.isEmpty()){
            //llamo a mi método del triggerHelper
            AV_AccountTriggerHelper.relatedAccountAndLead(listData);
        }
			  //AV_AccountTriggerHelper.updateOppConfidentiality(listData, mapOldObj);
	}

}