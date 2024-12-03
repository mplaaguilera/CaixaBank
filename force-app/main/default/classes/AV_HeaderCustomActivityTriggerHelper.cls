/**********************************************************************************************************************
 Name:	  AV_HeaderCustomActivityTriggerHelper
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de AV_HeaderCustomActivity__c.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR		   		DATE				Description
    1.0			APP                 Jashanpreet 	   	13/10/2020		    Init version
    1.1			APP                 Víctor Santiago	   	22/11/2021		    Method insertOrUpdateEventQueues added
    1.2			APP                 Víctor Santiago	   	14/12/2021		    Call to AV_CitaPrevia_SyncEvents and commented insertOrUpdateEventQueues
    1.3         US385113            Alex Cubells        30/05/2022          Remove method insertOrUpdateEventQueues 
    1.4         US385113            Víctor Santiago     21/06/2022          syncEvents commented due to bug 

***********************************************************************************************************************/
public with sharing class AV_HeaderCustomActivityTriggerHelper {

    /**
	 * @description		 	Check the record types
	 * @param listNews  	list of new records
	 */
    public static List<AV_HeaderCustomActivity__c> checkGeneralRT(List<AV_HeaderCustomActivity__c> listNews){
        Set<Id> setIdsRt = getAllRT();
        
        List<AV_HeaderCustomActivity__c> listData = new List<AV_HeaderCustomActivity__c>();
        for(AV_HeaderCustomActivity__c dataNew : listNews){
            if((setIdsRt).contains(dataNew.RecordTypeId)){
				listData.add(dataNew);
            }
        }
        return listData;
    }
    
    /**
	 * @description		 	Get all the ID's of the RT
	 */
    public static Set<Id> getAllRT(){
        Schema.DescribeSObjectResult objDescribe = AV_HeaderCustomActivity__c.SObjectType.getDescribe();
		List<Schema.RecordTypeInfo> recordTypeObj = objDescribe.getRecordTypeInfos();
		Set<Id> setIdsRt = New Set<Id>();
		
		for (Schema.RecordTypeInfo rt: recordTypeObj){
			if (rt.getDeveloperName().left(3)=='AV_') {
				setIdsRt.add(rt.getRecordTypeId());
			}
		}
        return setIdsRt;
    }
    
    /**
	 * @description		 	Get the ID's of the RT's requested by param
	 * @param setRT			List of the RT
	 */
	public static Set<Id> getIdsRT(Set<String> setRT){
		return AV_AppUtilities.getRecordTypeIdsInSet(setRT);
	}


    /**
	 * @description		 Sync Events via cita previa API
	 * @param   listNews    list of new Event records
	 * @param   listOlds    list of old event records
	 */
	/*public static void syncEvents(List<AV_HeaderCustomActivity__c> listNews, Map<Id, AV_HeaderCustomActivity__c> mapOldObj){
		String methodName = 'syncEvents';
        
        List<Event> eventsToProcess = new List<Event>();
        List<Event> listEvent = new List<Event>();
        Map<Id, AV_HeaderCustomActivity__c> mapEventsTask = new Map<Id, AV_HeaderCustomActivity__c>();
        Set<Id> setIdsRt = getAllRT();
        
        for(AV_HeaderCustomActivity__c headerTask : listNews) {
            if((setIdsRt).contains(headerTask.RecordTypeId) && (headerTask.AV_UrlTeams__c != mapOldObj.get(headerTask.Id).AV_UrlTeams__c)) {
                mapEventsTask.put(headerTask.Id, headerTask);
            }
        }

        if(!mapEventsTask.isEmpty()) {
            listEvent = new AV_Query('Event')
                                    .selectAllFields()
                                    .addConditionIn('AV_Task__c', mapEventsTask.keySet())
                                    .run();
        }
		
        if(!listEvent.isEmpty() && listEvent != null){
            for(Event e : listEvent){
                if(e.AV_Tipo__c == AV_AppConstants.VIDEOLLAMADA_TIPO && !e.IsRecurrence2 && AV_AppConstants.EVENTCLIENTE_RT.equals(e.recordType.DeveloperName)){
                    eventsToProcess.add(e);
                }
            }
            if(eventsToProcess!=null && !eventsToProcess.isEmpty()){
                String jsonString = json.serialize(eventsToProcess);
                AV_LogDebug.printLogDebug(methodName, 'eventsToProcess: ' + eventsToProcess.size());
                AV_CitaPrevia_SyncEvents.insertOrUpdateEvent(jsonString, false);
            }
        }
		
	}*/

}