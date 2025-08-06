public class CC_ServiceResourceSkill_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<ServiceResourceSkill>)tp.newList);
	}
    
    private void process(List<ServiceResourceSkill> listNewObj) {
		System.debug('OAM CC_ServiceResourceSkill_AI_TRHan');
        crearSkillSession(listNewObj);
	}


	private void crearSkillSession(List<ServiceResourceSkill> listNewObj)
	{
		//Sesiones por Skills
		List<CC_SkillHistory__c> listaSkillSession = new List<CC_SkillHistory__c>();
		Set<Id> listaUsuariosGenesysId = new Set<Id>();
		Set<Id> skillIdList = new Set<Id>();
		
		if (listNewObj != null && !listNewObj.isEmpty())
		{
			for (ServiceResourceSkill serviceResSkill : listNewObj)
			{
				//Creamos las sesiones por skills de cada agente al que se le asigna un nuevo skill
				CC_SkillHistory__c skillSession = new CC_SkillHistory__c();
				skillSession.CC_Fecha_Inicio__c = Datetime.now();
				skillSession.CC_SkillId__c = serviceResSkill.SkillId;
				skillSession.CC_User__c = serviceResSkill.CC_AgenteId__c;
				//skillSession.CC_Usuario_Genesys__c; Se rellena más adelante

				//Guardamos la lista de agentes para buscar el usuarioGenesys si lo tienen configurado
				listaUsuariosGenesysId.add(serviceResSkill.CC_AgenteId__c);
				//Guardamos la lista de sesiones que se crean
				listaSkillSession.add(skillSession);
				//Guardamos la lista de skills
				skillIdList.add(serviceResSkill.SkillId);
			}

			if (listaUsuariosGenesysId != null && !listaUsuariosGenesysId.isEmpty())
			{
				//Buscamos los usuarios genesys relacionados con los agentes
				List<CC_Usuario_Genesys__c> listaUsuariosGenesys = [SELECT Id, CC_User__c FROM CC_Usuario_Genesys__c WHERE CC_User__c IN :listaUsuariosGenesysId];
				System.debug('OAM listaUsuariosGenesys ' + listaUsuariosGenesys.size());
				System.debug('OAM listaUsuariosGenesys ' + listaUsuariosGenesys);

				//Buscamos los skills y su DeveloperName
				Map<Id,Skill> skillNameMap = new Map<Id,Skill>([SELECT Id, DeveloperName FROM Skill WHERE Id IN :skillIdList]);
				System.debug('OAM skillNameMap ' + skillNameMap.size());
				System.debug('OAM sskillNameMap ' + skillNameMap);

				if ((listaUsuariosGenesys != null && !listaUsuariosGenesys.isEmpty()) || (listaSkillSession != null && !listaSkillSession.isEmpty()))
				{
					//Guardamos en un mapa la relacion de UserId y UsuarioGenesys
					Map<Id, Id> mapUsuariosGenesysPorId = new Map<Id, Id>();
					for (CC_Usuario_Genesys__c usuarioGenesys : listaUsuariosGenesys)
					{
						mapUsuariosGenesysPorId.put(usuarioGenesys.CC_User__c, usuarioGenesys.Id);
					}

					System.debug('OAM mapUsuariosGenesysPorId ' + mapUsuariosGenesysPorId.size());
					System.debug('OAM mapUsuariosGenesysPorId ' + mapUsuariosGenesysPorId);

					//Actualizamos las sesiones introduciendo el UsuarioGenesys que corresponde al User y el developerName del Skill
					for (CC_SkillHistory__c skillSession : listaSkillSession)
					{
						if (mapUsuariosGenesysPorId != null && mapUsuariosGenesysPorId.get(skillSession.CC_User__c) != null)
						{
							skillSession.CC_Usuario_Genesys__c = mapUsuariosGenesysPorId.get(skillSession.CC_User__c);
						}

						if (skillNameMap!= null && !skillNameMap.isEmpty() && skillNameMap.get(skillSession.CC_SkillId__c) != null)
						{
							Skill skillName = skillNameMap.get(skillSession.CC_SkillId__c);
							skillSession.CC_SkillDescription__c = skillName?.DeveloperName;
						}
					}
				}
			}
			
			if (listaSkillSession != null && !listaSkillSession.isEmpty())
			{
				System.debug('OAM listaSkillSession ' + listaSkillSession.size());
				System.debug('OAM listaSkillSession ' + listaSkillSession);

				List<Database.SaveResult> srList = Database.insert(listaSkillSession, true);
			
				List<Id> newSkillSessionIdList = new List<Id>();
				for (Database.SaveResult sr : srList) {
					if (sr.isSuccess()) {
						newSkillSessionIdList.add(sr.getId());
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

				if (newSkillSessionIdList != null && !newSkillSessionIdList.isEmpty())
				{
					//llamamos al método future para que añada a los agentes a las colas de Stop&Go
					CC_ServiceResourceSkill.asignarAgentesStopGoQueue(newSkillSessionIdList);
				}
			}

		}
		
	}
}