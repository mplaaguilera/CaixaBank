public class CC_ServiceResourceSkill_AD_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<ServiceResourceSkill>)tp.oldList);
	}
    
    private void process(List<ServiceResourceSkill> listOldObj) {
        finalizarSkillSession(listOldObj);
	}

    private void finalizarSkillSession(List<ServiceResourceSkill> listOldObj)
	{
        List<CC_SkillHistory__c> listaSkillSessionUpdate = new List<CC_SkillHistory__c>();
		Set<Id> listaUsuariosId = new Set<Id>();
		Map<Id,List<ServiceResourceSkill>> mapUserSkills = new Map<Id,List<ServiceResourceSkill>>();
        
        if (listOldObj != null && !listOldObj.isEmpty())
        {
            for (ServiceResourceSkill serviceResSkill : listOldObj)
            {
                List<ServiceResourceSkill> userSkillsList = new List<ServiceResourceSkill>();
                //Guardamos el listado de usuarios para las búsquedas
                listaUsuariosId.add(serviceResSkill.CC_AgenteId__c);

                //Guardamos todos los skills que se han eliminado por usuario, para luego finalizar las fechas de todos y sacar al agente de las colas correspondientes
                if (!mapUserSkills.isEmpty() && mapUserSkills.get(serviceResSkill.CC_AgenteId__c) != null)
                {
                    userSkillsList = mapUserSkills.get(serviceResSkill.CC_AgenteId__c);
                    if (!userSkillsList.contains(serviceResSkill))
                    {
                        userSkillsList.add(serviceResSkill);
                        mapUserSkills.put(serviceResSkill.CC_AgenteId__c, userSkillsList);
                    }
                }
                else
                {
                    userSkillsList.add(serviceResSkill);
                    mapUserSkills.put(serviceResSkill.CC_AgenteId__c, userSkillsList);
                }
            }
            System.debug('OAM listaUsuariosId ' + listaUsuariosId.size());
            System.debug('OAM listaUsuariosId ' + listaUsuariosId);

            System.debug('OAM mapUserSkills ' + mapUserSkills.size());
            System.debug('OAM mapUserSkills ' + mapUserSkills);

            if (!listaUsuariosId.isEmpty())
            {
                //Obtenemos todos los registros de las sesiones por skills de los agentes
                List<CC_SkillHistory__c> listaSkillSession = [SELECT Id, CC_Fecha_Inicio__c, CC_Fecha_Fin__c, CC_SkillId__c, CC_SkillDescription__c, CC_User__c 
                                                                FROM CC_SkillHistory__c WHERE CC_Fecha_Fin__c = NULL AND CC_User__c IN : listaUsuariosId];
                System.debug('OAM listaSkillSession ' + listaSkillSession.size());
                System.debug('OAM listaSkillSession ' + listaSkillSession);
                if (listaSkillSession != null && !listaSkillSession.isEmpty() && mapUserSkills != null && !mapUserSkills.isEmpty())
                {
                    for (CC_SkillHistory__c serviceResSkill : listaSkillSession)
                    {
                        if (mapUserSkills.get(serviceResSkill.CC_User__c) != null)
                        {
                            List<ServiceResourceSkill> userSkillsList = new List<ServiceResourceSkill>();
                            userSkillsList = mapUserSkills.get(serviceResSkill.CC_User__c);
                            
                            if (userSkillsList != null)
                            {
                                for (ServiceResourceSkill skillIdToUpdate : userSkillsList)
                                {
                                    //Si coinciden los Ids del Skill con el almacenado en la lista de eliminados, actualizamos el campo Fecha fin de la sesión
                                    if (serviceResSkill.CC_SkillId__c == skillIdToUpdate.SkillId)
                                    {
                                        serviceResSkill.CC_Fecha_Fin__c = Datetime.now();
                                        listaSkillSessionUpdate.add(serviceResSkill);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if (listaSkillSessionUpdate != null && !listaSkillSessionUpdate.isEmpty())
            {
                System.debug('OAM listaSkillSessionUpdate ' + listaSkillSessionUpdate.size());
                System.debug('OAM listaSkillSessionUpdate ' + listaSkillSessionUpdate);
                Database.update(listaSkillSessionUpdate, true);

                List<Database.SaveResult> srList = Database.update(listaSkillSessionUpdate, true);
            
                List<Id> updatedSkillSessionIdList = new List<Id>();
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        updatedSkillSessionIdList.add(sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }

                if (updatedSkillSessionIdList != null && !updatedSkillSessionIdList.isEmpty())
                {
                    //llamamos al método future para que quite a los agentes de las colas de Stop&Go
                    CC_ServiceResourceSkill.quitarAgentesStopGoQueue(updatedSkillSessionIdList);
                }
            }
        }
	}
}