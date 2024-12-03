/**********************************************************************************************************************
 Name:	  EV_CampaignMember_BU_TRHan
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Campaign BeforeUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		  	Eventos - 73889	  	Jorge Centella	   	06/05/2020			Init version
    1.0		  	                  	Eric Vazquez	   	10/06/2021			Init version
    1.2                           	Daniel Rodriguez    30/01/2023          Remove duplicated method cambioStatusEncursoFinalizado to EV_CampaignTriggerHelper
  	1.2 		US587001			Daniel Rodriguez	23/05/2023			Add method surveyActive

***********************************************************************************************************************/

public class EV_Campaign_BU_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Campaign>)tp.newList, (Map<Id, Campaign>)tp.newMap, (List<Campaign>)tp.oldList, (Map<Id, Campaign>)tp.oldMap);
    }
    
    private void process(List<Campaign> listNewObj, Map<Id, Campaign> mapNewObj, List<Campaign> listOldObj, Map<Id, Campaign> mapOldObj) {
        EV_LogDebug.printLogDebug('EV_Campaign_BU_TRHan ',String.valueof(listNewObj) + ' '+ String.valueof(mapOldObj));
        EV_CampaignTriggerHelper.cambioStatusEncursoFinalizado(listNewObj, mapOldObj);
        EV_CampaignTriggerHelper.newFlowAC(mapNewObj, mapOldObj);
        EV_CampaignTriggerHelper.validateEventToTranslations(listNewObj, mapOldObj);
        EV_CampaignTriggerHelper.validatePublicForEvent(mapNewObj, mapOldObj);
        EV_CampaignTriggerHelper.surveyActive(listNewObj, mapNewObj, mapOldObj);
       
    }


}