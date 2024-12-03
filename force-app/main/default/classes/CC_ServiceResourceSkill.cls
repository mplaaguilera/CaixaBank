public class CC_ServiceResourceSkill {

    @future
    public static void asignarAgentesStopGoQueue(List<Id> newSkillSessionIdList)
	{
		List<GroupMember> listaColasAgentes = new List<GroupMember>();
        Set<String> listaUsuariosServResoId = new Set<String>();
        Set<Id> listaUsuariosId = new Set<Id>();
        Set<Id> skillIdList = new Set<Id>();
        
        if (newSkillSessionIdList != null && !newSkillSessionIdList.isEmpty())
        {
            //En el metadato guardamos los tipos de chat posibles y los idiomas para generar el label de la cola que necesitamos buscar para asignar al agente
            List<CC_Chat_Empleados_Stop_Go__mdt> listaValoresIdentificacion = [SELECT CC_Opciones__c, MasterLabel FROM CC_Chat_Empleados_Stop_Go__mdt];
            Map<String,String> tipoChatMap = new Map<String,String>();
            Map<String,String> idiomaMap = new Map<String,String>();
            Map<String,String> proveedorMap = new Map<String,String>();

            if (listaValoresIdentificacion != null && !listaValoresIdentificacion.isEmpty())
            {
                for(CC_Chat_Empleados_Stop_Go__mdt valor : listaValoresIdentificacion)
                {
                    if (valor.MasterLabel == 'TipoChat')
                    {
                        List<String> valoresTipoChat = valor.CC_Opciones__c.split(';');
                        if (valoresTipoChat != null && !valoresTipoChat.isEmpty())
                        {
                            for(String opcion : valoresTipoChat)
                            {
                                tipoChatMap.put(opcion, ('CC_' + opcion));
                            }
                        }
                    }
                    else if(valor.MasterLabel == 'Idioma')
                    {
                        List<String> valoresIdiomaChat = valor.CC_Opciones__c.split(';');
                        if (valoresIdiomaChat != null && !valoresIdiomaChat.isEmpty())
                        {
                            for(String opcion : valoresIdiomaChat)
                            {
                                idiomaMap.put(opcion.toUpperCase(), (opcion.toUpperCase() + '_stopGo'));
                            }
                        }
                    }else if(valor.MasterLabel == 'Proveedor')
                    {
                    	List<String> valoresProveedorChat = valor.CC_Opciones__c.split(';');
                        for(String opcion : valoresProveedorChat)
                        {
                            proveedorMap.put(opcion, ('_' + opcion));
                        }
                    }
                }
            }

            System.debug('NMA proveedorMap ' + proveedorMap.size());
            System.debug('NMA proveedorMap ' + proveedorMap);

            //Obtenemos las sesiones de skills que se han creado nuevas, para buscar los agentes y los skills
            List<CC_SkillHistory__c> listaSkillSession = [SELECT Id, CC_User__c, CC_SkillId__c FROM CC_SkillHistory__c WHERE Id IN :newSkillSessionIdList];
            
            if (listaSkillSession != null && !listaSkillSession.isEmpty())
            {
                for (CC_SkillHistory__c sesion: listaSkillSession)
                {
                    String idUsuario = (string)(sesion.CC_User__c);
                    listaUsuariosServResoId.add(idUsuario.substring(0,15));
                    listaUsuariosId.add(sesion.CC_User__c);
                }
                //Buscamos todos los skills que tiene cada agente
                List<ServiceResourceSkill> serviceResSkillList = [SELECT Id, CC_AgenteId__c, SkillId FROM ServiceResourceSkill WHERE CC_AgenteId__c IN :listaUsuariosServResoId];

                //Guardamos la lista de skills asignados a cada agente
                Map<Id,List<Id>> skillUserMap = new Map<Id,List<Id>>();
                if (serviceResSkillList != null && !serviceResSkillList.isEmpty())
                {
                    for (ServiceResourceSkill serviceResSkill : serviceResSkillList)
                    {
                        List<Id> userSkillsList = new List<Id>();
                        //Guardamos todos los skills que hay para cada agente
                        /*if (skillUserMap.isEmpty())
                        {
                            userSkillsList.add(serviceResSkill.SkillId);
                            skillUserMap.put(serviceResSkill.CC_AgenteId__c, userSkillsList);
                        } */
                        if (!skillUserMap.isEmpty() && skillUserMap.get(serviceResSkill.CC_AgenteId__c) != null)
                        {
                            userSkillsList = skillUserMap.get(serviceResSkill.CC_AgenteId__c);
                            if (!userSkillsList.contains(serviceResSkill.SkillId))
                            {
                                userSkillsList.add(serviceResSkill.SkillId);
                                skillUserMap.put(serviceResSkill.CC_AgenteId__c, userSkillsList);
                            }
                        }
                        else
                        {
                            userSkillsList.add(serviceResSkill.SkillId);
                            skillUserMap.put(serviceResSkill.CC_AgenteId__c, userSkillsList);
                        }
                        //Guardamos todos los skills para luego obtener su DeveloperName
                        skillIdList.add(serviceResSkill.SkillId);
                    }
                }

                //Buscamos los skills y su DeveloperName
                Map<Id,Skill> skillNameMap = new Map<Id,Skill>([SELECT Id, DeveloperName FROM Skill WHERE Id IN :skillIdList]);
                
                //Buscamos todas las colas que sean para enrutar chats
                List<Group> queueList = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND QueueRoutingConfigId <> Null];
             

                //Buscamos las colas a las que pertenecen los agentes, para no repetir la asignación
                List<GroupMember> queueMemberList = [SELECT GroupId, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId IN :listaUsuariosId AND Group.QueueRoutingConfigId <> null];
              
                Map<Id,List<String>> queueAgentMap = new Map<Id,List<String>>();
                if (queueMemberList != null && !queueMemberList.isEmpty())
                {
                    for (GroupMember miembro : queueMemberList)
                    {
                        List<Id> userSkillsList = new List<Id>();
                        List<String> miembroQueueList = new List<String>();
                        //Guardamos todos los skills que hay para cada agente
                        /*if (queueAgentMap.isEmpty())
                        {
                            miembroQueueList.add(miembro.Group.DeveloperName);
                            queueAgentMap.put(miembro.UserOrGroupId, miembroQueueList);
                        } 
                        else */
                        if (!queueAgentMap.isEmpty() && queueAgentMap.get(miembro.UserOrGroupId) != null)
                        {
                            miembroQueueList = queueAgentMap.get(miembro.UserOrGroupId);
                            if (!miembroQueueList.contains(miembro.Group.DeveloperName))
                            {
                                miembroQueueList.add(miembro.Group.DeveloperName);
                                queueAgentMap.put(miembro.UserOrGroupId, miembroQueueList);
                            }
                        }
                        else
                        {
                            miembroQueueList.add(miembro.Group.DeveloperName);
                            queueAgentMap.put(miembro.UserOrGroupId, miembroQueueList);
                        }
                    }
                }
    
                if (queueList != null && !queueList.isEmpty() && skillNameMap!= null && !skillNameMap.isEmpty() && skillUserMap != null && !skillUserMap.isEmpty() && !tipoChatMap.isEmpty() && !idiomaMap.isEmpty())
                {
                    Map<Id, CC_AgenteSkillBuscar> agenteSkillsBuscarMap = new Map<Id, CC_AgenteSkillBuscar>();
                    for (Id idAgente : skillUserMap.keySet())
                    {
                        CC_AgenteSkillBuscar agenteSkillsBuscar = new CC_AgenteSkillBuscar();
                        Set<String> listaSkillsNombres = new Set<String>();
                        agenteSkillsBuscar.agenteId = idAgente;
                        List<Id> userSkillsList = new List<Id>();
                        userSkillsList = skillUserMap.get(idAgente);
                        for (Id idSkillAgente : userSkillsList)
                        {
                            Skill skillName = skillNameMap.get(idSkillAgente);
                            if (skillName != null && skillName.DeveloperName != null)
                            {
                                if (tipoChatMap.get(skillName.DeveloperName) != null)
                                {
                                    if (agenteSkillsBuscar.tipoChatSkill != null)
                                    {
                                        agenteSkillsBuscar.tipoChat2Skill = tipoChatMap.get(skillName.DeveloperName);
                                    }    
                                    else 
                                    {
                                        agenteSkillsBuscar.tipoChatSkill = tipoChatMap.get(skillName.DeveloperName);
                                    }
                                }
                                else if(idiomaMap.get(skillName.DeveloperName) != null)
                                {
                                    if (String.isBlank(agenteSkillsBuscar.idiomaSkill))
                                    {
                                        agenteSkillsBuscar.idiomaSkill = idiomaMap.get(skillName.DeveloperName);
                                    }
                                    else 
                                    {
                                        agenteSkillsBuscar.idioma2Skill = idiomaMap.get(skillName.DeveloperName);
                                    }
                                }
                                else if(proveedorMap.get(skillName.DeveloperName) != null)
                                {
                                    if (String.isBlank(agenteSkillsBuscar.proveedorSkill))
                                    {
                                        agenteSkillsBuscar.proveedorSkill = proveedorMap.get(skillName.DeveloperName);
                                    }
                                    else 
                                    {
                                        agenteSkillsBuscar.proveedor2Skill = proveedorMap.get(skillName.DeveloperName);
                                    }
                                }
                                else 
                                {
                                    listaSkillsNombres.add(skillName.DeveloperName);
                                }
                            }  
                        }

                        if (!listaSkillsNombres.isEmpty())
                        {
                            agenteSkillsBuscar.listaSkillsNombres = listaSkillsNombres;
                        }
                        agenteSkillsBuscarMap.put(idAgente, agenteSkillsBuscar);
                    }
                    if (!agenteSkillsBuscarMap.isEmpty())
                    {
                        for (CC_AgenteSkillBuscar agenteSkillsBuscar : agenteSkillsBuscarMap.values())
                        {
                            System.debug('NMA agenteSkillsBuscar ' + agenteSkillsBuscar);
                            Set<String> skillsABuscarList = agenteSkillsBuscar.listaSkillsNombres;
                            if(skillsABuscarList != null && !skillsABuscarList.isEmpty())
                            {
                                for (String skillABuscar : skillsABuscarList)
                                {
                                    for(Group queue : queueList)
                                    {
                                        if (queue.DeveloperName != null && queue.DeveloperName.startsWith('CC_') && queue.DeveloperName.contains('_stopGo'))
                                        {
                                            String nombreSkillBuscarIdioma ='';
											System.debug('NMA agenteSkillsBuscar.tipoChatSkill' + agenteSkillsBuscar.tipoChatSkill);
											System.debug('NMA agenteSkillsBuscar.tipoChatSkill' + agenteSkillsBuscar.tipoChatSkill);
                                            if(agenteSkillsBuscar.tipoChatSkill == 'CC_Agente'){
                                            	 nombreSkillBuscarIdioma = agenteSkillsBuscar.tipoChatSkill + '_' + skillABuscar + '_' + agenteSkillsBuscar.idiomaSkill + agenteSkillsBuscar.proveedorSkill;
                                            	 System.debug('NMA nombreSkillBuscarIdioma0' + nombreSkillBuscarIdioma);
    
                                            }else if(agenteSkillsBuscar.tipoChat2Skill == 'CC_Agente'){
                                            	 nombreSkillBuscarIdioma = agenteSkillsBuscar.tipoChat2Skill + '_' + skillABuscar + '_' + agenteSkillsBuscar.idiomaSkill + agenteSkillsBuscar.proveedorSkill;
                                            	 System.debug('NMA nombreSkillBuscarIdioma0' + nombreSkillBuscarIdioma);
    
                                            }else{
                                            	 nombreSkillBuscarIdioma = agenteSkillsBuscar.tipoChatSkill + '_' + skillABuscar + '_' + agenteSkillsBuscar.idiomaSkill;
                                            	 System.debug('NMA nombreSkillBuscarIdioma1' + nombreSkillBuscarIdioma);

                                            }
                                            //Comprobamos si el agente ya es miembro de la cola
                                            List<String> colasMiembroAgente = queueAgentMap.get(agenteSkillsBuscar.agenteId);
                                            System.debug('NMA queue.Id ' + queue.Id);
                                            System.debug('NMA queue.DeveloperName ' + queue.DeveloperName);
                                            System.debug('NMA agenteSkillsBuscar.agenteId ' + agenteSkillsBuscar.agenteId);
                                            System.debug('NMA colasMiembroAgente ' + colasMiembroAgente);
                                            
                                            System.debug('NMA nombreSkillBuscarIdioma ' + nombreSkillBuscarIdioma);


                                            GroupMember miembroQueue = comprobarCrearMiembroCola (queue.Id, queue.DeveloperName, agenteSkillsBuscar.agenteId, colasMiembroAgente, nombreSkillBuscarIdioma);
                                            System.debug('NMA miembroQueue ' + miembroQueue);
                                            if (miembroQueue != null && (listaColasAgentes.isEmpty() || !listaColasAgentes.contains(miembroQueue)))
                                            {
                                                listaColasAgentes.add(miembroQueue);
                                            }
                                            
                                            
                                            if (agenteSkillsBuscar.idioma2Skill != null)
                                            {
                                                String nombreSkillBuscarIdioma2 = agenteSkillsBuscar.tipoChatSkill + '_' + skillABuscar + '_' + agenteSkillsBuscar.idioma2Skill;
												System.debug('NMA nombreSkillBuscarIdioma2 ' + nombreSkillBuscarIdioma2);

                                                GroupMember miembroQueue2 = comprobarCrearMiembroCola (queue.Id, queue.DeveloperName, agenteSkillsBuscar.agenteId, colasMiembroAgente, nombreSkillBuscarIdioma2);
                                                if (miembroQueue2 != null && (listaColasAgentes.isEmpty() || !listaColasAgentes.contains(miembroQueue2)))
                                                {
                                                    listaColasAgentes.add(miembroQueue2);
                                                }
                                            }

                                            if (agenteSkillsBuscar.tipoChat2Skill != null)
                                            {
                                                String nombreSkill2BuscarIdioma = agenteSkillsBuscar.tipoChat2Skill + '_' + skillABuscar + '_' + agenteSkillsBuscar.idiomaSkill ;
                                                GroupMember miembroQueue3 = comprobarCrearMiembroCola (queue.Id, queue.DeveloperName, agenteSkillsBuscar.agenteId, colasMiembroAgente, nombreSkill2BuscarIdioma);
                                                if (miembroQueue3 != null && (listaColasAgentes.isEmpty() || !listaColasAgentes.contains(miembroQueue3)))
                                                {
                                                    listaColasAgentes.add(miembroQueue3);
                                                }

                                                if (agenteSkillsBuscar.idioma2Skill != null && agenteSkillsBuscar.proveedorSkill != null)
                                                {
                                                    String nombreSkill2BuscarIdioma2 = agenteSkillsBuscar.tipoChat2Skill + '_' + skillABuscar + '_' + agenteSkillsBuscar.idioma2Skill + agenteSkillsBuscar.proveedorSkill;

                                                    GroupMember miembroQueue4 = comprobarCrearMiembroCola (queue.Id, queue.DeveloperName, agenteSkillsBuscar.agenteId, colasMiembroAgente, nombreSkill2BuscarIdioma2);
                                                    if (miembroQueue4 != null && (listaColasAgentes.isEmpty() || !listaColasAgentes.contains(miembroQueue4)))
                                                    {
                                                        listaColasAgentes.add(miembroQueue4);
                                                    }
                                                }
                                                
                                                if (agenteSkillsBuscar.idioma2Skill != null && agenteSkillsBuscar.proveedor2Skill != null)
                                                {
                                                    String nombreSkill2BuscarIdioma2 = agenteSkillsBuscar.tipoChat2Skill + '_' + skillABuscar + '_' + agenteSkillsBuscar.idioma2Skill + agenteSkillsBuscar.proveedor2Skill;

                                                    GroupMember miembroQueue4 = comprobarCrearMiembroCola (queue.Id, queue.DeveloperName, agenteSkillsBuscar.agenteId, colasMiembroAgente, nombreSkill2BuscarIdioma2);
                                                    if (miembroQueue4 != null && (listaColasAgentes.isEmpty() || !listaColasAgentes.contains(miembroQueue4)))
                                                    {
                                                        listaColasAgentes.add(miembroQueue4);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
			}
        }
        if (listaColasAgentes != null && !listaColasAgentes.isEmpty())
        {
            system.debug('listaColasAgentes: '+listaColasAgentes);
            Database.insert(listaColasAgentes, true);
        }
    }

    private static GroupMember comprobarCrearMiembroCola (Id queuId, String nombreQueue, Id agenteId, List<String> colasMiembroAgente, String nombreBuscar)
	{
        GroupMember miembroQueue = null;
        if (nombreQueue != null && nombreQueue.equals(nombreBuscar) && (colasMiembroAgente == null || colasMiembroAgente.isEmpty() || !colasMiembroAgente.contains(nombreBuscar)))
        {
            miembroQueue =  new GroupMember();
            //Asignar agente a cola Stop&Go 
            miembroQueue.GroupId = queuId;
            miembroQueue.UserOrGroupId = agenteId;
        }
        return miembroQueue;
    }


    @future
    public static void quitarAgentesStopGoQueue(List<Id> endSkillSessionIdList)
	{

        List<GroupMember> listaColasAgentes = new List<GroupMember>();
        Set<String> listaUsuariosServResoId = new Set<String>();
        Set<Id> listaUsuariosId = new Set<Id>();
        Set<Id> skillIdList = new Set<Id>();
        Map<Id,List<Id>> skillUserMap = new Map<Id,List<Id>>();
        List<GroupMember> miembroQueueEliminar = new List <GroupMember>();

        if (endSkillSessionIdList != null && !endSkillSessionIdList.isEmpty())
        {
            //En el metadato guardamos los tipos de chat posibles y los idiomas para generar el label de la cola que necesitamos buscar para asignar al agente
            List<CC_Chat_Empleados_Stop_Go__mdt> listaValoresIdentificacion = [SELECT CC_Opciones__c, MasterLabel FROM CC_Chat_Empleados_Stop_Go__mdt];
            Map<String,String> tipoChatMap = new Map<String,String>();
            Map<String,String> idiomaMap = new Map<String,String>();
            Map<String,String> proveedorMap = new Map<String,String>();

            if (listaValoresIdentificacion != null && !listaValoresIdentificacion.isEmpty())
            {
                for(CC_Chat_Empleados_Stop_Go__mdt valor : listaValoresIdentificacion)
                {
                    if (valor.MasterLabel == 'TipoChat')
                    {
                        List<String> valoresTipoChat = valor.CC_Opciones__c.split(';');
                        if (valoresTipoChat != null && !valoresTipoChat.isEmpty())
                        {
                            for(String opcion : valoresTipoChat)
                            {
                                tipoChatMap.put(opcion, ('CC_' + opcion));
                            }
                        }
                    }
                    else if(valor.MasterLabel == 'Idioma')
                    {
                        List<String> valoresIdiomaChat = valor.CC_Opciones__c.split(';');
                        if (valoresIdiomaChat != null && !valoresIdiomaChat.isEmpty())
                        {
                            for(String opcion : valoresIdiomaChat)
                            {
                                idiomaMap.put(opcion.toUpperCase(), (opcion.toUpperCase() + '_stopGo'));
                            }
                        }
                    }
                    else if(valor.MasterLabel == 'Proveedor')
                    {
                        List<String> valoresProveedorChat = valor.CC_Opciones__c.split(';');
                        if (valoresProveedorChat != null && !valoresProveedorChat.isEmpty())
                        {
                            for(String opcion : valoresProveedorChat)
                            {
                            	proveedorMap.put(opcion, ('_' + opcion));
                            }
                        }
                    }

                }
            }

            //Obtenemos las sesiones de skills que se han finalizado, para buscar los agentes y los skills eliminados
            List<CC_SkillHistory__c> listaSkillSession = [SELECT Id, CC_User__c, CC_SkillId__c FROM CC_SkillHistory__c WHERE Id IN :endSkillSessionIdList];
          
            if (listaSkillSession != null && !listaSkillSession.isEmpty())
            {
                for (CC_SkillHistory__c sesion: listaSkillSession)
                {
                    List<Id> userSkillsList = new List<Id>();
                    if (!skillUserMap.isEmpty() && skillUserMap.get(sesion.CC_User__c) != null)
                    {
                        userSkillsList = skillUserMap.get(sesion.CC_User__c);
                        if (!userSkillsList.contains(sesion.CC_SkillId__c))
                        {
                            userSkillsList.add(sesion.CC_SkillId__c);
                            skillUserMap.put(sesion.CC_User__c, userSkillsList);
                        }
                    }
                    else
                    {
                        userSkillsList.add(sesion.CC_SkillId__c);
                        skillUserMap.put(sesion.CC_User__c, userSkillsList);
                    }
                    //Guardamos todos los skills para luego obtener su DeveloperName
                    skillIdList.add(sesion.CC_SkillId__c);
                    listaUsuariosId.add(sesion.CC_User__c);
                }


                //Buscamos los skills y su DeveloperName
                Map<Id,Skill> skillNameMap = new Map<Id,Skill>([SELECT Id, DeveloperName FROM Skill WHERE Id IN :skillIdList]);
                
    
                //Buscamos las colas a las que pertenecen los agentes, para sacarlos de las colas que toque
                List<GroupMember> queueMemberList = [SELECT Id, GroupId, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId IN :listaUsuariosId AND Group.QueueRoutingConfigId <> null];
             
                Map<Id,List<GroupMember>> queueAgentMap = new Map<Id,List<GroupMember>>();
                if (queueMemberList != null && !queueMemberList.isEmpty())
                {
                    for (GroupMember miembro : queueMemberList)
                    {
                        List<GroupMember> miembroQueueList = new List<GroupMember>();
                        //Guardamos todas las colas que hay para cada agente
                        if (!queueAgentMap.isEmpty() && queueAgentMap.get(miembro.UserOrGroupId) != null)
                        {
                            miembroQueueList = queueAgentMap.get(miembro.UserOrGroupId);
                            if (!miembroQueueList.contains(miembro))
                            {
                                miembroQueueList.add(miembro);
                                queueAgentMap.put(miembro.UserOrGroupId, miembroQueueList);
                            }
                        }
                        else
                        {
                            miembroQueueList.add(miembro);
                            queueAgentMap.put(miembro.UserOrGroupId, miembroQueueList);
                        }
                    }
                }
    
                if (queueAgentMap!= null && !queueAgentMap.isEmpty() && skillNameMap!= null && !skillNameMap.isEmpty() && skillUserMap != null && !skillUserMap.isEmpty() && !tipoChatMap.isEmpty() && !idiomaMap.isEmpty())
                {
                    for(String agenteQueueId : queueAgentMap.keySet())
                    {
                        List<GroupMember> miembroQueueList = new List<GroupMember>();
                        miembroQueueList = queueAgentMap.get(agenteQueueId);

                        for (GroupMember miembroQueue : miembroQueueList)
                        {
                            Map<Id, CC_AgenteSkillBuscar> agenteSkillsBuscarMap = new Map<Id, CC_AgenteSkillBuscar>();
                            for (Id idAgenteSkill : skillUserMap.keySet())
                            {
                                System.debug('OAM agenteQueueId ' + agenteQueueId + ' idAgenteSkill ' + idAgenteSkill);
                                if (agenteQueueId == idAgenteSkill && miembroQueue.UserOrGroupId == agenteQueueId)
                                {
                                    CC_AgenteSkillBuscar agenteSkillsBuscar = new CC_AgenteSkillBuscar();
                                    Set<String> listaSkillsNombres = new Set<String>();
                                    agenteSkillsBuscar.agenteId = idAgenteSkill;
                                    List<Id> userSkillsList = new List<Id>();
                                    userSkillsList = skillUserMap.get(idAgenteSkill);
                                    for (Id idSkillAgente : userSkillsList)
                                    {
                                        Skill skillName = skillNameMap.get(idSkillAgente);
                                        if (skillName != null && String.isNotBlank(skillName.DeveloperName))
                                        {
                                            if (tipoChatMap.get(skillName.DeveloperName) != null)
                                            {
                                                if (String.isNotBlank(miembroQueue.Group.DeveloperName) && (miembroQueue.Group.DeveloperName).startsWith(tipoChatMap.get(skillName.DeveloperName)) && 
                                                    ((miembroQueueEliminar != null && !miembroQueueEliminar.contains(miembroQueue)) || miembroQueueEliminar.isEmpty()))
                                                {
                                                    miembroQueueEliminar.add(miembroQueue);
                                                }
                                            }
                                            else if(idiomaMap.get(skillName.DeveloperName) != null)
                                            {
                                                if (String.isNotBlank(miembroQueue.Group.DeveloperName) && (miembroQueue.Group.DeveloperName).endsWith(idiomaMap.get(skillName.DeveloperName)) && 
                                                    ((miembroQueueEliminar != null && !miembroQueueEliminar.contains(miembroQueue)) || miembroQueueEliminar.isEmpty()))
                                                {
                                                    miembroQueueEliminar.add(miembroQueue);
                                                }
                                            }
                                            else if(proveedorMap.get(skillName.DeveloperName) != null)
                                            {
                                                if (String.isNotBlank(miembroQueue.Group.DeveloperName) && (miembroQueue.Group.DeveloperName).endsWith(proveedorMap.get(skillName.DeveloperName)) && 
                                                    ((miembroQueueEliminar != null && !miembroQueueEliminar.contains(miembroQueue)) || miembroQueueEliminar.isEmpty()))
                                                {
                                                    miembroQueueEliminar.add(miembroQueue);
                                                }
                                            }
                                            else 
                                            {
                                                String skillNameBuscar = '_' + skillName.DeveloperName + '_';
                                                if (String.isNotBlank(miembroQueue.Group.DeveloperName) && (miembroQueue.Group.DeveloperName).contains(skillNameBuscar) && 
                                                    ((miembroQueueEliminar != null && !miembroQueueEliminar.contains(miembroQueue)) || miembroQueueEliminar.isEmpty()))
                                                {
                                                    miembroQueueEliminar.add(miembroQueue);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
			}
        }

        if (miembroQueueEliminar != null && !miembroQueueEliminar.isEmpty())
        {
            Database.delete(miembroQueueEliminar, false);
        }
        
    }

    public class CC_AgenteSkillBuscar
    {
        public Id agenteId {get;set;}
        public String tipoChatSkill{get;set;}
        public String tipoChat2Skill{get;set;}
        public String idiomaSkill{get;set;}
        public String idioma2Skill{get;set;}
        public String proveedorSkill{get;set;}
        public String proveedor2Skill{get;set;}
        public Set<String> listaSkillsNombres {get;set;}
    } 

}