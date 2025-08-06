public class CC_Grupo_Colaborador_Anadir {
    
    public class GrupoWrapper {
        public String grupoDeveloperName {get;set;}
        public String grupoName {get;set;}
    }
    
    @InvocableMethod(label='Crear queue' description='Crear queue asociada al grupo')
    public static void crearQueue(List<Id> grupos) {
        //Llamada a la función future, se debe hacer así ya que no se permite hacer un insert a un objeto del Setup (Group) si la acción incial es un custom.
        
        crearQueueFuture(grupos);
    }
    
    @future(callout=true)
    public static void crearQueueFuture(List<Id> grupos) {
        
        if (!grupos.isEmpty())
        {
            //Nos guardamos en un mapa el DeveloperName y Name del grupo creado
            Map<Id,GrupoWrapper> mapGruposNombre =  new Map<Id,GrupoWrapper>();
            List<Group> groupList = new List<Group>();
            List<CC_Grupo_Colaborador__c> grupoColaboradorList = new List<CC_Grupo_Colaborador__c>();
            Set<String> gruposDeveloperNameSet = new Set<String>();
            for(CC_Grupo_Colaborador__c grupo : [SELECT Id, Name, CC_Queue_Traslado__c FROM CC_Grupo_Colaborador__c WHERE Id IN :grupos]){
                String grupoDeveloperName = grupo.Name.replaceAll(' ', '_');
                grupoDeveloperName = 'CC_'+ grupoDeveloperName;
                //mapGruposNombre.put(grupoDeveloperName,grupo.Name);
                GrupoWrapper grupoWrapp = new GrupoWrapper();
                grupoWrapp.grupoName = grupo.Name;
                grupoWrapp.grupoDeveloperName = grupoDeveloperName;
                
                mapGruposNombre.put(grupo.Id, grupoWrapp);
                gruposDeveloperNameSet.add(grupoDeveloperName);
            }
            
            //Guardamos todas las queues y public groups que existan para que la query sera más eficiente
            Set<String> colasDeveloperNameSet = new Set<String>();
            Set<String> gruposPublicosDeveloperNameSet = new Set<String>();
            for(Group cola : [SELECT Type, DeveloperName FROM Group WHERE (Type = 'Queue' OR Type = 'Regular') AND DeveloperName IN : gruposDeveloperNameSet]){
                if (cola.Type == 'Queue') {
                    colasDeveloperNameSet.add(cola.DeveloperName);
                } else {
                    gruposPublicosDeveloperNameSet.add(cola.DeveloperName);
                }
            }

            
            //Solo insertamos las queues y public groups que no existan
            for(Id grupoId : mapGruposNombre.KeySet()){
                GrupoWrapper grupo = mapGruposNombre.get(grupoId);
                if(grupo != null){
                    if(!colasDeveloperNameSet.contains(grupo.grupoDeveloperName)){
                        groupList.add(new Group(Type = 'Queue', DeveloperName = grupo.grupoDeveloperName, Name = grupo.grupoName));
                    }
                    if(!gruposPublicosDeveloperNameSet.contains(grupo.grupoDeveloperName)){
                        groupList.add(new Group(Type = 'Regular', DeveloperName = grupo.grupoDeveloperName, Name = grupo.grupoName));
                    }
                    grupoColaboradorList.add(new CC_Grupo_Colaborador__c(Id = grupoId,CC_Queue_Traslado__c = grupo.grupoDeveloperName));
                }
            }

            //Insertamos la queue nueva
            if(!groupList.isEmpty()){
                insert groupList;
            }
            
            //Insertamos la queue nueva
            if(!grupoColaboradorList.isEmpty()){
                update grupoColaboradorList;
            }
            
            
        }
    }
}