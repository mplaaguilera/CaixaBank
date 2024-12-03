/**********************************************************************************************************************
 Name:	  AV_AccountTriggerHelper
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Account.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	                            AUTHOR		   		DATE				Description
	1.0			SF - Palabras prohibidas. Error		    Álvaro López	   	06/10/2020		    Init version
	1.0         US124210                                Jashanpreet Singh   08/10/2020         	Add method processOwnerEAPGestor
	1.1         US92299                                 Eric Vazquez        14/10/2020          Add modify user
	1.2			Check RT								David Rufo			09/12/2020			Improve common method to check RT + general RT
	1.3			US180910								Sandra Gómez		02/03/2021			Add method accountValueOficinaPrincipalRelacionas
	1.4			DE46491/DE46686		                    Sandra Gómez		02/06/2021			Change method processEAPGestorUser and processOwnerEAPGestor
	1.5			Fix Confidencial            		    Víctor Santiago	   	04/10/2021		    Created method updateOppConfidentiality
	1.6			DE52465									Sandra Gómez		30/09/2021			Refactor EAP/Gestor
	1.7			US245181								Daniel Rodríguez	01/12/2021			Include AV_EmployeeCustomer__c field in updateOppConfidentiality method
	1.8			AV_Query IT								Daniel Rodríguez	03/02/2022			Change AV_Query to SOQL for User, Account, Contact
	1.9			US310702								Luis Fernández		19/02/2022			Modify method processOwnerEapGestores to assign GFC user to accounts with no EAP and Book
	2.0													Vladislav Lityagin	01/03/2023			Modify relatedAccountAndLead reducing code
	2.1			US603731								Sandra Gómez		18/05/2023			Modify proccessEAPGestorUser include not isQueueable
***********************************************************************************************************************/

public with sharing class AV_AccountTriggerHelper {

	private static AV_AppUtilities.SearchRT clientePA 	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_ACCOUNT, 'CC_ClientePA');
	private static AV_AppUtilities.SearchRT cliente 	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_ACCOUNT, 'CC_Cliente');
	private static Set<Id> setRtAll 		= getAllRT();
	private static Set<Id> setRtClientePA 	= getIdsRT(new Set<AV_AppUtilities.SearchRT>{clientePA});
	private static Set<Id> setRtCliente 	= getIdsRT(new Set<AV_AppUtilities.SearchRT>{cliente});
	
	/**
	 * @description		 	Check the record types
	 * @param listNews  	list of new records
	 */
	public static List<Account> checkGeneralRT(List<Account> listNews){
		List<Account> listData = new List<Account>();
		for(Account dataNew : listNews){
			if((setRtAll).contains(dataNew.RecordTypeId)){
				listData.add(dataNew);
			}
		}
		return listData;
	}
	
	/**
	 * @description		 	Get all the ID's of the RT
	 */
	public static Set<Id> getAllRT(){
		Set<AV_AppUtilities.SearchRT> setLabelsRt = new Set<AV_AppUtilities.SearchRT>{clientePA, cliente};
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
	 * @description		 Validate forbidden words in Account field 
	 * @param  listNews  list of new account records
	 * @param mapOlds map of old account records
	 */
	/*public static void validateForbiddenWords(List<Account> listNews, Map<Id, Account> mapOlds) {
		List<Account> listToProcess = new List<Account>();
		Set<String> setFields = new Set<String>{'Description'};
			
		if(mapOlds != null && !mapOlds.isEmpty()) {
			for(Account cli : listNews) {
				if((setRtAll).contains(cli.RecordTypeId) && String.isNotBlank(cli.Description) && mapOlds.get(cli.Id).Description != cli.Description) {
					listToProcess.add(cli);
				}
			}
		} else {
			for(Account cli : listNews) {
				if((setRtAll).contains(cli.RecordTypeId) && String.isNotBlank(cli.Description)) {
					listToProcess.add(cli);
				}
			}
		}
		
		if(listToProcess!=null && !listToProcess.isEmpty()) {
			AV_ForbiddenWords.validateRecords(listToProcess, setFields);
		}
	}*/

	/**
	 * @description		 Procces owners of accounts where field EAP Gestor has changed
	 * @param  listNews  list of new account records
	 * @param mapOlds    map of old account records
	 */
	public static void processOwnerEAPGestor(List<Account> listNews, Map<Id, Account> mapOlds){
		Set<Id> eapGestorsIds = new Set<Id>();
		List<Account> lstClientes = new List<Account>();
		List<Account> lstClientesSinEap = new List<Account>();
		List<AV_BookMember__c> accountsWithNoBook = new List<AV_BookMember__c>();
		Set<Id> accountsWithNoBookIds = new Set<Id>();
		if(mapOlds != null && !mapOlds.isEmpty()) {
			for(Account cli : listNews) {
				//Update EAP Gestor with different employee
				if((setRtAll).contains(cli.RecordTypeId) && String.isNotBlank(cli.AV_EAPGestor__c)
						&& cli.AV_EAPGestor__c != mapOlds.get(cli.Id).AV_EAPGestor__c){
					lstClientes.add(cli);
					eapGestorsIds.add(cli.AV_EAPGestor__c);
				}
				//Update EAP Gestor without employee
				else if ((setRtAll).contains(cli.RecordTypeId) && String.isBlank(cli.AV_EAPGestor__c) 
						&& cli.AV_EAPGestor__c != mapOlds.get(cli.Id).AV_EAPGestor__c) {
					lstClientesSinEap.add(cli);
				}
			}
		}else{
			for(Account cli : listNews) {
				//Update EAP Gestor with different employee
				if((setRtAll).contains(cli.RecordTypeId) && String.isNotBlank(cli.AV_EAPGestor__c)){
					lstClientes.add(cli);
					eapGestorsIds.add(cli.AV_EAPGestor__c);
				}else if((setRtAll).contains(cli.RecordTypeId) && String.isBlank(cli.AV_EAPGestor__c)){
					lstClientesSinEap.add(cli);

				}
			}
		}
		//Get the default user for the clients without EAP Gestor
		// User userCli = [Select Id From User Where Profile.Name = 'API Only' and Alias = 'FC-TF9' limit 1];
		User userCli = [Select Id From User Where Profile.Name = 'API Only' and Alias = 'AV-TF9' limit 1];
		List<Contact> sinGestorEap = [SELECT Id FROM CONTACT WHERE AV_UsuarioAsociado__r.Alias = 'AV-TF9' LIMIT 1];
		//Iteramos la lista de clientes a los que se le has quitado el EAP o han sido creados sin uno.
		if (lstClientesSinEap!=null && !lstClientesSinEap.isEmpty() && !sinGestorEap.isEmpty()) {
			accountsWithNoBook= [SELECT AV_Cliente__c FROM AV_BookMember__c WHERE AV_Cliente__c IN :lstClientesSinEap];
			for (AV_BookMember__c bm : accountsWithNoBook) {
				accountsWithNoBookIds.add(bm.AV_Cliente__c);
			}
			for(Account acc : lstClientesSinEap) {
				if (userCli != null){
					acc.OwnerId = userCli.Id;			
					if(!accountsWithNoBookIds.contains(acc.Id)){
						acc.AV_EAPGestor__c = sinGestorEap[0].Id;
					}
				}
			}
		}	
		if(eapGestorsIds!=null && !eapGestorsIds.isEmpty()) {
			Map<Id,Id> mapEAPGestorUser = new Map<Id,Id>();
			List<Contact> listEmployees= [Select Id, AV_UsuarioAsociado__c From Contact Where Id in :eapGestorsIds and AV_UsuarioAsociado__r.IsActive = true];
			if(listEmployees != null && !listEmployees.isEmpty()){
				for(Contact c : listEmployees){
					mapEAPGestorUser.put(c.Id, c.AV_UsuarioAsociado__c);
				}
				for(Account acc : lstClientes){
					if(mapEAPGestorUser.get(acc.AV_EAPGestor__c) != null){
						acc.OwnerId = mapEAPGestorUser.get(acc.AV_EAPGestor__c);
					} 
					else if (userCli != null){
						acc.OwnerId = userCli.Id;
					}
				}
			} else {
				for(Account acc : lstClientes) {
					if (userCli != null){
						acc.OwnerId = userCli.Id;
						if (!sinGestorEap.isEmpty()) {
							acc.AV_EAPGestor__c = sinGestorEap[0].Id;
						}
					}
				}
			}
		} 
	}

	/**
	 * @description		 Update the date when the description is updated
	 * @param  lstClientes  list of new account records
	 */
	public static void descriptionLastModifiedDate(List<Account> lstClientes){
		for(Account cliente : lstClientes){
			if((setRtClientePA).contains(cliente.RecordTypeId) && String.isNotBlank(cliente.Description)){
				cliente.AV_FechaUltimaActualizacion__c = datetime.now();
			}
		}
	}

	/**
	 * @description		 Update the user and last modified date when the description is updated
	 * @param  listNews  list of new account records
	 * @param mapOlds    map of old account records
	 */
	public static void descriptionLastModifiedDateAndUser(List<Account> listNews, Map<Id, Account> mapOlds){
		//Get current user modify description
		User user = [Select Id,AV_ExternalID__c From User where Id = :UserInfo.getUserId() limit 1];
		if(mapOlds != null && !mapOlds.isEmpty()){
			for(Account cliente : listNews){
				if((setRtAll).contains(cliente.RecordTypeId) && String.isNotBlank(cliente.Description) 
						&& !(cliente.Description).equalsIgnoreCase(mapOlds.get(cliente.Id).Description)){
					cliente.AV_FechaUltimaActualizacion__c = datetime.now();
					cliente.AV_ModifyByUser__c = user.AV_ExternalId__c;
				}
				else if((setRtAll).contains(cliente.RecordTypeId) && String.isNotBlank(cliente.Description) 
						&& (((cliente.AV_FechaUltimaActualizacion__c) < (mapOlds.get(cliente.Id).AV_FechaUltimaActualizacion__c))
						|| ((cliente.AV_FechaUltimaActualizacion__c) > (mapOlds.get(cliente.Id).AV_FechaUltimaActualizacion__c)))
						&& (cliente.Description).equalsIgnoreCase(mapOlds.get(cliente.Id).Description)){
					cliente.AV_FechaUltimaActualizacion__c = datetime.now();
					cliente.AV_ModifyByUser__c = user.AV_ExternalId__c;
				}                
			}    
		}	
	}

	/**
	 * @description		 Update the employee owners when the EAP Gestor change
	 * @param  listNews  list of new account records
	 * @param mapOlds    map of old account records
	 */
	public static void processEAPGestorUser(List<Account> listNews, Map<Id, Account> mapOlds) {
		if(!System.isBatch() && !System.isQueueable()){
			AV_LogDebug.printLogDebug('processEAPGestorUser', '@@Entro en processEAPGestorUser: ');
			Set<Id> eapGestorsIds = new Set<Id>();
			List<Account> lstClientes = new List<Account>();
			Set<Id> eapGestorsIdsOld = new Set<Id>();
			List<Account> lstClientesOld = new List<Account>();
			if(mapOlds != null && !mapOlds.isEmpty()) {
				for(Account cli : listNews) {
					if((setRtAll).contains(cli.RecordTypeId) && String.isNotBlank(cli.AV_EAPGestor__c)
							&& cli.AV_EAPGestor__c != mapOlds.get(cli.Id).AV_EAPGestor__c){
						lstClientes.add(cli);
						eapGestorsIds.add(cli.AV_EAPGestor__c);
						lstClientesOld.add(mapOlds.get(cli.Id));
						eapGestorsIdsOld.add(mapOlds.get(cli.Id).AV_EAPGestor__c);
					}
					//TODO: its necessary to check for Clients with EAP Gestor
					else if ((setRtAll).contains(cli.RecordTypeId) && String.isBlank(cli.AV_EAPGestor__c) 
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

			if(lstClientes!=null && !lstClientes.isEmpty()) {
				AV_GestorReassignmentFuture.processRelatedToAccount(JSON.serialize(lstClientes), eapGestorsIds, JSON.serialize(lstClientesOld), eapGestorsIdsOld,true);
			}
		}
	}


	/**
	 * @description		 Create a Account if Account has AV_OficinaPrincipalRelacionas__c
	 * @param  listNews  list of new Account records
	 */
	public static void accountValueOficinaPrincipalRelacionas(List<Account> listNews) {
		List<Account> lstToProcess = new List<Account>();
		Map<Id,Account> mapAcc = new Map<Id,Account>();

		for(Account acc : listNews) {
			lstToProcess.add(acc);
			mapAcc.put(acc.AV_OficinaPrincipal__c, acc);
		}

		if(!lstToProcess.isEmpty()) {
			List<Account> listAcc = [Select Id, CC_Numero_Oficina_Empresa__c From Account where Id = :mapAcc.keySet()];
			Map<Id,Account> mapAcc2 = new Map<Id,Account>();
			for(Account acc : listAcc){
				mapAcc2.put(acc.id, acc);
			}
			for(Account acc : lstToProcess){
				if (!String.isEmpty(acc.AV_OficinaPrincipal__c)) {
					Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
					if(mapAcc2.containsKey(acc.AV_OficinaPrincipal__c) && acc.RecordTypeId != accRecordTypeId) {
						if (String.isEmpty(acc.AV_OficinasRelacionadas__c)) {
							acc.AV_OficinaPrincipalRelacionas__c=mapAcc2.get(acc.AV_OficinaPrincipal__c).CC_Numero_Oficina_Empresa__c.substring(4,9);
						} else {
							acc.AV_OficinaPrincipalRelacionas__c=mapAcc2.get(acc.AV_OficinaPrincipal__c).CC_Numero_Oficina_Empresa__c.substring(4,9)+', '+acc.AV_OficinasRelacionadas__c;
						}
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
		String methodName = 'updateOppConfidentiality';
		Integer successfulUr = 0;
		if(mapOlds != null && !mapOlds.isEmpty()) {
			for (Account cli : listNews) {
				if ((cli.AV_Confidencial__c != mapOlds.get(cli.Id).AV_Confidencial__c) || (cli.AV_Empleado__c != mapOlds.get(cli.Id).AV_Empleado__c)) {
					cliConfidentiality.put(cli.Id, cli.AV_Confidencial__c);
					cliEmployee.put(cli.Id, cli.AV_Empleado__c);
				}
			}
			if (!cliConfidentiality.isEmpty()) {
				List<Opportunity> allOpps = [Select Id, AV_ClienteConfidencial__c, AccountId, AV_EmployeeCustomer__c From Opportunity Where AccountId in :cliConfidentiality.keySet()];								
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
	 * @description     getLeads for method relatedAccountAndLead
	 * @param identifications  set of string with AV_CustomerId__c
	 */
	public static Map<String, Lead> getLeads(Set<String> identifications){
		String methodName = 'getLeads';
		List<Lead> leadsList = new List<Lead>();
		leadsList = [SELECT AV_CustomerId__c, AV_Birthdate__c, AV_IsClient__c FROM Lead WHERE AV_CustomerId__c in :identifications AND RecordType.DeveloperName =: AV_AppConstants.LEAD_PPHH_RT];
		Map<String, Lead> mapLeads = new Map<String, Lead>();
		for(Lead l : leadsList){
			mapLeads.put(l.AV_CustomerId__c, l);
		}
		return mapLeads;
	}

	/**
	 * @description     getLeadOpps for method relatedAccountAndLead
	 * @param identifications  set of string with AV_Lead__r.AV_CustomerId__c
	 */
	public static Map<String, AV_LeadOpportunity__c> getLeadOpps(Set<String> identifications){
		String methodName = 'getLeadOpps';
		List<AV_LeadOpportunity__c> leadOppList = new List<AV_LeadOpportunity__c>();
		leadOppList = [SELECT Id, AV_DueDate__c, AV_Status__c, AV_Lead__r.AV_CustomerId__c FROM AV_LeadOpportunity__c WHERE AV_Lead__r.AV_CustomerId__c in :identifications AND (AV_Status__c='Nuevo' OR AV_Status__c='Enviada oferta comercial' OR AV_Status__c='Activo') AND RecordType.DeveloperName =: AV_AppConstants.LEAD_PPHH_RT];
		Map<String, AV_LeadOpportunity__c> mapLeadOpps = new Map<String, AV_LeadOpportunity__c>();
		for(AV_LeadOpportunity__c lo : leadOppList){
			mapLeadOpps.put(lo.AV_Lead__r.AV_CustomerId__c, lo);
		}
		return mapLeadOpps;
	}

	/**
	 * @description     Update lead and leadopportunity according to the client
	 * @param listAccs   list of new account records
	 */
	public static void relatedAccountAndLead(List<Account> listAccs){
		String methodName = 'relatedAccountAndLead';
		//Nos insertan muchos accounts en el proceso nocturno, de estos accounts podemos obtener el DNI y Fecha Nacimiento --> Usarlas para buscar los leads
		Map<String, Account> accMap = new Map<String, Account>();
		Map<String, Lead> mapLeads = new Map<String, Lead>();
		//El ID del Mapa hace referencia al ID del Lead, no del Lead Oportunidad.        
		Map<String, AV_LeadOpportunity__c> mapLeadOpps = new Map<String, AV_LeadOpportunity__c>();
		RecordType rtPAccount = AV_AppUtilities.getRecordType('Account', 'CC_ClientePA');
		List<Lead> leadsToUpdate = new List<Lead>();
		List<AV_LeadOpportunity__c> leadOppsToUpdate = new List<AV_LeadOpportunity__c>();
		Set<String> identifications = new Set<String>();
		for(Account a : listAccs){
			//Como sabemos que es un cliente particular y va a tener los campos informados lo metemos en el mapa
			if(a.RecordTypeId.equals(rtPAccount.Id)){
				identifications.add(a.CC_Identificador__c);
			}   
		}
		//Buscamos primero los leads que tengan el mismo DNI que los Accounts que hayan entrado
		if(identifications!=null){
			mapLeads = getLeads(identifications);
			mapLeadOpps = getLeadOpps(identifications);
		}
		if(!mapLeads.isEmpty()){
			//Recorrer los accounts nuevamente en busca del Lead que tenga su mismo dni y fecha nac.
			for(Account a : listAccs){
				if(mapLeads.get(a.CC_Identificador__c)!=null){
					Lead l = mapLeads.get(a.CC_Identificador__c);
					if(l != null){
						if(l.AV_Birthdate__c==a.PersonBirthdate){
							//Aqui tenemos el cruce ya hecho, es decir, tenemos el lead con el mismo DNI y fecha nac que el account
							//Si el isclient de account == true, el valor del Lead lo tenemos que poner también a true
							if(a.AV_Cliente__c){
								//Si ha sido marcado como cliente tenemos que blanquear la fecha vencimiento del lead oportunidad.
								if(mapLeadOpps.get(a.CC_Identificador__c)!=null){
									AV_LeadOpportunity__c lo = mapLeadOpps.get(a.CC_Identificador__c);
									lo.AV_DueDate__c = null;
									leadOppsToUpdate.add(lo);
									l.AV_IsClient__c=true;
									//El lead hay que vincularlo con el account, rellenandole el numperso
									l.AV_numperso__c = a.Id;
									leadsToUpdate.add(l);
								}
							}else{
								l.AV_IsClient__c=false;
								leadsToUpdate.add(l);
							}
						}
					}
				}
			}
		}
		Database.DMLOptions dmlOptions = new Database.DMLOptions();
		dmlOptions.OptAllOrNone = false;
		dmlOptions.EmailHeader.triggerUserEmail = false;
		if(leadsToUpdate.size()>0){
			Database.SaveResult[] srList = Database.update(leadsToUpdate, dmlOptions);
			AV_AppUtilities.displayErrors('relatedAccountAndLead', srList);
		}
		if(leadOppsToUpdate.size()>0){
			Database.SaveResult[] srList = Database.update(leadOppsToUpdate, dmlOptions);
			AV_AppUtilities.displayErrors('relatedAccountAndLead', srList);
		}
	}
}