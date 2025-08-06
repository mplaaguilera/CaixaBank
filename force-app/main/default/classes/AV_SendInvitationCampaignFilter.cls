/**
 * Clase de la aplicacion Gestor de Eventos
 */
public with sharing class AV_SendInvitationCampaignFilter {


    @invocableMethod(label='getFilteredCampaignCentros')
    public static List<List<Campaign>> getFilteredCampaignCentros(List<AV_CampaignList> campaigns) {
        List<Campaign> filteredCampsCentro = new List<Campaign>();
        Map<Id,Campaign> mapCamp = new Map<Id,Campaign>();
        for(Campaign camp : campaigns[0].camps){
            mapCamp.put(camp.id, camp);
        }
		
        for (Centro_Objetivo__c centroObj : campaigns[0].centrosObj) {
            Campaign camp = new Campaign();
            if (mapCamp.get(centroObj.EV_Campaign__c) != null) {
                camp = mapCamp.get(centroObj.EV_Campaign__c);
                filteredCampsCentro.add(camp);
            }   
        }
        return  new List<List<Campaign>>{filteredCampsCentro};
    }
}