/**********************************************************************************************************************
Name:	  CIBE_BookManagementMemberTriggerHelper
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Cartera Gestor
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US392789            Jose Maria		    04/10/2022			Init version

***********************************************************************************************************************/
public with sharing class CIBE_BookManagementMemberTriggerHelper {

    /**
	 *  @param description: Check the record types
	 *  @param listNews: list of new records
	 */
	public static List<AV_BookManagementMember__c> checkGeneralRT(List<AV_BookManagementMember__c> listNews){
		Set<Id> setIdsRt = getAllRT();
		Set<String> negocioValues = new Set<String>{'COR', 'CIB', 'INS', 'EMP', 'PRO', 'MIC', 'INT', 'MOR', 'FIN', 'TES', 'CMX', 'RIE'};
        Set<String> tipoNegValues = new Set<String>{'ETR'};

		List<AV_BookManagementMember__c> listData = new List<AV_BookManagementMember__c>();
		for(AV_BookManagementMember__c dataNew : listNews){
			if((setIdsRt).contains(dataNew.RecordTypeId) 
				&& 'S'.equalsIgnoreCase(dataNew.AV_CarteraActiva__c)
				&& (negocioValues.contains(dataNew.CIBE_NegocioCartera__c)
				|| (String.isNotBlank(dataNew.AV_ExternalID__c) && tipoNegValues.contains(dataNew.AV_ExternalID__c.substring(5, 8))))) {
				listData.add(dataNew);
			}
		}

		return listData;
	}
	
	/**
	 *  @param description: Get all the ID's of the RT
	 */
	public static Set<Id> getAllRT() {
		Set<String> setLabelsRt = new Set<String>{'AV_CarteraGestor'};
		return AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
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
				maxQueues = (Integer) AV_Bypass__c.getOrgDefaults().CIBE_MaxQueueSize__c;
			}

			Long chunkSize = ((Decimal)(listNews.size() / maxQueues)).round(System.RoundingMode.DOWN);

			List<AV_BookManagementMember__c> chunk = new List<AV_BookManagementMember__c>();
			Integer cont = 1;
			for(Integer i = 0; i < listNews.size(); i++) {
				chunk.add(listNews[i]);
				if (chunk.size() == chunkSize && cont <= (maxQueues-1)) {
					System.enqueueJob(new CIBE_BookManagementMemberQueueable(chunk, mapEmpleUser));
					chunk = new List<AV_BookManagementMember__c>();
					cont++;
				}
			}
			
			if (chunk != null && !chunk.isEmpty()) {
				System.enqueueJob(new CIBE_BookManagementMemberQueueable(chunk, mapEmpleUser));
			}
		}
	}

}
		/*

		Map<String, AV_BookMember__c> mapBookMember = new Map<String, AV_BookMember__c>();
		if(!mapBookManagement.isEmpty() && AV_BookMember__c.SObjectType.getDescribe().isAccessible()) {
			for (AV_BookMember__c bm : [SELECT Id, AV_Cliente__c, AV_Cartera__c FROM AV_BookMember__c WHERE AV_Cartera__c IN :mapBookManagement.keySet() AND AV_CarteraPrincipal__c = true]) {
				mapBookMember.put(bm.AV_Cliente__c, bm);
			}
		}

		
		Set<Id> listContactEAP = new Set<Id>();
		Set<Id> listContactEAPOld = new Set<Id>();
		List<Account> listAccountUpdate = new List<Account>();
		if(!mapBookMember.isEmpty() && Account.SObjectType.getDescribe().isAccessible()) {
			for(Account acc : [SELECT Id, OwnerId, AV_EAPGestor__c FROM Account WHERE Id = :mapBookMember.keySet()]) {
				if(mapBookMember.containsKey(acc.Id) && mapBookManagement.containsKey(mapBookMember.get(acc.Id).AV_Cartera__c)) {
					AV_BookMember__c carteraCliente = mapBookMember.get(acc.Id);
					AV_BookManagementMember__c carteraGestor = mapBookManagement.get(carteraCliente.AV_Cartera__c);

					if(String.isNotBlank(carteraGestor.AV_EmpleadoGestor__c) && acc.OwnerId != mapEmpleUser.get(carteraGestor.AV_EmpleadoGestor__c)) {
						if (String.isNotBlank(acc.AV_EAPGestor__c) && acc.AV_EAPGestor__c != carteraGestor.AV_EmpleadoGestor__c) {
							listContactEAP.add(carteraGestor.AV_EmpleadoGestor__c);
							listContactEAPOld.add(acc.AV_EAPGestor__c);
						}
						acc.OwnerId = mapEmpleUser.get(carteraGestor.AV_EmpleadoGestor__c);
						acc.AV_EAPGestor__c = carteraGestor.AV_EmpleadoGestor__c;
						listAccountUpdate.add(acc);
					}
				}
			}
		
			if (!listAccountUpdate.isEmpty() && Account.SObjectType.getDescribe().isAccessible()) {
				Integer maxQueues = 15;
				Integer maxQueueSize = 100;
				
				if (!Test.isRunningTest()) {
					maxQueues = (Integer) AV_Bypass__c.getOrgDefaults().CIBE_MaxQueueSize__c;
					maxQueueSize = (Integer) AV_Bypass__c.getOrgDefaults().CIBE_BMMMaxQueueSize__c;
				}

				List<Account> chunk = new List<Account>();
				Map<Id, Account> oldAccounts = new Map<Id, Account>([SELECT  Id, OwnerId, AV_EAPGestor__c FROM Account WHERE Id = :mapBookMember.keySet()]);
				Integer cont = 1;
				for(Integer i = 0; i < listAccountUpdate.size(); i++) {
					chunk.add(listAccountUpdate[i]);
					if (chunk.size() == maxQueueSize && cont <= (maxQueues-1)) {
						System.enqueueJob(new CIBE_BookManagementMemberQueueable(chunk, chunk, oldAccounts ,listContactEAP,listContactEAPOld, new List<Opportunity>(), new List<Task>(), new List<Event>()));
						chunk = new List<Account>();
						cont++;
					}
				}
				
				if (chunk != null && !chunk.isEmpty()) {
					System.enqueueJob(new CIBE_BookManagementMemberQueueable(chunk, chunk, oldAccounts, listContactEAP,listContactEAPOld, new List<Opportunity>(), new List<Task>(), new List<Event>()));
				}
			}	
		}
		*/