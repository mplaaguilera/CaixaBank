/**********************************************************************************************************************
 Name:	  AV_BookManagementMemberTriggerHelper
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Cartera Gestor
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			Init version        Sandra Gómez		14/10/2021			Init version
	1.1			USXXXXXX 		    Daniel Rodríguez	09/12/2021			add CBK_log in updateOwnerIdFromClient method
	1.2		    AV_Query IT	        Daniel Rodríguez	04/02/2022	        Change AV_Query to SOQL for User, Account, Contact
	1.3			Fix					Sandra Gómez		04/04/2022			Change to Queueable
	1.4			DE72651				Patricia Solano		06/03/2023			Modify method insertOrUpdateAccountQueues to change the queue limit
	1.5			US603731			Sandra Gómez		18/05/2023			Modify method updateOwnerIdFromClient to change queueables
	
***********************************************************************************************************************/
public with sharing class AV_BookManagementMemberTriggerHelper {
	
	/**
	 * @description		 	Check the record types
	 * @param listNews  	list of new records
	 */
	public static List<AV_BookManagementMember__c> checkGeneralRT(List<AV_BookManagementMember__c> listNews){
		Set<Id> setIdsRt = getAllRT();
		Set<String> negocioValues = new Set<String>{'COR', 'CIB', 'INS', 'EMP', 'PRO', 'MIC', 'INT', 'MOR', 'FIN', 'TES', 'CMX', 'RIE'};
        Set<String> tipoNegValues = new Set<String>{'ETR'};

		List<AV_BookManagementMember__c> listData = new List<AV_BookManagementMember__c>();
		for(AV_BookManagementMember__c dataNew : listNews){
			if((setIdsRt).contains(dataNew.RecordTypeId) 
				&& 'S'.equalsIgnoreCase(dataNew.AV_CarteraActiva__c)
				&& (!negocioValues.contains(dataNew.CIBE_NegocioCartera__c)
				|| (String.isNotBlank(dataNew.AV_ExternalID__c) && !tipoNegValues.contains(dataNew.AV_ExternalID__c.substring(5, 8))))) {
				listData.add(dataNew);
			}
		}

		return listData;
	}
	
	/**
	 * @description		 	Get all the ID's of the RT
	 */
	public static Set<Id> getAllRT(){
		Set<String> setLabelsRt = new Set<String>{'AV_CarteraGestor'};
		return AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
	}

	/**
	 * @description		 	Get the ID's of the RT's requested by param
	 * @param setRT			List of the RT
	 */
	public static Set<Id> getIdsRT(Set<AV_AppUtilities.SearchRT> setRT){
		return AV_AppUtilities.getRecordTypeIdsInSet(setRT);
	}
	
	/**
	 * @description		 	Change OwnerId and AV_EAPGestor__c of Account if OwnerId is different to User associated
	 * 						with contact of AV_BookManagementMember__c(AV_EmpleadoGestor__c)
	 * @param listNews		update the owners of the customers
	 */
	public static void updateOwnerIdFromClient(List<AV_BookManagementMember__c> listNews) {
		List<String> employees = new List<String>();
		for(AV_BookManagementMember__c bmm : listNews) {
			employees.add(bmm.AV_EmpleadoGestor__c);
		}

		Map<String, String> mapEmpleUser = new Map<String, String>();
		if (!employees.isEmpty() && Contact.SObjectType.getDescribe().isAccessible() && User.SObjectType.getDescribe().isAccessible()) {
			User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' LIMIT 1];

			for (Contact c : [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE Id IN :employees]) {
				if (String.isNotBlank(c.AV_UsuarioAsociado__c)) {
					mapEmpleUser.put(c.Id, c.AV_UsuarioAsociado__c);
				} else {
					mapEmpleUser.put(c.Id, userCli.Id);
				}
			}
		}

		if (!mapEmpleUser.isEmpty()) {
			Integer maxQueues = 15;
			
			if (!Test.isRunningTest()) {
				maxQueues = (Integer) AV_Bypass__c.getOrgDefaults().AV_MaxQueueSize__c;
			}

			Long chunkSize = ((Decimal)(listNews.size() / maxQueues)).round(System.RoundingMode.DOWN);

			List<AV_BookManagementMember__c> chunk = new List<AV_BookManagementMember__c>();
			Integer cont = 1;
			for(Integer i = 0; i < listNews.size(); i++) {
				chunk.add(listNews[i]);
				if (chunk.size() == chunkSize && cont <= (maxQueues-1)) {
					System.enqueueJob(new AV_BookManagementMemberQueueable(chunk, mapEmpleUser));
					chunk = new List<AV_BookManagementMember__c>();
					cont++;
				}
			}
			
			if (chunk != null && !chunk.isEmpty()) {
				System.enqueueJob(new AV_BookManagementMemberQueueable(chunk, mapEmpleUser));
			}
		}
	}

}