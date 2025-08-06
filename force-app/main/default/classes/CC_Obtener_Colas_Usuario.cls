public with sharing class CC_Obtener_Colas_Usuario {
    /*
        Clase para identificación de colas de agentes (incocable desde PB después de cambio de estado de agente)
        Informa a nivel de usuario las colas asignadas, para poder realizar reporting online 
    */
    
    @InvocableMethod(label='Informar Colas de usuario' description='Informa Colas de usuario en su perfil')
    public static void informarcolas(List<ID> listNewObj) {
        Set<Id> setIds = new Set<Id>();
        Map<Id, List<GroupMember>> mapIdUserGrupo = new Map<Id, List<GroupMember>>();
        
        List<User> agentes = [SELECT Id, CC_Colas__c from User where id IN : listNewObj and UserRole.DeveloperName IN ('Contact_Center','Contact_Center_sin_acceso_a_Directorio','HDT')];
        
        for (User usr : agentes) {
            setIds.add(usr.id);
        }
        
        if(!setIds.isEmpty()){
            List<GroupMember> lstGruposUsuarios = [SELECT Id, Group.name, UserorGroupId FROM GroupMember where Group.Type='Queue' and UserorGroupId IN:setIds and (NOT(Group.DeveloperName like '%stopGo')) ];
            
            for (GroupMember grupoUsuario : lstGruposUsuarios) {
                if (mapIdUserGrupo.containsKey(grupoUsuario.UserorGroupId)) {
                    List<GroupMember> listGroups = mapIdUserGrupo.get(grupoUsuario.UserorGroupId);
                    listGroups.add(grupoUsuario);
                    mapIdUserGrupo.put(grupoUsuario.UserorGroupId, listGroups);
                } else {
                    List<GroupMember> listGroups = new List<GroupMember>();
                    listGroups.add(grupoUsuario);
                    mapIdUserGrupo.put(grupoUsuario.UserorGroupId, listGroups);
                }
            }
            
            for (User usr : agentes) {
                string colas ='';
                if(mapIdUserGrupo.containsKey(usr.Id)){
                    for (GroupMember cola: mapIdUserGrupo.get(usr.Id)){
                        colas += cola.group.name + ',' ;                
                    }
                }
                usr.CC_Colas__c = colas;
            }
            
            update agentes;            
        }        
    }
}