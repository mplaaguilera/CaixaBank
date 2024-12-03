/**************************************************************************************************
 * Name:  SAC_ActualizacionUsuario
 * Copyright © 2019  
 * CaixaBank 
 * 
 * Proposito:         
 *          Guardar en el campo SAC_GruposPerteneciente__c del Objeto User
 *          los Ids de los grupos a los que pertenece este Usuario   
 * 
 * Historial
 * VERSION        USER_STORY            AUTHOR                DATE                   Description
 * 1.0             US206848          Marcela Neira         15/04/2021                Creación
 * 1.1             US383184          Marcela Neira         22/06/2022                Añadir método 
 * ************************************************************************************************/
public without sharing class SAC_ActualizacionUsuario {

    private static Set<String> objetos = new Set<String>{'CC_Grupo_Colaborador__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEPROVEEDORES = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_GrupoProveedores').getRecordTypeId();
    private static final Id RECTYPETAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_GrupoResponsableAccion').getRecordTypeId(); 
    private static final Id RECTYPELETRADOS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_Letrados').getRecordTypeId();       

    /************************************************************************************************************
     * Proposito:  Este método recibe dos listas, la nueva y la vieja para recoger todos los Id de los Usuarios 
     * que tienen o no un Grupo Colaborador y rellena el campo SAC_GruposPerteneciente__c del Objeto User
     * con los Ids de los Grupos Colaboradores (Grupo Padre)  
     *                                                        
     * Parameters: Una Lista de Colaboradores Nueva (Trigger.New) y otra lista de Colaboradores Vieja (Trigger.Old)
     *                                                           
     * --------------------------Historial-----------------------------------------------------------------------
     * VERSION              USER_STORY       AUTHOR               DATE               Description
     * 1.0                    US206848     Marcela Neira          19/04/2021         Creación
     * 1.1                    US227438     Marcela Neira          28/05/2021         Modificación para que se guarden tambien los ides de 
     *                                                                               grupos con RT SAC_GrupoResponsableAccion
     * 1.2                    DE71399      Raúl Santos            14/06/2023         Modificación: solucionar error al informar el campo SAC_PerteneceCOPSAJ__c
     * *********************************************************************************************************/
    
    public static  void actualizar(List<CC_Grupo_Colaborador_Contact__c> listaNueva, List<CC_Grupo_Colaborador_Contact__c> listaVieja){

        Set<Id> usuariosParaComprobar = new Set<id>();
        List<User> listausuariosParaActualizar =new List<User>();
        Map<Id,User> mapaDeUsuariosParaActualizar = new Map<Id,User>();
        
        if(listaNueva != null){
            for(CC_Grupo_Colaborador_Contact__c idUsuarioParaComprobarAux: listaNueva){
                if(String.isNotBlank(idUsuarioParaComprobarAux.CC_Usuario__c)){
                    usuariosParaComprobar.add(idUsuarioParaComprobarAux.CC_Usuario__c);
                }                
            }
        }
        
        if(listaVieja !=null){
            for(CC_Grupo_Colaborador_Contact__c idUsuarioParaComprobarAux: listaVieja){
                if(String.isNotBlank(idUsuarioParaComprobarAux.CC_Usuario__c)){
                    usuariosParaComprobar.add(idUsuarioParaComprobarAux.CC_Usuario__c);
                }
            }
        }
            
        if (Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isAccessible()  && Schema.sObjectType.User.isUpdateable()){               
            
            /**
             * Busca los GruposColaboradoresContact (Objeto Juntion / Grupo Hijo) y recoge el id del grupo Colaborador (Grupo Padre)
             * Que se encuentren en la lista que entra y a su vez que sean del RT Proveedores
             * */

            if(!usuariosParaComprobar.isEmpty()){
                List<CC_Grupo_Colaborador_Contact__c> grupoColaboradorContact = [SELECT id, CC_Grupo_Colaborador__r.RecordTypeId, CC_Usuario__c, CC_Usuario__r.SAC_PerteneceCOPSAJ__c, CC_Grupo_Colaborador__c, CC_Grupo_Colaborador__r.SAC_NivelGrupo__c
                                                                                FROM CC_Grupo_Colaborador_Contact__c 
                                                                                WHERE CC_Usuario__c  IN :usuariosParaComprobar 
                                                                                AND (CC_Grupo_Colaborador__r.RecordTypeId =:RECTYPEPROVEEDORES
                                                                                OR CC_Grupo_Colaborador__r.RecordTypeId =:RECTYPETAREAS
                                                                                OR CC_Grupo_Colaborador__r.RecordTypeId =: RECTYPELETRADOS)];


                //Inicializa el Mapa con los todos los usuarios que se tiene que modificar
                for(Id idUsuariosParaComprobar: usuariosParaComprobar){ 
                    User usuario = new User(Id = idUsuariosParaComprobar, SAC_GruposPerteneciente__c='',SAC_PerteneceCOPSAJ__c=false);
                    mapaDeUsuariosParaActualizar.put(idUsuariosParaComprobar, usuario);
                }

                //Los ususarios que tienen grupos se les actualiza y los que no se quedan con la inicialización anterior
                
                //Mapa con el id del usuario, y el valor booleano true o false, según si pertenece a algún grupo nivel 2 o nivel 3
                Map<Id,Boolean> mapUserCopsAj = new Map<Id,Boolean>();

                for(CC_Grupo_Colaborador_Contact__c grupoAuxConUsuarios: grupoColaboradorContact){ 
                    Boolean deCOPSAJ = false;
                    User usuario = mapaDeUsuariosParaActualizar.get(grupoAuxConUsuarios.CC_Usuario__c);
                    usuario.SAC_GruposPerteneciente__c += grupoAuxConUsuarios.CC_Grupo_Colaborador__c + ';';
                    
                                        
                    if(!deCOPSAJ && (grupoAuxConUsuarios.CC_Grupo_Colaborador__r.SAC_NivelGrupo__c == 'SAC_Nivel2' || grupoAuxConUsuarios.CC_Grupo_Colaborador__r.SAC_NivelGrupo__c == 'SAC_Nivel3')){
                        deCOPSAJ = true;
                        mapUserCopsAj.put(grupoAuxConUsuarios.CC_Usuario__c, true);
                    }

                    
                    if(mapUserCopsAj.get(grupoAuxConUsuarios.CC_Usuario__c) == true){
                        usuario.SAC_PerteneceCOPSAJ__c = true;
                    }else{
                        usuario.SAC_PerteneceCOPSAJ__c = false;
                    }
                    
                    mapaDeUsuariosParaActualizar.put(grupoAuxConUsuarios.CC_Usuario__c, usuario); 
                } 
                if(!mapaDeUsuariosParaActualizar.isEmpty()){                                        
                    listausuariosParaActualizar.addall(mapaDeUsuariosParaActualizar.values());
                    SAC_DatabaseDML.updateListDML(listausuariosParaActualizar,true);
                }       
            }                                                             
        }        
    }
    
    public static void actualizarSupervisores(Map<Id, CC_Grupo_Colaborador_Contact__c> mapNewObj, Map<Id, CC_Grupo_Colaborador_Contact__c> mapOldObj) {

        Id userId = UserInfo.getUserId();
        List<Id> listaSupervisoresAdd = new List<Id>();
        List<Id> listaSupervisoresSubtract = new List<Id>();  
        
        if(mapOldObj == null){//Viene del trigger de insertar
            for(Id ide : mapNewObj.keySet()){
                if(mapNewObj.get(ide).SAC_Supervisor__c){
                    listaSupervisoresAdd.add(mapNewObj.get(ide).CC_Usuario__c); 
                }
            }
        }
        else if(mapNewObj == null){//Viene del trigger de eliminar
            for(Id ide : mapOldObj.keySet()){
                if(mapOldObj.get(ide).SAC_Supervisor__c){
                    listaSupervisoresSubtract.add(mapOldObj.get(ide).CC_Usuario__c);
                }
            }
        }else{
            for(Id ide : mapNewObj.keySet()){
                if(mapNewObj.get(ide).SAC_Supervisor__c != mapOldObj.get(ide).SAC_Supervisor__c && mapNewObj.get(ide).SAC_Supervisor__c){
                    listaSupervisoresAdd.add(mapNewObj.get(ide).CC_Usuario__c);   
                }                
                if(mapNewObj.get(ide).SAC_Supervisor__c != mapOldObj.get(ide).SAC_Supervisor__c && !mapNewObj.get(ide).SAC_Supervisor__c){
                    listaSupervisoresSubtract.add(mapNewObj.get(ide).CC_Usuario__c);  
                }
            }
        }
 

        if(!listaSupervisoresAdd.isEmpty()){
            insertarSupervisoresCola(listaSupervisoresAdd);
        }
        if(!listaSupervisoresSubtract.isEmpty()){
            eliminarSupervisoresCola(listaSupervisoresSubtract);
        }
        
    }

    @future
    public static void insertarSupervisoresCola(List<Id> listaSupervisores) {
        Group colaSupervisores = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PteSupervisor' LIMIT 1];
        Group grupoPublicoSupervisores = [SELECT Id FROM Group WHERE Type = 'Regular' AND DeveloperName = 'SAC_SupervisoresDeGrupos' LIMIT 1];
        List<GroupMember> listaGroupMember = new List<GroupMember>();

        for (Id ide : listaSupervisores) {
            listaGroupMember.add(new GroupMember(UserOrGroupId = ide, GroupId = colaSupervisores.Id));
            listaGroupMember.add(new GroupMember(UserOrGroupId = ide, GroupId = grupoPublicoSupervisores.Id));
        }
        Database.insert(listaGroupMember);
    }

    @future
    public static void eliminarSupervisoresCola(List<Id> listaSupervisores) {

        List<Id> listaSupervisoresAEliminar = new List<Id>();

        //Buscamos los grupos a los que pertenecen los supervisores
        List<CC_Grupo_Colaborador_Contact__c> colabContact= [SELECT id, CC_Grupo_Colaborador__c, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c
                                 WHERE  CC_Usuario__c IN:listaSupervisores 
                                 AND SAC_Supervisor__c = true];
        
        Map<Id,Integer> mapUsuariosSupervisores = new Map<Id, Integer>();
        for (Id idSupervisores : listaSupervisores) {
            mapUsuariosSupervisores.put(idSupervisores, 0);
        }

        for (CC_Grupo_Colaborador_Contact__c gcc : colabContact) {
            Integer contador = mapUsuariosSupervisores.get(gcc.CC_Usuario__c);

            if(mapUsuariosSupervisores.containsKey(gcc.CC_Usuario__c)){ 
                contador++;               
                mapUsuariosSupervisores.put(gcc.CC_Usuario__c,contador);
            }
        }

        for(Id ide : mapUsuariosSupervisores.keySet()){ //Si solo esta en un grupo hay que quitarlo de la Cola de supervisores
            if(mapUsuariosSupervisores.get(ide)==0){
                listaSupervisoresAEliminar.add(ide);
            }   
        }

        if(!listaSupervisoresAEliminar.isEmpty()){
            List<GroupMember> listaSupervisoresEliminar =[SELECT Id FROM GroupMember where Group.DeveloperName ='SAC_PteSupervisor' AND UserOrGroupId IN :listaSupervisores];       
            List<GroupMember> listaSupervisoresGPEliminar =[SELECT Id FROM GroupMember where Group.DeveloperName ='SAC_SupervisoresDeGrupos' AND UserOrGroupId IN :listaSupervisores];
            
            if(!listaSupervisoresEliminar.isEmpty()){
                Database.delete(listaSupervisoresEliminar);
            }
            if(!listaSupervisoresGPEliminar.isEmpty()){
                Database.delete(listaSupervisoresGPEliminar);
            }    
        }
             
    }


    /*******************************************************************************************************
     * Proposito:  Método para actualizar los administradores del grupo COPS y el public group SAC_Auditor
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US502363      Sergio Martín   14/03/22       Creación Método
    *******************************************************************************************************/
    public static void actualizarAdministradores(Map<Id, CC_Grupo_Colaborador_Contact__c> mapNewObj, Map<Id, CC_Grupo_Colaborador_Contact__c> mapOldObj) {
        Id userId = UserInfo.getUserId();
        List<Id> listaAdministradoresAdd = new List<Id>();
        List<CC_Grupo_Colaborador_Contact__c> listaAdministradoresAddPs = new List<CC_Grupo_Colaborador_Contact__c>();
        List<Id> listaAdministradoresSubtract = new List<Id>();  
        List<CC_Grupo_Colaborador_Contact__c> listaAdministradoresSubtractPS = new List<CC_Grupo_Colaborador_Contact__c>();  
        
        if(mapOldObj == null){//Viene del trigger de insertar
            for(Id ide : mapNewObj.keySet()){
                listaAdministradoresAdd.add(mapNewObj.get(ide).CC_Usuario__c); 
            }
        }
        else if(mapNewObj == null){//Viene del trigger de eliminar
            for(Id ide : mapOldObj.keySet()){
                listaAdministradoresSubtract.add(mapOldObj.get(ide).CC_Usuario__c);
            }
        }else{
            for(Id ide : mapNewObj.keySet()){
                if(mapNewObj.get(ide).SAC_Administrador__c != mapOldObj.get(ide).SAC_Administrador__c && mapNewObj.get(ide).SAC_Administrador__c){
                    listaAdministradoresAdd.add(mapNewObj.get(ide).CC_Usuario__c);  
                    listaAdministradoresAddPS.add(mapNewObj.get(ide));  
                }                
                if(mapNewObj.get(ide).SAC_Administrador__c != mapOldObj.get(ide).SAC_Administrador__c && !mapNewObj.get(ide).SAC_Administrador__c){
                    listaAdministradoresSubtract.add(mapNewObj.get(ide).CC_Usuario__c);  
                    listaAdministradoresSubtractPS.add(mapNewObj.get(ide));
                }
            }
        }
 

        if(!listaAdministradoresAdd.isEmpty()){
            insertarAdministradoresGrupo(listaAdministradoresAdd);
            SAC_AdministrarUsuarios.asignarAuditorPermisionSet(listaAdministradoresAddPS, 'agregar');
        }
        if(!listaAdministradoresSubtract.isEmpty()){
            eliminarAdministradoresGrupo(listaAdministradoresSubtract);
            SAC_AdministrarUsuarios.asignarAuditorPermisionSet(listaAdministradoresSubtractPS, 'eliminar');
        }
        
    }

    /*******************************************************************************************************
     * Proposito:  Método para insertar los administrados del grupo COPS en el public group SAC_Auditor
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US502363      Sergio Martín   14/03/22       Creación Método
    *******************************************************************************************************/
    @future
    public static void insertarAdministradoresGrupo(List<Id> listaAdministradores) {
        Group grupoPublicoAdministradores = [SELECT Id FROM Group WHERE Type = 'Regular' AND DeveloperName = 'SAC_GrupoAuditor' LIMIT 1];
        List<GroupMember> listaGroupMember = new List<GroupMember>();

        if(!listaAdministradores.isEmpty()) {
            for (Id ide : listaAdministradores) {
                listaGroupMember.add(new GroupMember(UserOrGroupId = ide, GroupId = grupoPublicoAdministradores.Id));
            }
            Database.insert(listaGroupMember);
        }  
    }


    /*******************************************************************************************************
     * Proposito:  Método para eliminar los usuarios del public group SAC_Auditor
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US502363      Sergio Martín   14/03/22       Creación Método
    *******************************************************************************************************/
    @future
    public static void eliminarAdministradoresGrupo(List<Id> listaAdministradores) {
        if(!listaAdministradores.isEmpty()) {    
            List<GroupMember> listaAdministradoresGPEliminar = [SELECT Id FROM GroupMember where Group.DeveloperName = 'SAC_GrupoAuditor' AND UserOrGroupId IN :listaAdministradores];
            
            if(!listaAdministradoresGPEliminar.isEmpty()){
                Database.delete(listaAdministradoresGPEliminar);
            }    
        }
             
    }


    /*******************************************************************************************************
     * Proposito:  Método para actualizar el public group SAC_M2P
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US777530      Sergio Martín   13/05/24       Creación Método
    *******************************************************************************************************/
    public static void actualizarGrupoMoneyToPay(List <CC_Grupo_Colaborador_Contact__c> listGruposMoneyToPay, List<Id> listIdGrupoNivel3, String process) {
        Id userId = UserInfo.getUserId();
        List<Id> listaUsuariosAdd = new List<Id>();
        List<Id> listaUsuariosSubtract = new List<Id>();  
        
        if(process == 'agregar'){ //Viene del trigger de insertar
            for(CC_Grupo_Colaborador_Contact__c grupoContact : listGruposMoneyToPay){
                listaUsuariosAdd.add(grupoContact.CC_Usuario__c); 
            }
        }
        else if(process == 'eliminar'){ //Viene del trigger de eliminar
            for(CC_Grupo_Colaborador_Contact__c grupoContact : listGruposMoneyToPay){
                listaUsuariosSubtract.add(grupoContact.CC_Usuario__c); 
            }
        } 

        if(!listaUsuariosAdd.isEmpty()){
            insertarGrupoMoneyToPay(listaUsuariosAdd);
        }
        if(!listaUsuariosSubtract.isEmpty()){
            eliminarGrupoMoneyToPay(listaUsuariosSubtract, listIdGrupoNivel3);
        }
    }

    /*******************************************************************************************************
     * Proposito:  Método para insertar los usuarios en el public group SAC_M2P
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US777530      Sergio Martín   13/05/24       Creación Método
    *******************************************************************************************************/
    @future
    public static void insertarGrupoMoneyToPay(List<Id> listaUsuarios) {
        Group grupoPublicoMoneyToPay = [SELECT Id FROM Group WHERE Type = 'Regular' AND DeveloperName = 'SAC_M2P' LIMIT 1];
        List<GroupMember> listaGroupMember = new List<GroupMember>();

        if(!listaUsuarios.isEmpty()) {
            for (Id ide : listaUsuarios) {
                listaGroupMember.add(new GroupMember(UserOrGroupId = ide, GroupId = grupoPublicoMoneyToPay.Id));
            }
            Database.insert(listaGroupMember);
        }  
    }


    /*******************************************************************************************************
     * Proposito:  Método para eliminar los usuarios del public group SAC_M2P
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US777530      Sergio Martín   13/05/24       Creación Método
    *******************************************************************************************************/
    @future
    public static void eliminarGrupoMoneyToPay(List<Id> listaUsuarios, List<Id> listIdGrupoNivel3) {
        List<User> listaUsuariosEliminar = new List<User>();

        if(!listaUsuarios.isEmpty()) {   
            List<User> usuarios = [SELECT id, SAC_GruposPerteneciente__c FROM User WHERE Id =: listaUsuarios];

            for(User usuario : usuarios) {
                if(usuario.SAC_GruposPerteneciente__c != null) {
                    String[] gruposUsuario = usuario.SAC_GruposPerteneciente__c.split(';');
                    //Comprobamos si el grupo que queda es el de AJ o si no queda ningún grupo perteneciente para borrar al usuario del public group
                    for(id idGrupo : listIdGrupoNivel3) {
                        if((gruposUsuario.contains(idGrupo) && gruposUsuario.size() == 1)) { 
                            listaUsuariosEliminar.add(usuario);
                        }
                    }   
                } else {
                    listaUsuariosEliminar.add(usuario);
                }
            }
            if(!listaUsuariosEliminar.isEmpty()) {
                List<GroupMember> listaUsuariosGPEliminar = [SELECT Id FROM GroupMember where Group.DeveloperName = 'SAC_M2P' AND UserOrGroupId IN :listaUsuariosEliminar];
                if(!listaUsuariosGPEliminar.isEmpty()){
                    Database.delete(listaUsuariosGPEliminar);
                } 
            }
        }     
    }
}