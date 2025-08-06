/*********************************************************************************************************
 * Name: SPV_UserAITRHan
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Trigger Handler para controlar el After Insert del objeto User
 *              Esta clase se testea con 
 * 
 * Historial
 * -------
 * VERSION        USER_STORY            AUTHOR               DATE             Description
 * 1.0             US828257           Raúl Santos          29/04/24             Creación
**********************************************************************************************************/

public with sharing class SPV_UserAITRHan extends CC_TriggerHandlerBase{
    
    private final static String SPV_PERFIL = 'SPV_General';
	private static Set<String> listProfiles = new Set<String>{SPV_PERFIL};

    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<User>)tp.newList, (Map<Id, User>)tp.newMap);
    }

    private void process(List<User> listNewObj, Map<Id, User> mapNewObj) {

        List<User> listUsuarios = new List<User>();

        for(User user : listNewObj){
			if (listProfiles.contains(user.AV_ProfileName__c)) {
				listUsuarios.add(user);    
			}
		}

        if(!listUsuarios.isEmpty()){
            SPV_UserHelper.asignarPermissionSetBasicos(listUsuarios, 'agregar');
        }
    }
}