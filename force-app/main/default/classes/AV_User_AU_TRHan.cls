/**********************************************************************************************************************
 Name:	  AV_User_AU_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de User AfterUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Carolina Alonso		05/05/2020			Init version
	1.1			App FSC			David Rufo			21/07/2020			Fix problem with new users
	1.2			App FSC			David Rufo			24/08/2020			Add new function for update the user with the number of CAIXA office
	1.3			US170549		Sandra Gómez		09/02/2021			Add permissionUser
	1.4			Fix				Sandra Gómez		23/12/2021			Add userExternalId

***********************************************************************************************************************/
public class AV_User_AU_TRHan extends CC_TriggerHandlerBase {
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<User>)tp.newList, (Map<Id, User>)tp.newMap, (List<User>) tp.oldList, (Map<Id, User>) tp.oldMap);
	}
	
	private void process(List<User> listNewObj, Map<Id, User> mapNewObj, List<User> listOldObj, Map<Id, User> mapOldObj) {
		//General check the Record type's for intouch project
		List<User> listData = AV_UserTriggerHelper.checkByProfile(listNewObj);
		
		if (listData!=null && !listData.isEmpty()){
            // Lógica de negocio a ejecutar
            AV_UserTriggerHelper.updateUsuarioAsociado(false, listData, mapOldObj);
            AV_UserTriggerHelper.permissionUser(listData);
            AV_UserTriggerHelper.automiticProcessOwner(listData,mapOldObj);
			AV_UserTriggerHelper.reassignmentInactiveUser(listData,mapOldObj);
			AV_UserTriggerHelper.userExternalId(listData,mapOldObj);
        }
	}

}