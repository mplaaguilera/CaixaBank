/**********************************************************************************************************************
 Name:	  CBK_copado_Release_AU_TRHan
 Copyright © 2024  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de copado_Release para el After Update.
------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	        AUTHOR		   		DATE				Description
	1.0			US793496		    Sergio Garcia	   	04/03/2024		    Init version
***********************************************************************************************************************/
public with sharing class CBK_copado_Release_AU_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<copado__Release__c>) tp.newList, (Map<Id, copado__Release__c>) tp.oldMap);
	}

    private void process(List<copado__Release__c> listNewObj, Map<Id, copado__Release__c> mapOldObj) {
        Set<Id> releasedIds = new Set<Id>();
        List<copado__User_Story__c> usToUpdate = new List<copado__User_Story__c>();

        for(copado__Release__c release : listNewObj){
            if(mapOldObj.get(release.Id).copado__Status__c != 'Released' && release.copado__Status__c == 'Released'){
                releasedIds.add(release.Id);
            }
        }
        if(!releasedIds.isEmpty()){
            usToUpdate = [SELECT Id, copado__Stop_Indexing_Metadata__c FROM copado__User_Story__c WHERE copado__Stop_Indexing_Metadata__c = false AND copado__Release__c IN : releasedIds];
            
            if(!usToUpdate.isEmpty()){
                for (copado__User_Story__c usStory : usToUpdate) {
                    usStory.copado__Stop_Indexing_Metadata__c = true;
                    usStory.copado__Exclude_From_CBM__c = true;
                }
                List<Database.SaveResult> updR = Database.update(usToUpdate, false);
                for(Database.SaveResult resultado : updR){
                    if (!resultado.isSuccess()) {
                        for (Database.Error error : resultado.getErrors()) {
                            cbk_log.error(resultado.getId() + '  ' + error.getMessage());
                        }
                    }
                }
            }
        }
    }
}