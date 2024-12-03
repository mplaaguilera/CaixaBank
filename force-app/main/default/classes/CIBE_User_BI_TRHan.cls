/**********************************************************************************************************************
 Name:	  CIBE_User_BI_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de User BeforeInsert
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US394910		Alex Campos			27/06/2022			Init version

***********************************************************************************************************************/
public with sharing class CIBE_User_BI_TRHan extends CC_TriggerHandlerBase {
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<User>)tp.newList, (Map<Id, User>)tp.newMap, (List<User>) tp.oldList, (Map<Id, User>) tp.oldMap);
	}
	
	private void process(List<User> listNewObj, Map<Id, User> mapNewObj, List<User> listOldObj, Map<Id, User> mapOldObj) {
        //General check the Record type's for intouch project
		List<User> listData = CIBE_UserTriggerHelper.checkByProfile(listNewObj);
		
		if (listData!=null && !listData.isEmpty()){
			//Lógica de negocio a ejecutar
            AV_UserTriggerHelper.updateFuncion(listData, mapOldObj);
        }
	}
}