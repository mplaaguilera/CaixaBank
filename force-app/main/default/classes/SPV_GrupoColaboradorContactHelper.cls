/*****************************************************************
 * Name: SPV_GrupoColaboradorContactHelper
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Asignar/Eliminar los Permission Sets a los usuarios cuando se añadan o eliminen de un grupo colaborador
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             US828257      Raúl Santos    29/04/24        Creación
****************************************************************/   

public with sharing class SPV_GrupoColaboradorContactHelper {

    public class SPVException extends Exception {}
    
    private static Set<String> objetos = new Set<String>{'CC_Grupo_Colaborador__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEGESTORES = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoGestor').getRecordTypeId();
    private static final Id RECTYPELETRADOS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoLetrado').getRecordTypeId();
    private static final Id RECTYPETAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();

    private static final String COPS = 'SPV_COPS';
    private static final String AJ = 'SPV_AJ';


    /*****************************************************************
     * Proposito: Métodos para asignar permisos a los usuarios que se añadan al grupo correspondiente
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US828257      Raúl Santos    29/04/24        Creación
    *****************************************************************/
    public static void procesarPermissionSet(List<CC_Grupo_Colaborador_Contact__c> listNew, String process, String permissionSet){

        List<Id> listIds = new List<Id>();
        Set<Id> listIdsUsuario = new Set<Id>();

        for(CC_Grupo_Colaborador_Contact__c gc : listNew){
            listIds.add(gc.Id);
            listIdsUsuario.add(gc.CC_Usuario__c);
        }

        if(process == 'agregar'){
            procesarUsuarios(listIds, listIdsUsuario, permissionSet);
        }else if(process == 'eliminar'){
            borrarPermissionSetUsuarios(listIdsUsuario, permissionSet);
        }
    }

    /*****************************************************************
     * Proposito:  Métodos para asignar permisos a los usuarios que se añadan al grupo correspondiente
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US828257      Raúl Santos    29/04/24        Creación
    *****************************************************************/
    @future
    public static void procesarUsuarios(List<Id> lstNuevosId, set<Id> lstUsers, String permissionSet){
        PermissionSet ps = getPermissionSet(permissionSet);
        insertarPermissionSet(lstNuevosId, lstUsers, ps);
    }

    /*****************************************************************
     * Proposito:  Métodos para eliminar permisos a los usuarios que se eliminen correspondiente
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US828257      Raúl Santos    29/04/24        Creación
    *****************************************************************/
    @future
    private static void borrarPermissionSetUsuarios (set<Id> lstUsers, String permissionSet){ 
        
        Set<Id> setIdsRtGruposColaboradores = new Set<Id>();
        Boolean permisoAdministrador = false;
        Boolean permisoAjEscalados = false;
        Boolean permisoAuditor = false;
        Boolean permisoAdminGrupo = false;

        if(String.isNotBlank(permissionSet)){
            switch on permissionSet {
                when 'SPV_Gestor' {
                    setIdsRtGruposColaboradores.add(RECTYPEGESTORES);
                }
                when 'SPV_Letrado' {
                    setIdsRtGruposColaboradores.add(RECTYPELETRADOS);
                }
                when 'SPV_AdministradorGrupos' {
                    setIdsRtGruposColaboradores.addAll(new Set<Id>{RECTYPEGESTORES, RECTYPELETRADOS, RECTYPETAREAS});
                    permisoAdminGrupo = true;
                }
                when 'SPV_Administrador' {
                    setIdsRtGruposColaboradores.add(RECTYPETAREAS);
                    permisoAdministrador = true;
                }
                when 'SPV_Escalados' {
                    setIdsRtGruposColaboradores.add(RECTYPETAREAS);
                    permisoAjEscalados = true;
                }
                when 'SPV_Auditor' {
                    setIdsRtGruposColaboradores.add(RECTYPETAREAS);
                    permisoAuditor = true;
                }
            }
        }

        //Si el usuario pertenece a otro grupo gestor, no debemos eliminar el PS
        List<CC_Grupo_Colaborador_Contact__c> colaboradoresDelUser = new List<CC_Grupo_Colaborador_Contact__c>();
        if(Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isAccessible()){
            if(!permisoAdministrador && !permisoAjEscalados && !permisoAdminGrupo && !permisoAuditor){
                colaboradoresDelUser = [SELECT Id FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__r.RecordTypeId IN :setIdsRtGruposColaboradores AND CC_Usuario__c IN: lstUsers];    
            }else{
                if(permisoAdminGrupo){
                    colaboradoresDelUser = [SELECT Id FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__r.RecordTypeId IN :setIdsRtGruposColaboradores AND CC_Usuario__c IN: lstUsers AND SAC_Administrador__c = true];    
                }else if(permisoAdministrador){
                    colaboradoresDelUser = [SELECT Id FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__r.RecordTypeId =: RECTYPETAREAS AND CC_Usuario__c IN: lstUsers AND (CC_Grupo_Colaborador__r.SAC_DeveloperName__c =: COPS OR CC_Grupo_Colaborador__r.SAC_DeveloperName__c =: AJ)];
                }else if(permisoAjEscalados){
                    colaboradoresDelUser =  [SELECT Id FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__r.RecordTypeId =: RECTYPETAREAS AND CC_Usuario__c IN: lstUsers AND CC_Grupo_Colaborador__r.SAC_DeveloperName__c =: AJ];
                }else if(permisoAuditor){
                    colaboradoresDelUser =  [SELECT Id FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__r.RecordTypeId =: RECTYPETAREAS AND CC_Usuario__c IN: lstUsers AND CC_Grupo_Colaborador__r.SAC_DeveloperName__c =: COPS];
                }
            }
        }  
       
        if(colaboradoresDelUser.isEmpty()){
            PermissionSet ps = getPermissionSet(permissionSet);
            borrarPermissionSet(lstUsers, ps);
        }
    }

    /*****************************************************************
     * Proposito: Inserta el nuevo permission set al usuario (si no lo tiene)
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US828257      Raúl Santos    29/04/24        Creación
    *****************************************************************/
    public static void insertarPermissionSet (List<Id> lstNuevosId, set<Id> lstUsers, PermissionSet ps){
    
        Map<String,String> mapaUsuarios = new  Map<String,String>();
        List<PermissionSetAssignment> listaInsert = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> permisosUser = getPermisosUser(lstUsers, ps);
        List<CC_Grupo_Colaborador_Contact__c> aInsertar = [SELECT Id, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c WHERE Id IN: lstNuevosId];


        if(!permisosUser.isEmpty()){
            for(PermissionSetAssignment permiso : permisosUser){
                mapaUsuarios.put(permiso.AssigneeId, permiso.AssigneeId);
            }
        }

        for(CC_Grupo_Colaborador_Contact__c gc : aInsertar){
            if(!mapaUsuarios.containsKey(gc.CC_Usuario__c)){
                PermissionSetAssignment assigment = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = gc.CC_Usuario__c); 
                listaInsert.add(assigment);
            }
        }

        try{
            if(!listaInsert.isEmpty()){
                SPV_DatabaseDML.insertListDML(listaInsert, false);
            }
        } catch (Exception e){
            CBK_log.error(e);
        }       
    }

    /*****************************************************************
     * Proposito: Elimina el permission set al usuario
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US828257      Raúl Santos    29/04/24        Creación
    *****************************************************************/
    private static void borrarPermissionSet (set<Id> lstUsers, PermissionSet ps){
        List<PermissionSetAssignment> listPermisosUser = getPermisosUser(lstUsers, ps);

        try{
            if(!listPermisosUser.isEmpty()){
                SPV_DatabaseDML.deleteListDML(listPermisosUser, false);
            }
        }catch(Exception e){
            CBK_log.error(e);
        }
    }  

    /*****************************************************************
     * Proposito: Método que devuelve el permissionset a añadir al usuario
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US828257      Raúl Santos    29/04/24        Creación
    *****************************************************************/
    public static PermissionSet getPermissionSet (String psName){ 
        return [SELECT id FROM PermissionSet WHERE  PermissionSet.Name =: psName];
    }

    /*****************************************************************
     * Proposito: Método que devuelve el getPermisosUser al que se debe añadir el nuevo permiso
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US828257      Raúl Santos    29/04/24        Creación
    *****************************************************************/
    public static List<PermissionSetAssignment> getPermisosUser (set<Id> lstUsers, PermissionSet ps){ 
        return [SELECT PermissionSetId, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId IN: lstUsers AND PermissionSetId =: ps.Id];
    }

    /*****************************************************************
     * Proposito: Valida si el usuario que intenta insertar, modificar o eliminar un colaborador de un determinado grupo tiene permisos para ello.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US828257      Raúl Santos    29/04/24        Creación
    *****************************************************************/
    public static void validarAdmin(List<CC_Grupo_Colaborador_Contact__c> listNewObjFiltrada){
        //Validamos si usuarios es administrador del grupo
        Set<Id> myset = new Map<Id,AggregateResult>([SELECT CC_Grupo_Colaborador__c Id FROM CC_Grupo_Colaborador_Contact__c  
                                WHERE (CC_Grupo_Colaborador__r.RecordTypeId =: RECTYPEGESTORES OR CC_Grupo_Colaborador__r.RecordTypeId =: RECTYPELETRADOS OR CC_Grupo_Colaborador__r.RecordTypeId =: RECTYPETAREAS) 
                                AND CC_Usuario__c =: userInfo.getUserId() AND SAC_Administrador__c = true GROUP BY CC_Grupo_Colaborador__c HAVING CC_Grupo_Colaborador__c!= null]).keySet();

        for (CC_Grupo_Colaborador_Contact__c grContact : listNewObjFiltrada) {
            if(!myset.contains(grContact.CC_Grupo_Colaborador__c) && !Test.isRunningTest()){
                grContact.addError('Usted no puede llevar a cabo modificaciones del grupo. Por favor póngase en contacto con el administrador del grupo.');
            }    
        }
    }


    /*****************************************************************
     * Proposito: Método para comprobar si se permite modificar el propietario del caso
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0               ---          Alex Polo       ---       Creación Método
    *****************************************************************/
    public static void permitirCambiarOwner(List<Case> listOwners, Map<Id, Case> mapOld, Group cola){

        String usuarioActual = UserInfo.getUserId();
        List<Id> idGruposColaboradores = new List<Id>();

        //Se almacena los ids de los grupos de los que son los casos
        for(Case caso: listOwners){
            idGruposColaboradores.add(caso.SEG_Grupo__c);
        }

        Map<Id, List<CC_Grupo_Colaborador_Contact__c>> mapGrupoCol = new Map <Id, List<CC_Grupo_Colaborador_Contact__c>>();

        //Se obtienen aquellos grupos cuyo id se encuentre en alguno de los casos que se han modificado
        List<CC_Grupo_Colaborador__c> gruposColaboradores = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE Id IN: idGruposColaboradores];

        //Del objeto junction en el que se establece usuario-grupo, se obtiene el grupo, usuario, y si está checked admin y supervisor
        //Coge estos valores de aquellos registros de grupo_colaborador_contact que tengan como grupo alguno de los que haya en grupoColab de la consulta anterior

        List<CC_Grupo_Colaborador_Contact__c> usersGrupo =  [SELECT Id, CC_Usuario__c, SAC_Administrador__c, CC_Grupo_Colaborador__c
                                FROM CC_Grupo_Colaborador_Contact__c
                                WHERE CC_Grupo_Colaborador__c IN: gruposColaboradores];

        //Si hay registros que cumplen la consulta anterior, se recorren
        if(!usersGrupo.isEmpty()){
            for(CC_Grupo_Colaborador_Contact__c colaborador : usersGrupo){
                List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = new List<CC_Grupo_Colaborador_Contact__c>();

                //Si el grupo actual ya se encuentra en el mapa, se añadirá el colaborador a la lista de colaboradores de ese grupo
                if(mapGrupoCol.containsKey(colaborador.CC_Grupo_Colaborador__c)){
                    listaColaboradores = mapGrupoCol.get(colaborador.CC_Grupo_Colaborador__c);
                    listaColaboradores.add(colaborador);
                    mapGrupoCol.put(colaborador.CC_Grupo_Colaborador__c, listaColaboradores);    //Mapa <Id del grupo - lista de grupo_contact>
                }else{      //Si el grupo no estaba en el mapa, se añade, teniendo como lista de colaboradores de momento solo el actual
                    listaColaboradores.add(colaborador);
                    mapGrupoCol.put(colaborador.CC_Grupo_Colaborador__c, listaColaboradores);
                }
            }
        }


        //Para cada caso de los casos mmodificados
        for(Case caso : listOwners){
            //Si el grupo se encuentra en el mapa y si se encuentra no está vacío, y el nuevo owner no es el de cola ni supervisores (Pte. Asignar ni Pte. supervisores), se
            //va a comprobar si el usuario forma parte de la cola/ grupo
            Id grupoCaso = caso.SEG_Grupo__c;
    
            if(mapGrupoCol.containsKey(grupoCaso) && !mapGrupoCol.get(grupoCaso).isEmpty() && caso.OwnerId != cola.Id){
                Boolean formaParte = false;

                for(CC_Grupo_Colaborador_Contact__c colaborador : mapGrupoCol.get(grupoCaso)){
                        //Si el usuario actual se encuentra en alguno de esos registros  y o es administrador o supervisor, entonces forma parte
                        if(usuarioActual == colaborador.CC_Usuario__c && colaborador.SAC_Administrador__c == true){
                        formaParte = true;
                        }
                }

                if(formaParte == false){
                    caso.addError('Usted no pertenece a la cola de trabajo, o no es administrador de el mismo.');
                }
            }

        }  

        //Se va a comprometer los cambios
        commitChanges(listOwners, mapGrupoCol, cola);
    }

    /*****************************************************************
     * Proposito: Método para validar si no cumple los requisitos el nuevo owner
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0               ---          Alex Polo       ---       Creación Método
    *****************************************************************/
    public static void commitChanges(List<Case> listOwners, Map<Id, List<CC_Grupo_Colaborador_Contact__c>> mapGrupoCol, Group cola){

        //Para cada caso modificado
        for(Case caso : listOwners){

            //Se recoge el id del usuario al que se ha asignado el caso
            Id identificador = caso.OwnerId;
    
            List<CC_Grupo_colaborador_Contact__c> listaColaboradoresGrupo = mapGrupoCol.get(caso.SEG_Grupo__c);    //Se obtiene una lista de los colaboradores (registros usuario-grupo) que están en el grupo del caso actual

            if(listaColaboradoresGrupo != null){
                Boolean resultado = false;
                for(CC_Grupo_Colaborador_Contact__c colaborador : listaColaboradoresGrupo){      //Se recorren los colaboradores del grupo del caso actual
                    //Y si el owner es el usuario, o está en Pte. Asignar o Pte. Supervisor, entonces sí podrá tomar en propiedad. En caso contrario, error.
                    if(identificador == colaborador.CC_Usuario__c || identificador == cola.Id){
                        resultado = true;
                    }
                }

                if(resultado == false){
                    caso.addError('El usuario seleccionado no pertenece a la cola de trabajo.');
                }
            }
        }
    }

    /*****************************************************************
     * Proposito: Relllena el campo SAC_GruposPerteneciente__c del Objeto User con los Ids de los Grupos Colaboradores, tambien el campo SAC_PerteneceCOPSAJ__c en casi de pertenecer a estos
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                 ---      Raúl Santos     19/07/24        Creación
    *****************************************************************/
    public static  void actualizarGruposPertenecientesUser(List<CC_Grupo_Colaborador_Contact__c> listaNueva, List<CC_Grupo_Colaborador_Contact__c> listaVieja){

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

            if(!usuariosParaComprobar.isEmpty()){
                List<CC_Grupo_Colaborador_Contact__c> grupoColaboradorContact = [SELECT id, CC_Grupo_Colaborador__r.RecordTypeId, CC_Usuario__c, CC_Usuario__r.SAC_PerteneceCOPSAJ__c, CC_Grupo_Colaborador__c, CC_Grupo_Colaborador__r.SAC_NivelGrupo__c
                                                                                FROM CC_Grupo_Colaborador_Contact__c 
                                                                                WHERE (CC_Grupo_Colaborador__r.RecordTypeId =:RECTYPEGESTORES
                                                                                OR CC_Grupo_Colaborador__r.RecordTypeId =:RECTYPELETRADOS
                                                                                OR CC_Grupo_Colaborador__r.RecordTypeId =: RECTYPETAREAS) AND CC_Usuario__c  IN :usuariosParaComprobar ];


                //Inicializa el Mapa con los todos los usuarios que se tiene que modificar
                for(Id idUsuariosParaComprobar: usuariosParaComprobar){ 
                    User usuario = new User(Id = idUsuariosParaComprobar, SAC_GruposPerteneciente__c='',SAC_PerteneceCOPSAJ__c=false);
                    mapaDeUsuariosParaActualizar.put(idUsuariosParaComprobar, usuario);
                }

                //Los usuarios que tienen grupos se les actualiza y los que no se quedan con la inicialización anterior
                
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
                    SPV_DatabaseDML.updateListDML(listausuariosParaActualizar,true);
                }       
            }                                                             
        }        
    }

    /*****************************************************************
     * Proposito: Comprueba si el grupo tiene usuarios activos para informarlo en el campo SAC_TieneUsuariosActivos__c
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                 ---      Raúl Santos     19/07/24        Creación
    *****************************************************************/
    public static void recalcularUsuarioActivos(Set<Id> setIds) {

        Map<Id, CC_Grupo_Colaborador__c> mapaGruposActualizarFinal = new Map<Id, CC_Grupo_Colaborador__c>();
        
        List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = [SELECT id, CC_Grupo_Colaborador__r.SAC_TieneUsuariosActivos__c, CC_Grupo_Colaborador__c, CC_Usuario__r.IsActive
                                                            FROM CC_Grupo_Colaborador_Contact__c 
                                                            WHERE CC_Usuario__r.IsActive = true AND CC_Grupo_Colaborador__c IN :setIds
                                                            AND (CC_Grupo_Colaborador__r.RecordTypeId =: RECTYPEGESTORES
                                                            OR CC_Grupo_Colaborador__r.RecordTypeId =: RECTYPELETRADOS
                                                            OR CC_Grupo_Colaborador__r.RecordTypeId =: RECTYPETAREAS)];

        Map<Id,Boolean> mapaGruposActualizar = new  Map<Id,Boolean>();
        for (CC_Grupo_Colaborador_Contact__c gcc : listaColaboradores) {
            mapaGruposActualizar.put(gcc.CC_Grupo_Colaborador__c, false); 
            
            if(gcc.CC_Usuario__r.IsActive){
                mapaGruposActualizar.put(gcc.CC_Grupo_Colaborador__c, true);
            }
        }

        
        if(!mapaGruposActualizar.isEmpty()){
            for(Id ide : mapaGruposActualizar.keySet()){ 
                CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();
                grupo.id = ide;
                grupo.SAC_TieneUsuariosActivos__c = mapaGruposActualizar.get(ide);
                mapaGruposActualizarFinal.put(grupo.Id, grupo);
            }            
        }else{//Si no encuentra nada viene del Delete o no tiene usuarios activos
            for (Id ideGrupo : setIds) {
                CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c(Id = ideGrupo, SAC_TieneUsuariosActivos__c = false);
                mapaGruposActualizarFinal.put(grupo.Id, grupo);
            }
        }

        if (!mapaGruposActualizarFinal.isEmpty()) { 
            SPV_DatabaseDML.updateListDML(mapaGruposActualizarFinal.values(),true);
        }
    }

    /*****************************************************************
     * Proposito: Método para procesar a los usuarios su insercción o eliminación a un grupo publico
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0               ---         Raúl Santos    09/10/24        Creación
    *****************************************************************/
    public static void procesarPublicGroup(List<CC_Grupo_Colaborador_Contact__c> listNew, String process, String grupoPublico){

        Set<Id> listIdsUsuario = new Set<Id>();

        for(CC_Grupo_Colaborador_Contact__c gc : listNew){
            listIdsUsuario.add(gc.CC_Usuario__c);
        }

        if(process == 'agregar'){
            insertarGrupoPublico(listIdsUsuario, grupoPublico);
        }else if(process == 'eliminar'){
            eliminarGrupoPublico(listIdsUsuario, grupoPublico);
        }
    }

    /*******************************************************************************************************
     * Proposito: Método para insertar a los usuarios en un grupo publico
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0               ---         Raúl Santos    09/10/24        Creación
    *******************************************************************************************************/
    @future
    public static void insertarGrupoPublico(Set<Id> listIdsUsuario, String grupoPublicoName) {
        Group grupoPublico = [SELECT Id FROM Group WHERE Type = 'Regular' AND DeveloperName = :grupoPublicoName LIMIT 1];
        List<GroupMember> listaGroupMember = new List<GroupMember>();

        if(!listIdsUsuario.isEmpty()) {
            for (Id ide : listIdsUsuario) {
                listaGroupMember.add(new GroupMember(UserOrGroupId = ide, GroupId = grupoPublico.Id));
            }
            SPV_DatabaseDML.insertListDML(listaGroupMember, false);
        }  
    }

    /*******************************************************************************************************
     * Proposito:  Método para eliminar a los usuarios en un grupo publico
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0               ---         Raúl Santos    09/10/24        Creación
    *******************************************************************************************************/
    @future
    public static void eliminarGrupoPublico(Set<Id> listIdsUsuario, String grupoPublicoName) {
        if(!listIdsUsuario.isEmpty()) {    
            List<GroupMember> listUserGPEliminar = [SELECT Id FROM GroupMember WHERE Group.DeveloperName = :grupoPublicoName AND UserOrGroupId IN :listIdsUsuario];
            
            if(!listUserGPEliminar.isEmpty()){
                SPV_DatabaseDML.deleteListDML(listUserGPEliminar, false);
            }    
        }
    }
}