public with sharing class CC_User_AI_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<User>)tp.newList, (Map<Id, User>)tp.newMap, (List<User>)tp.oldList, (Map<Id, User>)tp.oldMap);
	}

    private void process(List<User> listNewObj, Map<Id, User> mapNewObj, List<User> listOldObj, Map<Id, User> mapOldObj) {
        

        List<UserRole> rolesCC = [SELECT Id FROM UserRole WHERE DeveloperName IN ('Contact_Center', 'Contact_Center_sin_acceso_a_Directorio') LIMIT 2 ];

        List<User> lstUsersCC = new List<User>();
        for(User usuario : listNewObj){
            if(usuario.UserRoleId == rolesCC[0].Id || usuario.UserRoleId == rolesCC[1].Id ){
                lstUsersCC.add(usuario);
            }
        }

        if(!lstUsersCC.isEmpty()) {
            CC_UserTriggerHelper.nuevoUsuarioAI(listNewObj);
            CC_UserTriggerHelper.usuarioActivoAI(listNewObj);
        }
    }
}