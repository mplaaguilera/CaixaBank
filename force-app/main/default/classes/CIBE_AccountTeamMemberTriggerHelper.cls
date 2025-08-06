/**********************************************************************************************************************
Name:	  CIBE_AccountTeamMemberTriggerHelper
Copyright © 2022  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de AccountTeamMember
----------------------------------------------------------------------------------------------------------------------
Historial 
---------------------
VERSION		USER_STORY			AUTHOR				DATE				Description
1.0								Alex Campos		    27/07/2023			Init version

***********************************************************************************************************************/
public with sharing class CIBE_AccountTeamMemberTriggerHelper {
    /**
     *  @param description: Check the record types, de field delete and if is active
     *  @param listNews: list of new records
     */
    public static List<AccountTeamMember> checkGeneralRT(List<AccountTeamMember> listNews) {
        List<AccountTeamMember> listData = new List<AccountTeamMember>();
        for(AccountTeamMember dataNew : listNews) {
            if(dataNew.CIBE_Negocio__c) {
                listData.add(dataNew);
            }
        }
        return listData;
    }

    public static void setAccountUsers(List<AccountTeamMember> listNewObj) {
        Set<Id> accountIds = new Set<Id>();
        for(AccountTeamMember accTM : listNewObj) {
            accountIds.add(accTM.AccountId);
        }

        List<Account> accounts = new List<Account>();
        if(Account.sObjectType.getDescribe().isAccessible()) {
            accounts = [SELECT Id, AV_EAPGestor__r.AV_UsuarioAsociado__c FROM Account WHERE Id IN :accountIds AND RecordType.DeveloperName = :CIBE_AppConstants.ACCOUNT_CLIENTE_RT LIMIT 1];
        }

        Map<Id, Set<Id>> userIds = new Map<Id, Set<Id>>();
        if(AccountTeamMember.sObjectType.getDescribe().isAccessible()) {
            for(AccountTeamMember accountTM : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :accountIds AND CIBE_IsAutomatic__c = false]) {
                if(!userIds.containsKey(accountTM.accountId)) {
                    userIds.put(accountTM.accountId, new Set<Id>());
                }
                userIds.get(accountTM.accountId).add(accountTM.UserId);
            }
        }

        for(Account acc : accounts) {
            if(String.isNotBlank(acc.AV_EAPGestor__r.AV_UsuarioAsociado__c)) {
                if(!userIds.containsKey(acc.Id)) {
                    userIds.put(acc.Id, new Set<Id>());
                }
                userIds.get(acc.Id).add(acc.AV_EAPGestor__r.AV_UsuarioAsociado__c);
            }        
        }

        List<Account> toUpdate = new List<Account>();
        for(Id accountId : userIds.keySet()) {
            toUpdate.add(
                new Account(
                    Id = accountId,
                    CIBE_AccountTeam__c = String.join(new List<Id>(userIds.get(accountId)), ',')
                ));
        }

        Database.SaveResult[] updates = Database.update(toUpdate, false);

		boolean hasError = false;
		List<Object> objs = new List<Object>();
		Map<String, String> msjs = new Map<String, String>();
		for (Integer i = 0; i < toUpdate.size(); i++) {
			Database.SaveResult dr = updates[i];
			if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
				msjs.put(toUpdate[i].Id, ((String)dr.getErrors()[0].getMessage()));
				objs.add(toUpdate[i]);
				hasError = true;
			}
		}

		if(hasError) {
			CBK_Log.error(msjs, objs);
		}
    }
    
}