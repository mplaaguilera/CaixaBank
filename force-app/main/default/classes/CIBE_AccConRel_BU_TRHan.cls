/**********************************************************************************************************************
 Name:	CIBE_AccConRel_BU_TRHan
 Copyright © 2024  CaixaBank
------------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de AccountContactRelation Before Update
------------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				  DATE				Description
	1.0			US493757	    Borja Lavesiera	   	  18/01/2024	    Init version
***********************************************************************************************************************/
public with sharing class CIBE_AccConRel_BU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
    	process((List<AccountContactRelation>)tp.newList, (Map<Id, AccountContactRelation>)tp.newMap, (List<AccountContactRelation>) tp.oldList, (Map<Id, AccountContactRelation>) tp.oldMap);
  	}
  
  	private void process(List<AccountContactRelation> listNewObj, Map<Id, AccountContactRelation> mapNewObj, List<AccountContactRelation> listOldObj, Map<Id, AccountContactRelation> mapOldObj) {
        CIBE_AccConRelExtTriggerHelper.setExternalSourceId(listNewObj, mapOldObj);
    }
}