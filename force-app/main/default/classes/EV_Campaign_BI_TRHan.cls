/**********************************************************************************************************************
 Name:	  EV_Campaign_BI_TRHan
 Copyright © 2020  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Campaign BeforeInsert
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		  	Eventos - 73889	  	Jorge Centella	   	06/05/2020			Init version
    1.1                           	Daniel Rodriguez    31/01/2023          Add method cambioStatusEncursoFinalizado to EV_Campaign_AI_TRHan. Remove setCampaignMemberRecordTypeId to EV_CampaignTriggerHelper
  	1.2 		US587001			Daniel Rodriguez	23/05/2023			Add method surveyActive
  	1.3		    US585725			Daniel Rodriguez	29/08/2023			Add differentiation between Alta masiva and normal Campaign
    1.4         TechSummit          Carolina Lopez      16/05/2024          Add method setTechSummitCampaign.
***********************************************************************************************************************/

public class EV_Campaign_BI_TRHan extends CC_TriggerHandlerBase {
    static final String ALTA_MASIVA = 'Alta masiva';
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Campaign>)tp.newList, (Map<Id, Campaign>)tp.newMap, (List<Campaign>)tp.oldList, (Map<Id, Campaign>)tp.oldMap);
    }
    
    private void process(List<Campaign> listNewObj, Map<Id, Campaign> mapNewObj, List<Campaign> listOldObj, Map<Id, Campaign> mapOldObj) {
        EV_LogDebug.printLogDebug('EV_Campaign_BI_TRHan ',String.valueof(listNewObj) + ' '+ String.valueof(mapOldObj));
        List<Campaign> campaignEntry = new List<Campaign>();
        List<Campaign> campaignEntryMasiva = new List<Campaign>();
        for(Campaign c :listNewObj){
            if(c.EV_Origen__c != ALTA_MASIVA){
                campaignEntry.add(c);
            }else{
                campaignEntryMasiva.add(c);
            } 
        }
        if(!campaignEntry.isEmpty()){
            EV_CampaignTriggerHelper.cambioStatusEncursoFinalizado(campaignEntry, mapOldObj);
            EV_CampaignTriggerHelper.fillPlaceOfCelebration(campaignEntry);
            EV_CampaignTriggerHelper.setCampaignMemberRecordTypeId(campaignEntry);
            EV_CampaignTriggerHelper.surveyActive(campaignEntry, mapNewObj, null);
            EV_CampaignTriggerHelper.setTechSummitCampaign(campaignEntry);
        }
    }


}