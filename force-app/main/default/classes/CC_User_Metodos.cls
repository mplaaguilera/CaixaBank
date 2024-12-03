public class CC_User_Metodos {
    
	@InvocableMethod(label='CC_User_Metodos' description='')
    public static void usuariosGruposPublicos (List<Id> usuarios)
    {
    	if (!usuarios.isEmpty())
        {
            Set<String> perfiles = new Set<String>();
            
            for(PermissionSetAssignment permission : [SELECT Id, PermissionSet.Name, Assignee.Id  FROM PermissionSetAssignment WHERE Assignee.Id IN :usuarios]){
                perfiles.add(permission.PermissionSet.Name);
            }
            for(User usuario : [SELECT Profile.Name FROM User WHERE Id IN :usuarios]){
                perfiles.add(usuario.Profile.Name);
            }
            
            Map<String,Id> mapGrupos =  new Map<String,Id>();
            for(Group grupo : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Regular']){
                mapGrupos.put(grupo.DeveloperName, grupo.Id);                
            }
            
            Map<String,String> mapMdtGrupos =  new Map<String,String>();
            for(CC_Grupos_Publicos__mdt grupoMdt : [SELECT CC_Grupo__c, CC_Perfil__c FROM CC_Grupos_Publicos__mdt WHERE CC_Perfil__c IN :perfiles]){
                if(mapGrupos.containsKey(grupoMdt.CC_Grupo__c)){
                    mapMdtGrupos.put(grupoMdt.CC_Perfil__c, mapGrupos.get(grupoMdt.CC_Grupo__c));
                    
                }                
            }
            List<GroupMember> membersList = new List<GroupMember>();
            for(PermissionSetAssignment permission : [SELECT Id, PermissionSet.Name, Assignee.Id  FROM PermissionSetAssignment WHERE Assignee.Id IN :usuarios]){
                if(mapMdtGrupos.containsKey(permission.PermissionSet.Name)){
                    membersList.add(new GroupMember(GroupId = mapMdtGrupos.get(permission.PermissionSet.Name),
                                                    UserOrGroupId = permission.Assignee.Id));
                    }
            }
            for(User usuario : [SELECT Id, Profile.Name FROM User WHERE Id IN :usuarios]){
                if(mapMdtGrupos.containsKey(usuario.Profile.Name))
                    membersList.add(new GroupMember(GroupId = mapMdtGrupos.get(usuario.Profile.Name),
                                                    UserOrGroupId = usuario.Id));
            }
           
            //Buscar los grupos
            if(!membersList.isEmpty())
                insert membersList;            
        }        
    }
}