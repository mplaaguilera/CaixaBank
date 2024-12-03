/**********************************************************************************************************************
	Name:  CIBE_AccountTriggerHelper
	Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Account.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	                            AUTHOR		   		DATE				Description
	1.0			Confidencialidad clientes		        Luis Martínez	   	03/11/2022		    Init version
	2.0			US425471								Jose Maria			21/11/2022			updateRatingPD
	3.0			Mejora de querys						Jose Maria			21/11/2022			Se han implementado mejoras en las querys	
***********************************************************************************************************************/
public with sharing class CIBE_AccountTriggerHelper {

private static AV_AppUtilities.SearchRT cliente 	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_ACCOUNT, 'CC_Cliente');
private static Set<Id> setRtAll 		= getAllRT();
private static Set<Id> setRtCliente 	= getIdsRT(new Set<AV_AppUtilities.SearchRT>{cliente});

    /**
     * @description		 	Check the record types
     * @param listNews  	list of new records
     */
    public static List<Account> checkGeneralRT(List<Account> listNews){
        List<Account> listData = new List<Account>();
        for(Account dataNew : listNews){
            if((setRtCliente).contains(dataNew.RecordTypeId)){
                listData.add(dataNew);
            }
        }
        return listData;
    }

	/**
	 * @description		 	Get all the ID's of the RT
	 */
	public static Set<Id> getAllRT(){
		Set<AV_AppUtilities.SearchRT> setLabelsRt = new Set<AV_AppUtilities.SearchRT>{cliente};
		return AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
	}

/**
* @description       Get the ID's of the RT's requested by param
* @param setRT      List of the RT
*/
public static Set<Id> getIdsRT(Set<AV_AppUtilities.SearchRT> setRT){
	return AV_AppUtilities.getRecordTypeIdsInSet(setRT);
}


/**
	 * @description     Updates the customer's related opportunity confidentiality
	 * @param listNews  list of new account records
	 * @param mapOlds   map of old account records
	 */

	public static void updateRatingPD(List<Account> listNews) {
		//comprobar acceso a query
		List<Decimal> listPDAcc = new List<Decimal>();
		for(Account acc : listNews){
			listPDAcc.add(acc.CIBE_PD__c);
		}

        if(!listPDAcc.isEmpty()){
            List<CIBE_PD__c> listPD = new List<CIBE_PD__c>();
            if(
                CIBE_PD__c.SObjectType.getDescribe().isAccessible()&&
                Schema.SObjectType.CIBE_PD__c.fields.CIBE_PDRating__c.isAccessible()&&
                Schema.SObjectType.CIBE_PD__c.fields.CIBE_FechaCarga__c.isAccessible()&&
                Schema.SObjectType.CIBE_PD__c.fields.CIBE_PDMax__c.isAccessible()&&
                Schema.SObjectType.CIBE_PD__c.fields.CIBE_PDMin__c.isAccessible()
            ) {
                
                listPD = [select id, CIBE_PDRating__c,CIBE_FechaCarga__c, CIBE_PDMin__c, CIBE_PDMax__c from CIBE_PD__c where CIBE_PDMin__c<= :listPDAcc and CIBE_PDMax__c>= :listPDAcc order by CIBE_PDMax__c desc];
            }
    
            if(!listPD.isEmpty()){
                for(Account acc : listNews){
                    if(acc.CIBE_PD__c != null){
                        for(CIBE_PD__c pd : listPD){
                            if(acc.CIBE_PD__c>=pd.CIBE_PDMin__c && acc.CIBE_PD__c<=pd.CIBE_PDMax__c){
                                acc.CIBE_Rating_SP__c = '('+ pd.CIBE_PDRating__c + ')';
                                acc.CIBE_FechaRating_SP__c =  pd.CIBE_FechaCarga__c;
                            }
                        }
                    }else{
                        acc.CIBE_Rating_SP__c = null;
                    }
                }
            }
        }
	}

	/**
	 * @description     Updates the customer's related opportunity confidentiality
	 * @param listNews  list of new account records
	 * @param mapOlds   map of old account records
	 */

	public static void updateOppConfidentiality(List<Account> listNews, Map<Id, Account> mapOlds) {
		Map<Id, Boolean> cliConfidentiality = new Map<Id, Boolean>();
		Map<Id, Boolean> cliEmployee= new Map<Id, Boolean>();
		List<Account> listNewsVal = getNegocio(listNews);
		List<Opportunity> allOpps = new List<Opportunity>();
        String methodName = 'updateOppConfidentiality';
        Integer successfulUr = 0;
		if(listNewsVal.size()>0){
			listNewsVal=listNews.clone();
		}

		if(mapOlds != null && !mapOlds.isEmpty()) {
			for (Account cli : listNewsVal) {
				if (((cli.AV_Confidencial__c != mapOlds.get(cli.Id).AV_Confidencial__c) && cli.AV_Confidencial__c) ||
                (cli.AV_Empleado__c != mapOlds.get(cli.Id).AV_Empleado__c)) {
					cliConfidentiality.put(cli.Id, cli.AV_Confidencial__c);
					cliEmployee.put(cli.Id, cli.AV_Empleado__c);
				}
			}
			if (!cliConfidentiality.isEmpty()) {
				if(
					Opportunity.SObjectType.getDescribe().isAccessible()&&
					Schema.SObjectType.Opportunity.fields.AV_ClienteConfidencial__c.isAccessible()&&
					Schema.SObjectType.Opportunity.fields.AccountId.isAccessible()&&
					Schema.SObjectType.Opportunity.fields.AV_EmployeeCustomer__c.isAccessible()
				) {
                   
					allOpps = [Select Id, AV_ClienteConfidencial__c, AccountId, AV_EmployeeCustomer__c 
                	FROM Opportunity 
                	WHERE AccountId in :cliConfidentiality.keySet() AND RecordType.DeveloperName LIKE '%CIBE%' ];
				}
			}
			if(!allOpps.isEmpty()){
				for (Opportunity opp : allOpps) {
					opp.AV_ClienteConfidencial__c = cliConfidentiality.get(opp.AccountId);
					opp.AV_EmployeeCustomer__c = cliEmployee.get(opp.AccountId);
				}
				List<Database.SaveResult> sr = Database.update(allOpps, false);
				for (Database.SaveResult res : sr) {
					if (res.isSuccess()) {                                                                                                                                                                                                                                                                                                                                                                          
						successfulUr++;
					}
				}
				AV_LogDebug.printLogDebug(methodName, 'Opportunities updated: ' + successfulUr + ' out of ' + sr.size());
			}			
		}
	}

    /**
	 * @description     Updates the customer's related Event confidentiality
	 * @param listNews  list of new account records
	 * @param mapOlds   map of old account records
	 */

	public static void updateEvntConfidentiality(List<Account> listNews, Map<Id, Account> mapOlds) {
		Map<Id, Boolean> cliConfidentiality = new Map<Id, Boolean>();
		Map<Id, Boolean> cliEmployee = new Map<Id, Boolean>();
		List<Account> listNewsVal = new List<Account>();
		List<Event> allEvent = new List<Event>();
		List<Event> toUpdateEvent = new List<Event>();
        String methodName = 'updateEvntConfidentiality';
        Integer successfulUr = 0;
		listNewsVal = getNegocio(listNews);
		if(listNewsVal.size()>0){
			listNewsVal=listNews.clone();
		}

		if(mapOlds != null && !mapOlds.isEmpty()) {
				for (Account cli : listNewsVal) {
					if (((cli.AV_Confidencial__c != mapOlds.get(cli.Id).AV_Confidencial__c) && cli.AV_Confidencial__c) ||
					(cli.AV_Empleado__c != mapOlds.get(cli.Id).AV_Empleado__c)) {
					cliConfidentiality.put(cli.Id, cli.AV_Confidencial__c);
					cliEmployee.put(cli.Id, cli.AV_Empleado__c);
				}
			}
			if (!cliConfidentiality.isEmpty()) {
				if(
					Event.SObjectType.getDescribe().isAccessible()&&
					Schema.SObjectType.Event.fields.CIBE_Confidential__c.isAccessible()&&
					Schema.SObjectType.Event.fields.AccountId.isAccessible()&&
					Schema.SObjectType.Event.fields.AV_CodigoGestorAsignado__c.isAccessible()
				) {
				allEvent = [Select Id, CIBE_Confidential__c, AccountId, AV_CodigoGestorAsignado__c 
							FROM Event 
							WHERE (AccountId in :cliConfidentiality.keySet() OR WhatId in :cliConfidentiality.keySet()) AND
							RecordType.DeveloperName LIKE '%CIBE%' ];	
				}
			}
			if(!allEvent.isEmpty()){
				for (Event evt : allEvent) {
					if(!evt.CIBE_Confidential__c){
						evt.CIBE_Confidential__c = cliConfidentiality.get(evt.AccountId);
						toUpdateEvent.add(evt);
					}
				}
				List<Database.SaveResult> sr = Database.update(toUpdateEvent, false);
				for (Database.SaveResult res : sr) {
					if (res.isSuccess()) {
						successfulUr++;
					}
				}
				AV_LogDebug.printLogDebug(methodName, 'Event updated: ' + successfulUr + ' out of ' + sr.size());			
			}
		}
	}

	/**
	 * @description     Updates the customer's related Event confidentiality
	 * @param listNews  list of new account records
	 * @param mapOlds   map of old account records
	 */

	public static void updateTaskConfidentiality(List<Account> listNews, Map<Id, Account> mapOlds) {
		Map<Id, Boolean> cliConfidentiality = new Map<Id, Boolean>();
		Map<Id, Boolean> cliEmployee= new Map<Id, Boolean>();
		List<Task> allTask = new List<Task>();
        String methodName = 'updateTaskConfidentiality';
        Integer successfulUr = 0;
		List<Account> listNewsVal = getNegocio(listNews);

		if(listNewsVal.size()>0){
			listNewsVal=listNews.clone();
		}

		if(mapOlds != null && !mapOlds.isEmpty()) {
			for (Account cli : listNewsVal) {
				if (((cli.AV_Confidencial__c != mapOlds.get(cli.Id).AV_Confidencial__c) && cli.AV_Confidencial__c) ||
                (cli.AV_Empleado__c != mapOlds.get(cli.Id).AV_Empleado__c)) {
					cliConfidentiality.put(cli.Id, cli.AV_Confidencial__c);
					cliEmployee.put(cli.Id, cli.AV_Empleado__c);
				}
			}
			if (!cliConfidentiality.isEmpty()) {
				if(
					Task.SObjectType.getDescribe().isAccessible()&&
					Schema.SObjectType.Task.fields.CIBE_Confidential__c.isAccessible()&&
					Schema.SObjectType.Task.fields.AccountId.isAccessible()&&
					Schema.SObjectType.Task.fields.AV_CodigoGestorAsignado__c.isAccessible()
				) {
				allTask = [Select Id, CIBE_Confidential__c, AccountId, AV_CodigoGestorAsignado__c 
							FROM Task 
							WHERE (AccountId in :cliConfidentiality.keySet() OR WhatId in :cliConfidentiality.keySet()) AND RecordType.DeveloperName LIKE '%CIBE%'];	
				}
			}
			if(!allTask.isEmpty()){
				for (Task tas : allTask) {
					tas.CIBE_Confidential__c = cliConfidentiality.get(tas.AccountId);
				}
				List<Database.SaveResult> sr = Database.update(allTask, false);
				for (Database.SaveResult res : sr) {
					if (res.isSuccess()) {
						successfulUr++;
					}
				}
				AV_LogDebug.printLogDebug(methodName, 'Task updated: ' + successfulUr + ' out of ' + sr.size());
			}
		}
	}

	/**	
	 * @description	Get all the ID's of the RT
	 */
    public static List<Account> getNegocio(List<Account> lstCliente) {
        List<AV_BookMember__c> lstLibros = new List<AV_BookMember__c>();
		Set<Id> setBookMember = new Set<Id>();
		String carteraCliente ='AV_CarteraCliente';
		String ese ='S';
		Set<Id> setIdsCliente = new Set<Id>();
		Set<Id> setIdsNegocidos = new Set<Id>();
		List<Account> lstClienteVal = new List <Account>(); 
		Set<String> negocioValues = new Set<String>{'COR', 'CIB', 'INS', 'EMP', 'MIC', 'PRO', 'PYM'};

		if(lstCliente.size()>0){
			for(Account acc:  lstCliente){
				setIdsCliente.add(acc.Id);
			}
			if(
				AV_BookMember__c.SObjectType.getDescribe().isAccessible()&&
				Schema.SObjectType.AV_BookMember__c.fields.AV_Cliente__c.isAccessible()
			) {
			lstLibros   = 	[SELECT AV_Cliente__c
				FROM AV_BookMember__c 
				WHERE  AV_Cliente__c in :setIdsCliente AND AV_Cartera__r.AV_Activa__c=:ese AND RecordType.developername =:carteraCliente
				AND  AV_Cartera__r.AV_Negocio__c in :negocioValues];
			}
			if(!lstLibros.isEmpty()){
				for(AV_BookMember__c bkm:lstLibros){
					setBookMember.add(bkm.AV_Cliente__c);
				}
				for(Account acc:lstCliente){
					if(setBookMember.contains(acc.id)){
						lstClienteVal.add(acc);
					}
				}
			}
		}

		return lstClienteVal;
    }

	/**
	 * @description		 Update the employee owners when the EAP Gestor change
	 * @param  listNews  list of new account records
	 * @param mapOlds    map of old account records
	 */
	public static void processEAPGestorUser(List<Account> listNews, Map<Id, Account> mapOlds) {
		if(!System.isBatch() && !System.isQueueable()) {
			Set<Id> eapGestorsIds = new Set<Id>();
			List<Account> lstClientes = new List<Account>();
			Set<Id> eapGestorsIdsOld = new Set<Id>();
			List<Account> lstClientesOld = new List<Account>();
			if(mapOlds != null && !mapOlds.isEmpty()) {
				for(Account cli : listNews) {
					if((setRtAll).contains(cli.RecordTypeId) && String.isNotBlank(cli.AV_EAPGestor__c) && cli.AV_EAPGestor__c != mapOlds.get(cli.Id).AV_EAPGestor__c){
						lstClientes.add(cli);
						eapGestorsIds.add(cli.AV_EAPGestor__c);
						lstClientesOld.add(mapOlds.get(cli.Id));
						eapGestorsIdsOld.add(mapOlds.get(cli.Id).AV_EAPGestor__c);
					} else if ((setRtAll).contains(cli.RecordTypeId) && String.isBlank(cli.AV_EAPGestor__c) 
							&& cli.AV_EAPGestor__c != mapOlds.get(cli.Id).AV_EAPGestor__c) {
						lstClientes.add(cli);
						lstClientesOld.add(mapOlds.get(cli.Id));
						eapGestorsIdsOld.add(mapOlds.get(cli.Id).AV_EAPGestor__c);
					}
				}
			}else{
				for(Account cli : listNews) {
					if((setRtAll).contains(cli.RecordTypeId) && String.isNotBlank(cli.AV_EAPGestor__c)){
						lstClientes.add(cli);
						eapGestorsIds.add(cli.AV_EAPGestor__c);
					}
				}
			}

			if(lstClientes != null && !lstClientes.isEmpty()) {
				CIBE_GestorReassignmentFuture.processRelatedToAccount(
					JSON.serialize(lstClientes), 
					eapGestorsIds, 
					JSON.serialize(lstClientesOld), 
					eapGestorsIdsOld, 
					true);
			}
		}
	}

}