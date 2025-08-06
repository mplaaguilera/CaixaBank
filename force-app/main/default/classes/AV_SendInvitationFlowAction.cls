/**********************************************************************************************************************
Name:     AV_SendInvitationFlowAction
-----------------------------------------------------------------------------------------------------------------------
@description Event Manager Application Class
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION     USER_STORY          AUTHOR              DATE            Description
1.0         GEO MC              Carolina Lopez      30/09/2024      Modify custom campaign member filtering logic. 
***********************************************************************************************************************/
public with sharing class AV_SendInvitationFlowAction {
    @invocableMethod(label='getFilteredCampaigns')
	public static List<List<Campaign>> getFilteredCampaigns(List<AV_CampaignList> campaigns){
        Map<Id, Campaign> mapCampaigns = new Map<Id, Campaign>();
        Map<Id, CampaignMember> mapCampaignsMem = new Map<Id, CampaignMember>();
        Map<Id, EV_CampaignMemberC__c> mapCampaignsMemCus = new Map<Id, EV_CampaignMemberC__c>();
        List<Campaign> filteredCamps = new List<Campaign>();
        List<Campaign> filteredCampsCus = new List<Campaign>();

        if(campaigns[0].campMembers != null){
        for(CampaignMember campMe : campaigns[0].campMembers){
            mapCampaignsMem.put(campMe.CampaignId, campMe);
        }
        }
        if(campaigns[0].campMembersCus != null){
            for(EV_CampaignMemberC__c campMeCus : campaigns[0].campMembersCus){
                mapCampaignsMemCus.put(campMeCus.EV_CampaignId__c, campMeCus);
            }
        }
        for (Campaign camp : campaigns[0].camps) {
            mapCampaigns.put(camp.Id, camp);
            if(mapCampaignsMemCus.get(camp.id) != null){
                filteredCampsCus.add(camp);
                CBK_log.debug('filteredCampsCus ' + filteredCampsCus);
            }
            if(mapCampaignsMem.get(camp.id) != null){
                filteredCamps.add(camp);
                CBK_log.debug('filteredCamps ' + filteredCamps);
            }
        }
        if(!filteredCampsCus.isEmpty()){
            for (Campaign c : filteredCampsCus) {
                if (mapCampaigns.get(c.Id) != null ) {
                    mapCampaigns.remove(c.Id);
                }
            }
        }
        if(!filteredCamps.isEmpty()){
        for (Campaign c : filteredCamps) {
            if (mapCampaigns.get(c.Id) != null ) {
                mapCampaigns.remove(c.Id);
            }
        }
        }
        
        return  new List<List<Campaign>>{mapCampaigns.values()}; 
    }
}