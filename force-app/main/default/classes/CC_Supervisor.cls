public with sharing class CC_Supervisor {
    
    public class ChatsWrapper {
        @AuraEnabled
        public String servicio{get;set;}
        @AuraEnabled
        public Integer contadorDXC{get;set;}
        @AuraEnabled
        public Integer contadorMST{get;set;}
    }
    

    @AuraEnabled
    public static Integer tiempoRefresco(){
        Integer tiempoRefresco= 0;
        CC_Tiempo_Refresco__c tiempo =[SELECT CC_Tiempo__c
                                            FROM CC_Tiempo_Refresco__c  
                                            WHERE CC_Tipo__c = 'Supervisor'];
        
        tiempoRefresco = Integer.valueOf(tiempo.CC_Tiempo__c);
        
        return tiempoRefresco;
    }
    
    
    @AuraEnabled
    public static List <ChatsWrapper> datosTotal() {
        
       List<PendingServiceRouting> pendings = [SELECT  Id, WorkItemId FROM PendingServiceRouting WHERE createdDate = today];
       Map<Id,Id> mapSkillsPend = new Map<Id,Id>();
       for(PendingServiceRouting pending : pendings){
           mapSkillsPend.put(pending.Id, pending.WorkItemId);
       }
        
       List<SkillRequirement> skillsReqs =  [SELECT Id, Skill.DeveloperName,RelatedRecordId, RelatedRecord.name FROM SkillRequirement 
                                             WHERE RelatedRecordId IN :mapSkillsPend.keySet() order by RelatedRecordId asc];
        Set<Id> setIdsChats = new Set<Id>();
        Map<Id,String> mapSkills = new Map<Id,String>();
        String  skills;
        String idChat;
        for(SkillRequirement skillsReq : skillsReqs){
            if(mapSkillsPend.containsKey(skillsReq.RelatedRecordId)){
                if(skills != null && skillsReq.RelatedRecordId == idChat){
                	skills = skills +'; ' +skillsReq.Skill.DeveloperName;    
                }else if(skills != null && idChat !='' && skillsReq.RelatedRecordId != idChat){
                    skills = '';
                	skills = skillsReq.Skill.DeveloperName;
                    idChat = skillsReq.RelatedRecordId;
                }else{
                	skills = skillsReq.Skill.DeveloperName;
                    idChat = skillsReq.RelatedRecordId;
                }
                mapSkills.put(mapSkillsPend.get(skillsReq.RelatedRecordId), skills);
                setIdsChats.add(mapSkillsPend.get(skillsReq.RelatedRecordId));
            }
        }
        
        List<ChatsWrapper> chats = new List<ChatsWrapper>();
        Integer contadorDXC = 0;
        Integer contadorMST = 0;
        String servicioChat = '';
        String proveedor = '';
        Map<String, Map<String, Integer>> mapProveedorChats = new Map<String, Map<String, Integer>>();
        Map<String,String> mapDXC = new Map<String,String>();
        Map<String,String> mapMST = new Map<String,String>();
        List<LiveChatTranscript> chatsReturn =   [Select CC_Servicio_Chat__c,Id FROM LiveChatTranscript WHERE createdDate = today 
                                                  AND CC_Tipo__c  ='Agente' AND RecordType.DeveloperName = 'CC_Empleados'
                                                  AND Id IN :setIdsChats order by CC_Servicio_Chat__c asc];
        for(LiveChatTranscript chat : chatsReturn){
        	if(mapSkills.containsKey(chat.Id)){
                proveedor = mapSkills.get(chat.Id).contains('DXC') ? 'DXC' : 'MST';
                servicioChat = chat.CC_Servicio_Chat__c;
                Map<String, Integer> mapProveedorConNumChats = mapProveedorChats.get(servicioChat);
                if(mapProveedorConNumChats != null)
                {
                	Integer numChats = mapProveedorConNumChats.get(proveedor);
                    if(numChats == null)
                    {
                        mapProveedorConNumChats.put(proveedor, 1);
                    }else{
                        mapProveedorConNumChats.put(proveedor, numChats + 1);
                    }
                }else{
                    mapProveedorConNumChats = new Map<String, Integer>();
                    mapProveedorConNumChats.put(proveedor, 1);
                }
                mapProveedorChats.put(servicioChat, mapProveedorConNumChats);
            }	
            
        }
            for(String servicio : mapProveedorChats.keySet()){
                Map<String, Integer> mapValores = mapProveedorChats.get(servicio);
                ChatsWrapper chatsWrapp = new ChatsWrapper();
                chatsWrapp.servicio =  servicio;
                chatsWrapp.contadorDXC = mapValores.get('DXC') != null ? mapValores.get('DXC') : 0;
                chatsWrapp.contadorMST = mapValores.get('MST') != null ? mapValores.get('MST') : 0;
                chats.add(chatsWrapp);
            }
        
        return chats;
    }

}