public without sharing class SAC_AdministrarUsuarios {
    /*****************************************************************
     * Name: SAC_AdministrarUsuarios
     * Copyright © 2021  CaixaBank
     * 
     * Proposito: Actualizar los PS del usuario que pertenezca al grupo colaborador y sea administrador
     * Proposito 2: Permitir cambiar el propietario del caso siempre y cuando sea el usuario actual admin del grupo; y introduzca un user de su grupo
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US233800         Luis Mesa      17/06/21     Creación
    *****************************************************************/    
    
        private static Set<String> objetos = new Set<String>{'CC_Grupo_Colaborador__c'};
        private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    
        private static final Id RECTYPEPROVEEDORES = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_GrupoProveedores').getRecordTypeId();
        private static final Id RECTYPETAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_GrupoResponsableAccion').getRecordTypeId();
        private static final Id RECTYPELETRADOS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SAC_Letrados').getRecordTypeId();
    
        private static final String PS_VIDA_CAIXA = 'SAC_Vidacaixa';
        private static final String PS_ADMIN_GRUPOS = 'SAC_AdministradorGrupos';
        private static final String PS_ASIGNAR_ESCALADO = 'SAC_Asignar_Escalado';
        private static final String PS_AUDITOR = 'SAC_Auditor';
        private static final String PS_ADMINISTRADOR = 'SAC_Administrador';
        private static final String PS_AUDITORIAS = 'SAC_Auditorias';
    
        /*****************************************************************
         * Proposito: Método que devuelve el permisionset que deben añadirse a los perfiles
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US233800         Jesús Costa   07/012/22       Creación Método
        *****************************************************************/
        private static  PermissionSet getPermisionSet (String psName){ 
            return [SELECT id FROM PermissionSet WHERE  PermissionSet.Name =: psName];
        }
    
        /*****************************************************************
         * Proposito: Método que devuelve el getPermisosUser al que se debe añadir el nuevo permiso
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US233800         Jesús Costa   07/012/22       Creación Método
        *****************************************************************/
        private static  List<PermissionSetAssignment> getPermisosUser (set<Id> lstUsers, PermissionSet ps){ 
            return [SELECT PermissionSetId, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId IN: lstUsers AND PermissionSetId =: ps.Id];
        }
    
        public static void asignarAdministradores(List<CC_Grupo_Colaborador_Contact__c> listNew, Map<Id, CC_Grupo_Colaborador_Contact__c> mapOld){
        /*****************************************************************
         * Proposito: Método para filtrar si se modifica el campo SAC_Administrador del Colaborador
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US233800         Luis Mesa    17/06/21       Creación Método
        *****************************************************************/
            List<Id> listadoGrupoColab = new List<Id>();
            for(CC_Grupo_Colaborador_Contact__c gc : listNew){
                if(mapOld.containsKey(gc.Id)){
                    if(mapOld.get(gc.Id).SAC_Administrador__c != gc.SAC_Administrador__c){
                        listadoGrupoColab.add(gc.Id);
                    }
                }
            }
            procesarAdminisitradores(listadoGrupoColab);
        }
    
        /*****************************************************************
         * Proposito: Método para asignar permisos VidaCaixa a los usuarios que se añadan a grupos VidaCaixa
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US499901         Raúl          07/12/22      Creación Método
        *****************************************************************/
        public static void asignarVidaCaixaPermisionSet (List<CC_Grupo_Colaborador_Contact__c> listNew, String process){
            List<Id> listIds = new List<Id>();
            set<Id> listIdsUsuario = new set<Id>();
    
            for(CC_Grupo_Colaborador_Contact__c gc : listNew){
                listIds.add(gc.Id);
                listIdsUsuario.add(gc.CC_Usuario__c);
                
            }
    
            if(process == 'agregar'){
                procesarUsuariosVidaCaixa(listIds, listIdsUsuario);
            }else if(process == 'eliminar'){
                borrarPermisionUsuariosVidaCaixa(listIds, listIdsUsuario);
            }
    
        }
    
        public static void asignarAJPermisionSet (List<CC_Grupo_Colaborador_Contact__c> listNew, String process){
            List<Id> listIds = new List<Id>();
            set<Id> listIdsUsuario = new set<Id>();
    
            for(CC_Grupo_Colaborador_Contact__c gc : listNew){
                listIds.add(gc.Id);
                listIdsUsuario.add(gc.CC_Usuario__c);  
            }
    
            if(process == 'agregar'){
                procesarUsuariosAJ(listIds, listIdsUsuario);
                procesarUsuariosAdministrador(listIds, listIdsUsuario);
                //US770903 Auditorias / Raúl Santos / Añadimos el PS de Auditorias
                procesarUsuariosAuditores(listIds, listIdsUsuario);
            }else if(process == 'eliminar'){
                borrarPermisionUsuariosAJ(listIds, listIdsUsuario);
                borrarPermisionUsuariosAdministrador(listIds, listIdsUsuario);
                //US770903 Auditorias / Raúl Santos / Eliminamos el PS de Auditorias
                borrarPermisionUsuariosAuditores(listIds, listIdsUsuario);
            }
        }
    
        @future
        private static void borrarPermisionUsuariosAJ (List<Id> lstNuevosId, set<Id> lstUsers){
        /*****************************************************************
         * Proposito:  Método para eliminar permisos VidaCaixa a los usuarios que se eliminen de grupos VidaCaixa
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US499901         Jesús          07/12/22       Creación Método
        *****************************************************************/
            
            PermissionSet ps = getPermisionSet(PS_ASIGNAR_ESCALADO);
            borrarPermisionSet(lstNuevosId, lstUsers, ps);
        }
    
        @future
        private static void procesarUsuariosAJ(List<Id> lstNuevosId, set<Id> lstUsers){
                PermissionSet ps = getPermisionSet(PS_ASIGNAR_ESCALADO);
                procesarPermisionSet(lstNuevosId, lstUsers, ps);
        }
    
        @future
        private static void borrarPermisionUsuariosVidaCaixa (List<Id> lstNuevosId, set<Id> lstUsers){
        /*****************************************************************
         * Proposito:  Método para eliminar permisos VidaCaixa a los usuarios que se eliminen de grupos VidaCaixa
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US499901         Jesús          07/12/22       Creación Método
        *****************************************************************/
            
            PermissionSet ps = getPermisionSet(PS_VIDA_CAIXA);
            borrarPermisionSet(lstNuevosId, lstUsers, ps);
        }
    
        @future
        private static void procesarUsuariosVidaCaixa(List<Id> lstNuevosId, set<Id> lstUsers){
                PermissionSet ps = getPermisionSet(PS_VIDA_CAIXA);
                procesarPermisionSet(lstNuevosId, lstUsers, ps);
        }
    
    
        /*****************************************************************
         * Proposito: Método para asignar permisos auditor a los usuarios que se eliminen del grupo COPS como administrador
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US502363      Sergio Martín   13/03/22       Creación Método
        *****************************************************************/
        public static void asignarAuditorPermisionSet (List<CC_Grupo_Colaborador_Contact__c> listNew, String process){
            List<Id> listIds = new List<Id>();
            set<Id> listIdsUsuario = new set<Id>();
    
            if(!listNew.isEmpty()){
                for(CC_Grupo_Colaborador_Contact__c gc : listNew){
                    listIds.add(gc.Id);
                    listIdsUsuario.add(gc.CC_Usuario__c);     
                }
            }
    
            if(process == 'agregar'){
                procesarUsuariosAuditor(listIds, listIdsUsuario);
            }else if(process == 'eliminar'){
                borrarPermisionUsuariosAuditor(listIds, listIdsUsuario);
            }
        }
    
        @future
        private static void borrarPermisionUsuariosAuditor (List<Id> lstNuevosId, set<Id> lstUsers){
        /*****************************************************************
         * Proposito:  Método para eliminar permisos auditor a los usuarios que se eliminen del grupo COPS como administrador
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US502363      Sergio Martín   13/03/22       Creación Método
        *****************************************************************/
            
            PermissionSet ps = getPermisionSet(PS_AUDITOR);
            borrarPermisionSet(lstNuevosId, lstUsers, ps);
        }
    
        @future
        private static void procesarUsuariosAuditor(List<Id> lstNuevosId, set<Id> lstUsers){
                PermissionSet ps = getPermisionSet(PS_AUDITOR);
                procesarPermisionSet(lstNuevosId, lstUsers, ps);
        }
    
    
        /*****************************************************************
         * Proposito: Método para asignar/eliminar el permission set SAC_Administrador a los usuarios que se añadan/eliminen de los grupos COPS/AJ
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US520791         Raúl Santos    06/06/2023   Creación Método
        *****************************************************************/
        public static void asignarAdministradorPermisionSet (List<CC_Grupo_Colaborador_Contact__c> listNew, String process){
            List<Id> listIds = new List<Id>();
            set<Id> listIdsUsuario = new set<Id>();
    
            if(!listNew.isEmpty()){
                for(CC_Grupo_Colaborador_Contact__c gc : listNew){
                    listIds.add(gc.Id);
                    listIdsUsuario.add(gc.CC_Usuario__c);     
                }
            }
    
            if(process == 'agregar'){
                procesarUsuariosAdministrador(listIds, listIdsUsuario);
            }else if(process == 'eliminar'){
                borrarPermisionUsuariosAdministrador(listIds, listIdsUsuario);
            }
        }
    
        @future
        private static void borrarPermisionUsuariosAdministrador (List<Id> lstNuevosId, set<Id> lstUsers){
        /*****************************************************************
         * Proposito:  Método para eliminar PS SAC_Administrador a los usuarios que se eliminen del grupo COPS/AJ
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0           US520791        Raúl Santos     06/06/2023    Creación Método
        *****************************************************************/
            
            PermissionSet ps = getPermisionSet(PS_ADMINISTRADOR);
    
            List<CC_Grupo_Colaborador_Contact__c> gruposUser = [SELECT Id, CC_Usuario__c, CC_Grupo_Colaborador__c, CC_Grupo_Colaborador__r.Name FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c IN: lstUsers];
    
            Boolean userPerteneceCopsAJ = false;
            for(CC_Grupo_Colaborador_Contact__c gc : gruposUser){
                if(gc.CC_Grupo_Colaborador__r.Name == 'COPS' || gc.CC_Grupo_Colaborador__r.Name == 'Asesoría Jurídica') {
                    userPerteneceCopsAJ = true;
                }
            }
    
            if(!userPerteneceCopsAJ){
                borrarPermisionSet(lstNuevosId, lstUsers, ps);
            }
            
        }
    
         /*****************************************************************
         * Proposito:  Método para añadir PS SAC_Administrador a los usuarios que se añaden al grupo COPS/AJ
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US520791        Raúl Santos     06/06/2023    Creación Método
        *****************************************************************/
        @future
        private static void procesarUsuariosAdministrador(List<Id> lstNuevosId, set<Id> lstUsers){
                PermissionSet ps = getPermisionSet(PS_ADMINISTRADOR);
                procesarPermisionSet(lstNuevosId, lstUsers, ps);
        }
    
    
        private static void borrarPermisionSet (List<Id> lstNuevosId, set<Id> lstUsers, PermissionSet ps){
            List<PermissionSetAssignment> listPermisosUser = getPermisosUser(lstUsers, ps);
    
            try{
                if(!listPermisosUser.isEmpty()){
                    SAC_DatabaseDML.deleteListDML(listPermisosUser, false);
                }
            }catch(Exception e){
                CBK_log.error(e);
            }
        }
    
        private static void procesarPermisionSet (List<Id> lstNuevosId, set<Id> lstUsers, PermissionSet ps){
    
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
                // insertar la lista
                if(!listaInsert.isEmpty()){
                    SAC_DatabaseDML.insertListDML(listaInsert, false);
                }
            } catch (Exception e){
                CBK_log.error(e);
            }       
        }
    
        
         /*****************************************************************
         * Proposito:  Método para añadir/eliminar PS SAC_Auditoria a los usuarios que se añaden al grupo SAC Auditores
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US742348        Carlos Gómez    30/10/2023    Creación Método
         * 1.1            US770903        Raúl Santos     12/12/2023    Modificación: Tras eliminar al usuario de un grupo, si ese usuario pertenece a COPS, AJ, grupo Auditores, o es auditor de otro 
         *                                                                            grupo Proveedor o Letrado, no debemos eleminar el PS
        *****************************************************************/
    
    
        public static void asignarPermissionSetAuditores (List<CC_Grupo_Colaborador_Contact__c> listNew, String process){
            List<Id> listIds = new List<Id>();
            set<Id> listIdsUsuario = new set<Id>();
    
            for(CC_Grupo_Colaborador_Contact__c gc : listNew){
                listIds.add(gc.Id);
                listIdsUsuario.add(gc.CC_Usuario__c);
            }
    
            if(process == 'agregar'){
                procesarUsuariosAuditores(listIds, listIdsUsuario);
            }else if(process == 'eliminar'){
                borrarPermisionUsuariosAuditores(listIds, listIdsUsuario);
            }
    
        }
    
        
        @future
        private static void borrarPermisionUsuariosAuditores (List<Id> lstNuevosId, set<Id> lstUsers){
    
            //Si el usuario pertenece a COPS, AJ, grupo Auditores, o es auditor de otro grupo Proveedor o Letrado, no debemos eleminar el PS
            List<CC_Grupo_Colaborador_Contact__c> colaboradoresDelUser = [SELECT Id, CC_Usuario__c, SAC_Supervisor__c, CC_Grupo_Colaborador__c
                                                    FROM CC_Grupo_Colaborador_Contact__c 
                                                    WHERE (((CC_Grupo_Colaborador__r.RecordTypeId =: RECTYPEPROVEEDORES OR CC_Grupo_Colaborador__r.RecordTypeId =: RECTYPELETRADOS) AND SAC_Auditor__c = true) OR 
                                                    (CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'COPS' OR CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'AJ' OR CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'SAC_AUDITORES')) 
                                                    AND CC_Usuario__c IN: lstUsers ];
            
            if(colaboradoresDelUser.size() == 0){
                PermissionSet ps = getPermisionSet(PS_AUDITORIAS);
                borrarPermisionSet(lstNuevosId, lstUsers, ps);
            }
        }
    
    
    
        @future
        private static void procesarUsuariosAuditores(List<Id> lstNuevosId, set<Id> lstUsers){
                PermissionSet ps = getPermisionSet(PS_AUDITORIAS);
                procesarPermisionSet(lstNuevosId, lstUsers, ps);
        }
    
    
    
        @future
        public static void procesarAdminisitradores(List<Id> nuevosId){
        /*****************************************************************
         * Proposito: Método para otorgar o revocar Permisos de Administrador de Grupos SAC, en funcion del campo SAC_Administrador
         *              Si está checked, se han de otorgar; Si no se han de revocar.
         *
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US233800         Luis Mesa    17/06/21       Creación Método
        *****************************************************************/
            List<CC_Grupo_Colaborador_Contact__c> nuevosAdmins = [SELECT Id, SAC_Administrador__c,CC_Usuario__c, CC_Grupo_Colaborador__c, CC_Grupo_Colaborador__r.Name
                FROM CC_Grupo_Colaborador_Contact__c
                WHERE ID IN: nuevosId];
    
            Boolean esAdminCOPS = true;
            set<Id> users = new set<Id>();
            for(CC_Grupo_Colaborador_Contact__c gc : nuevosAdmins){
                if(gc.CC_Grupo_Colaborador__r.Name != 'COPS') {
                    esAdminCOPS = false;
                }
                users.add(gc.CC_Usuario__c);
            }
    
    
            //MAP Id User - lista colaborador en los que se encuentra
            Map<Id, List<CC_Grupo_Colaborador_Contact__c>> mapGC = new Map<Id, List<CC_Grupo_Colaborador_Contact__c>>();
    
    
            List<CC_Grupo_Colaborador_Contact__c> colaboradoresDelUser = [SELECT Id, CC_Usuario__c, SAC_Administrador__c, CC_Grupo_Colaborador__c, CC_Grupo_Colaborador__r.Name
                                                    FROM CC_Grupo_Colaborador_Contact__c 
                                                        WHERE CC_Usuario__c IN: users];
            
            for(CC_Grupo_Colaborador_Contact__c result : colaboradoresDelUser){
                List<CC_Grupo_Colaborador_Contact__c> listadoColabs = new List<CC_Grupo_Colaborador_Contact__c>();
                if(mapGC.containsKey(result.CC_Usuario__c)){
                    listadoColabs = mapGC.get(result.CC_Usuario__c);
                    listadoColabs.add(result);
                    mapGC.put(result.CC_Usuario__c, listadoColabs);
                }
                else{
                    listadoColabs.add(result);
                    mapGC.put(result.CC_Usuario__c, listadoColabs);
                }
            }
    
            PermissionSet ps;
            if(esAdminCOPS) {
                ps = getPermisionSet(PS_AUDITOR);
            } else {
                ps = getPermisionSet(PS_ADMIN_GRUPOS);
            }
            
            List<PermissionSetAssignment> psaDelete = getPermisosUser(users, ps);
            //falta realizar comprobaciones.
            //delete
            List<PermissionSetAssignment> psaDeleteFinal = new List<PermissionSetAssignment>();
            if(!psaDelete.isEmpty()){
                for(PermissionSetAssignment psa : psaDelete){
                    if(mapGC.containsKey(psa.AssigneeId)){
                        List<CC_Grupo_Colaborador_Contact__c> listaGrupos = mapGC.get(psa.AssigneeId);
                        Integer contador = 0;
                        for(CC_Grupo_Colaborador_Contact__c grupo : listaGrupos){
                            if(grupo.SAC_Administrador__c){
                                contador = contador + 1;
                            }
                        }
                        if(contador == 0){
                            //eliminar el registro actual de la lista para evitar su borrado
                            psaDeleteFinal.add(psa);
                        }
                    }
                }
            }

            //insert
            List<PermissionSetAssignment> listaInsert = new List<PermissionSetAssignment>();
            for(CC_Grupo_Colaborador_Contact__c gc : nuevosAdmins){
                PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = gc.CC_Usuario__c); 
                
                if(gc.SAC_Administrador__c){
                    if(mapGC.containsKey(gc.CC_Usuario__c)){
                        List<CC_Grupo_Colaborador_Contact__c> listaGrupos = mapGC.get(gc.CC_Usuario__c);
                        Integer contador = 0;
    
                        for(CC_Grupo_Colaborador_Contact__c grupo : listaGrupos){
                            if(grupo.SAC_Administrador__c && grupo.CC_Grupo_Colaborador__c != gc.CC_Grupo_Colaborador__c){
                                contador = contador + 1;
                            }
                        }
                        if(contador == 0){
                            //insertar el permiso si no hay ninguno, y le corresponda
                            listaInsert.add(psa);
                        }
                    }      
                    
                }
            }
    
            if(!listaInsert.isEmpty()){
                SAC_DatabaseDML.insertListDML(listaInsert, false);
            }
            if(!psaDeleteFinal.isEmpty()){
                SAC_DatabaseDML.deleteListDML(psaDeleteFinal, false);
            }
    
        }
    
    
        public static void insertRecord(List<CC_Grupo_Colaborador_Contact__c> listNew){
         /*****************************************************************
         * Proposito: Método para insertar un Colaborador
         *
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US233800         Luis Mesa    17/06/21       Creación Método
        *****************************************************************/
            List<Id> listIds = new List<Id>();
            for(CC_Grupo_Colaborador_Contact__c gc : listNew){
                listIds.add(gc.Id);
            }
            if(!listIds.isEmpty()){
                insertarUsuario(listIds);
            }
        }
    
        @future
        public static void insertarUsuario(List<Id> listNew){
        /*****************************************************************
         * Proposito: Método para comprobar si hay que insertar un Colaborador con Permisos de Administrador de Grupos SAC
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US233800         Luis Mesa    17/06/21       Creación Método
         * 1.1            US520791         Raúl Santos  07/06/23       Modificación: comprobar si el user ya tiene el PS a insertar antes de insertarlo
        *****************************************************************/
    
            List<CC_Grupo_Colaborador_Contact__c> aInsertar = [SELECT Id, SAC_Administrador__c, CC_Usuario__c
                                                                FROM CC_Grupo_Colaborador_Contact__c
                                                                WHERE Id IN: listNew AND (CC_Grupo_Colaborador__r.RecordTypeId =: RECTYPEPROVEEDORES
                                                                OR CC_Grupo_Colaborador__r.RecordTypeId =: RECTYPETAREAS
                                                                OR CC_Grupo_Colaborador__r.RecordTypeId =: RECTYPELETRADOS) ];
    
            
            PermissionSet ps = getPermisionSet(PS_ADMIN_GRUPOS);
    
            Set<Id> users = new set<Id>();
            for(CC_Grupo_Colaborador_Contact__c gc : aInsertar){
                users.add(gc.CC_Usuario__c);
            }
    
            List<PermissionSetAssignment> listPermisosUser = getPermisosUser(users, ps);
    
            //El usuario no tiene el PS a asignar, luego procedemos a asignarlo
            if(listPermisosUser.isEmpty()){
                List<PermissionSetAssignment> listaInsert = new List<PermissionSetAssignment>();
    
                for(CC_Grupo_Colaborador_Contact__c gc : aInsertar){
                    if(gc.SAC_Administrador__c){
                        //añadir PS
                        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = gc.CC_Usuario__c);       
                        listaInsert.add(psa);
                    }
                }
                if(!listaInsert.isEmpty()){
                    SAC_DatabaseDML.insertListDML(listaInsert, false);
                }
            }
        }
    
        public static void comprobarOwner(List<Case> listNew, Map<Id, Case> mapOld, Group cola, Group colaSupervisores){
        /*****************************************************************
         * Proposito: Método para comprobar si se ha modificado desde el trigger de Case el propietario del caso
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US233800         Luis Mesa    17/06/21       Creación Método
        *****************************************************************/
    
            List<CC_Grupo_Colaborador_Contact__c> colabContact= new List<CC_Grupo_Colaborador_Contact__c>();
            colabContact = [SELECT id
                            FROM CC_Grupo_Colaborador_Contact__c 
                            WHERE CC_Usuario__c=:UserInfo.getUserId()
                            AND CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'COPS'];
    
            if(colabContact.isEmpty()){
    
                List<Case> ownerModificados = new List<Case>();
                String usuarioActual = UserInfo.getUserId();
                for(Case caso : listNew){
                    if(mapOld.containsKey(caso.Id)){
                        if(mapOld.get(caso.Id).OwnerId != caso.OwnerId && usuarioActual != caso.OwnerId){
                            ownerModificados.add(caso);
                        }
                    }
                }
                if(!ownerModificados.isEmpty()){
                    permitirCambiarOwner(ownerModificados, mapOld, cola, colaSupervisores);
                }
            }
        }
    
        public static void permitirCambiarOwner(List<Case> listOwners, Map<Id, Case> mapOld, Group cola, Group colaSupervisores){
        /*****************************************************************
         * Proposito: Método para comprobar si se permite modificar el propietario del caso
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US233800         Luis Mesa    17/06/21       Creación Método
        *****************************************************************/
            String usuarioActual = UserInfo.getUserId();
            List<Id> idGrupoColab = new List<Id>();
            for(Case caso : listOwners){
                idGrupoColab.add(caso.SEG_Grupo__c);
            }
    
            Map<Id, List<CC_Grupo_Colaborador_Contact__c>> mapGrupoCol = new Map<Id, List<CC_Grupo_Colaborador_Contact__c>>();
    
            List<CC_Grupo_Colaborador__c> grupoColab = 
            [SELECT Id, Name
                FROM CC_Grupo_Colaborador__c
                WHERE Id IN: idGrupoColab];
    
            List<CC_Grupo_Colaborador_Contact__c> usersGrupo = 
            [SELECT Id, CC_Usuario__c, SAC_Administrador__c, CC_Grupo_Colaborador__c, SAC_Supervisor__c
                FROM CC_Grupo_Colaborador_Contact__c
                WHERE CC_Grupo_Colaborador__c IN: grupoColab];
    
            if(!usersGrupo.isEmpty()){
                for(CC_Grupo_Colaborador_Contact__c colaborador : usersGrupo){
                    List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
                    if(mapGrupoCol.containsKey(colaborador.CC_Grupo_Colaborador__c)){
                        listaColaboradores = mapGrupoCol.get(colaborador.CC_Grupo_Colaborador__c);
                        listaColaboradores.add(colaborador);
                        mapGrupoCol.put(colaborador.CC_Grupo_Colaborador__c, listaColaboradores);
                    }
                    else{
                        listaColaboradores.add(colaborador);
                        mapGrupoCol.put(colaborador.CC_Grupo_Colaborador__c, listaColaboradores);
                    }
                }    
            } 
            for(Case caso : listOwners){
                if(mapGrupoCol.containsKey(caso.SEG_Grupo__c) && !mapGrupoCol.get(caso.SEG_Grupo__c).isEmpty() && caso.OwnerId != cola.Id && caso.OwnerId != colaSupervisores.Id){
                    Boolean formaParte = false;
                    for(CC_Grupo_Colaborador_Contact__c colaborador : mapGrupoCol.get(caso.SEG_Grupo__c)){
                        if(colaborador.CC_Usuario__c == usuarioActual && (colaborador.SAC_Administrador__c || colaborador.SAC_Supervisor__c)){
                            formaParte = true;
                        }
                    }
                    if(!formaParte){
                        caso.addError('Usted no pertenece a la cola de trabajo, o no es administrador de el mismo.');
                    }
                }
            }
            
            commitChanges(listOwners, mapGrupoCol, cola, colaSupervisores);
        }
    
        public static void commitChanges(List<Case> listOwners, Map<Id, List<CC_Grupo_Colaborador_Contact__c>> mapGrupoCol, Group cola, Group colaSupervisores){
        /*****************************************************************
         * Proposito: Método para validar si no cumple los requisitos el nuevo owner
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US233800         Luis Mesa    17/06/21       Creación Método
        *****************************************************************/
            for(Case caso : listOwners){
                Id identificador = caso.OwnerId;
                List<CC_Grupo_colaborador_Contact__c> listadoGrupo = mapGrupoCol.get(caso.SEG_Grupo__c);
                if(listadoGrupo != null){
                    Boolean resultado = false;
                    for(CC_Grupo_Colaborador_Contact__c colaborador : listadoGrupo){
                        if(colaborador.CC_Usuario__c == identificador || identificador == cola.Id || identificador == colaSupervisores.Id ){
                            resultado = true;
                        }
                    }
                    if(!resultado){
                        caso.addError('El usuario seleccionado no pertenece a la cola de trabajo.');
                    }
                }
            }
    
        }
    }