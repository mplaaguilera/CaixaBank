public without sharing class CC_Grupo_Colaborador_Contact_AD_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CC_Grupo_Colaborador_Contact__c>)tp.oldList);
	}
    
    private void process(List<CC_Grupo_Colaborador_Contact__c> listOldObj) {
        quitarUsuario(listOldObj);
        
        List<CC_Grupo_Colaborador_Contact__c> listOldObjCops = new List<CC_Grupo_Colaborador_Contact__c>();
        List<Id> idsGrupos = new List<Id>();

        for (CC_Grupo_Colaborador_Contact__c grupoColaboradorContact : listOldObj) {
            idsGrupos.add(grupoColaboradorContact.CC_Grupo_Colaborador__c);
        }

        List<CC_Grupo_Colaborador__c> grupos = [SELECT Id, RecordType.DeveloperName FROM CC_Grupo_Colaborador__c WHERE ID IN :idsGrupos];
        List<Id> idsGruposTrabajo = new List<Id>();
        for (CC_Grupo_Colaborador__c grupo : grupos) {
            if (grupo.RecordType.DeveloperName.startsWith('OS_') || grupo.RecordType.DeveloperName.startsWith('CC_')) {
                idsGruposTrabajo.add(grupo.Id);
            }
        }

        for (CC_Grupo_Colaborador_Contact__c grupoColaboradorContact : listOldObj) {
            if (idsGruposTrabajo.contains(grupoColaboradorContact.CC_Grupo_Colaborador__c)) {
                listOldObjCops.add(grupoColaboradorContact);
            }
        }
        
        if (!listOldObjCops.isEmpty()){
            quitarUsuarioGrupoTrabajo(listOldObjCops);
        }        
	}
    
    @future(callout=true)
    public static void quitarUsuarioFuture(List<Id> idsGroupMember){
        List<GroupMember> member = new List<GroupMember>();
        for(Id idGroupMember : idsGroupMember){
        	member.add(new GroupMember(Id = idGroupMember));	    
        }
    	delete member;    
    }
    
    public static void quitarUsuario(List<CC_Grupo_Colaborador_Contact__c> listOldObj) {
        
        //Guardamos los colaboradores (de tipo usuario) a añadir, por el nombre de la cola
        Map<Id,String> mapColaboradoresGrupos =  new Map<Id,String>();
        Set<Id> colaboradores = new Set<Id>();
        for (CC_Grupo_Colaborador_Contact__c colaborador : listOldObj) {
            colaboradores.add(colaborador.Id);    
            mapColaboradoresGrupos.put(colaborador.CC_Usuario__c,colaborador.CC_Grupo_Colaborador__c);
        }
        Map<Id,String> mapColasQuery =  new Map<Id,String>();
        Map<Id,String> mapGruposQuery =  new Map<Id,String>();

        List<CC_Grupo_Colaborador__c> listaGrupoColaborador = [SELECT Id, CC_Queue_Traslado__c, OS_GrupoTrabajo__c FROM CC_Grupo_Colaborador__c WHERE Id IN :mapColaboradoresGrupos.values()];
        for(CC_Grupo_Colaborador__c grupoColaborador : listaGrupoColaborador)
        {
            mapColasQuery.put(grupoColaborador.Id, grupoColaborador.CC_Queue_Traslado__c);
            mapGruposQuery.put(grupoColaborador.Id, grupoColaborador.OS_GrupoTrabajo__c);
            
        }
        system.debug('VICTOR listaGrupoColaborador ' + listaGrupoColaborador);
        
        //Guardamos todas las queues 
        Map<String,Id> mapColas =  new Map<String,Id>();
        Map<String,Id> mapGruposPublicos =  new Map<String,Id>();
system.debug('VICTOR mapColasQuery.values ' + mapColasQuery.values());
        List<Group> listaColas = [SELECT Id, Name, Type, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN: mapColasQuery.values()];
        for(Group grupo : listaColas)
        {
            mapColas.put(grupo.DeveloperName, grupo.Id);            
        }

        List<Group> listaGrupo = [SELECT Id, Name, Type, DeveloperName FROM Group WHERE Type = 'Regular' AND Name IN: mapGruposQuery.values()];
        for(Group grupo : listaGrupo)
        {            
            mapGruposPublicos.put(grupo.DeveloperName, grupo.Id);
        }

        Map<Id,Id> mapUsuariosColas = new Map<Id,Id>();
        Map<Id,Id> mapUsuariosGruposPublicos = new Map<Id,Id>();
        for(Id usuarioId : mapColaboradoresGrupos.keySet()){
            if(usuarioId !=null)
            {
                Id grupoColaId = mapColaboradoresGrupos.get(usuarioId);
                if(grupoColaId!=null)
                {
                    String colaName = mapColasQuery.get(grupoColaId);
                    if(colaName!=null)
                    {
                        Id colaId = mapColas.get(colaName);
                        if(colaId != null){
                            mapUsuariosColas.put(usuarioId, colaId);    
                        }
                        Id grupoPublicoId = mapGruposPublicos.get(colaName);
                        if(grupoPublicoId != null){
                            mapUsuariosGruposPublicos.put(usuarioId, grupoPublicoId);
                        }
                    }
                }
            }
        }
        
        List<Id> idsGroupMember = new List<Id>();
        for(GroupMember groupMember : [SELECT Id, Group.DeveloperName, UserOrGroupId FROM GroupMember
                                       WHERE (Group.Type = 'Queue'   AND Group.Id IN: mapUsuariosColas.values()          AND UserOrGroupId IN : mapUsuariosColas.keySet()) OR 
                                             (Group.Type = 'Regular' AND Group.Id IN: mapUsuariosGruposPublicos.values() AND UserOrGroupId IN : mapUsuariosGruposPublicos.keySet())])
        {
            if(mapUsuariosColas.containsKey(groupMember.UserOrGroupId) && (mapUsuariosColas.get(groupMember.UserOrGroupId) == groupMember.GroupId)){
                idsGroupMember.add(groupMember.Id);	    
            } else if(mapUsuariosGruposPublicos.containsKey(groupMember.UserOrGroupId) && (mapUsuariosGruposPublicos.get(groupMember.UserOrGroupId) == groupMember.GroupId)) {
                idsGroupMember.add(groupMember.Id);	    
            }
            
        }
        
        //Llamamos a la función future para hacer el delete ya que no se puede hacer sin future
        if(!idsGroupMember.isEmpty())
            quitarUsuarioFuture(idsGroupMember);
    }

    public static void quitarUsuarioGrupoTrabajo(List<CC_Grupo_Colaborador_Contact__c> listOldObjCops) {
        
        //Guardamos los colaboradores (de tipo usuario) a añadir, por el nombre de la cola
        Map<Id,String> mapColaboradoresGrupos =  new Map<Id,String>();
        Set<Id> colaboradores = new Set<Id>();
        for (CC_Grupo_Colaborador_Contact__c colaborador : listOldObjCops) {
            colaboradores.add(colaborador.Id);    
            mapColaboradoresGrupos.put(colaborador.CC_Usuario__c,colaborador.CC_Grupo_Colaborador__c);
        }
        Map<Id,String> mapGruposColas =  new Map<Id,String>();
        for(CC_Grupo_Colaborador__c grupoColaborador : [SELECT Id, OS_GrupoTrabajo__c
                                                        FROM CC_Grupo_Colaborador__c WHERE Id IN :mapColaboradoresGrupos.values()])
        {
            mapGruposColas.put(grupoColaborador.Id, grupoColaborador.OS_GrupoTrabajo__c);
            
        }
        
        //Guardamos todas las queues 
        Map<String,Id> mapColas =  new Map<String,Id>();
        Map<String,Id> mapGruposPublicos =  new Map<String,Id>();
        for(Group grupo : [SELECT Id, Name, Type, DeveloperName FROM Group WHERE Type = 'Regular' AND name IN: mapGruposColas.values()]){
            mapGruposPublicos.put(grupo.name, grupo.Id);
        }
        
        Map<Id,Id> mapUsuariosGruposPublicos = new Map<Id,Id>();
        for(Id usuarioId : mapColaboradoresGrupos.keySet()){
            if (usuarioId != null) {
                Id grupoColaId = mapColaboradoresGrupos.get(usuarioId);
                if (grupoColaId != null) {
                    String colaName = mapGruposColas.get(grupoColaId);
                    if (colaName != null) {
                        Id colaId = mapColas.get(colaName);
                        Id grupoPublicoId = mapGruposPublicos.get(colaName);
                        if(grupoPublicoId != null){
                            mapUsuariosGruposPublicos.put(usuarioId, grupoPublicoId);
                        }
                    }
                }
            }
        }
        
        List<Id> idsGroupMember = new List<Id>();
        for(GroupMember groupMember : [SELECT Id, Group.DeveloperName, UserOrGroupId FROM GroupMember
                                       WHERE Group.Type = 'Regular' AND Group.Id IN: mapUsuariosGruposPublicos.values() AND UserOrGroupId IN : mapUsuariosGruposPublicos.keySet()]) {
            if(mapUsuariosGruposPublicos.containsKey(groupMember.UserOrGroupId) && (mapUsuariosGruposPublicos.get(groupMember.UserOrGroupId) == groupMember.GroupId)) {
                idsGroupMember.add(groupMember.Id);	    
            }
            
        }
        
        //Llamamos a la función future para hacer el delete ya que no se puede hacer sin future
        if(!idsGroupMember.isEmpty())
            quitarUsuarioFuture(idsGroupMember);
        
    }
    
}