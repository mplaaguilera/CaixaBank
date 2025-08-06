/**********************************************************************************************************************
 Name:	  AV_User_BU_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de User BeforeUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Carolina Alonso		05/05/2020			Init version
	1.1			App FSC			David Rufo			24/08/2020			Add new function for update the user with the number of CAIXA office
	1.2			App FSC			David Rufo			09/06/2021			method to update the funcion field of the user
	1.3			Fix Azure		Sandra Gómez		09/03/2022			Add method userAzureId
    1.4         US423397        Patricia Solano     02/11/2022          Add method visibilityUser
	1.5         US448874        Patricia Solano     20/12/2022          Add method prepareDeleteInactiveUser to remove permissions granted when users become inactive
	1.6         IN1160717       Manuel Ramos		02/07/2024          Replace prepareDeleteInactiveUser to be called from WithoutSharing class
	1.7			FIX20091243		Sandra Gómez		25/09/2024			Add method groupConfidenProfileRol
***********************************************************************************************************************/
public class AV_User_BU_TRHan extends CC_TriggerHandlerBase {
	
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
			AV_UserHandlerWithoutSharingMethods.prepareDeleteInactiveUser(listData, mapOldObj);
        }
		AV_UserTriggerHelper.groupConfidenProfileRol(listNewObj, mapOldObj);
	}
}