/****************************************************************************************************************************
Name:	  CIBE_UpdateRelatedAccountTeam_Batch
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para actualizar el campo CIBE_AccountTeam__c en los Account cuando se generan nuevos ATM automaticos
-----------------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			DEFECT 		    Luis Martínez       21/12/2023			Init version
******************************************************************************************************************************/

public class CIBE_UpdateRelatedAccountTeam_Batch implements Database.Batchable<sObject>, Database.Stateful {
	public Integer recordsProcessed = 0;
    public static final String BATCHNAME = 'CIBE_UpdateRelatedAccountTeam_Batch';
    public static final String CLIENTE_RT = 'CC_Cliente';    
    private String avQuery;

    public CIBE_UpdateRelatedAccountTeam_Batch(){
        //el fwk de batches necesita un constructor vacío
        system.debug('Constructor - CIBE_UpdateRelatedAccountTeam_Batch');
    }
    public CIBE_UpdateRelatedAccountTeam_Batch(String avQuery){
        this.avQuery = setQuery();
    }
	
	private String setQuery(){        
        List<AccountTeamMember> listaAccTM = [SELECT Id, AccountId, Account.AV_EAPGestor__r.AV_UsuarioAsociado__c, UserId 
        FROM AccountTeamMember 
        WHERE CreatedDate = LAST_N_DAYS:23 AND CIBE_Negocio__c = true AND CIBE_IsAutomatic__c = true AND Account.RecordType.DeveloperName = :CLIENTE_RT LIMIT 1];
        
		if (!listaAccTM.isEmpty()){
			avQuery = 'SELECT Id, AccountId, UserId, Account.AV_EAPGestor__r.AV_UsuarioAsociado__c FROM AccountTeamMember WHERE CreatedDate = LAST_N_DAYS:23 AND CIBE_Negocio__c = true AND CIBE_IsAutomatic__c = true AND Account.RecordType.DeveloperName = :CLIENTE_RT';
		}
        return avQuery;
    }
    
	/**
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
    public Database.QueryLocator start(Database.BatchableContext bc){
        if(String.isBlank(avQuery)){
            avQuery = setQuery();
        }
        return Database.getQueryLocator(avQuery);
    }
    
	/**
	 * Update the Accounts
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<AccountTeamMember> param with the list of Accounts.
	 */
    public void execute(Database.BatchableContext bc, List<AccountTeamMember> scope){
        recordsProcessed = scope.size();
        Map<Id, Set<Id>> userIds = new Map<Id, Set<Id>>();
        if(AccountTeamMember.sObjectType.getDescribe().isAccessible()) {
            for(AccountTeamMember accountTM :scope) {
                if(!userIds.containsKey(accountTM.accountId)) {
                    userIds.put(accountTM.accountId, new Set<Id>());
                }
                userIds.get(accountTM.accountId).add(accountTM.UserId);
            }
        }

        for(Account acc : [SELECT Id, AV_EAPGestor__r.AV_UsuarioAsociado__c FROM Account WHERE Id IN :userIds.KeySet() AND RecordType.DeveloperName = :CIBE_AppConstants.ACCOUNT_CLIENTE_RT]) {
            if(String.isNotBlank(acc.AV_EAPGestor__r.AV_UsuarioAsociado__c)) {
                if(!userIds.containsKey(acc.Id)) {
                    userIds.put(acc.Id, new Set<Id>());
                }
                userIds.get(acc.Id).add(acc.AV_EAPGestor__r.AV_UsuarioAsociado__c);
            }        
        }

        List<Account> toUpdate = new List<Account>();
        for(Id accountId : userIds.keySet()) {
            toUpdate.add(new Account(
                Id = accountId,
                CIBE_AccountTeam__c = String.join(new List<Id>(userIds.get(accountId)), ',')
                ));
        }

		if(toUpdate != null && toUpdate.size()>0){
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


    /**
	 * Print the results of the batch process
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
    public void finish(Database.BatchableContext bc){
        String methodName='finish';
		CBK_Log.debug(BATCHNAME+' '+methodName, 'Record Processes: ' + recordsProcessed);
    }
}