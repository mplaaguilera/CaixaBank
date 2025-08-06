/**********************************************************************************************************************
 Name: CIBE_AccTeamMemberFromAccConRel_Batch
 Copyright © 2023  CaixaBank
------------------------------------------------------------------------------------------------------------------------
Proposito: Batch para controlar updates grandes debido a que hay centros asignados a grandes volumenes de clientes
------------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				  DATE				Description
	1.0			US493757	    Alex Pérez	   	      04/05/2023	    Init version
***********************************************************************************************************************/
public without sharing class CIBE_AccTMAccConRel_Batch implements Database.Batchable<sObject>, Database.Stateful {
    public list<id> relationIds = new list<Id>();
    private map<string, AccountContactRelation> accConKeyMap;
    private map<Id, Id> usuarioAsociadoContactMap;
    private map<Id, Id> contactUserMap;

    public CIBE_AccTMAccConRel_Batch() {
        //necesario para el fwk de batches
        system.debug('constructor CIBE_AccTeamMemberFromAccConRel_Batch');
    }

    public CIBE_AccTMAccConRel_Batch(list<Id> relationIds) {
        //para lanzar el batch sin el fwk
        this.relationIds = relationIds;

    }

    private list<id> constructor() {
        list<id> accList = new list<id>();
        list<id> contactList = new list<id>();
        this.accConKeyMap = new map<string, AccountContactRelation>();
        this.usuarioAsociadoContactMap = new map<Id, Id>();
        this.contactUserMap = new map<Id, Id>();
        for(AccountContactRelation accConRel : [SELECT Id, AccountId, contactId, isActive FROM AccountContactRelation WHERE Id IN : this.relationIds]){
            accList.add(accConRel.AccountId);
            this.accConKeyMap.put(accConRel.AccountId + '|' + accConRel.ContactId, accConRel);
            contactList.add(accConRel.ContactId);
        }
        for(Contact con : [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE Id IN : contactList AND recordType.developerName = 'CC_Empleado']){
            if(con.AV_UsuarioAsociado__c != null){
                this.usuarioAsociadoContactMap.put(con.AV_UsuarioAsociado__c, con.Id);
                this.ContactUserMap.put(con.Id, con.AV_UsuarioAsociado__c);
            }
        }
        return accList;
    }

    /**
	 * Delete the selected list of Accounts
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {

        list<id> accList = constructor();
        string sQuery;

        if(this.usuarioAsociadoContactMap.isEmpty()){
            sQuery = 'SELECT Id FROM Account WHERE Id = null';
        } else {
            sQuery = 'SELECT Id, AV_OficinaPrincipal__c, AV_Negocio__c FROM Account WHERE AV_OficinaPrincipal__c IN : accList AND recordType.developerName = \'CC_Cliente\'';
        }
        return Database.getQueryLocator(sQuery);
	}

    public void execute(Database.BatchableContext bc, List<Account> scope){

        map<Id, list<Id>> oficinaPrincipalMap = new map<Id, list<Id>>();
        map<Id, Id> clientesOficinasMap = new map<Id, Id>();
        //List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();
        list<AccountTeamMember> accMemberToDelete = new list<AccountTeamMember>();
        list<AccountTeamMember> accMemberToInsert = new list<AccountTeamMember>();
        list<string> toIgnore = new list<string>();
        list<string> sNegocioCIB = new list<string>{'CIB', 'COR', 'INS', 'BPA'};
        try{
            for(Account acc : scope){
                list<Id> idList;
                boolean bNegocioCIB=false;
                
                //list<string> negocios = ;
                if(acc.AV_Negocio__c !=null){
                    for(string negocio : acc.AV_Negocio__c.split(';')){      
                        if(sNegocioCIB.contains(negocio)){
                            bNegocioCIB=true;
                            break;
                        }  
                    }
                }

                if(bNegocioCIB){
                    continue;
                }
                if(oficinaPrincipalMap.containsKey(acc.AV_OficinaPrincipal__c)){
                    idList = oficinaPrincipalMap.get(acc.AV_OficinaPrincipal__c);
                } else {
                    idList = new list<Id>();
                }
                idList.add(acc.Id);
                oficinaPrincipalMap.put(acc.AV_OficinaPrincipal__c, idList);
                clientesOficinasMap.put(acc.Id, acc.AV_OficinaPrincipal__c);
            }

            if(!oficinaPrincipalMap.isEmpty()) {
                for(AccountTeamMember accMember : [SELECT AccountId, UserId, cibe_isAutomatic__c FROM AccountTeamMember 
                                                    WHERE AccountId IN : clientesOficinasMap.keySet() AND UserId IN : usuarioAsociadoContactMap.keySet()]){
                    Id contactId = usuarioAsociadoContactMap.get(accMember.UserId);
                    Id accountId = clientesOficinasMap.get(accMember.AccountId);
                    if(this.accConKeyMap.containsKey(accountId+ '|' +contactId)) {
                        if(this.accConKeyMap.get(accountId+ '|' +contactId).isActive){
                            toIgnore.add(accMember.AccountId +'|'+ accMember.UserId);
                        } else if(accMember.cibe_isAutomatic__c) {
                            accMemberToDelete.add(accMember);
                        }  
                    }                                
                }
                
                for(AccountContactRelation acr : this.accConKeyMap.values()){
                    list<Id> paco = oficinaPrincipalMap.get(acr.AccountId);
                    if(oficinaPrincipalMap.containsKey(acr.AccountId)) {
                        for(Id clienteId : oficinaPrincipalMap.get(acr.AccountId)){
                            if(!toIgnore.contains(clienteId + '|' + ContactUserMap.get(acr.contactId)) &&
                                acr.isActive && ContactUserMap.containsKey(acr.ContactId)){
                                AccountTeamMember acctoInsert = new AccountTeamMember(
                                    AccountId = clienteId,
                                    UserId = ContactUserMap.get(acr.ContactId),
                                    CIBE_isAutomatic__c = true,
                                    AccountAccessLevel = 'Read',
                                    OpportunityAccessLevel = CIBE_AppConstants.NONE,
                                    CaseAccessLevel = 'Read',
                                    ContactAccessLevel = 'Edit',
                                    TeamMemberRole = 'Participante'
                                );
                                accMemberToInsert.add(acctoInsert);       
                            }
                        }
                    }
                }


                boolean hasError = false;
                List<Object> objs = new List<Object>();
                Map<String, String> msjs = new Map<String, String>();

                Database.SaveResult[] dmlResult = Database.insert(accMemberToInsert, false);
                Database.deleteResult[] deleteResult = Database.delete(accMemberToDelete, false);

                for (Integer i = 0; i < accMemberToInsert.size(); i++) {
                    Database.SaveResult sr = dmlResult[i];
                    if(!sr.isSuccess() && !sr.getErrors().isEmpty() && accMemberToInsert[i] !=null) {
                        msjs.put(accMemberToInsert[i].Id, ((String) sr.getErrors()[0].getMessage()));
                        objs.add(accMemberToInsert[i]);
                        hasError = true;
                        }
                    }
                    for (Integer i = 0; i < accMemberToDelete.size(); i++) {
                        Database.deleteResult dr = deleteResult[i];
                        if(!dr.isSuccess() && !dr.getErrors().isEmpty() && accMemberToDelete[i] !=null) {
                            msjs.put(accMemberToDelete[i].Id, ((String) dr.getErrors()[0].getMessage()));
                            objs.add(accMemberToDelete[i]);
                            hasError = true;
                        }
                    }
                
                if(hasError) {
                    CBK_Log.error(msjs, objs);
                }
            }
        } catch(Exception e) {
            CBK_Log.error(e);
        }
    }

    /**
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	public void finish(Database.BatchableContext bc){
		String methodName='finish';
		//AV_LogDebug.printLogDebug(methodName, 'Record Processes: ' + recordsProcessed);
        system.debug('CIBE_AccConRelTriggerHelper');
	}
}