/**********************************************************************************************************************
 Name:	  CIBE_User_AU_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de User AfterUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Alex Campos		    18/10/2022			Init version
	1.1			US542103		Lucía Muñoz			22/02/2023			Llamada al método userRol
	1.2 		US639303		Bea					21/07/2023			Llamada al método automaticProcessOwner

***********************************************************************************************************************/
public class CIBE_User_AI_TRHan extends CC_TriggerHandlerBase {
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<User>)tp.newList, (Map<Id, User>)tp.newMap, (List<User>) tp.oldList, (Map<Id, User>) tp.oldMap);
	}
	
	private void process(List<User> listNewObj, Map<Id, User> mapNewObj, List<User> listOldObj, Map<Id, User> mapOldObj) {
        //General check the Record type's for intouch project
		List<User> listData = CIBE_UserTriggerHelper.checkByProfile(listNewObj);
		
		if (listData!=null && !listData.isEmpty()){
            // Lógica de negocio a ejecutar
            CIBE_UserTriggerHelper.updateUsuarioAsociado(false, listData, mapOldObj);
			CIBE_UserTriggerHelper.userRol(listData);
			CIBE_UserTriggerHelper.updatePermission(listData, mapOldObj);
			CIBE_UserTriggerHelper.automaticProcessOwner(listData, mapOldObj);
        }
	}
    
}