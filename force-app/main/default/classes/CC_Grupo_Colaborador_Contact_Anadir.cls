public class CC_Grupo_Colaborador_Contact_Anadir {
	
    @InvocableMethod(label='Añadir usuario a la queue' description='Añadir usuario queue a la queue')
    public static void anadirUsuario(List<Id> usuarios) {
        //Llamada a la función future, se debe hacer así ya que no se permite hacer un insert a un objeto del Setup (GroupMember) si la acción incial es un custom.
        
        anadirUsuarioFuture(usuarios);
        
    }
    @future(callout=true)
    public static void anadirUsuarioFuture(List<Id> usuarios) {
        
        if (!usuarios.isEmpty())
        {
            //Guardamos los colaboradores (de tipo usuario) a añadir, por el nombre de la cola
            Map<Id,String> mapColaboradoresColas =  new Map<Id,String>();

            List <CC_Grupo_Colaborador_Contact__c> listaUsuarios = [SELECT Id, CC_Usuario__c, CC_Grupo_Colaborador__r.CC_Queue_Traslado__c
                                                                    FROM CC_Grupo_Colaborador_Contact__c WHERE Id IN :usuarios];
            for(CC_Grupo_Colaborador_Contact__c colaborador : listaUsuarios){
                mapColaboradoresColas.put(colaborador.CC_Usuario__c,colaborador.CC_Grupo_Colaborador__r.CC_Queue_Traslado__c);
            }
            
            //Guardamos todas las queues y public groups
            Map<String,Id> mapColas =  new Map<String,Id>();
            Map<String,Id> mapGruposPublicos =  new Map<String,Id>();
            for(Group grupo : [SELECT Id, Name, DeveloperName, Type FROM Group WHERE (Type = 'Queue' OR Type = 'Regular') AND DeveloperName IN: mapColaboradoresColas.values()]){
                if (grupo.Type == 'Queue') {
                    mapColas.put(grupo.DeveloperName, grupo.Id);                
                } else {
                    mapGruposPublicos.put(grupo.DeveloperName, grupo.Id);                
                }
            }
            
            Set<String> setColas = new Set<String>();
            Set<String> setGruposPublicos = new Set<String>();
            for(GroupMember groupMember : [SELECT Id, Group.DeveloperName, UserOrGroupId, Group.Type
                                           FROM GroupMember WHERE (Group.Type = 'Queue' OR Group.Type = 'Regular') AND Group.DeveloperName IN: mapColaboradoresColas.values()
                                           AND UserOrGroupId IN : mapColaboradoresColas.keySet()])
            {  
                if (groupMember.Group.Type == 'Queue') {
                    setColas.add(groupMember.UserOrGroupId+'-'+groupMember.Group.DeveloperName);
                } else {
                    setGruposPublicos.add(groupMember.UserOrGroupId+'-'+groupMember.Group.DeveloperName);
                }
            }   
            
            List<GroupMember> membersList = new List<GroupMember>();
            for(CC_Grupo_Colaborador_Contact__c colaborador : listaUsuarios)
            {
                if(mapColas.containsKey(colaborador.CC_Grupo_Colaborador__r.CC_Queue_Traslado__c) && !setColas.contains(colaborador.CC_Usuario__c+'-'+colaborador.CC_Grupo_Colaborador__r.CC_Queue_Traslado__c)){
                    membersList.add(new GroupMember(GroupId = mapColas.get(colaborador.CC_Grupo_Colaborador__r.CC_Queue_Traslado__c ),
                                                    UserOrGroupId = colaborador.CC_Usuario__c));    
                }
                if(mapGruposPublicos.containsKey(colaborador.CC_Grupo_Colaborador__r.CC_Queue_Traslado__c) && !setGruposPublicos.contains(colaborador.CC_Usuario__c+'-'+colaborador.CC_Grupo_Colaborador__r.CC_Queue_Traslado__c)){
                    membersList.add(new GroupMember(GroupId = mapGruposPublicos.get(colaborador.CC_Grupo_Colaborador__r.CC_Queue_Traslado__c),
                                                    UserOrGroupId = colaborador.CC_Usuario__c));    
                }
            }
            
            //Añadimos los usuarios a la cola correspondiente
            if(!membersList.isEmpty())
                insert membersList;
          
        } 
    }
    
}