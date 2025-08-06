/**
*   @description SEG_MetodosComunes
*/
public without sharing class SEG_SincronizarGrupoHelper {

    /**
     * @description   Método para sincronizar grupos con CaseTeam.
     * @param listadoGrupos -> Listado de grupos a sincronizar.
     */    
    static public void sincronizarGruposACaseTeamBulk(List<ID> listadoGrupos)
    {
        if (listadoGrupos == null)
        {
            return;
        }
        
        Integer iErrorDML = 0;
        
        try
        {             
            // Preparar la búsqueda de grupos ya existentes.
            ID recordTypeSEG = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
            List<ID> listadoGruposActivos = new List<ID>();
            List<String> listadoGruposABuscarName = new List<String>();
            List<String> listadoGruposABuscarDescription = new List<String>();
            Map<String,String> mapGruposInactivos = new Map<String,String>();
            List<CaseTeamTemplate> actualizarNombreCaseTeam = new List<CaseTeamTemplate>();
            for (CC_Grupo_Colaborador__c grupoTratamiento : [SELECT Id, Name, SEG_Inactivo__c, SEG_EquipoCaso__c 
                                                             FROM CC_Grupo_Colaborador__c
                                                             WHERE Id IN :listadoGrupos
                                                             AND RecordTypeId = :recordTypeSEG])
            {
                listadoGruposABuscarName.add(grupoTratamiento.Name);
                listadoGruposABuscarDescription.add(grupoTratamiento.Id);
                if (!grupoTratamiento.SEG_Inactivo__c)
                {
                    listadoGruposActivos.add(grupoTratamiento.Id);
                }else{
                    mapGruposInactivos.put(grupoTratamiento.Name + '##' + grupoTratamiento.Id, grupoTratamiento.Id);
                }
                
                if (String.isNotBlank(grupoTratamiento.SEG_EquipoCaso__c))
                {
                    CaseTeamTemplate equipoUpdate = new CaseTeamTemplate();
                    equipoUpdate.Id = grupoTratamiento.SEG_EquipoCaso__c;
                    equipoUpdate.Name = grupoTratamiento.Name;
                    actualizarNombreCaseTeam.add(equipoUpdate);
                }
            }
            
            // Sincronizar el nombre del CaseTeam.
            if (!actualizarNombreCaseTeam.isEmpty())
            {
                try{
	                update actualizarNombreCaseTeam;
                }catch(Exception e){
                    iErrorDML = 1;
                    String sDescError = 'Error actualizando el nombre del equipo de casos. Verifique con el administrador del sistema que no existe uno con el mismo nombre.';
                    sDescError = sDescError + ' Detalle error: ' + e.getMessage();
                    throw new DmlException(sDescError, e);
                }
            }
            
            // Buscar los equipos de Caso ya existentes.
            Map<String,CaseTeamTemplate> mapEquiposExistentes = new Map<String,CaseTeamTemplate>();
            List<ID> caseTeamTemplateExistentes = new List<ID>();
            Map<String,String> conversionIdentificadorGrupoEquipo = new Map<String,String>();
            for (CaseTeamTemplate equipoCaso : [SELECT Id, Name, Description
                                               FROM CaseTeamTemplate
                                               WHERE Name IN :listadoGruposABuscarName AND Description IN :listadoGruposABuscarDescription])
            {            
                // Tratamiento para inactivar equipos de grupo.
                if (mapGruposInactivos.get(equipoCaso.Name + '##' + equipoCaso.Description) != null)
                {
                    mapGruposInactivos.put(equipoCaso.Name + '##' + equipoCaso.Description, equipoCaso.Id);
                }else{
                    mapEquiposExistentes.put (equipoCaso.Name + '##' + equipoCaso.Description, equipoCaso);
                    caseTeamTemplateExistentes.add(equipoCaso.Id);
                    conversionIdentificadorGrupoEquipo.put(equipoCaso.Id, equipoCaso.Name + '##' + equipoCaso.Description);
                }
            }
            
            // Buscar los miembros de equipo ya existentes.
            Map<String,CaseTeamTemplateMember> mapMiembrosEquipoExistentes = new Map<String,CaseTeamTemplateMember>();
            for (CaseTeamTemplateMember miembroEquipoCaso : [SELECT Id, MemberId, TeamTemplateId
                                                            FROM CaseTeamTemplateMember
                                                            WHERE TeamTemplateId IN :caseTeamTemplateExistentes])
            {
                String sClaveMiembro = conversionIdentificadorGrupoEquipo.get(miembroEquipoCaso.TeamTemplateId);
                mapMiembrosEquipoExistentes.put(sClaveMiembro + '##' + miembroEquipoCaso.MemberId, miembroEquipoCaso);
            }
            caseTeamTemplateExistentes.clear();
            
            // Recuperar configuración parámetros.
            Map<String,SEG_Parametros__mdt> mapParametrosROL = SEG_MetodosComunes.recuperarParametrosProceso ('Sincronización grupos <--> equipos');
            Map<String,String> conversionPickListNameRol = new Map<String,String>();
            for (String sClaveParam : mapParametrosROL.keySet())
            {
                conversionPickListNameRol.put(mapParametrosROL.get(sClaveParam).MasterLabel, mapParametrosROL.get(sClaveParam).SEG_Valor__c);
                
            }
            mapParametrosROL.clear();
            
            // Recuperar IDs roles equipos que están parametrizados.
            Map<String,String> conversionNameRolId = new Map<String,String>();
            for (CaseTeamRole rolTeam : [SELECT Id, Name FROM CaseTeamRole WHERE Name IN :conversionPickListNameRol.values()])
            {
                conversionNameRolId.put(rolTeam.Name, rolTeam.Id);
            }
            
            // Preparar conversión rol directa.
            for (String sClavePick : conversionPickListNameRol.keySet())
            {
                String sValorPick = conversionPickListNameRol.get(sClavePick);
                if (conversionNameRolId.get(sValorPick) != null)
                {
                    conversionPickListNameRol.put(sClavePick, conversionNameRolId.get(sValorPick));
                }
            }
            conversionNameRolId.clear();
            
            // Tratamiento de los miembros del Grupo de Colaborador para sincronizar con CaseTeam.
            List<CaseTeamTemplate> listadoCaseTemplatesNew = new List<CaseTeamTemplate>();
            List<CaseTeamTemplateMember> listadoMiembrosEquipoNew = new List<CaseTeamTemplateMember>();
            List<CaseTeamTemplateMember> listadoMiembrosEquipoUpdate = new List<CaseTeamTemplateMember>();
            Map<String,List<CaseTeamTemplateMember>> mapMiembrosEquipoPendienteNewGrupo = new Map<String,List<CaseTeamTemplateMember>>();    
            for (CC_Grupo_Colaborador__c grupoTratamiento : [SELECT Id, Name, RecordTypeId, (Select Id, CC_Usuario__c, SEG_TipodeAcceso__c FROM Colaboradores__r) 
                                                             FROM CC_Grupo_Colaborador__c
                                                             WHERE Id IN :listadoGruposActivos])
            {                
                if (mapEquiposExistentes.get(grupoTratamiento.Name + '##' + grupoTratamiento.Id) == null)
                {            
                    // Nuevo equipo de Caso.
                    CaseTeamTemplate equipoCaso = new CaseTeamTemplate();
                    equipoCaso.Name = grupoTratamiento.Name;
                    equipoCaso.Description = grupoTratamiento.Id;
                    listadoCaseTemplatesNew.add(equipoCaso);
                    
                    List<CaseTeamTemplateMember> listadoMiembrosEquipo = new List<CaseTeamTemplateMember>();
                    for (CC_Grupo_Colaborador_Contact__c usuarioGrupo : grupoTratamiento.Colaboradores__r)
                    {
                        CaseTeamTemplateMember miembroEquipo = new CaseTeamTemplateMember();
                        miembroEquipo.MemberId = usuarioGrupo.CC_Usuario__c;
                        miembroEquipo.TeamRoleId = conversionPickListNameRol.get(usuarioGrupo.SEG_TipodeAcceso__c);
                        listadoMiembrosEquipo.add(miembroEquipo);
                    }
                    mapMiembrosEquipoPendienteNewGrupo.put(grupoTratamiento.Name, listadoMiembrosEquipo);
                }else{
                    // Equipo de caso existente. Preparar los nuevos miembros a insertar.
                    for (CC_Grupo_Colaborador_Contact__c usuarioGrupo : grupoTratamiento.Colaboradores__r)
                    {
                        if (mapMiembrosEquipoExistentes.get(grupoTratamiento.Name + '##' + grupoTratamiento.Id + '##' + usuarioGrupo.CC_Usuario__c) == null)
                        {
                            CaseTeamTemplateMember miembroEquipo = new CaseTeamTemplateMember();
                            miembroEquipo.TeamTemplateId = mapEquiposExistentes.get(grupoTratamiento.Name + '##' + grupoTratamiento.Id).Id;
                            miembroEquipo.MemberId = usuarioGrupo.CC_Usuario__c;
                            miembroEquipo.TeamRoleId = conversionPickListNameRol.get(usuarioGrupo.SEG_TipodeAcceso__c);
                            listadoMiembrosEquipoNew.add(miembroEquipo);
                        }else{
                            // Actualizar miembro.
                            CaseTeamTemplateMember miembroEquipo = new CaseTeamTemplateMember();
                            miembroEquipo.Id = mapMiembrosEquipoExistentes.get(grupoTratamiento.Name + '##' + grupoTratamiento.Id + '##' + usuarioGrupo.CC_Usuario__c).Id;
                            miembroEquipo.TeamRoleId = conversionPickListNameRol.get(usuarioGrupo.SEG_TipodeAcceso__c);
                            listadoMiembrosEquipoUpdate.add(miembroEquipo);
                        }
                        
                        // Eliminar al miembro de equipo tratado.
                        mapMiembrosEquipoExistentes.remove(grupoTratamiento.Name + '##' + grupoTratamiento.Id + '##' + usuarioGrupo.CC_Usuario__c);
                    }
                }
            }
            
            // Borrar los miembros de equipo restantes (no tratados), ya que no están en el grupo.
            if (!mapMiembrosEquipoExistentes.isEmpty())
            {                
                try{
	                delete mapMiembrosEquipoExistentes.values();
                }catch(Exception e){
                    iErrorDML = 1;
                    String sDescError = 'Error al eliminar del equipo de casos los usuarios que no se han definido en el grupo.';
                    sDescError = sDescError + ' Detalle error: ' + e.getMessage();
                    throw new DmlException(sDescError, e);
                }
            }
            
            // Borrar los miembros de grupos inactivos.
            if (!mapGruposInactivos.isEmpty())
            {
                List<CaseTeamTemplateMember> quitarMiembrosGruposInactivos = new List<CaseTeamTemplateMember>();
                for (CaseTeamTemplateMember miembroEquipoCaso : [SELECT Id, MemberId, TeamTemplateId
                                                                 FROM CaseTeamTemplateMember
                                                                 WHERE TeamTemplateId IN :mapGruposInactivos.values()])
                {
                    quitarMiembrosGruposInactivos.add(miembroEquipoCaso);
                }            
                if (!quitarMiembrosGruposInactivos.isEmpty())
                {
                    try{
                        delete quitarMiembrosGruposInactivos;
                    }catch(Exception e){
                        iErrorDML = 1;
                        String sDescError = 'Error al eliminar los miembros del equipo de casos que se ha inactivado.';
                        sDescError = sDescError + ' Detalle error: ' + e.getMessage();
                        throw new DmlException(sDescError, e);
                    }
                }
            }
            
            // Crear los nuevos Case Teams.            
            try{
                insert listadoCaseTemplatesNew;
            }catch(Exception e){
                iErrorDML = 1;
                String sDescError = 'Error al crear el nuevo equipo de casos. Verifique con el administrador del sistema que no existe uno con el mismo nombre.';
                sDescError = sDescError + ' Detalle error: ' + e.getMessage();
                throw new DmlException(sDescError, e);
            }
            
            // Actualizar el Id del CaseTeam para los miembros nuevos.
            for (CaseTeamTemplate equipoCaso : listadoCaseTemplatesNew)
            {
                for (CaseTeamTemplateMember miembro : mapMiembrosEquipoPendienteNewGrupo.get(equipoCaso.Name))
                {
                    miembro.TeamTemplateId = equipoCaso.Id;
                    listadoMiembrosEquipoNew.add(miembro);
                }
            }
            
            // Crear los miembros del Case Team.
            try{
                insert listadoMiembrosEquipoNew;
            }catch(Exception e){
                iErrorDML = 1;
                String sDescError = 'Error al crear los nuevos miembros en el equipo de casos. Verifique con el administrador del sistema que no exista el miembro ya creado.';
                sDescError = sDescError + ' Detalle error: ' + e.getMessage();
                throw new DmlException(sDescError, e);
            }
            
            // Actualizar los miembros del Case Team. Cambio de rol.
            try{
                update listadoMiembrosEquipoUpdate;
            }catch(Exception e){
                iErrorDML = 1;
                String sDescError = 'Error al actualizar los miembros en el equipo de casos. Verifique con el administrador del sistema el problema ocurrido.';
                sDescError = sDescError + ' Detalle error: ' + e.getMessage();
                throw new DmlException(sDescError, e);
            }
            
        }catch(Exception e){
            
            // Relanzamos la excepción para cancelar la transacción.
			if (iErrorDML == 0)
            {
                String sErrorGen = 'Error durante el proceso de sincronización.';
                sErrorGen = sErrorGen + ' Detalle: ' + e.getMessage();
                throw new DmlException(sErrorGen, e);
            }else{
                throw e;
            }          
        }
    }
    
    /**
     * @description   Método para sincronizar el CaseTeam Id con el grupo. 
     * @param listadoGrupos -> Listado de grupos a sincronizar.
     */    
    static public void sincronizarCaseTeamIdBulk(List<ID> listadoGrupos)
    {
        if (listadoGrupos == null)
        {
            return;
        }
         
        // Preparar la búsqueda de grupos ya existentes.
        ID recordTypeSEG = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        List<String> listadoGruposABuscarName = new List<String>();
        List<String> listadoGruposABuscarDescription = new List<String>();
        for (CC_Grupo_Colaborador__c grupoTratamiento : [SELECT Id, Name, SEG_Inactivo__c, SEG_EquipoCaso__c 
                                                         FROM CC_Grupo_Colaborador__c
                                                         WHERE Id IN :listadoGrupos
                                                         AND RecordTypeId = :recordTypeSEG])
        {
            listadoGruposABuscarName.add(grupoTratamiento.Name);
            listadoGruposABuscarDescription.add(grupoTratamiento.Id);
        }
        
        // Buscar los equipos de Caso ya existentes.
        Map<String,CaseTeamTemplate> mapEquiposExistentes = new Map<String,CaseTeamTemplate>();
        List<CC_Grupo_Colaborador__c> listadoGruposActualizar = new List<CC_Grupo_Colaborador__c>();
        for (CaseTeamTemplate equipoCaso : [SELECT Id, Name, Description
                                           FROM CaseTeamTemplate
                                           WHERE Name IN :listadoGruposABuscarName AND Description IN :listadoGruposABuscarDescription])
        {
            // Preparar actualización campo ID equipo en el grupo.
            CC_Grupo_Colaborador__c grupoUpdate = new CC_Grupo_Colaborador__c();
            grupoUpdate.Id = equipoCaso.Description;
            grupoUpdate.SEG_EquipoCaso__c = equipoCaso.Id;
            grupoUpdate.SEG_EstadoSincronizacion__c = 'Sincronizado';
            listadoGruposActualizar.add(grupoUpdate);
        }
        
        if (!listadoGruposActualizar.isEmpty())
        {
            update listadoGruposActualizar;
        }
    }

    /**
     * @description   Método para validar que los usuarios de un grupo son compatibles con la tipología del mismo a partir de cambios en el grupo.
		Usado en el Trigger BU de modificación de un grupo.
     * @param mapGrupos -> Mapa de grupos con los nuevos valores.
     * @param mapGruposOld -> Mapa de grupos con los valores antes de guardar.
     */ 
    public static void verificarGrupoSegmentos(Map<ID, CC_Grupo_Colaborador__c> mapGrupos, Map<ID, CC_Grupo_Colaborador__c> mapGruposOld)
    {
        if (mapGrupos == null || mapGruposOld == null)
        {
            return;
        }
        
		// Sólo tratar los colaboradores de grupos de Segmentos.
		ID recordTypeSEG = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        Map<ID,String> grupoSegmentosTipo = new Map<ID,String>();
        for (ID sClaveGrupo : mapGrupos.keySet())
        {
            if (recordTypeSEG == mapGrupos.get(sClaveGrupo).RecordTypeId)
            {
                System.debug(mapGrupos.get(sClaveGrupo).SEG_Tipologia__c);
                System.debug(mapGruposOld.get(sClaveGrupo).SEG_Tipologia__c);
                if (mapGrupos.get(sClaveGrupo).SEG_Tipologia__c != mapGruposOld.get(sClaveGrupo).SEG_Tipologia__c)
                {
                    grupoSegmentosTipo.put(sClaveGrupo, mapGrupos.get(sClaveGrupo).SEG_Tipologia__c);
                }
            }
        }
        
        // Si hay grupos de Segmentos.
        if (!grupoSegmentosTipo.isEmpty())
        {
            // Recuperar solo los colaboradores de grupos de Segmentos.
            Map<ID,ID> mapColaboradorUsuario = new Map<ID,ID>();
            Map<ID,ID> mapColaboradoresGrupo = new Map<ID,ID>();
            for (CC_Grupo_Colaborador_Contact__c colaborador : [SELECT Id, CC_Usuario__c, CC_Grupo_Colaborador__c
                                                  FROM CC_Grupo_Colaborador_Contact__c 
                                                  WHERE CC_Grupo_Colaborador__c IN :grupoSegmentosTipo.keySet()])
            {
                mapColaboradorUsuario.put(colaborador.Id, colaborador.CC_Usuario__c);
                mapColaboradoresGrupo.put(colaborador.Id, colaborador.CC_Grupo_Colaborador__c);
            }
            
            // Recuperar los datos del usuario asociado.
            Map<ID,String> usuarioConTipo = new Map<ID,String>();
            for (User usuario : [SELECT Id, SEG_Tipo_usuario_SEG__c FROM User WHERE Id IN :mapColaboradorUsuario.values()])
            {
                usuarioConTipo.put(usuario.Id, usuario.SEG_Tipo_usuario_SEG__c);
            }
            
            String sValorParam = SEG_MetodosComunes.recuperarParametrosValor('SEG_GruposMixtos');
			List<String> gruposMixtos = new List<String>();
            if (String.isNotBlank(sValorParam))
            {
                gruposMixtos = sValorParam.split(';');
            }
            
            sValorParam = SEG_MetodosComunes.recuperarParametrosValor('SEG_GruposCSO');
			List<String> gruposCSO = new List<String>();
            if (String.isNotBlank(sValorParam))
            {
                gruposCSO = sValorParam.split(';');
            }
            
            sValorParam = SEG_MetodosComunes.recuperarParametrosValor('SEG_GruposBO');
			List<String> gruposBO = new List<String>();
            if (String.isNotBlank(sValorParam))
            {
                gruposBO = sValorParam.split(';');
            }
            
            // Recorrer todos los colaboradores y validar el tipo de usuario con el grupo.
            for (ID colaboradorId : mapColaboradorUsuario.keySet())
            {
                ID grupoColaboradorId = mapColaboradoresGrupo.get(colaboradorId);
                if (grupoSegmentosTipo.get(grupoColaboradorId) != null)
                {
                    // Usuario del grupo de segmentos. Verificar los tipos que no son Mixtos.
                    if (!gruposMixtos.contains(grupoSegmentosTipo.get(grupoColaboradorId)))
                    {
                        String sTipoGrupo = grupoSegmentosTipo.get(grupoColaboradorId);
                        
                        // Convertir el tipo de grupo.
                        if (gruposBO.contains(sTipoGrupo))
                        {
                            sTipoGrupo = 'BO';
                        }else if (gruposCSO.contains(sTipoGrupo))
                        {
                            sTipoGrupo = 'CSO';
                        }
                        
                        System.debug('Grupos Cambio');
                        System.debug(sTipoGrupo);
                        System.debug(usuarioConTipo.get(mapColaboradorUsuario.get(colaboradorId)));
                        System.debug('<<<<Grupos Cambio');
                        
                        if (sTipoGrupo != usuarioConTipo.get(mapColaboradorUsuario.get(colaboradorId)))
                        {
                            // Usuario no permitido en el grupo.
                            String sError = 'No se puede cambiar el tipo de grupo a ' + grupoSegmentosTipo.get(grupoColaboradorId);
                            sError = sError + ', el grupo contiene usuarios que no son de esta tipología.';
                            mapGrupos.get(grupoColaboradorId).addError(sError);
                        }
                    }
                }
            }
        }
    }
    
    /**
     * @description   Método para validar que los usuarios de un grupo son compatibles con la tipología del mismo.
		Usado en el Trigger AI de adición de usuarios.
     * @param mapUsuarios -> Mapa de usuarios a verificar su tipología.
     */ 
    public static void verificarUsuarioGrupoSegmentos(Map<ID, CC_Grupo_Colaborador_Contact__c> mapUsuarios)
    {
        if (mapUsuarios == null)
        {
            return;
        }
        
		// Sólo tratar los colaboradores de grupos de Segmentos.
		ID recordTypeSEG = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
  		
        // Recuperar tipo de grupos.
        Map<ID,String> grupoConTipo = new Map<ID,String>();
        List<ID> grupoAsociadoUsuario = new List<ID> ();
        for (String sClaveUsuario : mapUsuarios.keySet())
        {
            grupoAsociadoUsuario.add(mapUsuarios.get(sClaveUsuario).CC_Grupo_Colaborador__c);
        }
        
        if (!grupoAsociadoUsuario.isEmpty())
        {
            for (CC_Grupo_Colaborador__c grupo : [SELECT Id, RecordTypeId, SEG_Tipologia__c 
                                                  FROM CC_Grupo_Colaborador__c 
                                                  WHERE ID IN :grupoAsociadoUsuario
                                                  AND RecordTypeId = :recordTypeSEG])
            {
                grupoConTipo.put(grupo.Id, grupo.SEG_Tipologia__c);
            }
        }
        
        // Si hay grupos de Segmentos.
        if (!grupoConTipo.isEmpty())
        {
            // Recuperar solo los colaboradores de grupos de Segmentos.
            List<ID> busquedaUsuarios = new List<ID>();
            for (CC_Grupo_Colaborador_Contact__c colaborador : [SELECT Id, CC_Usuario__c
                                                  FROM CC_Grupo_Colaborador_Contact__c 
                                                  WHERE ID IN :mapUsuarios.keySet()
                                                  AND CC_Grupo_Colaborador__c IN :grupoConTipo.keySet()])
            {
                busquedaUsuarios.add(colaborador.CC_Usuario__c);
            }
            
            // Recuperar los datos del usuario asociado.
            Map<ID,String> usuarioConTipo = new Map<ID,String>();
            for (User usuario : [SELECT Id, SEG_Tipo_usuario_SEG__c FROM User WHERE Id IN :busquedaUsuarios])
            {
                usuarioConTipo.put(usuario.Id, usuario.SEG_Tipo_usuario_SEG__c);
            }
            
            String sValorParam = SEG_MetodosComunes.recuperarParametrosValor('SEG_GruposMixtos');
			List<String> gruposMixtos = new List<String>();
            if (String.isNotBlank(sValorParam))
            {
                gruposMixtos = sValorParam.split(';');
            }
            
            sValorParam = SEG_MetodosComunes.recuperarParametrosValor('SEG_GruposCSO');
			List<String> gruposCSO = new List<String>();
            if (String.isNotBlank(sValorParam))
            {
                gruposCSO = sValorParam.split(';');
            }
            
            sValorParam = SEG_MetodosComunes.recuperarParametrosValor('SEG_GruposBO');
			List<String> gruposBO = new List<String>();
            if (String.isNotBlank(sValorParam))
            {
                gruposBO = sValorParam.split(';');
            }
            
            // Recorrer los colaboradores entrantes en el trigger.
            for (String sClaveUsuario : mapUsuarios.keySet())
            {
                ID grupoColaboradorId = mapUsuarios.get(sClaveUsuario).CC_Grupo_Colaborador__c;
                if (grupoConTipo.get(grupoColaboradorId) != null)
                {
                    // Usuario del grupo de segmentos. Verificar los tipos que no son Mixtos.
                    if (!gruposMixtos.contains(grupoConTipo.get(grupoColaboradorId)))
                    {
                        String sTipoGrupo = grupoConTipo.get(grupoColaboradorId);
                        
                        // Convertir el tipo de grupo.
                        if (gruposBO.contains(sTipoGrupo))
                        {
                            sTipoGrupo = 'BO';
                        }else if (gruposCSO.contains(sTipoGrupo))
                        {
                            sTipoGrupo = 'CSO';
                        }
                        
                        
                        if (sTipoGrupo != usuarioConTipo.get(mapUsuarios.get(sClaveUsuario).CC_Usuario__c))
                        {
                            // Usuario no permitido en el grupo.
                            String sError = 'No se puede incluir el usuario en el grupo, ya que no es de tipo ' + grupoConTipo.get(grupoColaboradorId);
                            mapUsuarios.get(sClaveUsuario).addError(sError);
                        }
                    }
                }
            }
        }
    }
    /*
		Método auxiliar para marcar el estado de grupo Sincronizado / No Sincronizado a partir del grupo Id.
    */
    static private void marcarEstadoSincronizacionGrupo(List<ID> listadoGrupos, String sEstado)
    {
        if (listadoGrupos == null || String.isBlank(sEstado))
        {
            return;
        }
        
        List<CC_Grupo_Colaborador__c> gruposActualizar = new List<CC_Grupo_Colaborador__c>();
        for (ID grupoId : listadoGrupos)
        {
            CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();
            grupo.Id = grupoId;
            grupo.SEG_EstadoSincronizacion__c = sEstado;
            gruposActualizar.add(grupo);
        }
        
        if (!gruposActualizar.isEmpty())
        {
            update gruposActualizar;
        }
    }
    
    /**
     * @description   Método auxiliar para marcar el estado de grupo Sincronizado / No Sincronizado a partir del colaborador Id.
     * @param listadoUsuarios -> Listado de usuarios a comprobar su sincronización.
     */ 
    public static void actualizarUsuarioSegmentos(List<CC_Grupo_Colaborador_Contact__c> listadoUsuarios)
    {
        if (listadoUsuarios == null)
        {
            return;
        }
        
		// Sólo tratar los colaboradores de grupos de Segmentos.
		ID recordTypeSEG = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        List<ID> grupoAsociadoUsuario = new List<ID> ();
        for (CC_Grupo_Colaborador_Contact__c colaborador : listadoUsuarios)
        {
            grupoAsociadoUsuario.add(colaborador.CC_Grupo_Colaborador__c);
        }
        
        if (!grupoAsociadoUsuario.isEmpty())
        {
            List<ID> gruposNoSincronizar = new List<ID>();
            for (CC_Grupo_Colaborador__c grupo : [SELECT Id, RecordTypeId 
                                                  FROM CC_Grupo_Colaborador__c 
                                                  WHERE ID IN :grupoAsociadoUsuario
                                                  AND RecordTypeId = :recordTypeSEG])
            {
                gruposNoSincronizar.add(grupo.Id);
            }
            
			marcarEstadoSincronizacionGrupo (gruposNoSincronizar, 'No sincronizado');
        }        
    }
}