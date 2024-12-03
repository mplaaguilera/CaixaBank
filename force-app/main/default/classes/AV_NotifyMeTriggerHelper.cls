/**********************************************************************************************************************
 Name:	  AV_NotifyMeTriggerHelper
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase auxiliar de los Triggers de NotifyMe.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY	        AUTHOR		   		DATE				Description
    1.0			Init Version	    Esperanza Conde	    14/12/2020		    Init version
    1.1		    AV_Query IT	        Daniel Rodríguez	09/02/2022	        Change AV_Query to SOQL for User, Account, Contact
***********************************************************************************************************************/
public with sharing class AV_NotifyMeTriggerHelper {
    
    /**
	 * @description		 	Check the record types
	 * @param listNews  	list of new records
	 */
    public static List<AV_NotifyMe__c> checkGeneralRT(List<AV_NotifyMe__c> listNews){
        
        Set<Id> setIdsRt = getAllRT();
        List<AV_NotifyMe__c> listData = new List<AV_NotifyMe__c>();
        for(AV_NotifyMe__c dataNew : listNews){
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
        Schema.DescribeSObjectResult objDescribe = AV_NotifyMe__c.SObjectType.getDescribe();
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
	 * @description		    Procces owners of NotifyMe where field owner will be associated user of the employee	 * @param  lstEvents    list of new NotifyMe records
     * @param  mapOlds      map of old notifyMe records
	 */
    public static void processOwner(List<AV_NotifyMe__c> lstNews, Map<Id, AV_NotifyMe__c> mapOlds){
        Set<Id> setIdsRt = getAllRT();
		List<AV_NotifyMe__c> lstNotifyMe = new List<AV_NotifyMe__c>();
        Set<String> setEmployeeId = new Set<String>();

        if(mapOlds != null && !mapOlds.isEmpty()) {
            for(AV_NotifyMe__c notifyNew : lstNews){
                if((setIdsRt).contains(notifyNew.RecordTypeId) && String.isNotBlank(notifyNew.AV_Employee__c)
                && notifyNew.AV_Employee__c != mapOlds.get(notifyNew.Id).AV_Employee__c){
                    lstNotifyMe.add(notifyNew);
                    setEmployeeId.add(notifyNew.AV_Employee__c);
                }
            }
        }else{
            for(AV_NotifyMe__c notifyNew : lstNews){
                if((setIdsRt).contains(notifyNew.RecordTypeId) && String.isNotBlank(notifyNew.AV_Employee__c)){
                    lstNotifyMe.add(notifyNew);
                    setEmployeeId.add(notifyNew.AV_Employee__c);
                }
            }
        }

        if(setEmployeeId!=null && !setEmployeeId.isEmpty()) {

            Map<Id,Id> mapEmployeeUser = new Map<Id,Id>();
            List<Contact> listEmployees= [Select Id, AV_UsuarioAsociado__c From Contact Where Id in :setEmployeeId and AV_UsuarioAsociado__r.IsActive = true];
            /*List<Contact> listEmployees = new AV_Query('Contact')
                                        .selectFields('Id, AV_UsuarioAsociado__c')
                                        .addConditionIn('Id', setEmployeeId)
                                        .addConditionEq('AV_UsuarioAsociado__r.IsActive', true)
                                        .run();*/

            if(listEmployees.size() > 0 && listEmployees != null){
                for(Contact c : listEmployees){
                    mapEmployeeUser.put(c.Id, c.AV_UsuarioAsociado__c);
                }

                for(AV_NotifyMe__c notifyMe : lstNotifyMe){
                    if(mapEmployeeUser.get(notifyMe.AV_Employee__c) != null){
                        notifyMe.OwnerId = mapEmployeeUser.get(notifyMe.AV_Employee__c);
                    }
                }
            }
        }
            
    }

}