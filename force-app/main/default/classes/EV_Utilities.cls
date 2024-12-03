/**********************************************************************************************************************
 Name:	  EV_Utilities
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase de utilidades
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		                	  	Jorge Centella	   	29/10/2020			Init version
	1.1							  	Daniel Rodriguez    27/09/2022			Add method setToStringIn
	1.2 		US585725			Daniel Rodriguez	29/08/2023			Add method getRecordTypeIdsInSet, SearchRT
    1.3         US760328            Carolina Lopez      15/11/2023          Add with sharing.
    1.4         TechSummit          Manuel Ramos        19/07/2024          Add method getCampaignTranslations
***********************************************************************************************************************/

public with sharing class EV_Utilities {
    
    public static final String OBJECT_NAME_CAMPAIGN     	= 'Campaign';
	public static final String OBJECT_NAME_CAMPAIGNMEMBER  	= 'CampaignMember';
	public static final String OBJECT_NAME_CAMPAIGNMEMBERC	= 'EV_CampaignMemberC__c';

    /*
    Método para hacer un HASH a partir de una clave dada.
    */
    public static String generateSecureId(String secretKeyValue){
        String salt = String.valueOf(Crypto.getRandomInteger());
        String secretKey = secretKeyValue;
        String algorithmName = 'HmacSHA256';
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(salt), Blob.valueOf(secretKey));

        return EncodingUtil.urlEncode(EncodingUtil.base64Encode(hmacData), 'UTF-8');
    }
    
        /**
	 * Set pass to String format ('Ejemplo','Prueba')
	 */
    public static String setToStringIn(Set<String> setUserIds) {
        String listUserIds = '(';
		Integer cont=0;
		for(String s: setUserIds) {
			listUserIds=listUserIds+'\''+ s + '\'';
			if (cont == setUserIds.size()-1){
				listUserIds=listUserIds+')';
			} else {
				listUserIds=listUserIds+',';
			}
			cont++;
		}
        return listUserIds;
	}
    /**
	 * Set pass to integer 
	 */
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
        /**
     * Wrapper class to search RT ID's without queries
     */
    public class SearchRT {
        public String strObjectName;
        public String strDeveloperName;
        
        public SearchRT(String objectName, String developerName){
            strObjectName = objectName;
            strDeveloperName = developerName;
        }
    }

       /**
	 * @description		 Retrieve RecordType filter by Set of Developer Names
	 * @param  recorTypeName  set of Developer Names of RecordType
	 * @return			  Return a List of RecordType Ids
	 */
    public static Set<Id> getRecordTypeIdsInSet(Set<SearchRT> setRTs){
        Set<Id> setIdsRt = new Set<Id>();
        if(setRTs!=null && !setRTs.isEmpty()){
            Map<String,Map<String,Schema.RecordTypeInfo>> mapObjectRT = new Map<String,Map<String,Schema.RecordTypeInfo>>();
            for(SearchRT data : setRTs){                
                if (String.isNotBlank(data.strObjectName) && String.isNotBlank(data.strDeveloperName) && !mapObjectRT.containsKey(data.strObjectName)){
                    if (data.strObjectName == 'Opportunity') {
                        mapObjectRT.put(data.strObjectName, Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName());
                    }else if (data.strObjectName == 'Task') {
                        mapObjectRT.put(data.strObjectName, Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName());
                    } else if (data.strObjectName == 'Event') {
                        mapObjectRT.put(data.strObjectName, Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName());
                    } else if (data.strObjectName == 'Account') {
                        mapObjectRT.put(data.strObjectName, Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName());
                    } else if (data.strObjectName == 'Contact') {
                        mapObjectRT.put(data.strObjectName, Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName());
                    }else if (data.strObjectName == 'Campaign') {
                        mapObjectRT.put(data.strObjectName, Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName()); 
                    }else if (data.strObjectName == 'CampaignMember') {
                        mapObjectRT.put(data.strObjectName, Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName());
                    }else if (data.strObjectName == 'EV_CampaignMemberC__c') {
                        mapObjectRT.put(data.strObjectName, Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName());
                    }else {
                        mapObjectRT.put(data.strObjectName, Schema.getGlobalDescribe().get(data.strObjectName).getDescribe().getRecordTypeInfosByDeveloperName());
                    }
                }
            }
            for(SearchRT data : setRTs){                
                if (String.isNotBlank(data.strObjectName) && String.isNotBlank(data.strDeveloperName)){
                    String idRT = mapObjectRT?.get(data.strObjectName)?.get(data.strDeveloperName)?.getRecordTypeId();
                    if (String.isNotBlank(idRT)) {
                        setIdsRt.add(idRT);
                    }
                }
            }
        }
        return setIdsRt;
    }

	/**
	* @description          Obtain all Translation records related to a Campaign
	* @param                campaignId Id of the Campaign record
    * @notes                More fields can be added to the query when necessary in a future
	*/
    public static Map<Id,Map<String,EV_TraduccionDeEvento__c>> getEventoTraducciones(set<Id> campaignIds) {
        Map<Id, Map<String,EV_TraduccionDeEvento__c>> eventoTraduccionesMap = new Map<Id, Map<String, EV_TraduccionDeEvento__c>>();
        List<EV_TraduccionDeEvento__c> listTraducciones = [SELECT Id,EV_Evento__c,EV_Idioma__c,Name,EV_Descripcion__c FROM EV_TraduccionDeEvento__c WHERE EV_Evento__c IN :campaignIds];
        
        for (Id campaignId : campaignIds) {
            eventoTraduccionesMap.put(campaignId, new Map<String,EV_TraduccionDeEvento__c>());
        }

        for (EV_TraduccionDeEvento__c traduccion : listTraducciones) {
            eventoTraduccionesMap.get(traduccion.EV_Evento__c).put(traduccion.EV_Idioma__c, traduccion);
        }
        return eventoTraduccionesMap;
    }
}