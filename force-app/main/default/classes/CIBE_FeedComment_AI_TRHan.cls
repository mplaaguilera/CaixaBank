/**********************************************************************************************************************
 Name:	  CIBE_FeedComment_AI_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de FeedItem AfterInsert funcionalidad para CIBE 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
    1.0								Luis Martínez 	    20/12/2022			Init version

***********************************************************************************************************************/
public class CIBE_FeedComment_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<FeedComment>)tp.newList, (Map<Id, FeedComment>)tp.newMap, (List<FeedComment>) tp.oldList, (Map<Id, FeedComment>) tp.oldMap);
    }

    private void process(List<FeedComment> listNewObj, Map<Id, FeedComment> mapNewObj, List<FeedComment> listOldObj, Map<Id, FeedComment> mapOldObj) {
            Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
            if (!hasCustomPermission && !System.isbatch()) {
                CIBE_FeedCommentTriggerHelper.createNotificationNewChat(listNewObj);
            }
    }
}