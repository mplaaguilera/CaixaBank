public class EV_CampaignMember_BD_TRHan extends CC_TriggerHandlerBase {
    
    static Map<Id, String> mapNameForLeads = new Map<Id, String>();
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CampaignMember>)tp.newList, (Map<Id, CampaignMember>)tp.newMap, (List<CampaignMember>)tp.oldList, (Map<Id, CampaignMember>)tp.oldMap);
    }
    
    private void process(List<CampaignMember> listNewObj, Map<Id, CampaignMember> mapNewObj, List<CampaignMember> listOldObj, Map<Id, CampaignMember> mapOldObj) {
        for(CampaignMember member : [SELECT Id, LeadId, Lead.Name FROM CampaignMember
                                     WHERE Id IN :listOldObj])
        {
            mapNameForLeads.put(member.LeadId, member.Lead.Name);
        }
        
        crearHistoricoDelete(listOldObj);
    }
    
    private static void crearHistoricoDelete(List<CampaignMember> listOldObj) {
        
        List<EV_CampaignMemberHistory__c> ch = new List<EV_CampaignMemberHistory__c>(); 
        
        for(CampaignMember cmOld : listOldObj)
        {           
            EV_CampaignMemberHistory__c cmHistorial = new EV_CampaignMemberHistory__c();               
            cmHistorial.EV_Campaign_Id__c = cmOld.CampaignId;            
            cmHistorial.EV_CampaignMember_Id__c = cmOld.Id;    
            cmHistorial.EV_Nombre_Miembro__c = mapNameForLeads.get(cmOld.LeadId);
            cmHistorial.EV_Lead__c = cmOld.LeadId;     
            cmHistorial.EV_Usuario__c = userinfo.getUserId();
            cmHistorial.EV_Accion_Trigger__c = 'Delete';
            cmHistorial.EV_Detalles_del_historial__c = DateTime.now() + ' - Se ha eliminado al Campaign Member Id: ' 
                + cmOld.id + ' perteneciente a la Campaign Id: '+ cmOld.campaignId + ' por el usuario: '+ userinfo.getUserName();
            
            ch.add(cmHistorial);
        }
        
        if(!ch.isEmpty())
        {
            insert ch;
        }
    }
    
}