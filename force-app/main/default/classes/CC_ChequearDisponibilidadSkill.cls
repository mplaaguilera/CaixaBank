public with sharing class CC_ChequearDisponibilidadSkill {

    @InvocableMethod(label='Chequear Disponibilidad por Skills' description='Chequear Disponibilidad de los agentes por Skills')
    public static List<DisponibilidadWrapper> chequearDisponibilidad(List<List<SkillRequirement>> skillsRequirement)
	{
        DisponibilidadWrapper returnValue = new DisponibilidadWrapper();
        Set<Id> setIdSkills = new Set<Id>();
        //Lista de skills 
        List <SkillRequirement> skillReqs = skillsRequirement.get(0);
        
        CC_TrazaInt__c traza = new CC_TrazaInt__c();
        traza.name = 'ApexChatFlowCC';
       // traza.CC_MensajeEntrada__c = 'SkillRequirement => ' + JSON.serializePretty(skillReqs);

        //Recogemos los Skills ID de los SkillRequirements
        if(!skillReqs.isEmpty()){
            for(SkillRequirement skillrq : skillReqs){
                setIdSkills.add(skillrq.SkillId);
            }
        }
        traza.CC_MensajeSalida__c = 'SkillId => ' + JSON.serializePretty(setIdSkills);

        //Buscar PSR de tipo Skills - En el Channel de Live Agent
        Set<Id> psr = new Set<Id>();
        for(PendingServiceRouting psrItem : [
                SELECT Id
                FROM PendingServiceRouting 
                WHERE RoutingType = 'SkillsBased' AND ServiceChannel.MasterLabel LIKE '%Live Agent%'
            ]){
            psr.add(psrItem.Id);    
        }

        //Buscar en SkillRequirement si hay relacionados con las Skills que se reciben
        Integer skillsWaiting = [
            SELECT COUNT()
            FROM SkillRequirement
            WHERE SkillId IN: setIdSkills
            AND RelatedRecordId IN: psr
        ];

        returnValue.cantSkillsWaiting = skillsWaiting != null ? skillsWaiting : 0;


        //Buscar los Agentes que tengan asignadas TODAS las skills 
        Map<Id, Set<Id>> agentesSkillsMap = new Map<Id, Set<Id>>(); 
        for(ServiceResourceSkill agentSkills : 
            [
                SELECT Id, Skill.DeveloperName, SkillId, ServiceResource.Name, ServiceResource.RelatedRecordId  
                FROM ServiceResourceSkill 
                WHERE SkillId IN: setIdSkills
            ]){
            if(!agentesSkillsMap.containsKey(agentSkills.ServiceResource.RelatedRecordId)){
                agentesSkillsMap.put(agentSkills.ServiceResource.RelatedRecordId, new Set<Id> {agentSkills.SkillId} );
            }
            else{
                agentesSkillsMap.get(agentSkills.ServiceResource.RelatedRecordId).add(agentSkills.SkillId);
            }                        
        }

        traza.CC_DetalleError__c = 'Agentes Map => ' + JSON.serializePretty(agentesSkillsMap);
       
        //Descartar Agentes que no tengan TODAS las Skills
        Set<Id> agentesIds = new Set<Id>();
        for(Id agenteId : agentesSkillsMap.keySet()){
            if(agentesSkillsMap.get(agenteId).size() == setIdSkills.size()){
                agentesIds.add(agenteId);
            }
        }
        traza.CC_MensajeEntrada__c = 'Agentes con TODAS => ' + JSON.serializePretty(agentesIds);
        //default value
        returnValue.cantAgentesDisponibles = 0;

        if(agentesIds.size() > 0){         
            
            //Buscar si hay agentes disponibles aunque esten en isAway
            Integer agentsDisponibles = [
                SELECT COUNT()
                FROM UserServicePresence
                WHERE UserId IN: agentesIds
                AND IsCurrentState = true 
                AND (User.UserRole.DeveloperName LIKE '%Contact%' OR User.UserRole.DeveloperName LIKE '%HDT%')
            ];
        
            returnValue.cantAgentesDisponibles = agentsDisponibles != null ? agentsDisponibles : 0;

            traza.CC_MensajeEntrada__c = 'COUNT QUERT => ' + JSON.serializePretty([
                SELECT COUNT()
                FROM UserServicePresence
                WHERE UserId IN: agentesIds
                AND IsCurrentState = true 
                AND (User.UserRole.DeveloperName LIKE '%Contact%' OR User.UserRole.DeveloperName LIKE '%HDT%')
            ]);

         
        }

        insert traza;
        return 
            new List<DisponibilidadWrapper> {
                returnValue
            };     

    }


    public class DisponibilidadWrapper {
        
        @InvocableVariable(label='Cant Agentes Dispibles' description='Cant Agentes Dispibles')
        public Integer cantAgentesDisponibles;

        @InvocableVariable(label='Cant Chats Esperando' description='Cant Chat Esperando')
        public Integer cantSkillsWaiting;
    }
}