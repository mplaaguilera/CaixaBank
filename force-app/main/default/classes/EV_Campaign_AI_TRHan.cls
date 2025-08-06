/**********************************************************************************************************************
 Name:	  EV_CampaignMember_AI_TRHan
 Copyright © 2020  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Campaign AfterInsert
----------------------------------------------------------------------------------------------------------------------
Historial
----------------------------------------------------------------------------------------------------------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		  Eventos - 73889	  Jorge Centella	   	06/05/2020			Init version
    1.1                           Daniel Rodriguez      31/01/2023          Remove method cambioStatusEncursoFinalizado to EV_Campaign_BI_TRHan. Remove generarIdSeguro, generarTraduccionesEventoHijo, createCriteriosPO, crearCampaignEstados to EV_CampaignTriggerHelper
  	1.2		    US585725			Daniel Rodriguez	29/08/2023			Add differentiation between Alta masiva and normal Campaign
    1.3         US704873          Carolina Lopez        28/09/2023          Remove methods AgenerarTraduccionesEventoHijo, shareCampaign to EV_Campaign_BI_TRHan (campaignEntryMasiva)
  1.4         DE75856           Daniel Rodriguez      04/10/2023        Change method creationSchedule for new class EV_CreateScheduleChangeStatus

***********************************************************************************************************************/

public class EV_Campaign_AI_TRHan extends CC_TriggerHandlerBase {
    static final String ALTA_MASIVA = 'Alta masiva';
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Campaign>)tp.newList, (Map<Id, Campaign>)tp.newMap, (List<Campaign>)tp.oldList, (Map<Id, Campaign>)tp.oldMap);
    }
    
    private void process(List<Campaign> listNewObj, Map<Id, Campaign> mapNewObj, List<Campaign> listOldObj, Map<Id, Campaign> mapOldObj) {
        EV_LogDebug.printLogDebug('EV_Campaign_AI_TRHan ',String.valueof(listNewObj) + ' '+ String.valueof(mapOldObj));
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
            EV_CampaignTriggerHelper.generarIdSeguro(mapNewObj.keySet());
            EV_CampaignTriggerHelper.generarTraduccionesEventoHijo(campaignEntry);
            EV_CampaignTriggerHelper.createCriteriosPO(campaignEntry);
            EV_CampaignTriggerHelper.crearCampaignEstados(campaignEntry);
            EV_CampaignTriggerHelper.shareCampaign(campaignEntry,null);
            EV_CampaignTriggerHelper.fillCarteraParent(campaignEntry);
            EV_CreateScheduleChangeStatus.creationSchedule(campaignEntry,mapOldObj);
            //EV_CampaignTriggerHelper.cambioStatusEncursoFinalizado(listNewObj, mapOldObj);
        }if(!campaignEntryMasiva.isEmpty()){
            EV_CampaignTriggerHelper.generarIdSeguro(mapNewObj.keySet());
            //EV_CampaignTriggerHelper.generarTraduccionesEventoHijo(campaignEntryMasiva);
            EV_CampaignTriggerHelper.createCriteriosPO(campaignEntryMasiva);
            //EV_CampaignTriggerHelper.shareCampaign(campaignEntryMasiva,null);
        }

    }
}