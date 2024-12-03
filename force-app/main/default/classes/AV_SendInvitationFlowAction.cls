/**
 * Clase de la aplicacion Gestor de Eventos
 */

global with sharing class AV_SendInvitationFlowAction {
    
    
    @invocableMethod(label='getFilteredCampaigns')
	public static List<List<Campaign>> getFilteredCampaigns(List<AV_CampaignList> campaigns){
        Map<Id, Campaign> mapCampaigns = new Map<Id, Campaign>();
        Map<Id, CampaignMember> mapCampaignsMem = new Map<Id, CampaignMember>();
        List<Campaign> filteredCamps = new List<Campaign>();
        for(CampaignMember campMe : campaigns[0].campMembers){
            mapCampaignsMem.put(campMe.CampaignId, campMe);
        }
        

        for (Campaign camp : campaigns[0].camps) {
            mapCampaigns.put(camp.Id, camp);
            if(mapCampaignsMem.get(camp.id) != null){
                filteredCamps.add(camp);
                System.debug('filteredCamps ' + filteredCamps);
            }
        }
       
        
        for (Campaign c : filteredCamps) {
            if (mapCampaigns.get(c.Id) != null ) {
                mapCampaigns.remove(c.Id);
            }
        }


        
        return  new List<List<Campaign>>{mapCampaigns.values()}; 
    }

   
}