/**********************************************************************************************************************
 Name:	  AV_User_BI_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de User BeforeInsert
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Carolina Alonso		05/05/2020			Init version
	1.1			App FSC			David Rufo			24/08/2020			Add new function for update the user with the number of CAIXA office
	1.2			App FSC			David Rufo			09/06/2021			method to update the funcion field of the user
	1.3			Fix Azure		Sandra Gómez		09/03/2022			add method userAzureId
    1.4         US423397        Patricia Solano     02/11/2022          Added method visibilityUser
***********************************************************************************************************************/
public class AV_User_BI_TRHan extends CC_TriggerHandlerBase {
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<User>)tp.newList, (Map<Id, User>)tp.newMap, (List<User>) tp.oldList, (Map<Id, User>) tp.oldMap);
	}
	
	private void process(List<User> listNewObj, Map<Id, User> mapNewObj, List<User> listOldObj, Map<Id, User> mapOldObj) {
        //General check the Record type's for intouch project
		List<User> listData = AV_UserTriggerHelper.checkByProfile(listNewObj);
		
		if (listData!=null && !listData.isEmpty()){
			//Lógica de negocio a ejecutar
            AV_UserTriggerHelper.updateFuncion(listData, mapOldObj);
			AV_UserTriggerHelper.userAzureId(listData, mapOldObj);
			AV_UserTriggerHelper.visibilityUser(listData, mapOldObj);
        }
	}
}