/**********************************************************************************************************************
 Name:	  CIBE_FeedItem_AI_TRHan
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de FeedItem AfterInsert funcionalidad para CIBE 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
    1.0								Luis Martínez 	    20/12/2022			Init version

***********************************************************************************************************************/
public class CIBE_FeedItem_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<FeedItem>)tp.newList, (Map<Id, FeedItem>)tp.newMap, (List<FeedItem>) tp.oldList, (Map<Id, FeedItem>) tp.oldMap);
    }

    private void process(List<FeedItem> listNewObj, Map<Id, FeedItem> mapNewObj, List<FeedItem> listOldObj, Map<Id, FeedItem> mapOldObj) {
            Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
            if (!hasCustomPermission && !System.isbatch()) {
                CIBE_FeedItemTriggerHelper.createNotificationNewChat(listNewObj);
            }
    }
}