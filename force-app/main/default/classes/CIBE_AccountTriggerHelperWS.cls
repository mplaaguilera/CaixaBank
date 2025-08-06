/********************************************************************************************************************
Name: CIBE_AccountTriggerHelperWS
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Helper para el trigger de account donde se encuentra el recalculo de relaciones en la tabla de accountTeamMember
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			    	        									Init version
    1.1         US493757       Alex Perez        28/03/2023      	Añadiendo al recálculo el cambio de oficina principal
	1.2			US632725	   Alex Perez		 26/06/2023			Excluir negocio CIBE del recálculo por cambio de oficina
	1.3			US632725	   Luis Martínez	 16/01/2024			Cambio para recuperar el error en la creación 

************************************************************************************************************************/
public without sharing class CIBE_AccountTriggerHelperWS {
    
    public static Map<Id, List<AccountTeamMember>> teamMembersPerClient = new Map<Id, List<AccountTeamMember>>();

	/**
	 * @description		 Save AccountTeamMembers if owner changes
	 * @param  listNews  list of new account records
	 * @param mapOlds    map of old account records
	 */
	public static void queryTeamMembers(List<Account> listNews, Map<Id, Account> mapOlds) {
		Map<Id, Account> processOwnerTeamMembers = new Map<Id, Account>();
		List<Id> processOfficeTeamMembers = new List<Id>();
		map<Id, list<Id>> newAccountsOffice = new map<Id, list<Id>>();
		map<Id, list<Id>> oldAccountsOffice = new map<Id, list<Id>>();
		map<Id, list<Id>> contactsOffice = new map<Id, list<Id>>();
		map<Id, list<Id>> officesContact = new map<Id, list<Id>>();
		map<Id, Id> usuarioRegistradoMap = new map<Id, Id>();
		map<Id, Id> contactURMap = new map<Id, Id>();
		list<AccountTeamMember> teamMemberToDelete = new list<AccountTeamMember>();
		list<string> toIgnore = new list<string>();
		list<string> sNegocioCIB = new list<string>{'CIB', 'COR', 'INS', 'BPA'};
		for(Account client : listNews) {
			if(client.OwnerId != mapOlds.get(client.Id).OwnerId) {
				processOwnerTeamMembers.put(client.Id, client);
			}
			boolean bNegocioCIB = false;
			for(string negocio : client.AV_Negocio__c.split(';')){      
				if(sNegocioCIB.contains(negocio)){
					bNegocioCIB=true;
					break;
				}  
			}
			if(bNegocioCIB){
				continue;
			}

			if(mapOlds == null || client.AV_OficinaPrincipal__c != mapOlds.get(client.Id).AV_OficinaPrincipal__c){
				processOfficeTeamMembers.add(client.Id);
				if(client.AV_OficinaPrincipal__c != null){
					if(!newAccountsOffice.containsKey(client.AV_OficinaPrincipal__c)){
						newAccountsOffice.put(client.AV_OficinaPrincipal__c, new List<Id>());
					}
					newAccountsOffice.get(client.AV_OficinaPrincipal__c).add(client.Id);
				}
				if(mapOlds != null && mapOlds.get(client.Id).AV_OficinaPrincipal__c != null){
					if(!oldAccountsOffice.containsKey(mapOlds.get(client.Id).AV_OficinaPrincipal__c)){
						oldAccountsOffice.put(mapOlds.get(client.Id).AV_OficinaPrincipal__c, new List<Id>());
					}
					oldAccountsOffice.get(mapOlds.get(client.Id).AV_OficinaPrincipal__c).add(client.Id);
				}
			}	
		}

		for( AccountContactRelation acr : [SELECT ID, AccountId, ContactId 
													FROM AccountContactRelation 
													WHERE isActive = true AND FinServ__SourceSystemId__c LIKE 'CIBE%' AND
													( AccountId IN : newAccountsOffice.keySet() OR AccountId IN : oldAccountsOffice.keySet())]) {
			if(!contactsOffice.containsKey(acr.AccountId)){
				contactsOffice.put(acr.AccountId, new List<Id>());
			}
			if(!OfficesContact.containsKey(acr.ContactId)){
				OfficesContact.put(acr.ContactId, new List<Id>());
			}
			contactsOffice.get(acr.AccountId).add(acr.ContactId);
			OfficesContact.get(acr.ContactId).add(acr.AccountId);
		}


		for(Contact con : [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE recordType.developerName = 'CC_Empleado' AND Id IN : OfficesContact.keySet()]){
			if(con.AV_UsuarioAsociado__c!=null){
				usuarioRegistradoMap.put(con.Id, con.AV_UsuarioAsociado__c);
				contactURmap.put(con.AV_UsuarioAsociado__c, con.Id);
			}
		}

		if(!processOwnerTeamMembers.isEmpty() || !processOfficeTeamMembers.isEmpty()) {
			List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();
			
			if(Schema.SObjectType.AccountTeamMember.isAccessible()) {
				accountTeamMembers = [SELECT AccountId, UserId, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel, 
										CaseAccessLevel, ContactAccessLevel, CIBE_IsAutomatic__c, AV_Tipo__c
										FROM AccountTeamMember WHERE AccountId = :processOwnerTeamMembers.keySet() 
										OR (AccountId IN : processOfficeTeamMembers AND UserId IN : usuarioRegistradoMap.values())];
			}

			for(AccountTeamMember teamMember : accountTeamMembers) {
				if(processOfficeTeamMembers.contains(teamMember.AccountId)){
					boolean eliminate = false;
					if(contactURmap.containsKey(teamMember.UserId) && OfficesContact.containsKey(contactURmap.get(teamMember.UserId)) && teamMember.CIBE_IsAutomatic__c){
						for(id officeId : OfficesContact.get(contactURmap.get(teamMember.UserId))){
							if(oldAccountsOffice.containsKey(OfficeId) && oldAccountsOffice.get(OfficeId).contains(teamMember.AccountId)){
								teamMemberToDelete.add(teamMember);
								eliminate = true;
								break;
							}
						}
					}
					if(!eliminate){
						toIgnore.add(teamMember.AccountId + '|' + teamMember.UserId);
					}

				} else {
					teamMember.Id = null;
					addTeamMembers(teamMember, teamMember.AccountId);
				}	
			}

			boolean hasError = false;
			List<Object> objs = new List<Object>();
			Map<String, String> msjs = new Map<String, String>();
			if(!teamMemberToDelete.isEmpty() && AccountTeamMember.SObjectType.getDescribe().isDeletable()) {
                Database.DeleteResult[] lsr = Database.delete(teamMemberToDelete, false);
				for (Integer i = 0; i < lsr.size(); i++) {
					if(!lsr[i].isSuccess() && !lsr[i].getErrors().isEmpty()) {
						msjs.put(teamMemberToDelete[i].Id, ((String)lsr[i].getErrors()[0].getMessage()));
						objs.add(teamMemberToDelete[i]);
						hasError = true;
					}
                }
			}
			if(hasError) {
				CBK_Log.error(msjs, objs);
			}

			if(!newAccountsOffice.isEmpty() && !contactsOffice.isEmpty()){
				for(id officeId : newAccountsOffice.keySet()){
					for(Id accountId : newAccountsOffice.get(officeId)){
						if(contactsOffice.containsKey(officeId)){
							for(Id contactId : contactsOffice.get(officeId)){
								AccountTeamMember accMember;
								if(!toIgnore.contains(accountId + '|' + usuarioRegistradoMap.get(contactId))){
									accMember = new AccountTeamMember(
										AccountId = accountId,
										UserId = usuarioRegistradoMap.get(contactId),
										CIBE_isAutomatic__c = true,
										AccountAccessLevel = 'Read',
										OpportunityAccessLevel = CIBE_AppConstants.NONE,
										CaseAccessLevel = 'Read',
										ContactAccessLevel = 'Edit',
										TeamMemberRole = 'Participante'
									);
									addTeamMembers(accMember, accountId);
								}	
							}
						}
					}
				}
			}
		}
	}

	/**
	 * @description		 Commit AccountTeamMembers if owner changes
	 * @param  listNews  list of new account records
	 * @param mapOlds    map of old account records
	 */
	public static void commitTeamMembers(List<Account> listNews, Map<Id, Account> mapOlds) {
        if(!teamMembersPerClient.isEmpty()) {
            List<AccountTeamMember> teamMembers = new List<AccountTeamMember>();
            for(List<AccountTeamMember> tMs : teamMembersPerClient.values()) {
                teamMembers.addAll(tMs);
            }
			boolean hasError = false;
			List<Object> objs = new List<Object>();
			Map<String, String> msjs = new Map<String, String>();
			if(Schema.SObjectType.AccountTeamMember.isCreateable()) {
                Database.SaveResult[] lsr = Database.insert(teamMembers, false);
				for (Integer i = 0; i < lsr.size(); i++) {
					if(!lsr[i].isSuccess() && !lsr[i].getErrors().isEmpty() && teamMembers[i].userId!=null) {
						msjs.put(teamMembers[i].userId, ((String)lsr[i].getErrors()[0].getMessage()));
						objs.add(teamMembers[i]);
						hasError = true;
					}
                }
			}
			if(hasError) {
				CBK_Log.error(msjs, objs);
			}
		}
	}

	/**
	 * @description add to the global map the team members to insert
	 * @param teamMember  accountTeamMember to add to the map
	 * @param accountId Id of the account of the team member related
	 */
	public static void addTeamMembers(accountTeamMember teamMember, Id accountId) {
		if(!teamMembersPerClient.containsKey(accountId)) {
			teamMembersPerClient.put(accountId, new List<AccountTeamMember>());
		}
		teamMembersPerClient.get(accountId).add(teamMember);
	}

}