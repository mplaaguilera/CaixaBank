/**********************************************************************************************************************
 Name:	CIBE_AccConRel_AI_TRHan
 Copyright © 2023  CaixaBank
------------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de AccountContactRelation After Insert
------------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				  DATE				Description
	1.0			US493757	    Alex Pérez	   	      27/03/2023	    Init version
***********************************************************************************************************************/
public with sharing class CIBE_AccConRel_AI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
    	process((List<AccountContactRelation>)tp.newList, (Map<Id, AccountContactRelation>)tp.newMap);
  	}
  
  	private void process(List<AccountContactRelation> listNewObj, Map<Id, AccountContactRelation> mapNewObj) {
        CIBE_AccConRelTriggerHelper.teamMemberManager(listNewObj, null);
    }

}