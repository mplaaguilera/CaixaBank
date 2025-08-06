public without sharing class CC_Grupo_Colaborador_Contact_AI_TRHan extends CC_TriggerHandlerBase {

    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Grupo_Colaborador_Contact__c>)tp.newList, (Map<Id, CC_Grupo_Colaborador_Contact__c>)tp.newMap, (List<CC_Grupo_Colaborador_Contact__c>)tp.oldList, (Map<Id, CC_Grupo_Colaborador_Contact__c>)tp.oldMap);
    }
    
    private void process(List<CC_Grupo_Colaborador_Contact__c> listNewObj, Map<Id, CC_Grupo_Colaborador_Contact__c> mapNewObj, List<CC_Grupo_Colaborador_Contact__c> listOldObj, Map<Id, CC_Grupo_Colaborador_Contact__c> mapOldObj) {        
        Set<Id> idsGrupoColaboradorContact = new Set<Id>();
        for (CC_Grupo_Colaborador_Contact__c grupos : listNewObj) {
            idsGrupoColaboradorContact.add(grupos.Id);
        }
		if (!System.isFuture() && !System.isBatch()){
        	crearQueue(idsGrupoColaboradorContact);
        }

        updateGrupoColaboradorContact(idsGrupoColaboradorContact);
    }

    @future(callout=true)
    public static void crearQueue(Set<Id> idsGrupoColaboradorContact) {

        
        List<CC_Grupo_Colaborador_Contact__c> listNewObjCops = new List<CC_Grupo_Colaborador_Contact__c>();
        
        List<CC_Grupo_Colaborador_Contact__c> listNewObj = [SELECT Id, CC_Grupo_Colaborador__c, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c WHERE Id IN :idsGrupoColaboradorContact];
        List<Id> idsGrupos = new List<Id>();
        
        for (CC_Grupo_Colaborador_Contact__c grupoColaboradorContact : listNewObj) {
            idsGrupos.add(grupoColaboradorContact.CC_Grupo_Colaborador__c);
        }
        
        List<CC_Grupo_Colaborador__c> grupos = [SELECT Id, RecordType.DeveloperName FROM CC_Grupo_Colaborador__c WHERE ID IN :idsGrupos];
        List<Id> idsGruposTrabajo = new List<Id>();
        for (CC_Grupo_Colaborador__c grupo : grupos) {
            if (grupo.RecordType.DeveloperName.startsWith('OS_') ||grupo.RecordType.DeveloperName.startsWith('CC_')) {
                idsGruposTrabajo.add(grupo.Id);
            }
        }
        
        for (CC_Grupo_Colaborador_Contact__c grupoColaboradorContact : listNewObj) {
            if (idsGruposTrabajo.contains(grupoColaboradorContact.CC_Grupo_Colaborador__c)) {
                listNewObjCops.add(grupoColaboradorContact);
            }
        }
        
        if (!listNewObjCops.isEmpty()){
            
            //Guardamos los colaboradores (de tipo usuario) a añadir, por el nombre del public group
            Map<Id,Id> mapColaboradoresGrupos =  new Map<Id,Id>();
            
            for (CC_Grupo_Colaborador_Contact__c colaborador : listNewObjCops) {   
                mapColaboradoresGrupos.put(colaborador.CC_Grupo_Colaborador__c, colaborador.CC_Usuario__c);
            }
            
            Set<String> grupoTrabajo = new Set<String>();
            Map<String,Id> mapGruposColas =  new Map<String,Id>();
            
            List<CC_Grupo_Colaborador__c> gruposColaboradores = [SELECT Id, OS_GrupoTrabajo__c FROM CC_Grupo_Colaborador__c WHERE Id IN :mapColaboradoresGrupos.keySet()];
            
            if(!gruposColaboradores.isEmpty()){
                for(CC_Grupo_Colaborador__c grupoColaborador : gruposColaboradores){
                    grupoTrabajo.add(grupoColaborador.OS_GrupoTrabajo__c);
                    mapGruposColas.put(grupoColaborador.OS_GrupoTrabajo__c, grupoColaborador.Id);                    
                }
                
                List<GroupMember> newGroupMembers = new List<GroupMember>();
                
                List<Group> gruposPublicos = [SELECT Id, Name, Type, DeveloperName FROM Group WHERE Type = 'regular' AND name IN :grupoTrabajo];
                
                if (!gruposPublicos.isEmpty()){
                    
                    for(Group grupo : gruposPublicos){
                        GroupMember member = new GroupMember();
                        member.UserOrGroupId = mapColaboradoresGrupos.get(mapGruposColas.get(grupo.name));
                        member.GroupId = grupo.Id;
                        newGroupMembers.add(member);                       
                    }
                    
                    if(!newGroupMembers.isEmpty()) {
                        insert newGroupMembers;    
                    }
                }
                
            }
        }
    }    

    public static void updateGrupoColaboradorContact(Set<Id> idsGrupoColaboradorContact){

        List<CC_Grupo_Colaborador_Contact__c> contactos = [
            SELECT Id,
                   CC_Usuario__c,
                   CC_Grupo_Colaborador__r.OS_Negocio__c,
                   CC_Grupo_Colaborador__r.RecordType.DeveloperName
            FROM CC_Grupo_Colaborador_Contact__c
            WHERE Id IN :idsGrupoColaboradorContact
        ];

        //List of user to add to the queue
        List<Id> usersId = new List<Id>();

        for (CC_Grupo_Colaborador_Contact__c contact : contactos) {
            Boolean meetConditions = 
                contact.CC_Usuario__c != null &&
                contact.CC_Grupo_Colaborador__r != null &&
                contact.CC_Grupo_Colaborador__r.OS_Negocio__c == 'CC' &&
                contact.CC_Grupo_Colaborador__r.RecordType.DeveloperName != null &&
                contact.CC_Grupo_Colaborador__r.RecordType.DeveloperName.contains('CC_');

            if (meetConditions) {
                usersId.add(contact.id);
            } 
           
        }

        if(!usersId.isEmpty()){

            CC_Grupo_Colaborador_Contact_Anadir.anadirUsuario(usersId);

        }
           
  }

}