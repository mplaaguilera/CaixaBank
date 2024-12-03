/**********************************************************************************************************************
 Name:    EV_Campaign_AU_TRHan
 Copyright © 2020  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Campaign AfterUpdate
----------------------------------------------------------------------------------------------------------------------
Historial
----------------------------------------------------------------------------------------------------------------------
  VERSION    USER_STORY        AUTHOR        DATE        Description
  1.0                        Daniel Rodriguez                  Init version
   1.1      US586998      Daniel Rodriguez      15/06/2023      Insert method updateRollUpEventChangeStatus 
  1.2         DE75856           Daniel Rodriguez      04/10/2023        Change method creationSchedule for new class EV_CreateScheduleChangeStatus

***********************************************************************************************************************/

public  class EV_Campaign_AU_TRHan extends CC_TriggerHandlerBase {
  
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Campaign>)tp.newList, (Map<Id, Campaign>)tp.newMap, (List<Campaign>)tp.oldList, (Map<Id, Campaign>)tp.oldMap);
    }
    private void process(List<Campaign> listNewObj, Map<Id, Campaign> mapNewObj, List<Campaign> listOldObj, Map<Id, Campaign> mapOldObj) {
        EV_LogDebug.printLogDebug('EV_Campaign_AU_TRHan ',String.valueof(listNewObj) + ' '+ String.valueof(mapOldObj));
        EV_CampaignTriggerHelper.shareCampaign(listNewObj,mapOldObj);
        EV_CreateScheduleChangeStatus.creationSchedule(listNewObj,mapOldObj);
        EV_CampaignTriggerHelper.updateCarteraPO(listNewObj, mapOldObj);
        EV_CampaignTriggerHelper.updateRollUpEventChangeStatus(listNewObj, mapOldObj);
    }
}